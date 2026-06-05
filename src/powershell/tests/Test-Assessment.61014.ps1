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
        CompatibleLicense = ('AAD_BASIC', 'AAD_PREMIUM'),
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
    # The owners column is exported as JSON; computing the count in SQL avoids fragile
    # PowerShell coercion of NULL/object/array values.
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

    $results = @()
    try {
        $results = @(Invoke-DatabaseQuery -Database $Database -Sql $sql)
    }
    catch {
        Write-PSFMessage "Failed to query agent identities from ServicePrincipal table: $_" -Tag Test -Level Warning -ErrorRecord $_
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if (-not $results -or $results.Count -eq 0) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    Write-ZtProgress -Activity $activity -Status 'Evaluating ownership and disabled state'

    $ownerlessObjects = @($results | Where-Object { [int]$_.ownerCount -lt 1 })
    $disabledObjects  = @($results | Where-Object { $_.accountEnabled -eq $false })

    $passed = ($ownerlessObjects.Count -eq 0) -and ($disabledObjects.Count -eq 0)
    #endregion Assessment Logic

    #region Report Generation
    if ($passed) {
        $testResultMarkdown = "✅ Every agent identity and blueprint principal has at least one assigned owner and no disabled agent identities or blueprint principals exist in the directory.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more agent identities or blueprint principals have no assigned owner, or one or more disabled agent identities or blueprint principals exist in the directory.`n`n%TestResult%"
    }

    # Portal URLs (kept out of markdown literals per ZT engineering standards).
    $agentIdentityUrlFormat = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AgentIdentity.MenuView/~/overview/objectId/{0}/menuId/overview'
    $blueprintUrlFormat     = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/AgentBlueprintDetails.MenuView/~/overview/objectId/{0}'
    $allAgentsPortalUrl     = 'https://entra.microsoft.com/?feature.msaljs=true#view/Microsoft_AAD_RegisteredApps/AllAgents.MenuView/~/allAgentIds'
    $allBlueprintsPortalUrl = 'https://entra.microsoft.com/?feature.msaljs=true#view/Microsoft_AAD_RegisteredApps/AllAgents.MenuView/~/allAgentBlueprints'

    $agentIdentityCount = @($results | Where-Object { $_.odataType -eq '#microsoft.graph.agentIdentity' }).Count
    $blueprintCount     = @($results | Where-Object { $_.odataType -eq '#microsoft.graph.agentIdentityBlueprintPrincipal' }).Count

    $formatTemplate = @'


## {0}

| Object type | Display name | Account enabled |
| :---------- | :----------- | :-------------- |
{1}

'@

    $mdInfo  = "`n**Agent identity inventory:**`n`n"
    $mdInfo += "* [Agent identities]($allAgentsPortalUrl): $agentIdentityCount`n"
    $mdInfo += "* [Blueprint principals]($allBlueprintsPortalUrl): $blueprintCount`n"
    $mdInfo += "* Ownerless objects: $($ownerlessObjects.Count)`n"
    $mdInfo += "* Disabled objects: $($disabledObjects.Count)`n"

    if ($ownerlessObjects.Count -gt 0) {
        $tableRows = ''
        foreach ($item in ($ownerlessObjects | Sort-Object odataType, displayName)) {
            $typeName = if ($item.odataType) { $item.odataType -replace '^#microsoft\.graph\.', '' } else { 'unknown' }
            $displayName = Get-SafeMarkdown -Text $item.displayName
            $detailsUrl = if ($item.odataType -eq '#microsoft.graph.agentIdentity') {
                $agentIdentityUrlFormat -f $item.id
            } elseif ($item.odataType -eq '#microsoft.graph.agentIdentityBlueprintPrincipal') {
                $blueprintUrlFormat -f $item.id
            } else {
                $allAgentsPortalUrl
            }
            $nameLink = "[$displayName]($detailsUrl)"
            $enabled = if ($null -eq $item.accountEnabled) { 'N/A' } elseif ($item.accountEnabled) { '✅ Enabled' } else { '❌ Disabled' }
            $tableRows += "| ``$typeName`` | $nameLink | $enabled |`n"
        }
        $mdInfo += $formatTemplate -f 'Agent identities and blueprint principals without an assigned owner', $tableRows
    }

    if ($disabledObjects.Count -gt 0) {
        $tableRows = ''
        foreach ($item in ($disabledObjects | Sort-Object odataType, displayName)) {
            $typeName = if ($item.odataType) { $item.odataType -replace '^#microsoft\.graph\.', '' } else { 'unknown' }
            $displayName = Get-SafeMarkdown -Text $item.displayName
            $detailsUrl = if ($item.odataType -eq '#microsoft.graph.agentIdentity') {
                $agentIdentityUrlFormat -f $item.id
            } elseif ($item.odataType -eq '#microsoft.graph.agentIdentityBlueprintPrincipal') {
                $blueprintUrlFormat -f $item.id
            } else {
                $allAgentsPortalUrl
            }
            $nameLink = "[$displayName]($detailsUrl)"
            $enabled = if ($null -eq $item.accountEnabled) { 'N/A' } elseif ($item.accountEnabled) { '✅ Enabled' } else { '❌ Disabled' }
            $tableRows += "| ``$typeName`` | $nameLink | $enabled |`n"
        }
        $mdInfo += $formatTemplate -f 'Disabled agent identities and blueprint principals', $tableRows
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
