﻿<#
.SYNOPSIS
    Creates a new table in the database.
#>

function New-EntraTable {
    [CmdletBinding()]
    param (
        # The connection to the database.
        [Parameter(Mandatory = $true)]
        [DuckDB.NET.Data.DuckDBConnection]
        $Connection,

        # The name of the table to create.
        [Parameter(Mandatory = $true)]
        [string]
        $TableName,

        # The file path to import from
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath
    )

    $sqlTemp = "CREATE TABLE temp$TableName AS SELECT unnest(value) as d FROM read_json('$FilePath');"
    $sqlTable = "CREATE TABLE $TableName AS SELECT d.* FROM temp$TableName;"

    Invoke-DatabaseQuery -Database $Connection -Sql $sqlTemp -NonQuery
    Invoke-DatabaseQuery -Database $Connection -Sql $sqlTable -NonQuery
}