<#
.SYNOPSIS

#>

function Test-Assessment-24543 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24543,
    	Title = 'Compliance policies protect iOS/iPadOS devices',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking Compliance policy assignment for iOS/iPadOS devices"
    Write-ZtProgress -Activity $activity -Status "Getting compliance policies"

    # Query 1: List all compliance policies for iOS/iPadOS in Intune
    $compliancePoliciesUri = "deviceManagement/deviceCompliancePolicies"
    $allCompliancePolicies = Invoke-ZtGraphRequest -RelativeUri $compliancePoliciesUri -ApiVersion v1.0

    # Filter for iOS/iPadOS compliance policies
    $iOSCompliancePolicies = $allCompliancePolicies | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.iosCompliancePolicy' -or $_.'@odata.type' -eq '#microsoft.graph.iosDeviceCompliancePolicy' }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Check if at least one iOS compliance policy exists
    if ($iOSCompliancePolicies.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status "Checking policy assignments"

        # Query 2: Check assignment of iOS compliance policies
        $policiesWithAssignments = @()
        foreach ($policy in $iOSCompliancePolicies) {
            $assignmentsUri = "deviceManagement/deviceCompliancePolicies/$($policy.id)/assignments?`$select=target"

            $assignments = Invoke-ZtGraphRequest -RelativeUri $assignmentsUri -ApiVersion v1.0

            $policyWithAssignments = $null
            if ($assignments -and $assignments.Count -gt 0) {
                $isAssigned = $true
            }
            else {
                $isAssigned = $false
            }
            # Add assignment info to policy object

            $policyWithAssignments = $policy |
                Add-Member -NotePropertyName 'assignments' -NotePropertyValue $assignments -Force -PassThru |
                    Add-Member -NotePropertyName 'isAssigned' -NotePropertyValue $isAssigned -Force -PassThru

            $policiesWithAssignments += $policyWithAssignments
        }

        # Check if at least one policy is assigned
        $assignedPolicies = $policiesWithAssignments | Where-Object { $_.isAssigned -eq $true }

        if ($assignedPolicies.Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "At least one compliance policy for iOS/iPadOS exists and is assigned.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "No compliance policy for iOS/iPadOS exists or none are assigned.`n`n%TestResult%"
        }
    }
    else {
        $passed = $false
        $testResultMarkdown = "No compliance policy for iOS/iPadOS exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "iOS/iPadOS Compliance Policies"
    $tableRows = ""

    if ($iOSCompliancePolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($policyWithAssignments in $policiesWithAssignments) {

            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/compliance'

            $status = if ($policyWithAssignments.isAssigned) {
                "✅ Assigned"
            }
            else {
                "❌ Not assigned"
            }

            $assignmentTarget = 'None'

            if ($policyWithAssignments.assignments -and $policyWithAssignments.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policyWithAssignments.assignments
            }

            $tableRows += @"
| [$(Get-SafeMarkdown($policyWithAssignments.displayName))]($portalLink) | $status | $assignmentTarget |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    else {
        $mdInfo = "No iOS/iPadOS compliance policies found in this tenant.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24543'
        Title  = 'Compliance policy assignment for iOS/iPadOS devices'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
