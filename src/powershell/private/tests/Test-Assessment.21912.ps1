<#
.SYNOPSIS

#>

function Test-Assessment-21912{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Azure resources used by Microsoft Entra only allow access from privileged roles"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21912' -Title "Azure resources used by Microsoft Entra only allow access from privileged roles" `
        -UserImpact Low -Risk High -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
