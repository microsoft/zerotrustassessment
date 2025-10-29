
<#
.SYNOPSIS

#>



function Test-Assessment-24554 {
    [ZtTest(
    	Category = 'Device',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24554,
    	Title = 'Update policies for iOS/iPadOS are enforced to reduce risk from unpatched vulnerabilities',
    	UserImpact = 'Medium'
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

    $activity = "Checking iOS update policies are created and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve all iOS update policies and their potential assignments
    # MDM iOS Update Policies
    $iOSUpdatePolicies_MDMUri = "deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.iosUpdateConfiguration')&`$expand=assignments"
    $iOSUpdatePolicies_MDM_assignments = Invoke-ZtGraphRequest -RelativeUri $iOSUpdatePolicies_MDMUri -ApiVersion beta

    # DDM iOS Update Policies
    $iOSPolicies_DDMUri = "deviceManagement/configurationPolicies?&`$filter=(platforms has 'iOS') and (technologies has 'mdm' and technologies has 'appleRemoteManagement')&`$expand=settings"
    $iOSPolicies_DDM = Invoke-ZtGraphRequest -RelativeUri $iOSPolicies_DDMUri -ApiVersion beta

    $iOSUpdatePolicies_DDM = @()
    foreach ($iOSPolicy_DDM in $iOSPolicies_DDM) {
        $validSettingIds = @('ddm-latestsoftwareupdate_enforcelatestsoftwareupdateversion', 'enforcement_targetosversion')

        # Get all setting definition IDs from the policy (handle both single values and arrays)
        $policySettingIds = $iOSPolicy_DDM.settings.settingInstance.groupSettingCollectionValue.Children.settingDefinitionId

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
            $iOSUpdatePolicies_DDM += $iOSPolicy_DDM
        }
    }

    # Get assignments for DDM policies
    $iOSUpdatePolicies_DDM_assignments = @()
    foreach ($iOSUpdatePolicy_DDM in $iOSUpdatePolicies_DDM) {
        $assignments = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies('$($iOSUpdatePolicy_DDM.id)')/assignments" -ApiVersion beta
        $iOSUpdatePolicy_DDM | Add-Member -MemberType NoteProperty -Name assignments -Value $assignments -Force
        $iOSUpdatePolicies_DDM_assignments += $iOSUpdatePolicy_DDM
    }

    $iOSUpdatePolicies = @($iOSUpdatePolicies_MDM_assignments) + @($iOSUpdatePolicies_DDM_assignments)

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Test both MDM and DDM policy assignments
    $passed_MDM = Test-PolicyAssignment -Policies $iOSUpdatePolicies_MDM_assignments
    $passed_DDM = Test-PolicyAssignment -Policies $iOSUpdatePolicies_DDM_assignments

    # Pass if either MDM or DDM policies are assigned
    $passed = $passed_MDM -or $passed_DDM

    if ($passed) {
        $testResultMarkdown = "An iOS update policy is configured and assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No iOS update policy is configured or enforced.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "iOS Update Policies"
    $tableRows = ""

    if ($iOSUpdatePolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($policy in $iOSUpdatePolicies) {


            if ($policy.'@odata.type' -eq '#microsoft.graph.iosUpdateConfiguration') {
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
        $mdInfo = "No iOS update policies found in this tenant.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24554'
        Title  = 'An iOS update policy is created and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
