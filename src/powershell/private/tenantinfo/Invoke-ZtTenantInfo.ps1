<#
.SYNOPSIS
    Runs all the cmdlets to gather tenant information.
#>

function Invoke-ZtTenantInfo {
    [CmdletBinding()]
    param (
        # The database to export the tenant information to.
        $Database,

        # The Zero Trust pillar to assess. Defaults to All.
        [ValidateSet('All', 'Identity', 'Devices')]
        [string]
        $Pillar = 'All'
    )

        # Nothing to do if the Pillar is Devices (for now)
    if ($Pillar -eq 'Devices') {
        Write-PSFMessage 'Skipping data export for Devices pillar.'
        return
    }

    Add-ZtOverviewCaMfa -Database $Database
    Add-ZtOverviewCaDevicesAllUsers -Database $Database
    Add-ZtOverviewAuthMethodsAllUsers -Database $Database
    Add-ZtOverviewAuthMethodsPrivilegedUsers -Database $Database
}
