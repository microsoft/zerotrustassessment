<#
.SYNOPSIS
    Checks that every agent identity and blueprint has a sponsor, an entitlement-management
    access package targets agents, and a Lifecycle Workflow contains an agent-sponsor task.

.DESCRIPTION
    This test evaluates three independent sub-conditions of AI_004 identity governance for agents:

    Sub-condition A — Sponsorship presence: Every agent identity (microsoft.graph.agentIdentity)
    and every agent identity blueprint (microsoft.graph.agentIdentityBlueprint) has at least one
    effective sponsor. A group sponsor counts only if it has at least one transitive member.
    Agent identity blueprint principals are out of scope.

    Sub-condition B — Entitlement-management channel: At least one access package assignment
    policy in the tenant has allowedTargetScope set to 'allDirectoryAgentIdentities'.

    Sub-condition C — Lifecycle-automation pillar: At least one Lifecycle Workflow contains an
    enabled task whose taskDefinitionId matches one of the three documented agent-identity sponsor
    tasks (Send email to manager about sponsorship changes, Send email to co-sponsors about sponsor
    changes, or Transfer agent identity sponsorships to manager).

    The test passes only when all three sub-conditions pass.

    Agent identities (Q1) and blueprints (Q2) are read from the exported database.

.NOTES
    Test ID: 61013
    Category: AI Authentication & Access
    Required permissions: AgentIdentity.Read.All, AgentIdentity-Sponsor.Read.All,
                          GroupMember.Read.All, EntitlementManagement.Read.All,
                          LifecycleWorkflows-Workflow.Read.All on Microsoft Graph
#>

