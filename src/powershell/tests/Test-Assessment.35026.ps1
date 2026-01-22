<#
.SYNOPSIS
    Validates that SimplifiedClientAccessEnabled is enabled for Office 365 Message Encryption (OME).

.DESCRIPTION
    This test checks if SimplifiedClientAccessEnabled is enabled for OME, which controls whether the
    Protect button is available in Outlook on the web, allowing users to quickly apply encryption
    protections to their messages. SimplifiedClientAccessEnabled requires AzureRMSLicensingEnabled
    to be active, as Azure Rights Management is the underlying encryption foundation.

.NOTES
    Test ID: 35026
    Category: Office 365 Message Encryption (OME)
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Exchange Online
#>

function Test-Assessment-35026 {
    [ZtTest(
        Category = 'Office 365 Message Encryption (OME)',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce', 'External'),
        TestId = 35026,
        Title = 'Office 365 Message Encryption (OME) - SimplifiedClientAccessEnabled',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking OME SimplifiedClientAccess Configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting IRM configuration'

    # Get IRM configuration for OME settings
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
    elseif ($null -eq $irmConfig) {
        # Investigate: Cannot determine OME status
        $passed = $false
        $customStatus = 'Investigate'
    }
    elseif ($null -eq $irmConfig.SimplifiedClientAccessEnabled) {
        # Investigate: Property not available (OME not configured)
        $passed = $false
        $customStatus = 'Investigate'
    }
    elseif ($null -eq $irmConfig.AzureRMSLicensingEnabled) {
        # Investigate: AzureRMSLicensingEnabled property not available (incomplete configuration)
        $passed = $false
        $customStatus = 'Investigate'
    }
    # Check AzureRMSLicensingEnabled first (prerequisite for encryption foundation)
    elseif ($irmConfig.AzureRMSLicensingEnabled -ne $true) {
        # Fail: Encryption foundation is explicitly disabled
        $passed = $false
    }
    elseif ($irmConfig.SimplifiedClientAccessEnabled -eq $true) {
        # Pass: Both SimplifiedClientAccessEnabled and AzureRMSLicensingEnabled are true
        $passed = $true
    }
    else {
        # Fail: SimplifiedClientAccessEnabled is false
        $passed = $false
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''

    if ($customStatus -eq 'Investigate') {
        $testResultMarkdown = "⚠️ Unable to determine SimplifiedClientAccessEnabled status due to permissions issues or OME not configured.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ SimplifiedClientAccessEnabled is true (Protect button enabled) and AzureRMSLicensingEnabled is true (encryption foundation active).`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ SimplifiedClientAccessEnabled is false or AzureRMSLicensingEnabled is false (encryption foundation or Protect button disabled).`n`n%TestResult%"
    }

    # Build detailed information if we have data
    $mdInfo = ''

    if ($irmConfig) {
        $reportTitle = 'OME SimplifiedClientAccess Status'

        $protectButtonStatus = if (($irmConfig.SimplifiedClientAccessEnabled -eq $true) -and ($irmConfig.AzureRMSLicensingEnabled -eq $true)) {
            '✅ Enabled'
        } else {
            '❌ Disabled'
        }

        $formatTemplate = @'

### {0}

| Setting | Value |
| :------ | :---- |
{1}

**Summary:**

* Protect Button Status: {2}

'@

        $tableRows = "| SimplifiedClientAccessEnabled | $($irmConfig.SimplifiedClientAccessEnabled) |`n"
        $tableRows += "| AzureRMSLicensingEnabled | $($irmConfig.AzureRMSLicensingEnabled) |`n"
        $tableRows += "| InternalLicensingEnabled | $($irmConfig.InternalLicensingEnabled) |`n"

        $mdInfo = $formatTemplate -f $reportTitle, $tableRows, $protectButtonStatus
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35026'
        Title  = 'Office 365 Message Encryption (OME) - SimplifiedClientAccessEnabled'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
