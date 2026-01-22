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
    $crossTenantAccessPolicy = $null
    try {
        $crossTenantAccessPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/crossTenantAccessPolicy/default' -ApiVersion beta
    } catch {
        Write-PSFMessage "Unable to retrieve cross-tenant access policy: $_" -Level Warning
    }

    # Initialize variables and Extract data
    $isServiceDefault = $false
    $usersAndGroupsAccessType = 'N/A'
    $usersAndGroupsTargets = @('N/A')
    $applicationsAccessType = 'N/A'
    $applicationsTargets = @('N/A')

    if ($null -ne $crossTenantAccessPolicy) {
        $isServiceDefault = $crossTenantAccessPolicy.isServiceDefault
        $b2bOutbound = $crossTenantAccessPolicy.b2bCollaborationOutbound

        if ($null -ne $b2bOutbound) {
            if ($b2bOutbound.usersAndGroups) {
                $usersAndGroupsAccessType = $b2bOutbound.usersAndGroups.accessType
                if ($b2bOutbound.usersAndGroups.targets -and $b2bOutbound.usersAndGroups.targets.Count -gt 0) {
                    $usersAndGroupsTargets = @($b2bOutbound.usersAndGroups.targets.target)
                }
            }

            if ($b2bOutbound.applications) {
                $applicationsAccessType = $b2bOutbound.applications.accessType
                if ($b2bOutbound.applications.targets -and $b2bOutbound.applications.targets.Count -gt 0) {
                    $applicationsTargets = @($b2bOutbound.applications.targets.target)
                }
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $investigateFlag = $false


    if ($null -eq $crossTenantAccessPolicy) {
        $testResultMarkdown = "❌ Unable to retrieve cross-tenant access policy configuration.`n`n%TestResult%"
    }
    else {
        # Define evaluation conditions
        $fullAllowCondition = $usersAndGroupsAccessType -eq 'allowed' -and
                              $usersAndGroupsTargets -contains 'AllUsers' -and
                              $applicationsAccessType -eq 'allowed' -and
                              $applicationsTargets -contains 'AllApplications'

        $fullBlockCondition = $usersAndGroupsAccessType -eq 'blocked' -and
                              $usersAndGroupsTargets -contains 'AllUsers' -and
                              $applicationsAccessType -eq 'blocked' -and
                              $applicationsTargets -contains 'AllApplications'

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
            $investigateFlag = $true
            $testResultMarkdown = "⚠️ Default outbound B2B collaboration has partial restrictions configured; review settings to ensure they align with organizational security policies.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($null -ne $crossTenantAccessPolicy) {
        $reportTitle = 'Default Cross-Tenant Access Settings - Outbound B2B Collaboration'
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/CrossTenantAccessSettings'

        $isServiceDefaultStr = if ($null -eq $isServiceDefault) { 'N/A' } elseif ($isServiceDefault) { 'true' } else { 'false' }
        $isServiceDefaultStatus = if ($isServiceDefaultStr -eq 'false') { '✅' } else { '❌' }
        $usersAccessStatus = if ($usersAndGroupsAccessType -eq 'blocked') { '✅' } else { '❌' }
        $usersTargetStatus = if ($usersAndGroupsTargets -contains 'AllUsers') { '✅' } else { '❌' }
        $appsAccessStatus = if ($applicationsAccessType -eq 'blocked') { '✅' } else { '❌' }
        $appsTargetStatus = if ($applicationsTargets -contains 'AllApplications') { '✅' } else { '❌' }

        $displayUserTarget = if ($null -ne $usersAndGroupsTargets -and $usersAndGroupsTargets.Count -gt 0) { $usersAndGroupsTargets[0] } else { 'N/A' }
        $displayAppTarget = if ($null -ne $applicationsTargets -and $applicationsTargets.Count -gt 0) { $applicationsTargets[0] } else { 'N/A' }

        $formatTemplate = @'

## [{0}]({1})

| Setting | Configured Value | Expected Value | Status |
| :------ | :--------------- | :------------- | :----: |
{2}

'@

        $tableRows = "| Is Service Default | $isServiceDefaultStr | false | $isServiceDefaultStatus |`n"
        $tableRows += "| Users and Groups Access Type | $usersAndGroupsAccessType | blocked | $usersAccessStatus |`n"
        $tableRows += "| Users and Groups Target | $displayUserTarget | AllUsers | $usersTargetStatus |`n"
        $tableRows += "| Applications Access Type | $applicationsAccessType | blocked | $appsAccessStatus |`n"
        $tableRows += "| Applications Target | $displayAppTarget | AllApplications | $appsTargetStatus |"

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

    if ($investigateFlag -eq $true) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
