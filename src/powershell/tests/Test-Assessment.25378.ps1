<#
.SYNOPSIS
    Validates that external collaboration is governed by explicit Cross-Tenant Access Policies.

.DESCRIPTION
    This test checks if default outbound B2B collaboration settings block all users and all applications,
    requiring explicit cross-tenant access policies for external collaboration.

.NOTES
    Test ID: 25378
    Category: External Identities
    Required API: policies/crossTenantAccessPolicy/default
#>

function Test-Assessment-25378 {
    [ZtTest(
        Category = 'External Identities',
        ImplementationCost = 'Medium',
        MinimumLicense = 'AAD_PREMIUM',
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 25378,
        Title = 'External collaboration is governed by explicit Cross-Tenant Access Policies',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Cross-Tenant Access Policy configuration'
    Write-ZtProgress -Activity $activity -Status 'Retrieving default cross-tenant access policy'

    # Query 1: Retrieve the default cross-tenant access policy configuration
    $defaultPolicy = $null
    try {
        $defaultPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/crossTenantAccessPolicy/default' -ApiVersion beta
    } catch {
        Write-PSFMessage "Unable to retrieve cross-tenant access policy: $_" -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    # Initialize evaluation variables
    $isServiceDefault = $false
    $usersAndGroupsAccessType = 'N/A'
    $usersAndGroupsTargets = @('N/A')
    $applicationsAccessType = 'N/A'
    $applicationsTargets = @('N/A')

    if ($null -eq $defaultPolicy) {
        $passed = $false
        $testResultMarkdown = "❌ Unable to retrieve cross-tenant access policy configuration.`n`n%TestResult%"
    } else {
        # Extract configuration values
        $isServiceDefault = $defaultPolicy.isServiceDefault

        # Extract B2B Collaboration Outbound settings
        $b2bOutbound = $defaultPolicy.b2bCollaborationOutbound

        if ($null -ne $b2bOutbound) {
            # Users and Groups settings
            if ($b2bOutbound.usersAndGroups) {
                $usersAndGroupsAccessType = $b2bOutbound.usersAndGroups.accessType
                if ($b2bOutbound.usersAndGroups.targets -and $b2bOutbound.usersAndGroups.targets.Count -gt 0) {
                    # wrap in array to handle single vs multiple targets
                    $usersAndGroupsTargets = @($b2bOutbound.usersAndGroups.targets.target)
                }
            }

            # Applications settings
            if ($b2bOutbound.applications) {
                $applicationsAccessType = $b2bOutbound.applications.accessType
                if ($b2bOutbound.applications.targets -and $b2bOutbound.applications.targets.Count -gt 0) {
                    # wrap in array to handle single vs multiple targets
                    $applicationsTargets = @($b2bOutbound.applications.targets.target)
                }
            }
        }

        # Evaluation logic
        # Check if using service default (automatic fail)
        if ($isServiceDefault -eq $true) {
            $passed = $false
            $testResultMarkdown = "❌ Default outbound B2B collaboration allows all users to access all applications in external organizations without governance.`n`n%TestResult%"
        }
        # Check for full allow (Fail condition)
        elseif ($usersAndGroupsAccessType -eq 'allowed' -and $usersAndGroupsTargets -contains 'AllUsers' -and
                $applicationsAccessType -eq 'allowed' -and $applicationsTargets -contains 'AllApplications') {
            $passed = $false
            $testResultMarkdown = "❌ Default outbound B2B collaboration allows all users to access all applications in external organizations without governance.`n`n%TestResult%"
        }
        # Check for full block (Pass condition)
        elseif ($usersAndGroupsAccessType -eq 'blocked' -and $usersAndGroupsTargets -contains 'AllUsers' -and
                $applicationsAccessType -eq 'blocked' -and $applicationsTargets -contains 'AllApplications') {
            $passed = $true
            $testResultMarkdown = "✅ Default outbound B2B collaboration is blocked for all users and all applications, requiring explicit cross-tenant access policies for external collaboration.`n`n%TestResult%"
        }
        # Partial restrictions (Investigate)
        else {
            $passed = $false
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ Default outbound B2B collaboration has partial restrictions configured; review settings to ensure they align with organizational security policies.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($null -ne $defaultPolicy) {

        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/CrossTenantAccessSettings'

        # Details needed to generate the summary table
        $isServiceDefaultStr = if ($null -eq $isServiceDefault) { 'N/A' } elseif ($isServiceDefault) { 'true' } else { 'false' }
        $isServiceDefaultStatus = if ($isServiceDefaultStr -eq 'false') { '✅' } else { '❌' }
        $usersAccessStatus = if ($usersAndGroupsAccessType -eq 'blocked') { '✅' } else { '❌' }
        $usersTargetStatus = if ($usersAndGroupsTargets -contains 'AllUsers') { '✅' } else { '❌' }
        $appsAccessStatus = if ($applicationsAccessType -eq 'blocked') { '✅' } else { '❌' }
        $appsTargetStatus = if ($applicationsTargets -contains 'AllApplications') { '✅' } else { '❌' }

        $displayUserTarget = if ($null -ne $usersAndGroupsTargets -and $usersAndGroupsTargets.Count -gt 0) { $usersAndGroupsTargets[0] } else { 'N/A' }
        $displayAppTarget = if ($null -ne $applicationsTargets -and $applicationsTargets.Count -gt 0) { $applicationsTargets[0] } else { 'N/A' }

        # Summary Section
        $mdInfo += "`n## [Default Cross-Tenant Access Settings - Outbound B2B Collaboration]($portalLink)`n`n"
        $mdInfo += "| Setting | Configured Value | Expected Value | Status |`n"
        $mdInfo += "| :--- | :--- | :--- | :---: |`n"
        $mdInfo += "| Is Service Default | $isServiceDefaultStr | false | $isServiceDefaultStatus |`n"
        $mdInfo += "| Users and Groups Access Type | $usersAndGroupsAccessType | blocked | $usersAccessStatus |`n"
        $mdInfo += "| Users and Groups Target | $displayUserTarget | AllUsers | $usersTargetStatus |`n"
        $mdInfo += "| Applications Access Type | $applicationsAccessType | blocked | $appsAccessStatus |`n"
        $mdInfo += "| Applications Target | $displayAppTarget | AllApplications | $appsTargetStatus |`n"
    }

    # Replace placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25378'
        Title  = 'External collaboration is governed by explicit Cross-Tenant Access Policies'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($customStatus -eq 'Investigate') {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
