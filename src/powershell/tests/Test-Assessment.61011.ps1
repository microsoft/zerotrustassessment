<#
.SYNOPSIS
    Checks whether every Microsoft Entra Agent ID in the tenant produced sign-in evidence
    consistent with users reaching the agent through Microsoft Entra in the last 30 days.
#>
function Test-Assessment-61011 {
    [ZtTest(
        Category           = 'AI Authentication & Access',
        ImplementationCost = 'Medium',
        MinimumLicense     = ('P1'),
        Pillar             = 'AI',
        Service            = ('Graph'),
        RiskLevel          = 'High',
        SfiPillar          = 'Protect identities and secrets',
        TenantType         = ('Workforce'),
        TestId             = 61011,
        Title              = 'Require users to use Microsoft Entra ID auth to interact with agents',
        UserImpact         = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if (-not (Get-ZtLicense EntraIDP1)) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return
    }

    #region Data Collection

    $activity = 'Checking whether agent identities produced Entra-mediated user-authentication sign-in evidence in the last 30 days'

    # Q1: Enumerate all agent identities in the tenant
    Write-ZtProgress -Activity $activity -Status 'Getting agent identities (Q1)'
    $agentIdentities = $null
    if ($Database) {
        $sqlQ1 = @"
SELECT
    id,
    appId,
    displayName,
    agentIdentityBlueprintId,
    accountEnabled
FROM main.ServicePrincipal
WHERE "@odata.type" = '#microsoft.graph.agentIdentity'
ORDER BY displayName
"@
        try {
            $agentIdentities = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlQ1)
        }
        catch {
            Write-PSFMessage "Q1 DB query failed, falling back to Graph: $_" -Tag Test -Level Warning -ErrorRecord $_
        }
    }
    if (-not $agentIdentities) {
        $agentIdentities = Invoke-ZtGraphRequest `
            -RelativeUri 'servicePrincipals/microsoft.graph.agentIdentity' `
            -ApiVersion beta `
            -Select @('id', 'appId', 'displayName', 'agentIdentityBlueprintId', 'accountEnabled')
    }
    if (-not $agentIdentities -or @($agentIdentities).Count -eq 0) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }


    # Q2: Enumerate all agent identity blueprints in the tenant
    Write-ZtProgress -Activity $activity -Status 'Getting agent identity blueprints (Q2)'
    $agentBlueprints = $null
    if ($Database) {
        $sqlQ2 = @"
SELECT
    id,
    appId,
    displayName,
    signInAudience
FROM main.Application
WHERE "@odata.type" = '#microsoft.graph.agentIdentityBlueprint'
ORDER BY displayName
"@
        try {
            $agentBlueprints = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlQ2)
        }
        catch {
            Write-PSFMessage "Q2 DB query failed, falling back to Graph: $_" -Tag Test -Level Warning -ErrorRecord $_
        }
    }
    if (-not $agentBlueprints) {
        $agentBlueprints = Invoke-ZtGraphRequest `
            -RelativeUri 'applications/microsoft.graph.agentIdentityBlueprint' `
            -ApiVersion beta `
            -Select @('id', 'appId', 'displayName', 'signInAudience')

    # Build lookup table for blueprint joins
    # blueprintByAppId : keyed by blueprint.appId  — matches agentIdentity.agentIdentityBlueprintId and Q4 parentAppId
    $blueprintByAppId = @{}
    foreach ($blueprint in $agentBlueprints) {
        if (-not [string]::IsNullOrEmpty($blueprint.appId)) { $blueprintByAppId[$blueprint.appId] = $blueprint }
    }

    # Fast-lookup set of blueprint object IDs for Q3 client-side filtering
    $blueprintObjectIdSet = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::OrdinalIgnoreCase
    )
    foreach ($blueprint in $agentBlueprints) {
        if (-not [string]::IsNullOrEmpty($blueprint.id)) {
            $null = $blueprintObjectIdSet.Add($blueprint.id)
        }
    }

    # ISO 8601 UTC timestamp 30 days before now
    $lookbackDate = (Get-Date).ToUniversalTime().AddDays(-30).ToString('yyyy-MM-ddTHH:mm:ssZ')

    # Q3: Last 30 days of interactive user sign-ins targeting agent blueprints
    Write-ZtProgress -Activity $activity -Status 'Getting interactive user sign-ins (Q3)'
    $interactiveSignIns = $null
    try {
        $interactiveSignIns = Invoke-ZtGraphRequest `
            -RelativeUri 'auditLogs/signIns' `
            -ApiVersion beta `
            -Filter "createdDateTime ge $lookbackDate and signInEventTypes/any(t:t eq 'interactiveUser')" `
            -Select @('id', 'createdDateTime', 'userPrincipalName', 'appId', 'resourceId', 'resourceDisplayName', 'signInEventTypes') `
            -ErrorAction Stop
    }
    catch {
        Add-ZtTestResultDetail `
            -SkippedBecause NotConnectedToService `
            -NotConnectedService @('Graph') `
            -Result 'Skipped. The **AuditLog.Read.All** permission is required to read sign-in logs for agent identity evaluation. Ensure the assessment account has this permission and retry.'
        return
    }

    # Q4: Last 30 days of agentic non-interactive sign-ins on behalf of real users
    Write-ZtProgress -Activity $activity -Status 'Getting agentic non-interactive sign-ins (Q4)'
    $agenticSignIns = $null
    try {
        $agenticSignIns = Invoke-ZtGraphRequest `
            -RelativeUri 'auditLogs/signIns' `
            -ApiVersion beta `
            -Filter "createdDateTime ge $lookbackDate and signInEventTypes/any(t:t eq 'nonInteractiveUser') and agent/agentType eq 'agenticAppInstance' and agent/agentSubjectType ne 'agentIDuser'" `
            -Select @('id', 'createdDateTime', 'userPrincipalName', 'appId', 'resourceId', 'resourceDisplayName', 'signInEventTypes', 'agent') `
            -ErrorAction Stop
    }
    catch {
        Add-ZtTestResultDetail `
            -SkippedBecause NotConnectedToService `
            -NotConnectedService @('Graph') `
            -Result 'Skipped. The **AuditLog.Read.All** permission is required to read sign-in logs for agent identity evaluation. Ensure the assessment account has this permission and retry.'
        return
    }

    # Group Q3 records by blueprint object id — only retain records whose resourceId matches a blueprint
    $interactiveSignInsByBlueprintObjectId = @{}
    foreach ($signIn in $interactiveSignIns) {
        if (-not [string]::IsNullOrEmpty($signIn.resourceId) -and $blueprintObjectIdSet.Contains($signIn.resourceId)) {
            if (-not $interactiveSignInsByBlueprintObjectId.ContainsKey($signIn.resourceId)) {
                $interactiveSignInsByBlueprintObjectId[$signIn.resourceId] = [System.Collections.Generic.List[object]]::new()
            }
            $interactiveSignInsByBlueprintObjectId[$signIn.resourceId].Add($signIn)
        }
    }

    # Group Q4 records by agent.parentAppId (blueprint appId)
    $agenticSignInsByParentAppId = @{}
    foreach ($signIn in $agenticSignIns) {
        $parentAppId = $signIn.agent.parentAppId
        if (-not [string]::IsNullOrEmpty($parentAppId)) {
            if (-not $agenticSignInsByParentAppId.ContainsKey($parentAppId)) {
                $agenticSignInsByParentAppId[$parentAppId] = [System.Collections.Generic.List[object]]::new()
            }
            $agenticSignInsByParentAppId[$parentAppId].Add($signIn)
        }
    }

    #endregion

    #region Assessment Logic

    # Classify each agent identity as Warning (no evidence) or passing (Signal 1 or Signal 2 present)
    $warningAgents = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($agentIdentity in $agentIdentities) {
        $blueprintAppId = $agentIdentity.agentIdentityBlueprintId
        $blueprint      = if (-not [string]::IsNullOrEmpty($blueprintAppId)) { $blueprintByAppId[$blueprintAppId] } else { $null }

        $signal1HasDelegatedCall = $false   # Strong pass: agent acquired token on behalf of a real user
        $signal2HasUserSignIn    = $false   # Pass: real user signed in to the blueprint audience through Entra
        $lastDelegatedCall       = $null
        $lastUserSignIn          = $null

        if ($blueprint) {
            # Signal 1: any Q4 record with agent.parentAppId == blueprint.appId
            $q4Records = $agenticSignInsByParentAppId[$blueprint.appId]
            if ($q4Records -and $q4Records.Count -gt 0) {
                $signal1HasDelegatedCall = $true
                $lastDelegatedCall = ($q4Records | Sort-Object createdDateTime -Descending | Select-Object -First 1).createdDateTime
            }

            # Signal 2: any Q3 record with resourceId == blueprint.id (object id)
            $q3Records = $interactiveSignInsByBlueprintObjectId[$blueprint.id]
            if ($q3Records -and $q3Records.Count -gt 0) {
                $signal2HasUserSignIn = $true
                $lastUserSignIn = ($q3Records | Sort-Object createdDateTime -Descending | Select-Object -First 1).createdDateTime
            }
        }

        # Warning: neither signal present — no Entra-mediated user authentication evidence
        if (-not $signal1HasDelegatedCall -and -not $signal2HasUserSignIn) {
            $warningAgents.Add([PSCustomObject]@{
                AgentDisplayName     = $agentIdentity.displayName
                AgentAppId           = $agentIdentity.appId
                AgentObjectId        = $agentIdentity.id
                BlueprintDisplayName = if ($blueprint) { $blueprint.displayName } else { '' }
                BlueprintAppId       = if (-not [string]::IsNullOrEmpty($blueprintAppId)) { $blueprintAppId } else { '' }
                LastUserSignIn       = $lastUserSignIn
                LastDelegatedCall    = $lastDelegatedCall
            })
        }
    }

    $passed = $warningAgents.Count -eq 0

    #endregion

    #region Report Generation

    $agentPortalUrl  = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AllAgents.MenuView/~/allAgentIds'
    $totalAgentCount = @($agentIdentities).Count
    $warningCount    = $warningAgents.Count

    if ($passed) {
        $testResultMarkdown = 'Every agent identity in the tenant produced Entra-mediated user-authentication sign-in evidence in the last 30 days.%TestResult%'
        $mdInfo = ''
    }
    else {
        $testResultMarkdown = 'One or more agent identities produced no evidence of Entra-mediated user authentication in the last 30 days. The platform cannot confirm whether those agents enforce Microsoft Entra user authentication; verify each agent''s host configuration directly.%TestResult%'

        $tableRows = ''
        foreach ($agent in $warningAgents) {
            $lastUserSignInDisplay    = if ($agent.LastUserSignIn)    { $agent.LastUserSignIn }    else { 'none' }
            $lastDelegatedCallDisplay = if ($agent.LastDelegatedCall) { $agent.LastDelegatedCall } else { 'none' }
            $tableRows += "| [$(Get-SafeMarkdown $agent.AgentDisplayName)]($agentPortalUrl) | $(Get-SafeMarkdown $agent.AgentAppId) | $(Get-SafeMarkdown $agent.AgentObjectId) | $(Get-SafeMarkdown $agent.BlueprintDisplayName) | $(Get-SafeMarkdown $agent.BlueprintAppId) | $lastUserSignInDisplay | $lastDelegatedCallDisplay |`n"
        }

        $formatTemplate = @'

### [Agent identities without Entra-mediated user-authentication evidence]({0})

| Agent display name | Agent app ID | Agent object ID | Blueprint display name | Blueprint app ID | Last user sign-in to blueprint | Last delegated downstream call |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{1}
**Summary:**
- Total agent identities evaluated: {2}
- Agent identities with warning: {3}

'@

        $mdInfo = $formatTemplate -f $agentPortalUrl, $tableRows, $totalAgentCount, $warningCount
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    Add-ZtTestResultDetail -Status $passed -Result $testResultMarkdown

    #endregion
}
}
