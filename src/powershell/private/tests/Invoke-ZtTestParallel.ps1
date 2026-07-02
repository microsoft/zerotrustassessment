function Invoke-ZtTestParallel {
	<#
	.SYNOPSIS
		Execute individual tests and collect execution statistics.

	.DESCRIPTION
		Execute individual tests and collect execution statistics.
		This command is expected to be run from background runspaces launched by Start-ZtTestExecution.

		Use Get-ZtTestStatistics to retrieve the results of these executions.

	.PARAMETER Test
		The test object to process.
		Expects an object as returned by Get-ZtTest.

	.PARAMETER Database
		The Database used for accessing cached tenant data.

	.PARAMETER LogsPath
		Path to the logs folder where per-test log files are written.
		If not specified, no log files are written.

	.PARAMETER PreviousMessages
		The messages previously sent from this runspace.
		Used to include only messages written afterwards in the test statistics.

	.EXAMPLE
		PS C:\> Invoke-ZtTestParallel -Test $_ -Database $global:database -LogsPath $logsPath

		Executes the current test with the globally cached database connection and writes a log file.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PSTypeName('ZeroTrustAssessment.Test')]
		$Test,

		[DuckDB.NET.Data.DuckDBConnection]
		$Database,

		[string]
		$LogsPath,

		$PreviousMessages
	)
	begin {
		$result = Get-ZtTestResult -Test $Test
	}
	process {
		Write-PSFMessage -Message "Processing test '{0}'" -StringValues $Test.TestID -Target $Test -Tag start

		# Update progress dashboard: map this runspace to this test and mark as starting
		$runspaceId = [runspace]::DefaultRunspace.InstanceId.ToString()
		$script:__ZtSession.ProgressState.Value["rs_$runspaceId"] = $Test.TestID
		Update-ZtProgressState -WorkerId $Test.TestID -WorkerName $result.DisplayName -WorkerStatus 'Running' -WorkerDetail 'Starting test...'

		# Check if the function exists and what parameters it has
		$command = Get-Command $Test.Command -ErrorAction SilentlyContinue
		if (-not $command) {
			Write-PSFMessage -Level Warning -Message "Test command for test '{0}' not found" -StringValues $Test.TestID -Target $Test
			throw "Test command for test '$($Test.TestID)' not found"
		}

		$dbParam = @{}
		if (($null -ne $command) -and $command.Parameters.ContainsKey("Database") -and $Database) {
			$dbParam.Database = $Database
		}

		# Write stub log file and progress entry so hanging tests are visible
		if ($LogsPath) {
			Write-ZtTestProgress -TestID $Test.TestID -LogsPath $LogsPath -Action Started
			try {
				$stubDir = Join-Path $LogsPath '2-Tests'
				[void][System.IO.Directory]::CreateDirectory($stubDir)
				$stubPath = Join-Path $stubDir "$($Test.TestID).md"
				[System.IO.File]::WriteAllText($stubPath, "# Test: $($Test.TestID) - Started at $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss.fff'))$([System.Environment]::NewLine)")
			}
			catch {
				Write-PSFMessage -Level Warning -Message "Failed to write stub test log for test '{0}': {1}" -StringValues $Test.TestID, $_ -Tag log
			}
		}

		try {
			# Set Current Test for "Add-ZtTestResultDetail to pick up"
			$script:__ztCurrentTest = $Test

			# Only start on first attempt - retries count as extra
			if (-not $result.Start) {
				$result.Start = Get-Date
			}
			else {
				$result.Attempts++
			}

			$result.Output = & $command @dbParam -ErrorAction Stop
		}
		catch {
			throw
		}

		$result.End = Get-Date
		$result.Duration = $result.End - $result.Start

		# Reset marker in an assured way, to prevent confusion about the current test being executed
		$script:__ztCurrentTest = $null

		Write-PSFMessage -Message "Processing test '{0}' - Concluded" -StringValues $Test.TestID -Target $Test -Tag end
	}

	end {
		Write-ZtTestFinish -Result $result -PreviousMessages $previousMessages -Test $Test -LogsPath $LogsPath -PassThru
	}
}
