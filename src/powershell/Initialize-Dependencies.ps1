# Initialize-Dependencies.ps1
# This script is run by the module manifest (ScriptsToProcess) before the module is imported.
# It ensures that dependencies are loaded in the correct order to avoid DLL conflicts.
# Specifically, ExchangeOnlineManagement and Az.Accounts/Graph both use Microsoft.Identity.Client.dll.
# We must ensure the oldest compatible version is loaded first, BEFORE any modules import.

# Wrapped in a scriptblock to prevent variable leakage into the user's session
& {
    Write-Verbose "=== Initialize-Dependencies.ps1 Starting ==="

    try {
        # Check if MSAL is already loaded
        $loadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetName().Name -eq 'Microsoft.Identity.Client' }

        if ($loadedAssemblies) {
            Write-Warning "MSAL assembly is already loaded. This may cause DLL conflicts."
            Write-Verbose "  Loaded versions:"
            foreach ($asm in $loadedAssemblies) {
                Write-Verbose "  - $($asm.GetName().Version) from $($asm.Location)"
            }
            Write-Verbose "  Recommendation: Restart PowerShell and import ZeroTrustAssessment first."
        }
        else {
            # Dot-source helper if it exists
            $helperPath = Join-Path $PSScriptRoot "private\utility\Get-ModuleImportOrder.ps1"

            if (Test-Path $helperPath) {
                . $helperPath

                # Define dependencies
                $requiredVersions = @{ 'ExchangeOnlineManagement' = '3.8.0' }

                $exoModule = Get-ModuleImportOrder -Name 'ExchangeOnlineManagement' -RequiredVersions $requiredVersions

                if ($exoModule -and $exoModule.DLLPath -and (Test-Path $exoModule.DLLPath)) {
                    Write-Verbose "Pre-loading MSAL from ExchangeOnlineManagement ($($exoModule.ModuleVersion))..."

                    # Load Main DLL
                    [System.Reflection.Assembly]::LoadFrom($exoModule.DLLPath) | Out-Null

                    # Load related DLLs (Brokers, etc.)
                    $msalDir = Split-Path $exoModule.DLLPath
                    Get-ChildItem -Path $msalDir -Filter "Microsoft.Identity.Client*.dll" -File | ForEach-Object {
                        if ($_.Name -ne "Microsoft.Identity.Client.dll") {
                            try {
                                [System.Reflection.Assembly]::LoadFrom($_.FullName) | Out-Null
                            }
                            catch {
                            }
                        }
                    }
                }
            }
            else {
                Write-Verbose "Get-ModuleImportOrder.ps1 not found. Skipping dependency pre-load."
            }
        }
    }
    catch {
        Write-Warning "Initialize-Dependencies.ps1 failed: $_"
    }

}
