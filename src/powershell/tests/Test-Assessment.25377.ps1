<#
.SYNOPSIS
    Validates that Universal Tenant Restrictions (UTR) are configured to block access to unauthorized external tenants.

.DESCRIPTION
    This test checks if Universal Tenant Restrictions are properly configured by verifying:
    1. Global Secure Access network packet tagging is enabled
    2. Tenant restrictions v2 default policy blocks all users and all applications

.NOTES
    Test ID: 25377
    Category: Global Secure Access
    Required API: networkAccess/settings/crossTenantAccess (beta), policies/crossTenantAccessPolicy/default (beta)
#>

function Test-Assessment-25377 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('AAD_PREMIUM', 'Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 25377,
        Title = 'Users accessing external applications from corporate devices are blocked unless explicitly authorized by tenant restrictions policies',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Universal Tenant Restrictions configuration'
    Write-ZtProgress -Activity $activity -Status 'Querying Global Secure Access network packet tagging status'

    # Q1: Get Global Secure Access Universal Tenant Restrictions status
    try {
        $crossTenantAccessSettings = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/settings/crossTenantAccess' -ApiVersion beta -ErrorAction Stop
        $networkPacketTaggingStatus = $crossTenantAccessSettings.networkPacketTaggingStatus
    }
    catch {
        Write-PSFMessage "Failed to retrieve Global Secure Access cross-tenant access settings: $_" -Tag Test -Level Warning
        $networkPacketTaggingStatus = $null
    }

    Write-ZtProgress -Activity $activity -Status 'Querying tenant restrictions v2 default policy'

    # Q2: Get default cross-tenant access policy tenant restrictions configuration
    try {
        $defaultCrossTenantPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/crossTenantAccessPolicy/default' -ApiVersion beta -ErrorAction Stop
        $tenantRestrictions = $defaultCrossTenantPolicy.tenantRestrictions
    }
    catch {
        Write-PSFMessage "Failed to retrieve cross-tenant access policy: $_" -Tag Test -Level Warning
        $tenantRestrictions = $null
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false

    # Check Q1: Network packet tagging must be enabled
    if ($null -eq $networkPacketTaggingStatus -or $networkPacketTaggingStatus -ne 'enabled') {
        $statusText = if ($null -eq $networkPacketTaggingStatus) {
            'not configured'
        }
        else {
            $networkPacketTaggingStatus
        }
        $testResultMarkdown = "❌ Universal Tenant Restrictions are not fully configured. Network packet tagging is $statusText (expected: enabled). `n`n%TestResult%"
        $passed = $false
    }
    else {
        # Check if tenant restrictions policy was retrieved successfully
        if ($null -eq $tenantRestrictions) {
            $testResultMarkdown = "❌ Unable to retrieve tenant restrictions v2 default policy. Network packet tagging is enabled, but policy configuration could not be evaluated.`n`n%TestResult%"
            $passed = $false
        }
        else {
            # Validate usersAndGroups configuration
            $usersAndGroupsValid = $false
            if ($tenantRestrictions.usersAndGroups) {
                $usersAccessType = $tenantRestrictions.usersAndGroups.accessType
                $usersTargets = $tenantRestrictions.usersAndGroups.targets

                # Check if accessType is blocked and targets contain AllUsers
                if ($usersAccessType -eq 'blocked' -and $usersTargets) {
                    $usersAndGroupsValid = @($usersTargets.target) -contains 'AllUsers'
                }
            }

            # Validate applications configuration
            $applicationsValid = $false
            if ($tenantRestrictions.applications) {
                $appsAccessType = $tenantRestrictions.applications.accessType
                $appsTargets = $tenantRestrictions.applications.targets

                # Check if accessType is blocked and targets contain AllApplications
                if ($appsAccessType -eq 'blocked' -and $appsTargets) {
                    $applicationsValid = @($appsTargets.target) -contains 'AllApplications'
                }
            }

            # Both must be valid for test to pass
            if ($usersAndGroupsValid -and $applicationsValid) {
                $testResultMarkdown = "✅ Universal Tenant Restrictions are configured. Network packet tagging is enabled and the default tenant restrictions v2 policy blocks all users from accessing all applications in unauthorized external tenants. `n`n%TestResult%"
                $passed = $true
            }
            else {
                $testResultMarkdown = "❌ Universal Tenant Restrictions are not fully configured. Tenant restrictions v2 policy does not block all users and all applications by default. `n`n%TestResult%"
                $passed = $false
            }
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Calculate all values and status icons
    # Network Packet Tagging
    $networkPacketDisplay = if ($null -eq $networkPacketTaggingStatus) { 'Not configured' } else { $networkPacketTaggingStatus }
    $networkPacketIcon = if ($networkPacketTaggingStatus -eq 'enabled') { '✅' } else { '❌' }

    # Users & Groups Access Type
    $usersAccessTypeDisplay = if ($tenantRestrictions.usersAndGroups) { $tenantRestrictions.usersAndGroups.accessType } else { 'Not configured' }
    $usersAccessIcon = if ($usersAccessTypeDisplay -eq 'blocked') { '✅' } else { '❌' }

    # Users & Groups Target - extract targets array (no GUID resolution for users)
    $usersTargetsArray = @()
    if ($tenantRestrictions.usersAndGroups.targets) {
        $usersTargetsArray = @($tenantRestrictions.usersAndGroups.targets | ForEach-Object { $_.target })
    }

    $usersTargetDisplay = if ($usersTargetsArray.Count -gt 0) { $usersTargetsArray[0] } else { '' }
    $usersTargetIcon = if ($usersTargetsArray -contains 'AllUsers') { '✅' } else { '❌' }

    # Applications Access Type
    $appsAccessTypeDisplay = if ($tenantRestrictions.applications) { $tenantRestrictions.applications.accessType } else { 'Not configured' }
    $appsAccessIcon = if ($appsAccessTypeDisplay -eq 'blocked') { '✅' } else { '❌' }

    # Applications Target - extract targets array and resolve GUIDs
    $appsTargetsArray = @()
    if ($tenantRestrictions.applications.targets) {
        $appsTargetsArray = @($tenantRestrictions.applications.targets | ForEach-Object { $_.target })
    }

    # Resolve application GUIDs to display names
    $resolvedAppsArray = Get-ApplicationNameFromId -TargetsArray $appsTargetsArray -Database $Database

    # Display first 5 items with "..." if more exist
    $maxItems = 5
    $appsTargetDisplay = if ($resolvedAppsArray.Count -le $maxItems) {
        $resolvedAppsArray -join ', '
    } else {
        ($resolvedAppsArray[0..($maxItems - 1)] -join ', ') + ' ...'
    }
    $appsTargetIcon = if ($appsTargetsArray -contains 'AllApplications') { '✅' } else { '❌' }

    # Build configuration table using format template
    $formatTemplate = @'

## [{0}]({1})

| Setting | Current Value | Expected Value | Status |
| :------ | :------------ | :------------- | :----: |
{2}

'@

    $reportTitle = 'Universal Tenant Restrictions Configuration'
    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/TenantRestrictions.ReactView/isDefault~/true/name//id/'

    $tableRows = "| Network Packet Tagging Status | $networkPacketDisplay | enabled | $networkPacketIcon |`n"
    $tableRows += "| Users & Groups Access Type | $usersAccessTypeDisplay | blocked | $usersAccessIcon |`n"
    $tableRows += "| Users & Groups Target | $usersTargetDisplay | AllUsers | $usersTargetIcon |`n"
    $tableRows += "| Applications Access Type | $appsAccessTypeDisplay | blocked | $appsAccessIcon |`n"
    $tableRows += "| Applications Target | $appsTargetDisplay | AllApplications | $appsTargetIcon |"

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25377'
        Title  = 'Users accessing external applications from corporate devices are blocked unless explicitly authorized by tenant restrictions policies'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
