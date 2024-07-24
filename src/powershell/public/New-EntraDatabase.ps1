<#
.SYNOPSIS
    Creates a database with the data files found in the specified folder.
#>

function New-EntraDatabase {
    [CmdletBinding()]
    param (
        # The path to the database file.
        [Parameter(Mandatory = $true)]
        [string]$Path,

        # The folder containing the data files that were exported.
        [Parameter(Mandatory = $true)]
        [string]$ExportedFolder
    )

    $absoluteExportedFolder = $ExportedFolder | Resolve-Path

    $schema = Get-EEDefaultSchema

    $db = [DuckDB.NET.Data.DuckDBConnection]::new("Data Source=$Path")

    $db.Open()

    Import-EntraDatabaseNode -Connection $db -Path $absoluteExportedFolder -Schema $schema

    $db.Close()
}
