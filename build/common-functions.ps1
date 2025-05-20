# ------------------------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All Rights Reserved.  Licensed under the MIT License.  See License in the project root for license information.
# ------------------------------------------------------------------------------
Set-StrictMode -Version 5

$script:_config = Import-PowerShellDataFile -Path "$PSScriptRoot\build.config.psd1"

function Get-ConfigValue {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[ArgumentCompleter({ (Import-PowerShellDataFile -Path "$PSScriptRoot\build.config.psd1").Keys })]
		[string]
		$Name
	)

	$script:_config[$Name]
}
function Get-ModuleManifestFile {
	Get-ChildItem (Get-ModuleBasePath) -Filter '*.psd1'
}
function Get-ModuleName {
	Get-ChildItem (Get-ModuleBasePath) -Filter '*.psd1' | Select-Object -ExpandProperty basename
}

function Get-ModuleBasePath {
	Join-Path (Split-Path -Parent $psscriptroot) (Get-ConfigValue -Name OutputPath)
}

function Get-ModuleVersion {
	# Added -ErrorAction SilentlyContinue due to validation failure on Microsoft.Entra RequiredModules
	# The RequiredModules are the Microsoft.Entra.* sub-modules
    (Get-ModuleManifestFile).FullName | Test-ModuleManifest -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version
}

function Get-ModuleFiles {
    (Get-ModuleManifestFile).FullName | Test-ModuleManifest -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FileList
}

function Get-PSGalleryRepoName {
	Get-ConfigValue -Name PSGalleryRepoName
}

function Get-LocalPSRepoName {
	Get-ConfigValue -Name LocalGalleryRepoName
}

function Get-SourceRootDirectory {
    (Get-Item (Split-Path -Parent $psscriptroot)).fullname
}

function Get-OutputDirectory {
	Join-Path (Get-SourceRootDirectory) (Get-ConfigValue -Name OutputPath)
}

function Get-DevRepoDirectory {
	Join-Path (Get-SourceRootDirectory) '.psrepo'
}

function Remove-BuildDirectories {

	$binPath = Get-OutputDirectory
	if ( Test-Path $binPath ) {
		$binPath | Remove-Item -Recurse -Force 
	}

	$devRepoLocation = Get-DevRepoDirectory
	if (Test-Path $devRepoLocation) {
		$devRepoLocation | Remove-Item -Recurse -Force
	}
}

function Register-LocalGallery {
	param (
		$Path
	)

	$repoPath = Get-DevRepoDirectory
	if ($Path) {
		$repoPath = $Path
	}    
	if (-not(Test-Path $repoPath)) {
		$null = New-Item -Path $repoPath -ItemType Directory
	}

	$null = Register-PSRepository -Name (Get-LocalPSRepoName) -SourceLocation ($repoPath) -ScriptSourceLocation ($repoPath) -InstallationPolicy Trusted
	$null = Register-PSResourceRepository -Name (Get-LocalPSRepoName) -Uri ($repoPath)
}

function Unregister-LocalGallery {    
	$null = Unregister-PSRepository (Get-LocalPSRepoName)
	$null = Unregister-PSResourceRepository (Get-LocalPSRepoName)
}

function Update-ModuleVersion {
	[cmdletbinding()]
	param(
		[switch] $Minor,
		[switch] $Major,
		[switch] $Build
	)

	$version = Get-ModuleVersion
	$v = @{        
		Major = $version.Major
		Minor = $version.Minor
		Build = $version.Build            
	}
 
	if ($Build.IsPresent) {
		$v.Build++
	}

	if ($Minor.IsPresent) {
		$v.Minor++
	}

	if ($Major.IsPresent) {
		$v.Major++
	}

	$ver = $v.Major, $v.Minor, $v.Build -Join "."
	Update-ModuleManifest -Path (Get-ModuleManifestFile).FullName -ModuleVersion $ver
}

