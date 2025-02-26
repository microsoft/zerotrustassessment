<#
.SYNOPSIS

#>

function Test-Assessment-%testId%{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking %testTitle%"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Under construction."
    $passed = $result


    Add-ZtTestResultDetail -TestId '%testId%' -Title "%testTitle%" `
        -UserImpact %userImpact% -Risk %risk% -ImplementationCost %implementationCost% `
        -AppliesTo Entra -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
