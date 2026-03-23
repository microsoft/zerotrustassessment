<#
.SYNOPSIS
    Validates that Global Secure Access client is deployed on all managed endpoints.

.DESCRIPTION
    This test compares the count of devices connected to Global Secure Access with the total
    count of Entra ID managed devices (joined and hybrid joined) to determine deployment coverage.
    Endpoints without the GSA client operate outside the organization's Security Service Edge controls.

.NOTES
    Test ID: 25372
    Category: Global Secure Access
    Required API: networkAccess/reports/getDeviceUsageSummary (beta), devices (v1.0)
#>

function Test-Assessment-25372 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        Service = ('Graph'),
        MinimumLicense = ('AAD_PREMIUM', 'Entra_Premium_Internet_Access', 'Entra_Premium_Private_Access'),
        CompatibleLicense = ('Entra_Premium_Private_Access','Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25372,
        Title = 'Global Secure Access client is deployed on all managed endpoints',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

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

    $gsaCmdletFailed = $false
    $deviceQueryFailed = $false

    # Query Q1: Retrieve Global Secure Access device usage summary
    $gsaDeviceSummary = $null
    try {
        $gsaDeviceSummary = Invoke-ZtGraphRequest `
            -RelativeUri "networkAccess/reports/getDeviceUsageSummary(startDateTime=$startDateTimeStr,endDateTime=$endDateTimeStr,activityPivotDateTime=$activityPivotDateTimeStr)" `
            -ApiVersion beta `
            -ErrorAction Stop
    }
    catch {
        $gsaCmdletFailed = $true
        Write-PSFMessage "Failed to get GSA device usage summary: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Getting Entra ID joined and hybrid joined device count'

    # Query Q2: Count Entra ID joined and hybrid joined devices from database
    $entraDeviceCount = 0
    try {
        $sql = "SELECT COUNT(*) as DeviceCount FROM Device WHERE trustType == 'AzureAd' OR trustType == 'ServerAd'"
        $result = Invoke-DatabaseQuery -Database $Database -Sql $sql -ErrorAction Stop
        $entraDeviceCount = if ($result) { $result.DeviceCount } else { 0 }
    }
    catch {
        $deviceQueryFailed = $true
        Write-PSFMessage "Failed to query device count from database: $_" -Tag Test -Level Warning
    }

    # Extract values
    $totalGsaDevices = if ($gsaDeviceSummary) { $gsaDeviceSummary.totalDeviceCount } else { 0 }
    $activeGsaDevices = if ($gsaDeviceSummary) { $gsaDeviceSummary.activeDeviceCount } else { 0 }
    $inactiveGsaDevices = if ($gsaDeviceSummary) { $gsaDeviceSummary.inactiveDeviceCount } else { 0 }
    $totalManagedDevices = if ($entraDeviceCount) { $entraDeviceCount } else { 0 }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    # Handle any query failure - cannot determine deployment status
    if ($gsaCmdletFailed -or $deviceQueryFailed) {
        Write-PSFMessage "Unable to retrieve GSA deployment data due to query failure" -Tag Test -Level Warning
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine GSA client deployment coverage due to query failure, connection issues, or insufficient permissions.`n`n"
    }
    # Edge case: GSA devices > Entra ID devices (data inconsistency; GSA has more devices than Entra ID)
    # Per spec: Still calculate percentage and gap to help diagnose the issue
    elseif ($totalGsaDevices -gt $totalManagedDevices -and $totalManagedDevices -gt 0) {
        $customStatus = 'Investigate'
        $deploymentPercentage = [math]::Round(($totalGsaDevices / $totalManagedDevices) * 100, 1)
        $gap = [math]::Abs($totalManagedDevices - $totalGsaDevices)
        $testResultMarkdown = "⚠️ Global Secure Access device count exceeds the Entra ID managed device count. This indicates stale GSA device records, devices removed from Entra ID, or data synchronization issues between systems. Review both data sources to reconcile counts.`n`n%TestResult%"
    }
    # Edge case: No devices at all (both = 0) - Fail per spec
    elseif ($totalManagedDevices -eq 0 -and $totalGsaDevices -eq 0) {
        $deploymentPercentage = 0
        $gap = 0
        $testResultMarkdown = "❌ Global Secure Access client deployment is insufficient or cannot be verified. Either deployment coverage is below 70%, no devices are detected, or services may not be in scope for this environment.`n`n%TestResult%"
    }
    # Edge case: No managed devices but GSA devices exist (cannot calculate percentage; Entra ID baseline unavailable)
    elseif ($totalManagedDevices -eq 0 -and $totalGsaDevices -gt 0) {
        $customStatus = 'Investigate'
        $deploymentPercentage = 'N/A'
        $gap = 'N/A'
        $testResultMarkdown = "⚠️ Global Secure Access devices were detected but no Entra ID joined or Hybrid joined devices were found. Deployment coverage cannot be calculated. This may indicate device registration data is inaccessible or the required permissions are missing.`n`n%TestResult%"
    }
    # Normal scenario: Calculate deployment percentage and assess
    else {
        $deploymentPercentage = [math]::Round(($totalGsaDevices / $totalManagedDevices) * 100, 1)
        $gap = $totalManagedDevices - $totalGsaDevices

        # Pass: Deployment percentage >= 90%
        if ($deploymentPercentage -ge 90) {
            $passed = $true
            $testResultMarkdown = "✅ Global Secure Access client is deployed to the majority of managed endpoints.`n`n%TestResult%"
        }
        # Investigate: Deployment percentage between 70% and 90%
        elseif ($deploymentPercentage -ge 70) {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ Global Secure Access client deployment coverage is between 70% and 90% of managed devices. Review device platform breakdown for more details.`n`n%TestResult%"
        }
        # Fail: Deployment percentage < 70%
        else {
            $testResultMarkdown = "❌ Global Secure Access client deployment is insufficient or cannot be verified. Either deployment coverage is below 70%, no devices are detected, or services may not be in scope for this environment.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Only generate report table if we have data (not in error state)
    if (-not ($gsaCmdletFailed -or $deviceQueryFailed)) {
        $reportTitle = 'Deployment Summary'
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/AdminDashboard.ReactView'
        $deploymentPercentageDisplay = if ($deploymentPercentage -ne 'N/A') { "$deploymentPercentage%" } else { $deploymentPercentage }
        $evaluationPeriod = "$(Get-FormattedDate -DateString $startDateTime.ToString()) to $(Get-FormattedDate -DateString $endDateTime.ToString())"

        $formatTemplate = @'

## [{0}]({1})

| Metric | Value |
| :----- | ----: |
{2}

'@

        $tableRows = "| Total GSA devices | $totalGsaDevices |`n"
        $tableRows += "| Active devices | $activeGsaDevices |`n"
        $tableRows += "| Inactive devices | $inactiveGsaDevices |`n"
        $tableRows += "| Total managed device count | $totalManagedDevices |`n"
        $tableRows += "| Deployment percentage | $deploymentPercentageDisplay |`n"
        $tableRows += "| Gap | $gap |`n"
        $tableRows += "| Evaluation period | $evaluationPeriod |`n"

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }
    #endregion Report Generation

    $params = @{
        TestId = '25372'
        Title  = 'Global Secure Access client is deployed on all managed endpoints'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
