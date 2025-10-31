<#
.SYNOPSIS
Checks that all users are required to use phishing-resistant authentication methods through Conditional Access policies.

Pass/Fail Hook:
- Test checks for enabled Conditional Access policies that apply to all users
- Policies must require authentication strength with phishing-resistant methods
- Passes if such policies exist without significant user exclusions
- Fails if no policies found or policies have coverage gaps due to exclusions
#>

function Test-Assessment-21784 {
    [ZtTest(
        Category = 'Access control',
        ImplementationCost = 'Medium',
        Pillar = 'Identity',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce', 'External'),
        TestId = 21784,
        Title = 'All user sign in activity uses phishing-resistant authentication methods',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    # Helper function to render policy table
    function Get-PolicyTable {
        param(
            [array]$Policies,
            [array]$PhishingResistantPolicies,
            [string]$TableTitle,
            [switch]$ShowIssues
        )

        if (-not $Policies -or $Policies.Count -eq 0) {
            return ""
        }

        $tableMarkdown = "## $TableTitle`n`n"
        $tableMarkdown += "| Policy | Authentication strength | Included Users | Excluded Users |`n"
        $tableMarkdown += "| :---------- | :---------------------- | :------------- | :------------- |`n"

        foreach ($policy in $Policies) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"
            $authStrengthLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/menuId//fromNav/Identity"

            # Get authentication strength name
            $strengthPolicy = $PhishingResistantPolicies | Where-Object { $_.id -eq $policy.grantControls.authenticationStrength.id }
            $authStrengthName = if ($strengthPolicy) {
                "[$(Get-SafeMarkdown($strengthPolicy.displayName))]($authStrengthLink)"
            }
            else {
                "None"
            }

            # Format included users
            $includedUsers = if ($policy.conditions.users.includeUsers -contains 'All') {
                "All Users"
            }
            elseif ($policy.conditions.users.includeUsers.Count -gt 0) {
                "$($policy.conditions.users.includeUsers.Count) users"
            }
            else {
                "None"
            }

            # Format excluded users with warning if showing issues
            $excludedUsers = if ($policy.conditions.users.excludeUsers.Count -gt 0) {
                if ($ShowIssues) {
                    "⚠️ $($policy.conditions.users.excludeUsers.Count) users"
                }
                else {
                    "$($policy.conditions.users.excludeUsers.Count) users"
                }
            }
            else {
                "None"
            }

            $tableMarkdown += "| [$(Get-SafeMarkdown($policy.displayName))]($portalLink) | $authStrengthName | $includedUsers | $excludedUsers |`n"
        }
        $tableMarkdown += "`n"
        return $tableMarkdown
    }

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking phishing-resistant authentication methods'

    # Get enabled Conditional Access policies
    $policies = @()

    Write-ZtProgress -Activity $activity -Status 'Getting policies'
    $enabledPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -Filter "state eq 'enabled'" -ApiVersion beta
    $policies = $enabledPolicies

    # Get authentication strength policies
    $strengthPolicies = @()
    $authStrengthPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/authenticationStrength/policies' -ApiVersion beta
    $strengthPolicies = $authStrengthPolicies

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
        # Add policy details using helper function
        if ($relevantPolicies) {
            $testResultMarkdown += Get-PolicyTable -Policies $relevantPolicies -PhishingResistantPolicies $phishingResistantPolicies -TableTitle 'Conditional Access Policies with Phishing-Resistant Authentication'
        }
    }
    else {
        $failReason = if (-not $relevantPolicies) {
            'No Conditional Access policies found that require phishing-resistant authentication for all users'
        }
        else {
            'Found policies with user exclusions that create coverage gaps'
        }

        $testResultMarkdown = @"
❌ Not all users are protected by Conditional Access policies requiring phishing-resistant authentication methods.

**Reason**: $failReason

"@
        # Add policy details even for failures
        if ($relevantPolicies) {
            $testResultMarkdown += Get-PolicyTable -Policies $relevantPolicies -PhishingResistantPolicies $phishingResistantPolicies -TableTitle "Conditional Access Policies with Phishing-Resistant Authentication (Issues Found)" -ShowIssues
        }
        else {
            # Show available authentication strength policies even if none are applied to all users
            if ($phishingResistantPolicies) {
                $testResultMarkdown += "## Available Authentication Strength Policies`n`n"
                $testResultMarkdown += "| Authentication Strength Policy | Allowed Methods |`n"
                $testResultMarkdown += "| :----------------------------- | :-------------- |`n"

                foreach ($strengthPolicy in $phishingResistantPolicies) {
                    $allowedMethods = $strengthPolicy.allowedCombinations -join ', '
                    $testResultMarkdown += "| $($strengthPolicy.displayName) | $allowedMethods |`n"
                }
                $testResultMarkdown += "`n*Note: These authentication strength policies exist but are not applied to all users via Conditional Access.*`n`n"
            }
        }
    }
    $passed = $result

    $params = @{
        TestId = '21784'
        Status = $passed
        Result = $testResultMarkdown

    }
    Add-ZtTestResultDetail @params
    Write-PSFMessage '🟦 End' -Tag Test -Level VeryVerbose

}
