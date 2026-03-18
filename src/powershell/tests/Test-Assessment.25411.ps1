<#
.SYNOPSIS
    TLS inspection is enabled and correctly configured for outbound traffic in Global Secure Access.
.DESCRIPTION
    Verifies that a TLS Inspection policy is properly configured. It will fail if no TLS Inspection policy exists, if the policy is not linked to a Security Profile, or if no Conditional Access policy assigning that Security Profile can be identified.
#>

function Test-Assessment-25411 {
    [ZtTest(
    	Category = 'Global Secure Access',
    	ImplementationCost = 'High',
    	MinimumLicense = ('Entra_Premium_Internet_Access'),
    	CompatibleLicense = ('Entra_Premium_Internet_Access'),
    	Pillar = 'Network',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce'),
    	TestId = 25411,
    	Title = 'TLS inspection is enabled and correctly configured for outbound traffic',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    # Define constants
    [int]$BASELINE_PROFILE_PRIORITY = 65000

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'TLS inspection is enabled and correctly configured for outbound traffic in Global Secure Access.'
    Write-ZtProgress -Activity $activity -Status 'Querying TLS inspection policies'

    # Step 1: Get TLS Inspection policies
    $tlsInspectionPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/tlsInspectionPolicies' -ApiVersion beta

    # Step 2: List all policies in the Baseline Profile and in each Security Profile
    Write-ZtProgress -Activity $activity -Status 'Querying filtering profiles and policies'
    $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{
        '$select' = 'id,name,description,state,version,priority'
        '$expand' = 'policies($select=id,state;$expand=policy($select=id,name,version)),conditionalAccessPolicies($select=id,displayName)'
    } -ApiVersion beta

    # Query all Conditional Access policies with details
    Write-ZtProgress -Activity $activity -Status 'Querying Conditional Access policies'
    $allCAPolicies = Get-ZtConditionalAccessPolicy

    #endregion Data Collection

    #region Data Processing
    # Graph responses are automatically unwrapped by Invoke-ZtGraphRequest
    $baselineProfileResults = @()
    $securityProfileResults = @()

    # Iterate each TLS inspection policy and find linked profiles using the helper function
    foreach ($tlsPolicy in $tlsInspectionPolicies) {
        $findParams = @{
            PolicyId          = $tlsPolicy.id
            FilteringProfiles = $filteringProfiles
            CAPolicies        = $allCAPolicies
            BaselinePriority  = $BASELINE_PROFILE_PRIORITY
            PolicyLinkType    = 'tlsInspectionPolicyLink'
            PolicyRules       = $tlsPolicy
        }

        $linkedProfiles = Find-ZtProfilesLinkedToPolicy @findParams

        foreach ($policyProfile in $linkedProfiles) {
            if ($policyProfile.ProfileType -eq 'Baseline Profile') {
                $baselineProfileResults += [PSCustomObject]@{
                    ProfileId          = $policyProfile.ProfileId
                    ProfileName        = $policyProfile.ProfileName
                    ProfileState       = $policyProfile.ProfileState
                    ProfilePriority    = $policyProfile.ProfilePriority
                    TLSPolicyId        = $tlsPolicy.id
                    TLSPolicyName      = $tlsPolicy.name
                    TLSPolicyLinkState = $policyProfile.PolicyLinkState
                }
            }
            elseif ($policyProfile.ProfileType -eq 'Security Profile') {
                $matchedCAPolicies = @()
                if ($null -ne $policyProfile.CAPolicy) {
                    $matchedCAPolicies = @($policyProfile.CAPolicy)
                }

                # Collect all linked security profiles for table display (regardless of state or CA policy linkage)
                $securityProfileResults += [PSCustomObject]@{
                    ProfileId          = $policyProfile.ProfileId
                    ProfileName        = $policyProfile.ProfileName
                    ProfileState       = $policyProfile.ProfileState
                    ProfilePriority    = $policyProfile.ProfilePriority
                    TLSPolicyId        = $tlsPolicy.id
                    TLSPolicyName      = $tlsPolicy.name
                    TLSPolicyLinkState = $policyProfile.PolicyLinkState
                    MatchedCAPolicies  = $matchedCAPolicies
                    PassesCriteria     = $policyProfile.PassesCriteria
                }
            }
        }
    }

    # Baseline profiles that pass: both policy link state and profile state must be enabled
    $enabledBaseLineProfiles = @($baselineProfileResults | Where-Object { $_.ProfileState -eq 'enabled' -and $_.TLSPolicyLinkState -eq 'enabled' })

    # Security profiles that pass: profile enabled, policy link enabled, and at least one enabled CA policy linked
    $enabledSecurityProfiles = @($securityProfileResults | Where-Object { $_.ProfileState -eq 'enabled' -and $_.TLSPolicyLinkState -eq 'enabled' -and $_.PassesCriteria })

    #endregion Data Processing
    #region Assessment logic

    $testResultMarkdown = ''
    $passed = $false
    $mdInfo = ''

    if ($null -eq $tlsInspectionPolicies -or $tlsInspectionPolicies.Count -eq 0) {
        $testResultMarkdown = "❌ TLS Inspection Policy has not been properly configured. `n`n%TestResult%"
        $passed = $false
    }
    elseif ($enabledBaseLineProfiles.Count -gt 0) {
        $testResultMarkdown = "✅ TLS Inspection Policy is enabled and properly configured to inspect encrypted outbound traffic.`n`n%TestResult%"
        $passed = $true
    }
    elseif ($enabledSecurityProfiles.Count -gt 0) {
        $testResultMarkdown = "✅ TLS Inspection Policy is enabled and properly configured to inspect encrypted outbound traffic.`n`n%TestResult%"
        $passed = $true
    }
    else {
        $testResultMarkdown = "❌ TLS Inspection Policy has not been properly configured.`n`n%TestResult%"
        $passed = $false
    }

    #endregion Assessment logic

    #region Report Generation

    if ($baselineProfileResults.Count -gt 0) {

        $mdInfo += "`n## TLS Inspection Policies Linked to Baseline Profiles`n`n"
        $mdInfo += "| Linked Profile Name | Linked Profile Priority | Linked Policy Name | Policy Link State | Profile State |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- |`n"
        foreach ($policy in $baselineProfileResults) {
            $baseLineProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($policy.ProfileId))"
            $tlsPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditTlsInspectionPolicyMenuBlade.MenuView/~/basics/policyId/$(($policy.TLSPolicyId))"
            $profileName = Get-SafeMarkdown -Text $policy.ProfileName
            $profilePriority = $policy.ProfilePriority
            $tlsPolicyName = Get-SafeMarkdown -Text $policy.TLSPolicyName
            $tlsPolicyLinkState = if ($policy.TLSPolicyLinkState -eq 'enabled') { '✅ Enabled' } else { '❌ Disabled' }
            $profileState = if ($policy.ProfileState -eq 'enabled') { '✅ Enabled' } else { '❌ Disabled' }
            $mdInfo += "| [$profileName]($baseLineProfilePortalLink) | $profilePriority | [$tlsPolicyName]($tlsPolicyPortalLink) | $tlsPolicyLinkState | $profileState |`n"
        }
    }

    if ($securityProfileResults.Count -gt 0) {
        $mdInfo += "`n## TLS Inspection Policies Linked to Security Profiles`n`n"
        $mdInfo += "| Linked Profile Name | Linked Profile Priority | Linked Policy Name | Policy Link State | Profile State | CA Policy Name | CA Policy State |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"
        foreach ($profile in $securityProfileResults) {
            $securityProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($profile.ProfileId))"
            $tlsPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditTlsInspectionPolicyMenuBlade.MenuView/~/basics/policyId/$(($profile.TLSPolicyId))"
            $profileName = Get-SafeMarkdown -Text $profile.ProfileName
            $profilePriority = $profile.ProfilePriority
            $tlsPolicyName = Get-SafeMarkdown -Text $profile.TLSPolicyName
            $tlsPolicyLinkState = if ($profile.TLSPolicyLinkState -eq 'enabled') { '✅ Enabled' } else { '❌ Disabled' }
            $profileState = if ($profile.ProfileState -eq 'enabled') { '✅ Enabled' } else { '❌ Disabled' }
            if ($profile.MatchedCAPolicies.Count -gt 0) {
                $caPolicyLinksMarkdown = @()
                $caPolicyStatesList = @()
                foreach ($caPolicy in $profile.MatchedCAPolicies) {
                    $caPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($caPolicy.Id)"
                    $safeName = Get-SafeMarkdown -Text $caPolicy.DisplayName
                    $caPolicyLinksMarkdown += "[$safeName]($caPolicyPortalLink)"
                    $caPolicyStatesList += if ($caPolicy.State -eq 'enabled') { '✅ Enabled' } elseif ($caPolicy.State -eq 'enabledForReportingButNotEnforced') { '⚠️ Report Only' } else { '❌ Disabled' }
                }
                $caPolicyNamesLinked = $caPolicyLinksMarkdown -join ', '
                $caPolicyStates = $caPolicyStatesList -join ', '
            }
            else {
                $caPolicyNamesLinked = 'Missing'
                $caPolicyStates = 'Missing'
            }
            $mdInfo += "| [$profileName]($securityProfilePortalLink) | $profilePriority | [$tlsPolicyName]($tlsPolicyPortalLink) | $tlsPolicyLinkState | $profileState | $caPolicyNamesLinked | $caPolicyStates |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation


    $params = @{
        TestId = '25411'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
