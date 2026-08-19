function Get-ZtGraphScope {
	<#
	.SYNOPSIS
		List the Graph scopes needed for the ZeroTrustAssessment.

	.DESCRIPTION
		List the Graph scopes needed for the ZeroTrustAssessment.

	.EXAMPLE
		PS C:\> Get-ZtGraphScope

		List the Graph scopes needed for the ZeroTrustAssessment.
	#>
    [CmdletBinding()]
    param()

    # Any changes made to these permission scopes should be reflected in the documentation.
    # /zerotrustassessment/website/docs/sections/permissions.md

    # Default read-only scopes required for the assessment.
    $scopes = @( #IMPORTANT: Read note above before adding any new scopes.
        'Application.Read.All'
        'AuditLog.Read.All'
        'CopilotPackages.Read.All'
        'CrossTenantInformation.ReadBasic.All'
        'CustomSecAttributeAssignment.Read.All'
        'DeviceManagementApps.Read.All'
        'DeviceManagementConfiguration.Read.All'
        'DeviceManagementManagedDevices.Read.All'
        'DeviceManagementRBAC.Read.All'
        'DeviceManagementServiceConfig.Read.All'
        'Directory.Read.All'
        'DirectoryRecommendations.Read.All'
        'EntitlementManagement.Read.All'
        'IdentityRiskEvent.Read.All'
        'IdentityRiskyServicePrincipal.Read.All'
        'IdentityRiskyUser.Read.All'
        'LifecycleWorkflows-Workflow.Read.All'
        'NetworkAccess.Read.All'
        'Policy.Read.All'
        'Policy.Read.ConditionalAccess'
        'Policy.Read.PermissionGrant'
        'PrivilegedAccess.Read.AzureAD'
        'PrivilegedAssignmentSchedule.Read.AzureADGroup'
        'PrivilegedEligibilitySchedule.Read.AzureADGroup'
        'Reports.Read.All'
        'RoleManagement.Read.All'
        'SecurityAlert.Read.All'
        'SecurityEvents.Read.All'
        'SecurityIdentitiesHealth.Read.All'
        'SecurityIdentitiesSensors.Read.All'
        'SecurityIncident.Read.All'
        'ThreatHunting.Read.All'
        'UserAuthenticationMethod.Read.All'
    )

    $scopes | Sort-Object -Unique
}
