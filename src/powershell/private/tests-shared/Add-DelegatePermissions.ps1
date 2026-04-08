function Add-DelegatePermissions {
    [CmdletBinding()]
    param (
        $item,
        $Database
    )
    $sql = @"
    select delegatePermissions.id, delegatePermissions.permissionScope as permissionName
    from (
        select sp.id,
            unnest(sp.oauth2PermissionGrants).scope as permissionScope
        from main.ServicePrincipal sp
    ) delegatePermissions
    where delegatePermissions.permissionScope is not null
        and delegatePermissions.id == '{0}'
"@
    $sql = $sql -f $item.id
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    $item.DelegatePermissions = @()
    if ($results.permissionName) {
        $perms = $results.permissionName.Trim() -replace '"', ''
        $item.DelegatePermissions = $perms -split ' ' | Where-Object { ![string]::IsNullOrEmpty($_) }
    }
    return $item
}
