<#
@{
	# Universal Parameters (must always specify)
	Name = '' # Name of Export (and Export Folder)

	# Export-Specific Parameters
	# InputName = '' # Name of other Export needed. For Type "PrivilegedGroup"
	Uri = '' # Relative Uri to query
	QueryString = '' # Any Query string to send along
	RelatedPropertyNames = @() # Sub-API Endpoints to include as an extra request
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%' # Limit the execution time to this duration. This is designed to prevent eternal paging in large tenants

	# General Parameters for the system itself
	Type = 'Default' # PrivilegedGroup # What kind of data export this is
	Pillar = 'Identity' # The Pillar this export is used for
	# Environment = $null # 'Global' # Some exports may only be available in specific azure types
	# IncludePlan = @() # P2, Governance # Only run for Tenants with this EntraID Plan
	# ExcludePlan = @() # Free # Do NOT run for Tenants with this EntraID Plan
	# DependsOn = 'NameOfOtherExportCfg' # Only run this after a specific other export has concluded.
	                                     # WARNING: This will block a worker. Exports with a dependency should always be last in the configuration file
										 # Any export configuration with a DependsOn MUST be placed below that dependency, otherwise it will be skipped during export.
										 # Any export configuration with a DependsOn should have the same environment / plan requirements, as otherwise scenarios exist, where they would be in scope but cannot be executed.

	# Note on Variable inserts:
	# Some Properties support inserting configuration variables: %NameOfVariable%
	# This is supported on: Uri, QueryString, MaximumQueryTime
	# To look up available variables, see "Export-ZtTenantData.ps1"
}
#>
<#
Working with the Export System:

A few actions you may conceivably want to adjust:

+ Add more values you can insert into placeholders defined in the config file
+ Add more properties you can insert placeholder values into
+ Add more custom export commands
+ Extend the existing export commands and add new settings to the config file

> Placeholders and Properties

There are two parts to extending the dynamic value insertion:

+ Calculating the values to offer for insertion
+ Executing the value insertion into the properties

Both happen within 'Export-ZtTenantData' itself, so go there to look things up and insert them.
The values to insert are collected first into "$configVariables". Add new data to offer here.
Later, during processing each '$exportCfg', the values are inserted. If you want to make more config settings insertible, add those here.

> New Export Commands

Which export command is used is determined by the "Type" config settings.
This maps to the switch-statement in 'Invoke-ZtTenantDataExport'.
To add support for a new type and new export command, just add the new export command and include it in this switch statement.

All parameters on the export command are directly mapped to configuration entries.
This also means, that you should avoid using a parameter on your export command that conflicts with any of the General parameters used to control execution.

> Adding new configuration settings / parameters for Export Commands

The type property in each export setting determine which export command is selected for it.
This is implemented in a switch statement in 'Invoke-ZtTenantDataExport'.

Parameters on the export command are automatically mapped to the setting-names in this config file.
To add one more setting:

+ Add the parameter to the export command - e.g.: Export-GraphEntity (and implement what the command is supposed to do with it)
+ Add settings with the same name to this config file.

The mapping happens automagically, no further step is needed.
Note: Avoid using the same names as used for the "General Parameters" section of settings.
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
	Name = 'RoleAssignmentScheduleInstance'
	Uri = 'beta/roleManagement/directory/roleAssignmentScheduleInstances'
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
	Name = 'RoleEligibilityScheduleInstance'
	Uri = 'beta/roleManagement/directory/roleEligibilityScheduleInstances'
	QueryString = "`$expand=principal"
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
	Name = 'RoleEligibilityScheduleInstanceGroup'
	InputName = 'RoleEligibilityScheduleInstance'
	Type = 'PrivilegedGroup' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	IncludePlan = @('P2', 'Governance') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
	DependsOn = 'RoleEligibilityScheduleInstance'
}

@{
	Name = 'RoleAssignmentScheduleInstanceGroup'
	InputName = 'RoleAssignmentScheduleInstance'
	Type = 'PrivilegedGroup' # PrivilegedGroup

	Pillar = 'Identity'
	# Environment = 'Global' # 'Global'
	IncludePlan = @('P2', 'Governance') # P2, Governance
	# ExcludePlan = @('Free') # Free
	# MaximumQueryTime = '%MaximumSignInLogQueryTime%'
	DependsOn = 'RoleAssignmentScheduleInstance'
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
@{
	Name = 'ConfigurationPolicy'
	Uri = 'beta/deviceManagement/configurationPolicies'
	QueryString = '$expand=assignments,settings'
	RelatedPropertyNames = @()
	Type = 'Default'

	Pillar = 'Devices'
}
