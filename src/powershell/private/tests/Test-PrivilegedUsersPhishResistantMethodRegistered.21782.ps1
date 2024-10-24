
<#
.SYNOPSIS

#>

function Test-PrivilegedUsersPhishResistantMethodRegistered {
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test

    $passed = $false

    if ($passed) {
        $testResultMarkdown += "Validated that following accounts have phishing resistant methods registered"
    }
    else {
        $testResultMarkdown += "Found Accounts have not registered phishing resistant methods`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21782' -Title 'Privileged accounts have phishing resistant methods registered' `
        -UserImpact Low -Risk High -ImplementationCost Medium `
        -AppliesTo Entra -Tag Authentication `
        -Status $passed -Result $testResultMarkdown
}
