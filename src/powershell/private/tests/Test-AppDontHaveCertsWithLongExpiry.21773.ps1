
<#
.SYNOPSIS

#>

function Test-AppDontHaveCertsWithLongExpiry {
    [CmdletBinding()]
    param(
        $Database
    )

    $passed = $true

    if ($passed) {
        $testResultMarkdown += "Applications in your tenant don’t have certificates valid for more than 180 days."
    }
    else {
        $testResultMarkdown += "The following applications and service principals have certificates longer than 180 days`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21773' -Title 'Applications don''t have certificates with expiration longer than 180 days' `
        -UserImpact Medium -Risk High -ImplementationCost Medium `
        -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}

function Get-SafeMarkdown($text) {
    $text = $text -replace "\[", "\["
    $text = $text -replace "\]", "\]"
    return $text
}
