<#
.SYNOPSIS

#>

function Test-Assessment-21809{
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21809,
    	Title = 'Admin consent workflow is enabled',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Admin consent workflow is enabled"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = Invoke-ZtGraphRequest -RelativeUri "policies/adminConsentRequestPolicy" -ApiVersion v1.0
    $passed = $result.isEnabled

    if ($passed) {
        $testResultMarkdown = "Admin consent workflow is enabled.`n`n"
    }
    else {
        $testResultMarkdown = "Admin consent workflow is disabled.`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", "The adminConsentRequestPolicy.isEnabled property is set to false."


    Add-ZtTestResultDetail -TestId '21809' -Title "Admin consent workflow is enabled" `
        -UserImpact Low -Risk High -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
