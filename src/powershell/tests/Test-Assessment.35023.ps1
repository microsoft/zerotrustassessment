<#
.SYNOPSIS
    Validates that OCR configuration for sensitive information detection is enabled.

.DESCRIPTION
    This test verifies whether Optical Character Recognition (OCR) is configured at the
    tenant level and enabled for at least one supported workload location. OCR enables
    Microsoft Purview policies to detect sensitive information contained within images.

.NOTES
    Test ID: 35023
    Category: Information Protection
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Security & Compliance PowerShell
#>

function Test-Assessment-35023 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35023,
        Title = 'OCR is enabled for sensitive information detection',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking OCR configuration'
    Write-ZtProgress -Activity $activity -Status 'Running Get-OcrConfiguration'

    $ocrConfig = $null
    $errorMsg = $null

    # Q1: Get OCR configuration
    try {
        $ocrConfig = Get-OcrConfiguration -ErrorAction Stop | Select-Object -Property Enabled, ExchangeLocation, SharePointLocation, OneDriveLocation, TeamsLocation, EndpointDlpLocation, IsOcrUsageBlocked, OcrUsageBlockageReason
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve OCR configuration: $_" -Tag Test -Level Error
    }
    # Q2/Q3: Extract detailed properties if configuration exists
    $enabled = $false
    $exchange = $false
    $sharePoint = $false
    $oneDrive = $false
    $teams = $false
    $endpoint = $false
    $isBlocked = $null
    $blockReason = $null
    $billingStatus = $null
    $enabledLocationsCount = 0

    if ($ocrConfig) {
        $blockReason = $ocrConfig.OcrUsageBlockageReason
        $enabled   = $ocrConfig.Enabled
        $exchange   = $ocrConfig.ExchangeLocation.Count -gt 0
        $sharePoint = $ocrConfig.SharePointLocation.Count -gt 0
        $oneDrive   = $ocrConfig.OneDriveLocation.Count -gt 0
        $teams      = $ocrConfig.TeamsLocation.Count -gt 0
        $endpoint   = $ocrConfig.EndpointDlpLocation.Count -gt 0
        $isBlocked  = $ocrConfig.IsOcrUsageBlocked

        if ($exchange)   { $enabledLocationsCount++ }
        if ($sharePoint) { $enabledLocationsCount++ }
        if ($oneDrive)   { $enabledLocationsCount++ }
        if ($teams)      { $enabledLocationsCount++ }
        if ($endpoint)   { $enabledLocationsCount++ }

        $billingStatus = if ($isBlocked) { 'Not Configured' } else { 'Configured' }
    }
    #endregion Data Collection

    #region Assessment Logic
    $customStatus = $null
    $passed = $false

    if ($errorMsg) {
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine OCR configuration status due to permissions issues or query failure. Error: $errorMsg`n`n%TestResult%"
    }
    else {
        $hasConfig = $null -ne $ocrConfig
        $anyLocationEnabled = $enabledLocationsCount -gt 0

        if (-not $hasConfig) {
            $passed = $false
            $testResultMarkdown = "❌ OCR is not configured.`n`n%TestResult%"
        }
        elseif (-not $enabled) {
            $passed = $false
            $testResultMarkdown = "❌ OCR is configured but disabled at the tenant level.`n`n%TestResult%"
        }
        elseif (-not $anyLocationEnabled) {
            $passed = $false
            $testResultMarkdown = "❌ OCR is enabled but not configured for any locations.`n`n%TestResult%"
        }
        elseif ($isBlocked) {
            $passed = $false
            $testResultMarkdown = "❌ OCR usage is blocked.`n`n%TestResult%"
        }
        else {
            $passed = $true
            $testResultMarkdown = "✅ OCR configuration is enabled at the tenant level for at least one workload, enabling policies to detect sensitive information within images.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if (-not $errorMsg) {
        $reportTitle = 'OCR configuration status'
        $portalLink = 'https://purview.microsoft.com/'
        $portalPathSafe = Get-SafeMarkdown -Text 'Microsoft Purview portal > Settings > Optical character recognition (OCR)'

        $configurationObjectStatus = if ($null -ne $ocrConfig) { 'Yes' } else { 'No' }

        $tableRows = "| Configuration object exists | $configurationObjectStatus |`n"
        $tableRows += "| OCR enabled (Tenant-level) | $enabled |`n"
        $tableRows += "| Exchange location enabled | $exchange |`n"
        $tableRows += "| SharePoint location enabled | $sharePoint |`n"
        $tableRows += "| OneDrive location enabled | $oneDrive |`n"
        $tableRows += "| Teams location enabled | $teams |`n"
        $tableRows += "| Endpoint location enabled | $endpoint |`n"
        $tableRows += "| OCR usage blocked | $(if ($null -eq $isBlocked) { 'N/A' } else { $isBlocked }) |`n"
        $tableRows += "| Blockage reason | $(if ($blockReason) { $blockReason } else { 'None' }) |`n"
        $tableRows += "| Azure billing status | $(if ($billingStatus) { $billingStatus } else { 'N/A' }) |`n"

        $ocrConfiguredStatus = if ($ocrConfig) { 'Configured' } else { 'Not Configured' }

        $formatTemplate = @'

### {0}

| Setting | Value |
| :------ | :---- |
{1}

**Summary:**

- OCR configuration: {2}
- Active locations: {3}

[{4}]({5})

'@
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows, $ocrConfiguredStatus, $enabledLocationsCount, $portalPathSafe, $portalLink
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35023'
        Title = 'OCR is enabled for sensitive information detection'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
