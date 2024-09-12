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

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'Application' `
        -EntityUri 'beta/applications' -ProgressActivity 'Applications' `
        -QueryString '$top=999' -ShowCount

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'ServicePrincipal' `
        -EntityUri 'beta/servicePrincipals' -ProgressActivity 'Service Principals' `
        -QueryString '$expand=appRoleAssignments&$top=999' -RelatedPropertyNames @('oauth2PermissionGrants') `
        -ShowCount

    Export-GraphEntity -ExportPath $ExportPath -EntityName 'ServicePrincipalSignIn' `
        -EntityUri 'beta/reports/servicePrincipalSignInActivities' -ProgressActivity 'Service Principal Sign In Activities'

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
