<#
.SYNOPSIS
    Checks that the Agent 365 data connector is installed on at least one Microsoft Sentinel-onboarded workspace.

.DESCRIPTION
    Verifies that the A365 Observability solution ("azuresentinel.azure-sentinel-solution-a365observability")
    is installed from the Content Hub on at least one Microsoft Sentinel-onboarded Log Analytics workspace.
    The connector brings AI agent telemetry — including agent invocations, tool calls, and grounding source
    access — into Microsoft Sentinel, enabling detection of prompt-injection and data-exfiltration attacks
    that occur entirely within the agent execution layer.

.NOTES
    Test ID: 61023
    Category: AI Threat Detection
    Pillar: AI
    Required API: Azure Resource Manager (management.azure.com)
#>

function Test-Assessment-61023 {
    [ZtTest(
        Category = 'AI Threat Detection',
        ImplementationCost = 'Low',
        MinimumLicense = ('AGENT_365', 'Consumption-based: Microsoft Sentinel'),
        CompatibleLicense = ('AGENT_365'),
        Service = ('Azure'),
        Pillar = 'AI',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 61023,
        Title = 'Agent 365 data connector is enabled on the Microsoft Sentinel workspace',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity        = 'Checking Agent 365 Content Hub solution on Sentinel workspaces'
    $a365ContentId    = 'azuresentinel.azure-sentinel-solution-a365observability'
    $a365DisplayName  = 'Agent 365'
    $a365DisplayName2 = 'A365 Observability'

    # Q1 + Q2 + onboarding check.
    # Returns 'Forbidden' on ARG 401/403, $null on unexpected failure,
    # 'NoSubscriptions' / 'NoWorkspaces' when nothing is in scope.
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity
    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '61023'
            Title        = 'Agent 365 data connector is enabled on the Microsoft Sentinel workspace'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '61023'
            Title        = 'Agent 365 data connector is enabled on the Microsoft Sentinel workspace'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when enumerating subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # No enabled subscriptions accessible to the caller.
    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Agent 365 connector check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # No Log Analytics workspaces across accessible subscriptions.
    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Agent 365 connector check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardedWorkspaces = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0) {
            # Auth errors on the Sentinel onboarding check mean we cannot confirm whether
            # those workspaces are onboarded — we cannot rule out a passing workspace exists.
            $params = @{
                TestId       = '61023'
                Title        = 'Agent 365 data connector is enabled on the Microsoft Sentinel workspace'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
        }
        else {
            # Full visibility, no workspace has Sentinel onboarded.
            # Full visibility, no workspace has Sentinel onboarded — nothing to evaluate.
            $params = @{
                TestId = '61023'
                Title  = 'Agent 365 data connector is enabled on the Microsoft Sentinel workspace'
                Status = $false
                Result = '❌ No Sentinel-onboarded workspace found in tenant.'
            }
        }
        Add-ZtTestResultDetail @params
        return
    }

    $workspaceResults = @()

    foreach ($workspace in $onboardedWorkspaces) {
        $packageName = 'Not found'
        $rowStatus   = 'Fail'

        # Q3: List installed Content Hub solutions and look for the Agent 365 / A365 Observability package.
        Write-ZtProgress -Activity $activity -Status "Checking content packages on $($workspace.WorkspaceName) in subscription $($workspace.SubscriptionName)"
        $packagesPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/contentPackages?api-version=2024-09-01"

        try {
            $packages    = @(Invoke-ZtAzureRequest -Path $packagesPath -ErrorAction Stop)
            $a365Package = $packages | Where-Object {
                $_.properties.contentId -eq $a365ContentId -or
                ($_.properties.displayName -and (
                    $_.properties.displayName -ieq $a365DisplayName -or
                    $_.properties.displayName -ieq $a365DisplayName2
                ))
            } | Select-Object -First 1
            if ($a365Package) {
                $packageName = $a365Package.properties.displayName
                $rowStatus   = 'Pass'
            }
        }
        catch {
            $packageName = 'Error'
            $rowStatus   = 'Investigate'
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
        $testResultMarkdown = "⚠️ The Content Hub API returned an authorization (401/403) or transient (5xx) error on at least one workspace, so the Agent 365 connector state could not be determined for those workspaces. Re-run after verifying Microsoft Sentinel Reader on each affected workspace's resource group.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ The Agent 365 data connector is installed and connected on at least one Sentinel-onboarded workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ The Agent 365 connector is not installed on any Sentinel-onboarded workspace. Install the solution from the Microsoft Sentinel Content Hub to gain visibility into AI agent activity.`n`n%TestResult%"
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
        $subLink       = "https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)"
        $sentinelId    = "/subscriptions/$($result.SubscriptionId)/resourcegroups/$($result.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($result.WorkspaceName)"
        $workspaceLink = "https://portal.azure.com/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/DataConnectors/id/$($sentinelId -replace '/', '%2F')"
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
        TestId = '61023'
        Title  = 'Agent 365 data connector is enabled on the Microsoft Sentinel workspace'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
