function Invoke-DatabaseQuery {
	<#
	.SYNOPSIS
		Executes a SQL statement against the specified / connected database.

	.DESCRIPTION
		Executes a SQL statement against the specified / connected database.
		Will default to the module-managed database established when calling Connect-Database.

	.PARAMETER Database
		The database to execute against.
		Use Connect-Database to establish a connection.
		May be omitted, when a module-managed connection has previously been established.

	.PARAMETER Sql
		The SQL Statement to execute.

	.PARAMETER NonQuery
		The SQl Statement is not a data request, no response is expected.

	.PARAMETER Ordered
		Ensure the properties on the result datasets are in the same order as in the query.
		In most cases a cosmetic choice, adds to the processing cost.

	.PARAMETER AsCustomObject
		The resultant datasets are returned as [PSCustomObject], rather than as [hashtable].
		Adds a slight processing cost, but may be more convenient.

	.EXAMPLE
		PS C:\> Invoke-DatabaseQuery -Sql $query

		Executes a SQL query against the previously established connection and returns the results.

	.EXAMPLE
		PS C:\> Invoke-DatabaseQuery -Sql $query -Database $db -NonQuery

		Executes a SQL statement against the provided connection without processing results.
	#>
    [CmdletBinding()]
    param (
        [DuckDB.NET.Data.DuckDBConnection]
        $Database,

        [Parameter(Mandatory = $true)]
		[Alias('Query')]
		[string]
        $Sql,

		[switch]
        $NonQuery,

		[switch]
		$Ordered,

		[switch]
		$AsCustomObject
    )

	#region Resolve Database
	$dbToUse = $Database
	if (-not $dbToUse) { $dbToUse = $script:_DatabaseConnection }
	if (-not $dbToUse) {
		Stop-PSFFunction -Message "No Database Connection provided, cannot execute SQL statement!`nUse 'Connect-Database' to connect first." -Cmdlet $PSCmdlet -EnableException $true -Category ConnectionError -Tag DB
	}
	#endregion Resolve Database

	#region Execute Query
    Write-PSFMessage "Running query: $Sql" -Level Debug -Tag DB
    $cmd = $dbToUse.CreateCommand()
    $cmd.CommandText = $Sql

    if ($NonQuery) {
        $null = $cmd.ExecuteNonQuery()
		$cmd.Dispose()
		return
    }

	try {
		$reader = $cmd.ExecuteReader()
	}
	catch {
		$cmd.Dispose()
		Write-PSFMessage "Error running query: $Sql" -Level Error -ErrorRecord $_ -Tag DB -EnableException $true
		return
	}
	#endregion Execute Query

	#region Process Results
	$logsIncludeResults = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Logging.Database.IncludeQueryResults'

	while ($reader.read()) {
		if ($Ordered) { $rowObject = [ordered]@{} }
		else { $rowObject = @{} }

		for ($columnIndex = 0; $columnIndex -lt $reader.FieldCount; $columnIndex++ ) {
			$rowObject[$reader.GetName($columnIndex)] = $reader.GetValue($columnIndex)
		}
		if ($logsIncludeResults) { Write-PSFMessage $rowObject -Target $rowObject -Level Debug -Tag DB }
		if ($AsCustomObject) { [PSCustomObject]$rowObject }
		else { $rowObject }
	}
	#endregion Process Results

    $cmd.Dispose()
}
