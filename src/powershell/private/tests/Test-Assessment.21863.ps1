<#
.SYNOPSIS

#>

function Test-Assessment-21863{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking All risky user sign ins are triaged"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Under construction."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21863' -Title "All risky user sign ins are triaged" `
        -UserImpact Low -Risk High -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
