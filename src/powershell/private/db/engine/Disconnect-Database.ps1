function Disconnect-Database {
	<#
	.SYNOPSIS
		Closes the connection to the database and flushes the file.

	.DESCRIPTION
		Closes the connection to the database and flushes the file.

		By default, it will close the module-managed database connection, unless otherwise specified.
		Will silently complete, if no connection exists.

	.PARAMETER Database
		The database connection to close, instead of the default, module-managed one.

	.EXAMPLE
		PS C:\> Disconnect-Database

		Closes the connection managed by the module.

	.EXAMPLE
		PS C:\> Disconnect-Database -Database $db

		Closes the connection specified.
	#>
	[CmdletBinding()]
	param (
		[DuckDB.NET.Data.DuckDBConnection]
		$Database
	)

	if ($Database) {
		if ($Database.State -eq 'Open') {
			$Database.Close()
		}
		$Database.Dispose()
	}
	elseif ($script:_DatabaseConnection) {
		if ($script:_DatabaseConnection.State -eq 'Open') {
			$script:_DatabaseConnection.Close()
		}
		$script:_DatabaseConnection.Dispose()
		$script:_DatabaseConnection = $null
	}
}
