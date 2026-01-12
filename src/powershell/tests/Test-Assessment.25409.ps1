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

    # Define constants
    [int]$BASELINE_PROFILE_PRIORITY = 65000

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Global Secure Access web content filtering by website categories'
    Write-ZtProgress -Activity $activity -Status 'Querying Web Content Filtering policies'

    # Q1: Get all Web Content Filtering policies (excluding "All Websites")
    try {
        $allFilteringPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringPolicies' -ApiVersion beta -ErrorAction Stop
        $wcfPolicies = $allFilteringPolicies | Where-Object { $_.name -ne 'All websites' }
    }
    catch {
        Write-PSFMessage "Failed to retrieve filtering policies: $_" -Tag Test -Level Warning
        $wcfPolicies = @()
    }

    Write-ZtProgress -Activity $activity -Status 'Querying filtering profiles'

    # Q2: Get all filtering profiles with their policies and priority
    try {
        $filteringProfilesQueryParams = @{
            '$select' = 'id,name,description,state,version,priority'
            '$expand' = 'policies($select=id,state;$expand=policy($select=id,name,version))'
        }
        $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters $filteringProfilesQueryParams -ApiVersion beta -ErrorAction Stop
    }
    catch {
        Write-PSFMessage "Failed to retrieve filtering profiles: $_" -Tag Test -Level Warning
        $filteringProfiles = @()
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Conditional Access policies'

    # Q3 prep: Get all Conditional Access policies with session controls
    $caPolicies = Get-ZtConditionalAccessPolicy
    #endregion Data Collection

    #region Assessment Logic
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $policiesWithWebCategory = @()

    # Check if any Web Content Filtering policies exist (excluding "All Websites")
    if (-not $wcfPolicies -or $wcfPolicies.Count -eq 0) {
        $testResultMarkdown = '❌ Web Content Filtering policy is not configured.'
        $passed = $false
    }
    else {
        # Per spec: Check if webCategory policies exist in Baseline Profile or Security Profiles with enabled CA
        foreach ($wcfPolicy in $wcfPolicies) {
            $policyId = $wcfPolicy.id
            $policyName = $wcfPolicy.name

            # Get full policy details with rules to check for webCategory
            $policyDetails = Invoke-ZtGraphRequest -RelativeUri "networkAccess/filteringPolicies/$policyId`?`$select=id,name,version&`$expand=policyRules" -ApiVersion beta
            $webCategoryRules = @($policyDetails.policyRules) | Where-Object { $_.ruleType -eq 'webCategory' }

            # Skip if no webCategory rules
            if (-not $webCategoryRules) {
                continue
            }

            # Find profiles that have this policy linked using shared helper function
            $findParams = @{
                PolicyId          = $policyId
                FilteringProfiles = $filteringProfiles
                CAPolicies        = $caPolicies
                BaselinePriority  = $BASELINE_PROFILE_PRIORITY
                PolicyLinkType    = 'filteringPolicyLink'
                PolicyRules       = $webCategoryRules
            }
            $linkedProfiles = Find-ZtProfilesLinkedToPolicy @findParams

            # Check if any linked profile passes criteria
            $profilePasses = $linkedProfiles | Where-Object { $_.PassesCriteria -eq $true }
            if ($profilePasses) {
                $passed = $true
            }

            # Add policy with its linked profiles to collection
            if ($linkedProfiles.Count -gt 0) {
                $policiesWithWebCategory += [PSCustomObject]@{
                    PolicyId         = $policyId
                    PolicyName       = $policyName
                    LinkedProfiles   = $linkedProfiles
                }
            }
        }

        # Determine status message based on pass/fail
        if ($passed) {
            $testResultMarkdown = "✅ Web content filtering with web category controls is configured and applied through either the Baseline Profile or a security profile linked to an active Conditional Access policy. `n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ No policies using web category filtering were found in the Baseline Profile or in security profiles linked to active Conditional Access policies. `n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $mdInfo = ''

    if ($policiesWithWebCategory.Count -gt 0) {
        # Table 1: Filtering Policies with Web Category Rules
        $mdInfo += "`n## Filtering Policies with Web Category Rules`n`n"
        $mdInfo += "| Profile type | Profile name | Policy name | Rule name | Web categories | State |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($wcfPolicy in $policiesWithWebCategory | Sort-Object -Property PolicyName) {
            $safePolicyName = Get-SafeMarkdown $wcfPolicy.PolicyName

            foreach ($profileInfo in $wcfPolicy.LinkedProfiles) {
                $safeProfileName = Get-SafeMarkdown $profileInfo.ProfileName
                $policyLinkState = $profileInfo.PolicyLinkState

                # Create blade links
                $profileBladeLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$($profileInfo.ProfileId)"
                $profileNameWithLink = "[$safeProfileName]($profileBladeLink)"

                $encodedPolicyName = [System.Uri]::EscapeDataString($wcfPolicy.PolicyName)
                $policyBladeLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditFilteringPolicyMenuBlade.MenuView/~/Basics/policyId/$($wcfPolicy.PolicyId)/title/$encodedPolicyName/defaultMenuItemId/Basics"
                $policyNameWithLink = "[$safePolicyName]($policyBladeLink)"

                # Process each webCategory rule
                foreach ($rule in $profileInfo.PolicyRules) {
                    $safeRuleName = Get-SafeMarkdown $rule.name
                    $webCategories = ($rule.destinations | ForEach-Object { $_.displayName }) -join ', '
                    $safeWebCategories = Get-SafeMarkdown $webCategories

                    # Show state with indicator
                    $stateDisplay = if ($policyLinkState -eq 'enabled') { '✅ Enabled' } else { '❌ Disabled' }

                    $mdInfo += "| $($profileInfo.ProfileType) | $profileNameWithLink | $policyNameWithLink | $safeRuleName | $safeWebCategories | $stateDisplay |`n"
                }
            }
        }

        # Table 2: Conditional Access Linkages (for Security Profiles only)
        $securityProfiles = $policiesWithWebCategory.LinkedProfiles | Where-Object { $_.ProfileType -eq 'Security Profile' -and $null -ne $_.CAPolicy }
        if ($securityProfiles.Count -gt 0) {
            $mdInfo += "`n## Conditional Access Linkages (for Security Profiles only)`n`n"
            $mdInfo += "| CA policy name | Security profile name | CA policy state |`n"
            $mdInfo += "| :--- | :--- | :--- |`n"

            # Build unique CA linkages
            $uniqueCALinks = @{}
            foreach ($policy in $policiesWithWebCategory) {
                foreach ($profileInfo in $policy.LinkedProfiles) {
                    if ($profileInfo.ProfileType -eq 'Security Profile' -and $null -ne $profileInfo.CAPolicy -and $profileInfo.CAPolicy.Count -gt 0) {
                        foreach ($caPolicy in $profileInfo.CAPolicy) {
                            $key = "$($profileInfo.ProfileId)|$($caPolicy.id)"
                            if (-not $uniqueCALinks.ContainsKey($key)) {
                                $uniqueCALinks[$key] = [PSCustomObject]@{
                                    ProfileName   = $profileInfo.ProfileName
                                    ProfileId     = $profileInfo.ProfileId
                                    CAPolicyName  = $caPolicy.displayName
                                    CAPolicyId    = $caPolicy.id
                                    CAPolicyState = $caPolicy.state
                                }
                            }
                        }
                    }
                }
            }

            foreach ($item in $uniqueCALinks.Values | Sort-Object CAPolicyName, ProfileName) {
                $safeProfileName = Get-SafeMarkdown $item.ProfileName
                $safeCAPolicyName = Get-SafeMarkdown $item.CAPolicyName

                $caPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($item.CAPolicyId)"
                $caPolicyNameWithLink = "[$safeCAPolicyName]($caPolicyPortalLink)"

                $profilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$($item.ProfileId)"
                $profileNameWithLink = "[$safeProfileName]($profilePortalLink)"

                # Show actual state with indicator
                $caPolicyState = if ($item.CAPolicyState -eq 'enabled') { '✅ Enabled' } else { '❌ Disabled' }

                $mdInfo += "| $caPolicyNameWithLink | $profileNameWithLink | $caPolicyState |`n"
            }
        }

        # Add portal links at the end
        $mdInfo += "`n### Portal links`n`n"
        $mdInfo += "- [Web content filtering policies](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/WebFilteringPolicy.ReactView)`n"
        $mdInfo += "- [Security profiles](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/FilteringPolicyProfiles.ReactView)`n"
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
