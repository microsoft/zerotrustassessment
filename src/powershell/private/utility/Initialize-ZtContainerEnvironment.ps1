function Initialize-ZtContainerEnvironment {
    <#
    .SYNOPSIS
        Detects dev container / remote environments and sets up browser auth compatibility.

    .DESCRIPTION
        When running inside a dev container (e.g. VS Code Remote Containers, Codespaces, or Docker),
        interactive browser authentication requires several dependencies to work correctly:

        1. An xdg-open command that routes to the host browser (via $BROWSER or $VSCODE_BROWSER)
        2. Network connectivity to Microsoft auth endpoints
        3. Correct localhost resolution (IPv4 127.0.0.1) for MSAL callback
        4. Port forwarding capability for the MSAL callback listener

        This function checks each dependency, attempts recovery if a check fails,
        and records what works so Connect-ZtAssessment can decide whether to use
        browser auth or fall back to device code flow.

        It is called automatically during Connect-ZtAssessment on non-Windows platforms.

    .EXAMPLE
        PS C:\> Initialize-ZtContainerEnvironment

        Detects and configures the container environment for browser-based auth.
    #>
    [CmdletBinding()]
    param ()

    # Only relevant on non-Windows
    if ($IsWindows) { return }

    $isContainer = Test-ZtContainerEnvironment

    if (-not $isContainer) {
        Write-PSFMessage -Message "Not running in a container environment. No shims needed." -Level Debug
        # Non-container environments should work with browser auth out of the box.
        $script:ZtContainerAuthReadiness = @{ IsContainer = $false; BrowserAuthReady = $true; Issues = @() }
        return
    }

    Write-PSFMessage -Message "Container environment detected. Checking browser auth dependencies..." -Level Verbose
    Write-Host -Object "`n🔍 Container environment detected. Checking auth dependencies..." -ForegroundColor Cyan

    $issues = [System.Collections.Generic.List[string]]::new()
    $browserAuthReady = $true
    $xdgOpenExisted = [bool](Get-Command -Name 'xdg-open' -ErrorAction Ignore)

    #region 1. Check xdg-open / browser helper
    $browserOk = Initialize-ZtContainerBrowserShim
    if (-not $browserOk) {
        $issues.Add('No browser helper available (xdg-open or $BROWSER). Cannot open auth URLs.')
        $browserAuthReady = $false
    }
    #endregion

    #region 2. Check network connectivity to Microsoft auth endpoints
    $authEndpointOk = Test-ZtAuthEndpointConnectivity
    if (-not $authEndpointOk) {
        $issues.Add('Cannot reach Microsoft authentication endpoints (login.microsoftonline.com).')
        $browserAuthReady = $false
    }
    #endregion

    #region 3. Check localhost resolution (IPv4 must be present for MSAL callback)
    $originalLocalhostOk = Test-ZtLocalhostResolution
    $localhostOk = $originalLocalhostOk
    if (-not $localhostOk) {
        # Attempt recovery: add 127.0.0.1 localhost to /etc/hosts
        $localhostOk = Repair-ZtLocalhostResolution
        if (-not $localhostOk) {
            $issues.Add('localhost does not resolve to 127.0.0.1 (IPv4). MSAL callback may fail.')
            # This is a warning, not a hard block — MSAL may still work on some setups
        }
    }
    #endregion

    #region 4. Check port forwarding capability
    $portForwardOk = Test-ZtPortForwarding
    if (-not $portForwardOk) {
        $issues.Add('Port forwarding test failed. MSAL callback listener may not be reachable from the browser.')
        # Don't block on this — it's a best-effort check
    }
    #endregion

    #region Summary
    if ($issues.Count -eq 0) {
        Write-Host -Object '    ✅ All browser auth dependencies satisfied.' -ForegroundColor Green
    }
    else {
        foreach ($issue in $issues) {
            Write-Host -Object "    ⚠️ $issue" -ForegroundColor Yellow
        }
        if (-not $browserAuthReady) {
            Write-Host -Object '    ℹ️ Device code flow will be recommended as fallback.' -ForegroundColor DarkGray
        }
    }
    Write-Host
    #endregion

    # Store results for Connect-ZtAssessment and cleanup to use
    $script:ZtContainerAuthReadiness = @{
        IsContainer        = $true
        BrowserAuthReady   = $browserAuthReady
        Issues             = $issues.ToArray()
        BrowserOk          = $browserOk
        AuthEndpointOk     = $authEndpointOk
        LocalhostOk        = $localhostOk
        PortForwardOk      = $portForwardOk
        # Track modifications for cleanup
        CreatedXdgOpenShim = (-not $xdgOpenExisted -and (Test-Path '/usr/local/bin/xdg-open' -ErrorAction Ignore))
        RepairedHosts      = (-not $originalLocalhostOk -and $localhostOk)
    }
}