function Create-ModuleFolder {
	[cmdletbinding()]
	param(
		[string]$OutputDirectory,
		[switch]$NoClean
	)

	if ( -not $OutputDirectory ) {
		$OutputDirectory = Join-Path (Split-Path -Parent $psscriptroot) (Get-ConfigValue -Name OutputPath)
	}

	$modulesDirectory = Join-Path $OutputDirectory (Get-ConfigValue -Name ModuleOutputSubdirectoryName)

	if ( (Test-Path $modulesDirectory) -and -not $noclean.ispresent ) {
		$null = Remove-Item -Recurse -Force $modulesDirectory
	}

	$modules = @()
	$moduleName = Get-ModuleName
	$moduleVersion = Get-ModuleVersion

	if($moduleVersion -is [array])
	{
		$moduleVersion = $moduleVersion[0]
	}

	if($moduleName -isnot [array]){
		$modules += $moduleName
	}
	else{
		$modules = $moduleName
	}

	foreach($module in $modules){
		$thisModuleDirectory = Join-Path $modulesDirectory $module
		$targetDirectory = Join-Path $thisModuleDirectory $moduleVersion.tostring()

		$null = New-Item -Path $targetDirectory -ItemType Directory

		$ignorableSegmentCount = ((Get-ModuleBasePath).replace("`\", '/') -split '/').count
		$sourceFileList = @()
		$destinationFileList = @()
		$moduleFiles = @()

		if(($module -eq 'Microsoft.Entra') -or ($module -eq 'Microsoft.Entra.Beta')){
			$moduleFiles +=  Get-ModuleFiles | Where { $_ -like "*$module.psd1" }
			$moduleFiles +=  Get-ModuleFiles | Where { $_ -like "*$module.psm1" }
		}
		else{
			$moduleFiles +=  Get-ModuleFiles | Where  { $_ -like "*$module*" }
		}

		$moduleFiles | ForEach-Object {
			$normalizedFile = $_.replace("`\", '/')
			$segments = $normalizedFile -split '/'
			$relativeSegments = $segments[$ignorableSegmentCount..($segments.length - 1)]
			$relativePath = $relativeSegments -join '/'

			$sourceFileList += Join-Path (Get-ModuleBasePath) $relativePath
			$destinationFileList += Join-Path $targetDirectory $relativePath
		}

		0..($sourceFileList.length - 1) | ForEach-Object {
			$parent = Split-Path -Parent $destinationFileList[ $_ ]
			if ( -not (Test-Path $parent) ) {
				$null = New-Item -Path $parent -ItemType Directory
			}

			$destinationName = Split-Path -Leaf $destinationFileList[ $_ ]
			$syntaxOnlySourceName = Split-Path -Leaf $sourceFileList[ $_ ]
			$sourceActualName = (Get-ChildItem (Split-Path -Parent $sourceFileList[ $_ ]) -Filter $syntaxOnlySourceName).name

			if ( $destinationName -cne $sourceActualName ) {
				throw "The case-sensitive name of the file at source path '$($sourceFileList[$_])' is actually '$sourceActualName' and it does not match the case of the last element of destination path '$($destinationFileList[$_])' -- the case of the file names must match exactly in order to support environments with case-sensitive file systems. This can be corrected in the module manifest by specifying the case of the file exactly as it exists in the module source code directory"
			}

			Copy-Item $sourceFileList[ $_ ] $destinationFileList[ $_ ]
		}
	}
}

function Get-CustomizationFiles {
	[cmdletbinding()]
	param(
		[string]
		$Module = "Entra",

		[string]
		$Directory
	)

	$path = Split-Path -Parent $psscriptroot

	if ( -not $Directory ) {
		$path = Join-Path $path 'module_legacy'
		$path = Join-Path $path $Module
		$path = Join-Path $path (Get-ConfigValue -Name CustomizationPath)
	}
	else {
		$path = Join-Path $path 'module_legacy'      
		$path = Join-Path $path $Module
		$path = Join-Path $path $Directory
	}
	$customizationFileList = @()
	$files = Get-ChildItem -Path $path -Filter '*.ps1'
	foreach ($file in $files) {
		$customizationFileList += $file.FullName        
	}
    
	$customizationFileList
}

# Reusable logging function
function Log-Message {
    param (
        [string]$Message,
        [string]$Level = 'INFO',  # Default log level is INFO
        [ConsoleColor]$Color = [ConsoleColor]::White # Default color is White
    )

    switch ($Level) {
        'INFO' {
            $color = 'Cyan'
        }
        'WARNING' {
            $color = 'Yellow'
        }
        'ERROR' {
            $color = 'Red'
        }
        'SUCCESS' {
            $color = 'Green'
        }
        default {
            $color = $Color
        }
    }

    Write-Host "[$Level] $Message" -ForegroundColor $color
}

function Create-ModuleHelp {
	param (
		[string]
		$Module = "Entra"
	)

	$binPath = Join-Path (Split-Path -Parent $psscriptroot) (Get-ConfigValue -Name OutputPath)
	if(!(Test-Path $binPath)){
		New-Item -ItemType Directory -Path $binPath | Out-Null
	}
	$moduleDocsPath = Join-Path (Split-Path -Parent $psscriptroot) (Get-ConfigValue -Name ModuleSubdirectoryName)
	$moduleDocsPath = Join-Path ($moduleDocsPath) (Get-ConfigValue -Name docsPath)
	$moduleDocsPath = Join-Path ($moduleDocsPath) (Get-ConfigValue -Name ($Module + "Path"))
	New-ExternalHelp -Path $moduleDocsPath -OutputPath $binPath -Force
}
