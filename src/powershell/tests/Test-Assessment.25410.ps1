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
        TenantType = ('Workforce', 'External'),
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
    $errorMsg = $null
    try {
        $filteringPolicies = Invoke-ZtGraphRequest `
            -RelativeUri 'networkAccess/filteringPolicies?$expand=policyRules' `
            -ApiVersion beta `
            -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to get filtering policies: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Getting security profiles'

    # Query Q2: List all security profiles with linked policies and CA policies
    $securityProfiles = $null
    try {
        $securityProfiles = Invoke-ZtGraphRequest `
            -RelativeUri 'networkAccess/filteringProfiles?$expand=policies($expand=policy),conditionalAccessPolicies' `
            -ApiVersion beta `
            -ErrorAction Stop
    }
    catch {
        if (-not $errorMsg) {
            $errorMsg = $_
        }
        Write-PSFMessage "Failed to get security profiles: $_" -Tag Test -Level Warning
    }

    # Extract values
    $policies = if ($filteringPolicies) { $filteringPolicies } else { @() }
    $profiles = if ($securityProfiles) { $securityProfiles } else { @() }

    # Collect all filtering policy IDs for use in assessment and reporting
    $q1PolicyIds = @($policies | ForEach-Object { $_.id })
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null
    $testResultMarkdown = ''

    # Check if API calls failed
    if ($errorMsg) {
        # Investigate: Cannot query API
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine web content filtering status due to API connection failure or insufficient permissions.`n`n%TestResult%"
    }
    # Check if both policies and profiles exist
    elseif ($policies.Count -gt 0 -and $profiles.Count -gt 0) {
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
            $testResultMarkdown = "✅ Web content filtering policies are configured and enforced - either through security profiles assigned to Conditional Access policies or through the Baseline Profile which applies to all internet traffic.`n`n%TestResult%"
        }
    }

    # Default failure message (if not API error and not passed)
    if (-not $errorMsg -and -not $passed) {
        $testResultMarkdown = "❌ Web content filtering is not properly configured - either no policies exist, policies are not linked to security profiles, or security profiles with filtering policies are not enforced (no CA policy assignment and not using Baseline Profile).`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Table 1: Web Content Filtering Policies
    if ($policies.Count -gt 0) {
        $table1Title = 'Web Content Filtering Policies'
        $table1Link = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/WebFilteringPolicy.ReactView'

        $table1Template = @'

## [{0}]({1})

| Policy Name | Action | Rules Count | Last Modified |
| :---------- | :----- | ----------: | :------------ |
{2}
'@

        $table1Rows = ''
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

            $table1Rows += "| $policyNameWithLink | $action | $rulesCount | $lastModified |`n"
        }

        $mdInfo += $table1Template -f $table1Title, $table1Link, $table1Rows
    }

    # Table 2: Security Profiles with Linked Policies
    if ($profiles.Count -gt 0) {
        $table2Title = 'Security Profiles with Linked Policies'
        $table2Link = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/FilteringPolicyProfiles.ReactView'

        $table2Template = @'

## [{0}]({1})

| Profile Name | State | Priority | Filtering Policies Linked | CA Policies Assigned | Is Baseline |
| :----------- | :---- | -------: | :----------------------- | -------------------: | :---------- |
{2}
'@

        $table2Rows = ''
        foreach ($securityProfile in $profiles) {
            $profileName = $securityProfile.name
            $profileId = $securityProfile.id
            $state = $securityProfile.state
            $priority = $securityProfile.priority
            $isBaseline = if ($priority -eq $BASELINE_PROFILE_PRIORITY) { 'Yes' } else { 'No' }

            # Create profile blade link
            $safeProfileName = Get-SafeMarkdown $profileName
            $profileBladeLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$profileId"
            $profileNameWithLink = "[$safeProfileName]($profileBladeLink)"

            # Get filtering policy links
            $filteringPolicyLinks = $securityProfile.policies | Where-Object {
                $_.'@odata.type' -eq '#microsoft.graph.networkaccess.filteringPolicyLink' -and
                $_.policy.id -in $q1PolicyIds
            }

            $linkedPolicyNames = if ($filteringPolicyLinks.Count -gt 0) {
                ($filteringPolicyLinks | ForEach-Object { Get-SafeMarkdown $_.policy.name }) -join ', '
            } else {
                'None'
            }

            $caCount = if ($isBaseline -eq 'Yes') {
                'N/A'
            } else {
                $securityProfile.conditionalAccessPolicies.Count
            }

            $table2Rows += "| $profileNameWithLink | $state | $priority | $linkedPolicyNames | $caCount | $isBaseline |`n"
        }

        $mdInfo += $table2Template -f $table2Title, $table2Link, $table2Rows
    }

    # Table 3: Conditional Access Policies Assigned to Security Profiles
    $caPolicies = @()
    foreach ($securityProfile in $profiles) {
        if ($securityProfile.conditionalAccessPolicies -and $securityProfile.conditionalAccessPolicies.Count -gt 0) {
            foreach ($caPolicy in $securityProfile.conditionalAccessPolicies) {
                $caPolicies += [PSCustomObject]@{
                    CAPolicyName = $caPolicy.displayName
                    ProfileName  = $securityProfile.name
                    CAPolicyId   = $caPolicy.id
                }
            }
        }
    }

    if ($caPolicies.Count -gt 0) {
        $table3Title = 'Conditional Access Policies Assigned to Security Profiles'
        $table3Link = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'

        $table3Template = @'

## [{0}]({1})

| CA Policy Name | Security Profile |
| :------------- | :--------------- |
{2}
'@

        $table3Rows = ''
        foreach ($caPolicy in $caPolicies) {
            $safeCAPolicyName = Get-SafeMarkdown $caPolicy.CAPolicyName
            $safeProfileName = Get-SafeMarkdown $caPolicy.ProfileName
            $table3Rows += "| [$safeCAPolicyName](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($caPolicy.CAPolicyId)) | $safeProfileName |`n"
        }

        $mdInfo += $table3Template -f $table3Title, $table3Link, $table3Rows
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25410'
        Title  = 'Internet traffic is protected by web content filtering policies in Global Secure Access'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
