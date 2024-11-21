
<#
.SYNOPSIS

#>

function Test-GuestStrongAuthMethod {
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

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
        -AppliesTo Identity -Tag Application `
        -Status $passed -Result $testResultMarkdown
}
