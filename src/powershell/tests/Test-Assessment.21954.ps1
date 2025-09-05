<#
.SYNOPSIS

#>

function Test-Assessment-21954{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Restrict nonadministrator users from recovering the BitLocker keys for their owned devices"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21954' -Title "Restrict nonadministrator users from recovering the BitLocker keys for their owned devices" `
        -UserImpact Low -Risk Low -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
