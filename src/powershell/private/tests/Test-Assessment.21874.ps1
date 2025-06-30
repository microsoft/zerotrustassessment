<#
.SYNOPSIS

#>

function Test-Assessment-21874 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Allow/Deny lists of domains to restrict external collaboration are configured"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $policies = Invoke-ZtGraphRequest -RelativeUri 'legacy/policies' -ApiVersion beta -DisableCache

    foreach ($policy in $policies) {
        if ( $policy.definition -and ($null -ne ($policy.definition | ConvertFrom-Json).B2BManagementPolicy.InvitationsAllowedAndBlockedDomainsPolicy.AllowedDomains) ) {
            $passed = $true
            $testResultMarkdown = "Allow/Deny lists of domains to restrict external collaboration are configured."
            break
        }
        else {
            $passed = $false
            $testResultMarkdown = "Allow/Deny lists of domains to restrict external collaboration are not configured."
        }
    }

    $params = @{
        TestId             = '21874'
        Title              = "Allow/Deny lists of domains to restrict external collaboration are configured"
        UserImpact         = 'Medium'
        Risk               = 'Medium'
        ImplementationCost = 'Medium'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
