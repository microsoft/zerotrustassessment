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

    try {
        $reportContent = Get-Content -Path $FilePath -Raw -ErrorAction Stop
    }
    catch {
        Write-PSFMessage -Message "Could not read report file for the report server: $FilePath. $_" -Level Warning
        return $null
    }
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

    # Stop any previously running server before tracking the new one
    Stop-ZtReportServer

    $script:ZtReportServer = $state
    return $state
}
