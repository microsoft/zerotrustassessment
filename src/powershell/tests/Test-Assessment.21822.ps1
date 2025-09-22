<#
.SYNOPSIS

#>

function Test-Assessment-21822{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'High',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21822,
    	Title = 'Guest access is limited to approved tenants',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Guest access is limited to approved tenants"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21822' -Title "Guest access is limited to approved tenants" `
        -UserImpact Medium -Risk Medium -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
