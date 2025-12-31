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

    # Query Q1: Single optimized query for all Private Access applications with assignments
    $privateAccessApps = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals?`$filter=tags/any(c:c eq 'IsAccessibleViaZTNAClient')&`$expand=appRoleAssignedTo&`$select=id,appId,displayName,accountEnabled,appRoleAssignmentRequired" -ApiVersion beta
    #endregion Data Collection

    #region Assessment Logic
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null

    # Check if any Private Access applications exist
    if (-not $privateAccessApps -or $privateAccessApps.Count -eq 0) {
        $testResultMarkdown = '⚠️ No Private Access application is configured in the tenant, please review the documentation on how to enable Private Access applications.'
        $customStatus = 'Investigate'
    }
    else {
        # Check each application for assignments and determine pass/fail
        $appsWithoutAssignments = $privateAccessApps | Where-Object { -not $_.appRoleAssignedTo -or $_.appRoleAssignedTo.Count -eq 0 }

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

    if ($privateAccessApps -and $privateAccessApps.Count -gt 0) {
        # Sort applications alphabetically for better readability
        $sortedApps = $privateAccessApps | Sort-Object displayName

        # Build comprehensive table with all information
        $mdInfo += "## [Private Access applications]($portalLink)`n`n"
        $mdInfo += "| Application name | Number of assignments | Assigned principal | Principal type |`n"
        $mdInfo += "|------------------|---------------|--------------------|----------------|`n"

        foreach ($app in $sortedApps) {
            $appName = $app.displayName
            $appId = $app.appId
            $objectId = $app.id
            $hasAssignments = $null -ne $app.appRoleAssignedTo -and $app.appRoleAssignedTo.Count -gt 0
            $assignmentCount = if ($hasAssignments) { $app.appRoleAssignedTo.Count } else { 0 }
            $statusIcon = if ($hasAssignments) { "✅" } else { "❌" }
            $appBladeLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$objectId/appId/$appId"
            $safeAppName = Get-SafeMarkdown $appName
            $appNameWithIcon = "$statusIcon [$safeAppName]($appBladeLink)"

            if ($hasAssignments) {
                # Add a row for each assignment
                $firstAssignment = $true
                foreach ($assignment in $app.appRoleAssignedTo) {
                    $principalName = $assignment.principalDisplayName
                    $principalType = $assignment.principalType

                    # Show app name and count only in the first row for each app
                    if ($firstAssignment) {
                        $mdInfo += "| $appNameWithIcon | $assignmentCount | $principalName | $principalType |`n"
                        $firstAssignment = $false
                    } else {
                        $mdInfo += "| | | $principalName | $principalType |`n"
                    }
                }
            } else {
                # No assignments - show single row with empty principal columns
                $mdInfo += "| $appNameWithIcon | $assignmentCount | | |`n"
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

    # Add CustomStatus if status is 'Investigate'
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
