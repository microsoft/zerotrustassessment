<#
.SYNOPSIS

#>

function Test-Assessment-21829{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Use cloud authentication"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21829' -Title "Use cloud authentication" `
        -UserImpact High -Risk High -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
