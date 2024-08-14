<#
.SYNOPSIS
    Creates a database with the data files found in the specified folder.
#>

function Export-Database {
    [CmdletBinding()]
    param (
        # The path to the folder where all the files were exported.
        [Parameter(Mandatory = $true)]
        [string]$ExportPath
    )
    $activity = "Creating database"
    Write-ZtProgress -Activity $activity -Status "Starting"

    Write-Verbose "Importing data from $ExportPath"
    $dbFolderName = 'db'
    $dbFolder = Join-Path $ExportPath $dbFolderName
    if (Test-Path $dbFolder) {
        Write-Host "Creating db folder $dbFolder"
        Remove-Item $dbFolder -Recurse -Force | Out-Null # Remove the existing database
    }
    New-Item -ItemType Directory -Path $dbFolder -Force -ErrorAction Stop | Out-Null

    $absExportPath = $ExportPath | Resolve-Path
    $dbPath = Join-Path $absExportPath $dbFolderName "zt.db"
    Write-Host "Creating database at $dbPath"
    $db = [DuckDB.NET.Data.DuckDBConnection]::new("Data Source=$dbPath")
    $db.Open()

    Import-Table -db $db -absExportPath $absExportPath -tableName 'Application'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'ServicePrincipal'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'ServicePrincipalSignIn'

    return $db
}

function Import-Table($db, $absExportPath, $tableName) {

    $filePath = Join-Path $absExportPath $tableName "$tableName*.json"

    New-EntraTable -Connection $db -TableName $tableName -FilePath $filePath
}
