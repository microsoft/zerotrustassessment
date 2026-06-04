<#
.SYNOPSIS
    Checks whether the Microsoft 365 Copilot data connector is enabled on at least one
    Microsoft Sentinel-onboarded workspace.

.DESCRIPTION
    For each Microsoft Sentinel-onboarded Log Analytics workspace, the test evaluates two paths:

      Path A (ARM data connector): The workspace has either (a) an Office365 data connector with
      CopilotActivity dataType enabled, or (b) a MicrosoftCopilot connector with its primary
      dataType enabled.

      Path B (Content Pack): The workspace has the "Microsoft Copilot" content package installed
      from the Content Hub.

    The tenant passes when at least one workspace satisfies either path.

.NOTES
    Test ID: 61021
    Workshop Task: AI_089
    Pillar: AI
    Category: AI Threat Detection
    Required permissions:
      Microsoft.Resources/subscriptions/read — subscription enumeration (Q1)
      Microsoft.SecurityInsights/dataConnectors/read — data connector list per workspace (Q3)
      Microsoft.SecurityInsights/contentPackages/read — content package list per workspace (Q4)
#>
function Test-Assessment-61021 {
    [ZtTest(
        Category           = 'AI Threat Detection',
        MinimumLicense      = ('Microsoft_365_Copilot'),
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
    # 'Forbidden'       → 401/403 on Q1 or Q2 ARG query (spec: Investigate)
    # $null             → unexpected ARG failure (spec: skip NotSupported)
    # 'NoSubscriptions' → no enabled subscriptions (spec: skip NotApplicable)
    # 'NoWorkspaces'    → no Log Analytics workspaces found (spec: skip NotApplicable)
    # array             → workspace results (SentinelOnboarded, PermissionError flags)
    $workspaceResults = Get-SentinelWorkspaceData -Activity $activity

    if ($workspaceResults -eq 'Forbidden') {
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

    if ($null -eq $workspaceResults) {
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    if ($workspaceResults -in @('NoSubscriptions', 'NoWorkspaces')) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Only Sentinel-onboarded workspaces are in scope for connector evaluation.
    $onboardedWorkspaces = @($workspaceResults | Where-Object { $_.SentinelOnboarded })
    if ($onboardedWorkspaces.Count -eq 0) {
        Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping connector check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q3 + Q4: For each Sentinel-onboarded workspace evaluate data connectors and content packages.
    $workspaceEvaluations = @()

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Checking connectors on workspace '$($workspace.WorkspaceName)'"

        # Q3: List data connectors — used to evaluate Path A
        $connectors        = $null
        $q3PermissionError = $false
        try {
            $connectors = Invoke-ZtAzureRequest `
                -Path "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/dataConnectors?api-version=2024-09-01" `
                -ErrorAction Stop
        }
        catch {
            $httpStatusCode = $null
            if ($_.Exception.Message -match 'with status (\d+):') { $httpStatusCode = [int]$Matches[1] }
            if ($httpStatusCode -in @(401, 403)) {
                $q3PermissionError = $true
                Write-PSFMessage "Q3 data connectors for workspace '$($workspace.WorkspaceName)' returned $httpStatusCode — insufficient permissions." -Tag Test -Level Warning
            }
            else {
                Write-PSFMessage "Q3 data connectors for workspace '$($workspace.WorkspaceName)' failed: $_" -Tag Test -Level Warning
            }
        }

        # Q4: List installed content packages — used to evaluate Path B
        $packages          = $null
        $q4PermissionError = $false
        try {
            $packages = Invoke-ZtAzureRequest `
                -Path "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/contentPackages?api-version=2024-09-01" `
                -ErrorAction Stop
        }
        catch {
            $httpStatusCode = $null
            if ($_.Exception.Message -match 'with status (\d+):') { $httpStatusCode = [int]$Matches[1] }
            if ($httpStatusCode -in @(401, 403)) {
                $q4PermissionError = $true
                Write-PSFMessage "Q4 content packages for workspace '$($workspace.WorkspaceName)' returned $httpStatusCode — insufficient permissions." -Tag Test -Level Warning
            }
            else {
                Write-PSFMessage "Q4 content packages for workspace '$($workspace.WorkspaceName)' failed: $_" -Tag Test -Level Warning
            }
        }

        # Evaluate Path A: Office365/CopilotActivity or MicrosoftCopilot connector enabled
        $pathAConnectorName = $null
        $pathADataTypes     = $null
        $pathAStatus        = 'Fail'
        if ($q3PermissionError) {
            $pathAStatus = 'NoAccess'
        }
        else {
            foreach ($connector in $connectors) {
                if ($connector.kind -ieq 'Office365') {
                    if ($connector.properties.dataTypes.CopilotActivity.state -ieq 'Enabled') {
                        $pathAConnectorName = 'Office365.CopilotActivity'
                        $pathADataTypes     = 'CopilotActivity'
                        $pathAStatus        = 'Pass'
                        break
                    }
                }
                elseif ($connector.kind -ieq 'MicrosoftCopilot') {
                    $primaryDataType = $connector.properties.dataTypes | Select-Object -First 1
                    if ($primaryDataType -and $primaryDataType.state -ieq 'Enabled') {
                        $pathAConnectorName = 'MicrosoftCopilot'
                        $pathADataTypes     = 'Enabled'
                        $pathAStatus        = 'Pass'
                        break
                    }
                }
            }
        }

        # Evaluate Path B: "Microsoft Copilot" content package installed
        $pathBPackageName = $null
        $pathBStatus      = 'Fail'
        if ($q4PermissionError) {
            $pathBStatus = 'NoAccess'
        }
        else {
            $copilotPackage = $packages | Where-Object { $_.properties.displayName -ieq 'Microsoft Copilot' } | Select-Object -First 1
            if ($copilotPackage) {
                $pathBPackageName = $copilotPackage.properties.displayName
                $pathBStatus      = 'Pass'
            }
        }

        $workspaceEvaluations += [PSCustomObject]@{
            SubscriptionName   = $workspace.SubscriptionName
            WorkspaceName      = $workspace.WorkspaceName
            WorkspaceId        = $workspace.WorkspaceId
            PathAStatus        = $pathAStatus
            PathAConnectorName = $pathAConnectorName
            PathADataTypes     = $pathADataTypes
            PathBStatus        = $pathBStatus
            PathBPackageName   = $pathBPackageName
            PermissionError    = ($q3PermissionError -or $q4PermissionError)
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passingWorkspaces   = @($workspaceEvaluations | Where-Object { $_.PathAStatus -eq 'Pass' -or $_.PathBStatus -eq 'Pass' })
    $permissionErrors    = @($workspaceEvaluations | Where-Object { $_.PermissionError })
    $checkableWorkspaces = @($workspaceEvaluations | Where-Object { -not $_.PermissionError })

    # All workspaces had permission errors on Q3/Q4 → return Investigate immediately
    if ($permissionErrors.Count -gt 0 -and $checkableWorkspaces.Count -eq 0) {
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
        $testResultMarkdown = 'The Microsoft 365 Copilot data connector is enabled on at least one Sentinel-onboarded workspace.%TestResult%'
    }
    else {
        $testResultMarkdown = 'The Microsoft 365 Copilot data connector is not enabled on any Sentinel-onboarded workspace.%TestResult%'
    }

    #endregion Assessment Logic

    #region Report Generation

    $sentinelPortalUrl = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'

    $formatTemplate = @'

### [Sentinel data connectors per workspace]({0})

| Subscription | Workspace | Path | Connector / Package | Enabled dataTypes | Status |
| :----------- | :-------- | :--- | :------------------ | :---------------- | :----- |
{1}
'@

    $tableRows = ''
    foreach ($evaluation in $workspaceEvaluations) {
        $subscriptionName = Get-SafeMarkdown -Text $evaluation.SubscriptionName
        $workspaceName    = Get-SafeMarkdown -Text $evaluation.WorkspaceName

        # Path A row
        $pathAConnector   = if ($evaluation.PathAConnectorName) { Get-SafeMarkdown -Text $evaluation.PathAConnectorName } else { 'absent' }
        $pathADataTypes   = if ($evaluation.PathADataTypes)     { Get-SafeMarkdown -Text $evaluation.PathADataTypes }     else { 'n/a' }
        $pathAStatusLabel = switch ($evaluation.PathAStatus) {
            'Pass'     { 'Pass' }
            'NoAccess' { '⚠️ No access' }
            default    { 'Fail' }
        }
        $tableRows += "| $subscriptionName | $workspaceName | A (ARM data connector — Q3) | $pathAConnector | $pathADataTypes | $pathAStatusLabel |`n"

        # Path B row
        $pathBPackage     = if ($evaluation.PathBPackageName) { Get-SafeMarkdown -Text $evaluation.PathBPackageName } else { 'absent' }
        $pathBStatusLabel = switch ($evaluation.PathBStatus) {
            'Pass'     { 'Pass' }
            'NoAccess' { '⚠️ No access' }
            default    { 'Fail' }
        }
        $tableRows += "| $subscriptionName | $workspaceName | B (Content Pack — Q4) | $pathBPackage | n/a | $pathBStatusLabel |`n"
    }

    $partialWarning = ''
    if ($permissionErrors.Count -gt 0) {
        $partialWarning = "`n`n> ⚠️ **$($permissionErrors.Count) workspace(s) could not be fully checked** due to insufficient permissions on the data connectors or content packages endpoint. Ensure Microsoft Sentinel Reader is granted on those workspaces and re-run the assessment."
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
    if (-not $passed -and $permissionErrors.Count -gt 0) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
