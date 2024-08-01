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

    Export-GraphEntity -ExportPath $ExportPath `
        -EntityUri 'beta/applications' -ProgressActivity 'Applications' `
        -QueryString '$top=999' -EntityName 'Applications'

    Export-GraphEntity -ExportPath $ExportPath `
        -EntityUri 'beta/servicePrincipals' -ProgressActivity 'Service Principals' `
        -QueryString '$expand=appRoleAssignments&$top=999' -EntityName 'ServicePrincipals' `
        -RelatedPropertyNames @('oauth2PermissionGrants')


    #Export-Entra -Path $OutputFolder -Type Config

    # Create database
    # $dbPath = Join-Path $Path "ZeroTrustAssessment.db"
    # $db = New-ZtDbConnection -Path $dbPath
}
