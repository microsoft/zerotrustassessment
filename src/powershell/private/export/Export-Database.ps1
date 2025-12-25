function Export-Database {
	<#
	.SYNOPSIS
		Creates a database with the data files found in the specified folder.

	.DESCRIPTION
		Creates a database with the data files found in the specified folder.
		Database will be created in the subfolder "db".
		If the folder already exists, it will be deleted before commencing.

	.PARAMETER ExportPath
		The folder in which to look for data and under which to create the database.
		This expects that previously all relevant data has already been exported from the tenant.

	.PARAMETER Pillar
		Which Zero Trust Pillar to process.
		Defaults to "All".

	.EXAMPLE
		PS C:\> Export-Database -ExportPath .

		Creates the database from the exported data found in the current folder.
	#>
	[CmdletBinding()]
	param (
		# The path to the folder where all the files were exported.
		[Parameter(Mandatory = $true)]
		[PSFDirectorySingle]$ExportPath,

		# The Zero Trust pillar to assess. Defaults to All.
		[ValidateSet('All', 'Identity', 'Devices', 'Network', 'Data')]
		[string]
		$Pillar = 'All'
	)

	#region Utility Function
	function Get-RoleSelectSql {
		[CmdletBinding()]
		param (
			[Parameter(Mandatory = $true)]
			[string]
			$TableName,

			[Parameter(Mandatory = $true)]
			[string]
			$PrivilegeType,

			[switch]
			$AddUnion
		)
		$sql = @"

    select
        rd.isPrivileged,
        cast(r."roleDefinitionId" as varchar)           as roleDefinitionId,
        cast(r.principal.displayName as varchar)        as principalDisplayName,
        rd.displayName                                  as roleDisplayName,
        cast(r.principal.userPrincipalName as varchar)  as userPrincipalName,
        cast(r.principal."@odata.type" as varchar)      as "@odata.type",
        cast(r.principalId as varchar)                  as principalId,
        '$PrivilegeType'                                as privilegeType
    from main."$TableName" r
        left join main."RoleDefinition" rd on r."roleDefinitionId" = rd.id

	union all

    select
        rd2.isPrivileged,
        cast(r2."roleDefinitionId" as varchar)           as roleDefinitionId,
        cast(r2.displayName as varchar)        as principalDisplayName,
        rd2.displayName                                  as roleDisplayName,
        cast(r2.userPrincipalName as varchar)  as userPrincipalName,
        cast(r2."@odata.type" as varchar)      as "@odata.type",
        cast(r2.Id as varchar)                  as principalId,
        '$PrivilegeType'                        as privilegeType
    from main."$($TableName)Group" r2
        left join main."RoleDefinition" rd2 on r2."roleDefinitionId" = rd2.id

"@

		if ($AddUnion) {
			$sql += 'union all'
		}

		return $sql
	}

	function New-ViewRole {
		[CmdletBinding()]
		param (
			[Parameter(Mandatory = $true)]
			[DuckDB.NET.Data.DuckDBConnection]
			$Database
		)

		$sql = @"
create view vwRole
as

"@

		$EntraIDPlan = Get-ZtLicenseInformation -Product EntraID

		if ($EntraIDPlan -eq "P2" -or $EntraIDPlan -eq "Governance") {
			# Is P2 tenant, don't read RoleAssignment because it contains PIM Eligible temporary users and has no way to filter it out.
			$sql += Get-RoleSelectSql -TableName 'RoleAssignmentScheduleInstance' -PrivilegeType 'Permanent' -AddUnion
		}
		else {
			# Is Free or P1 tenant so we only have the RoleAssignment table to go on.
			$sql += Get-RoleSelectSql -TableName "RoleAssignment" -PrivilegeType 'Permanent' -AddUnion
		}
		# Now read RoleEligibilityScheduleInstance to get PIM Eligible users
		$sql += Get-RoleSelectSql -TableName "RoleEligibilityScheduleInstance" -PrivilegeType 'Eligible'

		Invoke-DatabaseQuery -Database $Database -Sql $sql -NonQuery
	}
	#endregion Utility Function

	$activity = "Creating database"
	Write-ZtProgress -Activity $activity -Status "Starting"

	Write-PSFMessage "Importing data from $ExportPath" -Tag Import
	$dbFolderName = 'db'
	$dbFolder = Join-Path $ExportPath $dbFolderName
	$dbPath = Join-Path $ExportPath $dbFolderName "zt.db"

	if (Test-Path $dbFolder) {
		Write-PSFMessage "Clearing previous db $dbFolder" -Tag Import
		$database = Connect-Database -Path $dbPath -PassThru
		Invoke-DatabaseQuery -Database $database -Sql "FORCE CHECKPOINT;" -NonQuery
		Disconnect-Database -Database $database
		Remove-Item $dbFolder -Recurse -Force # Remove the existing database
	}
	$null = New-Item -ItemType Directory -Path $dbFolder -Force -ErrorAction Stop

	$database = Connect-Database -Path $dbPath -PassThru

	trap {
		Disconnect-Database -Database $database
		throw $_
	}

	if ($Pillar -in ('All', 'Identity')) {
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'User'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'Application'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'ServicePrincipal'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'ServicePrincipalSignIn'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'SignIn'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'RoleDefinition'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'RoleAssignment'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'RoleAssignmentGroup'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'RoleAssignmentScheduleInstance'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'RoleAssignmentScheduleInstanceGroup'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'RoleEligibilityScheduleInstance'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'RoleEligibilityScheduleInstanceGroup'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'RoleManagementPolicyAssignment'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'UserRegistrationDetails'

		New-ViewRole -Database $database
	}

	if ($Pillar -in ('All', 'Devices')) {
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'Device'
		Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'ConfigurationPolicy'
	}

	$database
}
