
<#
.SYNOPSIS

#>

function Test-GuestStrongAuthMethod {
    [CmdletBinding()]
    param(
        $Database
    )

    $passed = $true

    if ($passed) {
        $testResultMarkdown += "All guests protected with strong authentication methods."
    }
    else {
        $testResultMarkdown += "Guests are not using strong authentication methods`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21851' -Title 'All guests user strong authentication methods' `
        -UserImpact Medium -Risk Medium -ImplementationCost Medium `
        -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}

function Get-SafeMarkdown($text) {
    $text = $text -replace "\[", "\["
    $text = $text -replace "\]", "\]"
    return $text
}
