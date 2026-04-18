function Initialize-ZtContainerBrowserShim {
    <#
    .SYNOPSIS
        Ensures xdg-open is available for MSAL's browser launch in container environments.
    .OUTPUTS
        [bool] True if a browser helper is available.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    # Reset shim tracking state
    $script:ZtBrowserShimState = $null

    $xdgOpen = Get-Command -Name 'xdg-open' -ErrorAction Ignore

    if ($xdgOpen) {
        Write-Host -Object '    ✅ Browser helper: xdg-open available.' -ForegroundColor Green
        Write-PSFMessage -Message "xdg-open found at '$($xdgOpen.Source)'." -Level Debug
        return $true
    }

    # Try $VSCODE_BROWSER first (set by VS Code remote), then $BROWSER
    $browserHelper = $null
    foreach ($envVar in @('VSCODE_BROWSER', 'BROWSER')) {
        $candidate = [System.Environment]::GetEnvironmentVariable($envVar)
        if (-not $candidate) { continue }

        # The variable may be a full path, a bare command name, or include arguments.
        # Extract the first token (the executable) for resolution.
        $tokens = $candidate -split '\s+', 2
        $exePath = $tokens[0]

        # Resolve via Get-Command (handles both paths and command names on PATH)
        $resolved = Get-Command -Name $exePath -ErrorAction Ignore
        if ($resolved) {
            $remainder = if ($tokens.Count -gt 1) { ' ' + $tokens[1] } else { '' }
            $browserHelper = "$($resolved.Source)$remainder"
            break
        }
        else {
            Write-PSFMessage -Message "Browser helper from `$$envVar ('$exePath') not found on PATH." -Level Debug
        }
    }

    if ($browserHelper) {
        Write-PSFMessage -Message "xdg-open not found. Creating shim from browser helper '$browserHelper'." -Level Verbose

        # Split the browser helper into executable and arguments so the shim
        # works correctly when $browserHelper contains spaces or extra args.
        $helperTokens = $browserHelper -split '\s+', 2
        $helperExe = $helperTokens[0]
        $helperArgs = if ($helperTokens.Count -gt 1) { $helperTokens[1] } else { '' }

        $shimContent = @"
#!/bin/sh
exec "$helperExe" $helperArgs "`$@"
"@

        try {
            $shimPath = '/usr/local/bin/xdg-open'
            $shimContent | & sudo -n tee $shimPath > $null 2>&1
            & sudo -n chmod +x $shimPath 2>&1 > $null
        }
        catch {
            Write-PSFMessage -Message "Failed to create system xdg-open shim: $_" -Level Debug
        }

        if (Get-Command -Name 'xdg-open' -ErrorAction Ignore) {
            Write-Host -Object '    ✅ Browser helper: created xdg-open shim.' -ForegroundColor Green
            $script:ZtBrowserShimState = @{ ShimPath = $shimPath; AddedPathEntry = $null }
            return $true
        }

        try {
            $userBinDir = Join-Path -Path $HOME -ChildPath '.local/bin'
            $userShimPath = Join-Path -Path $userBinDir -ChildPath 'xdg-open'

            if (-not (Test-Path -Path $userBinDir)) {
                $null = New-Item -Path $userBinDir -ItemType Directory -Force
            }

            Set-Content -Path $userShimPath -Value $shimContent -NoNewline
            & chmod +x $userShimPath 2>&1 > $null

            $addedPathEntry = $null
            $pathEntries = $env:PATH -split ':'
            if ($pathEntries -notcontains $userBinDir) {
                $env:PATH = "${userBinDir}:$($env:PATH)"
                $addedPathEntry = $userBinDir
            }
        }
        catch {
            Write-PSFMessage -Message "Failed to create user xdg-open shim: $_" -Level Debug
        }

        if (Get-Command -Name 'xdg-open' -ErrorAction Ignore) {
            Write-Host -Object '    ✅ Browser helper: created xdg-open shim.' -ForegroundColor Green
            $script:ZtBrowserShimState = @{ ShimPath = $userShimPath; AddedPathEntry = $addedPathEntry }
            return $true
        }

        Write-Host -Object "    ⚠️ Browser helper: could not create xdg-open shim, and `$BROWSER alone may not be sufficient." -ForegroundColor Yellow
        return $false
    }

    Write-Host -Object '    ❌ Browser helper: no xdg-open, $VSCODE_BROWSER, or $BROWSER available.' -ForegroundColor Red
    return $false
}
