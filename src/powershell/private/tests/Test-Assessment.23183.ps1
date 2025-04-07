<#
.SYNOPSIS
    Checking App registrations must not have reply URLs containing *.azurewebsites.net
#>

function Test-Assessment-23183 {
    [CmdletBinding()]
    param($Database)

    # NOTE: This test is very similar to
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking service principals use safe redirect URIs "
    Write-ZtProgress -Activity $activity -Status "Getting policy"


    $results = Get-ZtAppWithUnsafeRedirectUris -Database $Database -Type 'ServicePrincipal'

    $passed = $results.Passed
    $testResultMarkdown = $results.TestResultMarkdown

    Add-ZtTestResultDetail -TestId '23183' -Title "Service principals use safe redirect URIs" `
        -UserImpact Low -Risk High -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
