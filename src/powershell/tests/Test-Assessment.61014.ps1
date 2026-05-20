<#
.SYNOPSIS
    Agent identities and blueprint principals have assigned technical owners and no disabled agents remain in the directory.

.DESCRIPTION
    Evaluates two sub-conditions for Microsoft Entra Agent ID:

      A. Every agent identity (microsoft.graph.agentIdentity) and every agent identity blueprint
         principal (microsoft.graph.agentIdentityBlueprintPrincipal) has at least one assigned owner.

      B. No agent identity or blueprint principal exists with accountEnabled == false.

    The check reads the ServicePrincipal table, which is exported under the AI pillar with
    agentIdentityBlueprintId and the owners related property. Derived types are identified
    via the "@odata.type" column emitted by Microsoft Graph for derived service principal types.

.NOTES
    Test ID: 61014
    Pillar: AI
    Workshop Task: AI_002
    Spec: ztspecs/specs/ai/61014.md
#>

function Test-Assessment-61014 {
    [ZtTest(
        Category = 'Agent Lifecycle',
        ImplementationCost = 'Medium',
        MinimumLicense = ('AAD_BASIC'),
        Service = ('Graph'),
        Pillar = 'AI',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 61014,
        Title = 'Agent identities and blueprint principals have assigned technical owners and no disabled agents remain in the directory',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking agent identity ownership and disabled state'
    Write-ZtProgress -Activity $activity -Status 'Querying agent identities and blueprint principals'

    # Pull agent identities and blueprint principals from the exported ServicePrincipal table.
    # The Graph response carries the derived type in "@odata.type" when the row is not the
    # base servicePrincipal type. agentIdentityBlueprintId is only populated for agent
    # identities, and createdByAppId is informational for blueprint principals.
    #
    # The owners column is exported by Export-TenantData as a related property and stored by
    # DuckDB as JSON (the values are heterogeneous: SQL NULL when Graph returned no owners,
    # an object for a single owner, or an array for multiple). Computing the count in SQL
    # with json_array_length / json_type avoids fragile PowerShell coercion: a NULL JSON
    # column surfaces as [System.DBNull]::Value (truthy in PS), and len() on JSON returns
    # string length rather than item count. coalesce + case yields a plain integer.
    $sql = @"
select
    id,
    appId,
    displayName,
    accountEnabled,
    "@odata.type" as odataType,
    agentIdentityBlueprintId,
    createdByAppId,
    case
        when owners is null then 0
        when json_type(owners) = 'ARRAY' then coalesce(json_array_length(owners), 0)
        when json_type(owners) = 'OBJECT' then 1
        else 0
    end as ownerCount
from main.ServicePrincipal
where "@odata.type" in (
        '#microsoft.graph.agentIdentity',
        '#microsoft.graph.agentIdentityBlueprintPrincipal'
    )
order by "@odata.type", displayName
"@

    $queryFailed = $false
    $results = @()
    try {
        $results = @(Invoke-DatabaseQuery -Database $Database -Sql $sql)
    }
    catch {
        $queryFailed = $true
        Write-PSFMessage "Failed to query agent identities from ServicePrincipal table: $_" -Tag Test -Level Warning -ErrorRecord $_
    }
    #endregion Data Collection

    #region Investigate or Skipped
    if ($queryFailed) {
        $params = @{
            TestId       = '61014'
            Title        = 'Agent identities and blueprint principals have assigned technical owners and no disabled agents remain in the directory'
            Status       = $false
            Result       = "⚠️ Unable to evaluate agent identities and blueprint principals because the ServicePrincipal table query failed. Review the test log and re-run the assessment."
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if (-not $results -or $results.Count -eq 0) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }
    #endregion Investigate or Skipped

    #region Assessment Logic
    Write-ZtProgress -Activity $activity -Status 'Evaluating ownership and disabled state'

    $ownerlessObjects = [System.Collections.Generic.List[object]]::new()
    $disabledObjects  = [System.Collections.Generic.List[object]]::new()

    foreach ($item in $results) {
        # ownerCount is computed in SQL (see query); cast defensively in case DuckDB
        # returns a wider numeric type.
        $ownerCount = [int]$item.ownerCount

        # Sub-condition A: ownerless
        if ($ownerCount -lt 1) {
            $ownerlessObjects.Add($item)
        }

        # Sub-condition B: disabled (accountEnabled is exported as a bool by DuckDB).
        if ($item.accountEnabled -eq $false) {
            $disabledObjects.Add($item)
        }
    }

    $subAFailed = $ownerlessObjects.Count -gt 0
    $subBFailed = $disabledObjects.Count -gt 0
    $passed = (-not $subAFailed) -and (-not $subBFailed)
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''

    if ($passed) {
        $testResultMarkdown = "Every agent identity and blueprint principal in the tenant has at least one assigned owner AND no disabled agent identities or blueprint principals exist in the directory.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "One or more agent identities or blueprint principals have no assigned owner, OR one or more disabled agent identities or blueprint principals exist in the directory.`n`n%TestResult%"
    }

    # Build summary counts
    $agentIdentityCount = @($results | Where-Object { $_.odataType -eq '#microsoft.graph.agentIdentity' }).Count
    $blueprintCount     = @($results | Where-Object { $_.odataType -eq '#microsoft.graph.agentIdentityBlueprintPrincipal' }).Count

    # Portal URLs (kept out of markdown literals per ZT engineering standards).
    # Both derived types have working per-item overview blades keyed on the
    # servicePrincipal objectId. Inventory bullets link to the corresponding listing pages.
    $agentIdentityUrlFormat   = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AgentIdentity.MenuView/~/overview/objectId/{0}/menuId/overview'
    $blueprintUrlFormat       = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AgentBlueprintDetails.MenuView/~/overview/objectId/{0}'
    $allAgentsPortalUrl       = 'https://entra.microsoft.com/?feature.msaljs=true#view/Microsoft_AAD_RegisteredApps/AllAgents.MenuView/~/allAgentIds'
    $allBlueprintsPortalUrl   = 'https://entra.microsoft.com/?feature.msaljs=true#view/Microsoft_AAD_RegisteredApps/AllAgents.MenuView/~/allAgentBlueprints'

    $mdInfo  = "`n**Agent identity inventory:**`n`n"
    $mdInfo += "* [Agent identities]($allAgentsPortalUrl): $agentIdentityCount`n"
    $mdInfo += "* [Blueprint principals]($allBlueprintsPortalUrl): $blueprintCount`n"
    $mdInfo += "* Ownerless objects: $($ownerlessObjects.Count)`n"
    $mdInfo += "* Disabled objects: $($disabledObjects.Count)`n`n"

    # Renders the short type name used in tables.
    function Format-AgentType($odataType) {
        switch ($odataType) {
            '#microsoft.graph.agentIdentity'                   { 'agentIdentity' }
            '#microsoft.graph.agentIdentityBlueprintPrincipal' { 'agentIdentityBlueprintPrincipal' }
            default { if ($odataType) { ($odataType -replace '^#microsoft\.graph\.', '') } else { 'unknown' } }
        }
    }

    # Returns the per-item portal overview blade URL for the given object. Both agent
    # identities and blueprint principals have working per-item blades keyed on the
    # servicePrincipal objectId; the blade route differs by derived type.
    function Get-AgentPortalUrl($item) {
        if ($item.id) {
            switch ($item.odataType) {
                '#microsoft.graph.agentIdentity'                   { return ($agentIdentityUrlFormat -f $item.id) }
                '#microsoft.graph.agentIdentityBlueprintPrincipal' { return ($blueprintUrlFormat -f $item.id) }
            }
        }
        return $allAgentsPortalUrl
    }

    # Renders the Account enabled cell consistently.
    function Format-EnabledCell($accountEnabled) {
        if ($null -eq $accountEnabled) { return 'N/A' }
        if ($accountEnabled) { '✅ Enabled' } else { '❌ Disabled' }
    }

    # Sub-condition A failures table
    # Note: Spec requested Object ID / App ID columns, but ZT engineering standards prohibit
    # raw IDs in output tables. The Display Name is linked to the per-item portal blade for
    # both agent identities and blueprint principals (see Get-AgentPortalUrl above).
    if ($subAFailed) {
        $mdInfo += "## Agent identities and blueprint principals without an assigned owner`n`n"
        $mdInfo += "| Object type | Display name | Account enabled |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($item in ($ownerlessObjects | Sort-Object odataType, displayName)) {
            $typeName    = Format-AgentType $item.odataType
            $displayName = Get-SafeMarkdown -Text $item.displayName
            $enabled     = Format-EnabledCell $item.accountEnabled
            $detailsUrl  = Get-AgentPortalUrl $item
            $nameLink    = "[$displayName]($detailsUrl)"
            $mdInfo += "| ``$typeName`` | $nameLink | $enabled |`n"
        }
        $mdInfo += "`n"
    }

    # Sub-condition B failures table
    # Note: Object ID / App ID columns omitted per ZT engineering standards.
    if ($subBFailed) {
        $mdInfo += "## Disabled agent identities and blueprint principals`n`n"
        $mdInfo += "| Object type | Display name | Account enabled |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($item in ($disabledObjects | Sort-Object odataType, displayName)) {
            $typeName    = Format-AgentType $item.odataType
            $displayName = Get-SafeMarkdown -Text $item.displayName
            $enabled     = Format-EnabledCell $item.accountEnabled
            $detailsUrl  = Get-AgentPortalUrl $item
            $nameLink    = "[$displayName]($detailsUrl)"
            $mdInfo += "| ``$typeName`` | $nameLink | $enabled |`n"
        }
        $mdInfo += "`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '61014'
        Title  = 'Agent identities and blueprint principals have assigned technical owners and no disabled agents remain in the directory'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
