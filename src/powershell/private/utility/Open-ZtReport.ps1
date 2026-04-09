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
    $isContainer = if ($authReadiness) { $authReadiness.IsContainer } else { Test-ZtContainerEnvironment }

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
