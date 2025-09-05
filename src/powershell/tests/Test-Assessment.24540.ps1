
<#
.SYNOPSIS

#>



function Test-Assessment-24540 {
    [CmdletBinding()]
    param()

    #region Helper Functions
    function Get-PolicyAssignmentTarget {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            $Assignments
        )

        if (-not $Assignments -or $Assignments.Count -eq 0) {
            return "None"
        }

        $includedTargets = @()
        $excludedTargets = @()

        foreach ($assignment in $Assignments) {
            $isExcluded = $assignment.target.'@odata.type' -eq '#microsoft.graph.exclusionGroupAssignmentTarget'

            if ($assignment.target.groupId -and $assignment.target.groupId -ne "") {
                $groupName = Invoke-ZtGraphRequest -RelativeUri "groups/$($assignment.target.groupId)?`$select=displayName" -ApiVersion v1.0
                if ($isExcluded) {
                    $excludedTargets += $groupName.displayName
                }
                else {
                    $includedTargets += $groupName.displayName
                }
            }
            elseif ($assignment.target.'@odata.type' -eq '#microsoft.graph.allDevicesAssignmentTarget') {
                $includedTargets += "All Devices"
            }
            elseif ($assignment.target.'@odata.type' -eq '#microsoft.graph.allLicensedUsersAssignmentTarget') {
                $includedTargets += "All Users"
            }
        }

        # Build grouped assignment target string
        $assignmentParts = @()
        if ($includedTargets.Count -gt 0) {
            $assignmentParts += "**Included:** " + ($includedTargets -join ", ")
        }
        if ($excludedTargets.Count -gt 0) {
            $assignmentParts += "**Excluded:** " + ($excludedTargets -join ", ")
        }

        if ($assignmentParts.Count -gt 0) {
            return $assignmentParts -join ", "
        }

        return "None"
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Windows Firewall policies are created and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query 1: Retrieve all Windows Firewall configuration policies and their potential assignments
    $firewallPoliciesWithAssignmentsUri = "deviceManagement/configurationPolicies?`$select=id,name,description,isAssigned,templateReference&`$expand=assignments&`$top=25&`$filter=templateReference/TemplateFamily eq 'endpointSecurityFirewall'"
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
            $policyWithAssignments = $firewallPoliciesWithAssignments | Where-Object { $_.id -eq $policy.id }
            $assignmentTarget = "None"

            if ($policyWithAssignments -and $policyWithAssignments.assignments -and $policyWithAssignments.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policyWithAssignments.assignments
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
