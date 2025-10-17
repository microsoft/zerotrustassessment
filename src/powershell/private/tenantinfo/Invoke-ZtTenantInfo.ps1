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

    # Only run if Pillar is All or Identity
    if ($Pillar -in ('All','Identity')) {
        Add-ZtOverviewCaMfa -Database $Database
        Add-ZtOverviewCaDevicesAllUsers -Database $Database
        Add-ZtOverviewAuthMethodsAllUsers -Database $Database
        Add-ZtOverviewAuthMethodsPrivilegedUsers -Database $Database
    }

    if ($Pillar -in ('All','Devices')) {
        Add-ZtDeviceOverview -Database $Database
        Add-ZtDeviceWindowsEnrollment
        Add-ZtDeviceEnrollmentRestriction
        Add-ZTDeviceCompliancePolicies
        Add-ZTDeviceAppProtectionPolicies
    }
}
