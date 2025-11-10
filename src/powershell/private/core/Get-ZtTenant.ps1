function Get-ZtTenant {
	<#
	.SYNOPSIS
		Retrieve information about the specified tenant.

	.DESCRIPTION
		Retrieve information about the specified tenant.
		Queries the "tenantRelationships" graph endpoint for the information.

		Defaults to an empty string in case of error.

	.PARAMETER TenantId
		ID of the tenant to lookup.

	.EXAMPLE
		PS C:\> Get-ZtTenant -TenantId $myTenant

		Retrieves the tenant information for $myTenant
	#>
    [CmdletBinding()]
    param(
		[string]
        $TenantId
    )

    try {
        Invoke-ZtGraphRequest -Uri "beta/tenantRelationships/findTenantInformationByTenantId(tenantId='{$($TenantId)}')"
    }
    catch {
        ""
    }
}
