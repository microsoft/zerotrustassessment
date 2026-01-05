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
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25411,
        Title = 'TLS inspection is enabled and correctly configured for outbound traffic in Global Secure Access',
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

    # Build CA profile lookup for O(1) access instead of O(N) search per profile
    Write-ZtProgress -Activity $activity -Status 'Building Conditional Access policy lookup'
    $caProfileLookup = @{}
    foreach ($cap in $allCAPolicies) {
        $session = $cap.sessionControls
        if ($null -ne $session -and $null -ne $session.globalSecureAccessFilteringProfile) {
            $sessionProfileId = $session.globalSecureAccessFilteringProfile.profileId
            $sessionEnabled = $session.globalSecureAccessFilteringProfile.isEnabled

            if ($sessionEnabled -eq $true -and $cap.state -eq 'enabled') {
                if (-not $caProfileLookup.ContainsKey($sessionProfileId)) {
                    $caProfileLookup[$sessionProfileId] = @()
                }
                $caProfileLookup[$sessionProfileId] += [PSCustomObject]@{
                    Id          = $cap.id
                    DisplayName = $cap.displayName
                    State       = $cap.state
                }
            }
        }
    }

    #endregion Data Collection

    #region Data Processing
    # Graph responses are automatically unwrapped by Invoke-ZtGraphRequest
    $enabledSecurityProfiles = @()
    $enabledBaseLineProfiles = @()

    # Iterate each TLS inspection policy and find linked profiles
    foreach ($tlsPolicy in $tlsInspectionPolicies) {
        $tlsId = $tlsPolicy.id
        $baseLineProfileFound = $false
        foreach ($profileItem in $filteringProfiles) {
            $profilePolicies = @()
            if ($null -ne $profileItem.policies) {
                $profilePolicies = $profileItem.policies
            }

            foreach ($plink in $profilePolicies) {
                $plinkType = $plink.'@odata.type'
                $linkedPolicyId = $null
                # Only process tlsInspectionPolicyLink entries
                if ($plinkType -eq '#microsoft.graph.networkaccess.tlsInspectionPolicyLink' -and $null -ne $plink.policy) {
                    $linkedPolicyId = $plink.policy.id
                }

                if ($null -ne $linkedPolicyId -and $linkedPolicyId -eq $tlsId) {
                    $linkState = if ($null -ne $plink.state) {
                        $plink.state
                    }
                    else {
                        'unknown'
                    }
                    $profileState = if ($null -ne $profileItem.state) {
                        $profileItem.state
                    }
                    else {
                        'unknown'
                    }
                    $priority = if ($null -ne $profileItem.priority) {
                        [int]$profileItem.priority
                    }
                    else {
                        $null
                    }

                    if ($priority -eq $BASELINE_PROFILE_PRIORITY) {
                        # Baseline Profile: apply without CA

                        if ($linkState -eq 'enabled' -and $profileState -eq 'enabled') {
                            $baseLineProfileFound = $true
                            $enabledBaseLineProfiles += [PSCustomObject]@{
                                ProfileId          = $profileItem.id
                                ProfileName        = $profileItem.name
                                ProfileState       = $profileState
                                ProfilePriority    = $priority
                                TLSPolicyId        = $tlsId
                                TLSPolicyName      = $plink.policy.name
                                TLSPolicyLinkState = $linkState
                            }
                            break
                        }
                    } elseif ($null -ne $priority -and $priority -lt $BASELINE_PROFILE_PRIORITY) {
                        # Security Profile: must be applied via Conditional Access
                        # Validate CA policies reference this profile via sessionControls
                        $matchedCAPolicies = @()
                        if ($caProfileLookup.ContainsKey($profileItem.id)) {
                            $matchedCAPolicies = $caProfileLookup[$profileItem.id]
                        }

                        if ($matchedCAPolicies.Count -gt 0 -and $profileState -eq 'enabled' -and $linkState -eq 'enabled') {
                            $enabledSecurityProfiles += [PSCustomObject]@{
                                ProfileId          = $profileItem.id
                                ProfileName        = $profileItem.name
                                ProfileState       = $profileState
                                ProfilePriority    = $priority
                                TLSPolicyId        = $tlsId
                                TLSPolicyName      = $plink.policy.name
                                TLSPolicyLinkState = $linkState
                                CAPolicyNames      = ($matchedCAPolicies | Select-Object -ExpandProperty DisplayName) -join ', '
                                CAPolicyIds        = ($matchedCAPolicies | Select-Object -ExpandProperty Id) -join ', '
                                CAPolicyStates     = ($matchedCAPolicies | Select-Object -ExpandProperty State) -join ', '
                                CAPolicyCount      = $matchedCAPolicies.Count
                                DefaultAction      = if ($null -ne $tlsPolicy.settings) {
                                    $tlsPolicy.settings.defaultAction
                                }
                                else {
                                    'unknown'
                                }
                            }
                        }
                    }
                }
            }
            if ($baseLineProfileFound) {
                break
            }
        }
    }

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

    if ($enabledBaseLineProfiles.Count -gt 0) {

        $mdInfo += "`n## TLS Inspection Policies Linked to Baseline Profiles`n`n"
        $mdInfo += "| Linked Profile Name | Linked Profile Priority | Linked Policy Name | Policy Link State | Profile State |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- |`n"
        foreach ($policy in $enabledBaseLineProfiles) {
            $baseLineProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($policy.ProfileId))"
            $tlsPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditTlsInspectionPolicyMenuBlade.MenuView/~/basics/policyId/$(($policy.TLSPolicyId))"
            $profileName = Get-SafeMarkdown -Text $policy.ProfileName
            $profilePriority = $policy.ProfilePriority
            $tlsPolicyName = Get-SafeMarkdown -Text $policy.TLSPolicyName
            $tlsPolicyLinkState = $policy.TLSPolicyLinkState
            $profileState = $policy.ProfileState
            $mdInfo += "| [$profileName]($baseLineProfilePortalLink) | $profilePriority | [$tlsPolicyName]($tlsPolicyPortalLink) | $tlsPolicyLinkState | $profileState |`n"
        }
    }

    if ($enabledSecurityProfiles.Count -gt 0) {
        $mdInfo += "`n## Security Profiles Linked to Conditional Access Policies`n`n"
        $mdInfo += "| Linked Profile Name | Linked Profile Priority | CA Policy Names | CA Policy State | Profile State | TLS Inspection Policy Name | Default Action |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"
        foreach ($enabledProfile in $enabledSecurityProfiles) {
            $securityProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($enabledProfile.ProfileId))"
            $tlsPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditTlsInspectionPolicyMenuBlade.MenuView/~/basics/policyId/$(($enabledProfile.TLSPolicyId))"
            $profileName = Get-SafeMarkdown -Text $enabledProfile.ProfileName
            $profilePriority = $enabledProfile.ProfilePriority
            # Build CA policy links
            $caNames = $enabledProfile.CAPolicyNames -split ', '
            $caIds = $enabledProfile.CAPolicyIds -split ', '
            $caPolicyLinksMarkdown = @()
            for ($i = 0; $i -lt $caNames.Count; $i++) {
                $caPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Intune_Actions/ConditionalAccessBlade/~/Policies/$($caIds[$i].Trim())"
                $safeName = Get-SafeMarkdown -Text $caNames[$i]
                $caPolicyLinksMarkdown += "[$safeName]($caPolicyPortalLink)"
            }
            $caPolicyNamesLinked = $caPolicyLinksMarkdown -join ', '
            $caPolicyStates = Get-SafeMarkdown -Text $enabledProfile.CAPolicyStates
            $profileState = $enabledProfile.ProfileState
            $tlsPolicyName = Get-SafeMarkdown -Text $enabledProfile.TLSPolicyName
            $defaultAction = $enabledProfile.DefaultAction
            $mdInfo += "| [$profileName]($securityProfilePortalLink) | $profilePriority | $caPolicyNamesLinked | $caPolicyStates | $profileState | [$tlsPolicyName]($tlsPolicyPortalLink) | $defaultAction |`n"
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
