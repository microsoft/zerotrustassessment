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
