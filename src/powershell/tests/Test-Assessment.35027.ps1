<#
.SYNOPSIS
    Custom branding templates are configured for Office 365 Message Encryption

.DESCRIPTION
    Office 365 Message Encryption (OME) allows organizations to send encrypted emails and protect sensitive information.
    When custom branding templates are not configured for OME, external recipients receive a generic Microsoft-branded encryption portal experience.
    Custom branding templates allow organizations to apply their company logo, custom colors, disclaimer text, and contact information to the OME portal,
    reinforcing organizational identity and improving user experience for external recipients.

.NOTES
    Test ID: 35027
    Pillar: Data
    Risk Level: Low
    Category: Information Protection
#>

function Test-Assessment-35027 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3', 'Microsoft 365 E5', 'Advanced Message Encryption add-on'),
        Pillar = 'Data',
        RiskLevel = 'Low',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35027,
        Title = 'Custom branding templates are configured for Office 365 Message Encryption',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking OME Custom Branding Configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting OME Configuration'

    $omeConfig = $null
    $errorMsg = $null
    $totalConfigs = 0
    $configsWithBranding = 0
    $configDetails = @()

    try {
        # Query Q1: Get all OME template branding configurations
        $omeConfig = Get-OMEConfiguration | Select-Object -Property Identity, ImageUrl, BackgroundColor, IntroductionText, PortalText, DisclaimerText, EmailText

        # Extract and normalize data
        $totalConfigs = ($omeConfig | Measure-Object).Count

        foreach ($config in $omeConfig) {
            # Check property values once (DRY principle)
            $hasBackgroundColor = -not [string]::IsNullOrWhiteSpace($config.BackgroundColor)
            $hasIntroductionText = -not [string]::IsNullOrWhiteSpace($config.IntroductionText)
            $hasDisclaimerText = -not [string]::IsNullOrWhiteSpace($config.DisclaimerText)
            $hasPortalText = -not [string]::IsNullOrWhiteSpace($config.PortalText)
            $hasEmailText = -not [string]::IsNullOrWhiteSpace($config.EmailText)
            $hasImageUrl = -not [string]::IsNullOrWhiteSpace($config.ImageUrl)

            # Check if this configuration has any custom branding
            $hasCustomBranding = $hasBackgroundColor -or $hasIntroductionText -or $hasDisclaimerText -or $hasPortalText -or $hasEmailText -or $hasImageUrl

            if ($hasCustomBranding) {
                $configsWithBranding++
            }

            # Store configuration details for reporting
            $configDetails += [PSCustomObject]@{
                Identity         = $config.Identity
                EmailText        = if ($hasEmailText) { "✅ $($config.EmailText)" } else { '❌ None' }
                LogoConfigured   = if ($hasImageUrl) { '✅ Yes' } else { '❌ No' }
                BackgroundColor  = if ($hasBackgroundColor) { "✅ $($config.BackgroundColor)" } else { '❌ None' }
                PortalText       = if ($hasPortalText) { "✅ $($config.PortalText)" } else { '❌ None' }
                IntroductionText = if ($hasIntroductionText) { "✅ $($config.IntroductionText)" } else { '❌ None' }
                DisclaimerText   = if ($hasDisclaimerText) { "✅ $($config.DisclaimerText)" } else { '❌ None' }
            }
        }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying OME Configuration: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null
    $testResultMarkdown = ''

    if ($errorMsg) {
        # Investigate scenario
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine OME branding configuration status due to permissions issues or query failure.`n`n%TestResult%"
    }
    elseif ($configsWithBranding -gt 0) {
        # Pass scenario
        $passed = $true
        $testResultMarkdown = "✅ Custom OME branding has been configured, providing a branded encryption portal experience for external recipients.`n`n%TestResult%"
    }
    else {
        # Fail scenario
        $passed = $false
        $testResultMarkdown = "❌ OME custom branding is not configured; the encryption portal uses generic Microsoft branding.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($totalConfigs -gt 0) {
        # Build summary and configuration details table for both pass and fail scenarios
        $formatTemplate = @'
**Summary:**

- Total OME Configurations: {0}
- Configured with Custom Branding: {1}

**Configuration Details:**

| Configuration identity | Email text | Logo configured | Background color | Portal text | Introduction text | Disclaimer text |
|:-----------------------|:-----------|:----------------|:-----------------|:------------|:------------------|:----------------|
{2}
'@

        $tableRows = ''
        foreach ($detail in $configDetails) {
            $tableRows += "| $($detail.Identity) | $($detail.EmailText) | $($detail.LogoConfigured) | $($detail.BackgroundColor) | $($detail.PortalText) | $($detail.IntroductionText) | $($detail.DisclaimerText) |`n"
        }

        $mdInfo = $formatTemplate -f $totalConfigs, $configsWithBranding, $tableRows.TrimEnd("`n")
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35027'
        Title  = 'OME Custom Branding Templates'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
