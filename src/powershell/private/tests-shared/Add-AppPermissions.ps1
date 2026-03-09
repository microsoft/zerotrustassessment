function Add-AppPermissions {
    [CmdletBinding()]
    param (
        $item,
        $Database
    )
    $sql = @"
    select distinct spAppRole.*
    from (select sp.id, sp.displayName, unnest(sp.appRoleAssignments).AppRoleId as appRoleId
        from main.ServicePrincipal sp) sp
        left join
            (select unnest(main.ServicePrincipal.appRoles).id as id, unnest(main.ServicePrincipal.appRoles)."value" permissionName
            from main.ServicePrincipal) spAppRole
            on sp.appRoleId = spAppRole.id
    where permissionName is not null and sp.id == '{0}'
"@
    $sql = $sql -f $item.id
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    $item.AppPermissions = $results.permissionName
    return $item
}
