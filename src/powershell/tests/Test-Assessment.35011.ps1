<#
.SYNOPSIS
    Azure Information Protection (AIP) Super User Feature Configuration

.DESCRIPTION
    Evaluates whether the Azure Information Protection (AIP) super user feature is enabled and properly configured with designated super users. The super user feature allows specified service accounts or administrators to decrypt rights-managed content for auditing, search, and compliance purposes.

    The cmdlets require the AipService module (v3.0+) which is only supported on Windows PowerShell 5.1. A PowerShell 7 subprocess workaround is automatically employed if running under PowerShell Core.

.NOTES
    Test ID: 35011
    Pillar: Data
    Risk Level: High
#>

function Test-Assessment-35011 {
    [ZtTest(
        Category = 'Azure Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = '',
        TenantType = ('Workforce','External'),
        TestId = 35011,
        Title = 'Azure Information Protection (AIP) Super User Feature',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Azure Information Protection Super User Configuration'
    Write-ZtProgress -Activity $activity -Status 'Querying AIP super user settings'

    $superUserFeatureEnabled = $null
    $superUsers = @()
    $errorMsg = $null

    try {
        # Note: AipService must be authenticated in Connect-ZtAssessment first
        # This test only performs queries against the authenticated service

        # Query Q1: Check if super user feature is enabled
        $superUserFeatureEnabled = Get-AipServiceSuperUserFeature -ErrorAction Stop

        # Query Q2: Get list of configured super users
        $superUsers = Get-AipServiceSuperUser -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying AIP Super User configuration: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $investigateFlag = $false

    if ($errorMsg) {
        $investigateFlag = $true
    }
    else {
        # Evaluation logic:
        # 1. If feature is disabled, test fails
        if ($superUserFeatureEnabled -eq $false) {
            $passed = $false
        }
        # 2. If feature is enabled, check if at least one super user is configured
        elseif ($superUserFeatureEnabled -eq $true) {
            $superUserCount = if ($superUsers) { @($superUsers).Count } else { 0 }

            if ($superUserCount -ge 1) {
                $passed = $true
            }
            else {
                $passed = $false
            }
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ""
    $mdInfo = ""

    if ($investigateFlag) {
        $testResultMarkdown = "⚠️ Unable to determine AIP super user configuration due to permissions or connection issues.`n`n"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ Super user feature is enabled with at least one member configured.`n`n"
        }
        else {
            if ($superUserFeatureEnabled -eq $true) {
                $testResultMarkdown = "❌ Super user feature is enabled BUT no members are configured.`n`n"
            }
            else {
                $testResultMarkdown = "❌ Super user feature is DISABLED.`n`n"
            }
        }

        # Build detailed information section
        $mdInfo = "## Azure Information Protection Super User Configuration`n`n"

        $featureStatus = if ($superUserFeatureEnabled) { "Enabled" } else { "Disabled" }
        $mdInfo += "**Super User Feature: $featureStatus**`n`n"

        if ($superUserFeatureEnabled) {
            $superUserCount = if ($superUsers) { @($superUsers).Count } else { 0 }
            $mdInfo += "**Super Users Configured: $superUserCount**`n`n"

            if ($superUserCount -gt 0) {
                $mdInfo += "| Email Address / Service Principal ID | Account Type |`n"
                $mdInfo += "| :--- | :--- |`n"

                foreach ($superUser in $superUsers) {
                    $accountType = if ($superUser -like '*-*-*-*-*') { "Service Principal" } else { "User" }
                    $mdInfo += "| $superUser | $accountType |`n"
                }

                $mdInfo += "`n"
            }
        }

        $mdInfo += "**Note:** Super user configuration is not available through the Azure portal and must be managed via PowerShell using the AipService module.`n"

        # Add mdInfo to the main markdown if there's content
        if ($mdInfo) {
            $testResultMarkdown += "%TestResult%"
        }
    }
    #endregion Report Generation

    # Replace placeholder with actual detailed info
    if ($mdInfo) {
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    }

    $params = @{
        TestId             = '35011'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    # Add investigate status if needed
    if ($investigateFlag -eq $true) {
        $params.CustomStatus = 'Investigate'
    }
    Add-ZtTestResultDetail @params
}
