function Install-ZtBrowserUrlCapture {
    <#
    .SYNOPSIS
        Installs a temporary xdg-open/open wrapper that captures the auth URL MSAL passes to the browser.
    .DESCRIPTION
        In container environments, MSAL opens the browser via xdg-open (Linux) or open (macOS) with a
        URL containing PKCE code_challenge, state, and a dynamic localhost port. This function creates
        a thin wrapper script that logs the URL to a temp file before forwarding to the real browser
        opener, enabling a clickable fallback link to be displayed in the terminal.
    .OUTPUTS
        [hashtable] State needed by Start-ZtBrowserUrlWatcher and Remove-ZtBrowserUrlCapture,
        or $null if the wrapper could not be installed.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    if (-not ($IsLinux -or $IsMacOS)) { return $null }

    $browserCmd = if ($IsLinux) { 'xdg-open' } else { 'open' }
    $realBrowserPath = & which $browserCmd 2>$null
    if (-not $realBrowserPath) {
        Write-PSFMessage -Message "Cannot install URL capture: '$browserCmd' not found on PATH." -Level Debug
        return $null
    }

    $authUrlFile = [System.IO.Path]::GetTempFileName()
    $wrapperDir  = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'zt-browser-wrapper'
    $null = New-Item -Path $wrapperDir -ItemType Directory -Force
    $wrapperPath = Join-Path -Path $wrapperDir -ChildPath $browserCmd

    # Wrapper: save the URL to the temp file, then call the real browser opener
    $wrapperContent = @"
#!/bin/bash
echo "`$1" > "$authUrlFile"
exec "$realBrowserPath" "`$@"
"@
    Set-Content -Path $wrapperPath -Value $wrapperContent -Force
    chmod +x $wrapperPath

    # Prepend wrapper dir to PATH so MSAL finds our wrapper first
    $env:PATH = "${wrapperDir}:$($env:PATH)"

    Write-PSFMessage -Message "Installed browser URL capture wrapper at $wrapperPath (real: $realBrowserPath)." -Level Debug

    return @{
        AuthUrlFile     = $authUrlFile
        WrapperPath     = $wrapperPath
        WrapperDir      = $wrapperDir
        RealBrowserPath = $realBrowserPath
    }
}

function Start-ZtBrowserUrlWatcher {
    <#
    .SYNOPSIS
        Starts a background PowerShell instance that watches for the captured auth URL and prints it.
    .DESCRIPTION
        After Install-ZtBrowserUrlCapture sets up the wrapper, call this function before
        Connect-MgGraph to start a background watcher. When MSAL invokes xdg-open, the wrapper
        writes the URL to a temp file, and the watcher detects it and prints it to the console
        as a clickable fallback link.
    .PARAMETER CaptureState
        The hashtable returned by Install-ZtBrowserUrlCapture.
    .OUTPUTS
        [powershell] The background PowerShell instance (dispose it during cleanup).
    #>
    [CmdletBinding()]
    [OutputType([powershell])]
    param (
        [Parameter(Mandatory)]
        [hashtable] $CaptureState
    )

    $watcher = [powershell]::Create()
    $null = $watcher.AddScript({
        param($authUrlFile)
        for ($i = 0; $i -lt 100; $i++) {
            Start-Sleep -Milliseconds 100
            if ((Test-Path $authUrlFile) -and (Get-Item $authUrlFile).Length -gt 0) {
                $capturedUrl = (Get-Content -Path $authUrlFile -Raw).Trim()
                if ($capturedUrl -match '^https://') {
                    [Console]::WriteLine("   If the browser did not open, copy and paste this link:")
                    [Console]::WriteLine("   `u{1f517} $capturedUrl")
                }
                break
            }
        }
    }).AddArgument($CaptureState.AuthUrlFile)
    $null = $watcher.BeginInvoke()

    return $watcher
}

function Remove-ZtBrowserUrlCapture {
    <#
    .SYNOPSIS
        Cleans up the browser URL capture wrapper, temp file, and background watcher.
    .DESCRIPTION
        Reverses the PATH modification, removes the wrapper directory and temp file,
        and disposes the background PowerShell watcher. Call this in a finally block
        after Connect-MgGraph completes.
    .PARAMETER CaptureState
        The hashtable returned by Install-ZtBrowserUrlCapture. May be $null (no-op).
    .PARAMETER Watcher
        The PowerShell instance returned by Start-ZtBrowserUrlWatcher. May be $null (no-op).
    #>
    [CmdletBinding()]
    param (
        [AllowNull()]
        [hashtable] $CaptureState,

        [AllowNull()]
        [powershell] $Watcher
    )

    if ($CaptureState) {
        if ($CaptureState.WrapperDir) {
            $env:PATH = ($env:PATH -split ':' | Where-Object { $_ -ne $CaptureState.WrapperDir }) -join ':'
            Remove-Item -Path $CaptureState.WrapperDir -Recurse -Force -ErrorAction Ignore
        }
        if ($CaptureState.AuthUrlFile) {
            Remove-Item -Path $CaptureState.AuthUrlFile -Force -ErrorAction Ignore
        }
        Write-PSFMessage -Message "Removed browser URL capture wrapper." -Level Debug
    }

    if ($Watcher) {
        $Watcher.Dispose()
    }
}
