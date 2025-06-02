
<#
.SYNOPSIS

#>

function Test-Assessment-21851 {
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result

    Add-ZtTestResultDetail -TestId '21851' -Title 'All guests user strong authentication methods' `
        -UserImpact Medium -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Application `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
