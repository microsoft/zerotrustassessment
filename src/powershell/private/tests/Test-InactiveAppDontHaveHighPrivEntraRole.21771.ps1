
<#
.SYNOPSIS

#>

function Test-InactiveAppDontHaveHighPrivEntraRole {
    [CmdletBinding()]
    param(
        $Database
    )

    $passed = $true

    if ($passed) {
        $testResultMarkdown += "No inactive applications with privileged Entra built-in roles"
    }
    else {
        $testResultMarkdown += "No inactive applications with privileged Entra built-in roles`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21771' -Title 'Inactive applications don'’t have highly privileged Microsoft Entra built-in roles' `
        -UserImpact Low -Risk High -ImplementationCost Low `
        -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}

function Get-SafeMarkdown($text) {
    $text = $text -replace "\[", "\["
    $text = $text -replace "\]", "\]"
    return $text
}
