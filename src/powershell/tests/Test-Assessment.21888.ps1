<#
.SYNOPSIS
    Checking App registrations must not have dangling or abandoned domain redirect URIs
#>

function Test-Assessment-21888{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking App registrations must not have dangling or abandoned domain redirect URIs"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $results = Get-ZtAppWithUnsafeRedirectUris -Database $Database -Type 'Application' -DnsCheckOnly

    $passed = $results.Passed
    $testResultMarkdown = $results.TestResultMarkdown


    Add-ZtTestResultDetail -TestId '21888' -Title "App registrations must not have dangling or abandoned domain redirect URIs" `
        -UserImpact Low -Risk High -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
