<#
.SYNOPSIS
Connects to the tenant and downloads the data to a local folder.

.DESCRIPTION
This function connects to the tenant and downloads the data to a local folder.

.PARAMETER OutputFolder
The folder to output the report to. If not specified, the report will be output to the current directory.
#>

function Export-ZtTenantData {
	[CmdletBinding()]
	param (
		# The folder to output the report to.
		[string]
		[Parameter(Mandatory = $true)]
		$ExportPath,

		# The number of days to export the log data for.
		[int]
		$Days,

		# The maximum time (in minutes) the assessment should spend on querying sign-in logs. Defaults to collecting sign logs for 60 minutes. Set to 0 for no limit.
		[int]
		$MaximumSignInLogQueryTime,

		# The Zero Trust pillar to assess. Defaults to All.
		[ValidateSet('All', 'Identity', 'Devices')]
		[string]
		$Pillar = 'All',

		[int]
		$ThrottleLimit = (Get-PSFConfigValue -FullName 'ZeroTrustAssessment.ThrottleLimit.Export' -Fallback 5)
	)

	#region Helper Functions
	function Get-ZtiAuditQueryString {
		[CmdletBinding()]
		param (
			[int]
			$PastDays
		)

		# Get the date range to query by subtracting the number of days from today set to midnight
		$statusFilter = "status/errorcode eq 0"

		$dateStart = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-$pastDays)

		# convert the date to the correct format
		$tmzFormat = "yyyy-MM-ddTHH:mm:ssZ"
		$dateStartString = $dateStart.ToString($tmzFormat)

		$dateFilter = "createdDateTime ge $dateStartString"

		return "$dateFilter and $statusFilter and appid eq '89bee1f7-5e6e-4d8a-9f3d-ecd601259da7'" # 89bee1f7-5e6e-4d8a-9f3d-ecd601259da7 -> Office365 Shell WCSS-Client
	}
	#endregion Helper Functions

	# TODO: Log tenant id and name to config and if it is different from the current tenant context error out.
	$entraIDPlan = Get-ZtLicenseInformation -Product EntraID
	$azureEnvironment = (Get-MgContext).Environment

	# Data that may be inserted into configured exports with placeholders
	$configVariables = [PSFramework.Object.PsfHashtable]@{
		AuditQueryString = Get-ZtiAuditQueryString -PastDays $Days
		MaximumSignInLogQueryTime = $MaximumSignInLogQueryTime
	}
	# If they key does not exist, pass through the original key, rather than return nothing
	$configVariables.SetCalculator({
		Write-PSFMessage -Level Warning -Message "Unexpected Export Variable: %$_%. This is likely a bug, please report this here: https://github.com/microsoft/zerotrustassessment/issues"
		"%$_%"
	})

	$exportConfig = Import-PSFPowerShellDataFile -Path "$script:ModuleRoot\assets\export-tenant.config.psd1" -Psd1Mode Safe
	$includedExports = @()
	$applicableExports = foreach ($exportCfg in $exportConfig) {
		if ($Pillar -notcontains 'All' -and $Pillar -notcontains $exportCfg.Pillar) { continue }
		if ($exportCfg.Environment -and $exportCfg.Environment -notcontains $azureEnvironment) { continue }
		if ($exportCfg.IncludePlan -and $entraIDPlan -notin $exportCfg.IncludePlan) { continue }
		if ($exportCfg.ExcludePlan -and $entraIDPlan -in $exportCfg.IncludePlan) { continue }

		if ($exportCfg.DependsOn -and $includedExports -notcontains $exportCfg.DependsOn) {
			# Dependencies must exist, be viable and come first in the order within the config file
			Write-PSFMessage -Level Warning -Message @"
The Export $($exportCfg.Name) would meet requirements but depends on the Export $($exportCfg.DependsOn), which does not.
This is very likely a configuration error in the ZeroTrustAssessment module, please report this on:
https://github.com/microsoft/zerotrustassessment/issues
"@
			continue
		}
		$includedExports += $exportCfg.Name

		# Insert dynamic data as prepared above
		if ($exportCfg.Uri -like "%*%") { $exportCfg.Uri = $configVariables[$exportCfg.Uri.Trim("%")] }
		if ($exportCfg.QueryString -like "%*%") { $exportCfg.QueryString = $configVariables[$exportCfg.QueryString.Trim("%")] }
		if ($exportCfg.MaximumQueryTime -like "%*%") { $exportCfg.MaximumQueryTime = $configVariables[$exportCfg.MaximumQueryTime.Trim("%")] }

		$exportCfg
	}

	try {
		$workflow = Start-ZtTenantDataExport -ExportConfig $applicableExports -ThrottleLimit $ThrottleLimit
		Wait-ZtTenantDataExport -Workflow $workflow
	}
	finally {
		if ($workflow) {
			Disable-PSFConsoleInterrupt
			Export-ZtExportState -Workflow $workflow
			$workflow | Stop-PSFRunspaceWorkflow
			$workflow | Remove-PSFRunspaceWorkflow
		}

		Enable-PSFConsoleInterrupt
	}

	return

	#TODO: Remove after wrapping up the parallelized export

	$userQueryString = '$top=999&$select=deletedDateTime, userType, streetAddress, onPremisesSipInfo, displayName, preferredLanguage, postalCode, faxNumber, onPremisesUserPrincipalName, serviceProvisioningErrors, cloudRealtimeCommunicationInfo, createdDateTime, signInSessionsValidFromDateTime, creationType, city, onPremisesDomainName, onPremisesProvisioningErrors, externalUserStateChangeDateTime, proxyAddresses, imAddresses, refreshTokensValidFromDateTime, onPremisesLastSyncDateTime, passwordPolicies, employeeLeaveDateTime, surname, employeeId, showInAddressList, usageLocation, isManagementRestricted, assignedPlans, authorizationInfo, id, provisionedPlans, userPrincipalName, accountEnabled, passwordProfile, onPremisesObjectIdentifier, state, ageGroup, isLicenseReconciliationNeeded, mobilePhone, employeeHireDate, securityIdentifier, onPremisesSyncEnabled, identities, jobTitle, onPremisesSecurityIdentifier, companyName, legalAgeGroupClassification, otherMails, mailNickname, employeeOrgData, assignedLicenses, employeeType, onPremisesSamAccountName, externalUserState, businessPhones, isResourceAccount, mail, infoCatalogs, deviceKeys, onPremisesImmutableId, externalUserConvertedOn, department, onPremisesExtensionAttributes, givenName, preferredDataLocation, officeLocation, onPremisesDistinguishedName, consentProvidedForMinor, country'
	if ($EntraIDPlan -ne 'Free') {
		# Add premium fields
		$userQueryString += ', signInActivity'
	}
	Export-GraphEntity -ExportPath $ExportPath -EntityName 'User' `
		-EntityUri 'beta/users' -ProgressActivity 'Users' `
		-QueryString $userQueryString -ShowCount

		Export-GraphEntity -ExportPath $ExportPath -EntityName 'Application' `
			-EntityUri 'beta/applications' -ProgressActivity 'Applications' `
			-QueryString '$expand=owners&$top=999' -ShowCount

		Export-GraphEntity -ExportPath $ExportPath -EntityName 'ServicePrincipal' `
			-EntityUri 'beta/servicePrincipals' -ProgressActivity 'Service Principals' `
			-QueryString '$expand=appRoleAssignments&$top=999' -RelatedPropertyNames @('oauth2PermissionGrants') `
			-ShowCount

		if ((Get-MgContext).Environment -eq 'Global') {
			Export-GraphEntity -ExportPath $ExportPath -EntityName 'ServicePrincipalSignIn' `
				-EntityUri 'beta/reports/servicePrincipalSignInActivities' -ProgressActivity 'Service Principal Sign In Activities'
		}

		Export-GraphEntity -ExportPath $ExportPath -EntityName 'RoleDefinition' `
			-EntityUri 'beta/roleManagement/directory/roleDefinitions' -ProgressActivity 'Role Definitions' `

		# Active role assignments
		Export-GraphEntity -ExportPath $ExportPath -EntityName 'RoleAssignment' `
			-EntityUri 'beta/roleManagement/directory/roleAssignments' -ProgressActivity 'Role Assignments' `
			-QueryString "`$expand=principal"

		if ($EntraIDPlan -eq "P2" -or $EntraIDPlan -eq "Governance") {
			# API requires PIM license
			# Filter for permanently assigned/active (ignore PIM eligible users that have temporarily actived)
			Export-GraphEntity -ExportPath $ExportPath -EntityName 'RoleAssignmentScheduleInstance' `
				-EntityUri 'beta/roleManagement/directory/roleAssignmentScheduleInstances' -ProgressActivity 'Role Assignment Instance' `
				-QueryString "`$expand=principal&`$filter = assignmentType eq 'Assigned'"

			# Filter for currently valid, eligible role assignments
			Export-GraphEntity -ExportPath $ExportPath -EntityName 'RoleEligibilityScheduleInstance' `
				-EntityUri 'beta/roleManagement/directory/roleEligibilityScheduleInstances' -ProgressActivity 'Role Eligibility Instance' `
				-QueryString "`$expand=principal"

			# Export role management policy assignments for PIM activation alert configuration
			Export-GraphEntity -ExportPath $ExportPath -EntityName 'RoleManagementPolicyAssignment' `
				-EntityUri 'beta/policies/roleManagementPolicyAssignments' -ProgressActivity 'Role Management Policy Assignments' `
				-QueryString "`$filter=scopeId eq '/' and scopeType eq 'DirectoryRole'"
		}

		if ($EntraIDPlan -ne 'Free') {
			Export-GraphEntity -ExportPath $ExportPath -EntityName 'UserRegistrationDetails' `
				-EntityUri 'beta/reports/authenticationMethods/userRegistrationDetails' -ProgressActivity 'User Registration Details'
		}

		## Download all privileged user details based on roles and role assignments
		Export-GraphEntityPrivilegedGroup -ExportPath $ExportPath -ProgressActivity 'Active Privileged Groups' `
			-InputEntityName 'RoleAssignment' -EntityName 'RoleAssignmentGroup'

		if ($EntraIDPlan -eq "P2" -or $EntraIDPlan -eq "Governance") {
			# Export eligible privileged groups
			Export-GraphEntityPrivilegedGroup -ExportPath $ExportPath -ProgressActivity 'Assigned Privileged Groups' `
				-InputEntityName 'RoleAssignmentScheduleInstance' -EntityName 'RoleAssignmentScheduleInstanceGroup'

			Export-GraphEntityPrivilegedGroup -ExportPath $ExportPath -ProgressActivity 'Eligible Privileged Groups' `
				-InputEntityName 'RoleEligibilityScheduleInstance' -EntityName 'RoleEligibilityScheduleInstanceGroup'
		}

		if ($EntraIDPlan -ne 'Free') {
			Export-GraphEntity -ExportPath $ExportPath -EntityName 'SignIn' `
				-EntityUri 'beta/auditlogs/signins' -ProgressActivity 'Sign In Logs' `
				-QueryString (Get-ZtiAuditQueryString -PastDays $Days) -MaximumQueryTime $MaximumSignInLogQueryTime
		}
	}

	if ($Pillar -in ('All', 'Devices')) {
		Export-GraphEntity -ExportPath $ExportPath -EntityName 'Device' `
			-EntityUri 'beta/devices' -ProgressActivity 'Devices' `
			-QueryString '$top=999' -ShowCount
	}
}
