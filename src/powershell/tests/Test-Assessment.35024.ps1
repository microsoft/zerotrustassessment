<#
.SYNOPSIS
    Azure RMS Licensing Enabled

.DESCRIPTION
    Azure Rights Management Service (Azure RMS) is the foundational encryption and access control technology underlying Microsoft Information Protection.
    Without Azure RMS enabled, organizations cannot implement sensitivity labels with encryption, protect emails with Office 365 Message Encryption (OME),
    enforce information rights management (IRM) policies, or deploy rights protection through mail flow rules.
    Azure RMS must be explicitly activated at the tenant level before any downstream protection features can function.

.NOTES
    Test ID: 35024
    Pillar: Data
    Risk Level: High
    Category: Rights Management Service (RMS)
#>

function Test-Assessment-35024 {
    [ZtTest(
        Category = 'Rights Management Service (RMS)',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35024,
        Title = 'Azure RMS Licensing Enabled',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Azure RMS Licensing Status'
    Write-ZtProgress -Activity $activity -Status 'Getting IRM Configuration'

    $irmConfig = $null
    $errorMsg = $null

    try {
        # Query Q1: Get IRM configuration status
        $irmConfig = Get-IRMConfiguration -ErrorAction Stop | Select-Object -Property AzureRMSLicensingEnabled, SimplifiedClientAccessEnabled, InternalLicensingEnabled, ExternalLicensingEnabled, WhenCreatedUTC
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying IRM Configuration: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $investigateFlag = $false

    if ($errorMsg) {
        $investigateFlag = $true
        $testResultMarkdown = "⚠️ Unable to retrieve Azure RMS licensing status. Please verify connectivity and permissions.`n`n%TestResult%"
    }
    else {
        $passed = $irmConfig.AzureRMSLicensingEnabled -eq $true

        if ($passed) {
            $testResultMarkdown = "✅ Azure RMS is enabled at the tenant level, enabling all downstream encryption and rights management capabilities.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ Azure RMS is not enabled or is disabled for the tenant.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($investigateFlag) {
        $azureRMSEnabledStatus = '⚠️ Unknown'
        $mdInfo = "**Summary:**`n`n Azure RMS Service: $azureRMSEnabledStatus`n"
    }
    else {
        $reportTitle = 'Azure RMS Status'
        $whenCreatedDate = if ($null -eq $irmConfig.WhenCreatedUTC) { 'N/A' } else { $irmConfig.WhenCreatedUTC }

        if ($passed) {
            $azureRMSEnabledStatus = '✅ Enabled'
        }
        else {
            $azureRMSEnabledStatus = '❌ Disabled'
        }

        $formatTemplate = @'

### {0}

| Setting | Value |
| :------ | :---- |
{1}

**Summary:**

 Azure RMS Service: {2}

'@

        $tableRows = "| AzureRMSLicensingEnabled | $($irmConfig.AzureRMSLicensingEnabled) |`n"
        $tableRows += "| SimplifiedClientAccessEnabled | $($irmConfig.SimplifiedClientAccessEnabled) |`n"
        $tableRows += "| InternalLicensingEnabled | $($irmConfig.InternalLicensingEnabled) |`n"
        $tableRows += "| ExternalLicensingEnabled | $($irmConfig.ExternalLicensingEnabled) |`n"
        $tableRows += "| Configuration Created | $whenCreatedDate |`n"

        $mdInfo = $formatTemplate -f $reportTitle, $tableRows, $azureRMSEnabledStatus
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35024'
        Title  = 'Azure RMS Licensing Enabled'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($investigateFlag -eq $true) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
