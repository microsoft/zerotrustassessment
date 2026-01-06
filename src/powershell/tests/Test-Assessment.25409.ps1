<#
.SYNOPSIS
    Validates that web content filtering policies based on website categories are configured in Global Secure Access.

.DESCRIPTION
    This test checks if web content filtering policies using website categories (webCategory ruleType) are configured
    and applied either through the Baseline Profile or through security profiles linked to active Conditional Access policies.

.NOTES
    Test ID: 25409
    Category: Global Secure Access
    Required API: networkAccess/filteringProfiles, networkAccess/filteringPolicies, conditionalAccess/policies (beta)
#>

function Test-Assessment-25409 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 25409,
        Title = 'Global Secure Access Web content filtering controls internet access based on website categories',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage 'Start GSA Web Content Filtering evaluation (webCategory rules)' -Tag Test -Level VeryVerbose

    $activity = 'Checking Web Content Filtering Policies'
    Write-ZtProgress -Activity $activity -Status 'Getting filtering profiles'

    # Q1: Retrieve all filtering profiles with their linked policies including nested policy details
    # Note: Using QueryParameters hashtable to properly handle nested OData expansion
    $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{
        '$select' = 'id,name,priority'
        '$expand' = 'policies($select=id,state;$expand=policy($select=id,name,version))'
    } -ApiVersion beta

    # Check if any profiles exist
    if (-not $filteringProfiles -or $filteringProfiles.Count -eq 0) {
        Write-PSFMessage 'No filtering profiles found. Skipping test.' -Tag GSA -Level Verbose

        $params = @{
            TestId = '25409'
            Title  = 'Web content filtering with website categories is configured'
            Status = $false
            Result = "❌ No filtering profiles are configured in Global Secure Access."
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Initialize collections
    $baselineProfilePolicies = @()
    $securityProfilePolicies = @()
    $allPoliciesWithWebCategory = @()

    # Separate baseline and security profiles based on priority
    # Priority 65000 = Baseline Profile, Priority < 65000 = Security Profile
    $baselineProfile = $filteringProfiles | Where-Object { $_.priority -eq 65000 }
    $securityProfiles = $filteringProfiles | Where-Object { $_.priority -lt 65000 }

    Write-ZtProgress -Activity $activity -Status 'Checking baseline profile policies'

    # Extract filtering policy links from baseline profile
    if ($baselineProfile -and $baselineProfile.policies) {
        $baselineProfilePolicies = $baselineProfile.policies | Where-Object {
            $_.'@odata.type' -eq '#microsoft.graph.networkaccess.filteringPolicyLink'
        }
    }

    # Extract filtering policy links from security profiles
    foreach ($profile in $securityProfiles) {
        if ($profile.policies) {
            $policyLinks = $profile.policies | Where-Object {
                $_.'@odata.type' -eq '#microsoft.graph.networkaccess.filteringPolicyLink'
            }
            foreach ($link in $policyLinks) {
                $securityProfilePolicies += [PSCustomObject]@{
                    ProfileId   = $profile.id
                    ProfileName = $profile.name
                    PolicyLink  = $link
                }
            }
        }
    }

    Write-ZtProgress -Activity $activity -Status 'Checking baseline profile policy rules'

    # Q2: Check baseline profile policies for webCategory rules
    $baselineHasWebCategory = $false
    foreach ($policyLink in $baselineProfilePolicies) {
        # Skip "All websites" default policy
        if ($policyLink.policy.name -eq 'All websites') {
            continue
        }

        # Get policy details with rules using the policy ID (per spec Q2)
        $policyId = $policyLink.policy.id
        $policyDetails = Invoke-ZtGraphRequest -RelativeUri "networkAccess/filteringPolicies/$policyId`?`$select=id,name,version&`$expand=policyRules" -ApiVersion beta

        $webCategoryRules = $policyDetails.policyRules | Where-Object { $_.ruleType -eq 'webCategory' }

        if ($webCategoryRules) {
            $baselineHasWebCategory = $true
            foreach ($rule in $webCategoryRules) {
                $allPoliciesWithWebCategory += [PSCustomObject]@{
                    ProfileType      = 'Baseline'
                    ProfileName      = 'Baseline Profile'
                    ProfileId        = $baselineProfile.id
                    PolicyName       = $policyDetails.name
                    PolicyId         = $policyDetails.id
                    RuleName         = $rule.name
                    RuleId           = $rule.id
                    WebCategories    = ($rule.destinations | ForEach-Object { $_.displayName }) -join ', '
                    State            = $policyLink.state
                    CALinked         = 'N/A'
                    CAPolicyName     = 'N/A'
                    CAPolicyState    = 'N/A'
                }
            }
        }
    }

    Write-ZtProgress -Activity $activity -Status 'Checking security profile policy rules'

    # Q3: Check security profile policies for webCategory rules
    $securityProfilesWithWebCategory = @()
    foreach ($profilePolicy in $securityProfilePolicies) {
        # Skip "All websites" default policy
        if ($profilePolicy.PolicyLink.policy.name -eq 'All websites') {
            continue
        }

        # Get policy details with rules using the policy ID (per spec Q3)
        $policyId = $profilePolicy.PolicyLink.policy.id
        $policyDetails = Invoke-ZtGraphRequest -RelativeUri "networkAccess/filteringPolicies/$policyId`?`$select=id,name,version&`$expand=policyRules" -ApiVersion beta

        $webCategoryRules = $policyDetails.policyRules | Where-Object { $_.ruleType -eq 'webCategory' }

        if ($webCategoryRules) {
            $securityProfilesWithWebCategory += [PSCustomObject]@{
                ProfileId       = $profilePolicy.ProfileId
                ProfileName     = $profilePolicy.ProfileName
                PolicyId        = $policyId
                PolicyName      = $policyDetails.name
                PolicyLinkState = $profilePolicy.PolicyLink.state
                Rules           = $webCategoryRules
            }
        }
    }

    # Q4: Check CA linkage for security profiles with webCategory rules
    $caLinkedSecurityProfiles = @()
    if ($securityProfilesWithWebCategory.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Checking Conditional Access linkages'

        $caPolicies = Get-ZtConditionalAccessPolicy
        $enabledCAPolicies = $caPolicies | Where-Object { $_.state -eq 'enabled' -and $null -ne $_.sessionControls.globalSecureAccessFilteringProfile }

        foreach ($profile in $securityProfilesWithWebCategory) {
            $linkedCAPolicy = $enabledCAPolicies | Where-Object {
                $_.sessionControls.globalSecureAccessFilteringProfile.profileId -eq $profile.ProfileId -and
                $_.sessionControls.globalSecureAccessFilteringProfile.isEnabled -eq $true
            }

            if ($linkedCAPolicy) {
                $caLinkedSecurityProfiles += $profile
            }

            # Add to results regardless of CA linkage (for reporting)
            foreach ($rule in $profile.Rules) {
                $allPoliciesWithWebCategory += [PSCustomObject]@{
                    ProfileType      = 'Security'
                    ProfileName      = $profile.ProfileName
                    ProfileId        = $profile.ProfileId
                    PolicyName       = $profile.PolicyName
                    PolicyId         = $profile.PolicyId
                    RuleName         = $rule.name
                    RuleId           = $rule.id
                    WebCategories    = ($rule.destinations | ForEach-Object { $_.displayName }) -join ', '
                    State            = $profile.PolicyLinkState
                    LinkedCAPolicy   = $linkedCAPolicy
                }
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    # Pass if webCategory rules exist in baseline OR in CA-linked security profiles
    $passed = $baselineHasWebCategory -or ($caLinkedSecurityProfiles.Count -gt 0)
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''

    if ($passed) {
        $testResultMarkdown = "✅ Web content filtering with web category controls is configured and applied through either the Baseline Profile or a security profile linked to an active Conditional Access policy.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No policies using web category filtering were found in the Baseline Profile or in security profiles linked to active Conditional Access policies. Web content filtering with web category controls is NOT configured in your tenant.`n`n%TestResult%"
    }

    # Build detailed markdown information
    $mdInfo = ''

    if ($allPoliciesWithWebCategory.Count -gt 0) {
        $mdInfo += "`n## Filtering Policies with Web Category Rules`n`n"
        $mdInfo += "| Profile type | Profile name | Policy name | Rule name | Web categories | State |`n"
        $mdInfo += "| :----------- | :----------- | :---------- | :-------- | :------------- | :---- |`n"

        foreach ($item in ($allPoliciesWithWebCategory | Sort-Object ProfileType, ProfileName)) {
            $stateIcon = if ($item.State -eq 'enabled') { '✅ Enabled' } else { '❌ Disabled' }

            $mdInfo += "| $($item.ProfileType) | $(Get-SafeMarkdown $item.ProfileName) | $(Get-SafeMarkdown $item.PolicyName) | $(Get-SafeMarkdown $item.RuleName) | $(Get-SafeMarkdown $item.WebCategories) | $stateIcon |`n"
        }

        # Add CA linkage details if security profiles are involved
        $securityProfiles = $allPoliciesWithWebCategory | Where-Object { $_.ProfileType -eq 'Security' } | Select-Object -ExpandProperty ProfileName -Unique
        if ($securityProfiles.Count -gt 0) {
            $mdInfo += "`n## Conditional Access Linkages`n`n"

            $caLinkedPolicies = $allPoliciesWithWebCategory | Where-Object { $_.ProfileType -eq 'Security' -and $null -ne $_.LinkedCAPolicy }
            if ($caLinkedPolicies.Count -gt 0) {
                $mdInfo += "| Security profile name | CA policy name | CA policy state | Users/groups targeted |`n"
                $mdInfo += "| :-------------------- | :------------- | :-------------- | :-------------------- |`n"

                # Build unique CA linkages with user/group summary
                $uniqueCALinks = @{}
                foreach ($item in $caLinkedPolicies) {
                    $key = "$($item.ProfileName)|$($item.LinkedCAPolicy.displayName)"
                    if (-not $uniqueCALinks.ContainsKey($key)) {
                        # Build user/group summary
                        $userGroupSummary = @()
                        $conditions = $item.LinkedCAPolicy.conditions.users

                        if ($conditions.includeUsers -and $conditions.includeUsers.Count -gt 0) {
                            if ($conditions.includeUsers -contains 'All') {
                                $userGroupSummary += 'All users'
                            } else {
                                $userGroupSummary += "$($conditions.includeUsers.Count) user(s)"
                            }
                        }
                        if ($conditions.includeGroups -and $conditions.includeGroups.Count -gt 0) {
                            $userGroupSummary += "$($conditions.includeGroups.Count) group(s)"
                        }
                        if ($conditions.includeRoles -and $conditions.includeRoles.Count -gt 0) {
                            $userGroupSummary += "$($conditions.includeRoles.Count) role(s)"
                        }

                        $summary = if ($userGroupSummary.Count -gt 0) { $userGroupSummary -join ', ' } else { 'Not specified' }

                        $uniqueCALinks[$key] = [PSCustomObject]@{
                            ProfileName      = $item.ProfileName
                            CAPolicyName     = $item.LinkedCAPolicy.displayName
                            CAPolicyState    = '✅ Enabled'
                            UsersGroups      = $summary
                        }
                    }
                }

                foreach ($item in $uniqueCALinks.Values | Sort-Object ProfileName) {
                    $mdInfo += "| $(Get-SafeMarkdown $item.ProfileName) | $(Get-SafeMarkdown $item.CAPolicyName) | $($item.CAPolicyState) | $($item.UsersGroups) |`n"
                }
            }
            else {
                $mdInfo += "⚠️ No enabled Conditional Access policies are linked to security profiles with web category filtering.`n`n"
                $mdInfo += "Security profiles must be delivered through Conditional Access policies to apply to users.`n"
            }
        }
    }
    else {
        $mdInfo += "`n⚠️ No web content filtering policies with web category rules were found.`n"
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25409'
        Title  = 'Web content filtering with website categories is configured'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
