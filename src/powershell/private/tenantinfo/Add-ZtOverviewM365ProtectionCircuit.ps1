function Add-ZtOverviewM365ProtectionCircuit {
    [CmdletBinding()]
    param()

    $tenantInfoName = 'OverviewM365ProtectionCircuit'
    $circuitResult = Get-ZtTestResultDetail -TestId '27022'
    if (-not $circuitResult -or -not $circuitResult.TestData) {
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $data = $circuitResult.TestData
    $acquisitionStatus = $data.acquisitionStatus
    $enforcementStatus = $data.enforcementStatus
    $countsAvailable = [bool]$data.countsAvailable
    $total = if ($countsAvailable) { [int]$data.totalDeviceCount } else { 100 }
    $acquired = if ($countsAvailable) {
        if ($data.profileEnabled) { [int]$data.activeDeviceCount } else { 0 }
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
        'Device counts are unavailable, so this flow uses a normalized all-or-nothing width of 100.'
    }
    Add-ZtTenantInfo -Name $tenantInfoName -Value @{ description = $description; nodes = $nodes; totalDevices = $total }
}
