<#
.SYNOPSIS

#>

function Test-Assessment-21884{
    [ZtTest(
    	Category = 'External collaboration',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and production systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21884,
    	Title = 'Conditional Access policies for workload identities based on known networks are configured',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Workload identities based on known networks are configured"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21884' -Title "Workload identities based on known networks are configured" `
        -UserImpact Low -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
