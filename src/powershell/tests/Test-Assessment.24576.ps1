
<#
.SYNOPSIS

#>



function Test-Assessment-24576 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'Low',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24576,
    	Title = 'Endpoint Analytics is enabled to help identify risks on Windows devices',
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

    $activity = "Checking Intune Endpoint Analytics policy is created and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve all device configuration policies
    $deviceConfigurationPolicies_Uri = "deviceManagement/deviceConfigurations?`$select=id,displayName,assignments&`$expand=assignments"
    $deviceConfigurationPolicies = Invoke-ZtGraphRequest -RelativeUri $deviceConfigurationPolicies_Uri -ApiVersion beta

    # Filter device configuration policies for Windows Health Monitoring
    # The @() wrapper ensures you always get an array, even if the result is null or a single item!
    $windowsHealthMonitoringPolicies = @($deviceConfigurationPolicies | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.windowsHealthMonitoringConfiguration' })

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Test Windows Health Monitoring policy assignments
    $passed = Test-PolicyAssignment -Policies $windowsHealthMonitoringPolicies

    if ($passed) {
        $testResultMarkdown = "An Endpoint analytics policy is created and assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Endpoint analytics policy is not created or not assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Endpoint Analytics Policies"
    $tableRows = ""

    if ($windowsHealthMonitoringPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($policy in $windowsHealthMonitoringPolicies) {

                $policyName = $policy.displayName
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
        $mdInfo = "No Endpoint Analytics policies found in this tenant.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24576'
        Title  = 'Intune Endpoint Analytics policy is created and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
