
<#
.SYNOPSIS

#>

function Test-Assessment-21851 {
    [ZtTest(
    	Category = 'External collaboration',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 21851,
    	Title = 'Guest access is protected by strong authentication methods',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result

    Add-ZtTestResultDetail -TestId '21851' -Title 'All guests user strong authentication methods' `
        -UserImpact Medium -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Application `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
