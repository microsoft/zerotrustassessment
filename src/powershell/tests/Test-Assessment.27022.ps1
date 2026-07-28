<#
.SYNOPSIS
    Confirms Microsoft 365 traffic is acquired by Global Secure Access and enforced by compliant network Conditional Access.

.DESCRIPTION
    Aggregates the completed results of tests 25376 and 25379. This composite test does not issue independent Graph requests.
#>

function Test-Assessment-27022 {
    [ZtTest(
        Category = 'Global Secure Access',
        CompatibleLicense = ('AAD_PREMIUM', 'Entra_Premium_Internet_Access'),
        ImplementationCost = 'Medium',
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27022,
        DependsOn = (25376, 25379),
        Title = 'Microsoft 365 traffic is protected end-to-end through Global Secure Access acquisition and compliant network enforcement',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    Write-ZtProgress -Activity 'Checking Microsoft 365 protection circuit' -Status 'Collecting acquisition and enforcement results'

    $acquisitionResult = Get-ZtTestResultDetail -TestId '25376'
    $enforcementResult = Get-ZtTestResultDetail -TestId '25379'
    #endregion Data Collection

    #region Assessment Logic
    $acquisitionStatus = if ($acquisitionResult) { $acquisitionResult.TestStatus } else { 'Unavailable' }
    $enforcementStatus = if ($enforcementResult) { $enforcementResult.TestStatus } else { 'Unavailable' }
    $failedStages = @()
    if ($acquisitionStatus -eq 'Failed') { $failedStages += 'Acquisition (25376)' }
    if ($enforcementStatus -eq 'Failed') { $failedStages += 'Enforcement (25379)' }
    $needsInvestigation = $acquisitionStatus -in @('Investigate', 'Skipped', 'Unavailable', 'Error', 'Planned') -or $enforcementStatus -in @('Investigate', 'Skipped', 'Unavailable', 'Error', 'Planned')

    if ($failedStages.Count -gt 0) {
        $passed = $false
        $customStatus = $null
        if ($acquisitionStatus -eq 'Failed' -and $enforcementStatus -eq 'Failed') {
            $testResultMarkdown = "❌ Microsoft 365 traffic is neither acquired by Global Secure Access nor gated by compliant network enforcement.`n`n%TestResult%"
        }
        elseif ($acquisitionStatus -eq 'Failed') {
            $testResultMarkdown = "❌ Microsoft 365 traffic is not tunneled through Global Secure Access, so it is invisible to security controls. Compliant network enforcement cannot function because the required signal is never generated.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ Microsoft 365 traffic is tunneled through Global Secure Access but access is not gated on the compliant network, so sessions can originate from uncontrolled networks.`n`n%TestResult%"
        }
    }
    elseif ($needsInvestigation) {
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ The Microsoft 365 protection circuit could not be conclusively evaluated because one or more required child checks need review or are not applicable.`n`n%TestResult%"
    }
    else {
        $passed = $true
        $customStatus = $null
        $testResultMarkdown = "✅ Microsoft 365 traffic is acquired by Global Secure Access and Conditional Access requires the compliant network signal before granting access.`n`n%TestResult%"
    }

    $acquisitionData = $acquisitionResult.TestData
    $totalDeviceCount = if ($acquisitionData) { [int]$acquisitionData.totalDeviceCount } else { 0 }
    $activeDeviceCount = if ($acquisitionData) { [int]$acquisitionData.activeDeviceCount } else { 0 }
    $profileEnabled = if ($acquisitionData) { [bool]$acquisitionData.profileEnabled } else { $false }
    $hasUsableCounts = $totalDeviceCount -gt 0 -and $activeDeviceCount -ge 0 -and $activeDeviceCount -le $totalDeviceCount
    #endregion Assessment Logic

    #region Report Generation
    $gsaPortalLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/ForwardingProfile.ReactView'
    $caPortalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'

    $acquisitionDisplay = switch ($acquisitionStatus) {
        'Passed'      { '✅ Passed' }
        'Failed'      { '❌ Failed' }
        'Investigate' { '⚠️ Investigate' }
        'Skipped'     { '⬜ Not applicable' }
        default       { "⬜ $acquisitionStatus" }
    }
    $enforcementDisplay = switch ($enforcementStatus) {
        'Passed'      { '✅ Passed' }
        'Failed'      { '❌ Failed' }
        'Investigate' { '⚠️ Investigate' }
        'Skipped'     { '⬜ Not applicable' }
        default       { "⬜ $enforcementStatus" }
    }

    $circuitDisplay = if ($passed) { '✅ Closed' } elseif ($customStatus -eq 'Investigate') { '⚠️ Investigate' } else { '❌ Open' }
    $measurementDisplay = if ($hasUsableCounts) { 'Device counts available' } else { 'Unavailable - normalized Sankey flow used' }

    # Build device usage section only when 25376 produced usable acquisition counts.
    $deviceUsageSection = ''
    if ($hasUsableCounts) {
        $acquiredPct = if ($totalDeviceCount -gt 0) { [Math]::Round($activeDeviceCount / $totalDeviceCount * 100) } else { 0 }
        $deviceUsageTemplate = @'

## Device Usage

| Metric | Count |
| :----- | ----: |
| Total devices | {0} |
| Active (acquired) | {1} |
| Inactive (not acquired) | {2} |
| Acquired | {3}% |
'@
        $deviceUsageSection = $deviceUsageTemplate -f $totalDeviceCount, $activeDeviceCount, ($totalDeviceCount - $activeDeviceCount), $acquiredPct
    }

    $trafficForwardingLinkText = Get-SafeMarkdown -Text 'View in Entra Portal: Traffic forwarding'
    $conditionalAccessLinkText = Get-SafeMarkdown -Text 'View in Entra Portal: Conditional Access policies'
    $formatTemplate = @'

## Summary

| Metric | Value |
| :--- | :--- |
| Protection circuit | {0} |
| Acquisition (25376) | {1} |
| Enforcement (25379) | {2} |
| Acquisition measurements | {3} |

## Protection Circuit

| Stage | Required check | Result |
| :---- | :------------- | :----- |
| Stage 1 - Acquisition | [Microsoft 365 traffic flows through Global Secure Access]({4}) | {1} |
| Stage 2 - Enforcement | [Conditional Access uses compliant network controls]({5}) | {2} |

Traffic is protected end-to-end only when it is both acquired by Global Secure Access and enforced by the compliant network policy. When acquisition fails, enforcement cannot operate because no traffic carries the compliant network signal.
{6}

[{7}]({4})

[{8}]({5})
'@
    $mdInfo = $formatTemplate -f $circuitDisplay, $acquisitionDisplay, $enforcementDisplay, $measurementDisplay, $gsaPortalLink, $caPortalLink, $deviceUsageSection, $trafficForwardingLinkText, $conditionalAccessLinkText

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '27022'
        Status = $passed
        Result = $testResultMarkdown
        Data = @{
            acquisitionStatus = $acquisitionStatus
            enforcementStatus = $enforcementStatus
            totalDeviceCount  = $totalDeviceCount
            activeDeviceCount = $activeDeviceCount
            profileEnabled    = $profileEnabled
            countsAvailable   = $hasUsableCounts
        }
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
