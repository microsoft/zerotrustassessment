<#
 .Synopsis
    Returns the list of Graph scopes required to run the Zero Trust Assessment.

 .Description
    Use this cmdlet to connect to Microsoft Graph using Connect-MgGraph.

 .Example
    Connect-MgGraph -Scopes (Get-ZtGraphScope)

    Connects to Microsoft Graph with the required scopes to run Zero Trust Assessment.
#>

Function Get-ZtGraphScope {

    [CmdletBinding()]
    param()

    # Any changes made to these permission scopes should be reflected in the documentation.
    # /zerotrustassessment/website/docs/sections/permissions.md

    # Default read-only scopes required for the assessment.
    $scopes = @( #IMPORTANT: Read note above before adding any new scopes.
        'AuditLog.Read.All'
        'Directory.Read.All'
        'Policy.Read.All'
        'Reports.Read.All'
        'DirectoryRecommendations.Read.All'
        'PrivilegedAccess.Read.AzureAD'
        'IdentityRiskEvent.Read.All'
        'RoleEligibilitySchedule.Read.Directory'
        'RoleManagement.Read.All'
        'RoleEligibilitySchedule.ReadWrite.Directory'
        'Policy.Read.ConditionalAccess'
        'UserAuthenticationMethod.Read.All'
        'CrossTenantInformation.ReadBasic.All'
    )

    #$scopes += Get-EERequiredScopes -PermissionType Delegated

    return $scopes | Sort-Object -Unique
}
