<#
.SYNOPSIS
    Corporate Wi-Fi Network on macOS Devices is Securely Managed
#>

function Test-Assessment-24870 {
    [ZtTest(
    	Category = 'Devices',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = '',
    	TenantType = ('Workforce'),
    	TestId = 24870,
    	Title = 'Secure Wi-Fi profiles are configured to protect macOS connectivity and devices',
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
    $activity = "Checking that Corporate Wi-Fi Network on macOS Devices is Securely Managed "
    Write-ZtProgress -Activity $activity

    # Query 1: All macOS Wi-Fi configuration profiles
    $macOSWifiConfProfilesUri = "deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.macOSWiFiConfiguration')&`$expand=assignments"
    $macOSWifiConfProfiles = Invoke-ZtGraphRequest -RelativeUri $macOSWifiConfProfilesUri -ApiVersion beta
    $compliantMacOSWifiConfProfiles = $macOSWifiConfProfiles.Where{$_.WifiSecurityType -eq 'wpaEnterprise'}
    #region Assessment Logic
    $passed = $compliantMacOSWifiConfProfiles.Count -gt 0 -and $compliantMacOSWifiConfProfiles.Assignments.count -gt 0

    if ($passed) {
        $testResultMarkdown = "At least one Enterprise Wi-Fi profile for macOS exists and is assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No Enterprise Wi-Fi profile for macOS exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "macOS WiFi Configuration Profiles"
    $tableRows = ""

    # Generate markdown table rows for each policy
    if ($compliantMacOSWifiConfProfiles.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $compliantMacOSWifiConfProfiles) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMacOsMenu/~/macOsDevices'
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
        TestId             = '24870'
        Title              = "Corporate Wi-Fi Network on macOS Devices is Securely Managed "
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
