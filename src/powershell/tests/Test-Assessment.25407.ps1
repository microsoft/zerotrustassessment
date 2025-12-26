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
        Title = 'Conditional Access policies are applied to Global Secure Access traffic',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start GSA Conditional Access evaluation (security profiles via CA)' -Tag Test -Level VeryVerbose

    # Licensing gate for Conditional Access
    <#if (-not (Get-ZtLicense EntraIDP1)) {
        Add-ZtTestResultDetail -TestId 25407 -Title 'Conditional Access policies are applied to Global Secure Access traffic' -Status $false -Result '### ⚠️ Test skipped`nThis tenant does not have Microsoft Entra ID P1, which is required for Conditional Access.'
        return
    }#>

    $policies = Get-ZtConditionalAccessPolicy

    # All policies that have any Global Secure Access security profile linked
    $gSAFilteringProfilePolicies = @()
    $policiesWithProfile = $policies | Where-Object { $null -ne $_.sessionControls.globalSecureAccessFilteringProfile -and $_.state -eq 'enabled'}
    foreach ($policy in $policiesWithProfile) {
        if ($policy.sessionControls.globalSecureAccessFilteringProfile.isEnabled -eq $true ) {
            $gSAFilteringProfilePolicies += $policy
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ''

    if ($null -ne $gSAFilteringProfilePolicies -and $gSAFilteringProfilePolicies.Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ Internet Access policy is being applied via Conditional Access.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ Internet Access policy is not being applied via Conditional Access.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''
    # Generate markdown table for policies with Global Secure Access filtering profiles
    if ($null -ne $policiesWithProfile -and $policiesWithProfile.Count -gt 0) {
        $mdInfo = "`n## All Policies with Global Secure Access Filtering Profile Configuration`n`n"
        $mdInfo += "| Policy Name | Policy ID | State | GSA Profile Enabled |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"
        foreach ($policy in $policiesWithProfile) {
            $gsaEnabledSign = if ($policy.sessionControls.globalSecureAccessFilteringProfile.isEnabled) { '✅' } else { '❌' }
            $stateSign = if ($policy.state -eq 'enabled') { '✅' } else { '❌' }
            $policyPortalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"
            $mdInfo += "| [$(Get-SafeMarkdown $policy.displayName)]($policyPortalLink) | $($policy.id) | $stateSign | $gsaEnabledSign |`n"
        }
    }
    else {
        $mdInfo = "`n## Conditional Access Policies`n`n"
        $mdInfo += "No Conditional Access policies with Global Secure Access security profiles were found.`n`n"
    }
    #endregion Report Generation

    $params = @{
        TestId = '25407'
        Title  = 'Conditional Access policies are applied to Global Secure Access traffic'
        Status = $passed
        Result = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }

    Add-ZtTestResultDetail @params
}
