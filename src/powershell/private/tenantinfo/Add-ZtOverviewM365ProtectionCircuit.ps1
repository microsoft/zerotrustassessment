function Add-ZtOverviewM365ProtectionCircuit {
    [CmdletBinding()]
    param(
        $TestResults = $script:__ZtSession.TestResultDetail.Value.Values
    )

    $tenantInfoName = 'OverviewM365ProtectionCircuit'
    $acquisitionResult = @($TestResults | Where-Object { $_.TestId -eq '25376' } | Select-Object -First 1)
    $enforcementResult = @($TestResults | Where-Object { $_.TestId -eq '25379' } | Select-Object -First 1)
    if (-not $acquisitionResult -or -not $enforcementResult) {
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $acquisitionStatus = $acquisitionResult.TestStatus
    $enforcementStatus = $enforcementResult.TestStatus
    $acquisitionData = $acquisitionResult.TestData
    $totalDeviceCount = if ($acquisitionData) { [int]$acquisitionData.totalDeviceCount } else { 0 }
    $activeDeviceCount = if ($acquisitionData) { [int]$acquisitionData.activeDeviceCount } else { 0 }
    $profileEnabled = if ($acquisitionData) { [bool]$acquisitionData.profileEnabled } else { $false }
    $countsAvailable = $totalDeviceCount -gt 0 -and $activeDeviceCount -ge 0 -and $activeDeviceCount -le $totalDeviceCount
    $total = if ($countsAvailable) { $totalDeviceCount } else { 100 }
    $acquired = if ($countsAvailable) {
        if ($profileEnabled) { $activeDeviceCount } else { 0 }
    }
    elseif ($acquisitionStatus -eq 'Passed') { 100 } else { 0 }

    $nodes = @()
    if ($acquisitionStatus -eq 'Passed') {
        $nodes += @{ source = 'Total M365 traffic'; target = 'Unprotected - not acquired (25376)'; value = $total - $acquired }
        $nodes += @{ source = 'Total M365 traffic'; target = 'Acquired via Global Secure Access (25376)'; value = $acquired }
        if ($enforcementStatus -eq 'Passed') {
            $nodes += @{ source = 'Acquired via Global Secure Access (25376)'; target = 'Enforced - compliant network (25379)'; value = $acquired }
        }
        elseif ($enforcementStatus -eq 'Investigate') {
            $nodes += @{ source = 'Acquired via Global Secure Access (25376)'; target = 'Acquired, enforcement needs review (25379)'; value = $acquired }
        }
        elseif ($enforcementStatus -eq 'Skipped') {
            $nodes += @{ source = 'Acquired via Global Secure Access (25376)'; target = 'Enforcement not applicable (25379)'; value = $acquired }
        }
        else {
            $nodes += @{ source = 'Acquired via Global Secure Access (25376)'; target = 'Acquired but not enforced (25379)'; value = $acquired }
        }
    }
    elseif ($acquisitionStatus -eq 'Investigate') {
        $nodes += @{ source = 'Total M365 traffic'; target = 'Acquisition needs review (25376)'; value = $total }
    }
    elseif ($acquisitionStatus -eq 'Skipped') {
        $nodes += @{ source = 'Total M365 traffic'; target = 'Acquisition not applicable (25376)'; value = $total }
    }
    else {
        $nodes += @{ source = 'Total M365 traffic'; target = 'Unprotected - not acquired (25376)'; value = $total }
    }

    $description = if ($countsAvailable) {
        "Microsoft 365 traffic acquisition is sized from $total observed devices; compliant network enforcement is a tenant-wide gate over the acquired band."
    }
    else {
        'Device counts are unavailable, so this flow uses a normalized all-or-nothing width of 100; proportional widths are unavailable.'
    }
    Add-ZtTenantInfo -Name $tenantInfoName -Value @{
        description        = $description
        nodes              = $nodes
        totalDevices       = $total
        countsAvailable    = $countsAvailable
        acquisitionStatus  = $acquisitionStatus
        enforcementStatus  = $enforcementStatus
    }
}
