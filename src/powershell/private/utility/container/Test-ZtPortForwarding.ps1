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
