﻿
<#
.SYNOPSIS

#>



function Test-Assessment-24552 {
    [ZtTest(
    	Category = 'Device management',
    	ImplementationCost = 'High',
    	Pillar = 'Devices',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect engineering systems',
    	TenantType = ('Workforce'),
    	TestId = 24552,
    	Title = 'macOS - Firewall policy is created and assigned',
    	UserImpact = 'High'
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

    $activity = "Checking macOS Firewall Policy is Created and Assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve all macOS policies
    $macOSPolicies_Uri = "deviceManagement/configurationPolicies?&`$filter=(platforms has 'macOS') and (technologies has 'mdm' and technologies has 'appleRemoteManagement')&`$select=id,name,description,platforms,technologies&`$expand=settings,assignments"
    $macOSPolicies = Invoke-ZtGraphRequest -RelativeUri $macOSPolicies_Uri -ApiVersion beta

    # Filter policies to include only those related to firewall settings
    $macOSFirewallPolicies = @()
    foreach ($macOSPolicy in $macOSPolicies) {
        $validSettingIds = @('com.apple.security.firewall_enablefirewall_true')

        # Get all setting definition IDs from the policy (handle both single values and arrays)
        $policySettingIds = $macOSPolicy.settings.settingInstance.groupSettingCollectionValue.Children.choiceSettingValue.value

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
            $macOSFirewallPolicies += $macOSPolicy
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Test macOS firewall policy assignments
    $passed = Test-PolicyAssignment -Policies $macOSFirewallPolicies

    if ($passed) {
        $testResultMarkdown = "A macOS firewall policy is configured and assigned in Intune.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No assigned macOS firewall policy was found in Intune.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "macOS Firewall Policies"
    $tableRows = ""

    if ($macOSFirewallPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($policy in $macOSFirewallPolicies) {

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
    else {
        $mdInfo = "No macOS firewall policies found in this tenant.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24552'
        Title  = 'macOS - Firewall policy is created and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
