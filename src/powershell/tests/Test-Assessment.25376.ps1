<#
.SYNOPSIS
    Checks if Microsoft 365 traffic is actively flowing through Global Secure Access.

.DESCRIPTION
    This test validates that the Microsoft 365 traffic forwarding profile is enabled and
    that Microsoft 365 traffic is actively being tunneled through Global Secure Access.

.NOTES
    Test ID: 25376
    Category: Traffic Acquisition
    Required API: networkAccess/reports (beta)
#>

function Test-Assessment-25376 {
    [ZtTest(
        Category = 'Traffic Acquisition',
        ImplementationCost = 'Medium',
        MinimumLicense = ('P1','E3'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25376,
        Title = 'Microsoft 365 traffic is actively flowing through Global Secure Access',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Microsoft 365 traffic through Global Secure Access'
    Write-ZtProgress -Activity $activity -Status 'Verifying M365 traffic forwarding profile'

    # Define evaluation time window (last 7 days)
    $endDateTime = (Get-Date).ToUniversalTime()
    $startDateTime = $endDateTime.AddDays(-7)
    $startDateTimeStr = $startDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
    $endDateTimeStr = $endDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')

    # Query 3: Verify Microsoft 365 traffic forwarding profile is enabled
    $m365Profile = $null
    try {
        $m365Profile = Invoke-ZtGraphRequest -RelativeUri "networkAccess/forwardingProfiles" -Filter "trafficForwardingType eq 'm365'" -ApiVersion beta
    } catch {
        Write-PSFMessage "Unable to retrieve M365 forwarding profile: $_" -Level Warning
    }

    # Query 1 & 2: Execute in parallel conceptually, but sequentially due to tool constraints
    Write-ZtProgress -Activity $activity -Status 'Retrieving traffic statistics'

    # Query 1: Get transaction summaries
    $transactionSummary = $null
    try {
        $transactionSummary = Invoke-ZtGraphRequest -RelativeUri "networkAccess/reports/transactionSummaries(startDateTime=$startDateTimeStr,endDateTime=$endDateTimeStr)" -ApiVersion beta
    } catch {
        Write-PSFMessage "Unable to retrieve transaction summaries: $_" -Level Warning
    }

    # Query 2: Get device usage summary
    $deviceUsage = $null
    try {
        $deviceUsage = Invoke-ZtGraphRequest -RelativeUri "networkAccess/reports/getDeviceUsageSummary(startDateTime=$startDateTimeStr,endDateTime=$endDateTimeStr)" -ApiVersion beta
    } catch {
        Write-PSFMessage "Unable to retrieve device usage summary: $_" -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $true
    $warnings = [System.Collections.Generic.List[string]]::new()

    # Extract M365 profile state
    $profileEnabled = $false
    $profileState = 'Not found'
    $profileName = 'N/A'
    if ($m365Profile -and $m365Profile.Count -gt 0) {
        $profile = $m365Profile | Select-Object -First 1
        $profileName = $profile.name
        $profileState = $profile.state
        $profileEnabled = ($profile.state -eq 'enabled')
    }

    # Extract M365 transaction data
    $m365TotalCount = 0
    $m365BlockedCount = 0
    if ($transactionSummary) {
        $m365Entry = $transactionSummary | Where-Object { $_.trafficType -eq 'microsoft365' } | Select-Object -First 1
        if ($m365Entry) {
            $m365TotalCount = [int]$m365Entry.totalCount
            $m365BlockedCount = [int]$m365Entry.blockedCount
        }
    }

    # Extract device usage data
    $totalDeviceCount = 0
    $activeDeviceCount = 0
    $inactiveDeviceCount = 0
    if ($deviceUsage) {
        $totalDeviceCount = [int]$deviceUsage.totalDeviceCount
        $activeDeviceCount = [int]$deviceUsage.activeDeviceCount
        $inactiveDeviceCount = [int]$deviceUsage.inactiveDeviceCount
    }

    # Evaluation logic
    if (-not $profileEnabled) {
        $passed = $false
    }

    if ($m365TotalCount -eq 0) {
        $passed = $false
    }

    # Warning conditions
    if ($profileEnabled -and $m365TotalCount -gt 0 -and $m365TotalCount -lt 1000) {
        $warnings.Add("Low Microsoft 365 transaction count ($m365TotalCount) may indicate deployment issues")
    }

    if ($activeDeviceCount -eq 0 -and $totalDeviceCount -gt 0) {
        $warnings.Add("No active devices detected despite $totalDeviceCount total devices registered")
    }

    if ($activeDeviceCount -lt 10 -and $profileEnabled) {
        $warnings.Add("Low active device count ($activeDeviceCount) - verify client deployment across endpoints")
    }

    # Generate result message
    if ($passed -and $warnings.Count -eq 0) {
        $testResultMarkdown = "✅ Microsoft 365 traffic forwarding is enabled and a healthy volume of Microsoft 365 traffic is flowing through Global Secure Access.`n`n%TestResult%"
    }
    elseif ($passed -and $warnings.Count -gt 0) {
        $testResultMarkdown = "⚠️ Microsoft 365 traffic is flowing through Global Secure Access, but some concerns were detected.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Microsoft 365 traffic forwarding is disabled or no Microsoft 365 traffic is being tunneled through Global Secure Access.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = [System.Text.StringBuilder]::new()

    # Summary Section
    [void]$mdInfo.AppendLine("`n## Summary`n")
    [void]$mdInfo.AppendLine("| Metric | Value |")
    [void]$mdInfo.AppendLine("| :--- | ---: |")
    [void]$mdInfo.AppendLine("| Profile Enabled | $(if ($profileEnabled) { '✅ Yes' } else { '❌ No' }) |")
    [void]$mdInfo.AppendLine("| M365 Transactions (7 days) | $($m365TotalCount.ToString('N0')) |")
    [void]$mdInfo.AppendLine("| M365 Blocked Transactions | $($m365BlockedCount.ToString('N0')) |")
    [void]$mdInfo.AppendLine("| Active Devices | $activeDeviceCount |")
    [void]$mdInfo.AppendLine("| Total Devices | $totalDeviceCount |`n")

    # Traffic Forwarding Profile Section
    [void]$mdInfo.AppendLine("`n## Traffic Forwarding Profile`n")
    [void]$mdInfo.AppendLine("| Property | Value |")
    [void]$mdInfo.AppendLine("| :--- | :--- |")
    [void]$mdInfo.AppendLine("| Profile Name | $(Get-SafeMarkdown -Text $profileName) |")
    [void]$mdInfo.AppendLine("| State | $profileState |")
    [void]$mdInfo.AppendLine("| Traffic Type | m365 |`n")

    # Transaction Summary Section
    [void]$mdInfo.AppendLine("`n## Transaction Summary`n")
    [void]$mdInfo.AppendLine("| Traffic Type | Total Count | Blocked Count |")
    [void]$mdInfo.AppendLine("| :--- | ---: | ---: |")
    if ($transactionSummary) {
        foreach ($entry in $transactionSummary | Sort-Object trafficType) {
            $total = [int]$entry.totalCount
            $blocked = [int]$entry.blockedCount
            [void]$mdInfo.AppendLine("| $($entry.trafficType) | $($total.ToString('N0')) | $($blocked.ToString('N0')) |")
        }
    } else {
        [void]$mdInfo.AppendLine("| - | No data available | - |")
    }
    [void]$mdInfo.AppendLine()
    [void]$mdInfo.AppendLine("*Evaluation Period: $($startDateTime.ToString('yyyy-MM-dd')) to $($endDateTime.ToString('yyyy-MM-dd'))*`n")

    # Device Usage Section
    [void]$mdInfo.AppendLine("`n## Device Usage`n")
    [void]$mdInfo.AppendLine("| Metric | Count |")
    [void]$mdInfo.AppendLine("| :--- | ---: |")
    [void]$mdInfo.AppendLine("| Total Devices | $totalDeviceCount |")
    [void]$mdInfo.AppendLine("| Active Devices | $activeDeviceCount |")
    [void]$mdInfo.AppendLine("| Inactive Devices | $inactiveDeviceCount |`n")

    # Warnings Section
    if ($warnings.Count -gt 0) {
        [void]$mdInfo.AppendLine("`n## ⚠️ Warnings`n")
        foreach ($warning in $warnings) {
            [void]$mdInfo.AppendLine("- $warning")
        }
        [void]$mdInfo.AppendLine()
    }

    # Portal Link
    $portalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/TrafficForwardingBlade"
    [void]$mdInfo.AppendLine("`n[$(Get-SafeMarkdown -Text 'View in Entra Portal: Traffic forwarding')]($portalLink)")

    # Replace placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo.ToString()
    #endregion Report Generation

    $params = @{
        TestId = '25376'
        Title  = 'Microsoft 365 traffic is actively flowing through Global Secure Access'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
