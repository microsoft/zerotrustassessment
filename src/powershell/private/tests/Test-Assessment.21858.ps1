<#
.SYNOPSIS

#>

function Test-Assessment-21858{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Inactive guest identities are removed from the tenant"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Under construction."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21858' -Title "Inactive guest identities are removed from the tenant" `
        -UserImpact Low -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
