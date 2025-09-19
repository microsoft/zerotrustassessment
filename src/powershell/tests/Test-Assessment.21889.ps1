<#
.SYNOPSIS

#>

function Test-Assessment-21889{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = '',
    	RiskLevel = 'Low',
    	SfiPillar = '',
    	TenantType = ('Workforce','External'),
    	TestId = 21889,
    	Title = 'Reduce the user-visible password surface area',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Reduce the user-visible password surface area"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21889' -Title "Reduce the user-visible password surface area" `
        -UserImpact Medium -Risk Low -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
