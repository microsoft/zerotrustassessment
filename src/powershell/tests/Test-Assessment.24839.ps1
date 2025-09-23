<#
.SYNOPSIS
    Corporate Wi-Fi network on iOS devices is securely managed
#>

function Test-Assessment-24839 {
    [ZtTest(
    	Category = 'Devices',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24839,
    	Title = 'Corporate Wi-Fi network on iOS devices is securely managed ',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

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
    if ($compliantIosWifiConfProfiles.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $compliantIosWifiConfProfiles) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesIosMenu/~/configuration'
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
        TestId             = '24839'
        Title              = "Corporate Wi-Fi network on iOS devices is securely managed"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
