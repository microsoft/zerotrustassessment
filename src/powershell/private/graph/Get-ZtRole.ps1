function Get-ZtRole {
	<#
	.Synopsis
		Returns all the role definitions in the tenant.

	.Description
		Returns all the role definitions in the tenant.

	.Parameter CisaHighlyPrivilegedRoles
		Filters the returned roles to only those described
		by CISA as highly privieleged.

	.Example
		PS C:\> Get-ZtRole

		List all role definitions in the tenant
	#>
	[CmdletBinding()]
	param(
		[switch]$CisaHighlyPrivilegedRoles,
		[switch]$IncludePrivilegedRoles
	)

	#https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#highly-privileged-roles
	$highlyPrivilegedRoles = @(
		"62e90394-69f5-4237-9190-012177145e10"
		"fe930be7-5e62-47db-91af-98c3a49a38b1"
		"29232cdf-9323-42fd-ade2-1d097af3e4de"
		"f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
		"9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3"
		"e8611ab8-c189-46e8-94e1-60213ab1f814"
		"158c047a-c907-4556-b7ef-446551a6b5f7"
		"8ac3fc64-6eca-42ea-9e69-59f4c7b60eb2"
	)

	Write-PSFMessage -Message "Getting directory role definitions."

	$roles = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleDefinitions' -ApiVersion beta

	if ($CisaHighlyPrivilegedRoles) {
		return $roles | Where-Object id -in $highlyPrivilegedRoles
	}
	elseif ($IncludePrivilegedRoles) {
		return $roles | Where-Object { $_.isPrivileged -eq $true }
	}
	return $roles
}
