function Get-ZtTenantName {
    [CmdletBinding()]
    param(
        $tenantId
    )

    $tenant = Get-ZtTenant -tenantId $tenantId
    if ($tenant -and $tenant.displayName) {
        $tenant = $tenant.displayName
    }
    else {
        $tenant = $tenantId
    }

    return $tenant
}
