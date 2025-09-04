## Initialize Module Variables
## Update Clear-ModuleVariable function in private/Clear-ModuleVariable.ps1 if you add new variables here
$script:__ZtSession = @{
	GraphCache = @{}
	GraphBaseUri = $null
}

$testMetaPath = "$script:ModuleRoot\private\tests\TestMeta.json"
if (Test-Path $testMetaPath) {
	# Read json and store in hashtable
	$script:__ZtSession.TestMeta = Import-PSFJson -LiteralPath $testMetaPath
}
