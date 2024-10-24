function Get-ZtTenant {
    [CmdletBinding()]
    param(
        $tenantId
    )

    try {
        $tenant = Invoke-ZtGraphRequest -Uri "beta/tenantRelationships/findTenantInformationByTenantId(tenantId='{$($tenantId)}')"
    }
    catch {
        $tenantId = ""
    }

    return $tenant
}
