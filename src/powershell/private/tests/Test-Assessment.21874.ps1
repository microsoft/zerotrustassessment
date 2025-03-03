<#
.SYNOPSIS

#>

function Test-Assessment-21874{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Tenant does have controls to selectively onboard external organizations (cross-tenant access polices and domain-based allow/deny lists)"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21874' -Title "Tenant does have controls to selectively onboard external organizations (cross-tenant access polices and domain-based allow/deny lists)" `
        -UserImpact Medium -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
