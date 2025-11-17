<#
.SYNOPSIS

#>

function Test-Assessment-21815 {
    [ZtTest(
    	Category = 'Privileged access',
    	ImplementationCost = 'High',
    	MinimumLicense = ('P2'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21815,
    	Title = 'All privileged role assignments are activated just in time and not permanently active',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if ( -not (Get-ZtLicense EntraIDP2) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP2
        return
    }

    $activity = "Checking All privileged role assignments are activated just in time and not permanently active"
    Write-ZtProgress -Activity $activity -Status "Getting privileged role assignments"

    $sql = @"
select distinct  principalDisplayName, userPrincipalName, roleDisplayName, privilegeType, isPrivileged
from vwRole
"@
    $roleAssignments = Invoke-DatabaseQuery -Database $Database -Sql $sql

    # Check if any privileged role assignment in the results has privilegeType set to Permanent
    $results = $roleAssignments | Where-Object { $_.isPrivileged -eq $true -and $_.privilegeType -eq 'Permanent' }

    $testResultMarkdown = ""

    if ($results.Count -eq 0) {
        $passed = $true
        $testResultMarkdown += "No privileged users have permanent role assignments."
    }
    else {
        $passed = $false
        $testResultMarkdown += "Privileged users with permanent role assignments were found.`n`n%TestResult%"
    }

        # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Privileged users with permanent role assignments"
    $tableRows = ""

    if (-not $passed) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| User | UPN | Role Name | Assignment Type |
| :--- | :-- | :-------- | :-------------- |
{1}

'@

        foreach ($result in $results) {
            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/{0}/hidePreviewBanner~/true' -f $result.principalId
            $tableRows += @"
| [$(Get-SafeMarkdown($result.principalDisplayName))]($portalLink) | $($result.userPrincipalName) | $($result.roleDisplayName) | $($result.privilegeType) |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21815'
        Title              = "All privileged role assignments are activated just in time and not permanently active"
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'High'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
