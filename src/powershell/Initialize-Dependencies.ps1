param (
    [Parameter()]
    [string]
    $ModuleManifestPath,

    [Parameter()]
    [string]
    $RequiredModulesPath,

    [Parameter()]
    [switch]
    $SkipModuleInstallation,

    [Parameter()]
    [switch]
    $SkipLoadMSAL,

    [Parameter()]
    [switch]
    $DoNotUpdatePSModulePath
)

# Initialize-Dependencies.ps1
# This script is run by the module manifest (ScriptsToProcess) before the module is imported.
# It ensures that dependencies are loaded in the correct order to avoid DLL conflicts.
# Specifically, ExchangeOnlineManagement and Az.Accounts/Graph both use Microsoft.Identity.Client.dll.
# It also updates the PSModulePath to include the directory where dependencies are saved,
# and saves required modules if they are not already present.
function Initialize-Dependencies {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ModuleManifestPath = (Join-Path -Path $PSScriptRoot -ChildPath "ZeroTrustAssessment.psd1" -Resolve -ErrorAction Stop),

        [Parameter()]
        [string]
        $RequiredModulesPath = $(
            if ($IsLinux -or $IsMacOS) {
                Join-Path -Path $env:HOME -ChildPath ".cache/ZeroTrustAssessment/Modules"
            }
            else {
                Join-Path -Path $env:APPDATA -ChildPath "ZeroTrustAssessment\Modules"
            }
        ),

        [Parameter()]
        [switch]
        $AllowPrerelease,

        [Parameter()]
        [switch]
        $SkipModuleInstallation,

        [Parameter()]
        [switch]
        $SkipLoadMSAL= ($Env:SkipLoadMSAL -eq 'true' -or $Env:SkipLoadMSAL -eq '1'),

        [Parameter()]
        [switch]
        $DoNotUpdatePSModulePath
    )

    Write-Verbose -Message "=== Initialize-Dependencies.ps1 Starting ==="

    #region Prepend $Env:PSModulePath with ~\AppData|.cache\ZeroTrustAssessment\Modules
    Write-Verbose -Message ("Setting $Env:PSModulePath to include the {0} for module dependencies..." -f $RequiredModulesPath)
    if (-not (Test-Path -Path $RequiredModulesPath -PathType Container))
    {
        Write-Verbose -Message "RequiredModulesPath path not found: $RequiredModulesPath"
        $RequiredModulesPath =  (New-Item -Path $RequiredModulesPath -ItemType Directory -Force -ErrorAction Stop).FullName
        Write-Verbose -Message "Created output directory: $RequiredModulesPath"
    }
    else
    {
        $RequiredModulesPath = (Get-Item -Path $RequiredModulesPath -ErrorAction Stop).FullName
        Write-Verbose -Message "RequiredModulesPath path already exists: $RequiredModulesPath"
    }

    if (-not $DoNotUpdatePSModulePath.IsPresent)
    {
        Write-Verbose -Message "Updating PSModulePath to include $RequiredModulesPath..."
        $modulePath = $env:PSModulePath.Split([System.IO.Path]::PathSeparator).ForEach{$_.TrimEnd([io.path]::DirectorySeparatorChar)}
        if ($RequiredModulesPath.TrimEnd([io.path]::DirectorySeparatorChar) -notin $modulePath)
        {
            Write-Debug -Message "Adding $RequiredModulesPath to PSModulePath."
            $env:PSModulePath = (@($RequiredModulesPath) + $modulePath) -join [System.IO.Path]::PathSeparator
            Write-Debug -Message "Updated PSModulePath to:`r`n$env:PSModulePath"
        }
        else
        {
            Write-Debug -Message "PSModulePath already contains $RequiredModulesPath. No update needed."
        }
    }
    #endregion

    #region Load module Manifest
    $moduleManifest = Import-PowerShellDataFile -Path $ModuleManifestPath -ErrorAction Stop
    [Microsoft.PowerShell.Commands.ModuleSpecification[]]$requiredModules = $moduleManifest.RequiredModules
    [Microsoft.PowerShell.Commands.ModuleSpecification[]]$externalModuleDependencies = $moduleManifest.PrivateData.ExternalModuleDependencies
    [Microsoft.PowerShell.Commands.ModuleSpecification[]]$windowsPowerShellRequiredModules = @(
        @{ModuleName = 'ExchangeOnlineManagement'; GUID = 'b5eced50-afa4-455b-847a-d8fb64140a22'; ModuleVersion = '3.9.2'; },     # Works on PS7
        @{ModuleName = 'Microsoft.Online.SharePoint.PowerShell'; GUID = 'adedde5f-e77b-4682-ab3d-a4cb4ff79b83'; ModuleVersion = '16.0.26914.12004'; },
        @{ModuleName = 'AipService'; GUID = 'e338ccc0-3333-4479-87fe-66382d33782d'; ModuleVersion = '3.0.0.1'; }
    ) #TODO: This needs a fix in the build process.

    $allModuleDependencies = @($requiredModules) + @($externalModuleDependencies) + @($windowsPowerShellRequiredModules)
    $requiredModuleToSave = $requiredModules.Where{$_.Name -notin $externalModuleDependencies.Name}
    $requiredModuleToSave += $windowsPowerShellRequiredModules.Where{ $_.Name -notin $requiredModules.Name -and $_.Name -notin $externalModuleDependencies.Name }
    #endregion

    if ($IsMacOS -or $IsLinux)
    {
        #region The ZeroTrustAssessment report should be run in Windows.
        # on Non-windows platform, some pillars won't be available, because some required modules only work on Windows PowerShell.
        Write-Host -Object "`r`n" -ForegroundColor Yellow
        Write-Host -Object '⚠️ Warning: The ZeroTrustAssessment module is designed to run on Windows, in PowerShell 7.'
        Write-Host -Object 'Some pillars require modules that can only run on Windows PowerShell (Windows PowerShell 5.1) with implicit remoting.' -ForegroundColor Yellow
        # skipping module installation.
        #endregion
    }
    elseif (-not $SkipModuleInstallation.IsPresent)
    {
        Write-Host -Object "`r`n"
        Write-Host -Object 'Resolving dependencies...' -ForegroundColor Green

        $saveModuleCmdParams = @{
            Path = $RequiredModulesPath
        }

        if ($saveModuleCmd = (Get-Command -Name Save-PSResource -ErrorAction Ignore))
        {
            $saveModuleCmdParams.Add('TrustRepository', $true)
            $saveModuleCmdParams.Add('Prerelease', $AllowPrerelease.IsPresent)
            Write-Verbose -Message "Saving required modules using Save-PSResource..."
        }
        elseif ($saveModuleCmd = (Get-Command -Name Save-Module -ErrorAction Ignore))
        {
            $saveModuleCmdParams.Add('Force', $true)
            $saveModuleCmdParams.Add('AllowPrerelease', $AllowPrerelease.IsPresent)
            Write-Verbose -Message "Saving required modules using Save-Module..."
        }
        else
        {
            Write-Error -Message 'Neither Save-PSResource nor Save-Module is available. Please install the PowerShellGet module to save required modules.'
            return
        }

        foreach ($moduleSpec in $requiredModuleToSave)
        {
            Write-Verbose -Message ("Saving module {0} with version {1}..." -f $moduleSpec.Name, $moduleSpec.Version)
            $saveModuleCmdParamsClone = $saveModuleCmdParams.Clone()
            $isModulePresent = Get-Module -FullyQualifiedName $moduleSpec -ListAvailable -ErrorAction Ignore

            if ($isModulePresent)
            {
                Write-Host -Object ('    ✅ Module {0} found (v{1}).' -f $moduleSpec.Name,$isModulePresent[0].Version) -ForegroundColor Green
                continue
            }

            try
            {
                $saveModuleCmdParamsClone['Name'] = $moduleSpec.Name
                if ($moduleSpec.Version -and $saveModuleCmd.Name -eq 'Save-Module')
                {
                    $saveModuleCmdParamsClone['MinimumVersion'] = $moduleSpec.Version
                }
                elseif ($moduleSpec.Version -and $saveModuleCmd.Name -eq 'Save-PSResource')
                {
                    $saveModuleCmdParamsClone['Version'] = '[{0}, ]' -f $moduleSpec.Version
                }

                & $saveModuleCmd @saveModuleCmdParamsClone
                Write-Host -Object ('    ⬇️ Module {0} saved successfully.' -f $moduleSpec.Name) -ForegroundColor Green
            }
            catch
            {
                Write-Host -Object ('    ❌ Failed to save module {0}: {1}' -f $moduleSpec.Name, $_) -ForegroundColor Red
            }
        }
    }

    try {
        # Check if MSAL is already loaded
        $loadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetName().Name -eq 'Microsoft.Identity.Client' }

        if ($loadedAssemblies) {
            Write-Warning -Message "MSAL assembly is already loaded. This may cause DLL conflicts."
            Write-Verbose -Message "  Loaded versions:"
            foreach ($asm in $loadedAssemblies) {
                Write-Verbose -Message ("  - {0} from {1}" -f $asm.GetName().Version, $asm.Location)
            }

            Write-Verbose -Message "  Recommendation: Restart PowerShell and import ZeroTrustAssessment first."
        }
        else {
            Write-Host -Object "`r`n"
            Write-Host -Object 'Asserting MSAL loading order for dependencies...' -ForegroundColor Green
            $helperPath = Join-Path -Path $PSScriptRoot -ChildPath "private\utility\Get-ModuleImportOrder.ps1" -Resolve -ErrorAction Stop
            . $helperPath
            Write-Verbose -Message ('Module with DLLs to load: {0}' -f (([Microsoft.PowerShell.Commands.ModuleSpecification[]]$moduleManifest.RequiredModules).Name -join ', '))
            # This method does not necessarily load the right dll (it ignores the load logic from the modules)
            $msalToLoadInOrder = Get-ModuleImportOrder -Name $allModuleDependencies.Name

            $msalToLoadInOrder.ForEach{
                Write-Verbose -Message ('Loading MSAL v{0} for dependency {1} version {2}' -f $_.DLLVersion, $_.Name, $_.ModuleVersion)
                if ([System.AppDomain]::CurrentDomain.GetAssemblies().Where{$_.GetName().Name -eq 'Microsoft.Identity.Client'}) {
                    Write-Verbose -Message ("MSAL v{0} is already loaded, skipping." -f $_.DLLVersion)
                }
                else
                {
                    Write-Host -Object ('    ✅ Loading MSAL v{0} for dependency {1} version {2}' -f $_.DLLVersion, $_.Name, $_.ModuleVersion) -ForegroundColor Green
                    $null = [System.Reflection.Assembly]::LoadFrom($_.DLLPath)
                }

                $brokerInteropToLoad = Get-ChildItem -Path (Split-Path -Path $_.DLLPath) -Filter "Microsoft.Identity.Client*.dll" -File | Where-Object { $_.Name -ne "Microsoft.Identity.Client.dll" }
                foreach ($broker in $brokerInteropToLoad)
                {
                    Write-Debug -Message ('Loading related MSAL broker/interop assembly {0}' -f $broker.Name)
                    try
                    {
                        $null = [System.Reflection.Assembly]::LoadFrom($broker.FullName)
                        Write-Host -Object ('    ✅ Loaded {0}' -f $broker.Name) -ForegroundColor Green
                    }
                    catch
                    {
                        Write-Debug -Message ("Failed to load related MSAL assembly {0}: {1}" -f $broker.FullName, $_)
                    }
                }
            }
        }
    }
    catch {
        Write-Warning -Message ("Initialize-Dependencies.ps1 failed: {0}" -f $_)
    }
}

Initialize-Dependencies @PSBoundParameters
