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

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21780' -Title "No usage of ADAL in the tenant" `
        -UserImpact Low -Risk Medium -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
