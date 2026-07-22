<#
.SYNOPSIS
    Checks that at least one watchlist is configured in Microsoft Sentinel for
    correlation against high-value entities.

.NOTES
    Test ID: 41208
    Workshop Task: SECOPS_102
    Pillar: SecOps
    Category: Security information and event management
    Required API: Azure Resource Manager (management.azure.com)
#>
function Test-Assessment-41208 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Low',
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Low',
        Service = ('Azure'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41208,
        Title = 'At least one watchlist is configured in Microsoft Sentinel for correlation against high-value entities',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking watchlists configured in Microsoft Sentinel workspaces'

    # Q1 + Q2 + onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 (Investigate).
    # Returns $null              on unexpected ARG failure (Investigate).
    # Returns 'NoSubscriptions'  when no enabled subscriptions are accessible (Skip).
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces exist in scope (Skip).
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41208'
            Title        = 'At least one watchlist is configured in Microsoft Sentinel for correlation against high-value entities'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41208'
            Title        = 'At least one watchlist is configured in Microsoft Sentinel for correlation against high-value entities'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel watchlists check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel watchlists check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardedWorkspaces = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0) {
            # Auth errors mean we cannot confirm whether those workspaces have Sentinel onboarded;
            # a passing workspace may exist among the inaccessible ones.
            $params = @{
                TestId       = '41208'
                Title        = 'At least one watchlist is configured in Microsoft Sentinel for correlation against high-value entities'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            # Spec: no Sentinel-onboarded workspaces with full visibility — Skipped.
            Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping Sentinel watchlists check.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Q1 (spec): Enumerate all watchlists for each Sentinel-onboarded workspace.
    # Invoke-ZtAzureRequest paginates automatically (Paginate=$true for GET) and unwraps .value.
    $watchlistsByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching watchlists for workspace '$($workspace.WorkspaceName)' in '$($workspace.SubscriptionName)'"
        $watchlistsPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/watchlists?api-version=2024-09-01"

        try {
            $watchlistsByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path $watchlistsPath -ErrorAction Stop)
        }
        catch {
            $watchlistsByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error querying watchlists for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $rawWatchlists = $watchlistsByWorkspace[$workspace.WorkspaceId]

        $activeWatchlists    = @()
        $succeededWatchlists = @()
        $rowStatus           = 'Fail'

        if ($null -eq $rawWatchlists) {
            # API error for this workspace — cannot determine watchlist state.
            $rowStatus = 'Investigate'
        }
        else {
            # Exclude deleted watchlists per spec.
            $activeWatchlists    = @($rawWatchlists | Where-Object { $_.properties.isDeleted -ne $true })
            $succeededWatchlists = @($activeWatchlists | Where-Object { $_.properties.provisioningState -eq 'Succeeded' })

            $rowStatus = if ($succeededWatchlists.Count -ge 1) {
                'Pass'
            }
            elseif ($activeWatchlists.Count -gt 0) {
                # Watchlists exist (Failed, New, Uploading, Canceled, or Deleting) but none have provisioningState = Succeeded.
                'Investigate'
            }
            else {
                # No active (non-deleted) watchlists found.
                'Fail'
            }
        }

        [PSCustomObject]@{
            SubscriptionName = $workspace.SubscriptionName
            SubscriptionId   = $workspace.SubscriptionId
            WorkspaceName    = $workspace.WorkspaceName
            ResourceGroup    = $workspace.ResourceGroup
            WorkspaceId      = $workspace.WorkspaceId
            TotalWatchlists  = if ($null -eq $rawWatchlists) { $null } else { $activeWatchlists.Count }
            ActiveWatchlists = $activeWatchlists   # kept for per-watchlist report rendering
            RowStatus        = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    $passedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Pass' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    $passed       = $passedItems.Count -gt 0
    $customStatus = $null

    if (-not $passed -and ($investigateItems.Count -gt 0 -or $forbiddenWorkspaces.Count -gt 0)) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ The watchlists API returned an unexpected response, or all watchlists report a non-successful provisioningState.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ At least one watchlist is configured in the Sentinel workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No watchlists are configured in the Sentinel workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $azContext          = Get-AzContext -ErrorAction SilentlyContinue
    $portalHost         = if ($azContext -and $azContext.Environment.Name -eq 'AzureUSGovernment') { 'https://portal.azure.us' } else { 'https://portal.azure.com' }
    $portalSentinelLink = "$portalHost/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel"
    $tableTitle         = 'Watchlists per Sentinel workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | Watchlist count | Watchlist names | Watchlist aliases | Providers | Provisioning states | Status |
| :----------- | :-------- | :-------------- | :-------------- | :---------------- | :-------- | :------------------ | :----- |
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
        $subLink        = "$portalHost/#resource/subscriptions/$($result.SubscriptionId)"
        $sentinelId     = "/subscriptions/$($result.SubscriptionId)/resourcegroups/$($result.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($result.WorkspaceName)"
        $watchlistsLink = "$portalHost/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/Watchlists/id/$($sentinelId -replace '/', '%2F')"
        $subMd          = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd    = "[$(Get-SafeMarkdown $result.WorkspaceName)]($watchlistsLink)"
        $statusDisplay  = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }

        if ($result.ActiveWatchlists.Count -gt 0) {
            $namesMd   = ($result.ActiveWatchlists | ForEach-Object { Get-SafeMarkdown $_.properties.displayName }) -join ', '
            $aliasesMd = ($result.ActiveWatchlists | ForEach-Object { Get-SafeMarkdown $_.properties.watchlistAlias }) -join ', '
            $provsMd   = ($result.ActiveWatchlists | ForEach-Object { Get-SafeMarkdown $_.properties.provider }) -join ', '
            $statesMd  = ($result.ActiveWatchlists | ForEach-Object {
                if ($_.properties.provisioningState -eq 'Succeeded') { '✅ Succeeded' } else { "⚠️ $($_.properties.provisioningState)" }
            }) -join ', '
            $tableRows += "| $subMd | $workspaceMd | $($result.TotalWatchlists) | $namesMd | $aliasesMd | $provsMd | $statesMd | $statusDisplay |`n"
        }
        else {
            # No active watchlists (Fail) or API error (Investigate) — one placeholder row so the workspace appears in the table
            $countMd    = if ($null -eq $result.TotalWatchlists) { '—' } else { $result.TotalWatchlists }
            $tableRows += "| $subMd | $workspaceMd | $countMd | — | — | — | — | $statusDisplay |`n"
        }
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41208'
        Title  = 'At least one watchlist is configured in Microsoft Sentinel for correlation against high-value entities'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
