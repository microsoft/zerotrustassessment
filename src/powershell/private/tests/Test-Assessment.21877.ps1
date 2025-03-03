<#
.SYNOPSIS

#>

function Test-Assessment-21877{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking All guests have a sponsor"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21877' -Title "All guests have a sponsor" `
        -UserImpact High -Risk Medium -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
