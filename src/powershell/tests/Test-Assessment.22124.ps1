<#
.SYNOPSIS
    Checks that high priority Entra recommendations are addressed
#>

function Test-Assessment-22124 {
    [ZtTest(
    	Category = 'Monitoring',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Monitor and detect cyberthreats',
    	TenantType = ('Workforce','External'),
    	TestId = 22124,
    	Title = 'High priority Microsoft Entra recommendations are addressed',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking for directory recommendations that are high priority and are active or postponed"
    Write-ZtProgress -Activity $activity

    $recommendations = Invoke-ZtGraphRequest -RelativeUri "directory/recommendations" -ApiVersion beta
    $result = $recommendations | Where-Object { $_.priority -eq 'high' -and $_.status -in @('active', 'postponed') }

    $passed = $result.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "High Priority Entra Recommendations are addressed.`n`n"
    }
    else {
        $testResultMarkdown = "Found $($result.Count) unaddressed high priority Entra recommendations.`n`n%TestResult%"
    }

    if ($result.Count -gt 0) {
        $mdInfo = "`n## Unaddressed high priority Entra recommendations`n`n"
        $mdInfo += "| Display Name | Status | Insights |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($item in $result) {
            $mdInfo += "| $($item.displayName) | $($item.status) | $($item.Insights) |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '22124' -Title 'High priority Entra recommendations are addressed' `
        -UserImpact Medium -Risk High -ImplementationCost Medium `
        -AppliesTo Identity -Tag Application `
        -Status $passed -Result $testResultMarkdown
}
