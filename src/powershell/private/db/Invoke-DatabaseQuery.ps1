function Invoke-DatabaseQuery {
    [CmdletBinding()]
    param (
        # The database connection to use
        [DuckDB.NET.Data.DuckDBConnection]
        $Database,
        # The query to run
        [string]
        [Parameter(Mandatory = $true)]
        $Sql,
        # If set, the query will be run as a non-query and no results returned.
        [switch]
        $NonQuery
    )

    Write-Verbose "Running query: $Sql"
    $cmd = $Database.CreateCommand()
    $cmd.CommandText = $Sql

    if ($NonQuery) {
        $cmd.ExecuteNonQuery() | Out-Null
    }
    else {
        $reader = $cmd.ExecuteReader()

        while ($reader.read()) {
            $rowObject = @{}
            for ($columnIndex = 0; $columnIndex -lt $reader.FieldCount; $columnIndex++ ) {
                $rowObject[$reader.GetName($columnIndex)] = $reader.GetValue($columnIndex)
            }
            Write-Verbose $rowObject
            $rowObject
        }
    }
    $cmd.Dispose();
}
