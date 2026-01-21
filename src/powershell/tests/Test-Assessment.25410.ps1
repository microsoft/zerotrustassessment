<#
.SYNOPSIS
    Validates that web content filtering policies are configured and enforced in Global Secure Access.

.DESCRIPTION
    This test checks if web content filtering policies exist and are properly linked to security profiles
    that are either assigned to Conditional Access policies or configured in the Baseline Profile which
    applies to all internet traffic. Web content filtering provides protection against malicious websites,
    phishing sites, and inappropriate content categories at the network edge.

.NOTES
    Test ID: 25410
    Category: Global Secure Access
    Pillar: Network
    Required API: networkAccess/filteringPolicies (beta), networkAccess/filteringProfiles (beta)
#>

function Test-Assessment-25410 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25410,
        Title = 'Internet traffic is protected by web content filtering policies in Global Secure Access',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    # Define constants
    [int]$BASELINE_PROFILE_PRIORITY = 65000

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Global Secure Access web content filtering'
    Write-ZtProgress -Activity $activity -Status 'Getting filtering policies'

    # Query Q1: List all web content filtering policies
    $filteringPolicies = $null
    try {
        $filteringPolicies = Invoke-ZtGraphRequest `
            -RelativeUri 'networkAccess/filteringPolicies?$expand=policyRules' `
            -ApiVersion beta
    }
    catch {
        Write-PSFMessage "Failed to get filtering policies: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Getting security profiles'

    # Query Q2: List all security profiles with linked policies and CA policies
    $securityProfiles = $null
    try {
        $securityProfiles = Invoke-ZtGraphRequest `
            -RelativeUri 'networkAccess/filteringProfiles?$expand=policies($expand=policy),conditionalAccessPolicies' `
            -ApiVersion beta
    }
    catch {
        Write-PSFMessage "Failed to get security profiles: $_" -Tag Test -Level Warning
    }

    # Extract values
    $policies = if ($filteringPolicies) { $filteringPolicies } else { @() }
    $profiles = if ($securityProfiles) { $securityProfiles } else { @() }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Step 1: Check if any filtering policies exist
    if ($policies.Count -eq 0) {
        # Fail: No filtering policies configured
        $testResultMarkdown = "❌ Web content filtering is not properly configured - either no policies exist, policies are not linked to security profiles, or security profiles with filtering policies are not enforced (no CA policy assignment and not using Baseline Profile).`n`n"
    }
    # Step 2: Check if any security profiles exist
    elseif ($profiles.Count -eq 0) {
        # Fail: No security profiles configured
        $testResultMarkdown = "❌ Web content filtering is not properly configured - either no policies exist, policies are not linked to security profiles, or security profiles with filtering policies are not enforced (no CA policy assignment and not using Baseline Profile).`n`n"
    }
    else {
        # Collect all filtering policy IDs from Q1
        $q1PolicyIds = $policies | ForEach-Object { $_.id }

        # Find Baseline Profile (priority = 65000)
        $baselineProfile = $profiles | Where-Object { $_.priority -eq $BASELINE_PROFILE_PRIORITY }

        # Check Condition B: Baseline Profile has filtering policy linked
        $baselineHasWCF = $false
        if ($baselineProfile) {
            $filteringPolicyLinks = $baselineProfile.policies | Where-Object {
                $_.'@odata.type' -eq '#microsoft.graph.networkaccess.filteringPolicyLink' -and
                $_.policy.id -in $q1PolicyIds
            }
            $baselineHasWCF = ($filteringPolicyLinks.Count -gt 0)
        }

        # Check Condition A: Non-Baseline profiles with filtering policy AND CA policy
        $nonBaselineProfilesWithWCFandCA = $profiles | Where-Object {
            $_.priority -ne $BASELINE_PROFILE_PRIORITY -and
            ($_.policies | Where-Object {
                $_.'@odata.type' -eq '#microsoft.graph.networkaccess.filteringPolicyLink' -and
                $_.policy.id -in $q1PolicyIds
            }).Count -gt 0 -and
            $_.conditionalAccessPolicies.Count -gt 0
        }

        # Determine pass/fail
        if ($baselineHasWCF -or $nonBaselineProfilesWithWCFandCA.Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "✅ Web content filtering policies are configured and enforced - either through security profiles assigned to Conditional Access policies or through the Baseline Profile which applies to all internet traffic.`n`n"
        }
        else {
            $testResultMarkdown = "❌ Web content filtering is not properly configured - either no policies exist, policies are not linked to security profiles, or security profiles with filtering policies are not enforced (no CA policy assignment and not using Baseline Profile).`n`n"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Table 1: Web Content Filtering Policies
    if ($policies.Count -gt 0) {
        $mdInfo += "## [Web Content Filtering Policies](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Policies.ReactView)`n`n"
        $mdInfo += "| Policy Name | Action | Rules Count | Last Modified |`n"
        $mdInfo += "| :---------- | :----- | ----------: | :------------ |`n"

        foreach ($policy in $policies) {
            $policyName = $policy.name
            $policyId = $policy.id
            $action = $policy.action
            $rulesCount = if ($policy.policyRules) { $policy.policyRules.Count } else { 0 }
            $lastModified = if ($policy.lastModifiedDateTime) {
                ([DateTime]$policy.lastModifiedDateTime).ToString('yyyy-MM-dd HH:mm')
            } else { 'N/A' }

            # Create policy blade link
            $safePolicyName = Get-SafeMarkdown $policyName
            $encodedPolicyName = [System.Uri]::EscapeDataString($policyName)
            $policyBladeLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditFilteringPolicyMenuBlade.MenuView/~/Basics/policyId/$policyId/title/$encodedPolicyName/defaultMenuItemId/Basics"
            $policyNameWithLink = "[$safePolicyName]($policyBladeLink)"

            $mdInfo += "| $policyNameWithLink | $action | $rulesCount | $lastModified |`n"
        }
        $mdInfo += "`n"
    }

    # Table 2: Security Profiles with Linked Policies
    if ($profiles.Count -gt 0) {
        $mdInfo += "## [Security Profiles with Linked Policies](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/SecurityProfiles.ReactView)`n`n"
        $mdInfo += "| Profile Name | State | Priority | Filtering Policies Linked | CA Policies Assigned | Is Baseline |`n"
        $mdInfo += "| :----------- | :---- | -------: | :----------------------- | -------------------: | :---------- |`n"

        $q1PolicyIds = $policies | ForEach-Object { $_.id }

        foreach ($profile in $profiles) {
            $profileName = $profile.name
            $profileId = $profile.id
            $state = $profile.state
            $priority = $profile.priority
            $isBaseline = if ($priority -eq $BASELINE_PROFILE_PRIORITY) { 'Yes' } else { 'No' }

            # Create profile blade link
            $safeProfileName = Get-SafeMarkdown $profileName
            $profileBladeLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$profileId"
            $profileNameWithLink = "[$safeProfileName]($profileBladeLink)"

            # Get filtering policy links
            $filteringPolicyLinks = $profile.policies | Where-Object {
                $_.'@odata.type' -eq '#microsoft.graph.networkaccess.filteringPolicyLink' -and
                $_.policy.id -in $q1PolicyIds
            }

            $linkedPolicyNames = if ($filteringPolicyLinks.Count -gt 0) {
                ($filteringPolicyLinks | ForEach-Object { $_.policy.name }) -join ', '
            } else {
                'None'
            }

            $caCount = if ($isBaseline -eq 'Yes') {
                'N/A'
            } else {
                $profile.conditionalAccessPolicies.Count
            }

            $mdInfo += "| $profileNameWithLink | $state | $priority | $linkedPolicyNames | $caCount | $isBaseline |`n"
        }
        $mdInfo += "`n"
    }

    # Table 3: Conditional Access Policies Assigned to Security Profiles
    $caPolicies = @()
    foreach ($profile in $profiles) {
        if ($profile.conditionalAccessPolicies -and $profile.conditionalAccessPolicies.Count -gt 0) {
            foreach ($caPolicy in $profile.conditionalAccessPolicies) {
                $caPolicies += [PSCustomObject]@{
                    CAPolicyName = $caPolicy.displayName
                    ProfileName  = $profile.name
                    CAPolicyId   = $caPolicy.id
                }
            }
        }
    }

    if ($caPolicies.Count -gt 0) {
        $mdInfo += "## [Conditional Access Policies Assigned to Security Profiles](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies)`n`n"
        $mdInfo += "| CA Policy Name | Security Profile |`n"
        $mdInfo += "| :------------- | :--------------- |`n"

        foreach ($caPolicy in $caPolicies) {
            $mdInfo += "| [$($caPolicy.CAPolicyName)](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($caPolicy.CAPolicyId)) | $($caPolicy.ProfileName) |`n"
        }
        $mdInfo += "`n"
    }

    $testResultMarkdown += $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25410'
        Title  = 'Internet traffic is protected by web content filtering policies in Global Secure Access'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
