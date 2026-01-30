<#
.SYNOPSIS
    Enterprise generative AI applications are protected from prompt injection attacks through AI Gateway.
.DESCRIPTION
    Verifies that Prompt Shield (AI Gateway) is properly configured to protect against prompt injection attacks.
    The test passes if prompt policies exist and are enforced either through the Baseline Profile or through
    Security Profiles assigned to Conditional Access policies.
#>

function Test-Assessment-25415 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25415,
        Title = 'Enterprise generative AI applications are protected from prompt injection attacks through AI Gateway',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    # Define constants
    [int]$BASELINE_PROFILE_PRIORITY = 65000

    #region Data Collection
    Write-PSFMessage '🟦 Start Prompt Shield evaluation' -Tag Test -Level VeryVerbose

    $activity = 'Checking Prompt Shield configuration for AI Gateway protection'
    Write-ZtProgress -Activity $activity -Status 'Querying prompt policies'

    # Q1: Get prompt policies
    $promptPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/promptPolicies' -QueryParameters @{
        '$expand' = 'policyRules'
    } -ApiVersion beta

    # Q2: Get filtering profiles with linked policies and Conditional Access policies
    Write-ZtProgress -Activity $activity -Status 'Querying security profiles and linked policies'
    $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{
        '$expand' = 'policies($expand=policy),conditionalAccessPolicies'
    } -ApiVersion beta

    # Get all Conditional Access policies
    Write-ZtProgress -Activity $activity -Status 'Querying Conditional Access policies'
    $allCAPolicies = Get-ZtConditionalAccessPolicy

    #endregion Data Collection

    #region Assessment Logic
    $enabledSecurityProfiles = @()
    $enabledBaselineProfiles = @()
    $allPromptPolicyIds = @()

    # Collect all prompt policy IDs from Q1
    if ($promptPolicies) {
        $allPromptPolicyIds = $promptPolicies | ForEach-Object { $_.id }
    }

    # Find profiles linked to each prompt policy
    foreach ($promptPolicy in $promptPolicies) {
        $findParams = @{
            PolicyId          = $promptPolicy.id
            FilteringProfiles = $filteringProfiles
            CAPolicies        = $allCAPolicies
            BaselinePriority  = $BASELINE_PROFILE_PRIORITY
            PolicyLinkType    = 'promptPolicyLink'
            PolicyRules       = $promptPolicy.policyRules
        }

        $linkedProfiles = Find-ZtProfilesLinkedToPolicy @findParams

        foreach ($profileLink in $linkedProfiles) {
            if ($profileLink.ProfileType -eq 'Baseline Profile' -and $profileLink.PassesCriteria -and $profileLink.ProfileState -eq 'enabled') {
                $enabledBaselineProfiles += [PSCustomObject]@{
                    ProfileId            = $profileLink.ProfileId
                    ProfileName          = $profileLink.ProfileName
                    ProfileState         = $profileLink.ProfileState
                    ProfilePriority      = $profileLink.ProfilePriority
                    PromptPolicyId       = $promptPolicy.id
                    PromptPolicyName     = $promptPolicy.name
                    PromptPolicyAction   = $promptPolicy.action
                    RulesCount           = if ($promptPolicy.policyRules) { @($promptPolicy.policyRules).Count } else { 0 }
                    LastModified         = $promptPolicy.lastModifiedDateTime
                    PromptPolicyLinkState = $profileLink.PolicyLinkState
                }
            }
            elseif ($profileLink.ProfileType -eq 'Security Profile' -and $profileLink.PassesCriteria -and $profileLink.ProfileState -eq 'enabled') {
                $matchedCAPolicies = @()
                if ($null -ne $profileLink.CAPolicy) {
                    $matchedCAPolicies = @($profileLink.CAPolicy)
                }

                $enabledSecurityProfiles += [PSCustomObject]@{
                    ProfileId            = $profileLink.ProfileId
                    ProfileName          = $profileLink.ProfileName
                    ProfileState         = $profileLink.ProfileState
                    ProfilePriority      = $profileLink.ProfilePriority
                    PromptPolicyId       = $promptPolicy.id
                    PromptPolicyName     = $promptPolicy.name
                    PromptPolicyAction   = $promptPolicy.action
                    RulesCount           = if ($promptPolicy.policyRules) { @($promptPolicy.policyRules).Count } else { 0 }
                    LastModified         = $promptPolicy.lastModifiedDateTime
                    PromptPolicyLinkState = $profileLink.PolicyLinkState
                    MatchedCAPolicies    = $matchedCAPolicies
                    CAPolicyCount        = $matchedCAPolicies.Count
                }
            }
        }
    }
    $testResultMarkdown = ''
    $passed = $false
    $mdInfo = ''

    # Evaluation logic per spec
    if ($null -eq $promptPolicies -or $promptPolicies.Count -eq 0) {
        # No prompt policies configured
        $testResultMarkdown = "❌ Prompt Shield is not properly configured - no prompt policies exist.`n`n%TestResult%"
        $passed = $false
    }
    elseif ($enabledBaselineProfiles.Count -gt 0) {
        # Condition B: Baseline Profile has prompt policies (applies to all traffic)
        $testResultMarkdown = "✅ Prompt Shield policies are configured and enforced through the Baseline Profile which applies to all internet traffic.`n`n%TestResult%"
        $passed = $true
    }
    elseif ($enabledSecurityProfiles.Count -gt 0) {
        # Condition A: Security profiles with prompt policies AND CA policy assignment
        $testResultMarkdown = "✅ Prompt Shield policies are configured and enforced through security profiles assigned to Conditional Access policies.`n`n%TestResult%"
        $passed = $true
    }
    else {
        # Prompt policies exist but are not enforced
        $testResultMarkdown = "❌ Prompt Shield is not properly configured - policies are not linked to security profiles, or security profiles with prompt policies are not enforced (no CA policy assignment and not using Baseline Profile).`n`n%TestResult%"
        $passed = $false
    }

    #endregion Assessment Logic

    #region Report Generation

    if ($passed) {
        # Build detailed report only when test passes
        $formatTemplate = @'

## [Prompt Policies (AI Gateway)](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Policies.ReactView)

| Policy Name | Action | Rules Count | Last Modified |
| :---------- | :----- | :---------- | :------------ |
{0}
{1}
{2}
'@

        # Table 1: Prompt Policies
        $promptPoliciesRows = ''
        if ($promptPolicies -and $promptPolicies.Count -gt 0) {
            foreach ($policy in $promptPolicies) {
                $policyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditPromptPolicyMenuBlade.MenuView/~/basics/policyId/$($policy.id)"
                $policyName = Get-SafeMarkdown -Text $policy.name
                $action = if ($policy.action) { $policy.action } else { 'Not specified' }
                $rulesCount = if ($policy.policyRules) { @($policy.policyRules).Count } else { 0 }
                $lastModified = if ($policy.lastModifiedDateTime) { $policy.lastModifiedDateTime } else { 'N/A' }
                $promptPoliciesRows += "| [$policyName]($policyPortalLink) | $action | $rulesCount | $lastModified |`n"
            }
        }

        # Table 2: Baseline Profiles with Prompt Policies
        $baselineProfilesSection = ''
        if ($enabledBaselineProfiles.Count -gt 0) {
            $baselineProfilesSection += "`n## Prompt Policies Linked to Baseline Profile`n`n"
            $baselineProfilesSection += "| Profile Name | Priority | State | Prompt Policy | Policy Link State | Rules Count |`n"
            $baselineProfilesSection += "| :----------- | :------- | :---- | :------------ | :---------------- | :---------- |`n"
            foreach ($profile in $enabledBaselineProfiles) {
                $profilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$($profile.ProfileId)"
                $policyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditPromptPolicyMenuBlade.MenuView/~/basics/policyId/$($profile.PromptPolicyId)"
                $profileName = Get-SafeMarkdown -Text $profile.ProfileName
                $policyName = Get-SafeMarkdown -Text $profile.PromptPolicyName
                $baselineProfilesSection += "| [$profileName]($profilePortalLink) | $($profile.ProfilePriority) | $($profile.ProfileState) | [$policyName]($policyPortalLink) | $($profile.PromptPolicyLinkState) | $($profile.RulesCount) |`n"
            }
        }

        # Table 3: Security Profiles with Prompt Policies and CA Assignments
        $securityProfilesSection = ''
        if ($enabledSecurityProfiles.Count -gt 0) {
            $securityProfilesSection += "`n## [Security Profiles with Linked Policies](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/SecurityProfiles.ReactView)`n`n"
            $securityProfilesSection += "| Profile Name | State | Priority | Prompt Policy | CA Policies Assigned | Is Baseline |`n"
            $securityProfilesSection += "| :----------- | :---- | :------- | :------------ | :------------------- | :---------- |`n"
            foreach ($profile in $enabledSecurityProfiles) {
                $profilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$($profile.ProfileId)"
                $policyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditPromptPolicyMenuBlade.MenuView/~/basics/policyId/$($profile.PromptPolicyId)"
                $profileName = Get-SafeMarkdown -Text $profile.ProfileName
                $policyName = Get-SafeMarkdown -Text $profile.PromptPolicyName
                $isBaseline = if ($profile.ProfilePriority -eq $BASELINE_PROFILE_PRIORITY) { 'Yes' } else { 'No' }
                $caCount = $profile.CAPolicyCount
                $securityProfilesSection += "| [$profileName]($profilePortalLink) | $($profile.ProfileState) | $($profile.ProfilePriority) | [$policyName]($policyPortalLink) | $caCount | $isBaseline |`n"
            }

            # Table 4: Conditional Access Policies
            $securityProfilesSection += "`n## [Conditional Access Policies Assigned to Security Profiles](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies)`n`n"
            $securityProfilesSection += "| CA Policy Name | Security Profile | CA Policy ID |`n"
            $securityProfilesSection += "| :------------- | :--------------- | :----------- |`n"
            foreach ($profile in $enabledSecurityProfiles) {
                foreach ($caPolicy in $profile.MatchedCAPolicies) {
                    $caPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($caPolicy.Id)"
                    $profileName = Get-SafeMarkdown -Text $profile.ProfileName
                    $caPolicyName = Get-SafeMarkdown -Text $caPolicy.DisplayName
                    $securityProfilesSection += "| [$caPolicyName]($caPolicyPortalLink) | $profileName | $($caPolicy.Id) |`n"
                }
            }
        }

        $mdInfo = $formatTemplate -f $promptPoliciesRows, $baselineProfilesSection, $securityProfilesSection
    }
    else {
        # For failed states, just show the portal link
        $mdInfo = "[View Prompt Shield Configuration](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Policies.ReactView)`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '25415'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
