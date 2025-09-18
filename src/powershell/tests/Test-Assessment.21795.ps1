<#
.SYNOPSIS

#>

function Test-Assessment-21795{
    [ZtTest(
    	Category = 'Monitoring',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Monitor and detect cyberthreats',
    	TenantType = ('Workforce'),
    	TestId = 21795,
    	Title = 'No legacy authentication sign-in activity',
    	UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking No legacy authentication sign-in activity"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21795' -Title "No legacy authentication sign-in activity" `
        -UserImpact High -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
