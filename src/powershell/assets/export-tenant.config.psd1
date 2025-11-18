<#
@{
	Name = '' # Name of Export (and Export Folder)
	# InputName = '' # Name of other Export needed. For Type "PrivilegedGroup"
	Uri = '' # Relative Uri to query
	QueryString = '' # Any Query string to send along
	RelatedPropertyNames = @() # Sub-API Endpoints to include as an extra request
	Type = 'Default' # PrivilegedGroup # What kind of data export this is
	Pillar = 'Identity' # The Pillar this export is used for

	# Environment = $null # 'Global' # Some exports may only be available in specific azure types
	# IncludePlan = @() # P2, Governance # Only run for Tenants with this EntraID Plan
	# ExcludePlan = @() # Free # Do NOT run for Tenants with this EntraID Plan
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%' # Limit the execution time to this duration. This is designed to prevent eternal paging in large tenants
	# DependsOn = 'NameOfOtherExportCfg' # Only run this after a specific other export has concluded.
	                                     # WARNING: This will block a worker. Exports with a dependency should always be last in the configuration file
										 # Any export configuration with a DependsOn MUST be placed below that dependency, otherwise it will be skipped during export.
										 # Any export configuration with a DependsOn should have the same environment / plan requirements, as otherwise scenarios exist, where they would be in scope but cannot be executed.

	# Note on Variable inserts:
	# Some Properties support inserting configuration variables: %NameOfVariable%
	# This is supported on: Uri, QueryString, MaximumQueryTime
	# To look up available variables, see "Export-TenantData.ps1"
}
#>
@{
	Name = 'Application'
	Uri = 'beta/applications'
	QueryString = '$top=999'
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = $null # 'Global'
	# IncludePlan = @('Free') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'ServicePrincipal'
	Uri = 'beta/servicePrincipals'
	QueryString = '$expand=appRoleAssignments&$top=999'
	RelatedPropertyNames = @('oauth2PermissionGrants')
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = $null # 'Global'
	# IncludePlan = @('Free') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'SignIn'
	Uri = 'beta/auditlogs/signins'
	QueryString = '%AuditQueryString%'
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	# IncludePlan = @('P2', 'Governance') # P2, Governance
	ExcludePlan = @('Free') # Free
	MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'User'
	Uri = 'beta/users'
	QueryString = '$top=999&$select=deletedDateTime, userType, streetAddress, onPremisesSipInfo, displayName, preferredLanguage, postalCode, faxNumber, onPremisesUserPrincipalName, serviceProvisioningErrors, cloudRealtimeCommunicationInfo, createdDateTime, signInSessionsValidFromDateTime, creationType, city, onPremisesDomainName, onPremisesProvisioningErrors, externalUserStateChangeDateTime, proxyAddresses, imAddresses, refreshTokensValidFromDateTime, onPremisesLastSyncDateTime, passwordPolicies, employeeLeaveDateTime, surname, employeeId, showInAddressList, usageLocation, isManagementRestricted, assignedPlans, authorizationInfo, id, provisionedPlans, userPrincipalName, accountEnabled, passwordProfile, onPremisesObjectIdentifier, state, ageGroup, isLicenseReconciliationNeeded, mobilePhone, employeeHireDate, securityIdentifier, onPremisesSyncEnabled, identities, jobTitle, onPremisesSecurityIdentifier, companyName, legalAgeGroupClassification, otherMails, mailNickname, employeeOrgData, assignedLicenses, employeeType, onPremisesSamAccountName, externalUserState, businessPhones, isResourceAccount, mail, infoCatalogs, deviceKeys, onPremisesImmutableId, externalUserConvertedOn, department, onPremisesExtensionAttributes, givenName, preferredDataLocation, officeLocation, onPremisesDistinguishedName, consentProvidedForMinor, country, signInActivity'
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = $null # 'Global'
	# IncludePlan = @() # P2, Governance
	ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'User'
	Uri = 'beta/users'
	QueryString = '$top=999&$select=deletedDateTime, userType, streetAddress, onPremisesSipInfo, displayName, preferredLanguage, postalCode, faxNumber, onPremisesUserPrincipalName, serviceProvisioningErrors, cloudRealtimeCommunicationInfo, createdDateTime, signInSessionsValidFromDateTime, creationType, city, onPremisesDomainName, onPremisesProvisioningErrors, externalUserStateChangeDateTime, proxyAddresses, imAddresses, refreshTokensValidFromDateTime, onPremisesLastSyncDateTime, passwordPolicies, employeeLeaveDateTime, surname, employeeId, showInAddressList, usageLocation, isManagementRestricted, assignedPlans, authorizationInfo, id, provisionedPlans, userPrincipalName, accountEnabled, passwordProfile, onPremisesObjectIdentifier, state, ageGroup, isLicenseReconciliationNeeded, mobilePhone, employeeHireDate, securityIdentifier, onPremisesSyncEnabled, identities, jobTitle, onPremisesSecurityIdentifier, companyName, legalAgeGroupClassification, otherMails, mailNickname, employeeOrgData, assignedLicenses, employeeType, onPremisesSamAccountName, externalUserState, businessPhones, isResourceAccount, mail, infoCatalogs, deviceKeys, onPremisesImmutableId, externalUserConvertedOn, department, onPremisesExtensionAttributes, givenName, preferredDataLocation, officeLocation, onPremisesDistinguishedName, consentProvidedForMinor, country'
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = $null # 'Global'
	IncludePlan = @('Free') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'ServicePrincipalSignIn'
	Uri = 'beta/reports/servicePrincipalSignInActivities'
	QueryString = ''
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	Environment = 'Global' # 'Global'
	# IncludePlan = @('Free') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'RoleDefinition'
	Uri = 'beta/roleManagement/directory/roleDefinitions'
	QueryString = ''
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	# IncludePlan = @('Free') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'RoleAssignment'
	Uri = 'beta/roleManagement/directory/roleAssignments'
	QueryString = '$expand=principal'
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	# IncludePlan = @('Free') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'RoleAssignmentSchedule'
	Uri = 'beta/roleManagement/directory/roleAssignmentSchedules'
	QueryString = '$expand=principal&$filter = assignmentType eq ''Assigned'''
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	IncludePlan = @('P2', 'Governance') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'RoleEligibilityScheduleRequest'
	Uri = 'beta/roleManagement/directory/roleEligibilityScheduleRequests'
	QueryString = "`$expand=principal&`$filter = NOT(status eq 'Canceled' or status eq 'Denied' or status eq 'Failed' or status eq 'Revoked')"
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	IncludePlan = @('P2', 'Governance') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'RoleManagementPolicyAssignment'
	Uri = 'beta/policies/roleManagementPolicyAssignments'
	QueryString = "`$filter=scopeId eq '/' and scopeType eq 'DirectoryRole'"
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	IncludePlan = @('P2', 'Governance') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
@{
	Name = 'UserRegistrationDetails'
	Uri = 'beta/reports/authenticationMethods/userRegistrationDetails'
	QueryString = ''
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	# IncludePlan = @('P2', 'Governance') # P2, Governance
	ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}

<#
PrivilegedGroup types should always be last.
They will block their worker until their dependency is completed and could risk starving the export otherwise.
#>
@{
	Name = 'RoleAssignmentGroup'
	InputName = 'RoleAssignment'
	Type = 'PrivilegedGroup' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	# IncludePlan = @('P2', 'Governance') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
	DependsOn = 'RoleAssignment'
}
@{
	Name = 'RoleEligibilityScheduleRequestGroup'
	InputName = 'RoleEligibilityScheduleRequest'
	Type = 'PrivilegedGroup' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	IncludePlan = @('P2', 'Governance') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
	DependsOn = 'RoleEligibilityScheduleRequest'
}

@{
	Name = 'Device'
	Uri = 'beta/devices'
	QueryString = '$top=999'
	RelatedPropertyNames = @()
	Type = 'Default' # PrivilegedGroup

	Pillar = 'Devices'
	# Environment = $null # 'Global'
	# IncludePlan = @('Free') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
}
