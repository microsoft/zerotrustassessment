<#
.SYNOPSIS

#>

function Test-Assessment-21793 {
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce','External'),
    	TestId = 21793,
    	Title = 'Tenant restrictions v2 policy is configured',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Tenant restrictions v2 are configured"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    if((Get-MgContext).Environment -ne 'Global')
    {
        Write-PSFMessage "This test is only applicable to the Global environment." -Tag Test -Level VeryVerbose
        return
    }


    # Query the cross-tenant access policy
    $crossTenantAccessPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/crossTenantAccessPolicy' -ApiVersion v1.0

    $guid = [System.Guid]::Empty
    $isGuid = [System.Guid]::TryParse($crossTenantAccessPolicy.id, [ref]$guid)

    if ($isGuid) {
        # Query the default cross-tenant access policy
        $defaultCrossTenantAccessPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/crossTenantAccessPolicy/default' -ApiVersion v1.0
        $result = $defaultCrossTenantAccessPolicy | Select-Object -Property id -ExpandProperty tenantRestrictions

        # Check if both usersAndGroups and applications are properly configured
        $usersAndGroupsBlocked = $result.usersAndGroups.accessType -eq 'blocked' -and
        $result.usersAndGroups.targets -and
        $result.usersAndGroups.targets[0].target -eq 'AllUsers'

        $applicationsBlocked = $result.applications.accessType -eq 'blocked' -and
        $result.applications -and
        $result.applications.targets[0].target -eq 'AllApplications'

        if ($usersAndGroupsBlocked -and $applicationsBlocked) {
            $passed = $true
            $testResultMarkdown = "Tenant Restrictions v2 policy is properly configured.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "Tenant Restrictions v2 policy is NOT configured or incorrectly configured.`n`n%TestResult%"
        }
    }
    else {
        $passed = $false
        $testResultMarkdown = "Tenant Restrictions v2 policy is NOT configured or incorrectly configured.`n`n%TestResult%"
    }

    # Build the detailed sections of the markdown
    $reportTitle = "Tenant restriction settings"

    # Create a here-string with format placeholders {0}, {1}, etc.
    $formatTemplate = @'

## {0}


| Policy Configured | External users and groups | External applications |
| :---------------- | :------------------------ | :-------------------- |
{1}

'@

    $configured = if ($isGuid) { "Yes" } else { "No" }

$portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/TenantRestrictions.ReactView/isDefault~/true/name//id/'

    $targetUsersAndGroup = if ($result.usersAndGroups.targets -and $result.usersAndGroups.targets[0].target -eq 'AllUsers') {
        "All external users and groups"
    }
    else {
        # Process all user/group targets and join them
            ($result.usersAndGroups.targets | ForEach-Object { $_.target }) -join ', '
    }

    $targetApplications = if ($result.applications.targets -and $result.applications.targets[0].target -eq 'AllApplications') {
        "All external applications"
    }
    else {
        # Process all application targets and join them
            ($result.applications.targets | ForEach-Object { $_.target }) -join ', '
    }

    $tableRows += @"
| [$($configured)]($portalLink) | $targetUsersAndGroup | $targetApplications |`n
"@

# Format the template by replacing placeholders with values
$mdInfo = $formatTemplate -f $reportTitle, $tableRows

# Replace the placeholder with the detailed information
$testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

$params = @{
    TestId             = '21793'
    Title              = "Tenant restrictions v2 are configured"
    UserImpact         = 'Low'
    Risk               = 'High'
    ImplementationCost = 'Medium'
    AppliesTo          = 'Identity'
    Tag                = 'Identity'
    Status             = $passed
    Result             = $testResultMarkdown
}
Add-ZtTestResultDetail @params
}
