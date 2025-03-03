<#
.SYNOPSIS

#>

function Test-Assessment-21832{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking All groups in Conditional Access policies belong to a restricted management administrative unit"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21832' -Title "All groups in Conditional Access policies belong to a restricted management administrative unit" `
        -UserImpact Low -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
