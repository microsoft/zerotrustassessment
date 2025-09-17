## Initialize Module Variables
## Update Clear-ModuleVariable function in private/Clear-ModuleVariable.ps1 if you add new variables here
$script:__ZtSession = @{
	GraphCache   = @{}
	GraphBaseUri = $null
}

$testMetaPath = "$script:ModuleRoot\tests\TestMeta.json"
if (Test-Path $testMetaPath) {
	# Read json and store in hashtable
	$script:__ZtSession.TestMeta = Import-PSFJson -LiteralPath $testMetaPath -AsHashtable
}

# The Database Connection used by Invoke-DatabaseQuery. Established by Connect-Database, cleared by Disconnect-Database
$script:_DatabaseConnection = $null

# Load the graph scope risk mapping. Used in Get-GraphPermissionRisk.
$graphPermissionsTable = Import-Csv -Path (Join-Path -Path $Script:ModuleRoot -ChildPath 'assets/aadconsentgrantpermissiontable.csv') -Delimiter ','
$Script:_GraphPermissions = @{}
$script:_GraphPermissionsHash = @{}
foreach ($perm in $graphPermissionsTable) {
	$key = $perm.Type + $perm.Permission
	$script:_GraphPermissionsHash[$key] = $perm
	if ($perm.permission -match "\.") {
		$key = $perm.Type + $perm.Permission.Split(".")[0]
		$script:_GraphPermissionsHash[$key] = $perm
	}
}
