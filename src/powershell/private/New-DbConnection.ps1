Function New-ZtDbConnection {
    [CmdletBinding()]
    param (
        [string]$Path = ":memory:"
    )

    return [DuckDB.NET.Data.DuckDBConnection]::new("Data Source=$dbPath")
}
