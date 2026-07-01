<#
.SYNOPSIS
    Checks whether at least one automation rule is configured in Microsoft Sentinel to manage incident response.

.DESCRIPTION
    This test enumerates all Sentinel-onboarded Log Analytics workspaces across in-scope Azure
    subscriptions and verifies that at least one has an enabled, non-expired automation rule
    configured. Automation rules are Sentinel's central control plane for incident handling: they
    fire on incident creation, incident update, or alert creation, evaluate conditions against
    incident properties, and execute actions such as assigning owners, changing status or severity,
    adding tags, suppressing duplicates, and running playbooks. Without automation rules, every
    incident is processed manually from the raw queue, inflating mean-time-to-acknowledge (MTTA)
    and mean-time-to-respond (MTTR).

    Evaluation steps:
    1. Enumerate Sentinel-onboarded Log Analytics workspaces via the shared Get-SentinelWorkspaceData helper.
    2. For each Sentinel-onboarded workspace, query the automation rules collection via the ARM API.
    3. Pass if at least one workspace has an enabled, non-expired automation rule.
    4. Fail if no enabled, non-expired automation rules exist across all checked workspaces.
    5. Investigate if the automation-rules API returns an auth or server error.
    6. Skip if no Sentinel-onboarded workspaces are found.

.NOTES
    Test ID: 41213
    Workshop Task: SECOPS_108
    Pillar: SecOps
    Category: Security information and event management
    Required permissions:
      - Reader on each subscription (for subscription and workspace enumeration)
      - Microsoft Sentinel Reader on each workspace (for automation rules query)
#>

function Test-Assessment-41213 {

    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        SfiPillar = 'Accelerate response and remediation',
        TenantType = ('Workforce'),
        TestId = 41213,
        Title = 'At least one automation rule is configured in Microsoft Sentinel to manage incident response',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking automation rules in Sentinel workspaces'

    # Q1 + Q2 + onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 (Investigate).
    # Returns $null              on unexpected ARG failure (Investigate).
    # Returns 'NoSubscriptions'  when no enabled subscriptions are accessible (Skip).
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces exist in scope (Skip).
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41213'
            Title        = 'At least one automation rule is configured in Microsoft Sentinel to manage incident response'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41213'
            Title        = 'At least one automation rule is configured in Microsoft Sentinel to manage incident response'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel automation-rules check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel automation-rules check.' -Tag Test -Level VeryVerbose
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
                TestId       = '41213'
                Title        = 'At least one automation rule is configured in Microsoft Sentinel to manage incident response'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            # Spec: no Sentinel-onboarded workspaces with full visibility — Skipped.
            Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping Sentinel automation-rules check.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Q1 (spec): List automation rules for each Sentinel-onboarded workspace.
    $rawRulesByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching automation rules for $($workspace.WorkspaceName) in $($workspace.SubscriptionName)"
        $automationRulesPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/automationRules?api-version=2024-09-01"

        try {
            $rawRulesByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path $automationRulesPath -ErrorAction Stop)
        }
        catch {
            $rawRulesByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error querying automation rules for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $now = [DateTime]::UtcNow

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $rawRules = $rawRulesByWorkspace[$workspace.WorkspaceId]

        $totalRules        = 0
        $enabledRules      = 0
        $actionTypeCounts  = @{}
        $triggersOnCounts  = @{}

        if ($null -ne $rawRules) {
            $totalRules = $rawRules.Count

            foreach ($rule in $rawRules) {
                $trigLogic = $rule.properties.triggeringLogic

                # Tally action types and triggersOn across all rules for the distribution columns.
                foreach ($action in $rule.properties.actions) {
                    if ($action.actionType) {
                        $actionTypeCounts[$action.actionType] = [int]$actionTypeCounts[$action.actionType] + 1
                    }
                }
                if ($trigLogic.triggersOn) {
                    $triggersOnCounts[$trigLogic.triggersOn] = [int]$triggersOnCounts[$trigLogic.triggersOn] + 1
                }

                # Count enabled, non-expired rules per spec pass condition.
                # A rule with expirationTimeUtc in the past is effectively disabled even when isEnabled=true.
                if ($trigLogic.isEnabled -eq $true) {
                    $expiry     = $trigLogic.expirationTimeUtc
                    $notExpired = ($null -eq $expiry) -or ([DateTime]$expiry -gt $now)
                    if ($notExpired) {
                        $enabledRules++
                    }
                }
            }
        }

        $actionTypesStr = if ($actionTypeCounts.Count -gt 0) {
            ($actionTypeCounts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name): $($_.Value)" }) -join ', '
        } else { '' }

        $triggersOnStr = if ($triggersOnCounts.Count -gt 0) {
            ($triggersOnCounts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name): $($_.Value)" }) -join ', '
        } else { '' }

        $rowStatus = if ($null -eq $rawRules) {
            'Investigate'
        }
        elseif ($enabledRules -gt 0) {
            'Pass'
        }
        else {
            'Fail'
        }

        [PSCustomObject]@{
            SubscriptionName = $workspace.SubscriptionName
            SubscriptionId   = $workspace.SubscriptionId
            WorkspaceName    = $workspace.WorkspaceName
            ResourceGroup    = $workspace.ResourceGroup
            WorkspaceId      = $workspace.WorkspaceId
            TotalRules       = $totalRules
            EnabledRules     = $enabledRules
            ActionTypes      = $actionTypesStr
            TriggersOn       = $triggersOnStr
            RowStatus        = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    $passedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Pass' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    $passed       = $passedItems.Count -gt 0
    $customStatus = $null

    if (-not $passed -and $investigateItems.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ The automation-rules API returned an unexpected response for one or more workspaces. Re-run after verifying Microsoft Sentinel Reader access on each affected workspace.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Automation rules are configured in the Sentinel workspace to manage incident response.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No enabled, non-expired automation rules are configured in the Sentinel workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalSentinelLink = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'
    $tableTitle         = 'Automation rules per workspace'

    $formatTemplate = @'


### [{0}]({1})

| Subscription | Workspace | Total rules | Enabled rules | Action types | Triggers on | Status |
| :----------- | :-------- | ----------: | ------------: | :----------- | :---------- | :----- |
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
        $subLink        = "https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)"
        $sentinelId     = "/subscriptions/$($result.SubscriptionId)/resourcegroups/$($result.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($result.WorkspaceName)"
        $automationLink = "https://portal.azure.com/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/Automation/id/$($sentinelId -replace '/', '%2F')"
        $subMd          = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd    = "[$(Get-SafeMarkdown $result.WorkspaceName)]($automationLink)"
        $actionTypesMd  = if ($result.ActionTypes) { Get-SafeMarkdown -Text $result.ActionTypes } else { '—' }
        $triggersOnMd   = if ($result.TriggersOn) { Get-SafeMarkdown -Text $result.TriggersOn } else { '—' }
        $statusDisplay  = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $subMd | $workspaceMd | $($result.TotalRules) | $($result.EnabledRules) | $actionTypesMd | $triggersOnMd | $statusDisplay |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41213'
        Title  = 'At least one automation rule is configured in Microsoft Sentinel to manage incident response'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
