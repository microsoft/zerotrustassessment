
<#
.SYNOPSIS

#>



function Test-Assessment-24690 {
    [ZtTest(
    	Category = 'Device',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24690,
    	Title = 'Update policies for macOS are enforced to reduce risk from unpatched vulnerabilities',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions

    function Test-PolicyAssignment {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [AllowEmptyCollection()]
            [AllowNull()]
            $Policies
        )

        # Check if at least one policy exists
        if ($Policies.Count -gt 0) {
            # Check if at least one policy has assignments
            $assignedPolicies = $Policies | Where-Object {
                $_.assignments -and $_.assignments.Count -gt 0
            }

            return $assignedPolicies.Count -gt 0
        }

        return $false
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking macOS update policy is configured and assigned "
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve all macOS update policies and their potential assignments
    # MDM macOS Update Policies
    $macOSUpdatePolicies_MDMUri = "deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.macOSSoftwareUpdateConfiguration')&`$expand=assignments"
    $macOSUpdatePolicies_MDM_assignments = Invoke-ZtGraphRequest -RelativeUri $macOSUpdatePolicies_MDMUri -ApiVersion beta

    # DDM macOS Update Policies
    $macOSPolicies_DDMUri = "deviceManagement/configurationPolicies?&`$filter=(platforms has 'macOS') and (technologies has 'mdm' or technologies has 'appleRemoteManagement')&`$expand=settings"
    $macOSPolicies_DDM = Invoke-ZtGraphRequest -RelativeUri $macOSPolicies_DDMUri -ApiVersion beta

    $macOSUpdatePolicies_DDM = @()
    foreach ($macOSPolicy_DDM in $macOSPolicies_DDM) {
        $validSettingIds = @('ddm-latestsoftwareupdate_enforcelatestsoftwareupdateversion', 'enforcement_targetosversion')

        # Get all setting definition IDs from the policy (handle both single values and arrays)
        $policySettingIds = $macOSPolicy_DDM.settings.settingInstance.groupSettingCollectionValue.Children.settingDefinitionId

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
            $macOSUpdatePolicies_DDM += $macOSPolicy_DDM
        }
    }

    # Get assignments for DDM policies
    $macOSUpdatePolicies_DDM_assignments = @()
    foreach ($macOSUpdatePolicy_DDM in $macOSUpdatePolicies_DDM) {
        $assignments = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies('$($macOSUpdatePolicy_DDM.id)')/assignments" -ApiVersion beta
        $macOSUpdatePolicy_DDM | Add-Member -MemberType NoteProperty -Name assignments -Value $assignments -Force
        $macOSUpdatePolicies_DDM_assignments += $macOSUpdatePolicy_DDM
    }

    $macOSUpdatePolicies = @($macOSUpdatePolicies_MDM_assignments) + @($macOSUpdatePolicies_DDM_assignments)

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Test both MDM and DDM policy assignments
    $passed_MDM = Test-PolicyAssignment -Policies $macOSUpdatePolicies_MDM_assignments
    $passed_DDM = Test-PolicyAssignment -Policies $macOSUpdatePolicies_DDM_assignments

    # Pass if either MDM or DDM policies are assigned
    $passed = $passed_MDM -or $passed_DDM

    if ($passed) {
        $testResultMarkdown = "At least one macOS update policy is assigned to a group.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No macOS update policies are created, or created policies are not assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "macOS Update Policies"
    $tableRows = ""

    if ($macOSUpdatePolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($policy in $macOSUpdatePolicies) {


            if ($policy.'@odata.type' -eq '#microsoft.graph.macOSSoftwareUpdateConfiguration') {
                $policyName = $policy.displayName
                $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/iOSiPadOSUpdate'
            }
            else {
                $policyName = $policy.Name
                $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration'
            }

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
        $mdInfo = "No macOS update policies found in this tenant.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24690'
        Title  = 'macOS update policy is configured and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
