<#
.SYNOPSIS
    Checking App registrations must not have reply URLs containing *.azurewebsites.net
#>

function Test-Assessment-21885 {
    [CmdletBinding()]
    param($Database)

    # NOTE: This test is very similar to
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking app registrations use safe redirect URIs "
    Write-ZtProgress -Activity $activity -Status "Getting policy"


    $results = Get-ZtAppWithUnsafeRedirectUris -Database $Database -Type 'Application'

    Write-Host "Results"
    Write-Host ($results | ConvertTo-Json -Depth 10)

    $passed = $results.Passed
    $testResultMarkdown = $results.TestResultMarkdown


    Add-ZtTestResultDetail -TestId '21885' -Title "App registrations use safe redirect URIs" `
        -UserImpact Low -Risk High -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
