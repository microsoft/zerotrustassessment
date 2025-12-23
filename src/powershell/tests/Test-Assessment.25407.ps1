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
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start GSA Conditional Access evaluation (security profiles via CA)' -Tag Test -Level VeryVerbose

    $policies = Get-ZtConditionalAccessPolicy

    # All policies that have Global Secure Access security profile enabled
    $gSAFilteringProfilePolicies = $policies | Where-Object {
        $_.state -eq 'enabled' -and
        $_.sessionControls.globalSecureAccessFilteringProfile.isEnabled -eq $true
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    if ($null -ne $gSAFilteringProfilePolicies -and $gSAFilteringProfilePolicies.Count -gt 0) {
        $passed = $true
    }
    else {
        $passed = $false
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''
    $testResultMarkdown = ''
    # Generate markdown table for policies with Global Secure Access filtering profiles
    if ($passed) {
        $testResultMarkdown = "✅ Internet Access policy is being applied via Conditional Access.`n`n%TestResult%"
        $mdInfo = "`n## Conditional Access Policies with Global Secure Access Security Profiles`n`n"
        $mdInfo += "| Policy Name | Policy ID | State |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($policy in $gSAFilteringProfilePolicies) {
            $policyPortalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"
            $mdInfo += "| [$(Get-SafeMarkdown $policy.displayName)]($policyPortalLink) | $($policy.id) | ✅ Enabled |`n"
        }
    }
    else {
        $testResultMarkdown = "❌ Internet Access policy is not being applied via Conditional Access.`n`n%TestResult%"
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
