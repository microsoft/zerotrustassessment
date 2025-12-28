# Initialize-Dependencies.ps1
# This script is run by the module manifest (ScriptsToProcess) before the module is imported.
# It ensures that dependencies are loaded in the correct order to avoid DLL conflicts.
# Specifically, ExchangeOnlineManagement and Az.Accounts/Graph both use Microsoft.Identity.Client.dll.
# We must ensure the oldest compatible version is loaded first, BEFORE any modules import.

Write-Host "=== Initialize-Dependencies.ps1 Starting ===" -ForegroundColor Cyan

try {
    # Check if MSAL is already loaded
    $loadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetName().Name -eq 'Microsoft.Identity.Client' }

    if ($loadedAssemblies) {
        Write-Host "MSAL assembly is already loaded in the current session:" -ForegroundColor Yellow
        foreach ($asm in $loadedAssemblies) {
            $loadedVersion = $asm.GetName().Version
            Write-Host "  Version $loadedVersion from $($asm.Location)" -ForegroundColor Yellow
        }
        Write-Host "" -ForegroundColor Yellow
        Write-Host "This will cause DLL conflicts. To fix:" -ForegroundColor Red
        Write-Host "  1. Close this PowerShell session" -ForegroundColor Cyan
        Write-Host "  2. Open a NEW PowerShell session" -ForegroundColor Cyan
        Write-Host "  3. Import ZeroTrustAssessment FIRST before any other modules" -ForegroundColor Cyan
        Write-Host "" -ForegroundColor Yellow
    } else {
        Write-Host "MSAL not yet loaded - proceeding with pre-load" -ForegroundColor Green

        # Dot-source the helper function to determine proper module import order
        $helperPath = "$PSScriptRoot\private\utility\Get-ModuleImportOrder.ps1"
        Write-Host "Loading helper from: $helperPath" -ForegroundColor Gray

        if (-not (Test-Path $helperPath)) {
            Write-Error "Cannot find Get-ModuleImportOrder.ps1 at $helperPath"
            return
        }

        . $helperPath

        # Define dependencies and their required versions
        $dependencies = @('Az.Accounts', 'ExchangeOnlineManagement', 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Beta.Teams')
        $requiredVersions = @{
            'ExchangeOnlineManagement' = '3.8.0'
        }

        # CRITICAL: ExchangeOnlineManagement must be loaded FIRST due to its specific Broker DLL requirements
        # Even if other modules have newer MSAL versions, Exchange needs its specific Broker extensions
        Write-Host "Looking for ExchangeOnlineManagement module..." -ForegroundColor Gray
        $exoModule = Get-ModuleImportOrder -Name 'ExchangeOnlineManagement' -RequiredVersions $requiredVersions

        if ($exoModule) {
            Write-Host "Loading MSAL and Broker from ExchangeOnlineManagement v$($exoModule.ModuleVersion)" -ForegroundColor Green

            if ($exoModule.DLLPath -and (Test-Path $exoModule.DLLPath)) {
                Write-Host "Explicitly loading MSAL assembly from: $($exoModule.DLLPath)" -ForegroundColor Cyan
                $loadedAsm = [System.Reflection.Assembly]::LoadFrom($exoModule.DLLPath)
                Write-Host "Successfully loaded MSAL DLL version $($loadedAsm.GetName().Version)" -ForegroundColor Green

                # Load ALL Microsoft.Identity.Client related DLLs from Exchange's directory
                $msalDirectory = Split-Path $exoModule.DLLPath
                $relatedDlls = Get-ChildItem -Path $msalDirectory -Filter "Microsoft.Identity.Client*.dll" -File

                foreach ($dll in $relatedDlls) {
                    if ($dll.Name -ne "Microsoft.Identity.Client.dll") {
                        Write-Host "Loading related assembly: $($dll.Name)" -ForegroundColor Gray
                        try {
                            [System.Reflection.Assembly]::LoadFrom($dll.FullName) | Out-Null
                            Write-Host "  Successfully loaded $($dll.Name)" -ForegroundColor Green
                        } catch {
                            Write-Host "  Failed to load $($dll.Name): $_" -ForegroundColor Yellow
                        }
                    }
                }
            } else {
                Write-Warning "Could not find Microsoft.Identity.Client.dll for ExchangeOnlineManagement at $($exoModule.DLLPath)"
            }
        } else {
            Write-Warning "ExchangeOnlineManagement 3.8.0 or higher not found. MSAL DLL conflict will occur."
        }
    }
    Write-Host "=== Initialize-Dependencies.ps1 Complete ===" -ForegroundColor Cyan
}
catch {
    Write-Host "=== Initialize-Dependencies.ps1 FAILED ===" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    # Don't throw - let RequiredModules try to proceed
}
