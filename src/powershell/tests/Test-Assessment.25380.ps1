<#
.SYNOPSIS
    Global Secure Access signaling for Conditional Access is enabled

.DESCRIPTION
    When Global Secure Access routes user traffic through Microsoft's Security Service Edge,
    the original source IP of the user is replaced by the proxy egress IP. If signaling is not
    enabled, Conditional Access policies that rely on named locations or trusted IP ranges evaluate
    the proxy IP, not the user's actual location. Enabling signaling restores the original source IP
    to Microsoft Entra ID and allows Conditional Access to enforce compliant network checks.

.NOTES
    Test ID: 25380
    Pillar: Network
    Risk Level: Medium
    Category: Global Secure Access
#>

function Test-Assessment-25380 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('AAD_PREMIUM', 'Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25380,
        Title = 'Global Secure Access signaling for Conditional Access is enabled',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Global Secure Access Conditional Access signaling status'

    # Q1: Retrieve Global Secure Access Conditional Access signaling status
    Write-ZtProgress -Activity $activity -Status 'Getting Conditional Access signaling settings'
    $caSettings = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/settings/conditionalAccess' -ApiVersion beta
    Write-PSFMessage "Signaling status: $($caSettings.signalingStatus)" -Level Verbose
    #endregion Data Collection

    #region Assessment Logic
    $passed = $caSettings.signalingStatus -eq 'enabled'

    if ($passed) {
        $testResultMarkdown = "✅ Global Secure Access signaling for Conditional Access is enabled. Source IP restoration and compliant network checks are active.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Global Secure Access signaling for Conditional Access is disabled. Conditional Access policies do not receive source IP or compliant network signals.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $signalingIcon = if ($caSettings.signalingStatus -eq 'enabled') { '✅ Enabled' } else { '❌ Disabled' }

    $mdInfo = "`n`n### [Global Secure Access Conditional Access settings](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Security.ReactView)`n"
    $mdInfo += "| Property | Value |`n"
    $mdInfo += "| :--- | :--- |`n"
    $mdInfo += "| Signaling status | $signalingIcon |`n"

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25380'
        Title  = 'Global Secure Access signaling for Conditional Access is enabled'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
