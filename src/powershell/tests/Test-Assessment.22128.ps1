<#
.SYNOPSIS

#>

function Test-Assessment-22128 {
    [ZtTest(
        Category = 'Application management',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Free'),
        Pillar = 'Identity',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and isolate production systems',
        TenantType = ('Workforce', 'External'),
        TestId = 22128,
        Title = 'Guests are not assigned high privileged directory roles',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Guests are not assigned high privileged directory roles"
    Write-ZtProgress -Activity $activity -Status "Getting high privileged directory roles"

    # SQL query to find service principals with password credentials
    $sqlPrivilegedRoles = @"
    SELECT
        vr.roleDefinitionId,
        vr.roleDisplayName,
        vr.isPrivileged,
        vr.principalId,
        vr.principalDisplayName,
        vr.userPrincipalName,
        u.userType as userType,  -- Added User Type
        vr.privilegeType as assignmentType
    FROM vwRole vr
    LEFT JOIN "User" u ON vr.principalId = u.id  -- Join with User table
    WHERE vr.isPrivileged = true AND u.userType = 'Guest'
    AND vr."@odata.type" = '#microsoft.graph.user'  -- Filter for users only
    ORDER BY vr.roleDisplayName, vr.principalDisplayName
"@


    $resultsPrivilegedRoles = Invoke-DatabaseQuery -Database $Database -Sql $sqlPrivilegedRoles

    $passed = $resultsPrivilegedRoles.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "Guests with privileged roles were not found.`n`nAll users with privileged roles are members of the tenant.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Guests with privileged roles were detected.`n`n%TestResult%"
    }

    if (!$passed) {
        # Build the detailed sections of the markdown

        # Define variables to insert into the format string
        $reportTitle = "Guests with privileged roles"
        $tableRows = ""

        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Role Name | User Name | User Principal Name | User Type | Assignment Type |
| :-------- | :-------- | :------------------ | :-------- | :-------------- |
{1}

'@

        foreach ($role in $resultsPrivilegedRoles) {
            if ($role.userType -ne 'Guest') {
                continue
            }

            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/{0}/hidePreviewBanner~/true' -f $role.principalId
            $tableRows += @"
| $($role.roleDisplayName) | [$(Get-SafeMarkdown($role.principalDisplayName))]($portalLink) | $($role.userPrincipalName) | $($role.userType) | $($role.assignmentType) |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo


    $params = @{
        TestId             = '22128'
        Title              = "Guests are not assigned high privileged directory roles"
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
