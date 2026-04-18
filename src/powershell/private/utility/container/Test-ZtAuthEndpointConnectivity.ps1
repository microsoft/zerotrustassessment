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
