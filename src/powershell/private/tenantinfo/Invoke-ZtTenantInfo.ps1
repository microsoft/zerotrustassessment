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
        [ValidateSet('All', 'Identity', 'Devices', 'Network', 'Data', 'Infrastructure', 'SecOps', 'AI')]
        [string]
        $Pillar = 'All'
    )

    Add-ZtTenantOverview # Always run (shown on dashboard)
    Add-ZtAgentOverview # Always run (shown on dashboard)

    if ($Pillar -in ('All', 'AI')) {
        Add-ZtAgentOwnershipDistribution -Database $Database
    }

    # Only run if Pillar is All or Identity
    if ($Pillar -in ('All', 'Identity')) {
        Add-ZtOverviewCaMfa -Database $Database
        Add-ZtOverviewCaDevicesAllUsers -Database $Database
        Add-ZtOverviewAuthMethodsAllUsers -Database $Database
        Add-ZtOverviewAuthMethodsPrivilegedUsers -Database $Database
    }

    if ($Pillar -in ('All', 'Network')) {
        Add-ZtOverviewPrivateAccess
    }

    if ($Pillar -in ('All', 'Devices')) {
        $IntunePlan = Get-ZtLicenseInformation -Product Intune
        Add-ZtDeviceOverview -Database $Database

        if ($null -ne $IntunePlan) {
            Add-ZtDeviceWindowsEnrollment
            Add-ZtDeviceEnrollmentRestriction
            Add-ZTDeviceCompliancePolicies
            Add-ZTDeviceAppProtectionPolicies
        }
    }

    if ($Pillar -in ('All', 'Network')) {
        Add-ZtOverviewM365ProtectionCircuit
    }

    if ($Pillar -in ('All', 'Data')) {
        Add-ZtDlpWorkloadCoverage
    }
}
