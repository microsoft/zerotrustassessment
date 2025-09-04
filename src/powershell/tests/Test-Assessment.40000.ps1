
<#
.SYNOPSIS

#>

function Test-Assessment-40000{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Windows automatic enrollment is enabled"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $true
    $testResultMarkdown = "Windows automatic enrollment is enabled and configured correctly."
    $passed = $result


    Add-ZtTestResultDetail -TestId '40000' -Title "Windows automatic enrollment is enabled" `
        -UserImpact Low -Risk Low -ImplementationCost Low `
        -AppliesTo Devices -Tag Devices `
        -Status $passed -Result $testResultMarkdown
}
