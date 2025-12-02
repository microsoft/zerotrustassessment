<#
.SYNOPSIS
    Checks if Intelligent Local Access is enabled and configured by verifying private networks exist.
#>

function Test-Assessment-25405 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce'),
    	TestId = 25405,
    	Title = 'Intelligent Local Access is enabled and configured',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Intelligent Local Access configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting private networks'

    # Query private networks from Global Secure Access
    $privateNetworks = Invoke-ZtGraphRequest -RelativeUri 'networkaccess/privateNetworks' -ApiVersion beta

    if ($null -eq $privateNetworks) {
        Write-ZtProgress -Activity $activity -Status 'Failed to retrieve private networks'
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Check if at least one private network is configured
    $networkCount = ($privateNetworks | Measure-Object).Count
    $passed = $networkCount -gt 0

    if ($passed) {
        $testResultMarkdown = "At least one private network is configured in your tenant.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "There are no private networks configured in your tenant.`n`n%TestResult%"
    }

    # Build detailed information
    $mdInfo = "## Private Networks`n`n"

    if ($passed) {
        $mdInfo += "Found $networkCount private network(s) configured for Intelligent Local Access.`n`n"
        $mdInfo += "| Name | Id |`n"
        $mdInfo += "| :--- | :--- |`n"

        foreach ($network in $privateNetworks | Sort-Object name) {
            $mdInfo += "| $($network.name) | $($network.id) |`n"
        }
    }
    else {
        $mdInfo += "No private networks are currently configured. Consider setting up private networks to enable Intelligent Local Access.`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId = 25405
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
