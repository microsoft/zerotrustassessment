<#
.SYNOPSIS
    Imports the data files found in the specified folder into the database.

#>

function Import-EntraDatabaseNode {
    [CmdletBinding()]
    param (
        # The connection to the database.
        [Parameter(Mandatory = $true)]
        [DuckDB.NET.Data.DuckDBConnection]$Connection,

        # The path to the folder containing the data files.
        [Parameter(Mandatory = $true)]
        [string]$Path,

        # The schema to use for the import.
        [Parameter(Mandatory = $true)]
        [object]$Schema
    )

    Write-PSFMessage "Importing data from $Path" -Tag Import

    foreach ($item in $Schema) {
        $table = Get-ObjectProperty $item 'Table'
        if (!$table) {
            continue # Skip schema items that don't have a Table mapping defined
        }

        $fileName = Join-Path -Path $Path -ChildPath $item.Path
        Write-PSFMessage "Importing $fileName" -Level Debug -Tag Import

        if ($fileName -match "\.json$") {
            $hasFile = Test-Path $fileName
            if ($hasFile) {
                New-EntraTable -Connection $Connection -TableName $table -FilePath $fileName
            }
        }

    }

}
