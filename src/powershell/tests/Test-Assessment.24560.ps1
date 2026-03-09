<#
.SYNOPSIS
    Windows Cloud LAPS policy is created and assigned
#>

function Test-Assessment-24560 {
    [ZtTest(
    	Category = 'Device',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('Intune'),
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 24560,
    	Title = 'Local administrator credentials on Windows are protected by Windows LAPS',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    #region Data Collection
    $activity = "Checking that the Windows Cloud LAPS policy is created and assigned"
    Write-ZtProgress -Activity $activity

    # Query: Retrieve Windows LAPS policies from ConfigurationPolicy table
    $sql = @"
    SELECT id, name, platforms, technologies, templateReference, to_json(settings) as settings, to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE templateReference.templateFamily = 'endpointSecurityAccountProtection'
      AND platforms LIKE '%windows10%'
"@
    $windowsPolicies = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    # Parse JSON settings field
    foreach ($policy in $windowsPolicies) {
        if ($policy.settings -is [string]) {
            $policy.settings = $policy.settings | ConvertFrom-Json
        }
        if ($policy.assignments -is [string]) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }
    }

    $lapsPolicies = $windowsPolicies.Where{
        $_.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_laps_policies_backupdirectory' -or
        $_.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_laps_policies_automaticaccountmanagementenabled'
    }

    $compliantPolicies = $lapsPolicies.Where{
        # backup in Entra ID only
        (
            $_.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_laps_policies_backupdirectory' -and
            $_.settings.settingInstance.ChoiceSettingValue.Value -contains 'device_vendor_msft_laps_policies_backupdirectory_1' -and
            $_.settings.SettingInstance.choiceSettingValue.value -contains 'device_vendor_msft_laps_policies_automaticaccountmanagementenabled_true'
        ) -or

        # Backup in AD only
        (
            $_.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_laps_policies_backupdirectory' -and
            $_.settings.settingInstance.ChoiceSettingValue.Value -contains 'device_vendor_msft_laps_policies_backupdirectory_2' -and
            $_.settings.SettingInstance.choiceSettingValue.value -contains 'device_vendor_msft_laps_policies_automaticaccountmanagementenabled_true'
        )
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $compliantPolicies.count -gt 0 -and $compliantPolicies.Where{$_.assignments.count -gt 0}.count -gt 0

    if ($passed) {
        $testResultMarkdown = "Cloud LAPS policy is assigned and enforced.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Cloud LAPS policy is not assigned or enforced.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Windows Cloud LAPS policy is created and assigned"
    $tableRows = ""

    $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment | Backup Directory | Automatic Account Management |
| :---------- | :----- | :--------- | :--------------- | :--------------------------- |
{1}

'@

    # Generate markdown table rows for each policy
    if ($lapsPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        foreach ($policy in $lapsPolicies) {

            $policyName = Get-SafeMarkdown -Text $policy.name
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/accountprotection'

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $status = '✅ Assigned'
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }
            else {
                $status = '❌ Not assigned'
                $assignmentTarget = 'None'
            }

            $backupDirectory = if ($policy.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_laps_policies_backupdirectory') {
                if ($policy.settings.settingInstance.ChoiceSettingValue.Value -contains 'device_vendor_msft_laps_policies_backupdirectory_1') {
                    '✅ Entra ID (AAD)'
                }
                elseif ($policy.settings.settingInstance.ChoiceSettingValue.Value -contains 'device_vendor_msft_laps_policies_backupdirectory_2') {
                    '✅ Active Directory'
                }
                else {
                    '❌ Disabled'
                }
            }
            else {
                '❌ Not Configured'
            }

            $management = if ($policy.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_laps_policies_automaticaccountmanagementenabled') {
                if ($policy.settings.SettingInstance.choiceSettingValue.value -contains 'device_vendor_msft_laps_policies_automaticaccountmanagementenabled_true') {
                    '✅ Enabled'
                }
                else {
                    '❌ Disabled'
                }
            }
            else {
                '❌ Not Configured'
            }

            $tableRows += "| [$policyName]($portalLink) | $status | $assignmentTarget | $backupDirectory | $management |`n"
        }
    }

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $tableRows

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24560'
        Title              = "Windows Cloud LAPS policy is created and assigned"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
