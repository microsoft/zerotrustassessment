<#
.SYNOPSIS

#>

function Test-Assessment-21806{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Secure the MFA registration (My Security Info) page"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Under construction."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21806' -Title "Secure the MFA registration (My Security Info) page" `
        -UserImpact Low -Risk High -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
