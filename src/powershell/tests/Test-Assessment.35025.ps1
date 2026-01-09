<#
.SYNOPSIS
    Validates that internal RMS licensing is enabled in Exchange Online.

.DESCRIPTION
    This test checks if internal RMS licensing is enabled, which allows users and services within the
    organization to license protected content for internal distribution and sharing. Without internal
    RMS licensing enabled, users cannot share rights-protected content with internal recipients.

.NOTES
    Test ID: 35025
    Category: Rights Management Service (RMS)
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Exchange Online
#>

function Test-Assessment-35025 {
    [ZtTest(
        Category = 'Rights Management Service (RMS)',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35025,
        Title = 'Internal RMS Licensing Enabled',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Internal RMS Licensing Status'
    Write-ZtProgress -Activity $activity -Status 'Getting IRM configuration'

    # Get IRM licensing configuration
    $irmConfig = $null
    $errorMsg = $null

    try {
        $irmConfig = Get-IRMConfiguration -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve IRM configuration: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        # Investigate: Cannot query IRM configuration
        $passed = $false
        $customStatus = 'Investigate'
    }
    elseif ($null -eq $irmConfig.InternalLicensingEnabled) {
        # Investigate: Cannot determine licensing status
        $passed = $false
        $customStatus = 'Investigate'
    }
    elseif ($irmConfig.InternalLicensingEnabled -eq $true) {
        # Pass: Internal RMS licensing is enabled
        $passed = $true
    }
    else {
        # Fail: Internal RMS licensing is not enabled
        $passed = $false
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($customStatus -eq 'Investigate') {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to determine internal RMS licensing status due to permissions issues or incomplete configuration data."
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ Internal RMS licensing is enabled, allowing internal users to license and share protected content within the organization.`n`n"
        }
        else {
            $testResultMarkdown = "❌ Internal RMS licensing is not enabled or licensing endpoints are not configured.`n`n"
        }

        # Build detailed information if we have data
        if ($irmConfig) {
            # Prepare values first
            $internalLicensingValue = if ($null -eq $irmConfig.InternalLicensingEnabled) {
                'Unknown'
            } else {
                $irmConfig.InternalLicensingEnabled
            }

            $externalLicensingValue = if ($null -eq $irmConfig.ExternalLicensingEnabled) {
                'Unknown'
            } else {
                $irmConfig.ExternalLicensingEnabled
            }

            $azureRMSLicensingValue = if ($null -eq $irmConfig.AzureRMSLicensingEnabled) {
                'Unknown'
            } else {
                $irmConfig.AzureRMSLicensingEnabled
            }

            $licensingLocationValue = if ($irmConfig.LicensingLocation) {
                ($irmConfig.LicensingLocation | ForEach-Object { Get-SafeMarkdown $_ }) -join ', '
            } else {
                'Not configured'
            }

            $internalLicensingConfig = if ($irmConfig.InternalLicensingEnabled -eq $true) {
                '✅ Enabled'
            } elseif ($irmConfig.InternalLicensingEnabled -eq $false) {
                '❌ Disabled'
            } else {
                '⚠️ Incomplete'
            }

            $licensingEndpoints = if ($irmConfig.LicensingLocation) {
                '✅ Configured'
            } else {
                '❌ Not Configured'
            }

            # Build table
            $testResultMarkdown += "**[Internal RMS Licensing Status](https://purview.microsoft.com/settings/encryption)**`n"
            $testResultMarkdown += "| Setting | Status |`n"
            $testResultMarkdown += "| :--- | :--- |`n"
            $testResultMarkdown += "| InternalLicensingEnabled | $internalLicensingValue |`n"
            $testResultMarkdown += "| ExternalLicensingEnabled | $externalLicensingValue |`n"
            $testResultMarkdown += "| AzureRMSLicensingEnabled | $azureRMSLicensingValue |`n"
            $testResultMarkdown += "| LicensingLocation | $licensingLocationValue |`n`n"

            # Summary section
            $testResultMarkdown += "**Summary:**`n"
            $testResultMarkdown += "* Internal Licensing Configuration: $internalLicensingConfig`n"
            $testResultMarkdown += "* Licensing Endpoints: $licensingEndpoints`n"
        }
    }
    #endregion Report Generation

    $params = @{
        TestId = '35025'
        Title  = 'Internal RMS Licensing Enabled'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
