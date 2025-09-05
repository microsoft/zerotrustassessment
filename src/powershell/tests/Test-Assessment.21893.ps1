<#
.SYNOPSIS

#>

function Test-Assessment-21893{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Enable Microsoft Entra ID Protection policy to enforce multifactor authentication registration"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21893' -Title "Enable Microsoft Entra ID Protection policy to enforce multifactor authentication registration" `
        -UserImpact Medium -Risk Low -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
