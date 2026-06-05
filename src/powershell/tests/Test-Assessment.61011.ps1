<#
.SYNOPSIS
    Checks whether every Microsoft Entra Agent ID in the tenant produced sign-in evidence
    consistent with users reaching the agent through Microsoft Entra in the last 30 days.

.DESCRIPTION
    For each agent identity service principal (microsoft.graph.agentIdentity), the test looks for
    two positive signals in the last 30 days of sign-in logs:

      Signal 1 (strong pass) — A non-interactive sign-in where the agent acquired a token on
      behalf of a real user (agent.agentType eq 'agenticAppInstance' and agent.parentAppId
      matches the agent's blueprint appId). This proves end-to-end delegated user authentication.

      Signal 2 (pass) — An interactive user sign-in whose resourceId matches the agent's
      blueprint object ID. This proves users reach the agent's blueprint audience through Entra.

    An agent identity with neither signal in the lookback window is classified as Warning; the
    tenant-level result is Fail when any agent identity is in Warning.

.NOTES
    Test ID: 61011
    Workshop Task: AI_000
    Pillar: AI
    Category: AI Authentication & Access
    Required permissions:
      Application.Read.All — to enumerate agent identities (Q1) and blueprints (Q2)
      AuditLog.Read.All   — to read interactive (Q3) and agentic non-interactive (Q4) sign-in logs
#>
function Test-Assessment-61011 {
    [ZtTest(
        Category           = 'AI Authentication & Access',
        ImplementationCost = 'Medium',
        CompatibleLicense  = ('AAD_PREMIUM'),
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

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking whether agent identities produced Entra-mediated user-authentication sign-in evidence in the last 30 days'

    # Q1: Enumerate all agent identities from the exported database
    Write-ZtProgress -Activity $activity -Status 'Getting agent identities (Q1)'
    $sqlQ1 = @"
SELECT id, appId, displayName, agentIdentityBlueprintId, accountEnabled
FROM main.ServicePrincipal
WHERE "@odata.type" = '#microsoft.graph.agentIdentity'
ORDER BY displayName
"@
    try {
        $agentIdentities = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlQ1)
    }
    catch {
        Write-PSFMessage "Failed to query agent identities: $_" -Tag Test -Level Warning -ErrorRecord $_
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if (-not $agentIdentities -or $agentIdentities.Count -eq 0) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q2: Enumerate all agent identity blueprints from the exported database
    Write-ZtProgress -Activity $activity -Status 'Getting agent identity blueprints (Q2)'
    $sqlQ2 = @"
SELECT id, appId, displayName, signInAudience
FROM main.Application
WHERE "@odata.type" = '#microsoft.graph.agentIdentityBlueprint'
ORDER BY displayName
"@
    try {
        $agentBlueprints = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlQ2)
    }
    catch {
        Write-PSFMessage "Failed to query agent identity blueprints: $_" -Tag Test -Level Warning -ErrorRecord $_
        $agentBlueprints = @()
    }

    # Build lookup tables: blueprintByAppId keyed by blueprint.appId
    $blueprintByAppId = @{}
    foreach ($blueprint in $agentBlueprints) {
        if (-not [string]::IsNullOrEmpty($blueprint.appId)) { $blueprintByAppId[$blueprint.appId] = $blueprint }
    }

    $blueprintObjectIdSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($blueprint in $agentBlueprints) {
        if (-not [string]::IsNullOrEmpty($blueprint.id)) { $null = $blueprintObjectIdSet.Add($blueprint.id) }
    }

    $lookbackDate = (Get-Date).ToUniversalTime().AddDays(-30).ToString('yyyy-MM-ddTHH:mm:ssZ')

    # Q3: Last 30 days of interactive user sign-ins targeting agent blueprints (live Graph — sign-in logs are not exported)
    Write-ZtProgress -Activity $activity -Status 'Getting interactive user sign-ins (Q3)'
    $q3QueryError = $null
    $interactiveSignIns = @()
    try {
        $interactiveSignIns = @(Invoke-ZtGraphRequest `
            -RelativeUri 'auditLogs/signIns' `
            -ApiVersion beta `
            -Filter "createdDateTime ge $lookbackDate and signInEventTypes/any(t:t eq 'interactiveUser')" `
            -Select @('id', 'createdDateTime', 'userPrincipalName', 'appId', 'resourceId', 'resourceDisplayName', 'signInEventTypes') `
            -ErrorAction Stop)
    }
    catch {
        $q3QueryError = $_
        Write-PSFMessage "Failed to retrieve interactive sign-in logs: $_" -Tag Test -Level Warning
    }

    # Q4: Last 30 days of agentic non-interactive sign-ins on behalf of real users (live Graph — sign-in logs are not exported)
    Write-ZtProgress -Activity $activity -Status 'Getting agentic non-interactive sign-ins (Q4)'
    $q4QueryError = $null
    $agenticSignIns = @()
    try {
        $agenticSignIns = @(Invoke-ZtGraphRequest `
            -RelativeUri 'auditLogs/signIns' `
            -ApiVersion beta `
            -Filter "createdDateTime ge $lookbackDate and signInEventTypes/any(t:t eq 'nonInteractiveUser') and agent/agentType eq 'agenticAppInstance' and agent/agentSubjectType ne 'agentIDuser'" `
            -Select @('id', 'createdDateTime', 'userPrincipalName', 'appId', 'resourceId', 'resourceDisplayName', 'signInEventTypes', 'agent') `
            -ErrorAction Stop)
    }
    catch {
        $q4QueryError = $_
        Write-PSFMessage "Failed to retrieve agentic non-interactive sign-in logs: $_" -Tag Test -Level Warning
    }

    # Group Q3 records by blueprint object id
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
    #endregion Data Collection

    #region Assessment Logic
    $warningAgents = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($agentIdentity in $agentIdentities) {
        $blueprintAppId = $agentIdentity.agentIdentityBlueprintId
        $blueprint      = if (-not [string]::IsNullOrEmpty($blueprintAppId)) { $blueprintByAppId[$blueprintAppId] } else { $null }

        $signal1HasDelegatedCall = $false
        $signal2HasUserSignIn    = $false
        $lastDelegatedCall       = $null
        $lastUserSignIn          = $null

        if ($blueprint) {
            # Signal 1: agentic non-interactive sign-in with agent.parentAppId == blueprint.appId
            $q4Records = $agenticSignInsByParentAppId[$blueprint.appId]
            if ($q4Records -and $q4Records.Count -gt 0) {
                $signal1HasDelegatedCall = $true
                $lastDelegatedCall = ($q4Records | Sort-Object createdDateTime -Descending | Select-Object -First 1).createdDateTime
            }

            # Signal 2: interactive user sign-in with resourceId == blueprint.id
            $q3Records = $interactiveSignInsByBlueprintObjectId[$blueprint.id]
            if ($q3Records -and $q3Records.Count -gt 0) {
                $signal2HasUserSignIn = $true
                $lastUserSignIn = ($q3Records | Sort-Object createdDateTime -Descending | Select-Object -First 1).createdDateTime
            }
        }

        if (-not $signal1HasDelegatedCall -and -not $signal2HasUserSignIn) {
            $warningAgents.Add([PSCustomObject]@{
                AgentDisplayName     = $agentIdentity.displayName
                AgentObjectId        = $agentIdentity.id
                BlueprintDisplayName = if ($blueprint) { $blueprint.displayName } else { '' }
                BlueprintAppId       = if ($blueprint) { $blueprint.appId } else { '' }
                LastUserSignIn       = $lastUserSignIn
                LastDelegatedCall    = $lastDelegatedCall
            })
        }
    }

    $passed = $warningAgents.Count -eq 0
    #endregion Assessment Logic

    #region Report Generation
    $agentPortalUrl     = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AllAgents.MenuView/~/allAgentIds'
    $agentUrlFormat     = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AgentIdentity.MenuView/~/overview/objectId/{0}/menuId/overview'
    $blueprintUrlFormat = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AgentBlueprintDetails.MenuView/~/overview/appId/{0}'
    $totalAgentCount    = @($agentIdentities).Count
    $warningCount       = $warningAgents.Count

    if ($passed) {
        $testResultMarkdown = "✅ Every agent identity in the tenant produced Entra-mediated user-authentication sign-in evidence in the last 30 days.`n`n%TestResult%"
        $mdInfo = ''
    }
    else {
        $testResultMarkdown = "❌ One or more agent identities produced no evidence of Entra-mediated user authentication in the last 30 days. The platform cannot confirm whether those agents enforce Microsoft Entra user authentication; verify each agent's host configuration directly.`n`n%TestResult%"

        $tableRows = ''
        foreach ($agent in $warningAgents) {
            $agentUrl     = if (-not [string]::IsNullOrEmpty($agent.AgentObjectId)) { $agentUrlFormat -f $agent.AgentObjectId } else { $agentPortalUrl }
            $blueprintUrl = if (-not [string]::IsNullOrEmpty($agent.BlueprintAppId)) { $blueprintUrlFormat -f $agent.BlueprintAppId } else { $agentPortalUrl }
            $agentLink     = "[$(Get-SafeMarkdown $agent.AgentDisplayName)]($agentUrl)"
            $blueprintLink = if (-not [string]::IsNullOrEmpty($agent.BlueprintDisplayName)) { "[$(Get-SafeMarkdown $agent.BlueprintDisplayName)]($blueprintUrl)" } else { '' }
            $lastUserSignInDisplay    = if ($agent.LastUserSignIn)    { $agent.LastUserSignIn }    else { 'none' }
            $lastDelegatedCallDisplay = if ($agent.LastDelegatedCall) { $agent.LastDelegatedCall } else { 'none' }
            $tableRows += "| $agentLink | $blueprintLink | $lastUserSignInDisplay | $lastDelegatedCallDisplay |`n"
        }

        $formatTemplate = @'


### [Agent identities without Entra-mediated user-authentication evidence]({0})

| Agent Display Name | Blueprint Display Name | Last User Sign-In to Blueprint | Last Delegated Downstream Call |
| :--- | :--- | :--- | :--- |
{1}
**Summary:**
- Total agent identities evaluated: {2}
- Agent identities with warning: {3}

'@

        $mdInfo = $formatTemplate -f $agentPortalUrl, $tableRows, $totalAgentCount, $warningCount
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    $params = @{
        TestId = '61011'
        Title  = 'Require users to use Microsoft Entra ID auth to interact with agents'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params

    #endregion Report Generation
}
