<#
.SYNOPSIS
    Validates that compliant network controls are used in Conditional Access policies.
.DESCRIPTION
    This test checks if Global Secure Access signaling is enabled, the compliant network named location exists, and at least one enabled Conditional Access policy blocks access from all locations except the compliant network.
.NOTES
    Test ID: 25379
    Category: External Identities
    Required API: Microsoft Graph (beta)
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

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = 'Checking compliant network controls in Conditional Access'
    Write-ZtProgress -Activity $activity -Status 'Querying Global Secure Access signaling status'

    # Query 1: Q1:  Get Global Secure Access Conditional Access signaling settings
    $settings = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/settings/conditionalAccess' -ApiVersion beta

    # Query 2: Q2: Retrieve the compliant network named location
    Write-ZtProgress -Activity $activity -Status 'Querying compliant network named location'

    $namedLocations = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/namedLocations`?`$filter=isof('microsoft.graph.compliantNetworkNamedLocation')" -ApiVersion beta
    # Query 3: Q3: Retrieve enabled Conditional Access policies
    Write-ZtProgress -Activity $activity -Status 'Querying enabled Conditional Access policies'
    $policies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies`?`$filter=state eq 'enabled'" -ApiVersion beta
    #endregion Data Collection

    #region Assessment
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null
    $mdInfo = ''
    $compliantNetworkLocation = $null
    $compliantNetworkLocationId = $null
    $policyMatch = $null
    $investigateMatch = $null

    if ($null -eq $settings -or $settings.signalingStatus -ne 'enabled') {
        $testResultMarkdown = '❌ Global Secure Access signaling is disabled or could not be retrieved.'
        $passed = $false
    }
    else {
        if ($null -eq $namedLocations) {
            $testResultMarkdown = '❌ Compliant network named location does not exist.'
            $passed = $false
        } else {
            $compliantNetworkLocation = $namedLocations | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.compliantNetworkNamedLocation' -and $_.compliantNetworkType -eq 'allTenantCompliantNetworks' }
            if ($null -eq $compliantNetworkLocation) {
                $testResultMarkdown = '❌ Compliant network named location not found or not properly configured.'
                $passed = $false
            } else {
                $compliantNetworkLocationId = $compliantNetworkLocation.id
                if ($null -eq $policies -or !$policies.value) {
                    $testResultMarkdown = '❌ No enabled Conditional Access policies found.'
                    $passed = $false
                } else {
                    # Find policy that blocks all except compliant network (Standard pattern)
                    $policyMatch = $policies| Where-Object {
                        $_.conditions.locations.includeLocations -contains 'All' -and
                        $_.conditions.locations.excludeLocations -contains $compliantNetworkLocationId -and
                        $_.grantControls.builtInControls -contains 'block'
                    }
                    # Investigate: alternative enforcement patterns
                    # Pattern 1: Requires additional controls (MFA, device compliance) for non-compliant networks
                    $investigateMatchPattern1 = $policies | Where-Object {
                        $_.conditions.locations.excludeLocations -contains $compliantNetworkLocationId -and
                        ($_.grantControls.builtInControls -notcontains 'block')
                    }
                    # Pattern 2: Compliant network in includeLocations rather than excludeLocations
                    $investigateMatchPattern2 = $policies| Where-Object {
                        $_.conditions.locations.includeLocations -contains $compliantNetworkLocationId -and
                        $_.conditions.locations.excludeLocations -notcontains $compliantNetworkLocationId
                    }
                    # Pattern 3: Targets specific applications with compliant network conditions
                    $investigateMatchPattern3 = $policies| Where-Object {
                        ($_.conditions.locations.includeLocations -contains 'All' -or $_.conditions.locations.excludeLocations -contains $compliantNetworkLocationId) -and
                        ($_.conditions.applications.includeApplications -ne 'All')
                    }
                    $investigateMatch = $investigateMatchPattern1 + $investigateMatchPattern2 + $investigateMatchPattern3 | Select-Object -Unique
                    if ($policyMatch) {
                        $testResultMarkdown = "✅ Compliant network controls are configured in Conditional Access.`n`n%TestResult%"
                        $passed = $true
                    } elseif ($investigateMatch) {
                        $testResultMarkdown = "⚠️ Compliant network controls are partially configured. Alternative enforcement pattern requires manual review.`n`n%TestResult%"
                        $passed = $true
                        $customStatus = 'Investigate'
                    } else {
                        $testResultMarkdown = "❌ Compliant network controls are not properly configured.`n`n%TestResult%"
                        $passed = $false
                    }
                }
            }
        }
    }
    #endregion Assessment

    #region Report Generation
    $mdInfo = ''

    # Add Global Secure Access Signaling Status
    $mdInfo += "`n## Global secure access configuration`n`n"
    $mdInfo += "| Setting | Value |`n"
    $mdInfo += "| :--- | :--- |`n"
    $signalingStatusValue = if ($null -ne $settings) { $settings.signalingStatus } else { 'N/A' }
    $mdInfo += "| Signaling status | $signalingStatusValue |`n`n"
    $namedLocationPortal = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations"
    # Add Compliant Network Named Location Details
    if ($compliantNetworkLocation) {
        $mdInfo += "## Compliant network named location`n`n"
        $mdInfo += "| Property | Value |`n"
        $mdInfo += "| :--- | :--- |`n"

        $mdInfo += "| Display name  | [$(get-safeMarkdown($($compliantNetworkLocation.displayName)))]($namedLocationPortal) |`n"
        $mdInfo += "| Network type | $($compliantNetworkLocation.compliantNetworkType) |`n"
        $isTrustedValue = if ($null -ne $compliantNetworkLocation.isTrusted) { $compliantNetworkLocation.isTrusted } else { 'Not specified' }
        $mdInfo += "| Is trusted | $isTrustedValue |`n`n"
        #$displayText = "[$(Get-SafeMarkdown($superUserObj.DisplayName))]($spPortalLink)"
    }

    # Add Conditional Access Policy Details
    if ($passed -or $customStatus -eq 'Investigate') {
        $mdInfo += "## Conditional access policies using compliant network`n`n"
        $mdInfo += "| Status | Policy name | State | Include locations |  Grant controls |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- |`n"

        if ($policyMatch) {
            foreach ($policy in $policyMatch) {
                $includeLocations = if ($policy.conditions.locations.includeLocations) { ($policy.conditions.locations.includeLocations -join ', ') } else { 'None' }
                $excludeLocations = if ($policy.conditions.locations.excludeLocations) { ($policy.conditions.locations.excludeLocations -join ', ') } else { 'None' }
                $grantControls = if ($policy.grantControls.builtInControls) { ($policy.grantControls.builtInControls -join ', ') } else { 'None' }
                $mdInfo += "| ✅ | [$(get-safeMarkdown($($compliantNetworkLocation.displayName)))]($namedLocationPortal)  | $($policy.state) | $includeLocations | $grantControls |`n"
            }
        }

        if ($investigateMatch) {
            foreach ($policy in $investigateMatch) {
                $includeLocations = if ($policy.conditions.locations.includeLocations) { ($policy.conditions.locations.includeLocations -join ', ') } else { 'None' }
                $excludeLocations = if ($policy.conditions.locations.excludeLocations) { ($policy.conditions.locations.excludeLocations -join ', ') } else { 'None' }
                $grantControls = if ($policy.grantControls.builtInControls) { ($policy.grantControls.builtInControls -join ', ') } else { 'None' }
                $mdInfo += "| ⚠️ | [$(get-safeMarkdown($($compliantNetworkLocation.displayName)))]($namedLocationPortal)  | $($policy.state) | $includeLocations  | $grantControls |`n"
            }
        }

        $mdInfo += "`n## Portal Links`n`n"
        $mdInfo += "- [Global Secure Access Settings](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/SessionManagementMenu.ReactView/menuId~/null/sectionId~/null)`n"
        $mdInfo += "- [Conditional Access Named Locations](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations)`n"
        $mdInfo += "- [Conditional Access Policies](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies)`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    #endregion Report Generation

    $params = @{
        TestId             = '25379'
        Title              = 'Compliant network controls are used in conditional access policies',
        Status             = $passed
        Result             = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
