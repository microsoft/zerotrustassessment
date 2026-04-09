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
        and records the resulting browser-auth readiness state for diagnostics
        and for callers that choose to inspect it.

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
        BrowserShimState   = $script:ZtBrowserShimState
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
            $browserHelper = $candidate
            Write-PSFMessage -Message "Resolved browser helper from `$$envVar='$candidate' (exe: $($resolved.Source))." -Level Debug
            break
        }
        else {
            Write-PSFMessage -Message "`$$envVar='$candidate' set but '$exePath' not found on PATH or filesystem." -Level Debug
        }
    }

    if ($browserHelper) {
        Write-PSFMessage -Message "xdg-open not found. Creating shim from browser helper '$browserHelper'." -Level Verbose

        $shimContent = @"
#!/bin/sh
exec "$browserHelper" "`$@"
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
                $env:PATH = "$userBinDir:$($env:PATH)"
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
