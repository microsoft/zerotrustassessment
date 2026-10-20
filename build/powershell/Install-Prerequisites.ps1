[CmdletBinding()]
param (
    [string]
    $Repository = 'PSGallery'
)

$ErrorActionPreference = 'Stop'

$modules = @(
    @{ ModuleName = 'Pester' }          # Test Framework, runs the tests
    @{ ModuleName = 'PSScriptAnalyzer' } # PowerShell Best Practices analyzer
    @{ ModuleName = 'Refactor' }        # Used to update metadata for individual test commands
    @{ ModuleName = 'Metadata' }        # Used to update psd1 files
)

# Automatically add missing dependencies
$data = Import-PowerShellDataFile -Path "$PSScriptRoot\..\..\src\powershell\ZeroTrustAssessment.psd1"

foreach ($dependency in $data.RequiredModules) {
    if ($dependency -is [string]) {
        if ($modules.ModuleName -contains $dependency) {
            continue
        }

        $modules += @{
            ModuleName = $dependency
        }
    }
    else {
        if ($modules.ModuleName -contains $dependency.ModuleName) {
            continue
        }

        $modules += @{
            ModuleName      = $dependency.ModuleName
            RequiredVersion = $dependency.RequiredVersion
            MinimumVersion  = $dependency.ModuleVersion
        }
    }
}

# Require PSResourceGet rather than bootstrapping the legacy
# PowerShellGet / PackageManagement stack.
if (-not (Get-Command Install-PSResource -ErrorAction SilentlyContinue)) {
    throw @"
Microsoft.PowerShell.PSResourceGet is required to install build prerequisites.
Install a current version of PowerShell 7 or install Microsoft.PowerShell.PSResourceGet,
then run this script again.
"@
}

# Ensure the requested repository is registered with PSResourceGet.
if (-not (Get-PSResourceRepository -Name $Repository -ErrorAction SilentlyContinue)) {
    if ($Repository -eq 'PSGallery') {
        Reset-PSResourceRepository
    }
    else {
        throw "Repository '$Repository' is not registered with PSResourceGet. Register it before running this script."
    }
}

$totalModules = $modules.Count
$currentIndex = 0

foreach ($module in $modules) {
    $currentIndex++

    $installParams = @{
        Name            = $module.ModuleName
        Repository      = $Repository
        Scope           = 'CurrentUser'
        TrustRepository = $true
        ErrorAction     = 'Stop'
    }

    if ($module.RequiredVersion) {
        $installParams['Version'] = $module.RequiredVersion
    }
    elseif ($module.MinimumVersion) {
        $installParams['Version'] = "[$($module.MinimumVersion),)"
    }

    $versionInfo = if ($installParams['Version']) { " ($($installParams['Version']))" } else { '' }
    Write-Host "[$currentIndex/$totalModules] Installing module '$($module.ModuleName)'$versionInfo from repository '$Repository'..."

    Install-PSResource @installParams
}

Write-Host "All $totalModules prerequisite modules installed." -ForegroundColor Green
