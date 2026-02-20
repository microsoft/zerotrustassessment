param (
    [Parameter()]
    [string]
    $ModuleManifestPath = '{0}\..\src\powershell\ZeroTrustAssessment.psd1' -f (Split-Path -Parent $PSScriptRoot).TrimEnd([io.path]::DirectorySeparatorChar),

    [Parameter()]
    [string]
    $OutputPath = '{0}\..\output\RequiredModules' -f (Split-Path -Parent $PSScriptRoot).TrimEnd([io.path]::DirectorySeparatorChar),

    [Parameter()]
    [switch]
    $DoNotUpdatePSModulePath,

    [Parameter()]
    [switch]
    $SkipModuleInstallation,

    [Parameter()]
    [switch]
    $AllowPrerelease
)

if (-not (Test-Path -Path $OutputPath -PathType Container))
{
    Write-Verbose -Message "Output path not found: $OutputPath"
    $OutputPath =  (New-Item -Path $OutputPath -ItemType Directory -Force -ErrorAction Stop).FullName
    Write-Verbose -Message "Created output directory: $OutputPath"
}
else
{
    $OutputPath = (Get-Item -Path $OutputPath -ErrorAction Stop).FullName
    Write-Verbose -Message "Output path already exists: $OutputPath"
}

if (-not $DoNotUpdatePSModulePath.IsPresent)
{
    Write-Information -MessageData "Updating PSModulePath to include $OutputPath..."
    $modulePath = $env:PSModulePath.Split([System.IO.Path]::PathSeparator).ForEach{$_.TrimEnd([io.path]::DirectorySeparatorChar)}
    if ($OutputPath.TrimEnd([io.path]::DirectorySeparatorChar) -notin $modulePath)
    {
        Write-Verbose -Message "Adding $OutputPath to PSModulePath."
        $env:PSModulePath = (@($OutputPath) + $modulePath) -join [System.IO.Path]::PathSeparator
        Write-Verbose -Message "Updated PSModulePath to:`r`n$env:PSModulePath"
    }
    else
    {
        Write-Information -MessageData "PSModulePath already contains $OutputPath. No update needed."
    }
}

if (-not $SkipModuleInstallation.IsPresent)
{
    Write-Verbose -Message "Installing required modules to $OutputPath..."
    $moduleManifest = Import-PowerShellDataFile -Path $ModuleManifestPath -ErrorAction Stop
    [Microsoft.PowerShell.Commands.ModuleSpecification[]]$requiredModules = $moduleManifest.RequiredModules
    [Microsoft.PowerShell.Commands.ModuleSpecification[]]$externalModuleDependencies = $moduleManifest.PrivateData.ExternalModuleDependencies

    $requiredModuleToSave = $requiredModules.Where{$_.Name -notin $externalModuleDependencies.Name}

    if (-not $SkipModuleInstallation.IsPresent)
    {
        $saveModuleCmdParams = @{
            Path = $OutputPath
        }

        Write-Host -Object "`r`n"
        Write-Host -Object ('Resolving {0} dependencies...' -f $requiredModuleToSave.Count) -ForegroundColor Green

        if ($saveModuleCmd = (Get-Command -Name Save-PSResource -ErrorAction Ignore))
        {
            Write-Verbose -Message "Saving required modules using Save-PSResource..."
        }
        elseif ($saveModuleCmd = (Get-Command -Name Save-Module -ErrorAction Ignore))
        {
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
            $isModulePresent = Get-Module -FullyQualifiedName $moduleSpec -ListAvailable -ErrorAction Ignore

            if ($isModulePresent)
            {
                Write-Host -Object ('    ✅ Module {0} found (v{1}).' -f $moduleSpec.Name,$isModulePresent[0].Version) -ForegroundColor Green
                continue
            }

            try
            {
                if ($saveModuleCmd.Name -eq 'Save-PSResource')
                {
                    # To Save-PSResource we need to first Find-PSResource to get the latest available in given range.
                    $findModuleParams = @{
                        Name = $moduleSpec.Name
                        ErrorAction = 'Stop'
                        'Prerelease' = $AllowPrerelease.IsPresent
                    }

                    # Find-PSResource uses NuGet version range syntax: https://learn.microsoft.com/en-us/nuget/concepts/package-versioning?tabs=semver20sort#version-ranges
                    if ($moduleSpec.RequiredVersion) {
                        # Absolute required version
                        $findModuleParams['Version'] = '[{0}]' -f $moduleSpec.RequiredVersion
                    }
                    elseif ($moduleSpec.MaximumVersion -and $moduleSpec.Version) {
                        # Minimum and maximum version (exact range) inclusive
                        $findModuleParams['Version'] = '[{0},{1}]' -f $moduleSpec.Version, $moduleSpec.MaximumVersion
                    }
                    elseif ($moduleSpec.MaximumVersion) {
                        # Maximum version inclusive
                        $findModuleParams['Version'] = '(,{0}]' -f $moduleSpec.MaximumVersion
                    }
                    elseif ($moduleSpec.Version) {
                        # Minimum version inclusive
                         $findModuleParams['Version'] = '[{0}, )' -f $moduleSpec.Version
                    }

                    # Get the latest version of the module in the range specified in Module Specification.
                    $latestModuleInRange = Find-PSResource @findModuleParams -ErrorAction Stop | Sort-Object -Property Version -Descending | Select-Object -First 1

                    $savePSResourceParams = @{
                        Path = $OutputPath
                        PassThru = $true
                        ErrorAction = 'Stop'
                        TrustRepository = $true
                    }

                    $savedModule = ($latestModuleInRange | Save-PSResource @savePSResourceParams).Where({ $_.Name -eq $moduleSpec.Name },1)
                    Write-Host -Object ('    ⬇️ Module {0} v{1} saved successfully.' -f $moduleSpec.Name, $savedModule.Version) -ForegroundColor Green
                }
                elseif ($saveModuleCmd.Name -eq 'Save-Module')
                {
                    $saveModuleCmdParams = @{
                        ErrorAction = 'Stop'
                        Force = $true
                        Path = $OutputPath
                    }

                    $moduleSpec | &$saveModuleCmd @saveModuleCmdParams
                    Write-Host -Object ('    ⬇️ Module {0} saved successfully.' -f $moduleSpec.Name) -ForegroundColor Green
                }
            }
            catch
            {
                Write-Host -Object ('    ❌ Failed to save module {0}: {1}' -f $moduleSpec.Name, $_) -ForegroundColor Red
            }
        }

        Write-Host -Object "`r`n"
    }
}
else
{
    Write-Verbose -Message "Skipping module installation as per parameter. Required modules will not be saved to $OutputPath."
    return
}
