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
        $ExportPath
    )

    # TODO: Log tenant id and name to config and if it is different from the current tenant context error out.

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'Application' `
        -EntityUri 'beta/applications' -ProgressActivity 'Applications' `
        -QueryString '$top=999' -ShowCount

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'ServicePrincipal' `
        -EntityUri 'beta/servicePrincipals' -ProgressActivity 'Service Principals' `
        -QueryString '$expand=appRoleAssignments&$top=999' -RelatedPropertyNames @('oauth2PermissionGrants') `
        -ShowCount

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'ServicePrincipalSignIn' `
        -EntityUri 'beta/reports/servicePrincipalSignInActivities' -ProgressActivity 'Service Principal Sign In Activities'


    #Export-Entra -Path $OutputFolder -Type Config
}
