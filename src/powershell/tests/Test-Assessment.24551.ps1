<#
.SYNOPSIS
    Windows Hello for Business Policy is Configured and Assigned
#>

function Test-Assessment-24551 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = "Checking that the Windows Hello for Business Policy is Configured and Assigned"
    Write-ZtProgress -Activity $activity

    # Query 1: Retrieve assignment for Tenant wide Windows Hello for Business Configuration Policies
    $windowsHelloTenantConfig = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/deviceEnrollmentConfigurations?`$filter=deviceEnrollmentConfigurationType eq 'windowsHelloForBusiness'" -ApiVersion beta

    # Query 2: Retrieve assignment for Windows Hello for Business related MDM Policies
    $windowsMdmPolicies = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies?`$filter=platforms has 'windows10' and technologies has 'mdm'&`$select=id,name,platforms,technologies&`$expand=assignments,settings" -ApiVersion beta

    # filter to only Windows Hello for Business related policies
    $windowsHelloMdmPolicies = $windowsMdmPolicies.Where{
        $_.settings.settingInstance.groupSettingCollectionValue.children.SettingDefinitionId -contains 'device_vendor_msft_passportforwork_{tenantid}_policies_usepassportforwork' -or
        $_.settings.settingInstance.groupSettingCollectionValue.children.SettingDefinitionId -contains 'user_vendor_msft_passportforwork_{tenantid}_policies_usepassportforwork'
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $windowsHelloTenantConfig.state -eq 'enabled' -or $windowsHelloMdmPolicies.Where{$_.Assignments.target.groupId}.count -ne 0

    if ($passed) {
        # TODO: Result is misleading. It might be assigned and enforced on some devices but not all.
        # A more thorough check would require checking each assignment target and ensuring it covers all corporate devices
        $testResultMarkdown = "Windows Hello for Business policy is assigned and enforced for all devices.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Windows Hello for Business policy is not assigned or not enforced.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Windows Hello for Business Policy is Configured and Assigned"
    $tableRows = ""

    $formatTemplate = @'

## {0}

{2}

| Policy Name | Status | Assignment | Biometrics |
| :---------- | :----- | :--------- | :--------- |
{1}

'@

    if ($windowsHelloTenantConfig)
    {
        $tenantConfigState = if ($windowsHelloTenantConfig.state -eq 'enabled') {
            'Windows Hello For Business ([Tenant Wide Setting]({0}) ): ✅ Enabled.' -f 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesEnrollmentMenu/~/windowsEnrollment'
        }
        elseif ($windowsHelloTenantConfig.state -eq 'disabled') {
            'Windows Hello For Business ([Tenant Wide Setting]({0}) ): ❌ Disabled.' -f 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesEnrollmentMenu/~/windowsEnrollment'
        }
        else {
            'Windows Hello For Business ([Tenant Wide Setting]({0}) ): ❓ Not Configured.' -f 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesEnrollmentMenu/~/windowsEnrollment'
        }
    }

    # Generate markdown table rows for each policy
    if ($windowsHelloMdmPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        foreach ($policy in $windowsHelloMdmPolicies) {
            # TODO: check URL
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration'
            $status = if ($policy.assignments.count -gt 0) {
                '✅ Assigned'
            }
            else {
                '❌ Not Assigned'
            }

            $biometrics = if ($policy.settings.settingInstance.ChoiceSettingValue.Value -contains 'device_vendor_msft_passportforwork_biometrics_usebiometrics_true') {
                '✅ Enabled'
            }
            elseif ($policy.settings.settingInstance.ChoiceSettingValue.Value -contains 'device_vendor_msft_passportforwork_biometrics_usebiometrics_false') {
                '❌ Disabled'
            }
            else {
                '❓ Not Configured'
            }

            $policyName = Get-SafeMarkdown -Text $policy.name
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += @"
| [$policyName]($portalLink) | $status | $assignmentTarget | $biometrics |`n
"@
        }
    }

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $tableRows, $tenantConfigState

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24551'
        Title              = "Windows Hello for Business Policy is Configured and Assigned"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
