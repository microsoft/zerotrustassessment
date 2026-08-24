<#
.SYNOPSIS
    Checks that data collection rules (DCRs) are used to control ingestion into Microsoft Sentinel workspaces.

.DESCRIPTION
    Verifies that every Sentinel-onboarded Log Analytics workspace is the destination of at least
    one Azure Monitor data collection rule whose data flow routes telemetry to that destination,
    confirming that ingestion is explicitly controlled rather than default-configured or absent.

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
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        ImplementationCost = 'Medium',
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

    foreach ($workspace in $onboardedWorkspaces) {
        $subId = $workspace.SubscriptionId
        if ($dcrStateBySubscription.ContainsKey($subId)) {
            continue
        }

        Write-ZtProgress -Activity $activity -Status "Listing data collection rules for subscription '$($workspace.SubscriptionName)' (Q1)"
        $dcrPath = "/subscriptions/$subId/providers/Microsoft.Insights/dataCollectionRules?api-version=2022-06-01"

        try {
            # GET requests are paged automatically and ARM list responses are unwrapped by the helper.
            $listedDcrs = @(Invoke-ZtAzureRequest -Path $dcrPath -ErrorAction Stop)
        }
        catch {
            $dcrStateBySubscription[$subId] = $null
            Write-PSFMessage "Error listing data collection rules for subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
            continue
        }

        $fullDcrs   = @()
        $errorDcrs  = @()
        foreach ($dcr in $listedDcrs) {
            try {
                Write-ZtProgress -Activity $activity -Status "Fetching data collection rule '$($dcr.name)' (Q2)"
                $fullDcr = Invoke-ZtAzureRequest -Path "$($dcr.id)?api-version=2022-06-01" -ErrorAction Stop
                $fullDcrs += @($fullDcr)
            }
            catch {
                $errorDcrs += [PSCustomObject]@{
                    Name       = $dcr.name
                    ResourceId = $dcr.id
                    Reason     = $_.Exception.Message
                }
                Write-PSFMessage "Error fetching data collection rule '$($dcr.name)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
            }
        }

        $dcrStateBySubscription[$subId] = [PSCustomObject]@{
            Rules      = $fullDcrs
            ErrorRules = $errorDcrs
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $dcrState = $dcrStateBySubscription[$workspace.SubscriptionId]

        $dcrDetails       = @()
        $missingTransform = $false
        $rowStatus        = 'Fail'

        if ($null -eq $dcrState) {
            # DCR enumeration failed — cannot determine ingestion control for this workspace.
            $rowStatus = 'Investigate'
        }
        else {
            $dcrDetails = @(foreach ($dcr in $dcrState.Rules) {
                # dataSources is an object keyed by source type (windowsEventLogs, syslog,
                # performanceCounters, extensions, logFiles); report the populated keys.
                $dataSourceTypes = @()
                if ($dcr.properties.dataSources) {
                    $dataSourceTypes = @($dcr.properties.dataSources.PSObject.Properties |
                        Where-Object { @($_.Value).Count -gt 0 } |
                        ForEach-Object { $_.Name })
                }

                $matchingDestinationNames = @($dcr.properties.destinations.logAnalytics |
                    Where-Object { $_.workspaceResourceId -ieq $workspace.WorkspaceId -and -not [string]::IsNullOrWhiteSpace($_.name) } |
                    ForEach-Object { $_.name } | Select-Object -Unique)
                $routedFlows = @($dcr.properties.dataFlows | Where-Object {
                    $flowDestinations = @($_.destinations)
                    @($matchingDestinationNames | Where-Object { $_ -iin $flowDestinations }).Count -gt 0
                })
                $routesToDestination = $matchingDestinationNames.Count -gt 0 -and $routedFlows.Count -gt 0
                $transformPresent    = $routesToDestination -and @($routedFlows | Where-Object {
                    -not [string]::IsNullOrWhiteSpace($_.transformKql)
                }).Count -gt 0

                $reason = if ($routesToDestination -and $transformPresent) {
                    'Telemetry is routed with an ingestion transform.'
                }
                elseif ($routesToDestination) {
                    'Telemetry is routed without an ingestion transform.'
                }
                elseif ($matchingDestinationNames.Count -gt 0) {
                    'The destination is not referenced by a data flow.'
                }
                else {
                    'The workspace is not configured as a destination.'
                }

                [PSCustomObject]@{
                    Name                     = $dcr.name
                    ResourceId               = $dcr.id
                    MatchingDestinationNames = $matchingDestinationNames
                    RoutesToDestination      = $routesToDestination
                    DataSourceTypes          = $dataSourceTypes
                    TransformPresent         = $transformPresent
                    Status                   = if ($routesToDestination) { 'Pass' } else { 'Fail' }
                    Reason                   = $reason
                }
            })

            $dcrDetails += @(foreach ($errorDcr in $dcrState.ErrorRules) {
                [PSCustomObject]@{
                    Name                     = $errorDcr.Name
                    ResourceId               = $errorDcr.ResourceId
                    MatchingDestinationNames = @()
                    RoutesToDestination      = $null
                    DataSourceTypes          = @()
                    TransformPresent         = $null
                    Status                   = 'Investigate'
                    Reason                   = "The data collection rule detail could not be read: $($errorDcr.Reason)"
                }
            })

            $qualifyingDcrs   = @($dcrDetails | Where-Object { $_.Status -eq 'Pass' })
            $missingTransform = $qualifyingDcrs.Count -gt 0 -and @($qualifyingDcrs | Where-Object { $_.TransformPresent }).Count -eq 0

            $rowStatus = if (@($dcrState.ErrorRules).Count -gt 0) { 'Investigate' }
            elseif ($qualifyingDcrs.Count -gt 0) { 'Pass' }
            else { 'Fail' }
        }

        [PSCustomObject]@{
            SubscriptionName    = $workspace.SubscriptionName
            SubscriptionId      = $workspace.SubscriptionId
            WorkspaceName       = $workspace.WorkspaceName
            ResourceGroup       = $workspace.ResourceGroup
            WorkspaceId         = $workspace.WorkspaceId
            DataCollectionRules = $dcrDetails
            MissingTransform    = $missingTransform
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
            DataCollectionRules = @()
            MissingTransform    = $false
            RowStatus           = 'Investigate'
        }
    }
    $workspaceResults = @($workspaceResults) + @($unresolvedWorkspaceResults)

    $investigateItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })
    $failedItems           = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Fail' })
    $missingTransformItems = @($workspaceResults | Where-Object { $_.MissingTransform })
    $totalWorkspaceCount   = $workspaceResults.Count

    # Pass only when every onboarded workspace is targeted by at least one DCR and no workspace
    # state is unknown (API failure or insufficient permissions).
    $passed       = $failedItems.Count -eq 0 -and $investigateItems.Count -eq 0
    $customStatus = $null

    # Spec: missing ingestion transforms are surfaced as a warning and never change the verdict.
    $transformNote = ''
    if ($missingTransformItems.Count -gt 0) {
        $transformWorkspaceLabel = if ($missingTransformItems.Count -eq 1) { 'workspace has' } else { 'workspaces have' }
        $transformNote = "`n`n⚠️ $($missingTransformItems.Count) Sentinel $transformWorkspaceLabel qualifying data collection rules, but none of those rules apply an ingestion transform to the routed data flow."
    }

    $investigateNote = ''
    if ($failedItems.Count -gt 0 -and $investigateItems.Count -gt 0) {
        $investigateNote = "`n`n⚠️ In addition, $($investigateItems.Count) of $totalWorkspaceCount Sentinel workspaces could not be evaluated due to permission or API errors."
    }

    if ($failedItems.Count -gt 0) {
        $testResultMarkdown = "❌ Sentinel workspaces without a qualifying data collection rule configured to send telemetry: $($failedItems.Count) of $totalWorkspaceCount.$investigateNote$transformNote`n`n%TestResult%"
    }
    elseif ($investigateItems.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ Sentinel workspaces that could not be evaluated due to permission or API errors: $($investigateItems.Count) of $totalWorkspaceCount.$transformNote`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "✅ Sentinel workspaces with a qualifying data collection rule controlling ingestion: $totalWorkspaceCount of $totalWorkspaceCount.$transformNote`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation

    $azContext     = Get-AzContext -ErrorAction SilentlyContinue
    $portalHost    = if ($azContext -and $azContext.Environment.Name -eq 'AzureUSGovernment') { 'https://portal.azure.us' } else { 'https://portal.azure.com' }
    $portalDcrLink = "$portalHost/#view/HubsExtension/BrowseResource/resourceType/Microsoft.Insights%2FdataCollectionRules"
    $tableTitle    = 'Data collection rules per Sentinel workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | DCR | Matching destination name | Data flow routes to destination | Data source types | Transform present | Status | Reason | Workspace status |
| :----------- | :-------- | :-- | :------------------------ | :------------------------------- | :---------------- | :---------------- | :----- | :----- | :--------------- |
{2}
'@

    $tableRows      = ''
    $maxDisplayRows = 10
    $statusPriority = @{ Fail = 0; Investigate = 1; Pass = 2 }
    $statusDisplay  = @{ Fail = '❌ Fail'; Investigate = '⚠️ Investigate'; Pass = '✅ Pass' }
    $sortedResults  = @($workspaceResults | Sort-Object { $statusPriority[$_.RowStatus] }, SubscriptionName, WorkspaceName)
    $reportRows     = @(foreach ($result in $sortedResults) {
        if ($result.DataCollectionRules.Count -eq 0) {
            [PSCustomObject]@{
                WorkspaceResult    = $result
                DataCollectionRule = $null
            }
            continue
        }

        foreach ($dcr in $result.DataCollectionRules) {
            [PSCustomObject]@{
                WorkspaceResult    = $result
                DataCollectionRule = $dcr
            }
        }
    })
    $displayRows  = @($reportRows | Select-Object -First $maxDisplayRows)
    $hasMoreItems = $reportRows.Count -gt $maxDisplayRows

    foreach ($reportRow in $displayRows) {
        $result      = $reportRow.WorkspaceResult
        $dcr         = $reportRow.DataCollectionRule
        $subLink     = "$portalHost/#resource/subscriptions/$($result.SubscriptionId)"
        $subMd       = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd = "[$(Get-SafeMarkdown $result.WorkspaceName)]($portalHost/#resource$($result.WorkspaceId)/overview)"
        $rollupMd    = $statusDisplay[$result.RowStatus]

        if ($null -eq $dcr) {
            # No DCRs (Fail) or unresolved enumeration/onboarding state (Investigate).
            $placeholderReason = if ($result.RowStatus -eq 'Fail') { 'No data collection rules exist in the subscription.' }
            else { 'Data collection rules or Sentinel onboarding state could not be read.' }
            $tableRows += "| $subMd | $workspaceMd | — | — | — | — | — | — | $placeholderReason | $rollupMd |`n"
            continue
        }

        $dcrNameMd     = if ([string]::IsNullOrWhiteSpace($dcr.Name)) { 'Unknown rule' } else { Get-SafeMarkdown $dcr.Name }
        $dcrMd         = if ([string]::IsNullOrWhiteSpace($dcr.ResourceId)) { $dcrNameMd } else { "[$dcrNameMd]($portalHost/#resource$($dcr.ResourceId)/overview)" }
        $destinationMd = if ($dcr.MatchingDestinationNames.Count -gt 0) { ($dcr.MatchingDestinationNames | ForEach-Object { Get-SafeMarkdown $_ }) -join ', ' } else { '—' }
        $transformMd   = if (-not $dcr.RoutesToDestination) { '—' } elseif ($dcr.TransformPresent) { '✅ Yes' } else { '⚠️ No' }
        $reasonMd      = Get-SafeMarkdown $dcr.Reason

        $tableRows += "| $subMd | $workspaceMd | $dcrMd | $destinationMd | $routesMd | $sourcesMd | $transformMd | $($statusDisplay[$dcr.Status]) | $reasonMd | $rollupMd |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $reportRows.Count - $maxDisplayRows
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
