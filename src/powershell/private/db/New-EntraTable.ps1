<#
.SYNOPSIS
    Creates a new table in the database.
#>

function New-EntraTable {
    [CmdletBinding()]
    param (
        # The connection to the database.
        [Parameter(Mandatory = $true)]
        [DuckDB.NET.Data.DuckDBConnection]$Connection,

        # The name of the table to create.
        [Parameter(Mandatory = $true)]
        [string]$TableName,

        # The file path to import from
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    Write-Verbose "Creating table $TableName from $FilePath"

    $command = $Connection.CreateCommand()
    $command.CommandText = "CREATE TABLE $TableName AS SELECT unnest(value, recursive:=true) FROM '$FilePath';"
    $command.ExecuteNonQuery()
    $command.Dispose()
}