function Test-Assessment-61013 {
    [ZtTest(
        Category = 'AI Authentication & Access',
        ImplementationCost = 'Low',
        Service = ('Graph'),
        CompatibleLicense = ('AAD_PREMIUM&AGENT_365'),
        Pillar = 'AI',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 61013,
        Title = 'Identity governance for agents — sponsors assigned, entitlement-management channel exists, and lifecycle automation in place',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    # Agent-identity sponsor task definition IDs (from spec)
    $agentSponsorTaskDefinitionIds = @(
        'b8c4e1f9-3a7d-4b2e-9c5f-8d6a9b1c2e3f', # Send email to manager about sponsorship changes
        'ad3b85cd-75b1-43e7-b4b9-0e52faba3944',  # Send email to co-sponsors about sponsor changes
        'b8f4c3d5-9e7a-4b1c-8f2d-6a5e8b9c7f4a'  # Transfer agent identity sponsorships to manager
    )

    $activity = 'Checking agent identity governance'

    # Q1: Agent identities from dedicated AgentIdentity table (pre-filtered cast collection with sponsors expanded)
    $q1QueryError = $null
    $agentIdentities = @()
    Write-ZtProgress -Activity $activity -Status 'Getting agent identities with sponsors (Q1)'
    try {
        $sqlAgentIdentities = @"
SELECT id, agentAppId AS appId, displayName, accountEnabled,
    to_json(sponsors) as sponsorsJson
FROM AgentIdentity
ORDER BY displayName
"@
        $agentIdentityRows = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlAgentIdentities)
        $agentIdentities = @($agentIdentityRows | ForEach-Object {
            $sponsorsParsed = if ($_.sponsorsJson -and $_.sponsorsJson -ne 'null') {
                @($_.sponsorsJson | ConvertFrom-Json)
            } else { @() }
            [PSCustomObject]@{
                Kind           = 'agentIdentity'
                id             = $_.id
                appId          = $_.appId
                displayName    = $_.displayName
                accountEnabled = $_.accountEnabled
                sponsors       = $sponsorsParsed
            }
        })
    }
    catch {
        $q1QueryError = $_
        Write-PSFMessage "Failed to get agent identities: $_" -Tag Test -Level Warning
    }

    # Q2: Agent identity blueprints from dedicated AgentIdentityBlueprint table (pre-filtered cast collection with sponsors expanded)
    $q2QueryError = $null
    $agentBlueprints = @()
    Write-ZtProgress -Activity $activity -Status 'Getting agent identity blueprints with sponsors (Q2)'
    try {
        $sqlAgentBlueprints = @"
SELECT id, appId, displayName,
    to_json(sponsors) as sponsorsJson
FROM AgentIdentityBlueprint
ORDER BY displayName
"@
        $agentBlueprintRows = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlAgentBlueprints)
        $agentBlueprints = @($agentBlueprintRows | ForEach-Object {
            $sponsorsParsed = if ($_.sponsorsJson -and $_.sponsorsJson -ne 'null') {
                @($_.sponsorsJson | ConvertFrom-Json)
            } else { @() }
            [PSCustomObject]@{
                Kind        = 'agentIdentityBlueprint'
                id          = $_.id
                appId       = $_.appId
                displayName = $_.displayName
                sponsors    = $sponsorsParsed
            }
        })
    }
    catch {
        $q2QueryError = $_
        Write-PSFMessage "Failed to get agent identity blueprints: $_" -Tag Test -Level Warning
    }

    # Skip: no agent identities or blueprints → Microsoft Entra Agent ID not in use
    if ($null -eq $q1QueryError -and $null -eq $q2QueryError -and
        $agentIdentities.Count -eq 0 -and $agentBlueprints.Count -eq 0) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q3: Transitive member counts for every group used as a sponsor (ConsistencyLevel: eventual)
    $q3QueryError = $null
    $groupHasMembers = @{}
    $sourcesForQ3 = @()
    if ($null -eq $q1QueryError) { $sourcesForQ3 += $agentIdentities }
    if ($null -eq $q2QueryError) { $sourcesForQ3 += $agentBlueprints }

    $uniqueGroupIds = @($sourcesForQ3 |
        ForEach-Object { $_.sponsors } |
        Where-Object {
            $null -ne $_ -and (
                $_.'@odata.type' -eq '#microsoft.graph.group' -or
                ($null -eq $_.'@odata.type' -and $null -ne $_.PSObject.Properties['mailEnabled'])
            )
        } |
        Select-Object -ExpandProperty id -Unique)

    Write-ZtProgress -Activity $activity -Status 'Resolving group sponsor member counts (Q3)'
    if ($uniqueGroupIds.Count -gt 0) {
        try {
            $groupCountResults = Invoke-ZtGraphBatchRequest `
                -Path 'groups/{0}/transitiveMembers/$count' `
                -ArgumentList $uniqueGroupIds `
                -Header @{ 'ConsistencyLevel' = 'eventual' } `
                -NoPaging `
                -Matched `
                -ErrorAction SilentlyContinue
            foreach ($countResult in $groupCountResults) {
                $gid = $countResult.Argument
                if ($countResult.Success) {
                    $groupHasMembers[$gid] = ([int]($countResult.Result | Select-Object -First 1) -gt 0)
                }
                else {
                    $groupHasMembers[$gid] = $false
                    Write-PSFMessage "Failed to get member count for group ${gid}: $($countResult.Status)" -Tag Test -Level Warning
                }
            }
        }
        catch {
            $q3QueryError = $_
            Write-PSFMessage "Failed to get group member counts: $_" -Tag Test -Level Warning
        }
    }

    # Q4: Assignment policies targeting agent identities — v1.0, server-side filtered to allDirectoryAgentIdentities,
    # with $expand=accessPackage to inline the parent package (id, displayName, catalogId) in a single round-trip.
    $q4QueryError = $null
    $agentTargetingPolicies = @()
    Write-ZtProgress -Activity $activity -Status 'Getting entitlement management assignment policies (Q4)'
    try {
        $agentTargetingPolicies = @(Invoke-ZtGraphRequest `
            -RelativeUri 'identityGovernance/entitlementManagement/assignmentPolicies' `
            -ApiVersion v1.0 `
            -QueryParameters @{ '$select' = 'id,displayName,allowedTargetScope'; '$expand' = 'accessPackage'; '$filter' = "allowedTargetScope eq 'allDirectoryAgentIdentities'" } `
            -ErrorAction Stop)
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 403 -or $_.Exception.Message -like '*403*' -or $_.Exception.Message -like '*Forbidden*' -or $_.Exception.Message -like '*accessDenied*') {
            Write-PSFMessage 'Skipping test: Entra ID Governance licensing is required for entitlement management assignment policies.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDGovernance
            return
        }
        $q4QueryError = $_
        Write-PSFMessage "Failed to get assignment policies: $_" -Tag Test -Level Warning
    }

    # Q5: Lifecycle workflows list
    $q5QueryError = $null
    $lifecycleWorkflows = @()
    Write-ZtProgress -Activity $activity -Status 'Getting lifecycle workflows (Q5)'
    try {
        $lifecycleWorkflows = @(Invoke-ZtGraphRequest `
            -RelativeUri 'identityGovernance/lifecycleWorkflows/workflows' `
            -ApiVersion beta `
            -QueryParameters @{ '$select' = 'id,displayName,category,isEnabled' } `
            -ErrorAction Stop)
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 403 -or $_.Exception.Message -like '*403*' -or $_.Exception.Message -like '*Forbidden*' -or $_.Exception.Message -like '*accessDenied*') {
            Write-PSFMessage 'Skipping test: Entra ID Governance licensing is required for lifecycle workflows.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDGovernance
            return
        }
        $q5QueryError = $_
        Write-PSFMessage "Failed to get lifecycle workflows: $_" -Tag Test -Level Warning
    }

    # Q6: Full workflow details with tasks (batched, tasks expanded by default)
    $q6QueryError = $null
    $workflowDetails = @()
    if ($lifecycleWorkflows.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Getting lifecycle workflow task details (Q6)'
        try {
            $workflowIds = @($lifecycleWorkflows | Select-Object -ExpandProperty id)
            $workflowDetailResults = Invoke-ZtGraphBatchRequest `
                -Path 'identityGovernance/lifecycleWorkflows/workflows/{0}' `
                -ArgumentList $workflowIds `
                -ApiVersion beta `
                -NoPaging `
                -Matched `
                -ErrorAction SilentlyContinue
            $workflowDetails = @($workflowDetailResults | Where-Object { $_.Success -and $_.Result } | Select-Object -ExpandProperty Result)
        }
        catch {
            $q6QueryError = $_
            Write-PSFMessage "Failed to get lifecycle workflow details: $_" -Tag Test -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic

    # Sub-condition A: sponsorship presence
    # Every agentIdentity and agentIdentityBlueprint must have ≥1 effective sponsor.
    # A group sponsor counts only if it has ≥1 transitive member.
    $subConditionAPass = $true
    $sponsorshipFailures = @()

    if ($null -ne $q1QueryError -or $null -ne $q2QueryError -or $null -ne $q3QueryError) {
        $subConditionAPass = $false
    }
    else {
        foreach ($agentObject in @(@($agentIdentities) + @($agentBlueprints))) {
            $objectKind = $agentObject.Kind

            $sponsors = @($agentObject.sponsors | Where-Object { $null -ne $_ })
            $hasEffectiveSponsor = $false
            $emptyGroupIds = @()

            foreach ($sponsor in $sponsors) {
                # @odata.type may be absent when Graph omits it from expanded sponsor objects.
                # Fall back to property heuristic: groups always have mailEnabled; users never do.
                $odataType = $sponsor.'@odata.type'
                if (-not $odataType) {
                    $odataType = if ($null -ne $sponsor.PSObject.Properties['mailEnabled']) {
                        '#microsoft.graph.group'
                    } else {
                        '#microsoft.graph.user'
                    }
                }
                if ($odataType -eq '#microsoft.graph.user') {
                    $hasEffectiveSponsor = $true
                    break
                }
                if ($odataType -eq '#microsoft.graph.group') {
                    if ($groupHasMembers.ContainsKey($sponsor.id) -and $groupHasMembers[$sponsor.id]) {
                        $hasEffectiveSponsor = $true
                        break
                    }
                    else {
                        $emptyGroupIds += $sponsor.id
                    }
                }
                # Service principals and other non-user/non-group types are not valid effective sponsors
            }

            if (-not $hasEffectiveSponsor) {
                $subConditionAPass = $false
                $failureReason = if ($sponsors.Count -eq 0) {
                    'no sponsors assigned'
                }
                else {
                    $groupSuffix = if ($emptyGroupIds.Count -gt 0) { " ($($emptyGroupIds -join ', '))" } else { '' }
                    "only empty-group sponsors$groupSuffix"
                }
                $sponsorshipFailures += [PSCustomObject]@{
                    ObjectKind    = $objectKind
                    DisplayName   = $agentObject.displayName
                    AppId         = $agentObject.appId
                    ObjectId      = $agentObject.id
                    FailureReason = $failureReason
                }
            }
        }
    }

    # Sub-condition B: entitlement-management channel
    # ≥1 assignment policy with allowedTargetScope == 'allDirectoryAgentIdentities'
    $subConditionBPass = $false
    if ($null -eq $q4QueryError) {
        $subConditionBPass = ($agentTargetingPolicies.Count -ge 1)
    }

    # Sub-condition C: lifecycle-automation pillar
    # ≥1 lifecycle workflow with ≥1 ENABLED task matching a known agent-sponsor taskDefinitionId
    $subConditionCPass = $false
    $matchingWorkflowTasks = @()

    if ($null -eq $q5QueryError -and $null -eq $q6QueryError) {
        foreach ($workflow in $workflowDetails) {
            foreach ($task in @($workflow.tasks | Where-Object { $null -ne $_ })) {
                if ($task.isEnabled -and
                    ($agentSponsorTaskDefinitionIds -contains $task.taskDefinitionId)) {
                    $subConditionCPass = $true
                    $matchingWorkflowTasks += [PSCustomObject]@{
                        WorkflowDisplayName = $workflow.displayName
                        WorkflowId          = $workflow.id
                        WorkflowCategory    = $workflow.category
                        WorkflowIsEnabled   = $workflow.isEnabled
                        TaskDisplayName     = $task.displayName
                        TaskDefinitionId    = $task.taskDefinitionId
                        TaskIsEnabled       = $task.isEnabled
                    }
                }
            }
        }
    }

    $passed = $subConditionAPass -and $subConditionBPass -and $subConditionCPass

    if ($passed) {
        $testResultMarkdown = "✅ Every agent identity and agent identity blueprint in the tenant has at least one sponsor assigned, at least one access package has an assignment policy that grants access to agent identities, and at least one Lifecycle Workflow contains at least one enabled agent-identity sponsor task.`n`n%TestResult%"
    }
    else {
        $failingConditions = @()
        if (-not $subConditionAPass) { $failingConditions += 'sponsorship' }
        if (-not $subConditionBPass) { $failingConditions += 'entitlement-management channel' }
        if (-not $subConditionCPass) { $failingConditions += 'lifecycle-automation pillar' }
        $testResultMarkdown = "❌ One or more agent identities or blueprints have no sponsor assigned, OR no access package in the tenant has an assignment policy targeting agent identities (``allowedTargetScope == 'allDirectoryAgentIdentities'``), OR no Lifecycle Workflow contains an enabled task whose ``taskDefinitionId`` matches one of the three documented agent-identity sponsor tasks. Failed: $($failingConditions -join '; ').`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $maxTableRows = 10
    $agentsPortalLink            = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AllAgents.MenuView/~/allAgentIds'
    $accessPackagePortalLink     = 'https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/AccessPackages'
    $lifecycleWorkflowPortalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_LifecycleManagement/CommonMenuBlade/~/workflows'

    $formatTemplate = @'


## [{0}]({1})

{2}

'@

    $mdInfo = ''

    # Section 1: Sponsorship failures (only emitted when sub-condition A fails)
    $sectionA = ''
    if (-not $subConditionAPass) {
        $contentA = if ($null -ne $q1QueryError -or $null -ne $q2QueryError -or $null -ne $q3QueryError) {
            '❌ Unable to evaluate sponsorship: query failed or permissions are insufficient.'
        }
        else {
            $tableRowsA = ''
            $displayedA = 0
            foreach ($failure in ($sponsorshipFailures | Sort-Object ObjectKind, DisplayName)) {
                if ($displayedA -ge $maxTableRows) { break }
                $portalLink = if ($failure.ObjectKind -eq 'agentIdentity') {
                    "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($failure.ObjectId)/appId/$($failure.AppId)"
                } else {
                    "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/overview/appId/$($failure.AppId)"
                }
                $tableRowsA += "| $(Get-SafeMarkdown $failure.ObjectKind) | [$(Get-SafeMarkdown $failure.DisplayName)]($portalLink) | $($failure.FailureReason) |`n"
                $displayedA++
            }
            $truncationNoteA = if ($sponsorshipFailures.Count -gt $maxTableRows) {
                "`n_**Note**: This table is truncated and showing the first $maxTableRows out of $($sponsorshipFailures.Count) total._"
            } else { '' }
            "| Object kind | Display name | Failure reason |`n| :--- | :--- | :--- |`n$tableRowsA$truncationNoteA"
        }
        $sectionA = $formatTemplate -f 'Agent identities and blueprints without an effective sponsor', $agentsPortalLink, $contentA
    }

    # Section 2: Access packages targeting agent identities (always emitted when B is evaluated)
    $contentB = if ($null -ne $q4QueryError) {
        '❌ Unable to evaluate entitlement management policies: query failed or permissions are insufficient.'
    }
    elseif ($agentTargetingPolicies.Count -gt 0) {
        $tableRowsB = ''
        $displayedB = 0
        foreach ($policy in $agentTargetingPolicies) {
            if ($displayedB -ge $maxTableRows) { break }
            $pkg        = $policy.accessPackage
            $pkgRawName = if ($pkg) { $pkg.displayName } else { $null }
            $pkgCell    = if ($pkgRawName) { Get-SafeMarkdown $pkgRawName } else { '—' }
            $tableRowsB += "| $pkgCell | $(Get-SafeMarkdown $policy.displayName) | $(Get-SafeMarkdown $policy.allowedTargetScope) |`n"
            $displayedB++
        }
        $truncationNoteB = if ($agentTargetingPolicies.Count -gt $maxTableRows) {
            "`n_**Note**: This table is truncated and showing the first $maxTableRows out of $($agentTargetingPolicies.Count) total._"
        } else { '' }
        "| Access package display name | Policy display name | Allowed target scope |`n| :--- | :--- | :--- |`n$tableRowsB$truncationNoteB"
    }
    else {
        'No access package has an agent-targeting policy.'
    }
    $sectionB = $formatTemplate -f 'Access packages and policies that grant access to agent identities', $accessPackagePortalLink, $contentB

    # Section 3: Lifecycle Workflows with agent-identity sponsor tasks (always emitted when C is evaluated)
    $contentC = if ($null -ne $q5QueryError -or $null -ne $q6QueryError) {
        '❌ Unable to evaluate lifecycle workflows: query failed or permissions are insufficient.'
    }
    elseif ($matchingWorkflowTasks.Count -gt 0) {
        $tableRowsC = ''
        $displayedC = 0
        foreach ($entry in $matchingWorkflowTasks) {
            if ($displayedC -ge $maxTableRows) { break }
            $wfEnabledText   = if ($entry.WorkflowIsEnabled) { '✅ Yes' } else { '❌ No' }
            $taskEnabledText = if ($entry.TaskIsEnabled) { '✅ Yes' } else { '❌ No' }
            $wfNameEncoded   = [System.Uri]::EscapeDataString($entry.WorkflowDisplayName)
            $wfPortalLink    = "https://entra.microsoft.com/#view/Microsoft_AAD_LifecycleManagement/DetailedWorkflowMenuBlade/~/overview/workflowId/$($entry.WorkflowId)/workflowName/$wfNameEncoded"
            $tableRowsC += "| [$(Get-SafeMarkdown $entry.WorkflowDisplayName)]($wfPortalLink) | $($entry.WorkflowCategory) | $wfEnabledText | $(Get-SafeMarkdown $entry.TaskDisplayName) | $taskEnabledText |`n"
            $displayedC++
        }
        $truncationNoteC = if ($matchingWorkflowTasks.Count -gt $maxTableRows) {
            "`n_**Note**: This table is truncated and showing the first $maxTableRows out of $($matchingWorkflowTasks.Count) total._"
        } else { '' }
        "| Workflow display name | Workflow category | Workflow enabled | Matching task display name | Task enabled |`n| :--- | :--- | :--- | :--- | :--- |`n$tableRowsC$truncationNoteC"
    }
    else {
        'No Lifecycle Workflow contains an enabled agent-identity sponsor task.'
    }
    $sectionC = $formatTemplate -f 'Lifecycle Workflows containing agent-identity sponsor tasks', $lifecycleWorkflowPortalLink, $contentC

    $mdInfo = "$sectionA$sectionB$sectionC"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    $params = @{
        TestId = '61013'
        Title  = 'Identity governance for agents — sponsors assigned, entitlement-management channel exists, and lifecycle automation in place'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
    #endregion Report Generation
}
