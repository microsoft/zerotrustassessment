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
        $enabled   = [bool]($ocrConfig.Enabled -eq $true)
        $exchange  = [bool]($ocrConfig.ExchangeLocation.Name -eq 'All')
        $sharePoint= [bool]($ocrConfig.SharePointLocation.Name -eq 'All')
        $oneDrive  = [bool]($ocrConfig.OneDriveLocation.Name -eq 'All')
        $teams     = [bool]($ocrConfig.TeamsLocation.Name -eq 'All')
        $endpoint  = [bool]($ocrConfig.EndpointDlpLocation.Name -eq 'All')
        $isBlocked = [bool]($ocrConfig.IsOcrUsageBlocked -eq $true)

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

    if ($errorMsg) {
        $passed = $false
        $customStatus = 'Investigate'
    }
    else {
        $hasConfig = $null -ne $ocrConfig
        $anyLocationEnabled = $enabledLocations.Count -gt 0
        $notBlocked = ($isBlocked -eq $false)

        if ($hasConfig -and $anyLocationEnabled -and $notBlocked) {
            $passed = $true
        }
        else {
            $passed = $false
        }
    }
    #endregion Assessment Logic

    #region Report Generation

    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to determine OCR configuration status due to error: $errorMsg"
    }
    else {
        $portalLink = "https://purview.microsoft.com/"
        # Status text
        if ($passed) {
            $statusIcon = "✅ Pass"
            $statusMessage = "OCR configuration is enabled at the tenant level for at least one workload, enabling policies to detect sensitive information within images."
        }
        else {
            $statusIcon = "❌ Fail"
            $statusMessage = "OCR is not configured or is disabled for all workloads."
        }

        # OCR Configuration Table
        $testResultMarkdown = "$statusIcon $statusMessage`n`n"

        $testResultMarkdown += "### OCR configuration status`n`n"
        $testResultMarkdown += "| Setting | Value |`n"
        $testResultMarkdown += "| :--- | :--- |`n"
        $testResultMarkdown += "| OCR enabled (Tenant-Level) | $enabled |`n"
        $testResultMarkdown += "| Exchange | $exchange |`n"
        $testResultMarkdown += "| SharePoint | $sharePoint |`n"
        $testResultMarkdown += "| OneDrive | $oneDrive |`n"
        $testResultMarkdown += "| Teams | $teams |`n"
        $testResultMarkdown += "| Endpoint | $endpoint |`n"
        $testResultMarkdown += "| OCR usage blocked | $isBlocked |`n"
        $testResultMarkdown += "| Blockage Reason | $(if ($blockReason) { $blockReason } else { 'None' }) |`n"
        $testResultMarkdown += "| Azure billing status | Manual verification required |`n"

        # Summary Section (matches MD output structure)
        $testResultMarkdown += "`n### Summary`n`n"
        $testResultMarkdown += "* **OCR configuration:** $(if ($ocrConfig) { 'Configured' } else { 'Not Configured' })`n"
        $testResultMarkdown += "* **Active workloads:** $($enabledLocations.Count)`n"
        $testResultMarkdown += "* **Status:** $(if ($passed) { 'Pass' } else { 'Fail' })`n"

        # Portal link
        $testResultMarkdown += "`n**Portal access:**`n`n"
        $testResultMarkdown += "[Microsoft purview portal > Settings > Optical character recognition (OCR)]($portalLink)`n"
    }
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
