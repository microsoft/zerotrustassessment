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
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -QueryParameters @{
        '$select' = 'id,displayName,state,createdDateTime,modifiedDateTime'
    } -ApiVersion beta

    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $true
    #endregion Data Collection

    #region Assessment Logic
    if ($null -eq $tlsInspectionPolicies -or $tlsInspectionPolicies.Count -eq 0) {
        $testResultMarkdown = '❌ TLS inspection policies are not configured'
        $passed = $false
    }


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
        foreach ($securityProfileCAPolicy in $securityProfileItem.ConditionalAccessPolicies) {
            $assignedCAPolicy = $allCAPolicies | Where-Object { $_.id -eq $securityProfileCAPolicy.id }
            if ($null -ne $assignedCAPolicy -and $assignedCAPolicy.state -eq 'enabled') {
                $enabledSecurityProfiles += [PSCustomObject]@{
                    TLSProfileId       = $securityProfileItem.id
                    TLSProfileName     = $securityProfileItem.name
                    CAPolicyId         = $assignedCAPolicy.id
                    CAPolicyName       = $assignedCAPolicy.displayName
                    CAPolicyState      = $assignedCAPolicy.state
                    TLSProfileState    = $securityProfileItem.state
                    TLSProfilePriority = $securityProfileItem.priority
                }
            }
        }
    }
    $enabledSecurityProfiles = $enabledSecurityProfiles | where-object { $_.'CAPolicyState' -eq 'enabled' -and $_.'TLSProfileState' -eq 'enabled' }
    # Determine test result
    if ($enabledBaseLineProfiles.Count -gt 0 -or $enabledSecurityProfiles.Count -gt 0) {
        $testResultMarkdown = "✅ TLS inspection policy is enabled and linked to Security Profile(s).`n`n%TestResult%"
        $passed = $true
    }
    else {
        $testResultMarkdown = "❌ TLS inspection policy is either not linked to any Security Profile or is not enabled.`n`n%TestResult%"
        $passed = $false
    }

    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($tlsInspectionPolicies.Count -gt 0) {
        $mdInfo += "`n## TLS Inspection Policies`n`n"
        $mdInfo += "| Policy ID | Policy Name | Action |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($tlsPolicy in $tlsInspectionPolicies) {
            $tlsPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditTlsInspectionPolicyMenuBlade.MenuView/~/basics/policyId/$(($tlsPolicy.id))"
            $mdInfo += "| [$($tlsPolicy.name)]($tlsPolicyPortalLink) | $($tlsPolicy.id) | $($tlsPolicy.settings.defaultAction) |`n"
        }
    }

    if ($enabledBaseLineProfiles.Count -gt 0) {

        $mdInfo += "`n## TLS Inspection Policies Linked to Base Line Profiles`n`n"
        $mdInfo += "| Profile Name | Policy Name | Policy State | Profile State |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"
        foreach ($policy in $enabledBaseLineProfiles) {
            $baseLineProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($policy.TLSProfileId))"
            $mdInfo += "| [$($policy.TLSProfileName)]($baseLineProfilePortalLink) | $($policy.TLSPolicyName) | $($policy.TLSPolicyState) | $($policy.TLSProfileState) |`n"
        }
    }

    if ($enabledSecurityProfiles.Count -gt 0) {
        $mdInfo += "`n## Security Profiles Linked to Conditional Access Policies`n`n"
        $mdInfo += "| Profile Name | CA Policy Name | CA Policy State | Profile State | Profile Priority |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- |`n"
        foreach ($profile in $enabledSecurityProfiles) {
            $securityProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$(($profile.TLSProfileId))"
            $mdInfo += "| [$($profile.TLSProfileName)]($securityProfilePortalLink) | $($profile.CAPolicyName) | $($profile.CAPolicyState) | $($profile.TLSProfileState) | $($profile.TLSProfilePriority) |`n"
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
