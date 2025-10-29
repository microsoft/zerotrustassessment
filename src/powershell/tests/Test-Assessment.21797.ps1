<#
.SYNOPSIS
    Checks if policies to restrict access to high risk users are implemented correctly.
#>

function Test-Assessment-21797{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Accelerate response and remediation',
    	TenantType = ('Workforce','External'),
    	TestId = 21797,
    	Title = 'Restrict access to high risk users',
    	UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Restrict access to high risk users"
    Write-ZtProgress -Activity $activity -Status "Getting policies"

    # Query 1: Authentication methods policy for passwordless authentication methods
    $authMethodsPolicy = Invoke-ZtGraphRequest -RelativeUri "policies/authenticationMethodsPolicy" -ApiVersion 'v1.0'

    # Query for all CA policies instead of multiple filtered queries
    Write-ZtProgress -Activity $activity -Status "Getting conditional access policies"
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -ApiVersion 'v1.0'

    # Local filtering for password change policies - only consider enabled policies
    $caPasswordChangePolicies = $allCAPolicies | Where-Object {
        $_.conditions.userRiskLevels -contains "high" -and
        $_.grantControls.builtInControls -contains "passwordChange" -and
        $_.state -eq "enabled"
    }

    # Local filtering for block policies - only consider enabled policies
    $caBlockPolicies = $allCAPolicies | Where-Object {
        $_.conditions.userRiskLevels -contains "high" -and
        $_.grantControls.builtInControls -contains "block" -and
        $_.state -eq "enabled"
    }

    # Collect report-only or disabled policies for reporting
    $inactiveCAPolicies = $allCAPolicies | Where-Object {
        $_.conditions.userRiskLevels -contains "high" -and
        ($_.grantControls.builtInControls -contains "passwordChange" -or $_.grantControls.builtInControls -contains "block") -and
        $_.state -ne "enabled"
    }

    # Check if passwordless authentication methods are enabled
    $passwordlessEnabled = $false
    $passwordlessAuthMethods = @()

    if ($authMethodsPolicy.authenticationMethodConfigurations) {
        foreach ($method in $authMethodsPolicy.authenticationMethodConfigurations) {
            # Check if it's one of the passwordless methods
            $isPasswordless = $false
            $methodName = $method.id
            $methodState = $method.state
            $additionalInfo = ""

            # Check for standard passwordless methods
            if ($method.id -in @("fido2")) {
                $isPasswordless = ($method.state -eq "enabled")
            }

            # Special case for X509Certificate - only passwordless if it's multifactor
            if ($method.id -eq "x509Certificate") {
                if ($method.state -eq "enabled" -and $method.x509CertificateAuthenticationDefaultMode -eq "x509CertificateMultiFactor") {
                    $isPasswordless = $true
                    $additionalInfo = " (Mode: x509CertificateMultiFactor)"
                }
            }

            if ($isPasswordless) {
                $passwordlessEnabled = $true
                $passwordlessAuthMethods += [PSCustomObject]@{
                    Name = $methodName
                    State = $methodState
                    AdditionalInfo = $additionalInfo
                }
            }
        }
    }

    # Determine pass/fail based on the given criteria
    $result = $false
    if ((-not $passwordlessEnabled -and ($caPasswordChangePolicies.Count + $caBlockPolicies.Count -gt 0)) -or
        ($passwordlessEnabled -and $caBlockPolicies.Count -gt 0)) {
        $result = $true
    }

    # Prepare the markdown output, starting with the main check result
    $testResultMarkdown = ""

    if ($result) {
        $testResultMarkdown += "Policies to restrict access for high risk users are properly implemented.%TestResult%"
    }
    else {
        if ($passwordlessEnabled -and $caBlockPolicies.Count -eq 0) {
            $testResultMarkdown += "Passwordless authentication is enabled, but no policies to block high risk users are configured.%TestResult%"
        } else {
            $testResultMarkdown += "No policies found to protect against high risk users.%TestResult%"
        }
    }

    # Build the detailed sections of the markdown
    $mdInfo = ""

    # Include passwordless methods information
    $mdInfo += "`n## Passwordless Authentication Methods allowed in tenant`n`n"

    if ($passwordlessAuthMethods.Count -gt 0) {
        $mdInfo += "| Authentication Method Name | State | Additional Info |`n"
        $mdInfo += "| :------------------------ | :---- | :-------------- |`n"
        foreach ($method in $passwordlessAuthMethods) {
            $mdInfo += "| $($method.Name) | $($method.State) | $($method.AdditionalInfo) |`n"
        }
    } else {
        $mdInfo += "No passwordless authentication methods are enabled.`n"
    }

    # Include CA policies information
    $mdInfo += "`n## Conditional Access Policies targeting high risk users`n`n"

    $allEnabledHighRiskPolicies = @($caPasswordChangePolicies) + @($caBlockPolicies)

    if ($allEnabledHighRiskPolicies.Count -gt 0) {
        $mdInfo += "| Conditional Access Policy Name | Status | Conditions |`n"
        $mdInfo += "| :--------------------- | :----- | :--------- |`n"

        foreach ($policy in $allEnabledHighRiskPolicies) {
            $conditions = "User Risk Level: High"
            if ($policy.grantControls.builtInControls -contains "passwordChange") {
                $conditions += ", Control: Password Change"
            }
            if ($policy.grantControls.builtInControls -contains "block") {
                $conditions += ", Control: Block"
            }
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}" -f $policy.id
            $mdInfo += "| [$(Get-SafeMarkdown($policy.displayName))]($portalLink) | Enabled | $conditions |`n"
        }
    }

    # Include inactive policies if any
    if ($inactiveCAPolicies.Count -gt 0) {
        if ($allEnabledHighRiskPolicies.Count -eq 0) {
            $mdInfo += "No conditional access policies targeting high risk users found.`n`n"
            $mdInfo += "### Inactive policies targeting high risk users (not contributing to security posture):`n`n"
            $mdInfo += "| Conditional Access Policy Name | Status | Conditions |`n"
            $mdInfo += "| :--------------------- | :----- | :--------- |`n"
        }

        foreach ($policy in $inactiveCAPolicies) {
            $conditions = "User Risk Level: High"
            if ($policy.grantControls.builtInControls -contains "passwordChange") {
                $conditions += ", Control: Password Change"
            }
            if ($policy.grantControls.builtInControls -contains "block") {
                $conditions += ", Control: Block"
            }
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}" -f $policy.id
            $status = if ($policy.state -eq "enabledForReportingButNotEnforced") { "Report-only" } else { "Disabled" }
            $mdInfo += "| [$(Get-SafeMarkdown($policy.displayName))]($portalLink) | $status | $conditions |`n"
        }
    } elseif ($allEnabledHighRiskPolicies.Count -eq 0) {
        $mdInfo += "No conditional access policies targeting high risk users found.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo


    $passed = $result

    Add-ZtTestResultDetail -TestId '21797' -Title "Restrict access to high risk users" `
        -UserImpact High -Risk High -ImplementationCost Medium `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
