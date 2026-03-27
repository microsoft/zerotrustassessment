function Write-ZtTestProgress {
	<#
	.SYNOPSIS
		Appends a progress entry to the overall test execution progress log.

	.DESCRIPTION
		Appends a single line to 3-test_progress.log in the logs folder, recording when
		each test starts, completes, or fails. This append-only log provides an
		at-a-glance timeline of all test executions and makes it easy to identify
		hanging tests (STARTED without a matching COMPLETED/FAILED line).

		Uses a per-file named mutex plus [System.IO.File]::AppendAllText to
		serialize writes from parallel runspaces/processes and keep each entry
		on a single line.

	.PARAMETER TestID
		The test ID to log progress for.

	.PARAMETER LogsPath
		Path to the logs folder. If empty or null, the function is a no-op.

	.PARAMETER Action
		The progress action: Started, Completed, or Failed.

	.PARAMETER Duration
		The test duration (for Completed/Failed actions).

	.PARAMETER ErrorMessage
		The error message (for Failed actions).

	.EXAMPLE
		PS C:\> Write-ZtTestProgress -TestID 25384 -LogsPath $logsPath -Action Started

		Appends a STARTED line for test 25384 to the progress log.

	.EXAMPLE
		PS C:\> Write-ZtTestProgress -TestID 25384 -LogsPath $logsPath -Action Completed -Duration $result.Duration

		Appends a COMPLETED line for test 25384 to the progress log.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$TestID,

		[string]
		$LogsPath,

		[Parameter(Mandatory = $true)]
		[ValidateSet('Started', 'Completed', 'Failed', 'TimedOut','Error')]
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

			$line = "$timestamp  $actionPadded  $TestID"
			if ($null -ne $Duration) {
				$line += "  $($Duration.ToString('hh\:mm\:ss\.fff'))"
			}
			if ($Action -eq 'Completed') {
				$line += '  Pass'
			}
			if ($Action -eq 'TimedOut') {
				if ($ErrorMessage) {
					$errorText = "$ErrorMessage"
					$errorText = $errorText -replace '[\r\n\t]+', ' '
					if ($errorText.Length -gt 1000) {
						$errorText = $errorText.Substring(0, 1000) + '...'
					}
					$line += "  $errorText"
				}
				else {
					$line += '  Test exceeded timeout limit'
				}
			}
			if ($Action -in @('Failed', 'Error') -and $ErrorMessage) {
				$errorText = "$ErrorMessage"
				$errorText = $errorText -replace '[\r\n\t]+', ' '
				if ($errorText.Length -gt 1000) {
					$errorText = $errorText.Substring(0, 1000) + '...'
				}
				$line += "  $errorText"
			}
			$line += [System.Environment]::NewLine

			$progressFilePath = Join-Path $LogsPath '3-test_progress.log'
			$fullPath = [System.IO.Path]::GetFullPath($progressFilePath)
			$normalizedPath = if ($IsWindows) { $fullPath.ToLowerInvariant() } else { $fullPath }

			# Cache the mutex name per resolved path to avoid repeated SHA256 hashing
			if (-not $script:ZtProgressMutexCache) {
				$script:ZtProgressMutexCache = @{}
			}
			if ($script:ZtProgressMutexCache.ContainsKey($normalizedPath)) {
				$mutexName = $script:ZtProgressMutexCache[$normalizedPath]
			}
			else {
				$pathBytes = [System.Text.Encoding]::UTF8.GetBytes($normalizedPath)
				$pathHashBytes = [System.Security.Cryptography.SHA256]::HashData($pathBytes)
				$pathHash = [System.BitConverter]::ToString($pathHashBytes).Replace('-', '')
				$mutexName = "Local\ZtProgress_$pathHash"
				$script:ZtProgressMutexCache[$normalizedPath] = $mutexName
			}

			$mutex = $null
			$lockAcquired = $false
			try {
				$mutex = [System.Threading.Mutex]::new($false, $mutexName)
				$lockAcquired = $mutex.WaitOne([TimeSpan]::FromSeconds(5))
				if (-not $lockAcquired) {
					throw "Timed out waiting for progress log mutex '$mutexName'."
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
			Write-PSFMessage -Level Warning -Message "Failed to write progress log for test '{0}': {1}" -StringValues $TestID, $_.Exception.Message -Tag log
		}
	}
}
