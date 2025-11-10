function Get-GraphPermissionRisk {
	<#
	.SYNOPSIS
		Get the risk of a permission in the graph database.

	.DESCRIPTION
		Get the risk of a permission in the graph database.
		The list of scopes / app roles is stored in "assets/aadconsentgrantpermissiontable.csv" and loaded during module import.

	.PARAMETER Permission
		The actual scope / role name, suchas "User.ReadBasic.All" or "Directory.ReadWrite.All".

	.PARAMETER PermissionType
		Whether it is an Application or Delegated role/Scope.

	.EXAMPLE
		PS C:\> Get-GraphPermissionRisk -Permission Application.ReadWrite.All -PermissionType Application

		Returns how risky/sensitive the role "Application.ReadWrite.All" is.
		(Spoiler: Very, very risky)
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]
		$Permission,

		[Parameter(Mandatory)]
		[ValidateSet('Application', 'Delegated')]
		[string]
		$PermissionType
	)

	$permKey = $PermissionType + $Permission
	$permRootKey = $PermissionType + $Permission.Split(".")[0]

	if ($Script:_GraphPermissions[$permKey]) {
		return $Script:_GraphPermissions[$permKey]
	}

	$permsHash = $script:_GraphPermissionsHash # Loaded during module import in variables.ps1

	$risk = "Unranked"
	# Search for matching root level permission if there was no exact match
	if ($permsHash[$permKey]) {
		# Exact match e.g. Application.Read.All
		$risk = $permsHash[$permKey].Privilege
	}
	elseif ($permsHash[$permRootKey]) {
		# Matches top level e.g. Application.
		$risk = $permsHash[$permRootKey].Privilege
	}
	elseif ($type -eq "Application") {
		# Application permissions without exact or root matches with write scope
		$risk = "Medium"
		if ($scope -like "*Write*") {
			$risk = "High"
		}
	}
	$Script:_GraphPermissions[$permKey] = $risk
	$Script:_GraphPermissions[$permKey]
}
