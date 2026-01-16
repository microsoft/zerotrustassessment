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
        Title = 'Universal Tenant Restrictions block access to unauthorized external tenants',
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
        # Validate usersAndGroups configuration
        $usersAndGroupsValid = $false
        if ($tenantRestrictions.usersAndGroups) {
            $usersAccessType = $tenantRestrictions.usersAndGroups.accessType
            $usersTargets = $tenantRestrictions.usersAndGroups.targets

            # Check if accessType is blocked and targets contain AllUsers
            if ($usersAccessType -eq 'blocked' -and $usersTargets) {
                $hasAllUsers = $usersTargets | Where-Object { $_.target -eq 'AllUsers' }
                $usersAndGroupsValid = $null -ne $hasAllUsers
            }
        }

        # Validate applications configuration
        $applicationsValid = $false
        if ($tenantRestrictions.applications) {
            $appsAccessType = $tenantRestrictions.applications.accessType
            $appsTargets = $tenantRestrictions.applications.targets

            # Check if accessType is blocked and targets contain AllApplications
            if ($appsAccessType -eq 'blocked' -and $appsTargets) {
                $hasAllApplications = $appsTargets | Where-Object { $_.target -eq 'AllApplications' }
                $applicationsValid = $null -ne $hasAllApplications
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
    #endregion Assessment Logic

    #region Report Generation
    # Calculate all values and status icons
    # Network Packet Tagging
    $networkPacketDisplay = if ($null -eq $networkPacketTaggingStatus) { 'Not configured' } else { $networkPacketTaggingStatus }
    $networkPacketIcon = if ($networkPacketTaggingStatus -eq 'enabled') { '✅ Pass' } else { '❌ Fail' }

    # Users & Groups Access Type
    $usersAccessType = if ($tenantRestrictions.usersAndGroups) { $tenantRestrictions.usersAndGroups.accessType } else { 'Not configured' }
    $usersAccessIcon = if ($usersAccessType -eq 'blocked') { '✅ Pass' } else { '❌ Fail' }

    # Users & Groups Target
    $usersTargets = if ($tenantRestrictions.usersAndGroups.targets) {
        ($tenantRestrictions.usersAndGroups.targets | ForEach-Object { $_.target }) -join ', '
    } else {
        'Not configured'
    }
    $usersTargetIcon = if ($usersTargets -like '*AllUsers*') { '✅ Pass' } else { '❌ Fail' }

    # Applications Access Type
    $appsAccessType = if ($tenantRestrictions.applications) { $tenantRestrictions.applications.accessType } else { 'Not configured' }
    $appsAccessIcon = if ($appsAccessType -eq 'blocked') { '✅ Pass' } else { '❌ Fail' }

    # Applications Target
    $appsTargets = if ($tenantRestrictions.applications.targets) {
        ($tenantRestrictions.applications.targets | ForEach-Object { $_.target }) -join ', '
    } else {
        'Not configured'
    }
    $appsTargetIcon = if ($appsTargets -like '*AllApplications*') { '✅ Pass' } else { '❌ Fail' }

    # Build clean configuration table
    $mdInfo = @"

#### [Universal Tenant Restrictions Configuration](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/SessionManagementMenu.ReactView/menuId~/null/sectionId~/null)

| Setting | Current Value | Expected Value | Status |
| :--- | :--- | :--- | :---: |
| Network Packet Tagging Status | $networkPacketDisplay | enabled | $networkPacketIcon |
| Users & Groups Access Type | $usersAccessType | blocked | $usersAccessIcon |
| Users & Groups Target | $usersTargets | AllUsers | $usersTargetIcon |
| Applications Access Type | $appsAccessType | blocked | $appsAccessIcon |
| Applications Target | $appsTargets | AllApplications | $appsTargetIcon |
"@

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25377'
        Title  = 'Universal Tenant Restrictions block unauthorized external tenant access'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
