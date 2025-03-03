<#
.SYNOPSIS

#>

function Test-Assessment-21899{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking All privileged role assignments have a recipient that can receive notifications"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '21899' -Title "All privileged role assignments have a recipient that can receive notifications" `
        -UserImpact Low -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
