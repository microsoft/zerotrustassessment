<#
.SYNOPSIS
    Validates that Global Secure Access (GSA) client is deployed on all managed endpoints.

.DESCRIPTION
    This test compares the count of devices connected to Global Secure Access with the total
    count of Intune-managed devices to determine deployment coverage. Endpoints without the
    GSA client operate outside the organization's Security Service Edge controls.

.NOTES
    Test ID: 25372
    Category: Global Secure Access
    Required API: networkAccess/reports/getDeviceUsageSummary (beta), deviceManagement/managedDevices (beta)
#>

function Test-Assessment-25372 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('AAD_PREMIUM', 'Entra_Premium_Internet_Access', 'Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25372,
        Title = 'Global Secure Access (GSA) client is deployed on all managed endpoints',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Global Secure Access client deployment'
    Write-ZtProgress -Activity $activity -Status 'Getting GSA device usage summary'

    # Set evaluation time window (last 7 days)
    $endDateTime = (Get-Date).ToUniversalTime()
    $startDateTime = $endDateTime.AddDays(-7)
    $activityPivotDateTime = $endDateTime.AddDays(-1)

    $startDateTimeStr = $startDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
    $endDateTimeStr = $endDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
    $activityPivotDateTimeStr = $activityPivotDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')

    # Query Q1: Retrieve Global Secure Access device usage summary
    $gsaDeviceSummary = $null
    $gsaQuerySuccess = $true
    try {
        $gsaDeviceSummary = Invoke-ZtGraphRequest `
            -RelativeUri "networkAccess/reports/getDeviceUsageSummary(startDateTime=$startDateTimeStr,endDateTime=$endDateTimeStr,activityPivotDateTime=$activityPivotDateTimeStr)" `
            -ApiVersion beta
    }
    catch {
        Write-PSFMessage "Failed to get GSA device usage summary: $_" -Tag Test -Level Warning
        $gsaQuerySuccess = $false
    }

    Write-ZtProgress -Activity $activity -Status 'Getting Intune managed device count'

    # Query Q2: Count Intune-managed devices
    $intuneDeviceCount = $null
    $intuneQuerySuccess = $true
    try {
        # Use -DisablePaging to get raw response with @odata.count
        $intuneResponse = Invoke-ZtGraphRequest `
            -RelativeUri 'deviceManagement/managedDevices' `
            -QueryParameters @{'$top' = '1'; '$count' = 'true'} `
            -ApiVersion beta `
            -DisablePaging
        $intuneDeviceCount = $intuneResponse.'@odata.count'
    }
    catch {
        Write-PSFMessage "Failed to get Intune device count: $_" -Tag Test -Level Warning
        $intuneQuerySuccess = $false
    }

    # Extract values
    $totalGsaDevices = if ($gsaDeviceSummary) { $gsaDeviceSummary.totalDeviceCount } else { 0 }
    $activeGsaDevices = if ($gsaDeviceSummary) { $gsaDeviceSummary.activeDeviceCount } else { 0 }
    $inactiveGsaDevices = if ($gsaDeviceSummary) { $gsaDeviceSummary.inactiveDeviceCount } else { 0 }
    $totalManagedDevices = if ($intuneDeviceCount) { [int]$intuneDeviceCount } else { 0 }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    # Calculate deployment percentage
    $deploymentPercentage = 0
    $gap = 0
    if ($totalManagedDevices -gt 0) {
        $deploymentPercentage = [math]::Round(($totalGsaDevices / $totalManagedDevices) * 100, 1)
        $gap = $totalManagedDevices - $totalGsaDevices
    }

    # Investigate: Unable to retrieve device data
    if (-not $gsaQuerySuccess -or -not $intuneQuerySuccess) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to retrieve device data. Manual verification required.`n`n%TestResult%"
    }
    # Investigate: No managed devices found (can't calculate percentage)
    elseif ($totalManagedDevices -eq 0) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ No Intune-managed devices found. Verify Intune enrollment status.`n`n%TestResult%"
    }
    # Pass: Deployment percentage >= 90%
    elseif ($deploymentPercentage -ge 90) {
        $passed = $true
        $testResultMarkdown = "✅ Global Secure Access client is deployed to the majority of managed endpoints.`n`n%TestResult%"
    }
    # Fail: Deployment percentage < 90%
    else {
        $testResultMarkdown = "❌ Global Secure Access client deployment is significantly below the managed device count; a substantial portion of managed endpoints are not protected by Security Service Edge controls.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Summary section with portal link in header
    $mdInfo += "`n## [Deployment Summary](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/AdminDashboard.ReactView)`n`n"

    $mdInfo += "| Metric | Value |`n"
    $mdInfo += "| :----- | ----: |`n"
    $mdInfo += "| Total GSA Devices | $totalGsaDevices |`n"
    $mdInfo += "| Active Devices | $activeGsaDevices |`n"
    $mdInfo += "| Inactive Devices | $inactiveGsaDevices |`n"
    $mdInfo += "| Total Managed Device Count | $totalManagedDevices |`n"
    $mdInfo += "| Deployment Percentage | $deploymentPercentage% |`n"
    $mdInfo += "| Gap | $gap |`n"
    $mdInfo += "| Evaluation Period | $($startDateTime.ToString('yyyy-MM-dd')) to $($endDateTime.ToString('yyyy-MM-dd')) |`n"

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25372'
        Title  = 'Global Secure Access (GSA) client is deployed on all managed endpoints'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
