<#
.SYNOPSIS
    Hunting capabilities are operationalized in Microsoft Sentinel via saved hunting queries or bookmarks
#>
function Test-Assessment-41212 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Medium',
        Service = ('Azure'),
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        SfiPillar = 'Accelerate response and remediation',
        TenantType = ('Workforce'),
        TestId = 41212,
        Title = 'Hunting capabilities are operationalized in Microsoft Sentinel via saved hunting queries or bookmarks',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Sentinel hunting queries and bookmarks'

    # Q1 + Q2 + onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 (Investigate).
    # Returns $null              on unexpected ARG failure (Investigate).
    # Returns 'NoSubscriptions'  when no enabled subscriptions are accessible (Skip).
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces exist in scope (Skip).
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41212'
            Title        = 'Hunting capabilities are operationalized in Microsoft Sentinel via saved hunting queries or bookmarks'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41212'
            Title        = 'Hunting capabilities are operationalized in Microsoft Sentinel via saved hunting queries or bookmarks'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel hunting check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel hunting check.' -Tag Test -Level VeryVerbose
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
                TestId       = '41212'
                Title        = 'Hunting capabilities are operationalized in Microsoft Sentinel via saved hunting queries or bookmarks'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            # Spec: no Sentinel-onboarded workspaces with full visibility — Skipped.
            Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping Sentinel hunting check.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Q1 (spec): List saved searches; filter to those with category "Hunting Queries".
    $rawSavedSearchesByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching saved hunting queries for $($workspace.WorkspaceName) in $($workspace.SubscriptionName)"
        $savedSearchesPath = "$($workspace.WorkspaceId)/savedSearches?api-version=2026-03-01"

        try {
            $rawSavedSearchesByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path $savedSearchesPath -ErrorAction Stop)
        }
        catch {
            $rawSavedSearchesByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error querying saved hunting queries for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    # Q2 (spec): List bookmarks for each Sentinel-onboarded workspace.
    $rawBookmarksByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching bookmarks for $($workspace.WorkspaceName) in $($workspace.SubscriptionName)"
        $bookmarksPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/bookmarks?api-version=2025-09-01"

        try {
            $rawBookmarksByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path $bookmarksPath -ErrorAction Stop)
        }
        catch {
            $rawBookmarksByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error querying bookmarks for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $rawSavedSearches = $rawSavedSearchesByWorkspace[$workspace.WorkspaceId]
        $rawBookmarks     = $rawBookmarksByWorkspace[$workspace.WorkspaceId]

        $q1Error = $null -eq $rawSavedSearches
        $q2Error = $null -eq $rawBookmarks

        $huntingQueryCount   = $null
        $bookmarkCount       = $null
        $recentBookmarkName  = $null
        $recentBookmarkBy    = $null

        if (-not $q1Error) {
            # savedSearches of category "Hunting Queries" are the persisted hunting surface.
            $huntingSearches   = @($rawSavedSearches | Where-Object { $_.properties.category -eq 'Hunting Queries' })
            $huntingQueryCount = $huntingSearches.Count
        }

        if (-not $q2Error) {
            $bookmarkCount = $rawBookmarks.Count

            if ($bookmarkCount -gt 0) {
                # Surface the most recently created bookmark for the display table.
                $recentBookmark    = $rawBookmarks | Sort-Object { $_.properties.created } -Descending | Select-Object -First 1
                $recentBookmarkName = $recentBookmark.properties.displayName
                $recentBookmarkBy  = if ($recentBookmark.properties.createdBy.name) {
                    $recentBookmark.properties.createdBy.name
                } elseif ($recentBookmark.properties.createdBy.email) {
                    $recentBookmark.properties.createdBy.email
                } else { $null }
            }
        }

        # Spec evaluation order — first matching rule wins:
        # Rule 1: Pass if Q1 succeeded with count >= 1 OR Q2 succeeded with count >= 1.
        #         A confirmed positive from either surface is authoritative even if the other errored.
        # Rule 2: Investigate if either query errored (absence cannot be confirmed while a query fails).
        # Rule 3: Fail if both succeeded and both counts are zero.
        $rowStatus = if ((-not $q1Error -and $huntingQueryCount -ge 1) -or (-not $q2Error -and $bookmarkCount -ge 1)) {
            'Pass'
        } elseif ($q1Error -or $q2Error) {
            'Investigate'
        } else {
            'Fail'
        }

        [PSCustomObject]@{
            SubscriptionName   = $workspace.SubscriptionName
            SubscriptionId     = $workspace.SubscriptionId
            WorkspaceName      = $workspace.WorkspaceName
            ResourceGroup      = $workspace.ResourceGroup
            WorkspaceId        = $workspace.WorkspaceId
            HuntingQueryCount  = $huntingQueryCount
            BookmarkCount      = $bookmarkCount
            RecentBookmarkName = $recentBookmarkName
            RecentBookmarkBy   = $recentBookmarkBy
            RowStatus          = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    $passedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Pass' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    $passed       = $passedItems.Count -gt 0
    $customStatus = $null

    if (-not $passed -and ($investigateItems.Count -gt 0 -or $forbiddenWorkspaces.Count -gt 0)) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ Hunting capability could not be confirmed — one or more workspaces had insufficient permissions on the Sentinel onboarding check, or the saved hunting queries or bookmarks API returned an unexpected response. Re-run after verifying Microsoft Sentinel Reader access on each affected workspace.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Hunting capability is operationalized in the Sentinel workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No saved hunting queries or bookmarks exist in the Sentinel workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalSentinelLink = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'
    $tableTitle         = 'Hunting queries and bookmarks per workspace'

    $formatTemplate = @'


### [{0}]({1})

| Subscription | Workspace | Hunting queries | Bookmarks | Recent bookmark | Created by | Status |
| :----------- | :-------- | --------------: | --------: | :-------------- | :--------- | :----- |
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
        $subLink         = "https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)"
        $sentinelId      = "/subscriptions/$($result.SubscriptionId)/resourcegroups/$($result.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($result.WorkspaceName)"
        $huntingLink     = "https://portal.azure.com/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/Hunting/id/$($sentinelId -replace '/', '%2F')"
        $subMd           = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd     = "[$(Get-SafeMarkdown $result.WorkspaceName)]($huntingLink)"
        $huntingCountMd  = if ($null -eq $result.HuntingQueryCount) { '—' } else { $result.HuntingQueryCount }
        $bookmarkCountMd = if ($null -eq $result.BookmarkCount) { '—' } else { $result.BookmarkCount }
        $recentNameMd    = if ($result.RecentBookmarkName) { Get-SafeMarkdown -Text $result.RecentBookmarkName } else { '—' }
        $recentByMd      = if ($result.RecentBookmarkBy) { Get-SafeMarkdown -Text $result.RecentBookmarkBy } else { '—' }
        $statusDisplay   = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $subMd | $workspaceMd | $huntingCountMd | $bookmarkCountMd | $recentNameMd | $recentByMd | $statusDisplay |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows     += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41212'
        Title  = 'Hunting capabilities are operationalized in Microsoft Sentinel via saved hunting queries or bookmarks'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
