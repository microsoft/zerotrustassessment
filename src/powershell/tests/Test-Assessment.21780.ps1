<#
.SYNOPSIS

#>

function Test-Assessment-21780 {
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'High',
    	MinimumLicense = ('Free'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21780,
    	Title = 'No usage of ADAL in the tenant',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking No usage of ADAL in the tenant"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Find the entra recommendation specific to ADAL/MSAL Migration
    $adalRecommendations = Invoke-ZtGraphRequest -RelativeUri "directory/recommendations" -filter "recommendationType eq 'adalToMsalMigration'" -ApiVersion beta

    $mdInfo = ""

    if ($adalRecommendations.Count -gt 0) {
        # Test Failed
        $passed = $false
        $testResultMarkdown = "ADAL Applications found in the tenant.%TestResult%"

        # markdown table for found ADAL applications
        $mdInfo = "`n## ADAL Applications Found`n`n"
        $mdInfo += "| Application |`n"
        $mdInfo += "| :---- |`n"

        foreach ($recommendation in $adalRecommendations) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Branding/appId/{0}" -f $recommendation.subjectId
            $mdInfo += "| [$(Get-SafeMarkdown($recommendation.displayName))]($portalLink) |`n"
        }

    }
    else {
        # Test passed
        $passed = $true
        $testResultMarkdown = "No ADAL applications found in the tenant.%TestResult%"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21780'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
