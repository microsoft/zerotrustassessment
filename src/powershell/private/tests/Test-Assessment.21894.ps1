<#
.SYNOPSIS

#>

function Test-Assessment-21894{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking All certificates Microsoft Entra Application Registrations and Service Principals must be issued by an approved certification authority"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Under construction."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21894' -Title "All certificates Microsoft Entra Application Registrations and Service Principals must be issued by an approved certification authority" `
        -UserImpact Low -Risk Low -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
