<#
.SYNOPSIS

#>

function Test-Assessment-24794 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24794,
    	Title = 'Terms and Conditions policies protect access to sensitive data',
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

    $activity = "Checking Intune Terms and Conditions Policy is configured and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve all Terms and Conditions policies configured in Intune
    $termsAndConditionsUri = "deviceManagement/termsAndConditions"
    $termsAndConditionsPolicies = @(Invoke-ZtGraphRequest -RelativeUri $termsAndConditionsUri -ApiVersion 'beta')

    # Initialize as empty array to avoid uninitialized variable issues
    $termsAndConditionsPoliciesWithAssignments = @()

    # Check if at least one Terms and Conditions policy exists
    if ($termsAndConditionsPolicies.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status "Checking policy assignments"

        # For each Terms and Conditions policy retrieve its assignments
        foreach ($policy in $termsAndConditionsPolicies) {
            $assignmentsUri = "deviceManagement/termsAndConditions/$($policy.id)/assignments"

            $assignments = @(Invoke-ZtGraphRequest -RelativeUri $assignmentsUri -ApiVersion 'beta')

            $termsAndConditionsPolicyWithAssignments = $null

            if ($assignments -and $assignments.Count -gt 0) {
                $isAssigned = $true
            }
            else {
                $isAssigned = $false
            }

            # Add assignment info to Terms and Conditions policy object
            $termsAndConditionsPolicyWithAssignments = $policy |
                Add-Member -NotePropertyName 'assignments' -NotePropertyValue $assignments -Force -PassThru |
                    Add-Member -NotePropertyName 'isAssigned' -NotePropertyValue $isAssigned -Force -PassThru

            $termsAndConditionsPoliciesWithAssignments += $termsAndConditionsPolicyWithAssignments
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Test Terms and Conditions policy assignments
    $passed = Test-PolicyAssignment -Policies $termsAndConditionsPoliciesWithAssignments

    if ($passed) {
        $testResultMarkdown = "At least one Terms and Conditions policy exists and is assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No Terms and Conditions policy exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Terms and Conditions policies"
    $tableRows = ""

    if ($termsAndConditionsPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($termsAndConditionsPolicyWithAssignments in $termsAndConditionsPoliciesWithAssignments) {

            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/TenantAdminMenu/~/termsAndConditions'

            $status = if ($termsAndConditionsPolicyWithAssignments.isAssigned) {
                "✅ Assigned"
            }
            else {
                "❌ Not assigned"
            }

            $assignmentTarget = "None"

            if ($termsAndConditionsPolicyWithAssignments.assignments -and $termsAndConditionsPolicyWithAssignments.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $termsAndConditionsPolicyWithAssignments.assignments
            }

$tableRows += @"
| [$(Get-SafeMarkdown($termsAndConditionsPolicyWithAssignments.displayName))]($portalLink) | $status | $assignmentTarget |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24794'
        Title  = 'Intune Terms and Conditions Policy is configured and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
