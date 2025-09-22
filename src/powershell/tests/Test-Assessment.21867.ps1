<#
.SYNOPSIS

#>

function Test-Assessment-21867{
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Monitor and detect cyberthreats',
    	TenantType = ('Workforce','External'),
    	TestId = 21867,
    	Title = 'Enterprise applications with high privilege Microsoft Graph API permissions have owners',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking All enterprise applications have owners"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21867' -Title "All enterprise applications have owners" `
        -UserImpact Low -Risk Low -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
