function Remove-ZtContainerEnvironment {
    <#
    .SYNOPSIS
        Cleans up container environment modifications made by Initialize-ZtContainerEnvironment.

    .DESCRIPTION
        Reverses modifications made during container auth setup:
        - Removes the xdg-open shim if it was created by this module
        - Removes the 127.0.0.1 localhost entry from /etc/hosts if it was added
        - Clears the readiness state variable

        Called automatically by Disconnect-ZtAssessment -IncludeCleanup.

    .EXAMPLE
        PS C:\> Remove-ZtContainerEnvironment

        Cleans up all container environment modifications.
    #>
    [CmdletBinding()]
    param ()

    $readiness = $script:ZtContainerAuthReadiness
    if (-not $readiness -or -not $readiness.IsContainer) {
        Write-PSFMessage -Message "No container environment modifications to clean up." -Level Debug
        return
    }

    Write-PSFMessage -Message "Cleaning up container environment modifications..." -Level Verbose

    #region Remove xdg-open shim
    $shimState = $readiness.BrowserShimState
    if ($shimState) {
        try {
            $shimPath = $shimState.ShimPath
            if ($shimPath -and (Test-Path $shimPath)) {
                # Use sudo -n only for system paths; user paths don't need elevation
                if ($shimPath -like '/usr/*') {
                    & sudo -n rm -f $shimPath 2>&1 > $null
                }
                else {
                    Remove-Item -Path $shimPath -Force -ErrorAction Stop
                }

                if (-not (Test-Path $shimPath)) {
                    Write-Host -Object '      ✅ Removed xdg-open shim.' -ForegroundColor Green
                    Write-PSFMessage -Message "Removed xdg-open shim at $shimPath." -Level Verbose
                }
                else {
                    Write-Host -Object '      ⚠️ Could not remove xdg-open shim.' -ForegroundColor Yellow
                    Write-PSFMessage -Message "Could not remove xdg-open shim at $shimPath." -Level Warning
                }
            }

            # Revert PATH addition if we added an entry
            if ($shimState.AddedPathEntry) {
                $env:PATH = ($env:PATH -split ':' | Where-Object { $_ -ne $shimState.AddedPathEntry }) -join ':'
                Write-PSFMessage -Message "Removed '$($shimState.AddedPathEntry)' from PATH." -Level Verbose
            }
        }
        catch {
            Write-Host -Object "      ⚠️ Error removing xdg-open shim: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-PSFMessage -Message "Error removing xdg-open shim: $_" -Level Debug
        }
    }
    #endregion

    #region Revert /etc/hosts modification
    if ($readiness.RepairedHosts) {
        try {
            $hostsContent = Get-Content '/etc/hosts' -ErrorAction Stop
            # Remove only the line we added (exact match)
            $filteredContent = $hostsContent | Where-Object { $_ -ne '127.0.0.1 localhost' }
            if ($filteredContent.Count -lt $hostsContent.Count) {
                $filteredContent | & sudo -n tee /etc/hosts > $null 2>&1
                Write-Host -Object '      ✅ Reverted /etc/hosts localhost entry.' -ForegroundColor Green
                Write-PSFMessage -Message "Removed '127.0.0.1 localhost' from /etc/hosts." -Level Verbose
            }
        }
        catch {
            Write-Host -Object "      ⚠️ Could not revert /etc/hosts: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-PSFMessage -Message "Error reverting /etc/hosts: $_" -Level Debug
        }
    }
    #endregion

    #region Clear readiness state
    $script:ZtContainerAuthReadiness = $null
    Write-PSFMessage -Message "Container environment cleanup complete." -Level Verbose
    #endregion
}
