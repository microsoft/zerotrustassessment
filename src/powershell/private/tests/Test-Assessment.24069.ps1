<#
.SYNOPSIS
    Checks that Fraud prevention integration is enabled.
#>

function Test-Assessment-24069 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking configuration of fraud prevention integration"
    Write-ZtProgress -Activity $activity

    $result = Invoke-ZtGraphRequest -RelativeUri 'identity/riskPrevention/fraudProtectionProviders' -ApiVersion beta
    $passed = ![string]::IsNullOrEmpty($result.value) -or $result.value.Count -ne 0

    if ($passed) {
        $testResultMarkdown = "Tenant is configured for fraud prevention.`n`n%TestResult%"
    }
    elseif (!$passed) {
        $testResultMarkdown = "Tenant is not configured for fraud prevention.`n`n"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    }

    Add-ZtTestResultDetail -TestId '24069' -Title 'Fraud prevention integration configured'`
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag User, Credential `
        -Status $passed -Result $testResultMarkdown
}