function Resolve-ZtContainerAuthMethod {
    <#
    .SYNOPSIS
        Determines whether to use device code flow based on container auth readiness.
    .DESCRIPTION
        In container environments, browser authentication may not work due to missing
        dependencies (xdg-open, port forwarding, localhost resolution, etc.).
        This function checks the readiness state from Initialize-ZtContainerEnvironment
        and decides whether to switch to device code flow, prompt the user, or proceed
        with browser auth.

        Returns $true if device code flow should be used, $false otherwise.
    .PARAMETER DeviceLoginUrl
        The device login URL to display to the user (varies by cloud environment).
    .OUTPUTS
        [bool] True if device code flow should be used.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [string] $DeviceLoginUrl
    )

    $authReadiness = $script:ZtContainerAuthReadiness

    if (-not $authReadiness -or -not $authReadiness.IsContainer) {
        return $false
    }

    if (-not $authReadiness.BrowserAuthReady) {
        # Hard dependencies failed — browser auth won't work at all
        Write-Host
        Write-Host -Object '   📱 Container detected. Browser auth is not available:' -ForegroundColor Cyan
        foreach ($issue in $authReadiness.Issues) {
            Write-Host -Object "      • $issue" -ForegroundColor Yellow
        }
        Write-Host -Object '   Switching to device code flow automatically.' -ForegroundColor Yellow
        Write-Host -Object "   🔗 Open ${DeviceLoginUrl} and enter the code shown below." -ForegroundColor Yellow
        Write-Host
        return $true
    }
    elseif ($authReadiness.Issues.Count -gt 0) {
        # Some checks had warnings but browser auth may still work.
        # Prompt so the user can choose device code if they prefer.
        Write-Host
        Write-Host -Object '   📱 Container/Codespace environment detected.' -ForegroundColor Cyan
        foreach ($issue in $authReadiness.Issues) {
            Write-Host -Object "      ⚠️ $issue" -ForegroundColor Yellow
        }
        Write-Host -Object '   Browser auth may hang if the callback cannot reach this container.' -ForegroundColor Yellow
        Write-Host -Object "   Device code flow is recommended (enter a code at ${DeviceLoginUrl})." -ForegroundColor Yellow
        Write-Host
        $choice = Read-Host -Prompt '   Use device code flow? [Y/n]'
        if ($choice -ne 'n' -and $choice -ne 'N') {
            return $true
        }
        return $false
    }
    else {
        # All dependency checks passed — proceed with browser auth.
        Write-PSFMessage -Message "Container detected but all browser auth dependency checks passed. Using browser auth." -Level Verbose
        return $false
    }
}

