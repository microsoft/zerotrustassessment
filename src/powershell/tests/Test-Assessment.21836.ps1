<#
.SYNOPSIS

#>

function Test-Assessment-21836{
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect engineering systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21836,
    	Title = 'Workload Identities are not assigned privileged roles',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Workload identities assigned privileged roles"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21836' -Title "Workload identities assigned privileged roles" `
        -UserImpact Low -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
