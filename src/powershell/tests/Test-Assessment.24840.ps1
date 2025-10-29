<#
.SYNOPSIS
    Corporate Wi-Fi network on fully managed Android devices is securely managed
#>

function Test-Assessment-24840 {
    [ZtTest(
    	Category = 'Data',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce'),
    	TestId = 24840,
    	Title = 'Secure Wi-Fi profiles protect Android devices from unauthorized network access',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    #region Data Collection
    $activity = 'Checking that Corporate Wi-Fi network on fully managed Android devices is securely managed'
    Write-ZtProgress -Activity $activity

    # Query 1: All android Wi-Fi configuration profiles
    $androidWifiConfProfilesUri = "deviceManagement/deviceConfigurations?`$expand=assignments"
    $androidWifiConfProfiles = Invoke-ZtGraphRequest -RelativeUri $androidWifiConfProfilesUri -Filter "isof('microsoft.graph.androidDeviceOwnerEnterpriseWiFiConfiguration')" -ApiVersion beta
    $compliantAndroidWifiConfProfiles = $androidWifiConfProfiles.Where{$_.WifiSecurityType -eq 'wpaEnterprise'}
    #region Assessment Logic
    $passed = $compliantAndroidWifiConfProfiles.Count -gt 0 -and $compliantAndroidWifiConfProfiles.Assignments.count -gt 0

    if ($passed) {
        $testResultMarkdown = "At least one Enterprise Wi-Fi profile for android exists and is assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No Enterprise Wi-Fi profile for android exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = 'Android Wi-Fi Configuration Profiles'
    $tableRows = ""

    # Generate markdown table rows for each policy
    if ($compliantAndroidWifiConfProfiles.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Wi-Fi Security Type | Status | Assignment |
| :---------- | :---------------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $compliantAndroidWifiConfProfiles) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesandroidMenu/~/configuration'
            $status = if ($policy.assignments.count -gt 0) {
                '✅ Assigned'
            }
            else {
                '❌ Not Assigned'
            }

            $policyName = Get-SafeMarkdown -Text $policy.displayName
            $wifiSecurityType = Get-SafeMarkdown -Text $policy.WifiSecurityType
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += @"
| [$policyName]($portalLink) | $wifiSecurityType | $status | $assignmentTarget |
"@
        }

         # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24840'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
