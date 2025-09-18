#requires -Modules PSFramework, Refactor
<#
.SYNOPSIS
	Bulk updater of test commands

.DESCRIPTION
	Bulk updater of test commands
	The config file may be .json or .psd1.

	Two content formats are supported:

	+ One big hashtable. Each key must be the Test ID, each value a child hashtable with the remaining entries to be appleid.
	+ An array of Hashtables. Each hashtable must include the full data for a single test, including either (or both) "Test" or "TestID" to identify the test it applies to.

	Requires two modules to function:

	+ PSFramework - General Tooling
	+ Refactor - Rewriting the commands / applying the changes

.PARAMETER ConfigFile
	Path to the config file(s) to apply.

.EXAMPLE
	PS C:\> .\metadata-bulkupdate -ConfigFile .\TestMeta.json

	Applies all the test settings from TestMeta.Json to the corresponding test commands.
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)]
	[PSFFile]
	$ConfigFile
)

$ErrorActionPreference = 'Stop'
trap {
	Write-Warning "Script failed: $_"
	throw $_
}

. "$PSScriptRoot\..\commands\Set-TestMetadata.ps1"

#region Functions
function ConvertTo-ConfigEntry {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string]
		$Path
	)

	process {
		$data = Import-PSFPowerShellDataFile -LiteralPath $Path -Psd1Mode Safe
		if ($data -is [hashtable]) {
			foreach ($pair in $data.GetEnumerator()) {
				$hash = $pair.Value | ConvertTo-PSFHashtable -ReferenceCommand Set-TestMetadata
				$hash.Test = $pair.Key
				$hash.TestID = $pair.Key
				$hash
			}
			return
		}

		foreach ($datum in $data) {
			$hash = $datum | ConvertTo-PSFHashtable -ReferenceCommand Set-TestMetadata
			if (-not $hash.TestID -and -not $hash.Test) {
				Write-Error "Invalid entry: Neither 'Test' nor 'TestID' found! $hash"
				continue
			}
			if ($hash.TestID -and -not $hash.Test) {
				$hash.Test = $hash.TestID
			}
			elseif ($hash.Test -and -not $hash.TestID) {
				$hash.TestID = $hash.Test
			}
			$hash
		}
	}
}
#endregion Functions

$configEntries = $ConfigFile | ConvertTo-ConfigEntry
foreach ($entry in $configEntries) {
	try { Set-TestMetadata @entry -ErrorAction Stop }
	catch {
		$testID = $entry.Test
		if (-not $testID) {
			$testID = $entry.TestID
		}
		Write-PSFMessage -Level Warning -Message "Failed to update Test $($testID)" -ErrorRecord $_ -Target $entry
	}
}
