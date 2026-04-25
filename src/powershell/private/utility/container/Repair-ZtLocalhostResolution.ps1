function Repair-ZtLocalhostResolution {
    <#
    .SYNOPSIS
        Attempts to add 127.0.0.1 localhost to /etc/hosts if missing.
    .OUTPUTS
        [bool] True if repair succeeded.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    Write-PSFMessage -Message "Attempting to add '127.0.0.1 localhost' to /etc/hosts..." -Level Verbose

    try {
        $hostsContent = Get-Content '/etc/hosts' -Raw -ErrorAction Stop

        if ($hostsContent -match '(?m)^\s*127\.0\.0\.1\s+.*localhost') {
            Write-PSFMessage -Message "/etc/hosts already has 127.0.0.1 localhost but DNS didn't resolve it. May be overridden." -Level Debug
            return $false
        }

        # Add IPv4 localhost entry
        '127.0.0.1 localhost' | & sudo -n tee -a /etc/hosts > $null 2>&1

        # Verify the fix worked
        $addresses = [System.Net.Dns]::GetHostAddresses('localhost')
        $hasIPv4 = $addresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' -and $_.ToString() -eq '127.0.0.1' }

        if ($hasIPv4) {
            Write-Host -Object '    ✅ Localhost: repaired — added 127.0.0.1 to /etc/hosts.' -ForegroundColor Green
            return $true
        }

        # .NET caches DNS. Try a fresh resolution via external tool.
        $getentResult = & getent hosts localhost 2>&1
        if ($getentResult -match '127\.0\.0\.1') {
            Write-Host -Object '    ✅ Localhost: repaired — 127.0.0.1 added (DNS cache may delay effect).' -ForegroundColor Green
            return $true
        }

        Write-Host -Object '    ⚠️ Localhost: repair attempted but 127.0.0.1 still not resolving.' -ForegroundColor Yellow
        return $false
    }
    catch {
        Write-PSFMessage -Message "Failed to repair /etc/hosts: $_" -Level Debug
        Write-Host -Object '    ⚠️ Localhost: could not modify /etc/hosts.' -ForegroundColor Yellow
        return $false
    }
}
