<#
.SYNOPSIS
    Checks that activation alerts are configured for the Global Administrator role assignment.
#>

function Test-Assessment-21819 {
    [ZtTest(
        Category = 'Privileged access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('P2'),
        Pillar = 'Identity',
        RiskLevel = 'Low',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 21819,
        Title = 'Activation alert for Global Administrator role assignment',
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
    Write-ZtProgress -Activity $activity -Status 'Getting Global Administrator role definition'

    # Query 1: Get only the Global Administrator role definition
    # Global Administrator role template ID: 62e90394-69f5-4237-9190-012177145e10
    $sql = @"
    SELECT id, displayName
    FROM RoleDefinition
    WHERE templateId = '62e90394-69f5-4237-9190-012177145e10'
"@

    $globalAdminRole = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    if (-not $globalAdminRole) {
        $testResultMarkdown = "## Global Administrator Role Not Found`n`n"
        $testResultMarkdown += "*Could not find the Global Administrator role definition.*`n`n"

        Add-ZtTestResultDetail -TestId '21819' -Status $false -Result $testResultMarkdown
        return
    }

    Write-PSFMessage "Found Global Administrator role: $($globalAdminRole.displayName)" -Level Verbose
    Write-ZtProgress -Activity $activity -Status "Checking alerts for $($globalAdminRole.displayName)"

    # Query 2: Get PIM role management policy assignment
    $filter = "scopeId eq '/' and scopeType eq 'DirectoryRole' and roleDefinitionId eq '$($globalAdminRole.id)'"
    $policyAssignments = Invoke-ZtGraphRequest -RelativeUri 'policies/roleManagementPolicyAssignments' -Filter $filter -ApiVersion beta

    $passed = $false
    if (-not $policyAssignments) {
        Write-PSFMessage "No PIM policy assignment found for Global Administrator role" -Level Verbose
        $isDefaultRecipientsEnabled = 'N/A'
        $recipients = 'N/A'
    }
    else {
        $policyId = $policyAssignments[0].policyId
        Write-PSFMessage "Found policy ID: $policyId" -Level Verbose

        # Query 3: Get activation notification rules
        $notificationRuleUri = "policies/roleManagementPolicies/$policyId/rules/Notification_Requestor_EndUser_Assignment"
        $notificationRule = Invoke-ZtGraphRequest -RelativeUri $notificationRuleUri -ApiVersion beta -DisableCache

        $isDefaultRecipientsEnabled = $notificationRule.isDefaultRecipientsEnabled
        $notificationRecipients = $notificationRule.notificationRecipients
        $recipients = $notificationRecipients -join ', '

        Write-PSFMessage "isDefaultRecipientsEnabled: $isDefaultRecipientsEnabled, Recipients: $($notificationRecipients -join ', ')" -Level Verbose

        $passed = $notificationRecipients -or $isDefaultRecipientsEnabled
    }
    #endregion Data Collection

    if ($passed) {
        $testResultMarkdown = "Activation alerts are configured for Global Administrator role.`n`n"
    }
    else {
        $testResultMarkdown = "Activation alerts are missing or improperly configured for Global Administrator role.`n`n"
    }

    #region Report Generation
    # Always show the table with configuration details
    $testResultMarkdown += "| Role display name | Default recipients | Additional recipients |`n"
    $testResultMarkdown += "| :---------------- | :----------------- | :------------------- |`n"

    $roleLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles"
    $displayNameLink = "[$($globalAdminRole.displayName)]($roleLink)"
    $defaultRecipientsStatus = if ($isDefaultRecipientsEnabled -eq $true) {
        '✅ Enabled'
    }
    elseif ($isDefaultRecipientsEnabled -eq $false) {
        '❌ Disabled'
    }
    else {
        'N/A'
    }
    $recipientsDisplay = if ([string]::IsNullOrEmpty($recipients)) {
        '-'
    }
    else {
        $recipients
    }

    $testResultMarkdown += "| $displayNameLink | $defaultRecipientsStatus | $recipientsDisplay |`n"
    #endregion Report Generation

    $params = @{
        TestId = '21819'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
