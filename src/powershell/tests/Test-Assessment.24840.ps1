<#
.SYNOPSIS
    Corporate Wi-Fi network on Fully managed Android devices is securely managed
#>

function Test-Assessment-24840 {
    [ZtTest(
    	Category = 'Devices',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = '',
    	TenantType = ('Workforce'),
    	TestId = 24840,
    	Title = 'Secure Wi-Fi profiles protect Android devices from unauthorized network access',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = "Checking that Corporate Wi-Fi network on Fully managed Android devices is securely managed "
    Write-ZtProgress -Activity $activity

    # Query 1: All android Wi-Fi configuration profiles
    $androidWifiConfProfilesUri = "deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.androidDeviceOwnerEnterpriseWiFiConfiguration')&`$expand=assignments"
    $androidWifiConfProfiles = Invoke-ZtGraphRequest -RelativeUri $androidWifiConfProfilesUri -ApiVersion beta
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
    $reportTitle = "Android WiFi Configuration Profiles"
    $tableRows = ""

    # Generate markdown table rows for each policy
    if ($compliantAndroidWifiConfProfiles.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
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
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += @"
| [$policyName]($portalLink) | $status | $assignmentTarget |
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
        Title              = "Corporate Wi-Fi network on Fully managed Android devices is securely managed "
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
