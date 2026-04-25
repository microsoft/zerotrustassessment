function Test-ZtLocalhostResolution {
    <#
    .SYNOPSIS
        Checks that localhost resolves to 127.0.0.1 (IPv4), which MSAL needs for its callback listener.
    .DESCRIPTION
        In many containers, /etc/hosts maps localhost only to ::1 (IPv6).
        MSAL's callback listener and VS Code port forwarding both need IPv4 127.0.0.1.
    .OUTPUTS
        [bool] True if localhost resolves to 127.0.0.1.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    try {
        $addresses = [System.Net.Dns]::GetHostAddresses('localhost')
        $hasIPv4 = $addresses | Where-Object { $_.AddressFamily -eq 'InterNetwork' -and $_.ToString() -eq '127.0.0.1' }

        if ($hasIPv4) {
            Write-Host -Object '    ✅ Localhost: resolves to 127.0.0.1 (IPv4).' -ForegroundColor Green
            return $true
        }

        $resolvedAddrs = ($addresses | ForEach-Object { $_.ToString() }) -join ', '
        Write-Host -Object "    ⚠️ Localhost: resolves to [$resolvedAddrs] but not 127.0.0.1 (IPv4)." -ForegroundColor Yellow
        return $false
    }
    catch {
        Write-Host -Object "    ⚠️ Localhost: DNS resolution failed: $_" -ForegroundColor Yellow
        return $false
    }
}
