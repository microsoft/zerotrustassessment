<#
.SYNOPSIS
    Get all applications with permissions, classified by risk level.

.DESCRIPTION
    This function queries ServicePrincipal objects with their associated Application data,
    enriches them with permission details, risk classifications and owner counts.
    Used by tests 21770, 24518, and 21867.
#>

function Get-ApplicationsWithPermissions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Database
    )

    # Query ServicePrincipal objects with permissions (same SQL as Test-21770)
    # LEFT JOIN with Application to get owners and other app properties
    $sql = @"
select sp.id, sp.appId, sp.displayName, sp.appOwnerOrganizationId, sp.publisherName,
spsi.lastSignInActivity.lastSignInDateTime,
app.owners, app.signInAudience, app.publisherDomain
from main.ServicePrincipal sp
    left join main.ServicePrincipalSignIn spsi on spsi.appId = sp.appId
    left join main.Application app on app.appId = sp.appId
where sp.id in
    (
        select sp.id
        from main.ServicePrincipal sp
        where sp.oauth2PermissionGrants.scope is not null
    )
    or sp.id in
    (
        select distinct sp.id,
        from (select sp.id, sp.displayName, unnest(sp.appRoleAssignments).AppRoleId as appRoleId
            from main.ServicePrincipal sp) sp
            left join
                (select unnest(main.ServicePrincipal.appRoles).id as id, unnest(main.ServicePrincipal.appRoles)."value" permissionName
                from main.ServicePrincipal) spAppRole
                on sp.appRoleId = spAppRole.id
        where permissionName is not null
    )
order by spsi.lastSignInActivity.lastSignInDateTime
"@

    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

    Write-PSFMessage "Found $($results.Count) service principals with permissions from database" -Level Verbose

    if (-not $results -or $results.Count -eq 0) {
        return @()
    }

    # Enrich each app with permissions and risk classification (using Test-21770 pattern)
    $enrichedApps = @()

    foreach ($item in $results) {
        try {
            # Add delegate permissions
            $item = Add-DelegatePermissions -item $item -Database $Database

            # Add application permissions
            $item = Add-AppPermissions -item $item -Database $Database

            # Add risk classification
            $item = Add-GraphRisk $item

            # Add owner count from Application.owners field
            $ownerCount = 0
            if ($item.owners) {
                if ($item.owners -is [System.Collections.ICollection]) {
                    $ownerCount = $item.owners.Count
                } else {
                    try {
                        $ownersList = $item.owners | ConvertFrom-Json
                        $ownerCount = $ownersList.Count
                    } catch {
                        $ownerCount = 0
                    }
                }
            }
            $item | Add-Member -MemberType NoteProperty -Name 'OwnerCount' -Value $ownerCount -Force

            $enrichedApps += $item
        }
        catch {
            Write-PSFMessage "Error processing app $($item.displayName): $_" -Level Warning -ErrorRecord $_ -Tag Test
            continue
        }
    }

    Write-PSFMessage "Enriched $($enrichedApps.Count) applications with permissions and risk data" -Level Verbose

    return $enrichedApps
}
