<#
.SYNOPSIS
    Checks that the Microsoft Purview Information Protection Content Hub solution is installed on the Microsoft Sentinel workspace.

.DESCRIPTION
    Verifies that the Microsoft Purview Information Protection solution is installed from the Content Hub on at least one
    Microsoft Sentinel-onboarded Log Analytics workspace.

.NOTES
    Test ID: 61018
    Category: AI Threat Detection
    Pillar: AI
    Required API: Azure Resource Manager (management.azure.com)
    Depends on: 61002 (Sentinel onboarding precondition)
#>

function Test-Assessment-61018 {
    [ZtTest(
        Category = 'AI Threat Detection',
        MinimumLicense = ('MIP_S_CLP1', 'Consumption-based: Microsoft Sentinel'),
        CompatibleLicense = ('MIP_S_CLP1'),
        ImplementationCost = 'Low',
        Pillar = 'AI',
        RiskLevel = 'Medium',
        Service = ('Azure'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 61018,
        Title = 'Microsoft Purview Information Protection data connector is enabled on the Microsoft Sentinel workspace',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Microsoft Purview Information Protection Content Hub solution on Sentinel workspaces'

    # Q1 + Q2 + onboarding check.
    # Returns 'Forbidden' on ARG 401/403, $null on unexpected failure,
    # 'NoSubscriptions' / 'NoWorkspaces' when nothing is in scope.
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity
    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '61018'
            Title        = 'Microsoft Purview Information Protection data connector is enabled on the Microsoft Sentinel workspace'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '61018'
            Title        = 'Microsoft Purview Information Protection data connector is enabled on the Microsoft Sentinel workspace'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # No enabled subscriptions accessible to the caller.
    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel onboarding check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # No Log Analytics workspaces across accessible subscriptions.
    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel onboarding check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces  = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces  = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardedWorkspaces  = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0) {
            # Auth errors on the Sentinel onboarding check mean we cannot confirm whether
            # those workspaces are onboarded — we cannot rule out a passing workspace exists.
            $params = @{
                TestId       = '61018'
                Title        = 'Microsoft Purview Information Protection data connector is enabled on the Microsoft Sentinel workspace'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
        }
        else {
            # Full visibility, no workspace has Sentinel onboarded.
            $params = @{
                TestId = '61018'
                Title  = 'Microsoft Purview Information Protection data connector is enabled on the Microsoft Sentinel workspace'
                Status = $false
                Result = '❌ No Sentinel-onboarded workspace in tenant.'
            }
        }
        Add-ZtTestResultDetail @params
        return
    }

    $workspaceResults = @()

    foreach ($workspace in $onboardedWorkspaces) {
        $packageName = 'Not found'
        $rowStatus   = 'Fail'

        # Q3: List installed Content Hub solutions and look for Microsoft Purview Information Protection
        Write-ZtProgress -Activity $activity -Status "Checking content packages on $($workspace.WorkspaceName) in subscription $($workspace.SubscriptionName)"
        $packagesPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/contentPackages?api-version=2024-09-01"

        try {
            $packages   = @(Invoke-ZtAzureRequest -Path $packagesPath -ErrorAction Stop)
            $mipPackage = $packages | Where-Object { $_.properties.displayName -ieq 'Microsoft Purview Information Protection' } | Select-Object -First 1
            if ($mipPackage) {
                $packageName = 'Microsoft Purview Information Protection'
                $rowStatus   = 'Pass'
            }
        }
        catch {
            $packageName = 'Error'
            $rowStatus = 'Investigate'
            Write-PSFMessage "Error querying content packages for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }

        $workspaceResults += [PSCustomObject]@{
            SubscriptionName = $workspace.SubscriptionName
            SubscriptionId   = $workspace.SubscriptionId
            WorkspaceName    = $workspace.WorkspaceName
            ResourceGroup    = $workspace.ResourceGroup
            WorkspaceId      = $workspace.WorkspaceId
            PackageName      = $packageName
            RowStatus        = $rowStatus
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Pass' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    $passed       = $passedItems.Count -gt 0
    $customStatus = $null

    if (-not $passed -and $investigateItems.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ The Content Hub API returned an authorization (401/403) or transient (5xx) error on at least one workspace, so the Microsoft Purview Information Protection solution state could not be determined for those workspaces. Re-run after verifying Microsoft Sentinel Reader on each affected workspace's resource group.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ The Microsoft Purview Information Protection data connector is enabled on at least one Sentinel-onboarded workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ The Microsoft Purview Information Protection data connector is not enabled on any Sentinel-onboarded workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalSentinelLink = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'
    $tableTitle         = 'Sentinel data connectors per workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | Content package | Status |
| :----------- | :-------- | :-------------- | :----- |
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
        $subLink            = "https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)"
        $sentinelId         = "/subscriptions/$($result.SubscriptionId)/resourcegroups/$($result.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($result.WorkspaceName)"
        $workspaceLink      = "https://portal.azure.com/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/DataConnectors/id/$($sentinelId -replace '/', '%2F')"
        $subMd         = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd   = "[$(Get-SafeMarkdown $result.WorkspaceName)]($workspaceLink)"
        $packageMd     = $result.PackageName
        $statusDisplay = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $subMd | $workspaceMd | $packageMd | $statusDisplay |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '61018'
        Title  = 'Microsoft Purview Information Protection data connector is enabled on the Microsoft Sentinel workspace'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
