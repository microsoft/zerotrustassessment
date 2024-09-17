function Get-ZtTenant {
    [CmdletBinding()]
    param(
        $tenantId
    )

    try {
        $tenant = Invoke-GraphRequest -Uri "beta/tenantRelationships/findTenantInformationByTenantId(tenantId='{$($tenantId)}')"
    }
    catch {
        $tenantId = ""
    }

    return $tenant
}
