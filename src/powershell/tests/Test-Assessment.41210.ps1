<#
.SYNOPSIS
    Microsoft Threat Intelligence feeds are integrated into Microsoft Sentinel

.DESCRIPTION
    This test enumerates all Sentinel-onboarded Log Analytics workspaces across in-scope Azure
    subscriptions and verifies that at least one has threat intelligence indicators ingested.
    Integration is evaluated by inspecting two resources per workspace:
    - Q1: the dataConnectors collection, filtered for the three documented TI connector kinds
      (MicrosoftThreatIntelligence, ThreatIntelligence, ThreatIntelligenceTaxii).
    - Q2: the threatIntelligence/main/metrics endpoint, which reports indicator counts grouped
      by source, threat type, and pattern type. Indicators are confirmed present when the sum of
      sourceMetrics[].metricValue is greater than zero.

    Pass:           At least one workspace has non-zero indicators regardless of connector state.
    Pass (no conn): Indicators are present but were supplied via the Microsoft Graph / Sentinel
                    upload API — no managed TI data connector is configured (noted in the table).
    Investigate:    A TI connector is configured but no indicators have been ingested, or an API
                    call for Q1 or Q2 returned an unexpected error (not the 404 zero-count case).
    Fail:           No indicators and no TI connector across all onboarded workspaces.
    Skip:           No Sentinel-onboarded workspaces found, or no subscriptions / workspaces accessible.

.NOTES
    Test ID: 41210
    Workshop Task: SECOPS_104
    Pillar: SecOps
    Category: Threat intelligence
    Required permissions:
      - Reader on each subscription (for subscription and workspace enumeration)
      - Microsoft Sentinel Reader on each workspace (for data connectors and TI metrics)
#>

