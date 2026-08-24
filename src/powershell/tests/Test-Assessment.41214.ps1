<#
.SYNOPSIS
    At least one Microsoft Sentinel automation rule executes a playbook for automated threat response.

.DESCRIPTION
    Enumerates Sentinel-onboarded Log Analytics workspaces and evaluates every RunPlaybook
    action. Each workspace passes only when it has an eligible action and every eligible action
    references an existing, enabled Logic App. The tenant passes only when every evaluated
    Sentinel workspace passes.

.NOTES
    Test ID: 41214
    Workshop Task: SECOPS_109
    Pillar: SecOps
    Category: Security information and event management
    Required API: Azure Resource Manager (management.azure.com)
#>
function Test-Assessment-41214 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        Service = ('Azure'),
        SfiPillar = 'Accelerate response and remediation',
        TenantType = ('Workforce'),
        TestId = 41214,
        Title = 'At least one Microsoft Sentinel automation rule executes a playbook for automated threat response',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking playbook automation in Microsoft Sentinel workspaces'

    # Sentinel workspace discovery and onboarding checks are provided by the shared helper.
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces -or $allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41214'
            Title        = 'At least one Microsoft Sentinel automation rule executes a playbook for automated threat response'
            Status       = $false
            Result       = '⚠️ Automation rules or the referenced Logic App could not be read.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -in @('NoSubscriptions', 'NoWorkspaces')) {
        Write-PSFMessage 'No Sentinel-onboarded workspaces are available for playbook evaluation.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces  = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces  = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardedWorkspaces  = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })
    $unresolvedWorkspaces = @($checkableWorkspaces | Where-Object { $_.OnboardingError })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0 -or $unresolvedWorkspaces.Count -gt 0) {
            $params = @{
                TestId       = '41214'
                Title        = 'At least one Microsoft Sentinel automation rule executes a playbook for automated threat response'
                Status       = $false
                Result       = '⚠️ Automation rules or the referenced Logic App could not be read.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            Write-PSFMessage 'No Sentinel-onboarded workspaces were found.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Q1: List automation rules for each Sentinel-onboarded workspace.
    $rulesByWorkspace = @{}
    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching automation rules for '$($workspace.WorkspaceName)' in '$($workspace.SubscriptionName)'"
        $automationRulesPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/automationRules?api-version=2024-09-01"

        try {
            $rules = @(Invoke-ZtAzureRequest -Path $automationRulesPath -ErrorAction Stop)
            $malformedRule = @($rules | Where-Object {
                    $null -eq $_.properties -or
                    $null -eq $_.properties.triggeringLogic -or
                    $null -eq $_.properties.actions
                }).Count -gt 0
            $rulesByWorkspace[$workspace.WorkspaceId] = [PSCustomObject]@{
                Rules      = $rules
                QueryError = $malformedRule
            }
        }
        catch {
            $rulesByWorkspace[$workspace.WorkspaceId] = [PSCustomObject]@{
                Rules      = @()
                QueryError = $true
            }
            Write-PSFMessage "Error querying automation rules for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    # Q2 depends on Q1. Collect each distinct supported playbook response once; rule eligibility
    # and all verdicts are calculated later in Assessment Logic.
    $playbookResponses = @{}
    $now               = [DateTimeOffset]::UtcNow

    foreach ($workspace in $onboardedWorkspaces) {
        if ($rulesByWorkspace[$workspace.WorkspaceId].QueryError) {
            continue
        }

        foreach ($rule in $rulesByWorkspace[$workspace.WorkspaceId].Rules) {
            $runPlaybookActions = @($rule.properties.actions | Where-Object { $_.actionType -eq 'RunPlaybook' })
            if ($runPlaybookActions.Count -eq 0 -or $rule.properties.triggeringLogic.isEnabled -ne $true) {
                continue
            }

            $expiration = $rule.properties.triggeringLogic.expirationTimeUtc
            if (-not [string]::IsNullOrWhiteSpace([string]$expiration)) {
                $parsedExpiration = [DateTimeOffset]::MinValue
                if (-not [DateTimeOffset]::TryParse([string]$expiration, [ref]$parsedExpiration) -or $parsedExpiration -le $now) {
                    continue
                }
            }

            foreach ($action in $runPlaybookActions) {
                $logicAppResourceId = [string]$action.actionConfiguration.logicAppResourceId
                if ([string]::IsNullOrWhiteSpace($logicAppResourceId) -or $logicAppResourceId -notmatch '(?i)/providers/Microsoft\.Logic/workflows/') {
                    continue
                }

                $playbookKey = $logicAppResourceId.ToLowerInvariant()
                if ($playbookResponses.ContainsKey($playbookKey)) {
                    continue
                }

                Write-ZtProgress -Activity $activity -Status "Resolving playbook referenced by '$($rule.properties.displayName)'"
                try {
                    $playbookResponses[$playbookKey] = [PSCustomObject]@{
                        Response     = Invoke-ZtAzureRequest -Path "$logicAppResourceId`?api-version=2019-05-01" -FullResponse -ErrorAction Stop
                        RequestError = $false
                    }
                }
                catch {
                    $playbookResponses[$playbookKey] = [PSCustomObject]@{
                        Response     = $null
                        RequestError = $true
                    }
                    Write-PSFMessage "Error resolving playbook referenced by automation rule '$($rule.properties.displayName)': $_" -Tag Test -Level Warning
                }
            }
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $workspaceResults = @()
    $actionResults    = @()

    foreach ($workspace in $onboardedWorkspaces) {
        $collectedRules          = $rulesByWorkspace[$workspace.WorkspaceId]
        $totalRuleCount          = $collectedRules.Rules.Count
        $runPlaybookActionCount  = 0
        $eligibleActionCount     = 0
        $excludedActionCount     = 0
        $healthyActionCount      = 0
        $unhealthyActionCount    = 0
        $unresolvedActionCount   = 0

        if (-not $collectedRules.QueryError) {
            foreach ($rule in $collectedRules.Rules) {
                $runPlaybookActions = @($rule.properties.actions | Where-Object { $_.actionType -eq 'RunPlaybook' })
                $runPlaybookActionCount += $runPlaybookActions.Count
                if ($runPlaybookActions.Count -eq 0) {
                    continue
                }

                $ruleEnabled      = $rule.properties.triggeringLogic.isEnabled -eq $true
                $expiration        = $rule.properties.triggeringLogic.expirationTimeUtc
                $expirationDisplay = 'Never'
                $parsedExpiration  = [DateTimeOffset]::MinValue
                $expirationValid   = $true
                if (-not [string]::IsNullOrWhiteSpace([string]$expiration)) {
                    $expirationValid = [DateTimeOffset]::TryParse([string]$expiration, [ref]$parsedExpiration)
                    if ($expirationValid) {
                        $expirationDisplay = $parsedExpiration.UtcDateTime.ToString('yyyy-MM-dd HH:mm:ssZ')
                    }
                }

                $ruleExpired = $expirationValid -and $parsedExpiration -ne [DateTimeOffset]::MinValue -and $parsedExpiration -le $now

                foreach ($action in $runPlaybookActions) {
                    $logicAppResourceId = [string]$action.actionConfiguration.logicAppResourceId
                    $tenantId          = [string]$action.actionConfiguration.tenantId
                    $playbookName      = if ($logicAppResourceId) { ($logicAppResourceId -split '/')[-1] } else { 'Unavailable' }
                    $playbookType      = if ($logicAppResourceId -match '(?i)/providers/Microsoft\.Logic/workflows/') { 'Consumption' } else { 'Unsupported' }
                    $playbookState     = $null
                    $playbookResolved  = $null
                    $eligibility       = 'Eligible'
                    $q2Result          = 'Not queried'
                    $actionStatus      = 'Investigate'
                    $actionReason      = ''

                    if (-not $ruleEnabled) {
                        $eligibility  = 'Excluded'
                        $actionStatus = 'Excluded'
                        $actionReason = 'The automation rule is disabled.'
                        $excludedActionCount++
                    }
                    elseif (-not $expirationValid) {
                        $eligibility = 'Excluded'
                        $actionReason = 'The automation rule expiration value was malformed.'
                        $excludedActionCount++
                        $unresolvedActionCount++
                    }
                    elseif ($ruleExpired) {
                        $eligibility  = 'Excluded'
                        $actionStatus = 'Excluded'
                        $actionReason = 'The automation rule is expired.'
                        $excludedActionCount++
                    }
                    elseif ([string]::IsNullOrWhiteSpace($logicAppResourceId)) {
                        $eligibleActionCount++
                        $actionReason = 'The RunPlaybook action did not contain a Logic App resource ID.'
                        $unresolvedActionCount++
                    }
                    elseif ($playbookType -eq 'Unsupported') {
                        $eligibleActionCount++
                        $actionReason = 'The referenced playbook resource type is not supported by the documented workflow query.'
                        $unresolvedActionCount++
                    }
                    else {
                        $eligibleActionCount++
                        $playbookKey = $logicAppResourceId.ToLowerInvariant()
                        $collectedPlaybook = $playbookResponses[$playbookKey]

                        if ($null -eq $collectedPlaybook -or $collectedPlaybook.RequestError) {
                            $q2Result = 'Request failed'
                            $actionReason = 'The referenced Logic App could not be read.'
                            $unresolvedActionCount++
                        }
                        else {
                            $statusCode = [int]$collectedPlaybook.Response.StatusCode
                            $q2Result   = "HTTP $statusCode"
                            if ($statusCode -eq 200) {
                                try {
                                    $workflow = $collectedPlaybook.Response.Content | ConvertFrom-Json -Depth 100 -ErrorAction Stop
                                    if ($null -eq $workflow.properties.state) {
                                        throw 'The workflow response did not contain properties.state.'
                                    }

                                    $playbookName     = [string]$workflow.name
                                    $playbookState    = [string]$workflow.properties.state
                                    $playbookResolved = $true
                                    if ($playbookState -eq 'Enabled') {
                                        $actionStatus = 'Pass'
                                        $actionReason = 'The rule is active and the referenced playbook is enabled.'
                                        $healthyActionCount++
                                    }
                                    else {
                                        $actionStatus = 'Fail'
                                        $actionReason = 'The referenced playbook is not enabled.'
                                        $unhealthyActionCount++
                                    }
                                }
                                catch {
                                    $actionReason = 'The Logic App response was malformed.'
                                    $unresolvedActionCount++
                                }
                            }
                            elseif ($statusCode -eq 404) {
                                $playbookResolved = $false
                                $actionStatus     = 'Fail'
                                $actionReason     = 'The referenced playbook was not found.'
                                $unhealthyActionCount++
                            }
                            else {
                                $actionReason = if ($statusCode -in @(401, 403)) {
                                    'The referenced Logic App could not be read.'
                                }
                                else {
                                    "The Logic App request returned HTTP $statusCode."
                                }
                                $unresolvedActionCount++
                            }
                        }
                    }

                    $actionResults += [PSCustomObject]@{
                        SubscriptionName = $workspace.SubscriptionName
                        SubscriptionId   = $workspace.SubscriptionId
                        WorkspaceName    = $workspace.WorkspaceName
                        WorkspaceId      = $workspace.WorkspaceId
                        RuleName         = [string]$rule.properties.displayName
                        RuleId           = [string]$rule.id
                        RuleEnabled      = $ruleEnabled
                        Expiration       = $expirationDisplay
                        Eligibility      = $eligibility
                        ActionOrder      = if ($null -ne $action.order) { [string]$action.order } else { '—' }
                        PlaybookName     = $playbookName
                        PlaybookId       = $logicAppResourceId
                        PlaybookTenantId = $tenantId
                        Q2Result         = $q2Result
                        PlaybookState    = $playbookState
                        PlaybookResolved = $playbookResolved
                        RowStatus        = $actionStatus
                        StatusDetails    = $actionReason
                    }
                }
            }
        }

        $workspaceStatus = if ($collectedRules.QueryError) {
            'Investigate'
        }
        elseif ($unhealthyActionCount -gt 0) {
            'Fail'
        }
        elseif ($unresolvedActionCount -gt 0) {
            'Investigate'
        }
        elseif ($eligibleActionCount -gt 0) {
            'Pass'
        }
        else {
            'Fail'
        }

        $workspaceReason = switch ($workspaceStatus) {
            'Pass'        { 'Every eligible RunPlaybook action references an enabled playbook.' }
            'Fail'        { if ($eligibleActionCount -eq 0) { 'No enabled, non-expired automation rule references a playbook.' } else { 'One or more referenced playbooks are missing, disabled, or suspended.' } }
            'Investigate' { if ($collectedRules.QueryError) { 'The automation rules request failed.' } else { 'One or more eligible actions could not be evaluated.' } }
        }

        $workspaceResults += [PSCustomObject]@{
            SubscriptionName     = $workspace.SubscriptionName
            SubscriptionId       = $workspace.SubscriptionId
            WorkspaceName        = $workspace.WorkspaceName
            WorkspaceId          = $workspace.WorkspaceId
            TotalRuleCount         = $totalRuleCount
            RunPlaybookActionCount = $runPlaybookActionCount
            EligibleActionCount    = $eligibleActionCount
            ExcludedActionCount    = $excludedActionCount
            HealthyActionCount     = $healthyActionCount
            UnhealthyActionCount   = $unhealthyActionCount
            UnresolvedActionCount = $unresolvedActionCount
            RowStatus            = $workspaceStatus
            StatusDetails        = $workspaceReason
        }
    }

    foreach ($workspace in @($forbiddenWorkspaces) + @($unresolvedWorkspaces)) {
        $workspaceResults += [PSCustomObject]@{
            SubscriptionName      = $workspace.SubscriptionName
            SubscriptionId        = $workspace.SubscriptionId
            WorkspaceName         = $workspace.WorkspaceName
            WorkspaceId           = $workspace.WorkspaceId
            TotalRuleCount         = 0
            RunPlaybookActionCount = 0
            EligibleActionCount    = 0
            ExcludedActionCount    = 0
            HealthyActionCount     = 0
            UnhealthyActionCount   = 0
            UnresolvedActionCount = 1
            RowStatus             = 'Investigate'
            StatusDetails         = 'The Microsoft Sentinel onboarding state could not be determined.'
        }
    }

    $failedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Fail' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })
    $passed           = $failedItems.Count -eq 0 -and $investigateItems.Count -eq 0
    $customStatus     = $null

    if ($failedItems.Count -gt 0) {
        $testResultMarkdown = "❌ No automation rule executes a playbook, or a referenced playbook is missing, disabled, or suspended.`n`n%TestResult%"
    }
    elseif ($investigateItems.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ Automation rules or the referenced Logic App could not be read.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "✅ Microsoft Sentinel executes playbooks for automated threat response.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalSentinelLink = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'

    $workspaceRows = ''
    foreach ($result in $workspaceResults | Sort-Object SubscriptionName, WorkspaceName) {
        $subscriptionLink = "https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)"
        $workspaceLink    = "https://portal.azure.com/#resource$($result.WorkspaceId)"
        $subscriptionMd   = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subscriptionLink)"
        $workspaceMd      = "[$(Get-SafeMarkdown $result.WorkspaceName)]($workspaceLink)"
        $statusDisplay    = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $workspaceRows += "| $subscriptionMd | $workspaceMd | $($result.TotalRuleCount) | $($result.RunPlaybookActionCount) | $($result.EligibleActionCount) | $($result.ExcludedActionCount) | $($result.HealthyActionCount) | $($result.UnhealthyActionCount) | $($result.UnresolvedActionCount) | $statusDisplay | $($result.StatusDetails) |`n"
    }

    $workspaceSection = @"
## [Playbook automation summary per Microsoft Sentinel workspace]($portalSentinelLink)

| Subscription | Workspace | Total rules | RunPlaybook actions | Eligible | Excluded | Healthy | Unhealthy | Unreadable | Workspace status | Reason |
| :----------- | :-------- | ----------: | ------------------: | -------: | -------: | ------: | --------: | ---------: | :--------------- | :----- |
$workspaceRows
"@

    $detailRows     = ''
    $maxDisplay     = 10
    $statusPriority = @{ Fail = 0; Investigate = 1; Pass = 2; Excluded = 3 }
    $displayResults = @($actionResults | Sort-Object { $statusPriority[$_.RowStatus] }, SubscriptionName, WorkspaceName, RuleName, ActionOrder)
    $hasMoreItems   = $displayResults.Count -gt $maxDisplay
    if ($hasMoreItems) {
        $displayResults = @($displayResults | Select-Object -First $maxDisplay)
    }

    foreach ($result in $displayResults) {
        $subscriptionLink = "https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)"
        $workspaceLink    = "https://portal.azure.com/#resource$($result.WorkspaceId)"
        $subscriptionMd   = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subscriptionLink)"
        $workspaceMd      = "[$(Get-SafeMarkdown $result.WorkspaceName)]($workspaceLink)"
        $ruleNameMd       = Get-SafeMarkdown $result.RuleName
        if ($result.RuleId) {
            $ruleNameMd = "[$ruleNameMd](https://portal.azure.com/#resource$($result.RuleId))"
        }
        $playbookNameMd = Get-SafeMarkdown $result.PlaybookName
        if ($result.PlaybookId -and $result.PlaybookResolved -eq $true) {
            $playbookNameMd = "[$playbookNameMd](https://portal.azure.com/#resource$($result.PlaybookId))"
        }
        $ruleEnabledMd = if ($result.RuleEnabled) { '✅ Yes' } else { '❌ No' }
        $stateMd       = if ($result.PlaybookState) { $result.PlaybookState } else { '—' }
        $tenantMd      = if ($result.PlaybookTenantId) { $result.PlaybookTenantId } else { '—' }
        $statusDisplay = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
            'Excluded'    { 'Excluded' }
        }
        $detailRows += "| $subscriptionMd | $workspaceMd | $ruleNameMd | $ruleEnabledMd | $($result.Expiration) | $($result.Eligibility) | $($result.ActionOrder) | $playbookNameMd | $tenantMd | $($result.Q2Result) | $stateMd | $statusDisplay | $($result.StatusDetails) |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $actionResults.Count - $maxDisplay
        $detailRows += "| … | … | $remainingCount more of $($actionResults.Count) total | … | … | … | … | … | … | … | … | … | [View all in Microsoft Sentinel]($portalSentinelLink) |`n"
    }

    if ($detailRows) {
        $detailSection = @"
## Playbook action details

| Subscription | Workspace | Automation rule | Rule enabled | Expiration UTC | Eligibility | Action order | Playbook | Playbook tenant ID | Q2 result | Playbook state | Status | Reason |
| :----------- | :-------- | :-------------- | :----------- | :------------- | :---------- | -----------: | :------- | :----------------- | :-------- | :------------- | :----- | :----- |
$detailRows
"@
    }
    else {
        $detailSection = @'
## Playbook action details

No RunPlaybook actions were found.
'@
    }

    $formatTemplate = @'
{0}

{1}
'@
    $mdInfo             = $formatTemplate -f $workspaceSection, $detailSection
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41214'
        Title  = 'At least one Microsoft Sentinel automation rule executes a playbook for automated threat response'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
