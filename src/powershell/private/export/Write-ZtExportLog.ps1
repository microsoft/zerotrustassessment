function Write-ZtExportLog {
	<#
	.SYNOPSIS
		Writes a per-export log file with execution summary and PSFramework messages.

	.DESCRIPTION
		Writes a per-export log file with execution summary and PSFramework messages.
		Each export gets its own export_<Name>.md file under the 1-Export subfolder of the
		logs folder (<LogsPath>/1-Export/export_<Name>.md), making it easy to debug
		individual export executions in parallel runs.

		The log file contains a header block with export metadata (name, status,
		duration, timing, Graph URI, errors) followed by timestamped message lines.

	.PARAMETER Result
		The export execution statistics object (ZeroTrustAssessment.ExportStatistics).

	.PARAMETER LogsPath
		Path to the logs folder. If empty or null, the function is a no-op.

	.EXAMPLE
		PS C:\> Write-ZtExportLog -Result $result -LogsPath $logsPath

		Writes the full export log for the completed export to <LogsPath>/1-Export/export_<Name>.md.
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

			$name = $Result.Name
			$status = if ($Result.Success) { 'Done' } else { 'Failed' }
			$duration = if ($null -ne $Result.Duration) { $Result.Duration.ToString('hh\:mm\:ss\.fff') } else { 'N/A' }
			$startTime = if ($Result.Start) { $Result.Start.ToString('yyyy-MM-dd HH:mm:ss.fff') } else { 'N/A' }
			$endTime = if ($Result.End) { $Result.End.ToString('yyyy-MM-dd HH:mm:ss.fff') } else { 'N/A' }

			$lines = [System.Collections.Generic.List[string]]::new()
			$lines.Add("# Export: $name")
			$lines.Add("# Status: $status")
			$lines.Add("# Duration: $duration")
			$lines.Add("# Start: $startTime")
			$lines.Add("# End: $endTime")
			if ($Result.Export) {
				$uri = $Result.Export.Uri
				if ($uri) {
					$lines.Add("# URI: $uri")
				}
				$type = $Result.Export.Type
				if ($type) {
					$lines.Add("# Type: $type")
				}
				$dependsOn = $Result.Export.DependsOn
				if ($dependsOn) {
					$lines.Add("# DependsOn: $dependsOn")
				}
			}
			$moduleVersion = if ($script:__ZtSession.ModuleVersion) { $script:__ZtSession.ModuleVersion } else { 'Unknown' }
			$lines.Add("# Version: $moduleVersion")
			if (-not $Result.Success -and $Result.Error) {
				$errorText = "$($Result.Error)"
				$lines.Add("# Error: $errorText")
			}
			$lines.Add('# ---')

			if ($Result.Messages) {
				foreach ($msg in $Result.Messages) {
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
					$text = if ($null -ne $msg.LogMessage) { "$($msg.LogMessage)" } else { '' }
					$lines.Add("$timestamp [$level] $text")
				}
			}

			$exportLogsPath = Join-Path $LogsPath '1-Export'
			[void][System.IO.Directory]::CreateDirectory($exportLogsPath)
			$logMarkdownPath = Join-Path $exportLogsPath "export_$name.md"
			[System.IO.File]::WriteAllLines($logMarkdownPath, $lines)
		}
		catch {
			$errorMessage = if ($null -ne $_.Exception -and $null -ne $_.Exception.Message) { $_.Exception.Message } else { 'Unknown error while writing export log.' }
			Write-PSFMessage -Level Warning -Message "Failed to write export log for '{0}': {1}" -StringValues $Result.Name, $errorMessage -Tag log
		}
	}
}
