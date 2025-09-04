<#
.SYNOPSIS
    Creates a database with the data files found in the specified folder.
#>

function Export-Database {
    [CmdletBinding()]
    param (
        # The path to the folder where all the files were exported.
        [Parameter(Mandatory = $true)]
        [string]$ExportPath,

        # The Zero Trust pillar to assess. Defaults to All.
        [ValidateSet('All', 'Identity', 'Devices')]
        [string]
        $Pillar = 'All'
    )

    # Nothing to do if the Pillar is Devices (for now)
    if ($Pillar -eq 'Devices') {
        Write-PSFMessage 'Skipping data export for Device pillar.' -Tag Import
        return
    }

    $activity = "Creating database"
    Write-ZtProgress -Activity $activity -Status "Starting"

    Write-PSFMessage "Importing data from $ExportPath" -Tag Import
    $dbFolderName = 'db'
    $dbFolder = Join-Path $ExportPath $dbFolderName
    $absExportPath = $ExportPath | Resolve-Path
    $dbPath = Join-Path $absExportPath $dbFolderName "zt.db"

    if (Test-Path $dbFolder) {
        Write-PSFMessage "Clearing previous db $dbFolder" -Tag Import
        $db = Connect-Database -Path $dbPath
        $sqlTemp = "FORCE CHECKPOINT;"
        Invoke-DatabaseQuery -Database $db -Sql $sqlTemp -NonQuery
        Disconnect-Database -Database $db
        Remove-Item $dbFolder -Recurse -Force | Out-Null # Remove the existing database
    }
    New-Item -ItemType Directory -Path $dbFolder -Force -ErrorAction Stop | Out-Null

    $db = Connect-Database -Path $dbPath

    Import-Table -db $db -absExportPath $absExportPath -tableName 'User'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'Application'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'ServicePrincipal'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'ServicePrincipalSignIn'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'SignIn'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleDefinition'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleAssignment'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleAssignmentGroup'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleAssignmentSchedule'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleEligibilityScheduleRequest'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleEligibilityScheduleRequestGroup'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'RoleManagementPolicyAssignment'
    Import-Table -db $db -absExportPath $absExportPath -tableName 'UserRegistrationDetails'

    New-ViewRole -db $db
    return $db
}

function Import-Table
{
	[CmdletBinding()]
	param (
		$db,

		$absExportPath,

		$tableName
	)

    Write-PSFMessage "Importing table $tableName" -Tag Import
    $folderPath = Join-Path $absExportPath $tableName

    # Copy the model file if it exists (needed to create table schema to avoid sql errors when there is no data)
    $modelFilePath = Join-Path -Path $script:ModuleRoot -ChildPath "assets/export-model/$tableName-model.json"

    $hasModelRow = $false
    if(Test-Path $modelFilePath) {
        # Ensure the folder exists
        if(!(Test-Path $folderPath)) {
            New-Item -ItemType Directory -Path $folderPath -Force -ErrorAction Stop | Out-Null
        }
        Copy-Item -Path $modelFilePath -Destination $folderPath -Force
        $hasModelRow = $true
    }

    $filePath = Join-Path $folderPath "$tableName*.json"

    New-EntraTable -Connection $db -TableName $tableName -FilePath $filePath

    if($hasModelRow) {
        # Let's delete the model row to keep the data clean.
        $deleteModelRow = "DELETE FROM main.$tableName WHERE isZtModelRow = true;"
        Invoke-DatabaseQuery -Database $db -Sql $deleteModelRow -NonQuery
    }
}

function Get-DbConnection
{
	[CmdletBinding()]
	param (
		$DbPath
	)
    $db = [DuckDB.NET.Data.DuckDBConnection]::new("Data Source=$DbPath")
    $db.Open()
    return $db
}

function Close-DbConnection
{
	[CmdletBinding()]
	param (
		$db
	)
    $db.Close()
    $db.Dispose()
}

function Get-RoleSelectSql
{
	[CmdletBinding()]
	param (
		$tableName,

		$privilegeType,

		[switch]
		$addUnion
	)
    $sql = @"

    select
        rd.isPrivileged,
        cast(r."roleDefinitionId" as varchar)            as roleDefinitionId,
        cast(r.principal.displayName as varchar)        as principalDisplayName,
        rd.displayName                                  as roleDisplayName,
        cast(r.principal.userPrincipalName as varchar)  as userPrincipalName,
        cast(r.principal."@odata.type" as varchar)      as "@odata.type",
        cast(r.principalId as varchar)                  as principalId,
        '$privilegeType'                                as privilegeType
    from main."$tableName" r
        left join main."RoleDefinition" rd on r."roleDefinitionId" = rd.id

"@

    if($addUnion){
        $sql += 'union all'
    }

    return $sql
}
function New-ViewRole
{
	[CmdletBinding()]
	param (
		$db
	)

    $sql = @"
create view vwRole
as

"@

    $RoleAssignmentScheduleCountSql = 'select count(*) as RoleAssignmentScheduleCount from RoleAssignmentSchedule where id is not null'
    $result = Invoke-DatabaseQuery -Database $db -Sql $RoleAssignmentScheduleCountSql
    if($result.RoleAssignmentScheduleCount -gt 0) {
        # Is P2 tenant, don't read RoleAssignment because it contains PIM Eligible temporary users and has no way to filter it out.
        $sql += Get-RoleSelectSql -tableName 'RoleAssignmentSchedule' -privilegeType 'Permanent' -addUnion
    }
    else {
        # Is Free or P1 tenant so we only have the RoleAssignment table to go on.
        $sql += Get-RoleSelectSql -tableName "RoleAssignment" -privilegeType 'Permanent' -addUnion
    }
    # Now read RoleEligibilityScheduleRequest to get PIM Eligible users
    $sql += Get-RoleSelectSql -tableName "RoleEligibilityScheduleRequest" -privilegeType 'Eligible'

    Invoke-DatabaseQuery -Database $db -Sql $sql -NonQuery
}
