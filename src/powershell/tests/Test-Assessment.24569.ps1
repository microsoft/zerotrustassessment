<#
.SYNOPSIS
    Intune macOS FileVault policy is created and Assigned
#>

function Test-Assessment-24569 {
    [ZtTest(
    	Category = 'Device',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 24569,
    	Title = 'FileVault encryption protects data on macOS devices',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    #region Data Collection
    $activity = "Checking that the Intune macOS FileVault policy is created and Assigned"
    Write-ZtProgress -Activity $activity

    # Query 1: Retrieve assignment for Tenant wide Intune macOS FileVault Configuration Policies
    $appleRemoteManagementPolicies = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies?`$filter=(platforms has 'macOS') and (technologies has 'mdm' and technologies has 'appleRemoteManagement')&`$expand=settings,assignments" -ApiVersion beta

    $macOSFileVaultEnabledPolicies = $appleRemoteManagementPolicies.Where{
        $_.settings.settingInstance.groupSettingCollectionValue.Children.Where{
            $_.settingDefinitionId -eq 'com.apple.mcx.filevault2_enable' -and
            $_.choiceSettingValue.Value -eq 'com.apple.mcx.filevault2_enable_0'
        }
    }

    # Query 2: Retrieve assignment for Windows Hello for Business related MDM Policies
    $deviceConfigs = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/deviceConfigurations?`$expand=assignments" -ApiVersion beta
    $macOSEndpointProtectionPolicies = $deviceConfigs.Where{
        $_.'@odata.type' -eq '#microsoft.graph.macOSEndpointProtectionConfiguration'
    }.Foreach{

    }

    $macOSEndpointProtectionFileVaultEnabledPolicies = $macOSEndpointProtectionPolicies.Where{
        $_.FileVaultEnabled -eq $true
    }

    $allPolicies = $macOSFileVaultEnabledPolicies.Foreach{$_} + $macOSEndpointProtectionFileVaultEnabledPolicies.Foreach{$_}
    #endregion Data Collection

    #region Assessment Logic
    $passed = ($macOSFileVaultEnabledPolicies.count -gt 0 -and $macOSFileVaultEnabledPolicies.Assignments.count -gt 0) -or
              ($macOSEndpointProtectionFileVaultEnabledPolicies.count -gt 0 -and $macOSEndpointProtectionFileVaultEnabledPolicies.Assignments.count -gt 0)

    if ($passed) {
        $testResultMarkdown = "macOS FileVault encryption policies are configured and assigned in Intune.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No relevant macOS FileVault encryption policies are configured or assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Intune macOS FileVault policy is created and Assigned"
    $tableRows = ""

    $formatTemplate = @'

## {0}

{2}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

    # Generate markdown table rows for each policy
    if ($allPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        foreach ($policy in $allPolicies) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration'
            $status = if ($policy.assignments.count -gt 0) {
                '✅ Assigned'
            }
            else {
                '❌ Not Assigned'
            }

            if ([string]::IsNullOrEmpty($policy.name)) {
                $policyName = Get-SafeMarkdown -Text $policy.displayName
            }
            else {
                $policyName = Get-SafeMarkdown -Text $policy.name
            }

            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += @"
| [$policyName]($portalLink) | $status | $assignmentTarget |`n
"@
        }
    }

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $tableRows, $tenantConfigState

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24569'
        Title              = "Intune macOS FileVault policy is created and Assigned"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
