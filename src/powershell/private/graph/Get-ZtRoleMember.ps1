<#
.Synopsis
Returns all the members of a role.

.Description
The role can be either active or eligible, defaults to getting members that are both active and eligible.

.Example
Get-ZtRoleMember -Role GlobalAdministrator

Returns all the Global administrators and includes both Eligible and Active members.

.Example
Get-ZtRoleMember -Role GlobalAdministrator -MemberStatus Active

Returns all the Global administrators that are currently active and excludes those that are eligible but not yet active.

.Example
Get-ZtRoleMember -Role GlobalAdministrator -MemberStatus Active

Returns all the Global administrators that are currently active and excludes those that are eligible but not yet active.

.EXAMPLE
Get-ZtRoleMember -Role GlobalAdministrator,PrivilegedRoleAdministrator

Returns all the Global administrators and Privileged Role administrators and includes both Eligible and Active members.

.Example
Get-ZtRoleMember -RoleId "00000000-0000-0000-0000-000000000000"

Returns all the members of the role with the specified RoleId and includes both Eligible and Active members.

.Example
Get-ZtRoleMember -RoleId "00000000-0000-0000-0000-000000000000" -MemberStatus Active

Returns all the currently active members of the role with the specified RoleId.

#>

function Get-ZtRoleMember {
	[CmdletBinding(DefaultParameterSetName = "RoleName")]
	param(
		# The name of the role to get members for.
		[Parameter(ParameterSetName = "RoleName", Position = 0, Mandatory = $true)]
		[ValidateSet('ApplicationAdministrator', 'ApplicationDeveloper', 'AttackPayloadAuthor', 'AttackSimulationAdministrator', 'AttributeAssignmentAdministrator', 'AttributeAssignmentReader', 'AttributeDefinitionAdministrator', 'AttributeDefinitionReader', 'AttributeLogAdministrator', 'AttributeLogReader', 'AuthenticationAdministrator', 'AuthenticationExtensibilityAdministrator', 'AuthenticationPolicyAdministrator', 'AzureADJoinedDeviceLocalAdministrator', 'AzureDevOpsAdministrator', 'AzureInformationProtectionAdministrator', 'B2CIEFKeysetAdministrator', 'B2CIEFPolicyAdministrator', 'BillingAdministrator', 'CloudAppSecurityAdministrator', 'CloudApplicationAdministrator', 'CloudDeviceAdministrator', 'ComplianceAdministrator', 'ComplianceDataAdministrator', 'ConditionalAccessAdministrator', 'CustomerLockBoxAccessApprover', 'DesktopAnalyticsAdministrator', 'DeviceJoin', 'DeviceManagers', 'DeviceUsers', 'DirectoryReaders', 'DirectorySynchronizationAccounts', 'DirectoryWriters', 'DomainNameAdministrator', 'Dynamics365Administrator', 'Dynamics365BusinessCentralAdministrator', 'EdgeAdministrator', 'ExchangeAdministrator', 'ExchangeRecipientAdministrator', 'ExtendedDirectoryUserAdministrator', 'ExternalIDUserFlowAdministrator', 'ExternalIDUserFlowAttributeAdministrator', 'ExternalIdentityProviderAdministrator', 'FabricAdministrator', 'GlobalAdministrator', 'GlobalReader', 'GlobalSecureAccessAdministrator', 'GroupsAdministrator', 'GuestInviter', 'GuestUser', 'HelpdeskAdministrator', 'HybridIdentityAdministrator', 'IdentityGovernanceAdministrator', 'InsightsAdministrator', 'InsightsAnalyst', 'InsightsBusinessLeader', 'IntuneAdministrator', 'KaizalaAdministrator', 'KnowledgeAdministrator', 'KnowledgeManager', 'LicenseAdministrator', 'LifecycleWorkflowsAdministrator', 'MessageCenterPrivacyReader', 'MessageCenterReader', 'Microsoft365MigrationAdministrator', 'MicrosoftHardwareWarrantyAdministrator', 'MicrosoftHardwareWarrantySpecialist', 'NetworkAdministrator', 'OfficeAppsAdministrator', 'OnPremisesDirectorySyncAccount', 'OrganizationalBrandingAdministrator', 'OrganizationalMessagesApprover', 'OrganizationalMessagesWriter', 'PartnerTier1Support', 'PartnerTier2Support', 'PasswordAdministrator', 'PermissionsManagementAdministrator', 'PowerPlatformAdministrator', 'PrinterAdministrator', 'PrinterTechnician', 'PrivilegedAuthenticationAdministrator', 'PrivilegedRoleAdministrator', 'ReportsReader', 'RestrictedGuestUser', 'SearchAdministrator', 'SearchEditor', 'SecurityAdministrator', 'SecurityOperator', 'SecurityReader', 'ServiceSupportAdministrator', 'SharePointAdministrator', 'SharePointEmbeddedAdministrator', 'SkypeforBusinessAdministrator', 'TeamsAdministrator', 'TeamsCommunicationsAdministrator', 'TeamsCommunicationsSupportEngineer', 'TeamsCommunicationsSupportSpecialist', 'TeamsDevicesAdministrator', 'TeamsTelephonyAdministrator', 'TenantCreator', 'UsageSummaryReportsReader', 'User', 'UserAdministrator', 'UserExperienceSuccessManager', 'VirtualVisitsAdministrator', 'VivaGoalsAdministrator', 'VivaPulseAdministrator', 'Windows365Administrator', 'WindowsUpdateDeploymentAdministrator', 'WorkplaceDeviceJoin', 'YammerAdministrator')]
		[string[]]$Role,

		# The ID of the role to get members for.
		[Parameter(ParameterSetName = "RoleId", Position = 0, Mandatory = $true)]
		[guid[]]$RoleId,

		# The type of members to look for. Default is both Eligible and Active.
		[ValidateSet('Eligible', 'Active', 'EligibleAndActive')]
		[string]$MemberStatus
	)

	function Get-UsersInRole {
		[CmdletBinding()]
		param(
			[string]$Uri,
			[string]$RoleId,
			[string]$Filter,
			[ValidateSet('Eligible', 'Active')]
			[string]$RoleAssignmentType)

		if ($Filter) {
			$Filter = "roleDefinitionId eq '$directoryRoleId' and $Filter"
		}
		else {
			$Filter = "roleDefinitionId eq '$directoryRoleId'"
		}

		$params = @{
			ApiVersion      = "v1.0"
			RelativeUri     = $Uri
			Filter          = $Filter
			QueryParameters = @{
				expand = "principal"
			}
		}

		$dirAssignments = Invoke-ZtGraphRequest @params

		$assignments = @()
		if ($dirAssignments.id.Count -eq 0) {
			Write-PSFMessage "No role assignments found" -Level Debug
			return $assignments
		}
		$assignments += @($dirAssignments.principal)

		$groups = $assignments | Where-Object { $_.'@odata.type' -eq "#microsoft.graph.group" }
		$groups | ForEach-Object {
			#5/10/2024 - Entra ID Role Enabled Security Groups do not currently support nesting
			$assignments += Get-ZtGroupMember -groupId $_.id
		}

		# Append the type of assignment
		$assignments | ForEach-Object {
			$_ | Add-Member -MemberType NoteProperty -Name "AssignmentType" -Value $RoleAssignmentType -Force
		}
		return $assignments
	}

	if (-not $MemberStatus -or $MemberStatus -eq "EligibleAndActive") {
		$Eligible = $Active = $true
	}
	elseif ($MemberStatus -eq "Eligible") {
		$Eligible = $true
	}
	elseif ($MemberStatus -eq "Active") {
		$Active = $true
	}

	if ($Role) {
		$RoleId = $Role | ForEach-Object { (Get-ZtRoleInfo -RoleName $_) }
	}

	$EntraIDPlan = Get-ZtLicenseInformation -Product EntraID
	$pim = $EntraIDPlan -eq "P2" -or $EntraIDPlan -eq "Governance"

	foreach ($directoryRoleId in $RoleId) {
		$assignments = @()
		if ($Active) {
			if ($pim) {
				$uri = 'roleManagement/directory/roleAssignmentScheduleInstances'
				# assignmentType eq 'Assigned' filters out eligible users that have temporarily activated the role
				$assignments += Get-UsersInRole -Uri $uri -RoleId $directoryRoleId -RoleAssignmentType Active -Filter "assignmentType eq 'Assigned'"
			}
			else {
				#Free or P1 tenant (PIM APIs cannot be called on non-P2 tenants)
				$uri = 'roleManagement/directory/roleAssignments'
				$assignments += Get-UsersInRole -Uri $uri -RoleId $directoryRoleId -RoleAssignmentType Active
			}
		}
		if ($Eligible) {
			$uri = 'roleManagement/directory/roleEligibilityScheduleInstances'
			$assignments += Get-UsersInRole -Uri $uri -RoleId $directoryRoleId -RoleAssignmentType Eligible
		}

		$assignments | Sort-Object id -Unique
	}
}
