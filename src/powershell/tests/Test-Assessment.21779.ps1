<#
.SYNOPSIS

#>

function Test-Assessment-21779{
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	Pillar = '',
    	RiskLevel = 'Medium',
    	SfiPillar = '',
    	TenantType = ('Workforce','External'),
    	TestId = 21779,
    	Title = 'Use recent versions of Microsoft Applications',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Use recent versions of Microsoft Applications"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21779' -Title "Use recent versions of Microsoft Applications" `
        -UserImpact Low -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
