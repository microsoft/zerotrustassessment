<#
.SYNOPSIS
    Checks if local administrators are managed on Microsoft Entra joined devices.
#>

function Test-Assessment-21955 {
    [ZtTest(
    	Category = 'Devices',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21955,
    	Title = 'Manage the local administrators on Microsoft Entra joined devices',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    # Check for Intune license, if present skip the test
    if (Get-ZtLicense Intune) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    #region Data Collection
    $activity = 'Checking Manage the local administrators on Microsoft Entra joined devices'

    # Query role assignments from database
    Write-ZtProgress -Activity $activity -Status 'Getting role assignments'
    $deviceLocalAdminRoleId = '9f06204d-73c1-4d4c-880a-6edb90606fd8'

    # Query database for assigned and eligible users/groups for this role
    $sql = "SELECT principalDisplayName, userPrincipalName, `"@odata.type`", principalId, privilegeType
              FROM vwRole
              WHERE roleDefinitionId = '$deviceLocalAdminRoleId';"

    $roleAssignments = Invoke-DatabaseQuery -Database $Database -Sql $sql

    Write-PSFMessage "Found $($roleAssignments.Count) role assignments for Azure AD Joined Device Local Administrator" -Level Verbose

    # Separate assigned vs eligible
    $assignedMembers = $roleAssignments | Where-Object { $_.privilegeType -eq 'Permanent' }
    $eligibleMembers = $roleAssignments | Where-Object { $_.privilegeType -eq 'Eligible' }
    #endregion Data Collection

    #region Assessment Logic

    if ($roleAssignments.Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "Local administrators on Microsoft Entra joined devices are managed by the organization.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "Local administrators on Microsoft Entra joined devices are not managed by the organization.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation

    # Build detailed markdown
    # Get current tenant ID from context to build the portal link
    $resourceId = (Get-MgContext).TenantId
    $assignmentsPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/$deviceLocalAdminRoleId/roleId/$deviceLocalAdminRoleId/roleTemplateId/$deviceLocalAdminRoleId/roleName/Microsoft%20Entra%20Joined%20Device%20Local%20Administrator/isRoleCustom~/false/resourceScopeId/%2F/resourceId/$resourceId"

    $mdInfo = ''

    if ($assignedMembers.Count -gt 0) {
        $mdInfo += "`n## [Active Microsoft Entra Joined Device Local Administrator assignments]($assignmentsPortalLink)`n`n"
        $mdInfo += "| Display name | UPN | Type | Assignment type |`n"
        $mdInfo += "| :----------- | :--- | :--- | :-------------- |`n"

        foreach ($member in ($assignedMembers | Sort-Object -Property principalDisplayName)) {
            $objectType = if ($member.'@odata.type' -eq '#microsoft.graph.user') { 'User' } else { 'Group' }
            $upn = if ([string]::IsNullOrWhiteSpace($member.userPrincipalName)) { 'N/A' } else { $member.userPrincipalName }

            $portalLink = if ($member.'@odata.type' -eq '#microsoft.graph.user') {
                "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/$($member.principalId)"
            } else {
                "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/$($member.principalId)"
            }

            $mdInfo += "| [$(Get-SafeMarkdown $member.principalDisplayName)]($portalLink) | $upn | $objectType | $($member.privilegeType) |`n"
        }
    }

    if ($eligibleMembers.Count -gt 0) {
        $mdInfo += "`n## [Eligible Microsoft Entra Joined Device Local Administrator assignments]($assignmentsPortalLink)`n`n"
        $mdInfo += "| Display name | UPN | Type | Assignment type |`n"
        $mdInfo += "| :----------- | :--- | :--- | :-------------- |`n"

        foreach ($member in ($eligibleMembers | Sort-Object -Property principalDisplayName)) {
            $objectType = if ($member.'@odata.type' -eq '#microsoft.graph.user') { 'User' } else { 'Group' }
            $upn = if ([string]::IsNullOrWhiteSpace($member.userPrincipalName)) { 'N/A' } else { $member.userPrincipalName }

            $portalLink = if ($member.'@odata.type' -eq '#microsoft.graph.user') {
                "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/$($member.principalId)"
            } else {
                "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/$($member.principalId)"
            }

            $mdInfo += "| [$(Get-SafeMarkdown $member.principalDisplayName)]($portalLink) | $upn | $objectType | $($member.privilegeType) |`n"
        }
    }

    if ($roleAssignments.Count -eq 0) {
        $mdInfo = "`n❌ No assigned or eligible users/groups found for the Microsoft Entra Joined Device Local Administrator role.`n"
    }

    # Replace placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '21955'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
