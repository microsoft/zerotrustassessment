function Invoke-ZtTest {
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

	.PARAMETER TestTimeout
		Maximum time a single test is allowed to run before it is stopped.
		TimeSpan.Zero disables the timeout.

	.EXAMPLE
		PS C:\> Invoke-ZtTest -Test $_ -Database $global:database -LogsPath $logsPath

		Executes the current test with the globally cached database connection and writes a log file.

	.EXAMPLE
		PS C:\> Invoke-ZtTest -Test $_ -Database $global:database -LogsPath $logsPath -TestTimeout ([timespan]::FromMinutes(30))

		Executes the test with a 30-minute timeout.
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

		[timespan]
		$TestTimeout = [timespan]::Zero
	)
	begin {
		$previousMessages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
		$result = [PSCustomObject]@{
			PSTypeName = 'ZeroTrustAssessment.TestStatistics'
			TestID     = $Test.TestID
			Test       = $Test

			# Performance Metrics, in case we want to identify problematic tests
			Start      = $null
			End        = $null
			Duration   = $null

			# What Happened?
			Success    = $true
			Error      = $null
			Messages   = $null
			TimedOut   = $false

			# Test should have no output, but we'll catch it anyways, just in case
			Output     = $null
		}
	}
	process {
		Write-PSFMessage -Message "Processing test '{0}'" -StringValues $Test.TestID -Target $Test -Tag start

		# Use the test Title as the display name, falling back to TestID if Title is not available
		$testDisplayName = if ($Test.Title) { $Test.Title } else { $Test.TestID }

		# Update progress dashboard: map this runspace to this test and mark as starting
		$runspaceId = [runspace]::DefaultRunspace.InstanceId.ToString()
		$script:__ZtSession.ProgressState.Value["rs_$runspaceId"] = $Test.TestID
		Update-ZtProgressState -WorkerId $Test.TestID -WorkerName $testDisplayName -WorkerStatus 'Running' -WorkerDetail 'Starting test...'

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

		$timeoutEnabled = $TestTimeout -gt [timespan]::Zero

		if ($timeoutEnabled) {
			Initialize-ZtTimeoutHelper
		}

		try {
			# Set Current Test for "Add-ZtTestResultDetail to pick up"
			$script:__ztCurrentTest = $Test

			$result.Start = Get-Date

			if (-not $timeoutEnabled) {
				# No timeout — run directly in the current thread (original behavior)
				$result.Output = & $command @dbParam -ErrorAction Stop
			}
			else {
				# Run test in a child PowerShell pipeline with a timer-based timeout.
				# Strategy: Use [powershell]::Create(CurrentRunspace) + synchronous Invoke(),
				# combined with a .NET timeout controller that calls ps.Stop() from a
				# ThreadPool thread when the timeout expires. We also track whether the
				# timer actually fired, so PipelineStoppedException is not blindly treated
				# as a timeout condition.
				$ps = $null
				$timeoutController = $null
				$timeoutTriggered = $false
				try {
					$ps = [powershell]::Create([System.Management.Automation.RunspaceMode]::CurrentRunspace)
					$null = $ps.AddCommand($command.Name)
					foreach ($key in $dbParam.Keys) {
						$null = $ps.AddParameter($key, $dbParam[$key])
					}
					$null = $ps.AddParameter('ErrorAction', 'Stop')

					# Schedule a .NET timer to call ps.Stop() when the timeout expires
					$timeoutController = [ZeroTrustAssessment.TimeoutHelper]::CreateTimeoutController($ps, [int]$TestTimeout.TotalMilliseconds)

					$result.Output = $ps.Invoke()

					$timeoutTriggered = $timeoutController.Fired
					$timeoutController.Dispose()
					$timeoutController = $null

					# When Stop() is called on a CurrentRunspace pipeline, Invoke() may return
					# silently instead of throwing PipelineStoppedException. Detect this via
					# the timer-fired flag and the final pipeline state.
					if ($timeoutTriggered -or $ps.InvocationStateInfo.State -eq [System.Management.Automation.PSInvocationState]::Stopped) {
						Set-ZtTimedOutResult -Result $result -Test $Test -Timeout $TestTimeout
					}
					elseif ($ps.HadErrors) {
						# Surface any non-terminating errors from the child pipeline
						$firstError = $ps.Streams.Error | Select-Object -First 1
						if ($firstError) {
							throw $firstError.Exception
						}
					}
				}
				catch [System.Management.Automation.PipelineStoppedException] {
					# PipelineStoppedException may be raised by the timeout controller or by
					# unrelated stop conditions. Only classify it as timeout if the controller
					# actually fired or the pipeline ended in Stopped state.
					$timeoutTriggered = ($null -ne $timeoutController -and $timeoutController.Fired) -or $timeoutTriggered
					if ($timeoutTriggered -or ($null -ne $ps -and $ps.InvocationStateInfo.State -eq [System.Management.Automation.PSInvocationState]::Stopped)) {
						Set-ZtTimedOutResult -Result $result -Test $Test -Timeout $TestTimeout
					}
					else {
						Write-PSFMessage -Level Warning -Message "PipelineStoppedException in test '{0}' was not caused by timeout" -StringValues $Test.TestID -Target $Test -ErrorRecord $_
						throw
					}
				}
				finally {
					if ($null -ne $timeoutController) { $timeoutController.Dispose() }
					if ($null -ne $ps) { $ps.Dispose() }
				}
			}
		}
		catch {
			Write-PSFMessage -Level Warning -Message "Error executing test '{0}': {1}" -StringValues $Test.TestID, $_.Exception.Message -Target $Test -ErrorRecord $_
			$result.Success = $false
			$result.Error = $_
			$message = @(
				'❌  Test {0} failed due to an unexpected error.' -f $Test.TestID
				' - **Error Message**: {0}.' -f $_.Exception.Message
				'```'
				'{0}' -f ($_ | Get-Error | Out-String)
				'```'
			) -join "`r`n"
			Add-ZtTestResultDetail -TestId $Test.TestID -Title $Test.Title -Status $false -Result $message -CustomStatus 'Error'
			Update-ZtProgressState -WorkerId $Test.TestID -WorkerName $testDisplayName -WorkerStatus 'Error' -WorkerDetail "Error: $($_.Exception.Message)"
		}
		finally {
			$result.End = Get-Date
			$result.Duration = $result.End - $result.Start

			# Reset marker in an assured way, to prevent confusion about the current test being executed
			$script:__ztCurrentTest = $null
		}

		Write-PSFMessage -Message "Processing test '{0}' - Concluded" -StringValues $Test.TestID -Target $Test -Tag end
	}

	end {
		$result.Messages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId) | Where-Object { $_ -notin $previousMessages }
		Write-ZtTestStatistics -Result $result

		# Update progress dashboard with final status
		if ($result.TimedOut) {
			Update-ZtProgressState -WorkerId $Test.TestID -WorkerName $testDisplayName -WorkerStatus 'TimedOut' -WorkerDetail "Timed out after $($result.Duration)"
		}
		elseif ($result.Success) {
			Update-ZtProgressState -WorkerId $Test.TestID -WorkerName $testDisplayName -WorkerStatus 'Done' -WorkerDetail ''
		}
		# Failed status already set in the catch block

		# Write per-test log file (overwrites stub) and progress entry
		if ($LogsPath) {
			Write-ZtTestLog -Result $result -LogsPath $LogsPath
			if ($result.TimedOut) {
				Write-ZtTestProgress -TestID $result.TestID -LogsPath $LogsPath -Action TimedOut -Duration $result.Duration -ErrorMessage "$($result.Error)"
			}
			elseif ($result.Success) {
				Write-ZtTestProgress -TestID $result.TestID -LogsPath $LogsPath -Action Completed -Duration $result.Duration
			}
			elseif ($result.Error) {
				Write-ZtTestProgress -TestID $result.TestID -LogsPath $LogsPath -Action Error -Duration $result.Duration -ErrorMessage "Error: $($result.Error.Exception.Message)"
			}
			else {
				$progressError = if ($result.Error) { "Error: $($result.Error.Exception.Message)" } else { $null }
				Write-ZtTestProgress -TestID $result.TestID -LogsPath $LogsPath -Action Failed -Duration $result.Duration -ErrorMessage $progressError
			}
		}

		$result
	}
}
