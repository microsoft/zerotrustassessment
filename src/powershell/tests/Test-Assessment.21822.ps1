<#
.SYNOPSIS
    Checks if domain-based allow/deny lists is configured
#>

function Test-Assessment-21822 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Guest access is limited to approved tenants"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = Invoke-ZtGraphRequest -RelativeUri "legacy/policies" -ApiVersion beta
    $b2BManagementPolicyDefinition = ($result | Where-Object -FilterScript {$_.Type -eq "B2BManagementPolicy"}).definition
    $b2BManagementPolicy = ( $b2BManagementPolicyDefinition | ConvertFrom-Json).B2BManagementPolicy
    $allowedDomains = $b2BManagementPolicy.InvitationsAllowedAndBlockedDomainsPolicy.AllowedDomains

    $passed = $allowedDomains.Count -gt 0
    if ($passed) {
        $testResultMarkdown = "Guest access is limited to approved tenants ✅"
    }
    else {
        $testResultMarkdown = "Guest access is note limited to approved tenants ❌"
    }

    Add-ZtTestResultDetail -TestId '21822' -Title "Guest access is limited to approved tenants" `
        -UserImpact Medium -Risk Medium -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
