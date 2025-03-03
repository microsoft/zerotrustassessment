<#
.SYNOPSIS

#>

function Test-Assessment-21849{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Smart lockout duration is set to a minimum of 60"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21849' -Title "Smart lockout duration is set to a minimum of 60" `
        -UserImpact Low -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
