<#
.SYNOPSIS
    Builds the Microsoft 365 protection circuit flow (spec 27022).

.DESCRIPTION
    Aggregates the Global Secure Access acquisition check (25376) and the compliant network
    enforcement check (25379) into a Sankey flow.

    Each stage keeps its child roll-up verdict; the flow widths only quantify the gap and never
    replace that verdict. A child that was skipped, errored, timed out or was excluded from the
    run has no verdict, so its band is reported as unavailable instead of being folded into a
    confirmed failure.

    The acquisition axis is proportional and sized from 25376's device counts. Enforcement has no
    per-item population to subdivide, so it acts as a binary gate over the acquired band.
#>

function Add-ZtOverviewM365ProtectionCircuit {
    [CmdletBinding()]
    param()

    $tenantInfoName = 'OverviewM365ProtectionCircuit'

    $activity = 'Building Microsoft 365 protection circuit'
    Write-ZtProgress -Activity $activity -Status 'Processing'

    # Skipped, errored and never-run children have no verdict to roll up, so their stage is unavailable
    $stageStatuses = @{}
    foreach ($testId in '25376', '25379') {
        $stageStatuses[$testId] = switch (Get-ZtTestResultStatus -TestId $testId) {
            'Passed' { 'Passed' }
            'Failed' { 'Failed' }
            'Investigate' { 'Investigate' }
            default { 'Unavailable' }
        }
    }

    $acquisitionStatus = $stageStatuses['25376']
    $enforcementStatus = $stageStatuses['25379']

    if ($acquisitionStatus -eq 'Unavailable' -and $enforcementStatus -eq 'Unavailable') {
        Write-PSFMessage '🟦 Skipping: No Microsoft 365 protection circuit results available' -Tag Test -Level VeryVerbose
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $allStageStatuses = @($acquisitionStatus, $enforcementStatus)
    $degraded = $allStageStatuses -contains 'Unavailable'
    $overallStatus = if ($allStageStatuses -contains 'Failed') {
        'Failed'
    }
    # An unavailable stage cannot be asserted to pass, so the circuit stays short of Passed
    elseif ($allStageStatuses -contains 'Investigate' -or $degraded) {
        'Investigate'
    }
    else {
        'Passed'
    }

    $openStages = @()
    if ($acquisitionStatus -eq 'Failed') { $openStages += 'Acquisition (25376)' }
    if ($enforcementStatus -eq 'Failed') { $openStages += 'Enforcement (25379)' }

    $acquisition = Get-ZtTestData -Name 'M365TrafficAcquisition'
    $totalDeviceCount = [Math]::Max(0, ($acquisition.TotalDeviceCount -as [int]) ?? 0)
    $activeDeviceCount = [Math]::Max(0, ($acquisition.ActiveDeviceCount -as [int]) ?? 0)
    $profileEnabled = [bool]$acquisition.ProfileEnabled

    $countsAvailable = $totalDeviceCount -gt 0 -and $activeDeviceCount -le $totalDeviceCount
    # Without usable counts the flow falls back to a normalized all-or-nothing width
    $total = if ($countsAvailable) { $totalDeviceCount } else { 100 }
    $acquired = if ($acquisitionStatus -ne 'Passed') {
        0
    }
    elseif (-not $countsAvailable) {
        $total
    }
    elseif ($profileEnabled) {
        $activeDeviceCount
    }
    else {
        0
    }

    $nodes = @()
    if ($acquisitionStatus -eq 'Passed') {
        $nodes += @{ source = 'Total M365 traffic'; target = 'Unprotected - not acquired'; value = $total - $acquired }
        $nodes += @{ source = 'Total M365 traffic'; target = 'Acquired via Global Secure Access'; value = $acquired }
        switch ($enforcementStatus) {
            'Passed' { $nodes += @{ source = 'Acquired via Global Secure Access'; target = 'Enforced - compliant network'; value = $acquired } }
            'Failed' { $nodes += @{ source = 'Acquired via Global Secure Access'; target = 'Acquired but not enforced'; value = $acquired } }
            'Investigate' { $nodes += @{ source = 'Acquired via Global Secure Access'; target = 'Acquired, enforcement needs review'; value = $acquired } }
            'Unavailable' { $nodes += @{ source = 'Acquired via Global Secure Access'; target = 'Enforcement unavailable'; value = $acquired } }
        }
    }
    else {
        $acquisitionTarget = switch ($acquisitionStatus) {
            'Failed' { 'Unprotected - not acquired' }
            'Investigate' { 'Acquisition needs review' }
            default { 'Acquisition unavailable' }
        }
        $nodes += @{ source = 'Total M365 traffic'; target = $acquisitionTarget; value = $total }
    }
    $nodes = @($nodes | Where-Object value -gt 0)

    $description = if ($acquisitionStatus -eq 'Failed' -and $enforcementStatus -eq 'Failed') {
        'Both acquisition and enforcement stages are open: Microsoft 365 traffic is neither acquired nor gated by compliant network enforcement.'
    }
    elseif ($acquisitionStatus -eq 'Failed') {
        'The acquisition stage is open. Compliant network enforcement cannot function because Global Secure Access does not acquire the traffic or generate the required signal.'
    }
    elseif ($enforcementStatus -eq 'Failed' -and $acquisitionStatus -eq 'Passed') {
        'The enforcement stage is open. Traffic is acquired, but sessions can originate from uncontrolled networks because access is not gated on the compliant network.'
    }
    elseif ($enforcementStatus -eq 'Failed') {
        'The enforcement stage is open, and acquisition is unavailable. End-to-end protection cannot be confirmed.'
    }
    elseif ($overallStatus -eq 'Investigate') {
        $reviewStages = @()
        if ($acquisitionStatus -ne 'Passed') { $reviewStages += "Acquisition ($acquisitionStatus)" }
        if ($enforcementStatus -ne 'Passed') { $reviewStages += "Enforcement ($enforcementStatus)" }
        "The protection circuit needs review: $($reviewStages -join ', ')."
    }
    else {
        'The protection circuit is closed: Microsoft 365 traffic is acquired and gated by compliant network enforcement.'
    }
    $description += if ($countsAvailable) {
        " Acquisition is sized from $total observed devices."
    }
    else {
        ' Device counts are unavailable, so the flow uses a normalized all-or-nothing width of 100.'
    }

    Add-ZtTenantInfo -Name $tenantInfoName -Value @{
        description        = $description
        nodes              = $nodes
        gates              = @(
            @{ testId = '25376'; name = 'Acquisition'; status = $acquisitionStatus }
            @{ testId = '25379'; name = 'Enforcement'; status = $enforcementStatus }
        )
        overallStatus      = $overallStatus
        openStages         = $openStages
        degraded           = $degraded
        totalDevices       = $total
        countsAvailable    = $countsAvailable
        acquisitionStatus  = $acquisitionStatus
        enforcementStatus  = $enforcementStatus
    }
}
