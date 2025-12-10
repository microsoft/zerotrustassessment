<#
.SYNOPSIS
    Deploy Attack Surface Reduction Policies (ASR) policies for Windows devices
#>

function Test-Assessment-24574 {
    [ZtTest(
    	Category = 'Device',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('Intune'),
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce'),
    	TestId = 24574,
    	Title = 'Attack Surface Reduction rules are applied to Windows devices to prevent exploitation of vulnerable system components',
    	UserImpact = 'Medium'
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
    $activity = "Checking that an Attack Surface Reduction (ASR) policy for Windows devices is created and assigned"
    Write-ZtProgress -Activity $activity

    # Query: Retrieve all Windows 10 policies with mdm and microsoftSense technologies
    $sql = @"
    SELECT id, name, platforms, technologies, to_json(settings) as settings, to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE platforms LIKE '%windows10%'
      AND technologies LIKE '%mdm%'
      AND technologies LIKE '%microsoftSense%'
"@
    $win10MdmSensePolicies = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    # Parse JSON settings field
    foreach ($policy in $win10MdmSensePolicies) {
        if ($policy.settings -is [string]) {
            $policy.settings = $policy.settings | ConvertFrom-Json
        }
        if ($policy.assignments -is [string]) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }
    }

    $win10MdmSenseASRPolicies = $win10MdmSensePolicies.Where{
        $_.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules'
    }

    # Initialize variables for filtered policies
    $warnObfuscated = @()
    $blockObfuscated = @()
    $blockWin32CallsFromMacros = @()
    $warnWin32CallsFromMacros = @()

    # Only proceed with filtering if we have ASR policies
    if ($win10MdmSenseASRPolicies -and $win10MdmSenseASRPolicies.Count -gt 0) {
        $requiredSettings = @{
            'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockexecutionofpotentiallyobfuscatedscripts' = @{
                ExpectedValues = @('device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockexecutionofpotentiallyobfuscatedscripts_warn')
                ContainerPath  = 'settings.settingInstance.groupSettingCollectionValue.children'
                SettingIdPath  = 'settingDefinitionId'
                ValuePath      = 'ChoiceSettingValue.Value'
                Description    = 'block execution of potentially obfuscated scripts = Warn'
            }
        }

        $warnObfuscated = Get-FilteredPoliciesBySetting -Policies $win10MdmSenseASRPolicies -RequiredSettings $requiredSettings

        $requiredSettings = @{
            'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockexecutionofpotentiallyobfuscatedscripts' = @{
                ExpectedValues = @('device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockexecutionofpotentiallyobfuscatedscripts_block')
                ContainerPath  = 'settings.settingInstance.groupSettingCollectionValue.children'
                SettingIdPath  = 'settingDefinitionId'
                ValuePath      = 'ChoiceSettingValue.Value'
                Description    = 'block execution of potentially obfuscated scripts = Block'
            }
        }

        $blockObfuscated = Get-FilteredPoliciesBySetting -Policies $win10MdmSenseASRPolicies -RequiredSettings $requiredSettings

        $requiredSettings = @{
            'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockwin32apicallsfromofficemacros' = @{
                ExpectedValues = @('device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockwin32apicallsfromofficemacros_block')
                ContainerPath  = 'settings.settingInstance.groupSettingCollectionValue.children'
                SettingIdPath  = 'settingDefinitionId'
                ValuePath      = 'ChoiceSettingValue.Value'
                Description    = 'block execution of potentially obfuscated scripts = Block'
            }
        }

        $blockWin32CallsFromMacros = Get-FilteredPoliciesBySetting -Policies $win10MdmSenseASRPolicies -RequiredSettings $requiredSettings

        $requiredSettings = @{
            'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockwin32apicallsfromofficemacros' = @{
                ExpectedValues = @('device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockwin32apicallsfromofficemacros_warn')
                ContainerPath  = 'settings.settingInstance.groupSettingCollectionValue.children'
                SettingIdPath  = 'settingDefinitionId'
                ValuePath      = 'ChoiceSettingValue.Value'
                Description    = 'block execution of potentially obfuscated scripts = Warn'
            }
        }

        $warnWin32CallsFromMacros = Get-FilteredPoliciesBySetting -Policies $win10MdmSenseASRPolicies -RequiredSettings $requiredSettings
    }
    #endregion Data Collection

    #region Assessment Logic
    # The two required ASR settings must be configured to at least 'Warn' and assigned to a group, but can be done in separate policies
    Write-ZtProgress -Activity $activity -Status "Checking ASR Policies"

    # Check if no ASR policies are found at all
    if ($win10MdmSenseASRPolicies.Count -eq 0) {
        $passed = $false
        $testResultMarkdown = "No Attack Surface Reduction policies found for Windows devices in Intune.`n`n%TestResult%"
    }
    else {
        $passed = ($warnObfuscated.Where{$_.assignments.count -gt 0}.count -gt 0 -or $blockObfuscated.Where{$_.assignments.count -gt 0}.count -gt 0) -and
                ($blockWin32CallsFromMacros.Where{$_.assignments.count -gt 0}.count -gt 0 -or $warnWin32CallsFromMacros.Where{$_.assignments.count -gt 0}.count -gt 0)

        if ($passed) {
            $testResultMarkdown = "ASR policies are configured and assigned to Windows devices in Intune.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "ASR policies found but are not properly configured or assigned, leaving endpoints vulnerable.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $formatTemplate = ''

    # Generate markdown table rows for each policy
    if ($win10MdmSenseASRPolicies.Count -gt 0) {
        # Create a here-string with format placeholders
        $tableRows = ""
        $formatTemplate = @'

| Policy name |  Execution of potentially obfuscated scripts | Win32 API calls from Office macros | Status | Assignment |
| :---------- |  :------------------------------------------ | :--------------------------------- | :----- | :--------- |
{0}

'@

        foreach ($policy in $win10MdmSenseASRPolicies) {

            $policyName = Get-SafeMarkdown -Text $policy.name
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/asr'

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $status = '✅ Assigned'
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }
            else {
                $status = '❌ Not assigned'
                $assignmentTarget = 'None'
            }

            $executionOfPotentiallyObfuscatedScripts = if ($policy.settings.settingInstance.groupSettingCollectionValue.children.settingDefinitionId -contains 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockexecutionofpotentiallyobfuscatedscripts') {
                if ($policy.settings.settingInstance.groupSettingCollectionValue.children.choiceSettingValue.value -contains 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockexecutionofpotentiallyobfuscatedscripts_block') {
                    '🟢 Block'
                }
                elseif ($policy.settings.settingInstance.groupSettingCollectionValue.children.choiceSettingValue.value -contains 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockexecutionofpotentiallyobfuscatedscripts_warn') {
                    '⚠️ Warn'
                }
                else {
                    '❌ Allowed'
                }
            }
            else {
                '❌ Not Configured'
            }

            $win32ApiCallsFromMacros = if ($policy.settings.settingInstance.groupSettingCollectionValue.children.settingDefinitionId -contains 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockwin32apicallsfromofficemacros') {
                if ($policy.settings.settingInstance.groupSettingCollectionValue.children.choiceSettingValue.value -contains 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockwin32apicallsfromofficemacros_block') {
                    '🟢 Block'
                }
                elseif ($policy.settings.settingInstance.groupSettingCollectionValue.children.choiceSettingValue.value -contains 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_blockwin32apicallsfromofficemacros_warn') {
                    '⚠️ Warn'
                }
                else {
                    '❌ Allowed'
                }
            }
            else {
                '❌ Not Configured'
            }

            $tableRows += "| [$policyName]($portalLink) | $executionOfPotentiallyObfuscatedScripts | $win32ApiCallsFromMacros | $status | $assignmentTarget | `n"
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $tableRows
    }
    else {
        # No ASR policies found
        $mdInfo = @"
**Required ASR Rules:**
- Block execution of potentially obfuscated scripts
- Block Win32 API calls from Office macros

"@
    }

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24574'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
