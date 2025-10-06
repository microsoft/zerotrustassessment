<#
.SYNOPSIS

#>

function Test-Assessment-21784{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21784,
    	Title = 'All user sign in activity uses phishing-resistant authentication methods',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking phishing-resistant authentication methods'

    # Get enabled Conditional Access policies
    $policies = @()
    try {
        Write-ZtProgress -Activity $activity -Status 'Getting policies'
        $enabledPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -Filter "state eq 'enabled'" -ApiVersion beta
        $policies = $enabledPolicies
    }
    catch {
        Write-PSFMessage 'Failed to get CA policies' -Level Warning -ErrorRecord $_
        return $false
    }

    # Get authentication strength policies
    $strengthPolicies = @()
    try {
        $authStrengthPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/authenticationStrength/policies' -ApiVersion beta
        $strengthPolicies = $authStrengthPolicies
    }
    catch {
        Write-PSFMessage 'Failed to get auth strength policies' -Level Warning -ErrorRecord $_
        return $false
    }

    # Define phishing-resistant methods
    $phishingResistantMethods = @(
        'windowsHelloForBusiness',
        'fido2',
        'x509CertificateMultiFactor',
        'certificateBasedAuthenticationPki'
    )

    # Find policies with phishing-resistant methods
    $phishingResistantPolicies = $strengthPolicies | Where-Object {
        $_.allowedCombinations | Where-Object { $phishingResistantMethods -contains $_ }
    }

    if (-not $phishingResistantPolicies) {
        Write-PSFMessage 'No phishing-resistant auth policies found' -Level Warning
        return $false
    }

    # Find policies that apply to all users
    $relevantPolicies = $policies | Where-Object {
        ($_.conditions.users.includeUsers -contains 'All') -and
        ($_.grantControls.authenticationStrength.id -in $phishingResistantPolicies.id)
    }

    $result = $false
    $details = [System.Collections.ArrayList]::new()

    if ($relevantPolicies) {
        foreach ($policy in $relevantPolicies) {
            [void]$details.Add("Policy: $($policy.displayName)")
            [void]$details.Add("- ID: $($policy.id)")
            [void]$details.Add("- Authentication Strength: $($policy.grantControls.authenticationStrength.id)")
            if ($policy.conditions.users.excludeUsers.Count -gt 0) {
                [void]$details.Add("- Excluded Users: $($policy.conditions.users.excludeUsers -join ', ')")
            }
            [void]$details.Add("")
        }

        # Check for coverage gaps due to exclusions
        $hasSignificantExclusions = $relevantPolicies | Where-Object {
            $_.conditions.users.excludeUsers.Count -gt 0
        }

        $result = -not $hasSignificantExclusions
    }

    $testResultMarkdown = ''
    if ($result) {
        $testResultMarkdown = @"
✅ All users are protected by Conditional Access policies requiring phishing-resistant authentication methods.

"@
    } else {
        $failReason = if (-not $relevantPolicies) {
            'No Conditional Access policies found that require phishing-resistant authentication for all users'
        } else {
            'Found policies with user exclusions that create coverage gaps'
        }

        $testResultMarkdown = @"
❌ Not all users are protected by Conditional Access policies requiring phishing-resistant authentication methods.

**Reason**: $failReason

"@
    }
        $passed = $result

        $params = @{
        TestId             = '21784'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
    $passed = $result
    Write-PSFMessage '🟦 End' -Tag Test -Level VeryVerbose

}
