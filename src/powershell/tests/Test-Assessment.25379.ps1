<#
.SYNOPSIS
    Checks that compliant network controls are configured in Conditional Access policies

.DESCRIPTION
    Verifies that Global Secure Access signaling is enabled, the compliant network named location exists,
    and at least one enabled Conditional Access policy enforces compliant network requirements.

.NOTES
    Test ID: 25379
    Category: External Identities
    Required API: networkAccess/settings, namedLocations, conditionalAccess/policies
#>

function Test-Assessment-25379 {
    [ZtTest(
        Category = 'External Identities',
        ImplementationCost = 'Medium',
        MinimumLicense = ('AAD_PREMIUM'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce','External'),
        TestId = 25379,
        Title = 'Compliant network controls are used in conditional access policies',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking compliant network controls in Conditional Access'
    Write-ZtProgress -Activity $activity -Status 'Retrieving Global Secure Access signaling status'

    # Q1: Get Global Secure Access Conditional Access signaling settings
    $settings = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/settings/conditionalAccess' -ApiVersion beta -ErrorAction SilentlyContinue

    if (-not $settings -or $settings.signalingStatus -ne 'enabled') {
        $result = if (-not $settings) {
            '❌ Unable to retrieve Global Secure Access signaling settings.'
        } else {
            '❌ Global Secure Access signaling is disabled.'
        }
        Add-ZtTestResultDetail -TestId '25379' -Status $false -Result $result
        return
    }

    # Q2: Retrieve the compliant network named location
    Write-ZtProgress -Activity $activity -Status 'Retrieving compliant network named location'

    $namedLocations = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/namedLocations' -Filter "isof('microsoft.graph.compliantNetworkNamedLocation')" -ApiVersion beta

    $compliantNetworkLocation = $namedLocations | Where-Object {
        $_.'@odata.type' -eq '#microsoft.graph.compliantNetworkNamedLocation' -and
        $_.compliantNetworkType -eq 'allTenantCompliantNetworks'
    } | Select-Object -First 1

    if (-not $compliantNetworkLocation) {
        Add-ZtTestResultDetail -TestId '25379' -Status $false -Result '❌ Compliant network named location does not exist or is not properly configured.'
        return
    }

    # Q3: Retrieve enabled Conditional Access policies
    Write-ZtProgress -Activity $activity -Status 'Retrieving enabled Conditional Access policies'

    $policies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -Filter "state eq 'enabled'" -ApiVersion beta

    if (-not $policies) {
        Add-ZtTestResultDetail -TestId '25379' -Status $false -Result '❌ No enabled Conditional Access policies found.'
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $compliantNetworkLocationId = $compliantNetworkLocation.id

    # Find policies that block all locations except compliant network (standard pattern)
    $standardPolicies = $policies | Where-Object {
        $_.conditions.locations -and
        $_.conditions.locations.includeLocations -contains 'All' -and
        $_.conditions.locations.excludeLocations -contains $compliantNetworkLocationId -and
        $_.grantControls.builtInControls -contains 'block'
    }

    # Find policies with alternative enforcement patterns
    $alternativePolicies = $policies | Where-Object {
        $_.conditions.locations -and
        (
            # Pattern 1: Excludes compliant network but uses controls other than block
            ($_.conditions.locations.excludeLocations -contains $compliantNetworkLocationId -and
             $_.grantControls.builtInControls -notcontains 'block') -or
            # Pattern 2: Includes compliant network in includeLocations
            ($_.conditions.locations.includeLocations -contains $compliantNetworkLocationId) -or
            # Pattern 3: Targets specific apps with compliant network conditions
            (($_.conditions.locations.excludeLocations -contains $compliantNetworkLocationId -or
              $_.conditions.locations.includeLocations -contains $compliantNetworkLocationId) -and
             $_.conditions.applications.includeApplications -ne 'All' -and
             -not ($_.conditions.applications.includeApplications -contains 'All'))
        )
    } | Where-Object { $standardPolicies -notcontains $_ } | Select-Object -Unique

    # Determine overall result per spec
    if ($standardPolicies) {
        $passed = $true
        $customStatus = $null
        $testResultMarkdown = "✅ Compliant network controls are configured in Conditional Access. Global Secure Access signaling is enabled and at least one Conditional Access policy blocks access from all locations except the compliant network.`n`n%TestResult%"
    }
    elseif ($alternativePolicies) {
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Compliant network controls are partially configured. Global Secure Access signaling is enabled and Conditional Access policies reference the compliant network location, but they use an alternative enforcement pattern that requires manual review to confirm adequate protection.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $customStatus = $null
        $testResultMarkdown = "❌ Compliant network controls are not properly configured. No Conditional Access policies reference the compliant network location.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Global Secure Access configuration
    $mdInfo += "`n## [Global Secure Access configuration](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/SessionManagementMenu.ReactView/menuId~/null/sectionId~/null)`n`n"
    $mdInfo += "| Setting | Value |`n"
    $mdInfo += "| :--- | :--- |`n"
    $mdInfo += "| Signaling status | $($settings.signalingStatus) |`n`n"

    # Compliant network named location
    $namedLocationPortal = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations"
    $mdInfo += "## [Compliant network named location]($namedLocationPortal)`n`n"
    $mdInfo += "| Property | Value |`n"
    $mdInfo += "| :--- | :--- |`n"
    $mdInfo += "| Display name | $(Get-SafeMarkdown $compliantNetworkLocation.displayName) |`n"
    $mdInfo += "| Network type | $($compliantNetworkLocation.compliantNetworkType) |`n"
    $isTrustedValue = if ($null -ne $compliantNetworkLocation.isTrusted) { $compliantNetworkLocation.isTrusted.ToString() } else { 'Not specified' }
    $mdInfo += "| Is trusted | $isTrustedValue |`n`n"

    # Conditional Access policies
    $allRelevantPolicies = @()
    if ($standardPolicies) { $allRelevantPolicies += $standardPolicies }
    if ($alternativePolicies) { $allRelevantPolicies += $alternativePolicies }

    if ($allRelevantPolicies.Count -gt 0) {
        $mdInfo += "## [Conditional Access policies using compliant network](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies)`n`n"
        $mdInfo += "| Status | Policy name | State | Include locations | Exclude locations | Grant controls |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $standardPolicies) {
            $policyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"
            $includeLocations = if ($policy.conditions.locations.includeLocations) { ($policy.conditions.locations.includeLocations -join ', ') } else { 'None' }
            $excludeLocations = if ($policy.conditions.locations.excludeLocations) { ($policy.conditions.locations.excludeLocations -join ', ') } else { 'None' }
            $grantControls = if ($policy.grantControls.builtInControls) { ($policy.grantControls.builtInControls -join ', ') } else { 'None' }
            $mdInfo += "| ✅ | [$(Get-SafeMarkdown $policy.displayName)]($policyLink) | $($policy.state) | $includeLocations | $excludeLocations | $grantControls |`n"
        }

        foreach ($policy in $alternativePolicies) {
            $policyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"
            $includeLocations = if ($policy.conditions.locations.includeLocations) { ($policy.conditions.locations.includeLocations -join ', ') } else { 'None' }
            $excludeLocations = if ($policy.conditions.locations.excludeLocations) { ($policy.conditions.locations.excludeLocations -join ', ') } else { 'None' }
            $grantControls = if ($policy.grantControls.builtInControls) { ($policy.grantControls.builtInControls -join ', ') } else { 'None' }
            $mdInfo += "| ⚠️ | [$(Get-SafeMarkdown $policy.displayName)]($policyLink) | $($policy.state) | $includeLocations | $excludeLocations | $grantControls |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25379'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
