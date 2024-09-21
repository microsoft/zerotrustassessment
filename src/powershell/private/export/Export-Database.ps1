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
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleDefinition'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleAssignment'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleAssignmentGroup'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleEligibilityScheduleRequest'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleEligibilityScheduleRequestGroup'

    New-ViewRole -db $db
    return $db
}

function Import-Table($db, $absExportPath, $tableName) {

    $folderPath = Join-Path $absExportPath $tableName

    # Copy the model file if it exists (needed to create table schema to avoid sql errors when there is no data)
    $modelFilePath = Join-Path -Path $PSScriptRoot -ChildPath "model/$tableName-model.json"
    if(Test-Path $modelFilePath) {
        Copy-Item -Path $modelFilePath -Destination $folderPath -Force
    }

    $filePath = Join-Path $folderPath "$tableName*.json"

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

function New-ViewRole($db){

    $sql = @"
create view vwRole
as
select ra."roleDefinitionId", ra.principal.displayName as principalDisplayName, rd.displayName as roleDisplayName, ra.principal.userPrincipalName, rd.isPrivileged,
    ra.principal."@odata.type",
    ra.principalId, ra.principalOrganizationId, ra.principal.servicePrincipalType,
    'Permanent' as privilegeType
from main."RoleAssignment" ra
    left join main."RoleDefinition" rd on ra."roleDefinitionId" = rd.id
UNION
select re."roleDefinitionId", re.principal.displayName as principalDisplayName, rd.displayName as roleDisplayName, re.principal.userPrincipalName, rd.isPrivileged,
     re.principal."@odata.type",
     re.principalId, null as principalOrganizationId, null as servicePrincipalType,
     'Eligible' as privilegeType
from main."RoleEligibilityScheduleRequest" re
    left join  main."RoleDefinition" rd on re."roleDefinitionId" = rd.id
order by roleDisplayName, principalDisplayName
"@
    Invoke-DatabaseQuery -Database $db -Sql $sql -NonQuery
}
