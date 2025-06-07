<#
.SYNOPSIS

#>

function Test-Assessment-21817 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Global Administrator role activation triggers an approval workflow"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    Write-ZtProgress -Activity $activity -Status "Getting PIM policy assignments for Global Administrator role"

    # Query retrieves the associated PIM role management policy assignments for Global Administrator role
    $sqlPolicyAssignments = @"
SELECT
    rmp.id as policyAssignmentId,
    rmp.roleDefinitionId,
    rmp.scopeId,
    rmp.scopeType,
    rmp.policyId
FROM main."RoleManagementPolicyAssignment" rmp
WHERE rmp.roleDefinitionId = '62e90394-69f5-4237-9190-012177145e10'
    AND rmp.scopeId = '/'
    AND rmp.scopeType = 'DirectoryRole';
"@

    $resultsPolicyAssignments = Invoke-DatabaseQuery -Database $Database -Sql $sqlPolicyAssignments

    $tableRows = ""

    if ($resultsPolicyAssignments -and $resultsPolicyAssignments.policyId) {
        Write-ZtProgress -Activity $activity -Status "Checking approval requirements for Global Administrator role"

        # Get the approval rule for the Global Administrator role policy
        $approvalRule = Invoke-ZtGraphRequest -RelativeUri "policies/roleManagementPolicies/$($resultsPolicyAssignments.policyId)/rules/Approval_EndUser_Assignment" -ApiVersion 'v1.0'

        # Check if approval is required and has approvers
        if ($approvalRule.setting.isApprovalRequired -eq $true) {
            $approverCount = 0
            foreach ($stage in $approvalRule.setting.approvalStages) {
                $approverCount += ($stage.primaryApprovers | Measure-Object).Count
            }

            if ($approverCount -gt 0) {
                $result = $true
                $testResultMarkdown = "✅ **Pass**: Approval required with $approverCount primary approver(s) configured.`n`n%TestResult%"
                $tableRows += "| Yes | $($approvalRule.setting.approvalStages[0].primaryApprovers.description -join ', ') | $($approvalRule.setting.approvalStages[0].escalationApprovers.description -join ', ') |`n"
            }
            else {
                $result = $false
                $testResultMarkdown = "❌ **Fail**: Approval required but no approvers configured.`n`n%TestResult%"
                $tableRows += "| Yes | None | None |`n"
            }
        }
        else {
            $result = $false
            $testResultMarkdown = "❌ **Fail**: Approval not required for Global Administrator role activation.`n`n%TestResult%"
            $tableRows += "| No | N/A | N/A |`n"
        }
    }
    else {
        $result = $false
        $testResultMarkdown = "❌ **Fail**: No PIM policy found for Global Administrator role.`n`n%TestResult%"
        $tableRows += "| N/A | N/A | N/A |`n"
    }

    $passed = $result


    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Global Administrator role activation and approval workflow"


    # Create a here-string with format placeholders {0}, {1}, etc.
    $formatTemplate = @'

## {0}


| Approval Required | Primary Approvers | Escalation Approvers |
| :---------------- | :---------------- | :------------------- |
{1}

'@

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $tableRows

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21817'
        Title              = "Global Administrator role activation triggers an approval workflow"
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'Medium'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
