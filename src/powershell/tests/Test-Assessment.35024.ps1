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
        $irmConfig = Get-IRMConfiguration -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying IRM Configuration: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $investigateFlag = $false
    $azureRMSEnabledStatus = '❌ Disabled'

    if ($errorMsg) {
        $investigateFlag = $true
    }
    else {
        # Query Q2: Check if Azure RMS licensing is enabled
        $azureRMSEnabled = $irmConfig.AzureRMSLicensingEnabled

        if ($azureRMSEnabled -eq $true) {
            $passed = $true
        }
        else {
            $passed = $false
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    if($investigateFlag){
        $testResultMarkdown = "⚠️ Unable to determine Azure RMS status due to permissions issues or service connection failure.`n`n"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅Azure RMS is enabled at the tenant level, enabling all downstream encryption and rights management capabilities.`n`n"
            $azureRMSEnabledStatus = '✅ Enabled'
        }
        else {
            $testResultMarkdown = "❌ Azure RMS is not enabled or is disabled for the tenant.`n`n"
            $azureRMSEnabledStatus = '❌ Disabled'
        }

        $testResultMarkdown += "### Summary`n`n"
        $testResultMarkdown += "- **Azure RMS Service:** $($azureRMSEnabledStatus)`n"


        $testResultMarkdown += "### Azure RMS Status`n`n"
        $testResultMarkdown += "| Service Enabled | Activation Date | Key Management Mode | Licensing Model |`n"
        $testResultMarkdown += "|:---|:---|:---|:---|`n"

        $testResultMarkdown += "| $azureRMSEnabledStatus | OnboardingDate if available | Standard/BYOK/Other | Enterprise/Consumer/Mixed |`n"

        $testResultMarkdown += "`n[Microsoft Purview portal > Settings > Encryption > Azure Information Protection](https://purview.microsoft.com/settings/encryption)`n"
    }
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
