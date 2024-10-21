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

    Write-PSFMessage "Running query: $Sql" -Level Debug -Tag DB
    $cmd = $Database.CreateCommand()
    $cmd.CommandText = $Sql

    if ($NonQuery) {
        $cmd.ExecuteNonQuery() | Out-Null
    }
    else {
        try {
            $reader = $cmd.ExecuteReader()
        }
        catch {
            Write-PSFMessage "Error running query: $Sql" -Level Warning -ErrorRecord $_ -Tag DB
        }

        while ($reader -and $reader.read()) {
            $rowObject = @{}
            for ($columnIndex = 0; $columnIndex -lt $reader.FieldCount; $columnIndex++ ) {
                $rowObject[$reader.GetName($columnIndex)] = $reader.GetValue($columnIndex)
            }
            Write-PSFMessage $rowObject -Level Debug -Tag DB
            $rowObject
        }
    }
    $cmd.Dispose();
}
