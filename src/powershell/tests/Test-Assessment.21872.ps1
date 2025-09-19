<#
.SYNOPSIS
    Checks if MFA is required for device join and device registration using conditional access
#>

function Test-Assessment-21872 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21872,
    	Title = 'Require multifactor authentication for device join and device registration using user action',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Require multifactor authentication for device join and device registration using user action"
    Write-ZtProgress -Activity $activity -Status "Getting conditional access policies"

    # Query all Conditional Access policies
    $caps = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion 'v1.0'

    # Get device settings to check if MFA is required at device settings level
    Write-ZtProgress -Activity $activity -Status "Getting device settings"
    $deviceSettings = Invoke-ZtGraphRequest -RelativeUri "policies/deviceRegistrationPolicy" -ApiVersion 'v1.0'
    $mfaRequiredInDeviceSettings = $deviceSettings.multiFactorAuthConfiguration -eq "required"

    # Filter for enabled device registration CA policies
    $deviceRegistrationPolicies = $caps | Where-Object {
        ($_.state -eq 'enabled') -and
        ($_.conditions.applications.includeUserActions -eq "urn:user:registerdevice")
    }

    # Check each policy to see if it properly requires MFA - simplified approach
    $validPolicies = @()
    foreach ($policy in $deviceRegistrationPolicies) {
        $requiresMfa = $false

        # Check if the policy directly requires MFA
        if ($policy.grantControls.builtInControls -contains "mfa") {
            $requiresMfa = $true
        }

        # Check if the policy uses any authentication strength (all treated as MFA)
        if ($null -ne $policy.grantControls.authenticationStrength) {
            $requiresMfa = $true
        }

        # If the policy requires MFA, add it to valid policies
        if ($requiresMfa) {
            $validPolicies += $policy
        }
    }

    # Determine pass/fail conditions
    $result = $false

    # If device settings has MFA required, that's not the recommended approach
    if ($mfaRequiredInDeviceSettings) {
        $result = $false
        $testResultMarkdown = "**MFA is configured incorrectly.** Device Settings has 'Require Multi-Factor Authentication to register or join devices' set to Yes. According to best practices, this should be set to No, and MFA should be enforced through Conditional Access policies instead.%TestResult%"
    }
    # If no device registration policies exist
    elseif ($deviceRegistrationPolicies.Count -eq 0) {
        $result = $false
        $testResultMarkdown = "**No Conditional Access policies found** for device registration or device join. Create a policy that requires MFA for these user actions.%TestResult%"
    }
    # If policies exist but none are properly configured
    elseif ($validPolicies.Count -eq 0) {
        $result = $false
        $testResultMarkdown = "**Conditional Access policies found**, but they're not correctly configured. Policies should require MFA or appropriate authentication strength.%TestResult%"
    }
    # If valid policies exist
    else {
        $result = $true
        $testResultMarkdown = "**Properly configured Conditional Access policies found** that require MFA for device registration/join actions.%TestResult%"
    }

    $passed = $result

    # Build the detailed sections of the markdown
    $mdInfo = ""

    # Add device settings information
    $mdInfo += "`n## Device Settings Configuration`n`n"
    $mdInfo += "| Setting | Value | Recommended Value | Status |`n"
    $mdInfo += "| :------ | :---- | :---------------- | :----- |`n"

    $deviceSettingStatus = if ($mfaRequiredInDeviceSettings) { "❌ Should be set to No" } else { "✅ Correctly configured" }
    $deviceSettingValue = if ($mfaRequiredInDeviceSettings) { "Yes" } else { "No" }
    $mdInfo += "| Require Multi-Factor Authentication to register or join devices | $deviceSettingValue | No | $deviceSettingStatus |`n"

    # Add policies information if any found
    if ($deviceRegistrationPolicies.Count -gt 0) {
        $mdInfo += "`n## Device Registration/Join Conditional Access Policies`n`n"
        $mdInfo += "| Policy Name | State | Requires MFA | Status |`n"
        $mdInfo += "| :---------- | :---- | :----------- | :----- |`n"

        foreach ($policy in $deviceRegistrationPolicies) {
            $policyName = $policy.displayName
            $policyState = $policy.state

            $link = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}" -f $policy.id
            $policyName = "[$policyName]($link)"

            # Check if this policy is properly configured
            $isValid = $policy -in $validPolicies
            $requiresMfaText = if ($isValid) { "Yes" } else { "No" }
            $statusText = if ($isValid) { "✅ Properly configured" } else { "❌ Incorrectly configured" }

            $mdInfo += "| $policyName | $policyState | $requiresMfaText | $statusText |`n"
        }
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21872' -Title "Require multifactor authentication for device join and device registration using user action" `
        -UserImpact Medium -Risk High -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
