<#
.SYNOPSIS

#>

function Test-Assessment-%testId%{
	[ZtTest(
		Category = '%category%',
		ImplementationCost = '%implementationCost%',
		Pillar = 'Identity',
		RiskLevel = '%risk%',
		SfiPillar = "Protect identities and secrets",
		TenantType = ('Workforce', 'External'),
		TestId = %testid%,
		Title = "%testTitle%",
		UserImpact = '%userImpact%'
	)]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking %testTitle%"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '%testId%' -Title "%testTitle%" `
        -UserImpact %userImpact% -Risk %risk% -ImplementationCost %implementationCost% `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
