<#
.SYNOPSIS

#>

function Test-Assessment-21780{
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'High',
    	Pillar = '',
    	RiskLevel = 'Medium',
    	SfiPillar = '',
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
    # $adalRecommendations = Invoke-ZtGraphRequest -RelativeUri 'directory/recommendations?$filter=recommendationType eq ''adalToMsalMigration''' -ApiVersion beta

    # **** using applicationCredentialExpiry Only for testing purpose, as no data available in adalToMsalMigration, must be replaced afterwards with adalToMsalMigration

    $adalRecommendations = Invoke-ZtGraphRequest -RelativeUri 'directory/recommendations?$filter=recommendationType eq ''applicationCredentialExpiry''' -ApiVersion beta

    $mdInfo = ""

    if ($adalRecommendations.Count -gt 0) {
        $passed = $false
        $testResultMarkdown = "❌ **Fail**: ADAL Applications found in the tenant.%TestResult%"

        # Build markdown table for found ADAL applications
        $mdInfo = "`n## ADAL Applications Found`n`n"
        $mdInfo += "| App ID | App Display Name |`n"
        $mdInfo += "| :---- | :---- |`n"

        foreach ($recommendation in $adalRecommendations) {
            $appId = $recommendation.id
            $displayName = $recommendation.displayName
            $mdInfo += "| $appId | $displayName |`n"
        }

        $mdInfo += "`n**Note**: Microsoft ended all support and security fixes for ADAL on June 30, 2023. These applications should be migrated to MSAL to ensure modern security protections.`n"
    }
    else {
        $passed = $true
        $testResultMarkdown = "✅ **Pass**: No ADAL applications found in the tenant.%TestResult%"
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
