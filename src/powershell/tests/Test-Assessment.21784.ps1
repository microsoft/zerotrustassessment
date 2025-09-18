<#
.SYNOPSIS

#>

function Test-Assessment-21784{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = '',
    	RiskLevel = 'Medium',
    	SfiPillar = '',
    	TenantType = ('Workforce','External'),
    	TestId = 21784,
    	Title = 'All user sign in activity uses phishing-resistant authentication methods',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking All user sign in activity uses phishing-resistant authentication methods"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21784' -Title "All user sign in activity uses phishing-resistant authentication methods" `
        -UserImpact Low -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
