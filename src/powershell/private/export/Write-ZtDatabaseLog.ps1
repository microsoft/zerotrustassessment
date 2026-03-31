function Write-ZtDatabaseLog {
	<#
	.SYNOPSIS
		Appends a progress entry to the database import progress log.

	.DESCRIPTION
		Appends a single line to 2-database_progress.log in the logs folder, recording when
		each table import starts, completes, or fails. This append-only log provides an
		at-a-glance timeline of all database table imports and makes it easy to identify
		which table import caused an issue.

		Uses a per-file named mutex plus [System.IO.File]::AppendAllText for
		consistency with the export and test progress log patterns.

	.PARAMETER TableName
		The name of the database table being imported.

	.PARAMETER LogsPath
		Path to the logs folder. If empty or null, the function is a no-op.

	.PARAMETER Action
		The progress action: Started, Completed, or Failed.

	.PARAMETER Duration
		The table import duration (for Completed/Failed actions).

	.PARAMETER ErrorMessage
		The error message (for Failed actions).

	.EXAMPLE
		PS C:\> Write-ZtDatabaseLog -TableName 'User' -LogsPath $logsPath -Action Started

		Appends a STARTED line for the User table import to the database progress log.

	.EXAMPLE
		PS C:\> Write-ZtDatabaseLog -TableName 'User' -LogsPath $logsPath -Action Completed -Duration $elapsed

		Appends a COMPLETED line for the User table import to the database progress log.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$TableName,

		[string]
		$LogsPath,

		[Parameter(Mandatory = $true)]
		[ValidateSet('Started', 'Completed', 'Failed')]
		[string]
		$Action,

		[timespan]
		$Duration,

		$ErrorMessage
	)
	process {
		if (-not $LogsPath) { return }

		try {
			[void][System.IO.Directory]::CreateDirectory($LogsPath)

			$timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss.fff')
			$actionPadded = $Action.ToUpper().PadRight(10)

			$line = "$timestamp  $actionPadded  $TableName"
			if ($null -ne $Duration) {
				$line += "  $($Duration.ToString('hh\:mm\:ss\.fff'))"
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

			$progressFilePath = Join-Path $LogsPath '2-database_progress.log'
			$fullPath = [System.IO.Path]::GetFullPath($progressFilePath)
			$normalizedPath = if ($IsWindows) { $fullPath.ToLowerInvariant() } else { $fullPath }

			# Cache the mutex name per resolved path to avoid repeated SHA256 hashing
			if (-not $script:ZtDatabaseProgressMutexCache) {
				$script:ZtDatabaseProgressMutexCache = @{}
			}
			if ($script:ZtDatabaseProgressMutexCache.ContainsKey($normalizedPath)) {
				$mutexName = $script:ZtDatabaseProgressMutexCache[$normalizedPath]
			}
			else {
				$pathBytes = [System.Text.Encoding]::UTF8.GetBytes($normalizedPath)
				$pathHashBytes = [System.Security.Cryptography.SHA256]::HashData($pathBytes)
				$pathHash = [System.BitConverter]::ToString($pathHashBytes).Replace('-', '')
				$mutexName = "Local\ZtDatabaseProgress_$pathHash"
				$script:ZtDatabaseProgressMutexCache[$normalizedPath] = $mutexName
			}

			$mutex = $null
			$lockAcquired = $false
			try {
				$mutex = [System.Threading.Mutex]::new($false, $mutexName)
				$lockAcquired = $mutex.WaitOne([TimeSpan]::FromSeconds(5))
				if (-not $lockAcquired) {
					throw "Timed out waiting for database progress log mutex '$mutexName'."
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
			Write-PSFMessage -Level Warning -Message "Failed to write database progress log for '{0}': {1}" -StringValues $TableName, $_.Exception.Message -Tag log
		}
	}
}
