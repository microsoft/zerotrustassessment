<#
.SYNOPSIS
    Deploy Attack Surface Reduction Policies (ASR) policies for Windows devices
#>

function Test-Assessment-24574 {
    [ZtTest(
    	Category = 'Devices',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce'),
    	TestId = 24574,
    	Title = 'Attack surface reduction policies for Windows',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = "Checking that an Attack Surface Reduction (ASR) policy for Windows devices is created and assigned"
    Write-ZtProgress -Activity $activity

    # Query 1: Retrieve all configuration policies for Windows 10 that use MDM and Microsoft Defender (Sense), and filter for ASR rules
    $win10MdmSensePolicies = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies?`$filter=(platforms has 'windows10') and (technologies has 'mdm' and technologies has 'microsoftSense')&`$expand=settings,assignments" -ApiVersion beta
    $win10MdmSenseASRPolicies = $win10MdmSensePolicies.Where{
        $_.settings.settingInstance.settingDefinitionId -contains 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules'
    }

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
    #endregion Data Collection

    #region Assessment Logic
    # The two required ASR settings must be configured to at least 'Warn' and assigned to a group, but can be done in separate policies
    Write-ZtProgress -Activity $activity -Status "Checking ASR Policies"
    $passed = ($warnObfuscated.Where{$_.assignments.count -gt 0}.count -gt 0 -or $blockObfuscated.Where{$_.assignments.count -gt 0}.count -gt 0) -and
            ($blockWin32CallsFromMacros.Where{$_.assignments.count -gt 0}.count -gt 0 -or $warnWin32CallsFromMacros.Where{$_.assignments.count -gt 0}.count -gt 0)

    if ($passed) {
        $testResultMarkdown = "ASR policies are configured and assigned to Windows devices in Intune.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No ASR policies are configured or assigned, leaving endpoints vulnerable.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = 'Attack Surface Reduction Policies for Windows devices'
    $formatTemplate = ''
    # Generate markdown table rows for each policy
    if ($win10MdmSenseASRPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $tableRows = ""
        $formatTemplate = @'
## {0}

| Policy Name |  Execution of Potentially obfuscated scripts | Win32 API calls from Office macros | Status | Assignment |
| :---------- |  :------------------------------------------ | :--------------------------------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $win10MdmSenseASRPolicies) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/accountprotection'
            $status = if ($policy.assignments.count -gt 0) {
                '🟢 Assigned'
            }
            else {
                '❌ Not Assigned'
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

            $policyName = Get-SafeMarkdown -Text $policy.name
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += "| [$policyName]($portalLink) | $status | $assignmentTarget | $executionOfPotentiallyObfuscatedScripts | $win32ApiCallsFromMacros |`n"
        }
    }

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $tableRows

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24574'
        Title              = "Deploy Attack Surface Reduction Policies (ASR) policies for Windows devices"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
