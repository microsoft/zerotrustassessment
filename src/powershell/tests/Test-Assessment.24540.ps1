
<#
.SYNOPSIS

#>



function Test-Assessment-24540 {
    [ZtTest(
    	Category = 'Device',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce'),
    	TestId = 24540,
    	Title = 'Windows Firewall policies protect against unauthorized network access',
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

    $activity = "Checking Windows Firewall policies are created and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query 1: Retrieve all Windows Firewall configuration policies and their potential assignments
    $firewallPoliciesWithAssignmentsUri = "deviceManagement/configurationPolicies?`$select=id,name,description,isAssigned,templateReference&`$expand=assignments&`$filter=templateReference/TemplateFamily eq 'endpointSecurityFirewall'"
    $firewallPoliciesWithAssignments = Invoke-ZtGraphRequest -RelativeUri $firewallPoliciesWithAssignmentsUri -ApiVersion beta
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Check if at least one policy exists
    if ($firewallPoliciesWithAssignments.Count -gt 0) {

        # Check if at least one policy has assignments
        $assignedPolicies = $firewallPoliciesWithAssignments | Where-Object {
            $_.assignments -and $_.assignments.Count -gt 0
        }

        if ($assignedPolicies.Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "At least one Windows Firewall policy is created and assigned to a group.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "There are no firewall policies assigned to any groups.`n`n%TestResult%"
        }
    }
    else {
        $passed = $false
        $testResultMarkdown = "No Windows Firewall configuration policies found.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Windows Firewall Configuration Policies"
    $tableRows = ""

    if ($firewallPoliciesWithAssignments.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($policy in $firewallPoliciesWithAssignments) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/firewall'

            $status = if ($policy.isAssigned) {
                "✅ Assigned"
            }
            else {
                "❌ Not assigned"
            }

            # Get assignment details for this specific policy
            $assignmentTarget = 'None'

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += @"
| [$(Get-SafeMarkdown($policy.name))]($portalLink) | $status | $assignmentTarget |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    else {
        $mdInfo = "No Windows Firewall configuration policies found in this tenant.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24540'
        Title  = 'Windows Firewall Policy is Created and Assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
