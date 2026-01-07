<#
.SYNOPSIS
    Validates that internal RMS licensing is enabled in Exchange Online.

.DESCRIPTION
    This test checks if internal RMS licensing is enabled, which allows users and services within the
    organization to license protected content for internal distribution and sharing. Without internal
    RMS licensing enabled, users cannot share rights-protected content with internal recipients.

.NOTES
    Test ID: 35025
    Category: Data
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Exchange Online
#>

function Test-Assessment-35025 {
    [ZtTest(
        Category = 'Data',
        ImplementationCost = 'Low',
        MinimumLicense = 'Microsoft_365_E3',
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce', 'External'),
        TestId = 35025,
        Title = 'Internal RMS licensing is enabled',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage 'Start Internal RMS Licensing evaluation' -Tag Test -Level VeryVerbose

    $activity = 'Checking Internal RMS Licensing'
    Write-ZtProgress -Activity $activity -Status 'Getting IRM configuration'

    # Q1: Get IRM licensing configuration
    try {
        $irmConfig = Get-IRMConfiguration -ErrorAction Stop
    }
    catch {
        Write-PSFMessage "Failed to retrieve IRM configuration: $_" -Tag Test -Level Warning
        
        $params = @{
            TestId = '35025'
            Title  = 'Internal RMS licensing is enabled'
            Status = $false
            Result = "❌ Unable to retrieve IRM configuration. Ensure you are connected to Exchange Online with Connect-ExchangeOnline.`n`nError: $_"
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q2: Check if internal licensing is enabled
    $internalLicensingEnabled = $irmConfig.InternalLicensingEnabled

    # Q3: Get detailed licensing configuration
    $detailedConfig = $irmConfig | Select-Object -Property InternalLicensingEnabled, ExternalLicensingEnabled, AzureRMSLicensingEnabled
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    # Investigate: Cannot determine licensing status
    if ($null -eq $internalLicensingEnabled) {
        $passed = $true
        $customStatus = 'Investigate'
    }
    # Pass: Internal RMS licensing is enabled
    elseif ($internalLicensingEnabled -eq $true) {
        $passed = $true
    }
    # Fail: Internal RMS licensing is not enabled
    else {
        $passed = $false
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''

    if ($customStatus -eq 'Investigate') {
        $testResultMarkdown = "⚠️ Unable to determine internal RMS licensing status due to permissions issues or incomplete configuration data.`n`n"
        
        $params = @{
            TestId = '35025'
            Title  = 'Internal RMS licensing is enabled'
            Status = $passed
            Result = $testResultMarkdown
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Internal RMS licensing is enabled, allowing internal users to license and share protected content within the organization.`n`n"
    }
    else {
        $testResultMarkdown = "❌ Internal RMS licensing is not enabled or licensing endpoints are not configured.`n`n"
    }

    # Build detailed information
    $mdInfo = "## [Internal RMS Licensing Configuration](https://purview.microsoft.com/settings/encryption)`n`n"
    $mdInfo += "| Setting | Status |`n"
    $mdInfo += "| :------ | :----- |`n"
    $mdInfo += "| Internal Licensing Enabled | $(if ($detailedConfig.InternalLicensingEnabled -eq $true) { '✅ Enabled' } elseif ($detailedConfig.InternalLicensingEnabled -eq $false) { '❌ Disabled' } else { '⚠️ Unknown' }) |`n"
    $mdInfo += "| External Licensing Enabled | $(if ($detailedConfig.ExternalLicensingEnabled -eq $true) { '✅ Enabled' } elseif ($detailedConfig.ExternalLicensingEnabled -eq $false) { '❌ Disabled' } else { '⚠️ Unknown' }) |`n"
    $mdInfo += "| Azure RMS Licensing Enabled | $(if ($detailedConfig.AzureRMSLicensingEnabled -eq $true) { '✅ Enabled' } elseif ($detailedConfig.AzureRMSLicensingEnabled -eq $false) { '❌ Disabled' } else { '⚠️ Unknown' }) |`n"
    $mdInfo += "`n"

    # Additional configuration details
    if ($irmConfig) {
        $mdInfo += "## Additional Configuration Details`n`n"
        
        if ($irmConfig.LicensingLocation) {
            $mdInfo += "- **Licensing Location**: $(Get-SafeMarkdown $irmConfig.LicensingLocation)`n"
        }
        
        if ($irmConfig.RMSOnlineKeySharingLocation) {
            $mdInfo += "- **RMS Online Key Sharing Location**: $(Get-SafeMarkdown $irmConfig.RMSOnlineKeySharingLocation)`n"
        }
        
        $mdInfo += "`n"
    }

    $testResultMarkdown += $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35025'
        Title  = 'Internal RMS licensing is enabled'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