function Get-ZtContainerAuthFailureHint {
    <#
    .SYNOPSIS
        Returns a user-friendly hint when Graph auth succeeds but no context is established.
    .DESCRIPTION
        When Connect-MgGraph completes without error but Get-MgContext returns null,
        this typically means the MSAL callback (browser redirect to localhost) did not
        reach the container. This function returns an appropriate message based on
        whether the session is running in a container.
    .OUTPUTS
        [string] A hint message suggesting next steps.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param ()

    $msg = "Connect-MgGraph completed but no auth context was established."

    $authReadiness = $script:ZtContainerAuthReadiness
    if ($authReadiness -and $authReadiness.IsContainer) {
        $msg += " The browser authentication callback may not have reached this container. Try using device code flow: Connect-ZtAssessment -UseDeviceCode"
    }

    return $msg
}

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

    $xdgOpen = Get-Command -Name 'xdg-open' -ErrorAction Ignore
    $browserHelper = $env:BROWSER

    if ($xdgOpen) {
        Write-Host -Object '    ✅ Browser helper: xdg-open available.' -ForegroundColor Green
        Write-PSFMessage -Message "xdg-open found at '$($xdgOpen.Source)'." -Level Debug
        return $true
    }

    if ($browserHelper -and (Test-Path $browserHelper)) {
        Write-PSFMessage -Message "xdg-open not found. Creating shim from `$BROWSER='$browserHelper'." -Level Verbose

        $shimContent = @"
#!/bin/sh
exec "$browserHelper" "`$@"
"@

        try {
            $shimPath = '/usr/local/bin/xdg-open'
            $shimContent | & sudo tee $shimPath > $null 2>&1
            & sudo chmod +x $shimPath 2>&1 > $null
        }
        catch {
            Write-PSFMessage -Message "Failed to create system xdg-open shim: $_" -Level Debug
        }

        if (Get-Command -Name 'xdg-open' -ErrorAction Ignore) {
            Write-Host -Object '    ✅ Browser helper: created xdg-open shim.' -ForegroundColor Green
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

            $pathEntries = $env:PATH -split ':'
            if ($pathEntries -notcontains $userBinDir) {
                $env:PATH = "$userBinDir:$($env:PATH)"
            }
        }
        catch {
            Write-PSFMessage -Message "Failed to create user xdg-open shim: $_" -Level Debug
        }

        if (Get-Command -Name 'xdg-open' -ErrorAction Ignore) {
            Write-Host -Object '    ✅ Browser helper: created xdg-open shim.' -ForegroundColor Green
            return $true
        }

        Write-Host -Object "    ⚠️ Browser helper: could not create xdg-open shim, and `$BROWSER alone may not be sufficient." -ForegroundColor Yellow
        return $false
    }

    Write-Host -Object '    ❌ Browser helper: no xdg-open or $BROWSER available.' -ForegroundColor Red
    return $false
}

function Test-ZtAuthEndpointConnectivity {
    <#
    .SYNOPSIS
        Tests network connectivity to Microsoft authentication endpoints.
    .OUTPUTS
        [bool] True if auth endpoints are reachable.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    # Only the auth endpoint is required for authentication.
    # Graph endpoint is tested separately as a warning (used later, not for auth).
    $authEndpoint = 'https://login.microsoftonline.com'

    try {
        $response = Invoke-WebRequest -Uri $authEndpoint -Method Head -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        Write-Host -Object '    ✅ Network: Microsoft auth endpoint reachable.' -ForegroundColor Green
        Write-PSFMessage -Message "Connectivity to $authEndpoint : OK ($($response.StatusCode))" -Level Debug
    }
    catch {
        Write-Host -Object "    ❌ Network: cannot reach $authEndpoint" -ForegroundColor Red
        Write-PSFMessage -Message "Connectivity to $authEndpoint failed: $_" -Level Debug
        return $false
    }

    # Graph endpoint: only log at debug level, don't show to user during auth setup.
    # Graph reachability is irrelevant for authentication and will be validated
    # when the assessment actually runs.
    try {
        $null = Invoke-WebRequest -Uri 'https://graph.microsoft.com' -Method Head -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        Write-PSFMessage -Message "Connectivity to graph.microsoft.com: OK" -Level Debug
    }
    catch {
        Write-PSFMessage -Message "Connectivity to graph.microsoft.com failed (non-blocking, will be checked during assessment): $_" -Level Debug
    }

    return $true
}

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

        if ($hostsContent -match '^\s*127\.0\.0\.1\s+.*localhost') {
            Write-PSFMessage -Message "/etc/hosts already has 127.0.0.1 localhost but DNS didn't resolve it. May be overridden." -Level Debug
            return $false
        }

        # Add IPv4 localhost entry
        '127.0.0.1 localhost' | & sudo tee -a /etc/hosts > $null 2>&1

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

