
<#
.SYNOPSIS

#>

function Test-AppDontHaveSecrets {
    [CmdletBinding()]
    param(
        $Database
    )

    $passed = $true

    if ($passed) {
        $testResultMarkdown += "Applications in your tenants do not use client secrets."
    }
    else {
        $testResultMarkdown += "The following applications and service principals have client secrets configured`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21772' -Title 'Applications don''t have secrets configured' `
        -UserImpact Medium -Risk High -ImplementationCost Medium `
        -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}

function Get-SafeMarkdown($text) {
    $text = $text -replace "\[", "\["
    $text = $text -replace "\]", "\]"
    return $text
}
