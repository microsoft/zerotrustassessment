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
    # [Microsoft.PowerShell.Commands.ModuleSpecification[]]$windowsPowerShellRequiredModules = $moduleManifest.PrivateData.WindowsPowerShellRequiredModules

    $requiredModuleToSave = $requiredModules.Where{$_.Name -notin $externalModuleDependencies.Name}
    # $requiredModuleToSave += $windowsPowerShellRequiredModules.Where{ $_.Name -notin $requiredModules.Name -and $_.Name -notin $externalModuleDependencies.Name }

    if (-not $SkipModuleInstallation.IsPresent)
    {
        Write-Host -Object "`r`n"
        Write-Host -Object 'Resolving dependencies...' -ForegroundColor Green

        $saveModuleCmdParams = @{
            Path = $OutputPath
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
            $isModulePresent = Get-Module -Name $moduleSpec.Name -ListAvailable -ErrorAction Ignore | Where-Object {
                $isValid = $true
                if ($moduleSpec.Guid)
                {
                    $isValid = $_.Guid -eq $moduleSpec.Guid
                }

                if ($moduleSpec.Version)
                {
                    $isValid = $isValid -and $_.Version -ge [Version]$moduleSpec.Version
                }
                elseif ($moduleSpec.RequiredVersion)
                {
                    $isValid = $isValid -and $_.Version -eq [Version]$moduleSpec.RequiredVersion
                }

                $isValid
            }

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

}
else
{
    Write-Verbose -Message "Skipping module installation as per parameter. Required modules will not be saved to $OutputPath."
    return
}
