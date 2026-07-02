[CmdletBinding()]
param (
	[string]
	$Repository = 'PSGallery'
)

$modules = @(
	@{ ModuleName = "Pester" } # Test Framework, runs the tests
	@{ ModuleName = "PSScriptAnalyzer" } # PowerShell Best Practices analyzer, will be used in tests
	@{ ModuleName = 'Refactor' } # Used to update the metadata for individual test commands
	@{ ModuleName = "Metadata" } # Used to update psd1 files instead of the broken Update-ModuleManifest command
)

# Automatically add missing dependencies
$data = Import-PowerShellDataFile -Path "$PSScriptRoot\..\..\src\powershell\ZeroTrustAssessment.psd1"
foreach ($dependency in $data.RequiredModules) {
	if ($dependency -is [string]) {
		if ($modules.ModuleName -contains $dependency) {
			continue
		}
		$modules += @{ ModuleName = $dependency }
	}
	else {
		if ($modules.ModuleName -contains $dependency.ModuleName) {
			continue
		}
		$modules += @{
			ModuleName     = $dependency.ModuleName
			RequiredVersion = $dependency.RequiredVersion
			MinimumVersion = $dependency.ModuleVersion
		}
	}
}

# Ensure TLS 1.2 is used when contacting the PowerShell Gallery
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# Make sure the NuGet package provider is available for Install-Module
if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
	Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force -Scope CurrentUser | Out-Null
}

# Ensure the target repository is registered for PowerShellGet.
# PowerShell 7.6+ bundles Microsoft.PowerShell.PSResourceGet as the default package module
# and no longer seeds the PSGallery source for the legacy PowerShellGet/PackageManagement stack
# that Install-Module relies on, so register it explicitly when missing.
if (-not (Get-PSRepository -Name $Repository -ErrorAction SilentlyContinue)) {
	if ($Repository -eq 'PSGallery') {
		Register-PSRepository -Default -ErrorAction Stop
	}
	else {
		throw "Repository '$Repository' is not registered for PowerShellGet. Register it before running this script."
	}
}

foreach ($module in $modules) {
	$installParams = @{
		Name               = $module.ModuleName
		Repository         = $Repository
		Scope              = 'CurrentUser'
		Force              = $true
		AllowClobber       = $true
		SkipPublisherCheck = $true
		ErrorAction        = 'Stop'
	}
	if ($module.RequiredVersion) {
		$installParams['RequiredVersion'] = $module.RequiredVersion
	}
	elseif ($module.MinimumVersion) {
		$installParams['MinimumVersion'] = $module.MinimumVersion
	}

	Write-Verbose "Installing module '$($module.ModuleName)' from repository '$Repository'."
	Install-Module @installParams
}
