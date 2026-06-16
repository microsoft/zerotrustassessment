function Write-ZtTestFinish {
	<#
	.SYNOPSIS
		Write the finishing data for a test.

	.DESCRIPTION
		Write the finishing data for a test.
		Handles progress updates and simple-logging.

	.PARAMETER Result
		The result object describing how the test went.

	.PARAMETER PreviousMessages
		The messages that had previously been written before starting on this test.
		Used to pick out the messages that apply to just this test.

	.PARAMETER Test
		The test object of the test executed.

	.PARAMETER LogsPath
		Where to write the simple-logs to.

	.PARAMETER PassThru
		Whether to return the result object as output.
		Otherwise it will be directly written to the output queue.
		Must be specified when called from within an Runspace WOrkflow Agent, but outside of the Process event scriptblock.

	.EXAMPLE
		PS C:\>  Write-ZtTestFinish -Result $result -PreviousMessages $global:msgSoFar[$_.TestID] -Test $this -LogsPath $logsPath

		Write the finishing data for the test specified.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Result,

		$PreviousMessages,

		[Parameter(Mandatory = $true)]
		$Test,

		[AllowEmptyString()]
		[string]
		$LogsPath,

		[switch]
		$PassThru
	)
	process {
		$Result.Messages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId) | Where-Object { $_ -notin $previousMessages }
		$limit = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Tests.Statistics.MaxMessageCount'
		if ($Result.Messages.Count -gt $limit) {
			$Result.Messages = $Result.Messages | Select-Object Timestamp, Level, Message, Tags, Runspace
		}
		Write-ZtTestStatistics -Result $Result

		# Update progress dashboard with final status
		if ($Result.TimedOut) {
			Update-ZtProgressState -WorkerId $Test.TestID -WorkerName $Result.DisplayName -WorkerStatus 'TimedOut' -WorkerDetail "Timed out after $($Result.Duration)"
		}
		elseif ($Result.Success) {
			Update-ZtProgressState -WorkerId $Test.TestID -WorkerName $Result.DisplayName -WorkerStatus 'Done' -WorkerDetail ''
		}
		# Failed status already set in the catch block

		# Write per-test log file (overwrites stub) and progress entry
		if ($LogsPath) {
			Write-ZtTestLog -Result $Result -LogsPath $LogsPath
			if ($Result.TimedOut) {
				Write-ZtTestProgress -TestID $Result.TestID -LogsPath $LogsPath -Action TimedOut -Duration $Result.Duration -ErrorMessage "$($Result.Error)"
			}
			elseif ($Result.Success) {
				Write-ZtTestProgress -TestID $Result.TestID -LogsPath $LogsPath -Action Completed -Duration $Result.Duration
			}
			elseif ($Result.Error) {
				Write-ZtTestProgress -TestID $Result.TestID -LogsPath $LogsPath -Action Error -Duration $Result.Duration -ErrorMessage "Error: $($Result.Error.Exception.Message)"
			}
			else {
				$progressError = $Result.Error ? "Error: $($Result.Error.Exception.Message)" : $null
				Write-ZtTestProgress -TestID $Result.TestID -LogsPath $LogsPath -Action Failed -Duration $Result.Duration -ErrorMessage $progressError
			}
		}

		if ($PassThru) {
			$Result
		}
		else {
			Write-PSFRunspaceQueue -Name $__PSF_Worker.OutQueue -Value $Result -UseCurrent
		}
	}
}
