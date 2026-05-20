<#
.SYNOPSIS
    Agent identity lifecycle tagging (customSecurityAttributes present)

.DESCRIPTION
    Custom security attributes are the primary mechanism for Conditional Access to distinguish
    between agent identities at scale, and they must be assigned to agent identities as part
    of the identity lifecycle. This test verifies that every agent identity service principal
    has custom security attributes assigned on its own object and that its parent blueprint
    principal also carries attribute assignments, ensuring both CA targeting surfaces are tagged.

    Without custom security attributes on both surfaces, Conditional Access policies cannot
    reliably distinguish between agent identities and risks having gaps in policy enforcement.

.NOTES
    Test ID: 61008
    Category: Secure AI Authentication and Access
    Pillar: AI
    Required APIs: servicePrincipals (v1.0)
    Required Permissions: Application.Read.All, CustomSecAttributeAssignment.Read.All
    Required Roles: Attribute Assignment Reader or Attribute Assignment Administrator
    Workshop Task: AI_005
#>

function Test-Assessment-61008 {
    [ZtTest(
        Category = 'Secure AI Authentication and Access',
        ImplementationCost = 'Medium',
        Service = ('Graph'),
        MinimumLicense = ('Free'),
        Pillar = 'AI',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 61008,
        Title = 'Agent identity lifecycle tagging (customSecurityAttributes present)',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Helper Functions

    function Test-HasCustomSecurityAttributes {
        <#
        .SYNOPSIS
            Checks if customSecurityAttributes is non-null and non-empty.
        .DESCRIPTION
            Graph API returns an empty object {} when CSAs are removed, which
            evaluates as $true in PowerShell. This function properly checks
            whether actual CSA values are present.
        .OUTPUTS
            System.Boolean - True if CSAs are assigned, false otherwise.
        #>
        param($Csa)
        if ($null -eq $Csa) { return $false }
        if ($Csa -is [string]) {
            if ([string]::IsNullOrWhiteSpace($Csa)) { return $false }
            if ($Csa.Trim() -eq '{}') { return $false }
            return $true
        }
        if ($Csa -is [hashtable]) { return $Csa.Count -gt 0 }
        $props = @($Csa.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' })
        return $props.Count -gt 0
    }

    function Get-CsaAttributeNames {
        <#
        .SYNOPSIS
            Extracts dotted attributeSet.attributeName keys from a customSecurityAttributes object.
        .DESCRIPTION
            Attribute values are intentionally omitted to avoid leaking classification data
            into assessment output. Only the attribute key names are returned.
        .OUTPUTS
            System.String - Comma-separated list of attribute set+name keys, or 'none'.
        #>
        param($Csa)
        if ($null -eq $Csa) { return 'none' }
        # DuckDB returns JSON columns as raw strings; parse before introspecting properties
        if ($Csa -is [string]) {
            if ([string]::IsNullOrWhiteSpace($Csa) -or $Csa.Trim() -eq '{}') { return 'none' }
            try { $Csa = $Csa | ConvertFrom-Json } catch { return 'none' }
        }
        $attrSets = @($Csa.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' })
        if ($attrSets.Count -eq 0) { return 'none' }
        $names = @()
        foreach ($attrSet in $attrSets) {
            $setName = $attrSet.Name
            $setObj = $attrSet.Value
            if ($null -eq $setObj) { continue }
            $attrs = @($setObj.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' -and $_.Name -notlike '@*' })
            foreach ($attr in $attrs) {
                $names += "$setName.$($attr.Name)"
            }
        }
        if ($names.Count -eq 0) { return 'none' }
        return ($names -join ', ')
    }

    #endregion Helper Functions

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking agent identity custom security attribute lifecycle tagging'
    Write-ZtProgress -Activity $activity -Status 'Querying agent identities and blueprint principals'

    $agentIdentities     = @()
    $blueprintPrincipals = @()
    try {
        # Q1: Agent identity service principals — carry agentIdentityBlueprintId used to join to their parent blueprint.
        $sqlAgents = @"
SELECT id, appId, displayName, agentIdentityBlueprintId, customSecurityAttributes
FROM ServicePrincipal
WHERE "@odata.type" = '#microsoft.graph.agentIdentity'
ORDER BY displayName
"@
        $agentIdentities = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlAgents -AsCustomObject)

        # Q2: Blueprint principals — group multiple agent identities under a single CA-targetable surface.
        $sqlBlueprints = @"
SELECT id, appId, displayName, customSecurityAttributes
FROM ServicePrincipal
WHERE "@odata.type" = '#microsoft.graph.agentIdentityBlueprintPrincipal'
"@
        $blueprintPrincipals = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlBlueprints -AsCustomObject)
    }
    catch {
        Write-PSFMessage "Failed to query agent identities from database: $_" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported -Result 'The Agent ID feature may not be available in this tenant, or the query returned an unexpected error.'
        return
    }

    #endregion Data Collection

    #region Assessment Logic

    # Skip: Q1 returned zero agent identities — Agent ID feature not enabled or no agents provisioned
    if ($agentIdentities.Count -eq 0) {
        Write-PSFMessage 'No agent identity service principals found in this tenant.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No agent identity service principals exist in this tenant.'
        return
    }

    # Build blueprint principal lookup keyed by appId for O(1) join
    $blueprintLookup = @{}
    foreach ($bp in $blueprintPrincipals) {
        if ($bp.appId) {
            $blueprintLookup[$bp.appId] = $bp
        }
    }

    # Evaluate each agent identity against both CA targeting surfaces independently
    $failingAgents = @()
    $passed = $true

    foreach ($agent in $agentIdentities) {

        # Condition A: agent identity's own CSA surface
        # Required for CA policies that target the agent as a *resource* (filter for applications)
        $conditionA    = Test-HasCustomSecurityAttributes $agent.customSecurityAttributes
        $agentAttrNames = Get-CsaAttributeNames $agent.customSecurityAttributes

        # Condition B: parent blueprint principal's CSA surface
        # Required for CA policies that target agents grouped by blueprint as the *principal*
        $conditionB          = $false
        $blueprintDisplayName = 'N/A'
        $blueprintAttrNames   = 'N/A'

        if ($agent.agentIdentityBlueprintId) {
            $blueprintPrincipal = $blueprintLookup[$agent.agentIdentityBlueprintId]
            if ($blueprintPrincipal) {
                $conditionB           = Test-HasCustomSecurityAttributes $blueprintPrincipal.customSecurityAttributes
                $blueprintDisplayName = $blueprintPrincipal.displayName
                $blueprintAttrNames   = Get-CsaAttributeNames $blueprintPrincipal.customSecurityAttributes
            }
        }

        # Per spec:
        #   - Test FAILS only when BOTH surfaces are untagged (AND condition).
        #   - Any agent with at least one untagged surface is included in the output table
        #     (informational, for remediation) even if the overall test still passes.
        $hasAnySurfaceGap    = (-not $conditionA) -or (-not $conditionB)
        $bothSurfacesUntagged = (-not $conditionA) -and (-not $conditionB)

        if ($bothSurfacesUntagged) {
            $passed = $false
        }

        if ($hasAnySurfaceGap) {
            $untaggedSurface = if (-not $conditionA -and -not $conditionB) {
                'both'
            }
            elseif (-not $conditionA) {
                'agent identity'
            }
            else {
                'blueprint principal'
            }

            $failingAgents += [PSCustomObject]@{
                AgentDisplayName      = $agent.displayName
                AgentObjectId         = $agent.id
                AgentAppId            = $agent.appId
                AgentAttrNames        = $agentAttrNames
                BlueprintDisplayName  = $blueprintDisplayName
                BlueprintAttrNames    = $blueprintAttrNames
                UntaggedSurface       = $untaggedSurface
            }
        }
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalAgentLink   = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AllAgents.MenuView/~/allAgentIds'
    $portalAgentTemplate = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AgentIdentity.MenuView/~/customSecurityAttributes/objectId/{0}/menuId/overview'

    if ($passed) {
        $testResultMarkdown = "✅ All agent identity service principals have custom security attributes assigned for lifecycle classification.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more agent identity service principals do not have custom security attributes assigned. These untagged agents cannot be targeted by attribute-based Conditional Access policies.`n`n%TestResult%"
    }

    $mdInfo  = "`n**Agent identity evaluation summary:**`n`n"
    $mdInfo += "| Metric | Count |`n|---|---|`n"
    $mdInfo += "| Total agent identities evaluated | $($agentIdentities.Count) |`n"
    $mdInfo += "| Blueprint principals found | $($blueprintPrincipals.Count) |`n"
    $mdInfo += "| Agents with gaps on any surface | $($failingAgents.Count) |`n`n"

    if ($failingAgents.Count -gt 0) {
        $maxDisplay = 10
        $tableRows  = ''
        $formatTemplate = @'
## [Agent identities missing custom security attributes]({0})

| Agent display name | Agent identity attribute names | Blueprint principal display name | Blueprint principal attribute names | Untagged surface |
|---|---|---|---|---|
{1}
'@
        foreach ($agent in ($failingAgents | Sort-Object AgentDisplayName | Select-Object -First $maxDisplay)) {
            $agentLink        = $portalAgentTemplate -f $agent.AgentObjectId
            $agentName        = "[$(Get-SafeMarkdown -Text $agent.AgentDisplayName)]($agentLink)"
            $agentAttrs       = Get-SafeMarkdown -Text $agent.AgentAttrNames
            $blueprintName    = Get-SafeMarkdown -Text $agent.BlueprintDisplayName
            $blueprintAttrs   = Get-SafeMarkdown -Text $agent.BlueprintAttrNames
            $untaggedSurface  = Get-SafeMarkdown -Text $agent.UntaggedSurface
            $tableRows += "| $agentName | $agentAttrs | $blueprintName | $blueprintAttrs | $untaggedSurface |`n"
        }
        $mdInfo += $formatTemplate -f $portalAgentLink, $tableRows
        if ($failingAgents.Count -gt $maxDisplay) {
            $mdInfo += "`n`n_**Note**: This table is truncated and showing the first $maxDisplay of $($failingAgents.Count) agents with surface gaps._`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '61008'
        Title  = 'Agent identity lifecycle tagging (customSecurityAttributes present)'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
