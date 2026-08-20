<#
.SYNOPSIS
    Checks that data collection rules (DCRs) are used to control ingestion into Microsoft Sentinel workspaces.

.DESCRIPTION
    Verifies that every Sentinel-onboarded Log Analytics workspace is referenced by at least one
    Azure Monitor data collection rule, confirming that ingestion is explicitly controlled rather
    than default-configured or absent.

.NOTES
    Test ID: 41205
    Workshop Task: SECOPS_097
    Pillar: SecOps
    Category: Security information and event management
    Required API: Azure Resource Manager (management.azure.com), Microsoft.Insights dataCollectionRules
#>
function Test-Assessment-41205 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        Service = ('Azure'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41205,
        Title = 'Data collection rules (DCRs) are used to control ingestion into Microsoft Sentinel workspaces',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    $testTitle = 'Data collection rules (DCRs) are used to control ingestion into Microsoft Sentinel workspaces'

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking data collection rules for Microsoft Sentinel workspaces'

    # Subscription + workspace enumeration and Sentinel onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 (Investigate).
    # Returns $null              on unexpected ARG failure (Investigate).
    # Returns 'NoSubscriptions'  when no enabled subscriptions are accessible (Skip).
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces exist in scope (Skip).
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41205'
            Title        = $testTitle
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41205'
            Title        = $testTitle
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel data collection rules check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel data collection rules check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces  = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces  = @($allWorkspaces | Where-Object { $_.PermissionError })
    $unresolvedWorkspaces = @($checkableWorkspaces | Where-Object { $_.OnboardingError })
    $onboardedWorkspaces  = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0 -or $unresolvedWorkspaces.Count -gt 0) {
            # Errors mean we cannot confirm whether those workspaces have Sentinel onboarded.
            $params = @{
                TestId       = '41205'
                Title        = $testTitle
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions or an unexpected error when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            # Spec: no Sentinel-onboarded workspaces — Skipped.
            Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping Sentinel data collection rules check.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Cache completed DCR definitions per subscription so workspaces in the same subscription
    # share the Q1 enumeration and Q2 detail requests.
    $dcrStateBySubscription = @{}

    # Hashtable keys are case-insensitive, matching the spec's case-insensitive workspace comparison.
    $knownWorkspaceIds = @{}
    foreach ($workspace in $allWorkspaces) {
        $knownWorkspaceIds[$workspace.WorkspaceId] = $true
    }

    foreach ($workspace in $onboardedWorkspaces) {
        $subId = $workspace.SubscriptionId
        if ($dcrStateBySubscription.ContainsKey($subId)) {
            continue
        }

        Write-ZtProgress -Activity $activity -Status "Listing data collection rules for subscription '$($workspace.SubscriptionName)' (Q1)"
        $dcrPath = "/subscriptions/$subId/providers/Microsoft.Insights/dataCollectionRules?api-version=2022-06-01"

        try {
            $listedDcrs = @(Invoke-ZtAzureRequest -Path $dcrPath -ErrorAction Stop)
        }
        catch {
            $dcrStateBySubscription[$subId] = $null
            Write-PSFMessage "Error listing data collection rules for subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
            continue
        }

        $fullDcrs = @()
        $hasDetailErrors = $false
        $hasUnresolvedDestinations = $false
        foreach ($dcr in $listedDcrs) {
            try {
                if ([string]::IsNullOrWhiteSpace($dcr.id)) {
                    throw "Data collection rule '$($dcr.name)' did not include a resource ID."
                }

                Write-ZtProgress -Activity $activity -Status "Fetching data collection rule '$($dcr.name)' (Q2)"
                $fullDcr = Invoke-ZtAzureRequest -Path "$($dcr.id)?api-version=2022-06-01" -ErrorAction Stop
                $fullDcrs += @($fullDcr)

                # A destination pointing at a workspace outside the enumerated inventory cannot be resolved.
                if (@($fullDcr.properties.destinations.logAnalytics | Where-Object {
                            $_.workspaceResourceId -and -not $knownWorkspaceIds.ContainsKey($_.workspaceResourceId)
                        }).Count -gt 0) {
                    $hasUnresolvedDestinations = $true
                }
            }
            catch {
                $hasDetailErrors = $true
                Write-PSFMessage "Error fetching data collection rule '$($dcr.name)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
            }
        }

        $dcrStateBySubscription[$subId] = [PSCustomObject]@{
            Rules                     = $fullDcrs
            HasDetailErrors           = $hasDetailErrors
            HasUnresolvedDestinations = $hasUnresolvedDestinations
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $dcrState = $dcrStateBySubscription[$workspace.SubscriptionId]

        $dcrCount   = $null
        $dcrDetails = @()
        $rowStatus  = 'Fail'

        if ($null -eq $dcrState) {
            # DCR enumeration failed — cannot determine ingestion control for this workspace.
            $rowStatus = 'Investigate'
        }
        else {
            # A DCR targets the workspace when any Log Analytics destination references the
            # workspace resource ID (case-insensitive) per spec evaluation logic.
            $matchedDcrs = @($dcrState.Rules | Where-Object {
                @($_.properties.destinations.logAnalytics | Where-Object { $_.workspaceResourceId -ieq $workspace.WorkspaceId }).Count -gt 0
            })

            $dcrCount = $matchedDcrs.Count
            $dcrDetails = @(foreach ($dcr in $matchedDcrs) {
                # dataSources is an object keyed by source type (windowsEventLogs, syslog,
                # performanceCounters, extensions, logFiles); report the populated keys.
                $dataSourceTypes = @()
                if ($dcr.properties.dataSources) {
                    $dataSourceTypes = @($dcr.properties.dataSources.PSObject.Properties |
                        Where-Object { @($_.Value).Count -gt 0 } |
                        ForEach-Object { $_.Name })
                }

                $flowNumber = 0
                $dataFlowTransforms = @(foreach ($dataFlow in @($dcr.properties.dataFlows)) {
                    $flowNumber++
                    if ([string]::IsNullOrWhiteSpace($dataFlow.transformKql)) {
                        "⚠️ Flow ${flowNumber}: not configured"
                    }
                    else {
                        "✅ Flow ${flowNumber}: configured"
                    }
                })

                [PSCustomObject]@{
                    Name               = $dcr.name
                    ResourceId         = $dcr.id
                    DataSourceTypes    = $dataSourceTypes
                    DataFlowTransforms = $dataFlowTransforms
                }
            })

            # A confirmed match is proof per spec, so uncertainty about other rules cannot override it.
            $rowStatus = if ($dcrCount -ge 1) {
                'Pass'
            }
            elseif ($dcrState.HasDetailErrors -or $dcrState.HasUnresolvedDestinations) {
                'Investigate'
            }
            else {
                'Fail'
            }
        }

        [PSCustomObject]@{
            SubscriptionName    = $workspace.SubscriptionName
            SubscriptionId      = $workspace.SubscriptionId
            WorkspaceName       = $workspace.WorkspaceName
            ResourceGroup       = $workspace.ResourceGroup
            WorkspaceId         = $workspace.WorkspaceId
            DcrCount            = $dcrCount
            DataCollectionRules = $dcrDetails
            RowStatus           = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    # Workspaces whose Sentinel onboarding state could not be confirmed are reported as
    # Investigate rows so they remain visible in the table alongside checked workspaces.
    $unresolvedWorkspaceResults = foreach ($workspace in @($forbiddenWorkspaces) + @($unresolvedWorkspaces)) {
        [PSCustomObject]@{
            SubscriptionName    = $workspace.SubscriptionName
            SubscriptionId      = $workspace.SubscriptionId
            WorkspaceName       = $workspace.WorkspaceName
            ResourceGroup       = $workspace.ResourceGroup
            WorkspaceId         = $workspace.WorkspaceId
            DcrCount            = $null
            DataCollectionRules = @()
            RowStatus           = 'Investigate'
        }
    }
    $workspaceResults = @($workspaceResults) + @($unresolvedWorkspaceResults)

    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })
    $failedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Fail' })

    # Pass only when every onboarded workspace is targeted by at least one DCR and no workspace
    # state is unknown (API failure or insufficient permissions).
    $passed       = $failedItems.Count -eq 0 -and $investigateItems.Count -eq 0
    $customStatus = $null

    if ($investigateItems.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ Data collection rules are present but reference workspaces that cannot be resolved.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Data collection rules control ingestion into the Sentinel workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No data collection rules are configured to send telemetry to the Sentinel workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $azContext     = Get-AzContext -ErrorAction SilentlyContinue
    $portalHost    = if ($azContext -and $azContext.Environment.Name -eq 'AzureUSGovernment') { 'https://portal.azure.us' } else { 'https://portal.azure.com' }
    $portalDcrLink = "$portalHost/#view/HubsExtension/BrowseResource/resourceType/Microsoft.Insights%2FdataCollectionRules"
    $tableTitle    = 'Data collection rules per Sentinel workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | DCRs targeting workspace | Rule name | Data sources | Ingestion transform | Status |
| :----------- | :-------- | -----------------------: | :-------- | :----------- | :------------------ | :----- |
{2}
'@

    $tableRows      = ''
    $maxDisplay     = 10
    $statusPriority = @{ Fail = 0; Investigate = 1; Pass = 2 }
    $displayResults = @($workspaceResults | Sort-Object { $statusPriority[$_.RowStatus] }, SubscriptionName, WorkspaceName)
    $hasMoreItems   = $false
    if ($workspaceResults.Count -gt $maxDisplay) {
        $displayResults = @($displayResults | Select-Object -First $maxDisplay)
        $hasMoreItems   = $true
    }

    foreach ($result in $displayResults) {
        $subLink       = "$portalHost/#resource/subscriptions/$($result.SubscriptionId)"
        $subMd         = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd   = "[$(Get-SafeMarkdown $result.WorkspaceName)]($portalHost/#resource$($result.WorkspaceId)/overview)"
        $countMd       = if ($null -eq $result.DcrCount) { '—' } else { $result.DcrCount }
        $statusDisplay = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }

        if ($result.DataCollectionRules.Count -gt 0) {
            # One row per matching rule — preserves the data-source-to-transform association.
            foreach ($dcr in $result.DataCollectionRules) {
                $dcrMd       = "[$(Get-SafeMarkdown $dcr.Name)]($portalHost/#resource$($dcr.ResourceId)/overview)"
                $sourcesMd   = if ($dcr.DataSourceTypes.Count -gt 0) { ($dcr.DataSourceTypes | ForEach-Object { Get-SafeMarkdown $_ }) -join ', ' } else { '—' }
                $transformMd = if ($dcr.DataFlowTransforms.Count -eq 0) {
                    '⚠️ No data flows'
                }
                else {
                    $dcr.DataFlowTransforms -join ', '
                }
                $tableRows += "| $subMd | $workspaceMd | $countMd | $dcrMd | $sourcesMd | $transformMd | $statusDisplay |`n"
            }
        }
        else {
            # No matching DCR (Fail) or unresolved state (Investigate) — one placeholder row so the workspace appears in the table.
            $tableRows += "| $subMd | $workspaceMd | $countMd | — | — | — | $statusDisplay |`n"
        }
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all data collection rules]($portalDcrLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalDcrLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41205'
        Title  = $testTitle
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
