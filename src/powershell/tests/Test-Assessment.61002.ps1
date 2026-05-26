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
    4. Fail if no workspaces exist or every workspace returns HTTP 404 (not onboarded).

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

    # Q1 + Q2: Use Azure Resource Graph to enumerate Log Analytics workspaces across all
    # in-scope subscriptions. ARG respects caller RBAC and returns only accessible resources.
    Write-ZtProgress -Activity $activity -Status 'Enumerating Log Analytics workspaces via Resource Graph'

    $argQuery = @"
resources
| where type =~ 'microsoft.operationalinsights/workspaces'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    workspaceName=name,
    workspaceId=id,
    resourceGroup,
    subscriptionId,
    subscriptionName
| order by subscriptionName asc, workspaceName asc
"@

    $allWorkspaces = @()
    try {
        $allWorkspaces = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG query returned $($allWorkspaces.Count) Log Analytics workspace(s)." -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Q3: For each workspace, query the Sentinel onboarding state.
    # HTTP 200 = Sentinel is onboarded; HTTP 404 = not onboarded.
    # -FullResponse is used so that a 404 does not throw and the status code can be inspected.
    $workspaceResults = @()
    foreach ($workspace in $allWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Checking Sentinel onboarding on workspace '$($workspace.workspaceName)'"

        $sentinelPath = "$($workspace.workspaceId)/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2024-03-01"

        $sentinelOnboarded = $false
        try {
            $sentinelResponse = Invoke-ZtAzureRequest -Path $sentinelPath -FullResponse -ErrorAction Stop
            $sentinelOnboarded = ($sentinelResponse.StatusCode -eq 200)
        }
        catch {
            Write-PSFMessage "Error checking Sentinel onboarding for workspace '$($workspace.workspaceName)': $_" -Tag Test -Level Warning
        }

        $workspaceResults += [PSCustomObject]@{
            SubscriptionName  = $workspace.subscriptionName
            WorkspaceName     = $workspace.workspaceName
            ResourceGroup     = $workspace.resourceGroup
            WorkspaceId       = $workspace.workspaceId
            SentinelOnboarded = $sentinelOnboarded
        }
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

    if ($workspaceResults.Count -gt 0) {
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
    }
    else {
        $mdInfo = "`nNo Log Analytics workspaces were found across accessible subscriptions.`n"
    }

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
