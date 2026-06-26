<#
.SYNOPSIS
    Checks that active analytics rules are configured in Microsoft Sentinel to detect threats.

.DESCRIPTION
    Verifies that at least one Sentinel-onboarded Log Analytics workspace has at least one
    analytics (alert) rule of a substantive kind (Scheduled, NRT, or
    MicrosoftSecurityIncidentCreation) enabled. A workspace with only the default Fusion rule
    enabled is considered non-compliant because Fusion alone is not sufficient detection
    coverage for a production environment.

.NOTES
    Test ID: 41207
    Category: Security information and event management
    Pillar: Security Operations
    Required API: Azure Resource Manager (management.azure.com)
#>

function Test-Assessment-41207 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Azure'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41207,
        Title = 'Active analytics rules are configured in Microsoft Sentinel to detect threats',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking active analytics rules in Sentinel workspaces'

    # Q1 + Q2 + onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 (Investigate).
    # Returns $null              on unexpected ARG failure (Investigate).
    # Returns 'NoSubscriptions'  when no enabled subscriptions are accessible (Skip).
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces exist in scope (Skip).
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41207'
            Title        = 'Active analytics rules are configured in Microsoft Sentinel to detect threats'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41207'
            Title        = 'Active analytics rules are configured in Microsoft Sentinel to detect threats'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel analytics-rules check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel analytics-rules check.' -Tag Test -Level VeryVerbose
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
                TestId       = '41207'
                Title        = 'Active analytics rules are configured in Microsoft Sentinel to detect threats'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            # Spec: no Sentinel-onboarded workspaces with full visibility — Skipped.
            Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping Sentinel analytics-rules check.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Q1 (spec) / Q3 (implementation — Q1+Q2 handled by Get-SentinelWorkspaceData):
    # Fetch all analytics (alert) rules for each Sentinel-onboarded workspace.
    $rawRulesByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching analytics rules for $($workspace.WorkspaceName) in $($workspace.SubscriptionName)"
        $alertRulesPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/alertRules?api-version=2024-09-01"

        try {
            $rawRulesByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path $alertRulesPath -ErrorAction Stop)
        }
        catch {
            $rawRulesByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error querying analytics rules for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $rawRules = $rawRulesByWorkspace[$workspace.WorkspaceId]

        $totalRules        = 0
        $enabledRules      = 0
        $enabledKinds      = @()
        $mitreTactics      = @()
        $onlyFusionEnabled = $false

        if ($null -ne $rawRules) {
            $totalRules         = $rawRules.Count
            $enabledRuleObjects = @($rawRules | Where-Object { $_.properties.enabled -eq $true })
            $enabledRules       = $enabledRuleObjects.Count

            # Collect the kind of every enabled rule; only Scheduled and NRT rules expose
            # properties.tactics so limit the tactics harvest to those two kinds.
            $enabledKinds = @($enabledRuleObjects | Select-Object -ExpandProperty kind -Unique | Sort-Object)
            $mitreTactics = @(
                $enabledRuleObjects |
                    Where-Object { $_.kind -iin @('Scheduled', 'NRT') } |
                    ForEach-Object { $_.properties.tactics } |
                    Where-Object { $_ } |
                    Sort-Object -Unique
            )
        }

        # Spec: pass only when at least one actionable rule kind is enabled.
        # Fusion is enabled by default in new workspaces and must not be credited alone.
        $actionableKinds   = @('Scheduled', 'NRT', 'MicrosoftSecurityIncidentCreation')
        $hasActionableRule = ($enabledKinds | Where-Object { $_ -iin $actionableKinds }).Count -gt 0

        $rowStatus = if ($null -eq $rawRules) {
            'Investigate'
        }
        elseif ($enabledRules -gt 0 -and $hasActionableRule) {
            'Pass'
        }
        elseif ($enabledRules -eq 0) {
            'Fail'
        }
        else {
            # Enabled rules exist but none are of an actionable kind.
            $onlyFusionEnabled = ($enabledKinds.Count -eq 1 -and ($enabledKinds -icontains 'Fusion'))
            'Fail'
        }

        [PSCustomObject]@{
            SubscriptionName  = $workspace.SubscriptionName
            SubscriptionId    = $workspace.SubscriptionId
            WorkspaceName     = $workspace.WorkspaceName
            ResourceGroup     = $workspace.ResourceGroup
            WorkspaceId       = $workspace.WorkspaceId
            TotalRules        = $totalRules
            EnabledRules      = $enabledRules
            EnabledKinds      = ($enabledKinds -join ', ')
            MitreTactics      = ($mitreTactics -join ', ')
            OnlyFusionEnabled = $onlyFusionEnabled
            RowStatus         = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    $passedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Pass' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })
    $failedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Fail' })

    $passed       = $passedItems.Count -gt 0
    $customStatus = $null

    if (-not $passed -and $investigateItems.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ The alert-rules API returned an unexpected response for one or more workspaces. Re-run after verifying Microsoft Sentinel Reader access on each affected workspace.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Active analytics rules are configured in the Sentinel workspace.`n`n%TestResult%"
    }
    else {
        $onlyFusionItems = @($failedItems | Where-Object { $_.OnlyFusionEnabled })
        if ($onlyFusionItems.Count -gt 0 -and $failedItems.Count -eq $onlyFusionItems.Count) {
            # Every failing workspace has only the default Fusion rule — surface the specific condition.
            $testResultMarkdown = "❌ No active analytics rules are configured in the Sentinel workspace. Only the default Fusion rule is enabled, which is not sufficient for threat detection coverage.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ No active analytics rules are configured in the Sentinel workspace.`n`n%TestResult%"
        }
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalSentinelLink = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'
    $tableTitle         = 'Analytics rules per workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | Total rules | Enabled rules | Enabled rule types | MITRE tactics | Status |
| :----------- | :-------- | ----------: | ------------: | :----------------- | :------------ | :----- |
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
        $subLink       = "https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)"
        $sentinelId    = "/subscriptions/$($result.SubscriptionId)/resourcegroups/$($result.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($result.WorkspaceName)"
        $analyticsLink = "https://portal.azure.com/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/AnalyticRules/id/$($sentinelId -replace '/', '%2F')"
        $subMd         = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd   = "[$(Get-SafeMarkdown $result.WorkspaceName)]($analyticsLink)"
        $kindsMd       = if ($result.EnabledKinds) { Get-SafeMarkdown -Text $result.EnabledKinds } else { '—' }
        $tacticsMd     = if ($result.MitreTactics) { Get-SafeMarkdown -Text $result.MitreTactics } else { '—' }
        $statusDisplay = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $subMd | $workspaceMd | $($result.TotalRules) | $($result.EnabledRules) | $kindsMd | $tacticsMd | $statusDisplay |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41207'
        Title  = 'Active analytics rules are configured in Microsoft Sentinel to detect threats'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
