<#
.SYNOPSIS
    Windows Cloud LAPS policy is created and assigned
#>

function Test-Assessment-24560 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = "Checking that the Windows Cloud LAPS policy is created and assigned"
    Write-ZtProgress -Activity $activity

    # Query 1: Retrieve assignment for Tenant wide Windows Hello for Business Configuration Policies
    $windowsPolicies = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies?`$filter=templateReference/templateFamily eq 'endpointSecurityAccountProtection' and platforms eq 'windows10'&`$expand=settings,assignments" -ApiVersion beta

    $endpointSecurityAcctPolicies = $windowsPolicies.Where{
        $_.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_laps_policies_backupdirectory' -or
        $_.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_laps_policies_automaticaccountmanagementenabled'
    }

    $cloudLapsPolicies = $endpointSecurityAcctPolicies.Where{
        # backup in Azure AD only
        ($_.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_laps_policies_backupdirectory' -and
        $_.settings.settingInstance.ChoiceSettingValue.Value -contains 'device_vendor_msft_laps_policies_backupdirectory_1') -or

        # Backup in AD only
        ($_.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_laps_policies_backupdirectory' -and
        $_.settings.settingInstance.ChoiceSettingValue.Value -contains 'device_vendor_msft_laps_policies_backupdirectory_2')
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $cloudLapsPolicies.count -gt 0 -and $cloudLapsPolicies.Where{$_.assignments.count -gt 0}.count -gt 0

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

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

    # Generate markdown table rows for each policy
    if ($cloudLapsPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        foreach ($policy in $cloudLapsPolicies) {
            # TODO: check URL
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/accountprotection'
            $status = if ($policy.assignments.count -gt 0) {
                '✅ Assigned'
            }
            else {
                '❌ Not Assigned'
            }

            $policyName = Get-SafeMarkdown -Text $policy.name
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += @"
| [$policyName]($portalLink) | $status | $assignmentTarget |
"@
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
