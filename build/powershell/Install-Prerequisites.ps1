[CmdletBinding()]
param (
	[string]
	$Repository = 'PSGallery'
)

Invoke-WebRequest 'https://raw.githubusercontent.com/PowershellFrameworkCollective/PSFramework.NuGet/refs/heads/master/bootstrap.ps1' | Invoke-Expression

$modules = @("Pester", "PSScriptAnalyzer")

# Automatically add missing dependencies
$data = Import-PowerShellDataFile -Path "$PSScriptRoot\..\..\src\powershell\ZeroTrustAssessmentV2.psd1"
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
