function Write-ZtTestLog {
	<#
	.SYNOPSIS
		Writes a per-test log file with execution summary and PSFramework messages.

	.DESCRIPTION
		Writes a per-test log file with execution summary and PSFramework messages.
		Each test gets its own <TestID>.md file under the 2-Tests subfolder of the
		logs folder (<LogsPath>/2-Tests/<TestID>.md), making it easy to debug
		individual test executions in parallel runs.

		The log file contains a header block with test metadata (ID, title, status,
		duration, timing, errors) followed by timestamped message lines.

	.PARAMETER Result
		The test execution statistics object (ZeroTrustAssessment.TestStatistics).

	.PARAMETER LogsPath
		Path to the logs folder. If empty or null, the function is a no-op.

	.EXAMPLE
		PS C:\> Write-ZtTestLog -Result $result -LogsPath $logsPath

		Writes the full test log for the completed test to <LogsPath>/2-Tests/<TestID>.md.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Result,

		[string]
		$LogsPath
	)
	process {
		if (-not $LogsPath) { return }

		try {
			[void][System.IO.Directory]::CreateDirectory($LogsPath)

			$testId = $Result.TestID
			$title = $Result.Test.Title
			$status = if ($Result.TimedOut) { 'TimedOut' } elseif ($Result.Success) { 'Pass' } else { 'Fail' }
			$duration = if ($null -ne $Result.Duration) { $Result.Duration.ToString('hh\:mm\:ss\.fff') } else { 'N/A' }
			$startTime = if ($Result.Start) { $Result.Start.ToString('yyyy-MM-dd HH:mm:ss.fff') } else { 'N/A' }
			$endTime = if ($Result.End) { $Result.End.ToString('yyyy-MM-dd HH:mm:ss.fff') } else { 'N/A' }

			$lines = [System.Collections.Generic.List[string]]::new()
			$lines.Add("# Test: $testId - $title")
			$lines.Add("# Status: $status")
			$lines.Add("# Duration: $duration")
			$lines.Add("# Start: $startTime")
			$lines.Add("# End: $endTime")
			$moduleVersion = if ($script:__ZtSession.ModuleVersion) { $script:__ZtSession.ModuleVersion } else { 'Unknown' }
			$lines.Add("# Version: $moduleVersion")
			if (-not $Result.Success -and $Result.Error) {
				$errorText = "$($Result.Error)"
				$lines.Add("# Error: $errorText")
			}
			$lines.Add('# ---')

            # Write messages, excluding "Result:" lines which contain tenant-specific report output (privacy)
            if ($Result.Messages) {
                foreach ($msg in $Result.Messages) {
                    $text = if ($null -ne $msg.LogMessage) { "$($msg.LogMessage)" } else { '' }
                    if ($text -like 'Result:*') { continue }

                    $timestamp = 'N/A'
                    if ($null -ne $msg.Timestamp) {
                        try {
                            $timestamp = ([datetime]$msg.Timestamp).ToString('yyyy-MM-dd HH:mm:ss.fff')
                        }
                        catch {
                            $timestamp = "$($msg.Timestamp)"
                        }
                    }

                    $level = if ($null -ne $msg.Level) { "$($msg.Level)" } else { 'Info' }
                    $lines.Add("$timestamp [$level] $text")
                }
            }

			$testLogsPath = Join-Path $LogsPath '2-Tests'
			[void][System.IO.Directory]::CreateDirectory($testLogsPath)
			$logMarkdownPath = Join-Path $testLogsPath "$testId.md"
			[System.IO.File]::WriteAllLines($logMarkdownPath, $lines)
		}
		catch {
			$errorMessage = if ($null -ne $_.Exception -and $null -ne $_.Exception.Message) { $_.Exception.Message } else { 'Unknown error while writing test log.' }
			Write-PSFMessage -Level Warning -Message "Failed to write test log for test '{0}': {1}" -StringValues $Result.TestID, $errorMessage -Tag log
		}
	}
}
