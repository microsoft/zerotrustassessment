<#
.SYNOPSIS

#>

function Test-Assessment-24542 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24542,
    	Title = 'Compliance policies protect macOS devices',
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

    $activity = "Checking macOS compliance policies are created and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting compliance policies"

    # Query 1: List all compliance policies for macOS in Intune
    $compliancePoliciesUri = "deviceManagement/deviceCompliancePolicies"
    $allCompliancePolicies = Invoke-ZtGraphRequest -RelativeUri $compliancePoliciesUri -ApiVersion v1.0

    # Filter for macOS compliance policies
    $macOSCompliancePolicies = $allCompliancePolicies | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.macOSCompliancePolicy' }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Check if at least one macOS compliance policy exists
    if ($macOSCompliancePolicies.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status "Checking policy assignments"

        # Query 2: Check assignment of macOS compliance policies
        $policiesWithAssignments = @()
        foreach ($policy in $macOSCompliancePolicies) {
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
            $testResultMarkdown = "At least one compliance policy for macOS exists and is assigned.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "No compliance policy for macOS exists or none are assigned.`n`n%TestResult%"
        }
    }
    else {
        $passed = $false
        $testResultMarkdown = "No compliance policy for macOS exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "macOS Compliance Policies"
    $tableRows = ""

    if ($macOSCompliancePolicies.Count -gt 0) {
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

            $assignmentTarget = "None"

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
        $mdInfo = "No macOS compliance policies found in this tenant.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24542'
        Title  = 'macOS Compliance Policy is Created and Assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
