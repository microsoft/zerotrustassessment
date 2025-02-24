<#
.SYNOPSIS
    Checks that high priority Entra recommendations are addressed
#>

function Test-HighPriorityEntraRecommendationsAddressed {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking for directory recommendations that are high priority and are active or postponed"
    Write-ZtProgress -Activity $activity

    $recommendations = Invoke-ZtGraphRequest -RelativeUri "directory/recommendations" -ApiVersion beta
    $result = $recommendations | Where-Object { $_.priority -eq 'high' -and $_.status -in @('active', 'postponed') }
    Write-Output $result.Count

    $passed = $result.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "High Priority Entra Recommendations are addressed.`n`n ✅"
    }
    else {
        $testResultMarkdown = "Unaddressed high priority entra recommendations are found.`n`n  ❌"
    }

    Add-ZtTestResultDetail -TestId '22124' -Title 'High priority Entra recommendations are addressed' `
        -UserImpact Medium -Risk High -ImplementationCost Medium `
        -AppliesTo Identity -Tag Application `
        -Status $passed -Result $testResultMarkdown
}
