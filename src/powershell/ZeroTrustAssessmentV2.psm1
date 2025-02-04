Add-Type -Path "$PSScriptRoot\lib\DuckDB.NET.Data.dll"

## Initialize Module Variables
## Update Clear-ModuleVariable function in private/Clear-ModuleVariable.ps1 if you add new variables here
$__ZtSession = @{
	GraphCache = @{}
	GraphBaseUri = $null
}
New-Variable -Name __ZtSession -Value $__ZtSession -Scope Script -Force


# Import private and public scripts and expose the public ones
$privateScripts = @(Get-ChildItem -Path "$PSScriptRoot\private" -Recurse -Filter "*.ps1")
$publicScripts = @(Get-ChildItem -Path "$PSScriptRoot\public" -Recurse -Filter "*.ps1")

foreach ($script in ($privateScripts + $publicScripts)) {
	try {
		. $script.FullName
	} catch {
		Write-Error -Message ("Failed to import function {0}: {1}" -f $script, $_)
	}
}

$testMetaPath = "$PSScriptRoot\private\tests\TestMeta.json"
if (Test-Path $testMetaPath) {
	# Read json and store in hashtable
	$__ZtSession.TestMeta = Get-Content -Path $testMetaPath | ConvertFrom-Json -AsHashtable
}
