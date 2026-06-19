# Initialize Module Variables
## Update Clear-ModuleVariable function in private/Clear-ModuleVariable.ps1 if you add new variables here

# Read module version from the manifest once, including any prerelease suffix (e.g. "2.1.8-preview")
$manifest = Import-PSFPowerShellDataFile -Path (Join-Path $script:ModuleRoot 'ZeroTrustAssessment.psd1')
$moduleVersion = $manifest.ModuleVersion
$prerelease = $manifest.PrivateData.PSData.Prerelease
if ($prerelease) { $moduleVersion = "$moduleVersion-$prerelease" }

$script:__ZtSession = @{
	# A DCO cache is the same threadsafe dictionary across all runspaces, allowing parallelized checks to write results to the same store safely. It also supports maximum number and maximum age of entries to prevent too heavy memory loads
	GraphCache   = Set-PSFDynamicContentObject -Name "ZtAssessment.GraphCache" -Cache -PassThru
	AzureCache   = Set-PSFDynamicContentObject -Name "ZtAssessment.AzureCache" -Cache -PassThru
	GraphBaseUri = $null
	TestMeta     = @()
	# A DCO dictionary is the same threadsafe dictionary across all runspaces, allowing parallelized checks to write results to the same store safely
	TestResultDetail = Set-PSFDynamicContentObject -Name "ZtAssessment.TestResultDetails" -Dictionary -PassThru
	TestStatistics = Set-PSFDynamicContentObject -Name "ZtAssessment.TestStatistics" -Dictionary -PassThru
	TenantInfo = Set-PSFDynamicContentObject -Name "ZtAssessment.TenantInfo" -Dictionary -PassThru
	ProgressState = Set-PSFDynamicContentObject -Name "ZtAssessment.ProgressState" -Dictionary -PassThru
	ProgressServer = $null # Holds the background runspace and listener for the progress web server
	ModuleVersion = $moduleVersion
}
if ($lifetime = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Azure.CacheLifetime') {
	$script:__ZtSession.AzureCache.Value.SetLifetime($lifetime)
}
if ($lifetime = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Graph.CacheLifetime') {
	$script:__ZtSession.GraphCache.Value.SetLifetime($lifetime)
}
if ($maxItems = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Azure.CacheMaxItems') {
	$script:__ZtSession.AzureCache.Value.SetMaxItems($maxItems)
}
if ($maxItems = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Graph.CacheMaxItems') {
	$script:__ZtSession.GraphCache.Value.SetMaxItems($maxItems)
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
