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
        Title = 'OCR configuration for sensitive information detection',
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
        $ocrConfig = Get-OcrConfiguration -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve OCR configuration: $_" -Tag Test -Level Warning
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
    $enabledLocations = @()

    if ($ocrConfig) {
        $blockReason = $ocrConfig.OcrUsageBlockageReason
        $enabled   = $ocrConfig.Enabled -eq $true
        $exchange  = $ocrConfig.ExchangeLocation.Name -eq 'All'
        $sharePoint= $ocrConfig.SharePointLocation.Name -eq 'All'
        $oneDrive  = $ocrConfig.OneDriveLocation.Name -eq 'All'
        $teams     = $ocrConfig.TeamsLocation.Name -eq 'All'
        $endpoint  = $ocrConfig.EndpointDlpLocation.Name -eq 'All'
        $isBlocked = $ocrConfig.IsOcrUsageBlocked -eq $true

        if ($exchange) { $enabledLocations += 'Exchange' }
        if ($sharePoint) { $enabledLocations += 'SharePoint' }
        if ($oneDrive) { $enabledLocations += 'OneDrive' }
        if ($teams) { $enabledLocations += 'Teams' }
        if ($endpoint) { $enabledLocations += 'Endpoint' }
    }
    #endregion Data Collection

    #region Assessment Logic
    $customStatus = $null
    $passed = $false
    $testResultMarkdown = ''

    if ($errorMsg) {
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine OCR configuration status due to error: $errorMsg`n`n%TestResult%"
    }
    else {
        $hasConfig = $null -ne $ocrConfig
        $anyLocationEnabled = $enabledLocations.Count -gt 0
        $notBlocked = ($isBlocked -eq $false)

        if ($hasConfig -and $anyLocationEnabled -and $notBlocked) {
            $passed = $true
            $testResultMarkdown = "✅ OCR configuration is enabled at the tenant level for at least one workload, enabling policies to detect sensitive information within images.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ OCR is not configured or is disabled for all workloads.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if (-not $errorMsg) {
        # OCR Configuration Table
        $mdInfo += "### OCR configuration status`n`n"
        $mdInfo += "| Setting | Value |`n"
        $mdInfo += "| :--- | :--- |`n"
        $mdInfo += "| OCR enabled (Tenant-Level) | $enabled |`n"
        $mdInfo += "| Exchange | $exchange |`n"
        $mdInfo += "| SharePoint | $sharePoint |`n"
        $mdInfo += "| OneDrive | $oneDrive |`n"
        $mdInfo += "| Teams | $teams |`n"
        $mdInfo += "| Endpoint | $endpoint |`n"
        $mdInfo += "| OCR usage blocked | $isBlocked |`n"
        $mdInfo += "| Blockage Reason | $(if ($blockReason) { $blockReason } else { 'None' }) |`n"
        $mdInfo += "| Azure billing status | Manual verification required |`n"

        # Summary Section (matches MD output structure)
        $mdInfo += "`n### Summary`n`n"
        $mdInfo += "* **OCR configuration:** $(if ($ocrConfig) { 'Configured' } else { 'Not Configured' })`n"
        $mdInfo += "* **Active workloads:** $($enabledLocations.Count)`n"
        $mdInfo += "* **Status:** $(if ($passed) { 'Pass' } else { 'Fail' })`n"

        # Portal link
        $mdInfo += "`n**Portal access:**`n`n"
        $PortalPath = "Microsoft purview portal > Settings > Optical character recognition (OCR)`n"
        $SafePortalPath = Get-SafeMarkdown -Text $PortalPath
        $portalLink = "https://purview.microsoft.com/"
        $mdInfo += "[$safePortalPath]($portalLink)"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35023'
        Title = 'OCR configuration for sensitive information detection'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
