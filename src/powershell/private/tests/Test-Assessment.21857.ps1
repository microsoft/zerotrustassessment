<#
.SYNOPSIS

#>

function Test-Assessment-21857{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Guest identities are lifecycle managed with access reviews"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21857' -Title "Guest identities are lifecycle managed with access reviews" `
        -UserImpact Low -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
