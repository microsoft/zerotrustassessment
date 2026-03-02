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
    $caSettings = $null
    $errorMsg = $null

    try {
        $caSettings = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/settings/conditionalAccess' -ApiVersion beta -ErrorAction Stop
        Write-PSFMessage "Signaling status: $($caSettings.signalingStatus)" -Level Verbose
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve CA signaling settings: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($errorMsg) {
        $passed = $false
    }
    elseif (-not $caSettings -or -not $caSettings.signalingStatus) {
        # null, blank or missing property likely indicates GSA is not deployed in this tenant
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }
    else {
        $passed = $caSettings.signalingStatus -eq 'enabled'
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "❌ Unable to retrieve Global Secure Access Conditional Access signaling status.`n`nError: $errorMsg"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ Global Secure Access signaling for Conditional Access is enabled. Source IP restoration and compliant network checks are active.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ Global Secure Access signaling for Conditional Access is disabled. Conditional Access policies do not receive source IP or compliant network signals.`n`n%TestResult%"
        }

        $signalingIcon = if ($caSettings.signalingStatus -eq 'enabled') { '✅ Enabled' } else { '❌ Disabled' }

        $mdInfo = "`n`n### [Global Secure Access Conditional Access settings](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Security.ReactView)`n"
        $mdInfo += "| Property | Value |`n"
        $mdInfo += "| :--- | :--- |`n"
        $mdInfo += "| Signaling status | $signalingIcon |`n"

        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }
    #endregion Report Generation

    $params = @{
        TestId = '25380'
        Title  = 'Global Secure Access signaling for Conditional Access is enabled'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
