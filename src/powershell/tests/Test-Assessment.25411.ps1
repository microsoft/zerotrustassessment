<#
.SYNOPSIS
    TLS inspection is enabled and correctly configured for outbound traffic in Global Secure Access.
.DESCRIPTION
    Verifies that a TLS Inspection policy is properly configured. It will fail if no TLS Inspection policy exists, if the policy is not linked to a Security Profile, or if no Conditional Access policy assigning that Security Profile can be identified.
#>

#region Helper functions
function Get-ProfileType {
    param (
        $Priority
    )
    if ($null -eq $Priority) {
        return 'NA'
    }
    if ($Priority -eq 65000) {
        return "Baseline Profile"
    }
    if ($Priority -lt 65000) {
        return "Security Profile"
    }
}

function Get-DefaultAction {
    param (
        $TLSPolicies,
        $TLSPolicyID
    )
    $TLSPolicy = $TLSPolicies | Where-Object { $_.id -eq $TLSPolicyID }
    if ($null -ne $TLSPolicy) {
        return $TLSPolicy.settings.defaultAction
    }
    else {
        return 'NA'
    }
}

#endregion Helper functions

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
    $tlsPolicyIds = $tlsInspectionPolicies.id

    # Search for TLS inspection policy in filtering profiles
    $enabledSecurityProfiles = @()
    $enabledBaseLineProfiles = @()
    $securityProfile = $filteringProfiles | Where-Object { ($_.priority -lt 65000) }
    $baseLineProfiles = $filteringProfiles | Where-Object { $_.priority -eq 65000 }
    <#foreach ($baseLineProfileItem in $baseLineProfiles) {
        foreach ($baseLineProfilePolicy in @($baseLineProfileItem.policies)) {
            # Check if the policy ID matches a TLS inspection policy
            if ($baseLineProfilePolicy.'@odata.type' -like '*filtering*') {
                $enabledBaseLineProfiles += [PSCustomObject]@{
                    ProfileId       = $baseLineProfileItem.id
                    ProfileName     = $baseLineProfileItem.name
                    TLSPolicyId     = $baseLineProfilePolicy.policy.id
                    TLSPolicyName   = $baseLineProfilePolicy.policy.name
                    TLSPolicyState  = $baseLineProfilePolicy.state
                    ProfileState    = $baseLineProfileItem.state
                    ProfilePriority = $baseLineProfileItem.priority
                    ProfileType     = Get-ProfileType -Priority $baseLineProfileItem.priority
                }
            }
        }
    }#>

    foreach ($securityProfileItem in $filteringProfiles) {
        # Check if the security profile contains a TLS inspection policy
        foreach ($securityProfilePolicy in $securityProfileItem.policies) {
            $linkedCAPolicies = @()
            if ($securityProfilePolicy.'@odata.type' -like '*tlsInspectionPolicyLink*' -or $securityProfilePolicy.'@odata.type' -like '*forwarding*') {
                $assignedCAPolicy = $allCAPolicies | Where-Object { $_.id -in @($securityProfileItem.ConditionalAccessPolicies.id) }
                if ($null -ne $assignedCAPolicy -and $assignedCAPolicy.state -eq 'enabled') {
                    $linkedCAPolicies = $assignedCAPolicy.displayName
                }
                if ($linkedCAPolicies.Count -gt 0 -and $securityProfileItem.state -eq 'enabled') {
                    $enabledSecurityProfiles += [PSCustomObject]@{
                        ProfileId               = $securityProfileItem.id
                        ProfileName             = $securityProfileItem.name
                        CAPolicyNames           = $linkedCAPolicies -join ', '
                        CAPolicyCount           = $linkedCAPolicies.Count
                        ProfileState            = $securityProfileItem.state
                        ProfilePriority         = $securityProfileItem.priority
                        ProfileType             = Get-ProfileType -Priority $securityProfileItem.priority
                        TLSInspectionPolicyName = $securityProfilePolicy.policy.name
                        DefaultAction           = Get-DefaultAction -TLSPolicies $tlsInspectionPolicies -TLSPolicyID $securityProfilePolicy.policy.id
                    }
                }
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
        $mdInfo += "| Profile Name | Policy Name | Policy State | Profile State | TLS Inspection Policy Name|`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"
        foreach ($policy in $enabledBaseLineProfiles) {
            $baseLineProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($policy.ProfileId))"
            $ProfileName = Get-SafeMarkdown($policy.ProfileName)
            $tlsPolicyName = Get-SafeMarkdown($policy.TLSPolicyName)
            $tlsPolicyState = $policy.TLSPolicyState
            $ProfileState = $policy.ProfileState
            $mdInfo += "| [$ProfileName]($baseLineProfilePortalLink) | $tlsPolicyName | $tlsPolicyState | $ProfileState |`n"
        }
    }

    if ($enabledSecurityProfiles.Count -gt 0) {
        $mdInfo += "`n## Security Profiles Linked to Conditional Access Policies`n`n"
        $mdInfo += "| Profile Name | CA Policies | Profile State | TLS Inspection Policy Name | Default Action |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- |`n"
        foreach ($profile in $enabledSecurityProfiles) {
            $securityProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($profile.ProfileId))"
            $ProfileName = Get-SafeMarkdown($profile.ProfileName)
            $caPolicyNames = Get-SafeMarkdown($profile.CAPolicyNames)
            $ProfileState = $profile.ProfileState
            $ProfilePriority = $profile.ProfilePriority
            $TlsPolicyName = Get-SafeMarkdown($profile.TLSInspectionPolicyName)
            $DefaultAction = $profile.DefaultAction
            $mdInfo += "| [$ProfileName]($securityProfilePortalLink) | $caPolicyNames | $ProfileState | $TlsPolicyName | $DefaultAction |`n"
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
