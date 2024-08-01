<#
.SYNOPSIS
    Creates a new database connection at the specified path.
#>
function Connect-Database {
    [CmdletBinding()]
    param (
        [string]$Path = ":memory:"
    )

    return [DuckDB.NET.Data.DuckDBConnection]::new("Data Source=$dbPath")
}
