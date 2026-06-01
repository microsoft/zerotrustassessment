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
        Pillar = 'AI',
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

    # Verify Azure connection
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'
    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Delegate all data fetching (Q1+Q2+Q3) to the private helper.
    # 'Forbidden' signals a 403 on the ARG workspace query (spec: Investigate).
    # $null signals any other ARG failure.
    # An empty array signals no workspaces found (spec: Skip).
    $workspaceResults = Get-SentinelWorkspaceData -Activity $activity

    # Per spec: Q2 returns 403 → Investigate.
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

    # $null signals a non-403 ARG failure.
    if ($null -eq $workspaceResults) {
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Per spec: zero workspaces → Skipped, not Failed.
    if ($workspaceResults.Count -eq 0) {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $onboardedWorkspaces = @($workspaceResults | Where-Object { $_.SentinelOnboarded })
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
'@

    $onboardedCount = $onboardedWorkspaces.Count

    $tableRows = ''
    foreach ($result in $workspaceResults) {
        $subscriptionName = Get-SafeMarkdown -Text $result.SubscriptionName
        $workspaceName    = Get-SafeMarkdown -Text $result.WorkspaceName
        $resourceGroup    = Get-SafeMarkdown -Text $result.ResourceGroup
        $workspaceLink    = "[$workspaceName]($($workspacePortalTemplate -f $result.WorkspaceId))"
        $onboardedLabel   = if ($result.SentinelOnboarded) { '✅ Yes' } else { '❌ No' }
        $tableRows        += "| $subscriptionName | $workspaceLink | $resourceGroup | $onboardedLabel |`n"
    }

    $mdInfo = $formatTemplate -f 'Workspaces and their Sentinel onboarding state', $workspacesPortalUrl, $tableRows, $workspaceResults.Count, $onboardedCount

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
