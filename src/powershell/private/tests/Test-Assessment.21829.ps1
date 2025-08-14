<#
.SYNOPSIS

#>

function Test-Assessment-21829{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Use cloud authentication"
    Write-ZtProgress -Activity $activity
    $domains = Invoke-ZtGraphRequest -RelativeUri "domains" -ApiVersion v1.0
    $result = $domains | Where-Object { $_.authenticationType -eq 'Federated' }
    $manageddomains = $domains | Where-Object { $_.authenticationType -eq 'Managed' }
    $passed = $result.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "All domains are using cloud authentication.`n`n"
    }
    else {
        $testResultMarkdown = "Federated authentication is in use.`n`n%TestResult%"
    }
    if ($result.Count -gt 0) {
        $mdInfo = "`n## List of federated domains`n`n"
        $mdInfo += "| Domain Name |`n"
        $mdInfo += "| :--- |`n"
        foreach ($item in $result) {
            $mdInfo += "| $($item.id) |`n"
        }
    }
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    Add-ZtTestResultDetail -TestId '21829' -Title "Use cloud authentication" `
        -UserImpact High -Risk High -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
