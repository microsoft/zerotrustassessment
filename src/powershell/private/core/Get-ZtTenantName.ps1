function Get-ZtTenantName {
	<#
	.SYNOPSIS
		Try and resolve the displayname of the specified tenant.

	.DESCRIPTION
		Try and resolve the displayname of the specified tenant.
		Will return the ID if doing so fails.

	.PARAMETER TenantId
		The ID of the tenant to get the name for

	.EXAMPLE
		PS C:\> Get-ZtTenantName -TenantId $myTenant

		Retrieves the displayname of the tenant in $myTenant
	#>
    [CmdletBinding()]
    param(
        $TenantId
    )

    $tenant = Get-ZtTenant -TenantId $TenantId
    if ($tenant -and $tenant.displayName) {
        return $tenant.displayName
    }
	# Fall back to the ID
    $TenantId
}
