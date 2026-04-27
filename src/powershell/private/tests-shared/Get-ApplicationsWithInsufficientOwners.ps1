<#
.SYNOPSIS
    Get applications with insufficient owners based on privilege level.

.DESCRIPTION
    Filters applications from Get-ApplicationsWithPermissions based on owner count and privilege level.
    Used by tests 24518 and 21867.
#>

function Get-ApplicationsWithInsufficientOwners {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateSet('High', 'Medium', 'Low', 'Unranked')]
        [string[]]$PrivilegeLevel
    )

    # Get apps with permissions, pre-filtered to Application type only to avoid enriching non-ownable types (e.g. Managed Identities)
    $allApps = Get-ApplicationsWithPermissions -Database $Database -ServicePrincipalType 'Application'

    # Filter the retrieved applications by privilege level and owner count
    $filteredApps = $allApps | Where-Object {
        ($PrivilegeLevel -contains $_.Risk) -and ($_.OwnerCount -lt 2)
    }

    Write-PSFMessage "Filtered to $($filteredApps.Count) applications with < 2 owners matching privilege levels: $($PrivilegeLevel -join ', ')" -Level Verbose

    return $filteredApps
}
