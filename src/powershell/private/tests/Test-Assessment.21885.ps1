<#
.SYNOPSIS

#>

function Test-Assessment-21885{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking App registrations must not have reply URLs containing *.azurewebsites.net, URL shorteners, or localhost, wildcard domains"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Under construction."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21885' -Title "App registrations must not have reply URLs containing *.azurewebsites.net, URL shorteners, or localhost, wildcard domains" `
        -UserImpact Low -Risk High -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
