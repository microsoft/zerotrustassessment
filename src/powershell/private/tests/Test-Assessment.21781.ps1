<#
.SYNOPSIS
    Checks that admins are enforced for phishing resistant authentication.
#>

function Test-Assessment-21781 {
    [CmdletBinding()]
    param()
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $passed = $false

    if ($passed) {
        $testResultMarkdown += "Validated that following accounts have phishing resistant methods registered"
    }
    else {
        $testResultMarkdown += "Found Accounts have not registered phishing resistant methods`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21781' -Title 'Privileged users sign in with phishing-resistant methods' `
        -UserImpact Low -Risk High -ImplementationCost Medium `
        -AppliesTo Identity -Tag Authentication `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
