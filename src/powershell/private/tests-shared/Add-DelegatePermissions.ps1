function Add-DelegatePermissions {
    [CmdletBinding()]
    param (
        $item,
        $Database
    )
    $sql = @"
    select sp.id, sp.oauth2PermissionGrants.scope as permissionName,
    from main.ServicePrincipal sp
    where sp.oauth2PermissionGrants.scope is not null
    and sp.id == '{0}'
"@
    $sql = $sql -f $item.id
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    $item.DelegatePermissions = @()
    if ($results.permissionName) {
        $perms = $results.permissionName.trim() -replace '"', ''
        $item.DelegatePermissions = $perms -split ' ' | Where-Object { ![string]::IsNullOrEmpty($_) }
    }
    return $item
}