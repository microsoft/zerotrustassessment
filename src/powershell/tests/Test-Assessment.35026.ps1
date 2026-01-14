<#
.SYNOPSIS
    Validates that SimplifiedClientAccessEnabled is enabled for Office 365 Message Encryption (OME).

.DESCRIPTION
    This test checks if SimplifiedClientAccessEnabled is enabled for OME, which allows external recipients
    to access encrypted emails using native email clients with simplified authentication flows rather than
    being forced to use the OME portal exclusively.

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
    elseif ($irmConfig.SimplifiedClientAccessEnabled -eq $true) {
        # Pass: SimplifiedClientAccessEnabled is true
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
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to determine OME SimplifiedClientAccess status due to permissions issues, service connection failure, or OME not configured."
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ SimplifiedClientAccessEnabled is true, allowing external recipients simplified client access to encrypted emails.`n`n"
    }
    else {
        $testResultMarkdown = "❌ SimplifiedClientAccessEnabled is false, requiring external recipients to use the OME portal exclusively.`n`n"
    }

    # Build detailed information if we have data
    if ($irmConfig) {
        $testResultMarkdown += "## [OME SimplifiedClientAccess Configuration](https://admin.exchange.microsoft.com/#/transportrules)`n`n"
        $testResultMarkdown += "| Property | Value |`n"
        $testResultMarkdown += "| :--- | :--- |`n"

        # SimplifiedClientAccessEnabled
        $simplifiedAccessValue = if ($irmConfig.SimplifiedClientAccessEnabled -eq $true) { '✅ True' } elseif ($irmConfig.SimplifiedClientAccessEnabled -eq $false) { '❌ False' } else { '⚠️ Not configured' }
        $testResultMarkdown += "| SimplifiedClientAccessEnabled | $simplifiedAccessValue |`n"

        # SimplifiedClientAccessEncryptOnlyDisabled
        if ($null -ne $irmConfig.SimplifiedClientAccessEncryptOnlyDisabled) {
            $encryptOnlyValue = if ($irmConfig.SimplifiedClientAccessEncryptOnlyDisabled -eq $false) { '✅ Allowed' } else { '❌ Disabled' }
            $testResultMarkdown += "| Encrypt-Only in Simplified Client Access | $encryptOnlyValue |`n"
        }

        # SimplifiedClientAccessDoNotForwardDisabled
        if ($null -ne $irmConfig.SimplifiedClientAccessDoNotForwardDisabled) {
            $doNotForwardValue = if ($irmConfig.SimplifiedClientAccessDoNotForwardDisabled -eq $false) { '✅ Allowed' } else { '❌ Disabled' }
            $testResultMarkdown += "| Do Not Forward in Simplified Client Access | $doNotForwardValue |`n"
        }

        # DecryptAttachmentFromPortal
        if ($null -ne $irmConfig.DecryptAttachmentFromPortal) {
            $decryptAttachmentValue = if ($irmConfig.DecryptAttachmentFromPortal -eq $true) { '✅ Enabled' } else { '❌ Disabled' }
            $testResultMarkdown += "| Decrypt Attachment From Portal | $decryptAttachmentValue |`n"
        }

        # EnablePortalTrackingLogs
        if ($null -ne $irmConfig.EnablePortalTrackingLogs) {
            $trackingLogsValue = if ($irmConfig.EnablePortalTrackingLogs -eq $true) { '✅ Enabled' } else { '❌ Disabled' }
            $testResultMarkdown += "| Portal Tracking Logs | $trackingLogsValue |`n"
        }

        # Summary
        $testResultMarkdown += "`n**Summary:**`n"
        $clientAccessMode = if ($irmConfig.SimplifiedClientAccessEnabled -eq $true) { 'Simplified' } else { 'Portal-Only' }
        $recipientExperience = if ($irmConfig.SimplifiedClientAccessEnabled -eq $true) { 'Flexible' } else { 'Restrictive' }
        $testResultMarkdown += "* Client Access Mode: $clientAccessMode`n"
        $testResultMarkdown += "* External Recipient Experience: $recipientExperience`n"
    }
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
