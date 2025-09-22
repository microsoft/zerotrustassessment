<#
.SYNOPSIS

#>

function Test-Assessment-21835{
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'High',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect engineering systems',
    	TenantType = ('Workforce'),
    	TestId = 21835,
    	Title = 'Emergency access accounts are configured appropriately',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Emergency account exists"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21835' -Title "Emergency account exists" `
        -UserImpact Low -Risk Low -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
