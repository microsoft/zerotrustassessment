<#
.SYNOPSIS
    A compliance policy for Windows devices exists and is assigned
#>

function Test-Assessment-24541 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24541,
    	Title = 'Compliance policies protect Windows devices',
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

    $activity = "Checking Windows compliance policies are created and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting compliance policies"

    # Query 1: List all compliance policies for Windows in Intune
    $compliancePoliciesUri = 'deviceManagement/deviceCompliancePolicies?$expand=assignments'
    $allCompliancePolicies = Invoke-ZtGraphRequest -RelativeUri $compliancePoliciesUri -ApiVersion v1.0

    # Filter for Windows compliance policies
    $windowsCompliancePolicies = $allCompliancePolicies | Where-Object {
        $_.'@odata.type' -eq '#microsoft.graph.windows10CompliancePolicy' -or
        $_.'@odata.type' -eq '#microsoft.graph.windows11CompliancePolicy'
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Check if at least one Windows compliance policy exists
    Write-ZtProgress -Activity $activity -Status "Checking policy assignments"
    $passed = $windowsCompliancePolicies.Count -gt 0 -and $windowsCompliancePolicies.assignments.Count -gt 0
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Windows Compliance Policies"
    $tableRows = ""
    if ($passed) {
        $testResultMarkdown = "At least one compliance policy for Windows exists and is assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No compliance policy for Windows exists or none are assigned.`n`n%TestResult%"
    }

    if ($windowsCompliancePolicies.Count -gt 0) {
                # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $windowsCompliancePolicies) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/compliance'
            $status = if ($policy.assignments.Count -gt 0) {
                '✅ Assigned'
            }
            else {
                '❌ Not Assigned'
            }

            $policyName = Get-SafeMarkdown -Text $policy.displayName
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += @"
| [$policyName]($portalLink) | $status | $assignmentTarget |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    else {
        $mdInfo = "No compliance policy for Windows exists or none are assigned.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24541'
        Title  = 'Windows Compliance Policy is Created and Assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
