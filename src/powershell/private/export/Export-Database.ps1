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
    $absExportPath = $ExportPath | Resolve-Path
    $dbPath = Join-Path $absExportPath $dbFolderName "zt.db"

    if (Test-Path $dbFolder) {
        Write-Verbose "Clearing previous db $dbFolder"
        $db = Connect-Database -Path $dbPath
        $sqlTemp = "FORCE CHECKPOINT;"
        Invoke-DatabaseQuery -Database $db -Sql $sqlTemp -NonQuery
        Disconnect-Database -Database $db
        Remove-Item $dbFolder -Recurse -Force | Out-Null # Remove the existing database
    }
    New-Item -ItemType Directory -Path $dbFolder -Force -ErrorAction Stop | Out-Null

    $db = Connect-Database -Path $dbPath

    Import-Table -db $db -absExportPath $absExportPath -tableName 'Application'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'ServicePrincipal'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'ServicePrincipalSignIn'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'SignIn'

    return $db
}

function Import-Table($db, $absExportPath, $tableName) {

    $filePath = Join-Path $absExportPath $tableName "$tableName*.json"

    New-EntraTable -Connection $db -TableName $tableName -FilePath $filePath
}

function Get-DbConnection ($DbPath) {
    $db = [DuckDB.NET.Data.DuckDBConnection]::new("Data Source=$DbPath")
    $db.Open()
    return $db
}

function Close-DbConnection ($db) {
    $db.Close()
    $db.Dispose()
}
