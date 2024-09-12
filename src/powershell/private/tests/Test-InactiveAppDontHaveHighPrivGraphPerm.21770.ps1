
<#
.SYNOPSIS

#>

function Test-InactiveAppDontHaveHighPrivGraphPerm {
    [CmdletBinding()]
    param(
        $Database
    )

    $passed = $false

    if ($passed) {
        $testResultMarkdown += "No inactive applications with high privileges"
    }
    else {
        $testResultMarkdown += "Inactive Application(s) with high privileges were found`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21770' -Title 'Inactive applications don''t have highly privileged permissions' `
        -UserImpact Low -Risk High -ImplementationCost Low `
        -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}

function Get-SafeMarkdown($text) {
    $text = $text -replace "\[", "\["
    $text = $text -replace "\]", "\]"
    return $text
}
