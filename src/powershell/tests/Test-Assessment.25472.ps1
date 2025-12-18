function Test-Assessment-25372 {
    [ZtTest(
        Category = 'Network',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Intune','Microsoft Entra Internet Access','Microsoft Entra Private Access','Microsoft Entra ID P1'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce','External'),
        TestId = 25372,
        Title = 'Global Secure Access (GSA) client is deployed on all managed endpoints',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start GSA Client Deployment Coverage Evaluation' -Tag Test -Level VeryVerbose

    <#if (-not (Get-ZtLicense Intune)) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }#>

    $activity = 'Checking GSA client deployment coverage vs Intune managed devices'
    Write-ZtProgress -Activity $activity -Status 'Collecting data'

    # Evaluation window (last 7 days), pivot at 24 hours ago
    $endDateTime = [DateTime]::UtcNow
    $startDateTime = $endDateTime.AddDays(-7)
    $activityPivotDateTime = $endDateTime.AddHours(-24)

    $startStr = $startDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
    $endStr   = $endDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
    $pivotStr = $activityPivotDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')

    # Q1: GSA device usage summary (beta)  (fixed: variable expansion)
    $q1Uri = "networkAccess/reports/getDeviceUsageSummary(startDateTime=$startStr,endDateTime=$endStr,activityPivotDateTime=$pivotStr)"
    $gsaSummary = Invoke-ZtGraphRequest -RelativeUri $q1Uri -ApiVersion beta -DisablePaging

    $gsaTotal    = [int]$gsaSummary.totalDeviceCount
    $gsaActive   = [int]$gsaSummary.activeDeviceCount
    $gsaInactive = [int]$gsaSummary.inactiveDeviceCount

    # Q2: Intune managed devices count (v1.0) (fixed: escape $count)
    $managedCountRaw = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDevices/`$count' -ApiVersion v1.0 -DisablePaging
    $managedCount = [int]$managedCountRaw

    # Q3 (optional): managed devices OS breakdown
    Write-ZtProgress -Activity $activity -Status 'Getting managed device OS breakdown (optional)'
    $managedDevices = Invoke-ZtGraphRequest `
        -RelativeUri 'deviceManagement/managedDevices?$select=id,deviceName,operatingSystem,osVersion,managementAgent,complianceState&$top=999' `
        -ApiVersion v1.0

    $deploymentPct = 0.0
    if ($managedCount -gt 0) {
        $deploymentPct = [math]::Round((($gsaTotal / $managedCount) * 100), 1)
    }

    $gap = [math]::Max(($managedCount - $gsaTotal), 0)

    $inactivePct = 0.0
    if ($gsaTotal -gt 0) {
        $inactivePct = [math]::Round((($gsaInactive / $gsaTotal) * 100), 1)
    }

    # Pass/Warning/Fail logic (fixed: string interpolation)
    $passed = $false
    $testResultMarkdown = ''

    if ($managedCount -eq 0) {
        $passed = $true
        $testResultMarkdown = "No Intune-managed devices were found in the tenant, so GSA client deployment coverage cannot be evaluated.nn%TestResult%"
    }
    elseif ($gsaTotal -eq 0) {
        $passed = $false
        $testResultMarkdown = "### ❌ No devices have connected to Global Secure Access in the last 7 daysnThis strongly indicates the GSA client is not deployed or not in use on managed endpoints.`nn%TestResult%"
    }
    elseif ($deploymentPct -lt 70) {
        $passed = $false
        $testResultMarkdown = "### ❌ GSA client deployment coverage is low ($deploymentPct%)nA significant portion of managed endpoints are not protected by Security Service Edge controls.`nn%TestResult%"
    }
    elseif ($deploymentPct -lt 90) {
        $passed = $false
        $testResultMarkdown = "### ⚠️ GSA client deployment coverage is partial ($deploymentPct%)nSome managed endpoints may be operating outside Security Service Edge controls.`nn%TestResult%"
    }
    elseif ($inactivePct -ge 10) {
        $passed = $false
        $testResultMarkdown = "### ⚠️ GSA client coverage is high ($deploymentPct%) but inactive device count is elevated ($inactivePct%)nThis may indicate client health or connectivity issues.`nn%TestResult%"
    }
    else {
        $passed = $true
        $testResultMarkdown = "### ✅ GSA client deployment coverage meets the target ($deploymentPct%)nMost managed endpoints are connecting to Global Secure Access.`nn%TestResult%"
    }

    # Details section (fixed: newlines + variable expansion)
    $mdInfo  = "n## Coverage Summaryn"
    $mdInfo += "| Metric | Value |`n"
    $mdInfo += "| :--- | :--- |`n"
    $mdInfo += "| Evaluation Period (UTC) | $startStr → $endStr |`n"
    $mdInfo += "| Activity Pivot (UTC) | $pivotStr |`n"
    $mdInfo += "| Global Secure Access Devices (Total) | $gsaTotal |`n"
    $mdInfo += "| Global Secure Access Devices (Active) | $gsaActive |`n"
    $mdInfo += "| Global Secure Access Devices (Inactive) | $gsaInactive ($inactivePct%) |`n"
    $mdInfo += "| Intune Managed Devices (Total) | $managedCount |`n"
    $mdInfo += "| Deployment Percentage | $deploymentPct% |`n"
    $mdInfo += "| Gap (Managed - GSA) | $gap |`n"
    $mdInfo += "| Portal Hint | Global Secure Access → Dashboard → Device Status |`n"

    if ($managedDevices -and $managedDevices.Count -gt 0) {
        $osGroups = $managedDevices | Group-Object operatingSystem | Sort-Object Count -Descending
        $mdInfo += "`n## Managed Device Breakdown (by OS)`n"
        $mdInfo += "| Operating System | Count |`n"
        $mdInfo += "| :--- | ---: |`n"
        foreach ($g in $osGroups) {
            $osName = if ([string]::IsNullOrWhiteSpace($g.Name)) { 'Unknown' } else { (Get-SafeMarkdown -Text $g.Name) }
            $mdInfo += "| $osName | $($g.Count) |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    Add-ZtTestResultDetail @{
        TestId = '25372'
        Title  = 'Global Secure Access (GSA) client is deployed on all managed endpoints'
        Status = $passed
        Result = $testResultMarkdown
    }
}
