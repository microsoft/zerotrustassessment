<#
.SYNOPSIS

#>

function Test-Assessment-21869{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Enterprise applications must require explicit assignment or scoped provisioning"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21869' -Title "Enterprise applications must require explicit assignment or scoped provisioning" `
        -UserImpact Low -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
