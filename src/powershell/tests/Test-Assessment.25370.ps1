<#
.SYNOPSIS
    Checks that Global Secure Access source IP restoration (Conditional Access signaling) is enabled.
.DESCRIPTION
    Ensures that user source IP addresses are preserved for Conditional Access and risk detection by verifying that Global Secure Access signaling is enabled in Microsoft Entra.
#>

function Test-Assessment-25370 {
    [ZtTest(
        Category = 'Network',
        ImplementationCost = 'Low',
        MinimumLicense = ('Free'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce','External'),
        TestId = 25370,
        Title = 'User source IP addresses are preserved for Conditional Access and risk detection',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Global Secure Access source IP restoration (Conditional Access signaling)'
    Write-ZtProgress -Activity $activity -Status 'Querying Global Secure Access signaling status'

    # Query Q1: Get Global Secure Access Conditional Access signaling settings
    $settings = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/settings/conditionalAccess' -ApiVersion beta

    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    #endregion Data Collection

    #region Assessment Logic
    if ($null -eq $settings) {
        $testResultMarkdown = 'Unable to retrieve Global Secure Access Conditional Access signaling settings.'
        $passed = $false
    }
    elseif ($settings.signalingStatus -eq 'enabled') {
        $testResultMarkdown = '✅ Global Secure Access signaling is enabled.'
        $passed = $true
    }
    else {
        $testResultMarkdown = '❌ Global Secure Access signaling is disabled.'
        $passed = $false
    }
    #endregion Assessment Logic


    $params = @{
        TestId = '25370'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
