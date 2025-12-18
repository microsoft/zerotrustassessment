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

    # Query Q1: Get TLS Inspection policies
    $tlsInspectionPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/tlsInspectionPolicies' -ApiVersion beta

    # Step 2: List all policies in the Baseline Profile and in each Security Profile
    Write-ZtProgress -Activity $activity -Status 'Querying filtering profiles and policies'
    $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{
        '$select' = 'id,name,description,state,version,priority'
        '$expand' = 'policies($select=id,state;$expand=policy($select=id,name,version)),ConditionalAccessPolicies'
    } -ApiVersion beta

    # Query all Conditional Access policies with details
    Write-ZtProgress -Activity $activity -Status 'Querying Conditional Access policies'
    $allCAPolicies = Get-ZtConditionalAccessPolicy


    #endregion Data Collection

    #region Data Processing
    # Extract TLS inspection policy IDs
    $tlsPolicyIds = [string[]] $tlsInspectionPolicies.id

    # Search for TLS inspection policy in filtering profiles
    $enabledSecurityProfiles = @()
    $enabledBaseLineProfiles = @()
    $securityProfile = $filteringProfiles | Where-Object { $_.priority -ne 65000 }
    $baseLineProfile = $filteringProfiles | Where-Object { $_.priority -eq 65000 }
    foreach ($baseLineProfilePolicy in $baseLineProfile.policies) {
        # Check if the policy ID matches a TLS inspection policy
        if ($baseLineProfilePolicy.id -in $tlsPolicyIds) {
            # Check if the policy state is enabled
            if ($baseLineProfilePolicy.state -eq 'enabled') {
                $enabledBaseLineProfiles += [PSCustomObject]@{
                    TLSProfileId       = $baseLineProfile.id
                    TLSProfileName     = $baseLineProfile.name
                    TLSPolicyId        = $baseLineProfilePolicy.policy.id
                    TLSPolicyName      = $baseLineProfilePolicy.policy.name
                    TLSPolicyState     = $baseLineProfilePolicy.state
                    TLSProfileState    = $baseLineProfile.state
                    TLSProfilePriority = $baseLineProfile.priority
                }

            }
        }
    }

    foreach ($securityProfileItem in $securityProfile) {
        $linkedCAPolicies = @()
        foreach ($securityProfileCAPolicy in $securityProfileItem.ConditionalAccessPolicies) {
            $assignedCAPolicy = $allCAPolicies | Where-Object { $_.id -eq $securityProfileCAPolicy.id }
            if ($null -ne $assignedCAPolicy -and $assignedCAPolicy.state -eq 'enabled') {
                $linkedCAPolicies += $assignedCAPolicy.displayName
            }
        }
        if ($linkedCAPolicies.Count -gt 0 -and $securityProfileItem.state -eq 'enabled') {
            $enabledSecurityProfiles += [PSCustomObject]@{
                TLSProfileId       = $securityProfileItem.id
                TLSProfileName     = $securityProfileItem.name
                CAPolicyNames      = $linkedCAPolicies -join ', '
                CAPolicyCount      = $linkedCAPolicies.Count
                TLSProfileState    = $securityProfileItem.state
                TLSProfilePriority = $securityProfileItem.priority
            }
        }
    }
    #endregion Data Processing
    #region Assessment logic

    $testResultMarkdown = ''
    $passed = $true
    $mdInfo = ''

    if ($null -eq $tlsInspectionPolicies -or $tlsInspectionPolicies.Count -eq 0) {
        $testResultMarkdown = '❌ TLS inspection policies are not configured'
        $passed = $false
    }
    elseif ($enabledBaseLineProfiles.Count -gt 0 -or $enabledSecurityProfiles.Count -gt 0) {
        $testResultMarkdown = "✅ TLS inspection policy is enabled and linked to Security Profile(s).`n`n%TestResult%"
        $passed = $true
    }
    else {
        $testResultMarkdown = "❌ TLS inspection policy is not linked to any Security Profile.`n`n%TestResult%"
        $passed = $false
    }

    #endregion Assessment logic

    #region Report Generation

    if ($tlsInspectionPolicies.Count -gt 0) {
        $mdInfo += "`n## TLS Inspection Policies`n`n"
        $mdInfo += "| Policy Name | Policy ID | Action |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($tlsPolicy in $tlsInspectionPolicies) {
            $tlsPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditTlsInspectionPolicyMenuBlade.MenuView/~/basics/policyId/$(($tlsPolicy.id))"
            $policyName = Get-SafeMarkdown($tlsPolicy.name)
            $tlsPolicyDefaultAction = $tlsPolicy.settings.defaultAction
            $tlsPolicyId = $tlsPolicy.id
            $mdInfo += "| [$policyName]($tlsPolicyPortalLink) | $tlsPolicyId | $tlsPolicyDefaultAction |`n"
        }
    }

    if ($enabledBaseLineProfiles.Count -gt 0) {

        $mdInfo += "`n## TLS Inspection Policies Linked to Base Line Profiles`n`n"
        $mdInfo += "| Profile Name | Policy Name | Policy State | Profile State |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"
        foreach ($policy in $enabledBaseLineProfiles) {
            $baseLineProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($policy.TLSProfileId))"
            $tlsProfileName = Get-SafeMarkdown($policy.TLSProfileName)
            $tlsPolicyName = Get-SafeMarkdown($policy.TLSPolicyName)
            $tlsPolicyState = $policy.TLSPolicyState
            $tlsProfileState = $policy.TLSProfileState
            $mdInfo += "| [$tlsProfileName]($baseLineProfilePortalLink) | $tlsPolicyName | $tlsPolicyState | $tlsProfileState |`n"
        }
    }

    if ($enabledSecurityProfiles.Count -gt 0) {
        $mdInfo += "`n## Security Profiles Linked to Conditional Access Policies`n`n"
        $mdInfo += "| Profile Name | CA Policies | CA Policy Count | Profile State | Profile Priority |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- |`n"
        foreach ($profile in $enabledSecurityProfiles) {
            $securityProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($profile.TLSProfileId))"
            $tlsProfileName = Get-SafeMarkdown($profile.TLSProfileName)
            $caPolicyNames = Get-SafeMarkdown($profile.CAPolicyNames)
            $caPolicyCount = $profile.CAPolicyCount
            $tlsProfileState = $profile.TLSProfileState
            $tlsProfilePriority = $profile.TLSProfilePriority
            $mdInfo += "| [$tlsProfileName]($securityProfilePortalLink) | $caPolicyNames | $caPolicyCount | $tlsProfileState | $tlsProfilePriority  |`n"
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
