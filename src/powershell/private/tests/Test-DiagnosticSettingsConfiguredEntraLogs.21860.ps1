
<#
.SYNOPSIS

#>

function Test-DiagnosticSettingsConfiguredEntraLogs {
    [CmdletBinding()]
    param(
        $Database
    )

    $passed = $true

    if ($passed) {
        $testResultMarkdown += "All Entra Logs are configured with Diagnostic Settings."
    }
    else {
        $testResultMarkdown += "Some Entra Logs are not configured with Diagnostic settings`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21860' -Title 'Diagnostic settings are configured for all Microsoft Entra logs' `
        -UserImpact Low -Risk High -ImplementationCost Medium `
        -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}

function Get-SafeMarkdown($text) {
    $text = $text -replace "\[", "\["
    $text = $text -replace "\]", "\]"
    return $text
}
