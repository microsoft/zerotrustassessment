<#
.SYNOPSIS

#>

function Test-Assessment-21775{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = '',
    	RiskLevel = 'Low',
    	SfiPillar = '',
    	TenantType = ('Workforce','External'),
    	TestId = 21775,
    	Title = 'Tenant app management policy is configured',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Tenant app management policy is configured"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21775' -Title "Tenant app management policy is configured" `
        -UserImpact Medium -Risk Low -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
