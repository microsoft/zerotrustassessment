<#
.SYNOPSIS

#>

function Test-Assessment-21776 {
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('Free'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21776,
    	Title = 'User consent settings are restricted',
    	UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking User consent settings are restricted"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query authorization policy for user consent settings
    $authorizationPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/authorizationPolicy' -ApiVersion 'v1.0'

    $matchedPolicies = $authorizationPolicy | Where-Object { $_.defaultUserRolePermissions.permissionGrantPoliciesAssigned -match '^ManagePermissionGrantsForSelf' }

    $hasNoMatchedPolicies = $matchedPolicies.Count -eq 0
    $hasLowImpactPolicy = $matchedPolicies.defaultUserRolePermissions.permissionGrantPoliciesAssigned -contains 'managePermissionGrantsForSelf.microsoft-user-default-low'

    if ($hasNoMatchedPolicies -or $hasLowImpactPolicy) {
        $passed = $true
        $testResultMarkdown = "✅ **Pass**: User consent settings are properly restricted to prevent illicit consent grant attacks.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ **Fail**: User consent settings are not sufficiently restricted, allowing users to consent to potentially risky applications.`n`n%TestResult%"
    }

    # Define variables to insert into the format string
    $reportTitle = "Authorization Policy Configuration"
    $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/~/UserSettings"

    # Create a here-string with format placeholders {0}, {1}, etc.
    # {0} - Title of the report
    # {1} - Link to the user consent settings in the portal
    # {2} - Description of the current user consent settings
    $formatTemplate = @"

## {0}


**Current [user consent settings]({1})**

- {2}

"@

    if ($hasNoMatchedPolicies) {
        $settingsDescription = "Do not allow user consent.`nAn administrator will be required for all apps."
    }
    elseif ($hasLowImpactPolicy) {
        $settingsDescription = "Allow user consent for apps from verified publishers, for selected permissions (Recommended).`nAll users can consent for permissions classified as `"low impact`", for apps from verified publishers or apps registered in this organization."
    }
    else {
        $settingsDescription = "Allow user consent for apps.`nAll users can consent for any app to access the organization's data."
    }

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $settingsDescription

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21776'
        Title              = 'User consent settings are restricted'
        UserImpact         = 'High'
        Risk               = 'High'
        ImplementationCost = 'Medium'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
