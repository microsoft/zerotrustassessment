function Connect-Database {
	<#
	.SYNOPSIS
		Creates a new database connection at the specified path.

	.DESCRIPTION
		Creates a new database connection at the specified path.
		By default, the connection will be maintained within the module scope.
		If there already is an existing, maintained connection, that connection will be closed,
		unless the new connection is created as a transient connection.

		Will fail if the prerequisites - C++ Redistributable - are missing.

	.PARAMETER Path
		The path where the data being wrapped into the datrabase is at.
		Defaults to ":memory:"

	.PARAMETER PassThru
		Return the database connection object.
		Without that, the database connection will only be retained in the module context.
		Redundant when using "-Transient"

	.PARAMETER Transient
		The connection will be established and returned, but NOT written to the module scope.
		Useful for temporary connections that do not affect the main workload.
		Automatically implicates "-PassThru".

	.EXAMPLE
		PS C:\> Connect-Database -Transient

		Connects to the in-memory database (or creates it as an empty database, if not present).
		This connection will not be managed.
		A good test, on whether the Database services are functional.

	.EXAMPLE
		PS C:\> Connect-Database -Path C:\reporting\data

		Establishes a connection to a file-based database under C:\reporting\data
		The connection will not be returned, but managed by the module.
		Subsequent "Invoke-DatabaseQuery" calls will automatically use it.

	.EXAMPLE
		PS C:\> Connect-Database -Path C:\reporting\data -PassThru

		Establishes a connection to a file-based database under C:\reporting\data
		The connection will be returned as an object, but also managed by the module.
		Subsequent "Invoke-DatabaseQuery" calls will automatically use it.
	#>
    [CmdletBinding()]
    param (
        [string]
		$Path = ":memory:",

		[switch]
		$PassThru,

		[switch]
		$Transient
    )

	Write-PSFMessage -Level System -Message 'Establishing a DuckDB connection against {0}' -StringValues $Path -Tag DB
    $database = [DuckDB.NET.Data.DuckDBConnection]::new("Data Source=$Path")
    $database.Open()
    if ($PassThru -or $Transient) {$database}
	if (-not $Transient) {
		if ($script:_DatabaseConnection) {
			$script:_DatabaseConnection.Close()
			$script:_DatabaseConnection.Dispose()
		}
		$script:_DatabaseConnection = $database
	}
}
