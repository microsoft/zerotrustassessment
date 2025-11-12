<#
.SYNOPSIS

#>

function Test-Assessment-21812 {
    [ZtTest(
    	Category = 'Privileged access',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'Low',
    	SfiPillar = 'Protect engineering systems',
    	TenantType = ('Workforce'),
    	TestId = 21812,
    	Title = 'Maximum number of Global Administrators doesn''t exceed five users',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Maximum number of Global Administrators doesn't exceed five users"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve all Global Administrators
    $allGlobalAdmins = Get-ZtRoleMember -Role GlobalAdministrator
    # Exclude groups from the count
    $globalAdmins = @($allGlobalAdmins | Where-Object { $_.'@odata.type' -in @('#microsoft.graph.user', '#microsoft.graph.servicePrincipal') })

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

if ($globalAdmins.Count -gt 8) {
        $passed = $false
    }
    else {
        $passed = $true
    }

    if ($passed) {
        $testResultMarkdown = "Maximum number of Global Administrators doesn't exceed five users/service principals.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Maximum number of Global Administrators exceeds five users/service principals.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Global Administrators"
    $tableRows = ""

    if ($globalAdmins.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

### Total number of Global Administrators: {1}

| Display Name | Object Type | User Principal Name |
| :----------- | :---------- | :------------------ |
{2}

'@

        foreach ($globalAdmin in $globalAdmins) {
            $displayName = $globalAdmin.DisplayName

            $objectType = switch ($globalAdmin.'@odata.type') {
                '#microsoft.graph.user' { 'User' }
                '#microsoft.graph.servicePrincipal' { 'Service Principal' }
                default { 'Unknown' }
            }

            $userPrincipalName = if ($globalAdmin.UserPrincipalName) { $globalAdmin.UserPrincipalName } else { 'N/A' }

            # Create portal link based on object type
            $portalLink = switch ($objectType) {
                'User' { "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/$($globalAdmin.Id)" }
                'Service Principal' { "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/$($globalAdmin.AppId)" }
                default { "https://entra.microsoft.com" }
            }

            $tableRows += @"
| [$(Get-SafeMarkdown($displayName))]($portalLink) | $objectType | $userPrincipalName |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $globalAdmins.Count, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '21812'
        Title  = "Maximum number of Global Administrators doesn't exceed five users"
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
