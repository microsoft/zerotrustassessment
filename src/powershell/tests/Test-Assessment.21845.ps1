<#
.SYNOPSIS
    Check if Temporary Access Pass is enabled and properly enforced with conditional access policies
#>

function Test-Assessment-21845{
    [ZtTest(
    	Category = 'Credential management',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21845,
    	Title = 'Temporary access pass is enabled',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if ( -not (Get-ZtLicense EntraIDP1) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return
    }

    $activity = 'Checking Temporary access pass is enabled'
    Write-ZtProgress -Activity $activity -Status 'Getting Temporary Access Pass policy'

    try {
        # Query 1: Get Temporary Access Pass authentication method configuration
        $tapConfig = Invoke-ZtGraphRequest -RelativeUri 'policies/authenticationMethodsPolicy/authenticationMethodConfigurations/temporaryAccessPass' -ApiVersion beta

        # Check if TAP is disabled - if so, fail immediately
        if ($tapConfig.state -ne 'enabled') {
            $passed = $false
            $testResultMarkdown = '❌ Temporary Access Pass is disabled in the tenant.'
        }
        else {
            Write-ZtProgress -Activity $activity -Status 'Getting conditional access policies'

            # Query 2: Get all enabled conditional access policies
            $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -Filter "state eq 'enabled'" -ApiVersion 'v1.0'

            # Find policies targeting security information registration
            $securityInfoPolicies = $allCAPolicies | Where-Object {
                $_.conditions.applications.includeUserActions -contains 'urn:user:registersecurityinfo' -and
                $_.grantControls.authenticationStrength -ne $null
            }

            Write-ZtProgress -Activity $activity -Status 'Getting authentication strength policies'

            # Query 3: Get authentication strength policies
            $authStrengthPolicies = Invoke-ZtGraphRequest -RelativeUri 'policies/authenticationStrengthPolicies' -Select 'id,displayName,description,policyType,allowedCombinations' -ApiVersion 'v1.0'

            # Check TAP configuration and conditional access enforcement
            $tapEnabled = $tapConfig.state -eq 'enabled'
            $targetsAllUsers = $tapConfig.includeTargets | Where-Object { $_.id -eq 'all_users' }
            $hasConditionalAccessEnforcement = ($securityInfoPolicies | Measure-Object).Count -gt 0

            # Check if authentication strength policies include TAP
            $tapSupportedInAuthStrength = $false
            $authStrengthWithTap = @()

            if ($hasConditionalAccessEnforcement) {
                # Get auth strength policies referenced in CA policies
                $referencedAuthStrengthIds = $securityInfoPolicies.grantControls.authenticationStrength.id | Select-Object -Unique
                $referencedAuthStrengthPolicies = $authStrengthPolicies | Where-Object { $_.id -in $referencedAuthStrengthIds }

                # Check if any referenced auth strength policies support TAP
                foreach ($policy in $referencedAuthStrengthPolicies) {
                    $tapCombinations = $policy.allowedCombinations | Where-Object { $_ -like '*temporaryAccessPass*' }
                    if ($tapCombinations) {
                        $tapSupportedInAuthStrength = $true
                        $authStrengthWithTap += $policy
                    }
                }
            }

        # Determine pass/fail status based on specification
        if ($tapEnabled -and $targetsAllUsers -and $hasConditionalAccessEnforcement -and $tapSupportedInAuthStrength) {
            $passed = $true
            $testResultMarkdown = 'Temporary Access Pass is enabled, targeting all users, and enforced with conditional access policies.'
        }
        elseif ($tapEnabled -and $targetsAllUsers -and $hasConditionalAccessEnforcement -and -not $tapSupportedInAuthStrength) {
            $passed = $false
            $testResultMarkdown = 'Temporary Access Pass is enabled but authentication strength policies don''t include TAP methods.'
        }
        elseif ($tapEnabled -and $targetsAllUsers -and -not $hasConditionalAccessEnforcement) {
            $passed = $false
            $testResultMarkdown = 'Temporary Access Pass is enabled but no conditional access enforcement for security info registration found. Consider adding conditional access policies for stronger security.'
        }
        else {
            $passed = $false
            $testResultMarkdown = 'Temporary Access Pass is not properly configured or does not target all users.'
        }
    }

    $testResultMarkdown += "`n`n**Configuration summary**`n`n"

    # Temporary Access Pass status
    $tapStatus = if ($tapConfig.state -eq 'enabled') { 'Enabled ✅' } else { 'Disabled ❌' }
    $testResultMarkdown += "[Temporary Access Pass](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AdminAuthMethods/fromNav/Identity): $tapStatus`n`n"

    # Conditional Access policy for Security info registration
    $caStatus = if ($hasConditionalAccessEnforcement) { 'Enabled ✅' } else { 'Not enabled ❌' }
    $testResultMarkdown += "[Conditional Access policy for Security info registration](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies/fromNav/Identity): $caStatus`n`n"

    # Authentication strength policy for Temporary Access Pass
    $authStrengthStatus = if ($tapSupportedInAuthStrength) { 'Enabled ✅' } else { 'Not enabled ❌' }
    $testResultMarkdown += "[Authentication strength policy for Temporary Access Pass](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/AuthenticationStrength.ReactView/fromNav/Identity): $authStrengthStatus`n"
}
    catch {
        $passed = $false
        $testResultMarkdown = "❌ Error querying Temporary Access Pass configuration: $($_.Exception.Message)"
    }

    $params = @{
        TestId             = '21845'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
