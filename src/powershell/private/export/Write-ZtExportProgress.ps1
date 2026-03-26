function Write-ZtExportProgress {
	<#
	.SYNOPSIS
		Appends a progress entry to the overall export execution progress log.

	.DESCRIPTION
		Appends a single line to 1-export_progress.log in the logs folder, recording when
		each export starts, waits for dependencies, completes, or fails. This append-only
		log provides an at-a-glance timeline of all export executions and makes it easy to
		identify hanging exports (STARTED without a matching COMPLETED/FAILED line).

		Uses a per-file named mutex plus [System.IO.File]::AppendAllText to
		serialize writes from parallel runspaces/processes and keep each entry
		on a single line.

	.PARAMETER ExportName
		The name of the export to log progress for.

	.PARAMETER LogsPath
		Path to the logs folder. If empty or null, the function is a no-op.

	.PARAMETER Action
		The progress action: Started, Waiting, InProgress, Completed, Failed, or Status.

	.PARAMETER Duration
		The export duration (for Completed/Failed actions).

	.PARAMETER ErrorMessage
		The error message (for Failed actions).

	.PARAMETER StatusMessage
		Additional status information (for Waiting/Status actions).

	.EXAMPLE
		PS C:\> Write-ZtExportProgress -ExportName 'User' -LogsPath $logsPath -Action Started

		Appends a STARTED line for the User export to the export progress log.

	.EXAMPLE
		PS C:\> Write-ZtExportProgress -ExportName 'User' -LogsPath $logsPath -Action Completed -Duration $result.Duration

		Appends a COMPLETED line for the User export to the export progress log.

	.EXAMPLE
		PS C:\> Write-ZtExportProgress -ExportName 'RoleAssignmentGroup' -LogsPath $logsPath -Action Waiting -StatusMessage 'dependency:RoleAssignment'

		Appends a WAITING line indicating a dependency wait.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$ExportName,

		[string]
		$LogsPath,

		[Parameter(Mandatory = $true)]
		[ValidateSet('Started', 'Waiting', 'InProgress', 'Completed', 'Failed', 'Status')]
		[string]
		$Action,

		[timespan]
		$Duration,

		$ErrorMessage,

		[string]
		$StatusMessage
	)
	process {
		if (-not $LogsPath) { return }

		try {
			[void][System.IO.Directory]::CreateDirectory($LogsPath)

			$timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss.fff')
			$actionPadded = $Action.ToUpper().PadRight(10)

			$line = "$timestamp  $actionPadded  $ExportName"
			if ($null -ne $Duration) {
				$line += "  $($Duration.ToString('hh\:mm\:ss\.fff'))"
			}
			if ($Action -eq 'Waiting' -and $StatusMessage) {
				$line += "  $StatusMessage"
			}
			if ($Action -eq 'Status' -and $StatusMessage) {
				$line += "  $StatusMessage"
			}
			if ($Action -eq 'Failed' -and $ErrorMessage) {
				$errorText = "$ErrorMessage"
				$errorText = $errorText -replace '[\r\n\t]+', ' '
				if ($errorText.Length -gt 1000) {
					$errorText = $errorText.Substring(0, 1000) + '...'
				}
				$line += "  $errorText"
			}
			$line += [System.Environment]::NewLine

			$progressFilePath = Join-Path $LogsPath '1-export_progress.log'
			$fullPath = [System.IO.Path]::GetFullPath($progressFilePath)
			$normalizedPath = if ($IsWindows) { $fullPath.ToLowerInvariant() } else { $fullPath }

			# Cache the mutex name per resolved path to avoid repeated SHA256 hashing
			if (-not $script:ZtExportProgressMutexCache) {
				$script:ZtExportProgressMutexCache = @{}
			}
			if ($script:ZtExportProgressMutexCache.ContainsKey($normalizedPath)) {
				$mutexName = $script:ZtExportProgressMutexCache[$normalizedPath]
			}
			else {
				$pathBytes = [System.Text.Encoding]::UTF8.GetBytes($normalizedPath)
				$pathHashBytes = [System.Security.Cryptography.SHA256]::HashData($pathBytes)
				$pathHash = [System.BitConverter]::ToString($pathHashBytes).Replace('-', '')
				$mutexName = "Local\ZtExportProgress_$pathHash"
				$script:ZtExportProgressMutexCache[$normalizedPath] = $mutexName
			}

			$mutex = $null
			$lockAcquired = $false
			try {
				$mutex = [System.Threading.Mutex]::new($false, $mutexName)
				$lockAcquired = $mutex.WaitOne([TimeSpan]::FromSeconds(5))
				if (-not $lockAcquired) {
					throw "Timed out waiting for export progress log mutex '$mutexName'."
				}

				[System.IO.File]::AppendAllText($fullPath, $line)
			}
			finally {
				if ($lockAcquired -and $null -ne $mutex) {
					$null = $mutex.ReleaseMutex()
				}
				if ($null -ne $mutex) {
					$mutex.Dispose()
				}
			}
		}
		catch {
			Write-PSFMessage -Level Warning -Message "Failed to write export progress log for '{0}': {1}" -StringValues $ExportName, $_.Exception.Message -Tag log
		}
	}
}
