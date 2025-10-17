# Initialize Module Variables
## Update Clear-ModuleVariable function in private/Clear-ModuleVariable.ps1 if you add new variables here
$script:__ZtSession = @{
	# A DCO dictionary is the same threadsafe dictionary across all runspaces, allowing parallelized checks to write results to the same store safely
	GraphCache   = Set-PSFDynamicContentObject -Name "ZtAssessment.GraphCache" -Dictionary -PassThru
	GraphBaseUri = $null
	TestMeta     = @()
	TestResultDetail = Set-PSFDynamicContentObject -Name "ZtAssessment.TestResultDetails" -Dictionary -PassThru
	TestStatistics = Set-PSFDynamicContentObject -Name "ZtAssessment.TestStatistics" -Dictionary -PassThru
	TenantInfo = Set-PSFDynamicContentObject -Name "ZtAssessment.TenantInfo" -Dictionary -PassThru
}

$script:__ZtThrottling = Set-PSFDynamicContentObject -Name "ZtAssessment.Throttles" -Dictionary -PassThru
## Intune API Limits: 1000 / 20 seconds
if (-not $script:__ZtThrottling.Value['deviceManagement']) {
	$script:__ZtThrottling.Value['deviceManagement'] = New-PSFThrottle -Interval 20s -Limit 1000
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
