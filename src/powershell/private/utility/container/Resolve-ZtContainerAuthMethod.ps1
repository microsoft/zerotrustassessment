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
