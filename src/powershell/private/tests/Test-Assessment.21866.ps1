<#
.SYNOPSIS

#>

function Test-Assessment-21866{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking All Microsoft Entra recommendations are addressed"
    Write-ZtProgress -Activity $activity

    $recommendations = Invoke-ZtGraphRequest -RelativeUri "directory/recommendations" -ApiVersion beta
    $result = $recommendations | Where-Object { $_.status -in @('active', 'postponed') }

    $passed = $result.Count -eq 0
    if ($passed) {
        $testResultMarkdown = "All Entra Recommendations are addressed.`n`n"
    }
    else {
        $testResultMarkdown = "Found $($result.Count) unaddressed Entra recommendations.`n`n%TestResult%"
    }

    if ($result.Count -gt 0) {
        $mdInfo = "`n## Unaddressed Entra recommendations`n`n"
        $mdInfo += "| Display Name | Status | Insights | Priority |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"
        foreach ($item in $result) {
            $mdInfo += "| $($item.displayName) | $($item.status) | $($item.Insights) | $($item.priority) |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21866' -Title "All Microsoft Entra recommendations are addressed" `
        -UserImpact Low -Risk Medium -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
