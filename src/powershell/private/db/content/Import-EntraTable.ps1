function Import-EntraTable {
	<#
	.SYNOPSIS
		Imports json data exported from entra into the database.

	.DESCRIPTION
		Imports json data exported from entra into the database.
		Ensures the model-data file is also correctly deployed and not included in the db.

	.PARAMETER Database
		The database to execute against.
		Defaults to the module-managed connection if present.

	.PARAMETER ExportPath
		The path where to find the exported data and where to push the model files.

	.PARAMETER TableName
		The name of the table to fill.

	.EXAMPLE
		PS C:\> Import-EntraTable -Database $database -ExportPath $ExportPath -TableName 'User'

		Creates the table "User" and converts the raw export files of all users of the tenant into the content of that table.
	#>
	[CmdletBinding()]
	param (
		[DuckDB.NET.Data.DuckDBConnection]
		$Database,

		[PSFDirectorySingle]
		$ExportPath,

		[string]
		$TableName
	)

	$dbParam = $PSBoundParameters | ConvertTo-PSFHashtable -Include Database

	Write-PSFMessage "Importing table $TableName" -Tag Import
	$folderPath = Join-Path -Path $ExportPath -ChildPath $TableName

	# Copy the model file if it exists (needed to create table schema to avoid sql errors when there is no data)
	$modelFilePath = Join-Path -Path $script:ModuleRoot -ChildPath "assets/export-model/$TableName-model.json"

	$hasModelRow = $false
	if (Test-Path $modelFilePath) {
		# Ensure the folder exists
		if (-not (Test-Path $folderPath)) {
			$null = New-Item -ItemType Directory -Path $folderPath -Force -ErrorAction Stop
		}
		Copy-Item -Path $modelFilePath -Destination $folderPath -Force
		$hasModelRow = $true
	}

	$filePath = Join-Path $folderPath "$TableName*.json"

	New-EntraTable -Database $Database -TableName $TableName -FilePath $filePath

	if ($hasModelRow) {
		# Let's delete the model row to keep the data clean.
		$deleteModelRow = "DELETE FROM main.$TableName WHERE isZtModelRow = true;"
		Invoke-DatabaseQuery @dbParam -Sql $deleteModelRow -NonQuery
	}
}
