<#
.SYNOPSIS

#>

function Test-Assessment-21789{
    [ZtTest(
    	Category = 'Monitoring',
    	ImplementationCost = 'Low',
    	Pillar = '',
    	RiskLevel = 'Medium',
    	SfiPillar = '',
    	TenantType = ('Workforce'),
    	TestId = 21789,
    	Title = 'Tenant creation events are triaged',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Tenant creation events are triaged"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21789' -Title "Tenant creation events are triaged" `
        -UserImpact Low -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
