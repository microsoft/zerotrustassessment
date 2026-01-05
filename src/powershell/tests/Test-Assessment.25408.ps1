<#
.SYNOPSIS
    Checks that Global Secure Access web content filtering is enabled and configured
.DESCRIPTION
    Verifies that Web Content Filtering policies are configured and applied either through the Baseline Profile
    or through Security Profiles linked to active Conditional Access policies. This ensures that organizations
    control access to websites based on categories, domains, or URLs to reduce exposure to malicious or
    inappropriate content.

.NOTES
    Test ID: 25408
    Category: Global Secure Access
    Required API: networkAccess/filteringPolicies, networkAccess/filteringProfiles, conditionalAccess/policies
#>

function Test-Assessment-25408 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce','External'),
        TestId = '25408',
        Title = 'Global Secure Access web content filtering is enabled and configured',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Global Secure Access web content filtering configuration'
    Write-ZtProgress -Activity $activity -Status 'Querying Web Content Filtering policies'

    # Q1: Get all Web Content Filtering policies (excluding "All Websites")
    $allFilteringPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringPolicies' -ApiVersion beta
    $wcfPolicies = $allFilteringPolicies | Where-Object { $_.name -ne 'All websites' }

    Write-ZtProgress -Activity $activity -Status 'Querying filtering profiles'

    # Q2: Get all filtering profiles with their policies and priority
    $securitySettings = Invoke-ZtGraphRequest -RelativeUri "networkAccess/filteringProfiles?`$select=id,name,description,state,version,priority&`$expand=policies(`$select=id,state;`$expand=policy(`$select=id,name,version))" -ApiVersion beta

    Write-ZtProgress -Activity $activity -Status 'Querying Conditional Access policies'

    # Q3 prep: Get all Conditional Access policies with session controls
    $caPolicies = Get-ZtConditionalAccessPolicy
    #endregion Data Collection

    #region Assessment Logic
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null
    $appliedPolicies = @()

    # Check if any Web Content Filtering policies exist (excluding "All Websites")
    if (-not $wcfPolicies -or $wcfPolicies.Count -eq 0) {
        $testResultMarkdown = '❌ No Web Content Filtering policies are configured in the tenant. Organizations should configure web content filtering to control access to websites based on categories, domains, or URLs.'
        $passed = $false
    }
    else {
        # Check if WCF policies are linked to profiles
        foreach ($wcfPolicy in $wcfPolicies) {
            $policyId = $wcfPolicy.id
            $policyName = $wcfPolicy.name
            $policyAction = $wcfPolicy.action

            # Find profiles that have this policy linked
            $linkedSettings = @()

            foreach ($securityItem in $securitySettings) {
                # Check if this profile contains the WCF policy
                $policyLink = $securityItem.policies | Where-Object {
                    $_.'@odata.type' -eq '#microsoft.graph.networkaccess.filteringPolicyLink' -and
                    $_.policy.id -eq $policyId -and
                    $_.state -eq 'enabled'
                }

                if ($policyLink) {
                    # Determine profile type based on priority
                    $itemType = if ($securityItem.priority -eq 65000) { 'Baseline Profile' } else { 'Security Profile' }

                    $itemInfo = [PSCustomObject]@{
                        ProfileId       = $securityItem.id
                        ProfileName     = $securityItem.name
                        ProfileType     = $itemType
                        ProfileState    = $securityItem.state
                        ProfilePriority = $securityItem.priority
                        PolicyLinkState = $policyLink.state
                        IsApplied       = $false
                        CAPolicy        = $null
                    }

                    # If Baseline Profile and enabled, it's automatically applied
                    if ($itemType -eq 'Baseline Profile' -and $securityItem.state -eq 'enabled') {
                        $itemInfo.IsApplied = $true
                    }
                    # If Security Profile, check if it's linked to an active CA policy
                    elseif ($itemType -eq 'Security Profile' -and $securityItem.state -eq 'enabled') {
                        # Step 4: Check for Conditional Access policy linkage
                        $linkedCAPolicies = $caPolicies | Where-Object {
                            $_.state -eq 'enabled' -and
                            $null -ne $_.sessionControls.globalSecureAccessFilteringProfile -and
                            $_.sessionControls.globalSecureAccessFilteringProfile.profileId -eq $securityItem.id -and
                            $_.sessionControls.globalSecureAccessFilteringProfile.isEnabled -eq $true
                        }

                        if ($linkedCAPolicies) {
                            $itemInfo.IsApplied = $true
                            $itemInfo.CAPolicy = $linkedCAPolicies
                        }
                    }

                    $linkedSettings += $itemInfo
                }
            }

            # If this policy is applied through at least one profile, add it to applied policies
            if ($linkedSettings | Where-Object { $_.IsApplied -eq $true }) {
                $appliedPolicies += [PSCustomObject]@{
                    PolicyId       = $policyId
                    PolicyName     = $policyName
                    PolicyAction   = $policyAction
                    LinkedSettings = $linkedSettings
                }
            }
        }

        # Determine pass/fail
        if ($appliedPolicies.Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "✅ Web Content Filtering policies are enabled and configured. `n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ Web Content Filtering policies exist but are not applied to any users through Baseline Profile or Security Profiles linked to Conditional Access policies. `n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyNetworkAccessMenuBlade/~/GlobalSecureAccessWebContentFiltering'
    $mdInfo = ''

    if ($wcfPolicies -and $wcfPolicies.Count -gt 0) {
        # Show all WCF policies and their application status
        $mdInfo += "## [Web Content Filtering Policies]($portalLink)`n`n"

        if ($appliedPolicies.Count -gt 0) {
            foreach ($appliedPolicy in $appliedPolicies) {
                $safePolicyName = Get-SafeMarkdown $appliedPolicy.PolicyName
                $mdInfo += "### ✅ $safePolicyName`n`n"
                $mdInfo += "**Action**: $($appliedPolicy.PolicyAction)`n`n"

                # Show profiles this policy is linked to
                $appliedItems = $appliedPolicy.LinkedSettings | Where-Object { $_.IsApplied -eq $true }

                foreach ($itemInfo in $appliedItems) {
                    $safeName = Get-SafeMarkdown $itemInfo.ProfileName
                    $itemBladeLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyNetworkAccessMenuBlade/~/GlobalSecureAccessInternetAccessProfiles"

                    $mdInfo += "#### [$safeName]($itemBladeLink) ($($itemInfo.ProfileType))`n`n"
                    $mdInfo += "| Property | Value |`n"
                    $mdInfo += "|----------|-------|`n"
                    $mdInfo += "| Profile Id | ``$($itemInfo.ProfileId)`` |`n"
                    $mdInfo += "| Priority | $($itemInfo.ProfilePriority) |`n"
                    $mdInfo += "| State | $($itemInfo.ProfileState) |`n"
                    $mdInfo += "| Policy link state | $($itemInfo.PolicyLinkState) |`n"

                    # If linked via CA policy, show CA policy details
                    if ($itemInfo.CAPolicy) {
                        $mdInfo += "`n**Applied through Conditional Access Policies:**`n`n"
                        $mdInfo += "| Policy name | State | Id |`n"
                        $mdInfo += "|-------------|-------|-----|`n"

                        foreach ($caPolicy in $itemInfo.CAPolicy) {
                            $safeCAPolicyName = Get-SafeMarkdown $caPolicy.displayName
                            $caPolicyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($caPolicy.id)"
                            $mdInfo += "| [$safeCAPolicyName]($caPolicyLink) | $($caPolicy.state) | ``$($caPolicy.id)`` |`n"
                        }
                    }
                    else {
                        $mdInfo += "`n*Applied through Baseline Profile (automatically applies to all users)*`n"
                    }

                    $mdInfo += "`n"
                }
            }
        }

        # Show unapplied policies if any
        $unappliedPolicies = $wcfPolicies | Where-Object { $_.id -notin $appliedPolicies.PolicyId }
        if ($unappliedPolicies.Count -gt 0) {
            $mdInfo += "### ❌ Policies Not Applied to Users`n`n"
            $mdInfo += "The following Web Content Filtering policies exist but are not applied through any profile:`n`n"
            $mdInfo += "| Policy name | Action | Id |`n"
            $mdInfo += "|-------------|--------|-----|`n"

            foreach ($unappliedPolicy in $unappliedPolicies) {
                $safeName = Get-SafeMarkdown $unappliedPolicy.name
                $mdInfo += "| $safeName | $($unappliedPolicy.action) | ``$($unappliedPolicy.id)`` |`n"
            }
        }
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25408'
        Title  = 'Global Secure Access web content filtering is enabled and configured'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if needed
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
