<#
.SYNOPSIS
Connects to the tenant and downloads the data to a local folder.

.DESCRIPTION
This function connects to the tenant and downloads the data to a local folder.

.PARAMETER OutputFolder
The folder to output the report to. If not specified, the report will be output to the current directory.
#>

function Export-TenantData {
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
        $MaximumSignInLogQueryTime
    )

    # TODO: Log tenant id and name to config and if it is different from the current tenant context error out.
    $EntraIDPlan = Get-ZtLicenseInformation -Product EntraID

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'User' `
        -EntityUri 'beta/users' -ProgressActivity 'Users' `
        -QueryString '$top=999&$select=signInActivity, deletedDateTime, userType, streetAddress, onPremisesSipInfo, displayName, preferredLanguage, postalCode, faxNumber, onPremisesUserPrincipalName, serviceProvisioningErrors, cloudRealtimeCommunicationInfo, createdDateTime, signInSessionsValidFromDateTime, creationType, city, onPremisesDomainName, onPremisesProvisioningErrors, externalUserStateChangeDateTime, proxyAddresses, imAddresses, refreshTokensValidFromDateTime, onPremisesLastSyncDateTime, passwordPolicies, employeeLeaveDateTime, surname, employeeId, showInAddressList, usageLocation, isManagementRestricted, assignedPlans, authorizationInfo, id, provisionedPlans, userPrincipalName, accountEnabled, passwordProfile, onPremisesObjectIdentifier, state, ageGroup, isLicenseReconciliationNeeded, mobilePhone, employeeHireDate, securityIdentifier, onPremisesSyncEnabled, identities, jobTitle, onPremisesSecurityIdentifier, companyName, legalAgeGroupClassification, otherMails, mailNickname, employeeOrgData, assignedLicenses, employeeType, onPremisesSamAccountName, externalUserState, businessPhones, isResourceAccount, mail, infoCatalogs, deviceKeys, onPremisesImmutableId, externalUserConvertedOn, department, onPremisesExtensionAttributes, givenName, preferredDataLocation, officeLocation, onPremisesDistinguishedName, consentProvidedForMinor, country' -ShowCount

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'Application' `
        -EntityUri 'beta/applications' -ProgressActivity 'Applications' `
        -QueryString '$top=999' -ShowCount

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'ServicePrincipal' `
        -EntityUri 'beta/servicePrincipals' -ProgressActivity 'Service Principals' `
        -QueryString '$expand=appRoleAssignments&$top=999' -RelatedPropertyNames @('oauth2PermissionGrants') `
        -ShowCount

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'ServicePrincipalSignIn' `
        -EntityUri 'beta/reports/servicePrincipalSignInActivities' -ProgressActivity 'Service Principal Sign In Activities'

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'RoleDefinition' `
        -EntityUri 'beta/roleManagement/directory/roleDefinitions' -ProgressActivity 'Role Definitions' `

    # Active role assignments
    Export-GraphEntity -ExportPath $ExportPath -EntityName 'RoleAssignment' `
        -EntityUri 'beta/roleManagement/directory/roleAssignments' -ProgressActivity 'Role Assignments' `
        -QueryString "`$expand=principal"

    if ($EntraIDPlan -eq "P2" -or $EntraIDPlan -eq "Governance") {
        # API requires PIM license
        # Filter for currently valid, eligible role assignments
        Export-GraphEntity -ExportPath $ExportPath -EntityName 'RoleEligibilityScheduleRequest' `
            -EntityUri 'beta/roleManagement/directory/roleEligibilityScheduleRequests' -ProgressActivity 'Role Eligibility' `
            -QueryString "`$expand=principal&`$filter = NOT(status eq 'Canceled' or status eq 'Denied' or status eq 'Failed' or status eq 'Revoked')"

        # Export role management policy assignments for PIM activation alert configuration
        Export-GraphEntity -ExportPath $ExportPath -EntityName 'RoleManagementPolicyAssignment' `
            -EntityUri 'beta/policies/roleManagementPolicyAssignments' -ProgressActivity 'Role Management Policy Assignments' `
            -QueryString "`$filter=scopeId eq '/' and scopeType eq 'DirectoryRole'"
    }

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'UserRegistrationDetails' `
        -EntityUri 'beta/reports/authenticationMethods/userRegistrationDetails' -ProgressActivity 'User Registration Details'

    ## Download all privileged user details based on roles and role assignments
    Export-GraphEntityPrivilegedGroup -ExportPath $ExportPath -ProgressActivity 'Active Privileged Groups' `
        -InputEntityName 'RoleAssignment' -EntityName 'RoleAssignmentGroup'
    Export-GraphEntityPrivilegedGroup -ExportPath $ExportPath -ProgressActivity 'Eligible Privileged Groups' `
        -InputEntityName 'RoleEligibilityScheduleRequest' -EntityName 'RoleEligibilityScheduleRequestGroup'

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'SignIn' `
        -EntityUri 'beta/auditlogs/signins' -ProgressActivity 'Sign In Logs' `
        -QueryString (Get-AuditQueryString $Days) -MaximumQueryTime $MaximumSignInLogQueryTime

    #Export-Entra -Path $OutputFolder -Type Config
}

function Get-AuditQueryString($pastDays) {

    # Get the date range to query by subtracting the number of days from today set to midnight
    $dateFilter = $null
    $statusFilter = "status/errorcode eq 0"

    $dateStart = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-$pastDays)

    # convert the date to the correct format
    $tmzFormat = "yyyy-MM-ddTHH:mm:ssZ"
    $dateStartString = $dateStart.ToString($tmzFormat)

    $dateFilter = "createdDateTime ge $dateStartString"

    return "$dateFilter and $statusFilter and appid eq '89bee1f7-5e6e-4d8a-9f3d-ecd601259da7'"
}
