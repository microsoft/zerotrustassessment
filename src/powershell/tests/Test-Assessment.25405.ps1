<#
.SYNOPSIS
    Checks if Intelligent Local Access is enabled and configured by verifying private networks exist.

.DESCRIPTION
    This test validates that at least one private network is configured in the tenant
    to enable Intelligent Local Access functionality in Global Secure Access.

.NOTES
    Test ID: 25405
    Category: Access control
    Required API: networkaccess/privateNetworks (beta)
#>

function Test-Assessment-25405 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('P1'),
    	Pillar = 'Network',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce'),
    	TestId = 25405,
    	Title = 'Intelligent Local Access is enabled and configured',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()


    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Intelligent Local Access configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting private networks'

    # Query private networks from Global Secure Access
    $privateNetworks = Invoke-ZtGraphRequest -RelativeUri 'networkaccess/privateNetworks' -ApiVersion beta
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $networkCount = 0

    if ($null -eq $privateNetworks -or $privateNetworks.Count -eq 0) {
        # No private networks configured - test fails
        $passed = $false
        $testResultMarkdown = "❌ No private networks are configured in your tenant.`n`n%TestResult%"
    }
    else {
        # At least one private network exists - test passes
        $networkCount = $privateNetworks.Count
        $passed = $true
        $testResultMarkdown = "✅ At least one private network is configured in your tenant.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $mdInfo = ''

    if ($passed) {
        $reportTitle = "Private Networks"
        $tableRows = ""

        $mdInfo += "`n## $reportTitle`n`n"
        $mdInfo += "Found $networkCount private network(s) configured for Intelligent Local Access.`n`n"

        $formatTemplate = @'
| Network name | Id |
| :--- | :--- |
{0}

'@
        foreach ($network in ($privateNetworks | Sort-Object name)) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/PrivateNetworks.ReactView"
            $networkName = Get-SafeMarkdown -Text $network.name
            $tableRows += "| [$networkName]($portalLink) | $($network.id) |`n"
        }
        $mdInfo += $formatTemplate -f $tableRows
    }
    else {
        $mdInfo += "`n## Private Networks`n`n"
        $mdInfo += "No private networks are currently configured. To enable Intelligent Local Access, you need to set up at least one private network in Global Secure Access.`n"
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25405'
        Title  = 'Intelligent Local Access is enabled and configured'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
