function Stop-ZtProgressServer {
	<#
	.SYNOPSIS
		Stops the progress dashboard HTTP server.

	.DESCRIPTION
		Gracefully stops the HttpListener running in the background runspace,
		disposes the PowerShell instance and runspace, and clears the server state.

		Safe to call multiple times or when no server is running.

	.EXAMPLE
		PS C:\> Stop-ZtProgressServer

		Stops the progress server if it is running.
	#>
	[CmdletBinding()]
	param ()
	process {
		$server = $script:__ZtSession.ProgressServer
		if (-not $server) { return }

		try {
			# Stop the PowerShell instance (this will cause the HttpListener.GetContextAsync to fail,
			# breaking the server loop)
			if ($server.PowerShell) {
				$server.PowerShell.Stop()
				$server.PowerShell.Dispose()
			}
		}
		catch {
			Write-PSFMessage -Level Debug -Message "Error stopping progress server PowerShell: $_"
		}

		try {
			if ($server.Runspace) {
				$server.Runspace.Close()
				$server.Runspace.Dispose()
			}
		}
		catch {
			Write-PSFMessage -Level Debug -Message "Error disposing progress server runspace: $_"
		}

		$script:__ZtSession.ProgressServer = $null
	}
}
