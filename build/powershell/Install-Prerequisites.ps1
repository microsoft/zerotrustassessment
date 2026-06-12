[CmdletBinding()]
param (
	[string]
	$Repository = 'PSGallery'
)

Invoke-WebRequest 'https://raw.githubusercontent.com/PowershellFrameworkCollective/PSFramework.NuGet/refs/heads/master/bootstrap.ps1' | Invoke-Expression

$modules = @(
	"Pester" # Test Framework, runs the tests
	"PSScriptAnalyzer" # PowerShell Best Practices analyzer, will be used in tests
	'Refactor' # Used to update the metadata for individual test commands
	"Metadata" # Used to update psd1 files instead of the broken Update-ModuleManifest command
)

# Automatically add missing dependencies
$data = Import-PowerShellDataFile -Path "$PSScriptRoot\..\..\src\powershell\ZeroTrustAssessment.psd1"
foreach ($dependency in $data.RequiredModules) {
	if ($dependency -is [string]) {
		if ($modules -contains $dependency) {
			continue
		}
		$modules += $dependency
	}
	else {
		if ($modules -contains $dependency.ModuleName) {
			continue
		}
		$modules += $dependency.ModuleName
	}
}

Install-PSFModule -Name $modules
