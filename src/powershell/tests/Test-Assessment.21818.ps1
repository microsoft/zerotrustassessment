<#
.SYNOPSIS

#>

function Test-Assessment-21818 {
    [ZtTest(
    	Category = 'Monitoring',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('P2'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Monitor and detect cyberthreats',
    	TenantType = ('Workforce'),
    	TestId = 21818,
    	Title = 'Privileged role activations have monitoring and alerting configured',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Activation alert for highly privileged role assignments"
    Write-ZtProgress -Activity $activity -Status "Getting PIM policy assignments for highly privileged roles"

    $EntraIDPlan = Get-ZtLicenseInformation -Product EntraID
    if ($EntraIDPlan -eq "Free" -or $EntraIDPlan -eq "P1") {
        Write-PSFMessage '🟦 Skipping test: Requires P2 or Governance plan' -Tag Test -Level VeryVerbose
        return
    }

    # Query retrieves the associated PIM role management policy assignments for each highly privileged role
    $sqlPolicyAssignments = @"
SELECT
    rmp.id as policyAssignmentId,
    rmp.roleDefinitionId,
    rmp.scopeId,
    rmp.scopeType,
    rmp.policyId,
    rd.displayName as roleDisplayName,
    rd.isPrivileged
FROM main."RoleManagementPolicyAssignment" rmp
INNER JOIN main."RoleDefinition" rd ON rmp.roleDefinitionId = rd.id
WHERE rd.isPrivileged = true
    AND rmp.scopeId = '/'
    AND rmp.scopeType = 'DirectoryRole'
ORDER BY rd.displayName;
"@
    $resultsPolicyAssignments = Invoke-DatabaseQuery -Database $Database -Sql $sqlPolicyAssignments

    # Define PIM notification settings that should be checked
    $notifications = @(
        [PSCustomObject]@{
            NotificationScenario = "Send notifications when members are assigned as eligible to this role"
            NotificationType     = "Role assignment alert"
            RuleId               = "Notification_Admin_Admin_Eligibility"
        }
        [PSCustomObject]@{
            NotificationScenario = "Send notifications when members are assigned as eligible to this role"
            NotificationType     = "Notification to the assigned user (assignee)"
            RuleId               = "Notification_Requestor_Admin_Eligibility"
        }
        [PSCustomObject]@{
            NotificationScenario = "Send notifications when members are assigned as eligible to this role"
            NotificationType     = "Request to approve a role assignment renewal/extension"
            RuleId               = "Notification_Approver_Admin_Eligibility"
        }
        [PSCustomObject]@{
            NotificationScenario = "Send notifications when members are assigned as active to this role"
            NotificationType     = "Role assignment alert"
            RuleId               = "Notification_Admin_Admin_Assignment"
        }
        [PSCustomObject]@{
            NotificationScenario = "Send notifications when members are assigned as active to this role"
            NotificationType     = "Notification to the assigned user (assignee)"
            RuleId               = "Notification_Requestor_Admin_Assignment"
        }
        [PSCustomObject]@{
            NotificationScenario = "Send notifications when members are assigned as active to this role"
            NotificationType     = "Request to approve a role assignment renewal/extension"
            RuleId               = "Notification_Approver_Admin_Assignment"
        }
        [PSCustomObject]@{
            NotificationScenario = "Send notifications when eligible members activate this role"
            NotificationType     = "Role activation alert"
            RuleId               = "Notification_Admin_EndUser_Assignment"
        }
        [PSCustomObject]@{
            NotificationScenario = "Send notifications when eligible members activate this role"
            NotificationType     = "Notification to activated user (requestor)"
            RuleId               = "Notification_Requestor_EndUser_Assignment"
        }
        [PSCustomObject]@{
            NotificationScenario = "Send notifications when eligible members activate this role"
            NotificationType     = "Request to approve an activation"
            RuleId               = "Notification_Approver_EndUser_Assignment"
        }
    )

    # Build one request per (policy, rule) pair and fetch them all in batched calls
    Write-ZtProgress -Activity $activity -Status "Getting activation notification rules"

    $ruleRequests = foreach ($policyAssignment in $resultsPolicyAssignments) {
        foreach ($ruleId in $notifications.ruleId) {
            [PSCustomObject]@{
                PolicyId        = $policyAssignment.policyId
                RuleId          = $ruleId
                RoleDisplayName = $policyAssignment.roleDisplayName
            }
        }
    }

    $notificationRules = @()
    if ($ruleRequests) {
        $ruleResults = Invoke-ZtGraphBatchRequest -Path "policies/roleManagementPolicies/{0}/rules/{1}" -ArgumentList $ruleRequests -Properties PolicyId, RuleId -Matched -ErrorAction SilentlyContinue
        foreach ($result in $ruleResults) {
            if (-not $result.Success -or -not $result.Result) { continue }
            $rule = $result.Result | Select-Object -First 1
            $notificationRules += ($rule | Add-Member -MemberType NoteProperty -Name RoleDisplayName -Value $result.Argument.RoleDisplayName -Force -PassThru)
        }
    }

    # A role is non-compliant when a notification rule has default recipients disabled and no
    # additional recipients configured.
    $failingRule = $notificationRules | Where-Object {
        $_.isDefaultRecipientsEnabled -eq $false -and
        ($null -eq $_.notificationRecipients -or $_.notificationRecipients.Count -eq 0)
    } | Select-Object -First 1
    $passed = -not $failingRule

    $testResultMarkdown = ""

    # Output the result of the check
    if ($passed) {
        $testResultMarkdown += "Role notifications are properly configured for privileged role.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "Role notifications are not properly configured.`n`n%TestResult%"
    }

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Notifications for high privileged roles"
    $tableRows = ""

    # Create a here-string with format placeholders {0}, {1}, etc.
    $formatTemplate = @'

## {0}


| Role Name | Notification Scenario | Notification Type | Default Recipients Enabled | Additional Recipients |
| :-------- | :-------------------- | :---------------- | :------------------------- | :-------------------- |
{1}

'@

    foreach ($notificationRule in $notificationRules) {
        $matchingNotification = $notifications | Where-Object { $_.RuleId -eq $notificationRule.id }
        $tableRows += @"
| $($notificationRule.roleDisplayName) | $($matchingNotification.notificationScenario) | $($matchingNotification.notificationType) | $($notificationRule.isDefaultRecipientsEnabled) | $($notificationRule.notificationRecipients -join ', ') |`n
"@
    }

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $tableRows

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo


    $params = @{
        TestId             = '21818'
        Title              = "Activation alert for highly privileged role assignments"
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
