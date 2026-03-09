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
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Cross-Tenant Access Policy configuration'
    Write-ZtProgress -Activity $activity -Status 'Retrieving default cross-tenant access policy'

    # Query 1: Retrieve the default cross-tenant access policy configuration
    $crossTenantAccessPolicy = $null
    try {
        $crossTenantAccessPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/crossTenantAccessPolicy/default' -ApiVersion beta
    } catch {
        Write-PSFMessage "Unable to retrieve cross-tenant access policy: $_" -Level Warning
    }

    # Initialize variables
    $isServiceDefault = $null
    $usersAndGroupsAccessType = $null
    $usersAndGroupsTargets = @()
    $usersAndGroupsTargetTypes = @()
    $applicationsAccessType = $null
    $applicationsTargets = @()
    $applicationsTargetTypes = @()

    # Extract data
    if ($null -ne $crossTenantAccessPolicy) {
        $isServiceDefault = $crossTenantAccessPolicy.isServiceDefault
        $b2bOutbound = $crossTenantAccessPolicy.b2bCollaborationOutbound

        if ($null -ne $b2bOutbound) {
            # Extract users and groups settings
            if ($b2bOutbound.usersAndGroups) {
                $usersAndGroupsAccessType = $b2bOutbound.usersAndGroups.accessType
                if ($b2bOutbound.usersAndGroups.targets.Count -gt 0) {
                    $usersAndGroupsTargets = @($b2bOutbound.usersAndGroups.targets.target)
                    $usersAndGroupsTargetTypes = @($b2bOutbound.usersAndGroups.targets.targetType)
                }
            }

            # Extract applications settings
            if ($b2bOutbound.applications) {
                $applicationsAccessType = $b2bOutbound.applications.accessType
                if ($b2bOutbound.applications.targets.Count -gt 0) {
                    $applicationsTargets = @($b2bOutbound.applications.targets.target)
                    $applicationsTargetTypes = @($b2bOutbound.applications.targets.targetType)
                }
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    if ($null -eq $crossTenantAccessPolicy) {
        $testResultMarkdown = "❌ Unable to retrieve cross-tenant access policy configuration.`n`n%TestResult%"
    }
    else {
        # Define evaluation conditions
        $fullAllowCondition = $usersAndGroupsAccessType -eq 'allowed' -and
                              $usersAndGroupsTargets -contains 'AllUsers' -and
                              $usersAndGroupsTargetTypes -contains 'user' -and
                              $applicationsAccessType -eq 'allowed' -and
                              $applicationsTargets -contains 'AllApplications' -and
                              $applicationsTargetTypes -contains 'application'

        $fullBlockCondition = $usersAndGroupsAccessType -eq 'blocked' -and
                              $usersAndGroupsTargets -contains 'AllUsers' -and
                              $usersAndGroupsTargetTypes -contains 'user' -and
                              $applicationsAccessType -eq 'blocked' -and
                              $applicationsTargets -contains 'AllApplications' -and
                              $applicationsTargetTypes -contains 'application'

        # Evaluate and set test result
        if ($isServiceDefault -or $fullAllowCondition) {
            $passed = $false
            $testResultMarkdown = "❌ Default outbound B2B collaboration allows all users to access all applications in external organizations without governance.`n`n%TestResult%"
        }
        elseif ($fullBlockCondition) {
            $passed = $true
            $testResultMarkdown = "✅ Default outbound B2B collaboration is blocked for all users and all applications, requiring explicit cross-tenant access policies for external collaboration.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ Default outbound B2B collaboration has partial restrictions configured; review settings to ensure they align with organizational security policies.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($null -ne $crossTenantAccessPolicy) {
        $reportTitle = 'Default Cross-tenant access settings - Outbound B2B collaboration'
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/CrossTenantAccessSettings'

        # Prepare display values
        $isServiceDefaultStr = if ($null -eq $isServiceDefault) { 'N/A' } elseif ($isServiceDefault) { 'true' } else { 'false' }
        $usersAndGroupsAccessTypeDisplay = if ([string]::IsNullOrEmpty($usersAndGroupsAccessType)) { 'N/A' } else { $usersAndGroupsAccessType }
        $applicationsAccessTypeDisplay = if ([string]::IsNullOrEmpty($applicationsAccessType)) { 'N/A' } else { $applicationsAccessType }

        # Resolve and display users and groups (first 5)
        $displayUserTarget = 'N/A'
        if ($b2bOutbound.usersAndGroups.targets.Count -gt 0) {
            $targets = $b2bOutbound.usersAndGroups.targets | Select-Object -First 5

            $userTargets = $targets | Where-Object { $_.targetType -eq 'user' } | Select-Object -ExpandProperty target
            $groupTargets = $targets | Where-Object { $_.targetType -eq 'group' } | Select-Object -ExpandProperty target

            # Resolve all user and group targets at once
            $resolvedNames = @()

            if ($userTargets.Count -gt 0) {
                $resolvedUsers = Get-UserNameFromId -TargetsArray $userTargets -Database $Database
                $resolvedNames += $resolvedUsers
            }

            if ($groupTargets.Count -gt 0) {
                $resolvedGroups = Get-GroupNameFromId -TargetsArray $groupTargets
                $resolvedNames += $resolvedGroups
            }

            $displayUserTarget = $resolvedNames -join ', '
            if ($b2bOutbound.usersAndGroups.targets.Count -gt 5) {
                $displayUserTarget += ', ...'
            }
        }

        # Resolve and display applications (first 5)
        $displayAppTarget = 'N/A'
        if ($b2bOutbound.applications.targets.Count -gt 0) {
            $targets = $b2bOutbound.applications.targets | Select-Object -First 5
            $resolvedApps = Get-ApplicationNameFromId -TargetsArray $targets.target -Database $Database

            $displayAppTarget = $resolvedApps -join ', '
            if ($b2bOutbound.applications.targets.Count -gt 5) {
                $displayAppTarget += ', ...'
            }
        }

        # Calculate status indicators
        $isServiceDefaultStatus = if ($isServiceDefaultStr -eq 'false') { '✅' } else { '❌' }
        $usersAccessStatus = if ($usersAndGroupsAccessTypeDisplay -eq 'blocked') { '✅' } else { '❌' }
        $usersTargetStatus = if ($usersAndGroupsTargets -contains 'AllUsers' -and $usersAndGroupsTargetTypes -contains 'user') { '✅' } else { '❌' }
        $appsAccessStatus = if ($applicationsAccessTypeDisplay -eq 'blocked') { '✅' } else { '❌' }
        $appsTargetStatus = if ($applicationsTargets -contains 'AllApplications' -and $applicationsTargetTypes -contains 'application') { '✅' } else { '❌' }

        $formatTemplate = @'

## [{0}]({1})

| Setting | Configured value | Expected value | Status |
| :------ | :--------------- | :------------- | :----: |
{2}

'@

        $tableRows = "| Is service default | $isServiceDefaultStr | false | $isServiceDefaultStatus |`n"
        $tableRows += "| Users and groups access type | $usersAndGroupsAccessTypeDisplay | blocked | $usersAccessStatus |`n"
        $tableRows += "| Users and groups target | $displayUserTarget | AllUsers | $usersTargetStatus |`n"
        $tableRows += "| Applications access type | $applicationsAccessTypeDisplay | blocked | $appsAccessStatus |`n"
        $tableRows += "| Applications target | $displayAppTarget | AllApplications | $appsTargetStatus |"

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25378'
        Title  = 'External collaboration is governed by explicit Cross-Tenant Access Policies'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
