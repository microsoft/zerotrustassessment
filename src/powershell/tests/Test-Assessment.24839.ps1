<#
.SYNOPSIS
    Corporate Wi-Fi network on iOS devices is securely managed
#>

function Test-Assessment-24839 {
    [ZtTest(
    	Category = 'Data',
    	ImplementationCost = 'Medium',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce'),
    	TestId = 24839,
    	Title = 'Secure Wi-Fi profiles protect iOS devices from unauthorized network access',
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
    $activity = "Checking that Corporate Wi-Fi network on iOS devices is securely managed"
    Write-ZtProgress -Activity $activity

    # Query 1: All
    $iOSWifiConfProfilesUri = "deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.iosWiFiConfiguration')&`$expand=assignments"
    $iOSWifiConfProfiles = Invoke-ZtGraphRequest -RelativeUri $iOSWifiConfProfilesUri -ApiVersion beta
    $compliantIosWifiConfProfiles = $iOSWifiConfProfiles.Where{$_.WifiSecurityType -in @('wpa2Enterprise','wpaEnterprise')}
    #region Assessment Logic
    $passed = $compliantIosWifiConfProfiles.Count -gt 0 -and $compliantIosWifiConfProfiles.Assignments.count -gt 0

    if ($passed) {
        $testResultMarkdown = "At least one Enterprise Wi-Fi profile for iOS exists and is assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No Enterprise Wi-Fi profile for iOS exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "iOS WiFi Configuration Profiles"
    $tableRows = ""

    # Generate markdown table rows for each policy
    if ($iOSWifiConfProfiles.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Wi-Fi Security Type | Status | Assignment |
| :---------- | :----- | :--------- | :--------- |
{1}

'@
        foreach ($policy in $iOSWifiConfProfiles) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesIosMenu/~/configuration'
            $status = if ($policy.assignments.count -gt 0) {
                '✅ Assigned'
            }
            else {
                '❌ Not Assigned'
            }

            $wifiType = Get-WifiSecurityType -SecurityType $policy.wiFiSecurityType

            $policyName = Get-SafeMarkdown -Text $policy.displayName
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += "| [$policyName]($portalLink) | $wifiType | $status | $assignmentTarget |`n"
        }

         # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24839'
        Title              = "Corporate Wi-Fi network on iOS devices is securely managed"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
