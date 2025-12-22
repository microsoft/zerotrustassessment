<#
.SYNOPSIS
    Checks that all Private Access applications have assigned users or groups
.DESCRIPTION
    Verifies that each Private Access application has at least one user or group assigned to it through appRoleAssignedTo.

.NOTES
    Test ID: 25481
    Category: Global Secure Access
    Required API: servicePrincipals with appRoleAssignedTo expansion
#>

function Test-Assessment-25481 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce','External'),
        TestId = '25481',
        Title = 'All Private Access applications have assigned users or groups',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Private Access applications user and group assignments'
    Write-ZtProgress -Activity $activity -Status 'Querying all Private Access applications'

    # Query Q1: Get all Private Access applications (ids only)
    $privateAccessAppsIds = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals?`$filter=tags/any(c:c eq 'IsAccessibleViaZTNAClient')&`$select=id" -ApiVersion beta

    # Query Q2: Get detailed information including appRoleAssignedTo for each app
    $appDetails = @()
    if ($null -ne $privateAccessAppsIds -and $privateAccessAppsIds.Count -gt 0) {
        foreach ($appId in $privateAccessAppsIds) {
            Write-ZtProgress -Activity $activity -Status "Querying details for application $($appId.id)"
            $appDetail = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals/$($appId.id)?`$select=id,appId,displayName,accountEnabled,appRoleAssignmentRequired&`$expand=appRoleAssignedTo" -ApiVersion beta
            $appDetails += $appDetail
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null
    $appsWithoutAssignments = @()
    $appsWithAssignments = @()

    # Check if any Private Access applications exist
    if (-not $appDetails -or $appDetails.Count -eq 0) {
        $testResultMarkdown = '⚠️ No Private Access application is configured in the tenant, please review the documentation on how to enable Private Access Applications.'
        $customStatus = 'Investigate'
    }
    else {
        # Check each application for assignments
        foreach ($app in $appDetails) {
            if ($null -ne $app.appRoleAssignedTo -and $app.appRoleAssignedTo.Count -gt 0) {
                $appsWithAssignments += $app
            }
            else {
                $appsWithoutAssignments += $app
            }
        }

        # Determine pass/fail
        if ($appsWithoutAssignments.Count -eq 0) {
            $passed = $true
            $testResultMarkdown = "✅ All Private Access applications have assigned users or groups. `n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ Found Private Access applications without assigned users or groups. `n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/EnterpriseApplicationListBladeV3/fromNav/globalSecureAccess/applicationType/GlobalSecureAccessApplication'
    $mdInfo = ''

    if ($appDetails.Count -gt 0) {
        # Build summary table
        $mdInfo += "## [Private Access applications]($portalLink)`n`n"
        $mdInfo += "| Application name | Application id | # Assignments | Status |`n"
        $mdInfo += "|------------------|----------------|---------------|--------|`n"

        foreach ($app in $appDetails) {
            $appName = $app.displayName
            $appId = $app.appId
            $assignmentCount = if ($null -ne $app.appRoleAssignedTo) { $app.appRoleAssignedTo.Count } else { 0 }
            $status = if ($assignmentCount -gt 0) { "✅ Pass" } else { "❌ Fail" }
            $mdInfo += "| $appName | $appId | $assignmentCount | $status |`n"
        }

        # Build detailed assignments table only if there are apps with assignments
        if ($appsWithAssignments.Count -gt 0) {
            $mdInfo += "## Assignment details`n`n"

            foreach ($app in $appDetails) {
                if ($null -ne $app.appRoleAssignedTo -and $app.appRoleAssignedTo.Count -gt 0) {
                    $mdInfo += "### $($app.displayName)`n`n"
                    $mdInfo += "| Principal display name | Principal type | Principal id |`n"
                    $mdInfo += "|------------------------|----------------|--------------|`n"

                    foreach ($assignment in $app.appRoleAssignedTo) {
                        $principalName = $assignment.principalDisplayName
                        $principalType = $assignment.principalType
                        $principalId = $assignment.principalId
                        $mdInfo += "| $principalName | $principalType | $principalId |`n"
                    }

                    $mdInfo += "`n"
                }
            }
        }
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25481'
        Title  = 'All Private Access applications have assigned users or groups'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if Investigate is needed
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
