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
    $enabledSecurityProfiles = @()
    $enabledBaseLineProfiles = @()

    # Iterate each TLS inspection policy and find linked profiles
    foreach ($tlsPolicy in $tlsInspectionPolicies) {
        $tlsId = $tlsPolicy.id
        $baselineProfileFound = $false
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

                    if ($priority -eq 65000) {
                        # Baseline Profile: apply without CA

                        if ($linkState -eq 'enabled' -and $profileState -eq 'enabled') {
                            $baselineProfileFound = $true
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
                    } elseif ($null -ne $priority -and $priority -lt 65000) {
                        # Security Profile: must be applied via Conditional Access
                        # Validate CA policies reference this profile via sessionControls
                        $matchedCAPolicies = @()
                        foreach ($cap in $allCAPolicies) {
                            $session = $cap.sessionControls
                            if ($null -ne $session -and $null -ne $session.globalSecureAccessFilteringProfile) {
                                $sessionProfileId = $session.globalSecureAccessFilteringProfile.profileId
                                $sessionEnabled = $session.globalSecureAccessFilteringProfile.isEnabled
                                if ($sessionProfileId -eq $profileItem.id -and $sessionEnabled -eq $true -and $cap.state -eq 'enabled') {
                                    $matchedCAPolicies += [PSCustomObject]@{
                                        Id          = $cap.id
                                        DisplayName = $cap.displayName
                                        State       = $cap.state
                                    }
                                }
                            }
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
            if ($baselineProfileFound) {
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
            $ProfileName = Get-SafeMarkdown -Text $policy.ProfileName
            $ProfilePriority = $policy.ProfilePriority
            $tlsPolicyName = Get-SafeMarkdown -Text $policy.TLSPolicyName
            $tlsPolicyLinkState = $policy.TLSPolicyLinkState
            $ProfileState = $policy.ProfileState
            $mdInfo += "| [$ProfileName]($baseLineProfilePortalLink) | $ProfilePriority | [$tlsPolicyName]($tlsPolicyPortalLink) | $tlsPolicyLinkState | $ProfileState |`n"
        }
    }

    if ($enabledSecurityProfiles.Count -gt 0) {
        $mdInfo += "`n## Security Profiles Linked to Conditional Access Policies`n`n"
        $mdInfo += "| Linked Profile Name | Linked Profile Priority | CA Policy Names | CA Policy State | Profile State | TLS Inspection Policy Name | Default Action |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"
        foreach ($enabledProfile in $enabledSecurityProfiles) {
            $securityProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($enabledProfile.ProfileId))"
            $tlsPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditTlsInspectionPolicyMenuBlade.MenuView/~/basics/policyId/$(($enabledProfile.TLSPolicyId))"
            $ProfileName = Get-SafeMarkdown -Text $enabledProfile.ProfileName
            $ProfilePriority = $enabledProfile.ProfilePriority
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
            $ProfileState = $enabledProfile.ProfileState
            $TlsPolicyName = Get-SafeMarkdown -Text $enabledProfile.TLSPolicyName
            $DefaultAction = $enabledProfile.DefaultAction
            $mdInfo += "| [$ProfileName]($securityProfilePortalLink) | $ProfilePriority | $caPolicyNamesLinked | $caPolicyStates | $ProfileState | [$TlsPolicyName]($tlsPolicyPortalLink) | $DefaultAction |`n"
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