function Test-Assessment-41210 {

    [ZtTest(
        Category = 'Threat intelligence',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41210,
        Title = 'Microsoft Threat Intelligence feeds are integrated into Microsoft Sentinel',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking threat intelligence integration in Sentinel workspaces'

    # Q1 + Q2 + onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 (Investigate).
    # Returns $null              on unexpected ARG failure (Investigate).
    # Returns 'NoSubscriptions'  when no enabled subscriptions are accessible (Skip).
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces exist in scope (Skip).
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41210'
            Title        = 'Microsoft Threat Intelligence feeds are integrated into Microsoft Sentinel'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41210'
            Title        = 'Microsoft Threat Intelligence feeds are integrated into Microsoft Sentinel'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel TI-integration check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel TI-integration check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardedWorkspaces = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0) {
            # Auth errors mean we cannot confirm whether those workspaces have Sentinel onboarded;
            # we cannot rule out a passing workspace exists among the inaccessible ones.
            $params = @{
                TestId       = '41210'
                Title        = 'Microsoft Threat Intelligence feeds are integrated into Microsoft Sentinel'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            # Spec: no Sentinel-onboarded workspaces with full visibility — Skipped.
            Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping Sentinel TI-integration check.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Q1 (spec): List data connectors for each workspace and identify TI connector kinds.
    # Q2 (spec): Retrieve indicator metrics. A 404 response means zero indicators (not an API error).
    $connectorsByWorkspace = @{}
    $metricsByWorkspace    = @{}
    $metricsOkByWorkspace  = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching data connectors for $($workspace.WorkspaceName) in $($workspace.SubscriptionName)"
        $dataConnectorsPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/dataConnectors?api-version=2024-09-01"

        try {
            $connectorsByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path $dataConnectorsPath -ErrorAction Stop)
        }
        catch {
            $connectorsByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error querying data connectors for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }

        Write-ZtProgress -Activity $activity -Status "Fetching threat intelligence metrics for $($workspace.WorkspaceName) in $($workspace.SubscriptionName)"
        $tiMetricsPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/threatIntelligence/main/metrics?api-version=2024-09-01"

        try {
            $rawMetrics = @(Invoke-ZtAzureRequest -Path $tiMetricsPath -ErrorAction Stop)
            $metricsByWorkspace[$workspace.WorkspaceId]   = $rawMetrics
            $metricsOkByWorkspace[$workspace.WorkspaceId] = $true
        }
        catch {
            $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($httpStatus -eq 404) {
                # ARM returns 404 with "No metrics data available" when zero indicators exist — treat as zero count.
                $metricsByWorkspace[$workspace.WorkspaceId]   = @()
                $metricsOkByWorkspace[$workspace.WorkspaceId] = $true
            }
            else {
                $metricsByWorkspace[$workspace.WorkspaceId]   = $null
                $metricsOkByWorkspace[$workspace.WorkspaceId] = $false
                Write-PSFMessage "Error querying threat intelligence metrics for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
            }
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Documented TI connector kinds from the KnownDataConnectorKind enum.
    $tiKinds = [System.Collections.Generic.HashSet[string]]::new(
        [string[]]@('MicrosoftThreatIntelligence', 'ThreatIntelligence', 'ThreatIntelligenceTaxii'),
        [System.StringComparer]::OrdinalIgnoreCase
    )

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $rawConnectors = $connectorsByWorkspace[$workspace.WorkspaceId]
        $rawMetrics    = $metricsByWorkspace[$workspace.WorkspaceId]
        $metricsOk     = $metricsOkByWorkspace[$workspace.WorkspaceId]
        $q1Ok          = $null -ne $rawConnectors

        # Identify which TI connector kinds are present in this workspace (Q1).
        $tiConnectorKinds = @()
        if ($q1Ok) {
            $tiConnectorKinds = @($rawConnectors | Where-Object { $tiKinds.Contains($_.kind) } | Select-Object -ExpandProperty kind -Unique | Sort-Object)
        }

        # Compute indicator count and metric breakdowns from Q2.
        # indicatorCount = $null when the metrics API call failed (rendered as '—' in the table).
        $indicatorCount       = $null
        $sourceMetricsStr     = $null
        $threatTypeMetricsStr = $null
        $lastUpdated          = $null

        if ($metricsOk) {
            $indicatorCount       = 0
            $sourceMetricsAgg     = @{}
            $threatTypeMetricsAgg = @{}

            foreach ($metricsItem in $rawMetrics) {
                foreach ($source in $metricsItem.properties.sourceMetrics) {
                    $indicatorCount += [int]$source.metricValue
                    if ([int]$source.metricValue -gt 0) {
                        $sourceMetricsAgg[$source.metricName] = [int]$sourceMetricsAgg[$source.metricName] + [int]$source.metricValue
                    }
                }
                foreach ($tt in $metricsItem.properties.threatTypeMetrics) {
                    if ([int]$tt.metricValue -gt 0) {
                        $threatTypeMetricsAgg[$tt.metricName] = [int]$threatTypeMetricsAgg[$tt.metricName] + [int]$tt.metricValue
                    }
                }
                # Track the most recent lastUpdatedTimeUtc across all metric entries.
                if ($metricsItem.properties.lastUpdatedTimeUtc -and (
                    -not $lastUpdated -or
                    [datetime]$metricsItem.properties.lastUpdatedTimeUtc -gt [datetime]$lastUpdated
                )) {
                    $lastUpdated = $metricsItem.properties.lastUpdatedTimeUtc
                }
            }

            $sourceMetricsStr = if ($sourceMetricsAgg.Count -gt 0) {
                ($sourceMetricsAgg.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name): $($_.Value)" }) -join ', '
            } else { '' }

            $threatTypeMetricsStr = if ($threatTypeMetricsAgg.Count -gt 0) {
                ($threatTypeMetricsAgg.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name): $($_.Value)" }) -join ', '
            } else { '' }
        }

        # Determine per-workspace row status per spec truth table.
        $rowStatus = if (-not $q1Ok -or -not $metricsOk) {
            'Investigate'
        }
        elseif ($indicatorCount -gt 0 -and $tiConnectorKinds.Count -gt 0) {
            # Q1 has a TI connector AND Q2 reports non-zero indicators — fully integrated.
            'Pass'
        }
        elseif ($indicatorCount -gt 0 -and $tiConnectorKinds.Count -eq 0) {
            # Q2 reports indicators but Q1 has no TI connector — indicators via upload API.
            'PassNoConnector'
        }
        elseif ($indicatorCount -eq 0 -and $tiConnectorKinds.Count -gt 0) {
            # TI connector configured but no indicators have been ingested.
            'Investigate'
        }
        else {
            # No TI connector and no indicators.
            'Fail'
        }

        [PSCustomObject]@{
            SubscriptionName  = $workspace.SubscriptionName
            SubscriptionId    = $workspace.SubscriptionId
            WorkspaceName     = $workspace.WorkspaceName
            ResourceGroup     = $workspace.ResourceGroup
            WorkspaceId       = $workspace.WorkspaceId
            TiConnectorKinds  = ($tiConnectorKinds -join ', ')
            IndicatorCount    = $indicatorCount
            SourceMetrics     = $sourceMetricsStr
            ThreatTypeMetrics = $threatTypeMetricsStr
            LastUpdated       = $lastUpdated
            RowStatus         = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    $passedItems          = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Pass' })
    $passNoConnectorItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'PassNoConnector' })
    $investigateItems     = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    $passed       = ($passedItems.Count + $passNoConnectorItems.Count) -gt 0
    $customStatus = $null

    if ($passed -and $forbiddenWorkspaces.Count -gt 0) {
        # Incomplete scan: some workspaces couldn't be checked — a clean Pass cannot be confirmed.
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ Microsoft Threat Intelligence appears integrated in at least one Sentinel workspace, but one or more workspaces could not be evaluated due to insufficient permissions — the overall state cannot be confirmed. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.`n`n%TestResult%"
    }
    elseif (-not $passed -and ($investigateItems.Count -gt 0 -or $forbiddenWorkspaces.Count -gt 0)) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ One or more Sentinel workspaces require manual review: a TI connector is configured but no indicators have been ingested, or an API call returned an unexpected response. Verify Microsoft Sentinel Reader access on each affected workspace and re-run the assessment.`n`n%TestResult%"
    }
    elseif ($passed) {
        if ($passNoConnectorItems.Count -gt 0 -and $passedItems.Count -eq 0) {
            # All passing workspaces have indicators supplied via the upload API — no managed connector.
            $testResultMarkdown = "✅ Microsoft Threat Intelligence is integrated into the Sentinel workspace. Indicators are present but were supplied through the Microsoft Graph / Sentinel upload API — no managed TI data connector is configured.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "✅ Microsoft Threat Intelligence is integrated into the Sentinel workspace.`n`n%TestResult%"
        }
    }
    else {
        $testResultMarkdown = "❌ Microsoft Threat Intelligence is not integrated into the Sentinel workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $azContext          = Get-AzContext -ErrorAction SilentlyContinue
    $portalHost         = if ($azContext -and $azContext.Environment.Name -eq 'AzureUSGovernment') { 'https://portal.azure.us' } else { 'https://portal.azure.com' }
    $portalSentinelLink = "$portalHost/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel"
    $tableTitle         = 'Threat intelligence status per workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | TI connectors | Total indicators | By source | By threat type | Last updated | Status |
| :----------- | :-------- | :------------ | ---------------: | :-------- | :------------- | :----------- | :----- |
{2}
'@

    $tableRows      = ''
    $maxDisplay     = 10
    $statusPriority = @{ Fail = 0; Investigate = 1; PassNoConnector = 2; Pass = 3 }
    $displayResults = @($workspaceResults | Sort-Object { $statusPriority[$_.RowStatus] }, SubscriptionName, WorkspaceName)
    $hasMoreItems   = $false
    if ($workspaceResults.Count -gt $maxDisplay) {
        $displayResults = @($displayResults | Select-Object -First $maxDisplay)
        $hasMoreItems   = $true
    }

    foreach ($result in $displayResults) {
        $subLink       = "$portalHost/#resource/subscriptions/$($result.SubscriptionId)"
        $sentinelId    = "/subscriptions/$($result.SubscriptionId)/resourcegroups/$($result.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($result.WorkspaceName)"
        $tiLink        = "$portalHost/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/ThreatIntelligence/id/$($sentinelId -replace '/', '%2F')"
        $subMd         = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd   = "[$(Get-SafeMarkdown $result.WorkspaceName)]($tiLink)"
        $connectorsMd  = if ($result.TiConnectorKinds) { $result.TiConnectorKinds } else { '—' }
        $indicatorMd   = if ($null -eq $result.IndicatorCount) { '—' } else { $result.IndicatorCount }
        $sourceMd      = if ($result.SourceMetrics) { Get-SafeMarkdown -Text $result.SourceMetrics } else { '—' }
        $threatTypeMd  = if ($result.ThreatTypeMetrics) { Get-SafeMarkdown -Text $result.ThreatTypeMetrics } else { '—' }
        $lastUpdatedMd = if ($result.LastUpdated) { Get-FormattedDate -DateString $result.LastUpdated } else { '—' }
        $statusDisplay = switch ($result.RowStatus) {
            'Pass'            { '✅ Pass' }
            'PassNoConnector' { '✅ Pass (no connector)' }
            'Fail'            { '❌ Fail' }
            'Investigate'     { '⚠️ Investigate' }
        }
        $tableRows += "| $subMd | $workspaceMd | $connectorsMd | $indicatorMd | $sourceMd | $threatTypeMd | $lastUpdatedMd | $statusDisplay |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows     += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41210'
        Title  = 'Microsoft Threat Intelligence feeds are integrated into Microsoft Sentinel'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
