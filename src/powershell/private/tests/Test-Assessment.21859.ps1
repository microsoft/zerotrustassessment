<#
.SYNOPSIS

#>

function Test-Assessment-21859{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking GDAP admin least privilege"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21859' -Title "GDAP admin least privilege" `
        -UserImpact Low -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
