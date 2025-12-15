<#
.SYNOPSIS
    TLS inspection is enabled and correctly configured for outbound traffic in Global Secure Access.
.DESCRIPTION
    Verifies that a TLS Inspection policy is properly configured. It will fail if no TLS Inspection policy exists, if the policy is not linked to a Security Profile, or if no Conditional Access policy assigning that Security Profile can be identified.
#>

function Test-Assessment-25411 {
    [ZtTest(
        Category = 'Network',
        ImplementationCost = 'Low',
        MinimumLicense = ('Free'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce','External'),
        TestId = 25411,
        Title = 'TLS inspection is enabled and correctly configured for outbound traffic in Global Secure Access',
        UserImpact = 'Low'
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
    $tlsPolicyIds = @()
    foreach ($tlsPolicy in $tlsInspectionPolicies) {
        $tlsPolicyIds += $tlsPolicy.id
    }
    #$tlsPolicyIds = @("c363e54f-d24a-46c7-b88d-d9dc8a0eaffe")

    # Search for TLS inspection policy in filtering profiles
    $enabledSecurityProfiles = @()
    $enabledPolicies = @()
    $securityProfile = $filteringProfiles | Where-Object { $_.priority -ne 65000 }
    $baseLineProfile = $filteringProfiles | Where-Object { $_.priority -eq 65000 }
    foreach ($baseLineProfilePolicy in $baseLineProfile.policies) {
        # Check if the policy ID matches a TLS inspection policy
        if ($baseLineProfilePolicy.id -in $tlsPolicyIds) {
            # Check if the policy state is enabled
            if ($baseLineProfilePolicy.state -eq 'enabled') {
                $enabledPolicies += [PSCustomObject]@{
                    "TLS Profile Id"   = $baseLineProfile.id
                    "TLS Profile Name" = $baseLineProfile.name
                    "TLS Policy Id"    = $baseLineProfilePolicy.policy.id
                    "TLS Policy Name"  = $baseLineProfilePolicy.policy.name
                    "TLS Policy State" = $baseLineProfilePolicy.state
                    "TLS Profile State" = $baseLineProfile.state
                    "TLS Profile Priority" = $baseLineProfile.priority
                }

            }
        }
    }

    foreach ($securityProfileItem in $securityProfile) {
        foreach ($securityProfileCAPolicy in $securityProfileItem.ConditionalAccessPolicies) {
            $assignedCAPolicy = $allCAPolicies | Where-Object { $_.id -eq $securityProfileCAPolicy.id }
            if($true){#($assignedCAPolicy.state -eq 'enabled') {
                $enabledSecurityProfiles += [PSCustomObject]@{
                "TLS Profile Id"   = $securityProfileItem.id
                "TLS Profile Name" = $securityProfileItem.name
                "CA Policy Id"    = $assignedCAPolicy.id
                "Policy Name"  = $assignedCAPolicy.displayName
                "Policy State" = $assignedCAPolicy.state
                "TLS Profile State" = $securityProfileItem.state
                "TLS Profile Priority" = $securityProfileItem.priority
            }
        }
            }
        }
        $securityEnabledProfiles = $enabledSecurityProfiles | where-object { $_.'Policy State' -eq 'enabled' -and $_.'TLS Profile State' -eq 'enabled' }
        # Determine test result
        if ($enabledPolicies.Count -gt 0 -or $securityEnabledProfiles.Count -gt 0) {
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

    if ($enabledPolicies.Count -gt 0) {
        $mdInfo += "`n## TLS Inspection Policies Linked to Base Line Profiles`n`n"
        $mdInfo += "| Profile Name | Policy Name | Policy State | Profile State |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"
        foreach ($policy in $enabledPolicies) {
            $mdInfo += "| $($policy.'TLS Profile Name') | $($policy.'TLS Policy Name') | $($policy.'TLS Policy State') | $($policy.'TLS Profile State') |`n"
        }
    }

    if ($enabledSecurityProfiles.Count -gt 0) {
        $mdInfo += "`n## Security Profiles Linked to Conditional Access Policies`n`n"
        $mdInfo += "| Profile Name | CA Policy Name | CA Policy State | Profile State | Profile Priority |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- |`n"
        foreach ($profile in $enabledSecurityProfiles) {
            $mdInfo += "| $($profile.'TLS Profile Name') | $($profile.'Policy Name') | $($profile.'Policy State') | $($profile.'TLS Profile State') | $($profile.'TLS Profile Priority') |`n"
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
