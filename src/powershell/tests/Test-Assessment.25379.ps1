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

    # Q1: Retrieve Global Secure Access Conditional Access signaling status
    # Query the Global Secure Access settings to determine if Conditional Access signaling is enabled
    try {
        $settings = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/settings/conditionalAccess' -ApiVersion beta -ErrorAction Stop
    }
    catch {
        Write-PSFMessage -Message "Failed to retrieve Global Secure Access Conditional Access settings via Graph: $_" -Tag Test, Graph -Level Warning
        $settings = $null
    }

    # Q2: Retrieve the compliant network named location
    # Query named locations to find the compliant network named location
    Write-ZtProgress -Activity $activity -Status 'Retrieving compliant network named location'
    $namedLocations = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/namedLocations' -Filter "isof('microsoft.graph.compliantNetworkNamedLocation')" -ApiVersion beta

    $compliantNetworkLocation = $namedLocations | Where-Object {
        $_.'@odata.type' -eq '#microsoft.graph.compliantNetworkNamedLocation' -and
        $_.compliantNetworkType -eq 'allTenantCompliantNetworks'
    } | Select-Object -First 1

    # Q3: Retrieve enabled Conditional Access policies that use compliant network location
    # Query all enabled Conditional Access policies to find those that reference the compliant network location
    Write-ZtProgress -Activity $activity -Status 'Retrieving enabled Conditional Access policies'
    $policies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -Filter "state eq 'enabled'" -ApiVersion beta
    #endregion Data Collection

    #region Assessment Logic
    # Evaluation Logic per spec:
    # 1. Check if Q1 signalingStatus equals 'enabled'
    # 2. Check if Q2 returns a valid compliant network named location
    # 3. Check if Q3 contains at least one enabled policy that uses the compliant network location

    # Pass Condition: Q1 enabled AND Q2 valid location AND Q3 has policy matching "block all except compliant network" pattern
    # Investigate Condition: Q1 enabled AND Q2 valid location AND Q3 has policy with alternative pattern
    # Fail Condition: Q1 disabled OR Q2 no location OR Q3 no policies referencing compliant network

    if (-not $settings -or $settings.signalingStatus -ne 'enabled') {
        $passed = $false
        $customStatus = $null
        $testResultMarkdown = if (-not $settings) {
            "❌ **Fail**: Unable to retrieve Global Secure Access signaling settings.`n`n%TestResult%"
        } else {
            "❌ **Fail**: Global Secure Access signaling is disabled. Compliant network controls cannot function without this prerequisite.`n`n%TestResult%"
        }
    }
    elseif (-not $compliantNetworkLocation) {
        $passed = $false
        $customStatus = $null
        $testResultMarkdown = "❌ **Fail**: Compliant network named location does not exist or is not properly configured.`n`n%TestResult%"
    }
    elseif (-not $policies) {
        $passed = $false
        $customStatus = $null
        $testResultMarkdown = "❌ **Fail**: No enabled Conditional Access policies found in the tenant.`n`n%TestResult%"
    }
    else {
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
                 -not ($_.conditions.applications.includeApplications -contains 'All'))
            )
        } | Where-Object { $standardPolicies -notcontains $_ } | Select-Object -Unique

        # Determine overall result per spec
        # NOTE: If at least one policy meets pass criteria, result is pass regardless of alternative patterns
        if ($standardPolicies) {
            $passed = $true
            $customStatus = $null
            $testResultMarkdown = "✅ **Pass**: Compliant network controls are configured in Conditional Access. Global Secure Access signaling is enabled and at least one Conditional Access policy blocks access from all locations except the compliant network.`n`n%TestResult%"
        }
        elseif ($alternativePolicies) {
            $passed = $false
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ **Investigate**: Compliant network controls are partially configured. Global Secure Access signaling is enabled and Conditional Access policies reference the compliant network location, but they use an alternative enforcement pattern that requires manual review to confirm adequate protection.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $customStatus = $null
            $testResultMarkdown = "❌ **Fail**: Compliant network controls are not properly configured. No Conditional Access policies reference the compliant network location.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Portal Links
    $gsaLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Security.ReactView'
    $namedLocationLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations'
    $caPoliciesLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'

    # Build GSA signaling status section
    $gsaSection = ''
    if ($settings) {
        $signalingStatusIcon = if ($settings.signalingStatus -eq 'enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $gsaSection = @"

### [Global Secure Access Signaling Status]($gsaLink)

| Setting | Value |
| :------ | :---- |
| Signaling status | $signalingStatusIcon |
"@
    }
    else {
        $gsaSection = @"

### [Global Secure Access Signaling Status]($gsaLink)

❌ Unable to retrieve Global Secure Access signaling settings.
"@
    }

    # Build compliant network location section
    $locationSection = ''
    if ($compliantNetworkLocation) {
        $isTrustedValue = if ($null -ne $compliantNetworkLocation.isTrusted) {
            if ($compliantNetworkLocation.isTrusted) { '✅ True' } else { '❌ False' }
        } else {
            'Not specified'
        }
        $locationSection = @"

### [Compliant Network Named Location]($namedLocationLink)

| Property | Value |
| :------- | :---- |
| Display name | $(Get-SafeMarkdown $compliantNetworkLocation.displayName) |
| Network type | $($compliantNetworkLocation.compliantNetworkType) |
| Is trusted | $isTrustedValue |
| Location ID | $($compliantNetworkLocation.id) |
"@
    }
    else {
        $locationSection = @"

### [Compliant Network Named Location]($namedLocationLink)

❌ Compliant network named location was not found. Enable Global Secure Access signaling to automatically create this location.
"@
    }

    # Build policy table rows
    $policyTableRows = ''
    if ($policies -and $compliantNetworkLocation) {
        $allRelevantPolicies = @()
        if ($standardPolicies) { $allRelevantPolicies += $standardPolicies }
        if ($alternativePolicies) { $allRelevantPolicies += $alternativePolicies }

        if ($allRelevantPolicies.Count -gt 0) {
            foreach ($policy in $standardPolicies) {
                $policyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"
                $includeLocations = if ($policy.conditions.locations.includeLocations) { ($policy.conditions.locations.includeLocations -join ', ') } else { 'None' }
                $excludeLocations = if ($policy.conditions.locations.excludeLocations) { ($policy.conditions.locations.excludeLocations -join ', ') } else { 'None' }
                $grantControls = if ($policy.grantControls.builtInControls) { ($policy.grantControls.builtInControls -join ', ') } else { 'None' }
                $policyState = Get-FormattedPolicyState $policy.state
                $policyTableRows += "| ✅ | [$(Get-SafeMarkdown $policy.displayName)]($policyLink) | $policyState | $includeLocations | $excludeLocations | $grantControls |`n"
            }

            foreach ($policy in $alternativePolicies) {
                $policyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"
                $includeLocations = if ($policy.conditions.locations.includeLocations) { ($policy.conditions.locations.includeLocations -join ', ') } else { 'None' }
                $excludeLocations = if ($policy.conditions.locations.excludeLocations) { ($policy.conditions.locations.excludeLocations -join ', ') } else { 'None' }
                $grantControls = if ($policy.grantControls.builtInControls) { ($policy.grantControls.builtInControls -join ', ') } else { 'None' }
                $policyState = Get-FormattedPolicyState $policy.state
                $policyTableRows += "| ⚠️ | [$(Get-SafeMarkdown $policy.displayName)]($policyLink) | $policyState | $includeLocations | $excludeLocations | $grantControls |`n"
            }
        }
    }

    # Build policies section
    $policiesSection = ''
    if ($policyTableRows -ne '') {
        $policiesSection = @"

### [Conditional Access Policies Using Compliant Network]($caPoliciesLink)

| Status | Policy name | State | Include locations | Exclude locations | Grant controls |
| :----- | :---------- | :---- | :---------------- | :---------------- | :------------- |
$policyTableRows
"@
    }
    elseif ($policies -and -not $compliantNetworkLocation) {
        $policiesSection = @"

### [Conditional Access Policies]($caPoliciesLink)

Found $($policies.Count) enabled Conditional Access policies, but unable to evaluate compliant network usage without a valid compliant network location.
"@
    }
    elseif (-not $policies) {
        $policiesSection = @"

### [Conditional Access Policies]($caPoliciesLink)

❌ No enabled Conditional Access policies found in the tenant.
"@
    }
    else {
        $policiesSection = @"

### [Conditional Access Policies Using Compliant Network]($caPoliciesLink)

❌ No enabled Conditional Access policies reference the compliant network location.
"@
    }

    # Calculate summary values
    $signalingEnabled = if ($settings -and $settings.signalingStatus -eq 'enabled') { 'True' } else { 'False' }
    $locationExists = if ($compliantNetworkLocation) { 'True' } else { 'False' }
    $standardPolicyCount = if ($standardPolicies) { $standardPolicies.Count } else { 0 }
    $alternativePolicyCount = if ($alternativePolicies) { $alternativePolicies.Count } else { 0 }

    # Build report using format template
    $formatTemplate = @'
{0}{1}{2}

**Summary:**

- Global Secure Access signaling enabled: {3}
- Compliant network location exists: {4}
- Policies using standard pattern (block all except compliant): {5}
- Policies using alternative patterns: {6}
'@

    $mdInfo = $formatTemplate -f $gsaSection, $locationSection, $policiesSection, $signalingEnabled, $locationExists, $standardPolicyCount, $alternativePolicyCount
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
