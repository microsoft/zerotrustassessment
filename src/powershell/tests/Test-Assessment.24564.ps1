﻿
<#
.SYNOPSIS

#>



function Test-Assessment-24564 {
    [ZtTest(
    	Category = 'Device',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('Intune'),
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 24564,
    	Title = 'Local account usage on Windows is restricted to reduce unauthorized access',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions
    function Test-PolicyAssignment {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $false)]
            [array]$Policies
        )

        # Return false if $Policies is null or empty
        if (-not $Policies) {
            return $false
        }

        # Check if at least one policy has assignments
        $assignedPolicies = $Policies | Where-Object {
            $_.PSObject.Properties.Match("assignments") -and $_.assignments -and $_.assignments.Count -gt 0
        }

        return $assignedPolicies.Count -gt 0
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking Intune Local Users and Groups policy is created and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve device configuration profiles in Intune
    $windowsPolicies_Uri = "deviceManagement/configurationPolicies?`$filter=platforms has 'windows10'&`$expand=assignments,settings"
    $windowsPolicies = Invoke-ZtGraphRequest -RelativeUri $windowsPolicies_Uri -ApiVersion beta

    # Filter policies to include only those related to Local Users and Groups settings
    $windowsLocalUsersAndGroupsPolicies = @()
    foreach ($windowsPolicy in $windowsPolicies) {
        $validSettingIds = @('device_vendor_msft_policy_config_localusersandgroups_configure')

        # Get all setting definition IDs from the policy (handle both single values and arrays)
        $policySettingIds = $windowsPolicy.settings.settinginstance.settingdefinitionid

        # Convert to array if it's a single value to ensure consistent handling
        if ($policySettingIds -isnot [array]) {
            $policySettingIds = @($policySettingIds)
        }

        # Check if any of the policy's setting IDs match our valid setting IDs
        $hasValidSetting = $false
        foreach ($settingId in $policySettingIds) {
            if ($validSettingIds -contains $settingId) {
                $hasValidSetting = $true
                break
            }
        }

        if ($hasValidSetting) {
            $windowsLocalUsersAndGroupsPolicies += $windowsPolicy
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Test Local Users and Groups policy assignments
    $passed = Test-PolicyAssignment -Policies $windowsLocalUsersAndGroupsPolicies

    if ($passed) {
        $testResultMarkdown = "At least one Local Users and Groups policy is configured and assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No Local Users and Groups policy is configured or assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Local Users and Groups Policies"
    $tableRows = ""
    $mdInfo = ""

    if ($windowsLocalUsersAndGroupsPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($policy in $windowsLocalUsersAndGroupsPolicies) {

            $policyName = $policy.Name
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration'

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $status = "✅ Assigned"
            }
            else {
                $status = "❌ Not assigned"
            }

            # Get assignment details for this specific policy
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += @"
| [$(Get-SafeMarkdown($policyName))]($portalLink) | $status | $assignmentTarget |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24564'
        Title  = 'Intune Local Users and Groups policy is created and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
