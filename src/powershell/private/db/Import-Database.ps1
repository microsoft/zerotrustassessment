<#
.SYNOPSIS
    Imports all the files in the specifed folder into the database.
#>

function Import-Database{
    [CmdletBinding()]
    param (
        # The connection to the database.
        [Parameter(Mandatory = $true)]
        [DuckDB.NET.Data.DuckDBConnection]$Connection,

        # The path to the folder containing the data files.
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    Write-Verbose "Importing data from $Path"

    New-EntraTable -Connection $Connection -TableName $table -FilePath $fileName
}
