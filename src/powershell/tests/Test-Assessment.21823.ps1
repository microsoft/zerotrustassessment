<#
.SYNOPSIS

#>

function Test-Assessment-21823{
    [ZtTest(
    	Category = 'External collaboration',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 21823,
    	Title = 'Guest self-service sign-up via user flow is disabled',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Guest self-service sign up via user flow is disabled"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21823' -Title "Guest self-service sign up via user flow is disabled" `
        -UserImpact Medium -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
