<#
.SYNOPSIS
    Internet Access security profiles are applied to users via Conditional Access policies.
#>

function Test-Assessment-25407 {
    [ZtTest(
        Category = 'Network',
        ImplementationCost = 'Medium',  # from your spec
        MinimumLicense = ('Microsoft Entra ID P1'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 25407,
        Title = 'Conditional Access policies are applied to Global Secure Access traffic',
        UserImpact = 'Low'      # from your spec
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start GSA Conditional Access evaluation (security profiles via CA)' -Tag Test -Level VeryVerbose

    # Initialize
    $passed = $false
    $testResultMarkdown = ''
    $mdInfo = ''

    # Licensing gate for Conditional Access
    <#if (-not (Get-ZtLicense EntraIDP1)) {
        Add-ZtTestResultDetail -TestId 25407 -Title 'Conditional Access policies are applied to Global Secure Access traffic' -Status $false -Result '### ⚠️ Test skipped`nThis tenant does not have Microsoft Entra ID P1, which is required for Conditional Access.'
        return
    }#>

    $policies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -apiVersion 'beta'

    # All policies that have any Global Secure Access security profile linked
    $gSAFilteringProfilePolicies = @()
    $policiesWithProfile = $policies | Where-Object { $null -ne $_.sessionControls.globalSecureAccessFilteringProfile }
    foreach ($policy in $policiesWithProfile) {
        if ($policy.sessionControls.globalSecureAccessFilteringProfile.isEnabled -eq $true -and $policy.state -eq 'enabled') {
            $gSAFilteringProfilePolicies += $policy
        }
    }
    if ($null -ne $gSAFilteringProfilePolicies -and $gSAFilteringProfilePolicies.Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ Conditional Access policies are applied to Global Secure Access traffic.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ No Conditional Access policies are applied to Global Secure Access traffic.`n`n%TestResult%"
    }

    # Generate markdown table for policies with Global Secure Access filtering profiles
    $mdInfo = "`n## All Policies with Global Secure Access Filtering Profile Configuration`n`n"
    $mdInfo += "| Policy ID | Display Name | State | GSA Profile Enabled |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- |`n"
    foreach ($policy in $policiesWithProfile) {
        $gsaEnabledSign = if ($policy.sessionControls.globalSecureAccessFilteringProfile.isEnabled) { '✅' } else { '❌' }
        $stateSign = if ($policy.state -eq 'enabled') { '✅' } else { '❌' }
        $mdInfo += "| $($policy.id) | $($policy.displayName) | $stateSign | $gsaEnabledSign |`n"
    }



    $params = @{
        TestId = '25407'
        Title  = 'Conditional Access policies are applied to Global Secure Access traffic'
        Status = $passed
        Result = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }

    Add-ZtTestResultDetail @params
}
