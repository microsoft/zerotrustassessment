function Get-ZtTenant {
    [CmdletBinding()]
    param(
        $tenantId
    )

    $tenant = Invoke-GraphRequest -Uri "beta/tenantRelationships/findTenantInformationByTenantId(tenantId='{$($tenantId)}')"

    return $tenant
}
