<#
.SYNOPSIS
    Internet Access security profiles are applied to users via Conditional Access policies.
#>

function Test-Assessment-25407 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 25407,
        Title = 'Internet Access security policies are enforced through Conditional Access for user-aware protection',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start GSA Conditional Access evaluation (security profiles via CA)' -Tag Test -Level VeryVerbose

    # Q1: Retrieve all Conditional Access policies
    $policies = Get-ZtConditionalAccessPolicy

    # Q2: Retrieve all Global Secure Access filtering/security profiles
    $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -ApiVersion beta

    # Process CA policies to find those with enabled GSA security profiles linked to enabled filtering profiles

    $gsaPolicies = $policies | Where-Object { ($_.state -eq 'enabled' )-and ($null -ne $_.sessionControls.globalSecureAccessFilteringProfile) }
    $gsaPolicyDetails = @()

    foreach ($policy in $gsaPolicies) {
        $profileId = $policy.sessionControls.globalSecureAccessFilteringProfile.profileId
        $caLinkageEnabled = $policy.sessionControls.globalSecureAccessFilteringProfile.isEnabled
        $matchedProfile = $filteringProfiles | Where-Object { $_.id -eq $profileId }
        $gsaPolicyDetails += [PSCustomObject]@{
            PolicyId          = $policy.id
            PolicyDisplayName = $policy.displayName
            PolicyState       = $policy.state
            ProfileId         = $profileId
            CALinkageEnabled  = $caLinkageEnabled
            ProfileName       = $matchedProfile.name
            ProfileState      = $matchedProfile.state
        }
    }
    $caPolicyWithGsaProfilesEnabled = $gsaPolicyDetails | Where-Object { $_.ProfileState -eq 'enabled' -and $_.CALinkageEnabled -eq $true }
    $caPolicyWithGsaProfilesDisabled = $gsaPolicyDetails | Where-Object { $_.ProfileState -ne 'enabled' -or $_.CALinkageEnabled -ne $true }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $caPolicyWithGsaProfilesEnabled.Count -ge 1
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''
    $testResultMarkdown = ''
    # Generate markdown table for policies with Global Secure Access filtering profiles
    if ($passed) {
        $testResultMarkdown = "✅ Internet Access policy is being applied via Conditional Access.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Internet Access policy is not being applied via Conditional Access.`n`n%TestResult%"
        if ($gsaPolicyDetails) {
            $mdInfo = "`n## Conditional Access Policies with Global Secure Access Security Profiles`n`n"
            $mdInfo += "| CA Policy Name | CA Policy State | Security Profile ID | CA Linkage Enabled | Security Profile Name | Security Profile State |`n"
            $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"
            foreach ($item in $caPolicyWithGsaProfilesDisabled) {
                $policyPortalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($item.PolicyId)"
                $caStateIcon = '✅ Enabled'
                $linkageIcon = if ($item.CALinkageEnabled) {
                    '✅ Enabled'
                }
                else {
                    '❌ Disabled'
                }
                $profileStateIcon = if ($item.ProfileState -eq 'enabled') {
                    '✅ Enabled'
                }
                else {
                    '❌ Disabled'
                }
                $mdInfo += "| [$(Get-SafeMarkdown $item.PolicyDisplayName)]($policyPortalLink) | $caStateIcon | $($item.ProfileId) | $linkageIcon | $(Get-SafeMarkdown $item.ProfileName) | $profileStateIcon |`n"
            }
        }
    }

    #endregion Report Generation

    $params = @{
        TestId = '25407'
        Status = $passed
        Result = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }

    Add-ZtTestResultDetail @params
}
