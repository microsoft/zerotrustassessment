<#
.SYNOPSIS

#>

function Test-Assessment-21776{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking User consent settings are restricted"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Under construction."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21776' -Title "User consent settings are restricted" `
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
