<#
.SYNOPSIS
    Checks that activation alerts are configured for all privileged role assignments.
#>

function Test-Assessment-21820 {
    [ZtTest(
        Category = 'Privileged access',
        ImplementationCost = 'Medium',
        Pillar = 'Identity',
        RiskLevel = 'Low',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 21820,
        Title = 'Activation alert for all privileged role assignments',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if ( -not (Get-ZtLicense EntraIDP2) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP2
        return
    }

    #region Data Collection
    $activity = 'Checking activation alerts for privileged role assignments'
    Write-ZtProgress -Activity $activity -Status 'Getting privileged role definitions'

    # Query 1: Get all highly privileged role definitions from database
    $sql = @"
    SELECT id, displayName
    FROM RoleDefinition
    WHERE isPrivileged = 1
"@

    $privilegedRoles = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    Write-PSFMessage "Found $($privilegedRoles.Count) privileged role definitions" -Level Verbose

    # Query 2: Get all PIM role management policy assignments for directory roles (single API call)
    Write-ZtProgress -Activity $activity -Status 'Getting PIM policy assignments'

    $filter = "scopeId eq '/' and scopeType eq 'DirectoryRole'"
    $allPolicyAssignments = Invoke-ZtGraphRequest -RelativeUri 'policies/roleManagementPolicyAssignments' -Filter $filter -ApiVersion beta

    # Build hashtable mapping roleDefinitionId -> policyId for quick lookup
    $policyIdByRoleId = @{}
    foreach ($assignment in $allPolicyAssignments) {
        $policyIdByRoleId[$assignment.roleDefinitionId] = $assignment.policyId
    }

    # Track roles with missing or misconfigured alerts
    $rolesWithIssues = @()
    # Flag to control early exit when first issue is found
    $exitLoop = $false
    $passed = $true
    $totalRoles = $privilegedRoles.Count
    $currentRole = 0

    foreach ($role in $privilegedRoles) {
        $currentRole++
        Write-ZtProgress -Activity $activity -Status "Checking alerts for $($role.displayName) ($currentRole of $totalRoles)"

        Write-PSFMessage "Checking PIM policy for role: $($role.displayName) (ID: $($role.id))" -Level Verbose

        # Lookup policy ID from hashtable
        # id is a GUID, so use Guid property for lookup
        $policyId = $policyIdByRoleId[$role.id.Guid]

        if (-not $policyId) {
            Write-PSFMessage "No PIM policy assignment found for role: $($role.displayName)" -Level Verbose

            $rolesWithIssues += @{
                Role                       = $role
                Issue                      = 'No PIM policy assignment found'
                IsDefaultRecipientsEnabled = 'N/A'
                NotificationRecipients     = 'N/A'
            }
            continue
        }

        Write-PSFMessage "Found policy ID: $policyId for role: $($role.displayName)" -Level Verbose

        # Query 3: Get activation notification rules for this policy
        $notificationRuleUri = "policies/roleManagementPolicies/$policyId/rules/Notification_Requestor_EndUser_Assignment"

        $notificationRule = Invoke-ZtGraphRequest -RelativeUri $notificationRuleUri -ApiVersion beta

        $isDefaultRecipientsEnabled = $notificationRule.isDefaultRecipientsEnabled
        $notificationRecipients = $notificationRule.notificationRecipients

        Write-PSFMessage "Role: $($role.displayName) - isDefaultRecipientsEnabled: $isDefaultRecipientsEnabled, Recipients: $($notificationRecipients -join ', ')" -Level Verbose

        # Check if alert is properly configured
        # Fail if: (isDefaultRecipientsEnabled is true AND notificationRecipients is empty) OR (isDefaultRecipientsEnabled is false AND no custom recipients)
        if (($isDefaultRecipientsEnabled -eq $true -and ([string]::IsNullOrEmpty($notificationRecipients) -or $notificationRecipients.Count -eq 0))) {

            $passed = $false
            Write-PSFMessage "Alert misconfigured for role: $($role.displayName) - Default recipients enabled but no recipients configured" -Level Verbose

            $rolesWithIssues += @{
                Role                       = $role
                IsDefaultRecipientsEnabled = $isDefaultRecipientsEnabled
                NotificationRecipients     = 'N/A'
            }

            $exitLoop = $true
        }
        else {
            Write-PSFMessage "Alert properly configured for role: $($role.displayName)" -Level Verbose
        }

        if ($exitLoop) {
            break
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($rolesWithIssues.Count -eq 0) {
        $passed = $true
        $testResultMarkdown = 'Activation alerts are configured for privileged role assignments.'
    }
    else {
        $passed = $false
        $testResultMarkdown = 'Activation alerts are missing or improperly configured for privileged roles.'
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build markdown output
    $mdInfo = ""

    if ($rolesWithIssues.Count -gt 0) {
        $mdInfo += "`n## Roles with missing or misconfigured alerts`n`n"
        $mdInfo += "| Role display name | Default recipients | Additional recipients |`n"
        $mdInfo += "| :---------------- | :----------------- | :------------------- |`n"

        foreach ($roleIssue in $rolesWithIssues) {
            $role = $roleIssue.Role
            $roleLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles"
            $displayName = $role.displayName
            $displayNameLink = "[$displayName]($roleLink)"

            $defaultRecipientsStatus = if ($roleIssue.IsDefaultRecipientsEnabled -eq $true) {
                'Enabled'
            }
            else {
                'Disabled'
            }
            $recipients = $roleIssue.NotificationRecipients

            $mdInfo += "| $displayNameLink | $defaultRecipientsStatus | $recipients |`n"
        }
        $mdInfo += "`n`n*Not all misconfigured roles may be listed. For performance reasons, this assessment stops at the first detected issue.*`n"
    }

    # Append details to the test result
    $testResultMarkdown += $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '21820'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
