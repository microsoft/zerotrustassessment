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
        $Path
    )

    Export-ServicePrincipals -Path $Path
    #Export-Entra -Path $OutputFolder -Type Config

    # Create database
    # $dbPath = Join-Path $Path "ZeroTrustAssessment.db"
    # $db = New-ZtDbConnection -Path $dbPath
}
