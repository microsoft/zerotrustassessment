<#
.SYNOPSIS

#>

function Test-Assessment-21834{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Directory sync account is locked down to specific named location"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21834' -Title "Directory sync account is locked down to specific named location" `
        -UserImpact Low -Risk Low -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
