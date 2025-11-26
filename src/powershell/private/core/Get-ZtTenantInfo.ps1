function Get-ZtTenantInfo {
	<#
	.SYNOPSIS
		Return the cached tenant information.

	.DESCRIPTION
		Return the cached tenant information.

	.PARAMETER Name
		Name of the tenant info to return.

	.EXAMPLE
		PS C:\> Get-ZtTenantInfo

		Return all cached tenant-related information
	#>
	[OutputType([hashtable])]
	[CmdletBinding()]
	param (
		[string]
		$Name
	)
	process {
		if ($Name) { return $script:__ZtSession.TenantInfo.Value[$Name] }
		$result = @{}
		foreach ($key in $script:__ZtSession.TenantInfo.Value.Keys) {
			$result[$key] = $script:__ZtSession.TenantInfo.Value[$key]
		}
		$result
	}
}
