<#
.SYNOPSIS
    Checks whether the Microsoft 365 Copilot data connector is enabled on at least one
    Microsoft Sentinel-onboarded workspace.

.DESCRIPTION
    For each Microsoft Sentinel-onboarded Log Analytics workspace, the test checks whether
    the "Microsoft Copilot" content package is installed from the Sentinel Content Hub (Q3).

    The tenant passes when at least one workspace has the "Microsoft Copilot" content package
    installed.

.NOTES
    Test ID: 61021
    Workshop Task: AI_089
    Pillar: AI
    Category: AI Threat Detection
    Required permissions:
      Microsoft.Resources/subscriptions/read          — subscription enumeration (Q1)
      Microsoft.SecurityInsights/contentPackages/read — content package list per workspace (Q3)
#>
function Test-Assessment-61021 {
    [ZtTest(
        Category           = 'AI Threat Detection',
        CompatibleLicense  = ('Microsoft_365_Copilot'),
        ImplementationCost = 'Low',
        Pillar             = 'AI',
        RiskLevel          = 'High',
        Service            = ('Azure'),
        SfiPillar          = 'Monitor and detect cyberthreats',
        TenantType         = ('Workforce'),
        TestId             = 61021,
        Title              = 'Microsoft 365 Copilot data connector is enabled on the Microsoft Sentinel workspace',
        UserImpact         = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Microsoft 365 Copilot data connector on Sentinel-onboarded workspaces'

    # Q1 (subscriptions) + Q2 (workspaces) + onboarding-state check:
    # Delegate to the shared helper used by 61002. Returns the same sentinel values.
    # $null             → unexpected ARG failure (spec: Investigate)
    # 'Forbidden'       → 401/403 on Q1 or Q2 ARG query (spec: Investigate)
    # 'NoSubscriptions' → no enabled subscriptions (spec: skip NotApplicable)
    # 'NoWorkspaces'    → no Log Analytics workspaces found (spec: skip NotApplicable)
    # array             → workspace results (SentinelOnboarded, PermissionError flags)
    $workspaceResults = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $workspaceResults) {
        $params = @{
            TestId       = '61021'
            Title        = 'Microsoft 365 Copilot data connector is enabled on the Microsoft Sentinel workspace'
            Status       = $false
            Result       = '⚠️ Some of the queried resources returned status indicating not sufficient permissions. Please make sure you have at least reader access to the Azure Subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($workspaceResults -eq 'Forbidden') {
        $params = @{
            TestId       = '61021'
            Title        = 'Microsoft 365 Copilot data connector is enabled on the Microsoft Sentinel workspace'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($workspaceResults -in @('NoSubscriptions', 'NoWorkspaces')) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Only Sentinel-onboarded workspaces are in scope for connector evaluation.
    # Workspaces where Q3 (onboarding check) returned 401/403 have PermissionError=$true and
    # SentinelOnboarded=$false — exclude them from the onboarded set but track them separately
    # so we can return Investigate instead of a silent NotApplicable skip.
    $permErrorFromHelper = @($workspaceResults | Where-Object { $_.PermissionError })
    $onboardedWorkspaces = @($workspaceResults | Where-Object { $_.SentinelOnboarded })
    if ($onboardedWorkspaces.Count -eq 0) {
        if ($permErrorFromHelper.Count -gt 0) {
            $params = @{
                TestId       = '61021'
                Title        = 'Microsoft 365 Copilot data connector is enabled on the Microsoft Sentinel workspace'
                Status       = $false
                Result       = '⚠️ Some of the queried resources returned status indicating not sufficient permissions. Please make sure you have at least reader access to the Azure Subscriptions being tested.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
            return
        }
        Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping connector check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q3: For each Sentinel-onboarded workspace check for the "Microsoft Copilot" content package.
    $workspaceEvaluations = @()

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Checking content packages on workspace '$($workspace.WorkspaceName)'"

        $packages        = $null
        $permissionError = $false
        try {
            $packages = Invoke-ZtAzureRequest `
                -Path "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/contentPackages?api-version=2024-09-01" `
                -ErrorAction Stop
        }
        catch {
            $httpStatusCode = $null
            if ($_.Exception.Message -match 'with status (\d+):') { $httpStatusCode = [int]$Matches[1] }
            if ($httpStatusCode -in @(401, 403)) {
                $permissionError = $true
                Write-PSFMessage "Q3 content packages for workspace '$($workspace.WorkspaceName)' returned $httpStatusCode — insufficient permissions." -Tag Test -Level Warning
            }
            else {
                # 5xx or network error — treat as Investigate per spec
                $permissionError = $true
                Write-PSFMessage "Q3 content packages for workspace '$($workspace.WorkspaceName)' failed (status $httpStatusCode): $_" -Tag Test -Level Warning
            }
        }

        $contentPackageName = $null
        $rowStatus          = 'Fail'
        if ($permissionError) {
            $rowStatus = 'Investigate'
        }
        else {
            $copilotPackage = $packages | Where-Object { $_.properties.displayName -ieq 'Microsoft Copilot' } | Select-Object -First 1
            if ($copilotPackage) {
                $contentPackageName = $copilotPackage.properties.displayName
                $rowStatus          = 'Pass'
            }
        }

        $workspaceEvaluations += [PSCustomObject]@{
            SubscriptionName   = $workspace.SubscriptionName
            WorkspaceName      = $workspace.WorkspaceName
            WorkspaceId        = $workspace.WorkspaceId
            ContentPackageName = $contentPackageName
            RowStatus          = $rowStatus
            PermissionError    = $permissionError
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passingWorkspaces = @($workspaceEvaluations | Where-Object { $_.RowStatus -eq 'Pass' })
    $investigateItems  = @($workspaceEvaluations | Where-Object { $_.RowStatus -eq 'Investigate' })

    # All workspaces had permission/server errors and none passed → return Investigate immediately
    if ($investigateItems.Count -gt 0 -and $passingWorkspaces.Count -eq 0 -and
        @($workspaceEvaluations | Where-Object { $_.RowStatus -eq 'Fail' }).Count -eq 0) {
        $params = @{
            TestId       = '61021'
            Title        = 'Microsoft 365 Copilot data connector is enabled on the Microsoft Sentinel workspace'
            Status       = $false
            Result       = '⚠️ Some of the queried resources returned status indicating not sufficient permissions. Please make sure you have at least reader access to the Azure Subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $passed = $passingWorkspaces.Count -gt 0

    if ($passed) {
        $testResultMarkdown = '✅ The Microsoft 365 Copilot data connector is enabled on at least one Sentinel-onboarded workspace.%TestResult%'
    }
    else {
        $testResultMarkdown = '❌ The Microsoft 365 Copilot data connector is not enabled on any Sentinel-onboarded workspace.%TestResult%'
    }

    #endregion Assessment Logic

    #region Report Generation

    $sentinelPortalUrl = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'

    $formatTemplate = @'

### [Sentinel data connectors per workspace]({0})

| Subscription | Workspace | Content Package | Status |
| :----------- | :-------- | :-------------- | :----- |
{1}
'@

    $tableRows = ''
    foreach ($evaluation in $workspaceEvaluations) {
        $subscriptionName = Get-SafeMarkdown -Text $evaluation.SubscriptionName
        $workspaceName    = Get-SafeMarkdown -Text $evaluation.WorkspaceName
        $packageDisplay   = if ($evaluation.ContentPackageName) { Get-SafeMarkdown -Text $evaluation.ContentPackageName } else { 'absent' }
        $statusDisplay    = switch ($evaluation.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Investigate' { '⚠️ Investigate' }
            default       { '❌ Fail' }
        }
        $tableRows += "| $subscriptionName | $workspaceName | $packageDisplay | $statusDisplay |`n"
    }

    $partialWarning = ''
    if ($investigateItems.Count -gt 0) {
        $partialWarning = "`n`n> ⚠️ **$($investigateItems.Count) workspace(s) could not be fully checked** due to insufficient permissions or a server error on the content packages endpoint. Ensure Microsoft Sentinel Reader is granted on those workspaces and re-run the assessment."
    }

    $mdInfo = ($formatTemplate -f $sentinelPortalUrl, $tableRows) + $partialWarning
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '61021'
        Title  = 'Microsoft 365 Copilot data connector is enabled on the Microsoft Sentinel workspace'
        Status = $passed
        Result = $testResultMarkdown
    }
    if (-not $passed -and $investigateItems.Count -gt 0) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