function Test-ZtPortForwarding {
    <#
    .SYNOPSIS
        Tests whether port forwarding is likely to work for MSAL's callback listener.
    .DESCRIPTION
        Starts a temporary HTTP listener, then verifies it's reachable on IPv4 127.0.0.1.
        In Codespaces, VS Code auto-detects listening ports and forwards them.
    .OUTPUTS
        [bool] True if the listener was reachable.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    $testPort = $null
    $listener = $null

    try {
        # Find a free port
        $tcp = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
        $tcp.Start()
        $testPort = $tcp.LocalEndpoint.Port
        $tcp.Stop()

        # Start an HTTP listener on that port (like MSAL would)
        $listener = [System.Net.HttpListener]::new()
        $listener.Prefixes.Add("http://127.0.0.1:${testPort}/")
        $listener.Start()

        Write-PSFMessage -Message "Test listener started on 127.0.0.1:$testPort" -Level Debug

        # Test that we can connect to it
        $client = [System.Net.Sockets.TcpClient]::new()
        $connectTask = $client.ConnectAsync('127.0.0.1', $testPort)
        $connected = $connectTask.Wait([timespan]::FromSeconds(3))
        $client.Close()

        if ($connected) {
            Write-Host -Object "    ✅ Port forwarding: callback listener test passed (port $testPort)." -ForegroundColor Green
            return $true
        }

        Write-Host -Object "    ⚠️ Port forwarding: could not connect to test listener on 127.0.0.1:$testPort." -ForegroundColor Yellow
        return $false
    }
    catch {
        Write-PSFMessage -Message "Port forwarding test failed: $_" -Level Debug

        if ($testPort) {
            Write-Host -Object "    ⚠️ Port forwarding: test on port $testPort failed — $($_.Exception.Message)" -ForegroundColor Yellow
        }
        else {
            Write-Host -Object '    ⚠️ Port forwarding: could not allocate test port.' -ForegroundColor Yellow
        }
        return $false
    }
    finally {
        if ($listener -and $listener.IsListening) {
            $listener.Stop()
            $listener.Close()
        }
    }
}

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
    if ($readiness.CreatedXdgOpenShim) {
        try {
            $shimPath = '/usr/local/bin/xdg-open'
            if (Test-Path $shimPath) {
                & sudo rm -f $shimPath 2>&1 > $null
                if (-not (Test-Path $shimPath)) {
                    Write-Host -Object '      ✅ Removed xdg-open shim.' -ForegroundColor Green
                    Write-PSFMessage -Message "Removed xdg-open shim at $shimPath." -Level Verbose
                }
                else {
                    Write-Host -Object '      ⚠️ Could not remove xdg-open shim.' -ForegroundColor Yellow
                    Write-PSFMessage -Message "Could not remove xdg-open shim at $shimPath." -Level Warning
                }
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
                $filteredContent | & sudo tee /etc/hosts > $null 2>&1
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

function Test-ZtContainerEnvironment {
    <#
    .SYNOPSIS
        Detects whether the current session is running inside a container.

    .DESCRIPTION
        Checks for common container indicators:
        - REMOTE_CONTAINERS or CODESPACES environment variables (VS Code)
        - /.dockerenv file
        - Container runtime in /proc/1/cgroup

    .OUTPUTS
        [bool] True if running in a container environment.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    # VS Code dev containers / Codespaces
    if ($env:REMOTE_CONTAINERS -or $env:CODESPACES -or $env:REMOTE_CONTAINERS_IPC) {
        return $true
    }

    # VS Code server running inside container
    if ($env:VSCODE_AGENT_FOLDER -or $env:VSCODE_IPC_HOOK_CLI) {
        return $true
    }

    # Docker container indicator
    if (Test-Path '/.dockerenv') {
        return $true
    }

    # Check cgroup for container runtimes
    if (Test-Path '/proc/1/cgroup') {
        $cgroup = Get-Content '/proc/1/cgroup' -Raw -ErrorAction Ignore
        if ($cgroup -match 'docker|containerd|kubepods|lxc') {
            return $true
        }
    }

    return $false
}

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

function Open-ZtFile {
    <#
    .SYNOPSIS
        Opens a file or URL in the default application, with container-aware fallback.
    .DESCRIPTION
        On Linux, uses xdg-open. On macOS, uses open. On Windows, uses Invoke-Item.
        Returns $true if the open command ran without error.
    .PARAMETER Path
        The file path or URL to open.
    .OUTPUTS
        [bool] True if the open command ran successfully.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [string] $Path
    )

    if ($IsLinux -or $IsMacOS) {
        $openCmd = if ($IsLinux) { 'xdg-open' } else { 'open' }
        if (Get-Command -Name $openCmd -ErrorAction Ignore) {
            try {
                & $openCmd $Path 2>&1 | Out-Null
                return $true
            }
            catch {
                Write-PSFMessage -Message "Failed to open with ${openCmd}: $_" -Level Debug
            }
        }
    }
    else {
        try {
            Invoke-Item $Path | Out-Null
            return $true
        }
        catch {
            Write-PSFMessage -Message "Failed to open with Invoke-Item: $_" -Level Debug
        }
    }

    return $false
}

function Open-ZtReport {
    <#
    .SYNOPSIS
        Opens the assessment report, using an HTTP server in containers for VS Code port forwarding.
    .DESCRIPTION
        In container environments, local file:// paths don't work in the browser.
        This function starts a lightweight HTTP server and opens the forwarded URL instead.
        On non-container environments, opens the file directly.
        Always displays a clickable link in the terminal.
    .PARAMETER FilePath
        The path to the HTML report file.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $FilePath
    )

    $authReadiness = $script:ZtContainerAuthReadiness
    $isContainer = $authReadiness -and $authReadiness.IsContainer

    if ($isContainer) {
        $reportServer = Start-ZtReportServer -FilePath $FilePath
        if ($reportServer) {
            $null = Open-ZtFile -Path $reportServer.Url
            Write-Host "   🌐 Report: $($reportServer.Url)" -ForegroundColor Green
            Write-Host "      Server will auto-stop after 30 minutes. Run Stop-ZtReportServer to stop earlier." -ForegroundColor DarkGray
            return
        }
    }

    # Non-container or server failed to start — open file directly
    $null = Open-ZtFile -Path $FilePath
    Write-Host "   🌐 Report: $FilePath" -ForegroundColor Green
}

function Start-ZtReportServer {
    <#
    .SYNOPSIS
        Starts a lightweight HTTP server to serve the assessment report in container environments.
    .DESCRIPTION
        In dev containers and Codespaces, opening local file paths in the browser doesn't work
        reliably. This function starts a background HTTP listener that serves the report HTML file.
        VS Code auto-detects the listening port and forwards it, making the report accessible
        via the browser.

        The server runs in a background PowerShell instance and serves only the specified file.
        It stops automatically after the timeout period or when Stop-ZtReportServer is called.
    .PARAMETER FilePath
        The path to the HTML report file to serve.
    .PARAMETER TimeoutMinutes
        How long the server should run before auto-stopping. Default is 30 minutes.
    .OUTPUTS
        [hashtable] Server state with Port, Url, and Job properties, or $null if the server could not start.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory)]
        [string] $FilePath,

        [int] $TimeoutMinutes = 30
    )

    if (-not (Test-Path -Path $FilePath)) {
        Write-PSFMessage -Message "Report file not found: $FilePath" -Level Warning
        return $null
    }

    # Find a free port
    try {
        $tcp = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
        $tcp.Start()
        $port = $tcp.LocalEndpoint.Port
        $tcp.Stop()
    }
    catch {
        Write-PSFMessage -Message "Could not allocate a port for the report server: $_" -Level Debug
        return $null
    }

    $reportContent = Get-Content -Path $FilePath -Raw -ErrorAction Stop
    $timeoutMs = $TimeoutMinutes * 60 * 1000

    # Start the HTTP server in a background PowerShell instance
    $serverJob = [powershell]::Create()
    $null = $serverJob.AddScript({
        param($port, $reportContent, $timeoutMs)
        $listener = [System.Net.HttpListener]::new()
        $listener.Prefixes.Add("http://127.0.0.1:${port}/")
        $listener.Start()

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        while ($listener.IsListening -and $stopwatch.ElapsedMilliseconds -lt $timeoutMs) {
            $contextTask = $listener.GetContextAsync()
            if ($contextTask.Wait(5000)) {
                $context = $contextTask.Result
                $response = $context.Response
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($reportContent)
                $response.ContentType = 'text/html; charset=utf-8'
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                $response.OutputStream.Close()
            }
        }
        $listener.Stop()
        $listener.Close()
    }).AddArgument($port).AddArgument($reportContent).AddArgument($timeoutMs)

    $null = $serverJob.BeginInvoke()

    # Brief pause to let the listener start
    Start-Sleep -Milliseconds 200

    Write-PSFMessage -Message "Report server started on port $port (timeout: ${TimeoutMinutes}m)." -Level Debug

    $state = @{
        Port = $port
        Url  = "http://localhost:${port}"
        Job  = $serverJob
    }
    $script:ZtReportServer = $state
    return $state
}

function Stop-ZtReportServer {
    <#
    .SYNOPSIS
        Stops the background report HTTP server if one is running.
    #>
    [CmdletBinding()]
    param ()

    $state = $script:ZtReportServer
    if ($state -and $state.Job) {
        $state.Job.Stop()
        $state.Job.Dispose()
        $script:ZtReportServer = $null
        Write-PSFMessage -Message "Report server stopped." -Level Debug
    }
}
