<#
.SYNOPSIS
    Checks whether Microsoft Sentinel is onboarded on at least one Log Analytics workspace.

.DESCRIPTION
    This test enumerates all Log Analytics workspaces across in-scope Azure subscriptions and
    verifies that at least one has Microsoft Sentinel onboarded. Sentinel is required as a central
    SIEM before any other AI threat detection control in this pillar can correlate signals across
    the environment.

    Evaluation steps:
    1. Use Azure Resource Graph to enumerate all Log Analytics workspaces (combining subscription
       listing and workspace listing in one query).
    2. For each workspace, query the Sentinel onboarding state resource via the
       Microsoft.SecurityInsights/onboardingStates/default ARM endpoint.
    3. Pass if at least one workspace returns HTTP 200 (Sentinel is onboarded).
    4. Fail if workspaces exist but every one returns HTTP 404 (Sentinel not onboarded).
    5. Skip if no Log Analytics workspaces are found across accessible subscriptions.

.NOTES
    Test ID: 61002
    Workshop Task: AI_089
    Pillar: AI
    Category: AI Threat Detection
    Required permissions:
      - Reader on each subscription (for Log Analytics workspace enumeration)
      - Microsoft Sentinel Reader on each workspace (for onboarding state query)
#>

function Test-Assessment-61002 {

    [ZtTest(
        Category = 'AI Threat Detection',
        ImplementationCost = 'Medium',
        Service = ('Azure'),
        MinimumLicense = ('Microsoft_Sentinel'),
        Pillar = ('AI', 'SecOps'),
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 61002,
        Title = 'Microsoft Sentinel is onboarded on at least one Log Analytics workspace',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating Microsoft Sentinel onboarding state across Log Analytics workspaces'

    # Delegate all data fetching (Q1+Q2+Q3) to the private helper.
    # 'Forbidden'       → 401/403 on Q1 or Q2 ARG query (spec: Investigate).
    # $null             → unexpected ARG failure.
    # 'NoSubscriptions' → Q1 succeeded but no enabled subscriptions accessible (spec: Skip).
    # 'NoWorkspaces'    → Q2 succeeded but no Log Analytics workspaces found (spec: Skip).
    # array             → workspace results; individual entries may have PermissionError=$true
    #                     when the Q3 Sentinel check returned 401/403 for that workspace.
    $workspaceResults = Get-SentinelWorkspaceData -Activity $activity

    # 401/403 on Q1 or Q2 ARG query → Investigate.
    if ($workspaceResults -eq 'Forbidden') {
        $params = @{
            TestId       = '61002'
            Title        = 'Microsoft Sentinel is onboarded on at least one Log Analytics workspace'
            Status       = $false
            Result       = '⚠️ Some of the queried resources returned status indicating insufficient permissions. Please make sure you have at least reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Unexpected ARG failure.
    if ($null -eq $workspaceResults) {
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # No enabled subscriptions accessible to the caller.
    if ($workspaceResults -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel onboarding check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # No Log Analytics workspaces across accessible subscriptions.
    if ($workspaceResults -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel onboarding check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $checkableWorkspaces  = @($workspaceResults | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces  = @($workspaceResults | Where-Object { $_.PermissionError })
    $onboardedWorkspaces  = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    # If every workspace returned 403 on the Sentinel check, treat the whole result as Investigate.
    if ($forbiddenWorkspaces.Count -gt 0 -and $checkableWorkspaces.Count -eq 0) {
        $params = @{
            TestId       = '61002'
            Title        = 'Microsoft Sentinel is onboarded on at least one Log Analytics workspace'
            Status       = $false
            Result       = '⚠️ All Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. Please make sure you have Microsoft Sentinel Reader on each workspace.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Evaluate pass/fail only from workspaces that could be checked.
    $passed = $onboardedWorkspaces.Count -ge 1

    if ($passed) {
        $testResultMarkdown = "✅ Microsoft Sentinel is onboarded on at least one Log Analytics workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No Log Analytics workspace in scope has Microsoft Sentinel onboarded.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $workspacesPortalUrl     = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/Microsoft.OperationalInsights%2Fworkspaces'
    $workspacePortalTemplate = 'https://portal.azure.com/#resource{0}/overview'

    $formatTemplate = @'


### [{0}]({1})

| Subscription | Workspace | Resource group | Sentinel onboarded |
| :----------- | :-------- | :------------- | :----------------- |
{2}

**Summary:**

- Total workspaces: {3}
- Workspaces with Sentinel onboarded: {4}
- Workspaces skipped (insufficient permissions): {5}
'@

    $onboardedCount  = $onboardedWorkspaces.Count
    $forbiddenCount  = $forbiddenWorkspaces.Count

    $tableRows = ''
    foreach ($result in $workspaceResults) {
        $subscriptionName = Get-SafeMarkdown -Text $result.SubscriptionName
        $workspaceName    = Get-SafeMarkdown -Text $result.WorkspaceName
        $resourceGroup    = Get-SafeMarkdown -Text $result.ResourceGroup
        $workspaceLink    = "[$workspaceName]($($workspacePortalTemplate -f $result.WorkspaceId))"
        $onboardedLabel   = if ($result.PermissionError) { '⚠️ No access' } elseif ($result.SentinelOnboarded) { '✅ Yes' } else { '❌ No' }
        $tableRows        += "| $subscriptionName | $workspaceLink | $resourceGroup | $onboardedLabel |`n"
    }

    $partialWarning = ''
    if ($forbiddenCount -gt 0) {
        $partialWarning = "`n`n> ⚠️ **$forbiddenCount workspace(s) could not be checked** due to insufficient permissions on the Sentinel onboarding state endpoint. Ensure Microsoft Sentinel Reader is granted on those workspaces and re-run the assessment."
    }

    $mdInfo = ($formatTemplate -f 'Workspaces and their Sentinel onboarding state', $workspacesPortalUrl, $tableRows, $workspaceResults.Count, $onboardedCount, $forbiddenCount) + $partialWarning

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '61002'
        Title  = 'Microsoft Sentinel is onboarded on at least one Log Analytics workspace'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
