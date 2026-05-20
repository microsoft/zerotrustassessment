function Wait-ZtTest {
	<#
	.SYNOPSIS
		Wait for all Test runs to complete, writing progress on screen and reporting failed tests.

	.DESCRIPTION
		Wait for all Test runs to complete, writing progress on screen and reporting failed tests.

	.PARAMETER Workflow
		The PSFramework Runspace Workflow executing the tests.

	.PARAMETER Timeout
		The maximum time to wait for the workflow to complete before giving up and writing a warning message

	.PARAMETER StartedAt
		The DateTime when the workflow started. This is used in combination with Timeout to determine if the workflow has exceeded the allowed time.

	.EXAMPLE
		PS C:\> Wait-ZtTest -Workflow $workflow

		Wait for all Tests of the workflow in $workflow to complete, writing progress on screen and reporting failed tests.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PSFramework.Runspace.RSWorkflow]
		$Workflow,

		[TimeSpan]
		$Timeout = '1.00:00:00',

		[datetime]
		$StartedAt = [DateTime]::Now
	)

	begin {
		$failedTests = @{}
		$totalCount = $Workflow.Queues["Input"].TotalItemCount
		$progressID = Get-Random -Minimum 1 -Maximum 999
		$lastMessageScan = [datetime]::MinValue

		# Initialize progress dashboard summary for the test stage
		Update-ZtProgressState -TotalItems $totalCount -CompletedItems 0 -FailedItems 0 -InProgressItems 0
	}

	process {
		Write-Progress -Id $progressID -Activity "Processing $($totalCount) Tests" -PercentComplete 0
		while (-not $Workflow.Queues["Results"].Closed -and $Timeout -gt ([DateTime]::Now - $StartedAt)) {
			Start-Sleep -Milliseconds 500

			$failed = Get-ZtTestStatistics | Where-Object -Property Success -eq $false
			foreach ($failure in $failed) {
				if ($failedTests[$failure.TestID]) { continue }
				$failedTests[$failure.TestID] = $true
				Write-PSFMessage -Level Warning -Message "Error processing Test {0}." -StringValues $failure.TestID -ErrorRecord $failure.Error
			}

			$percent = ($Workflow.Queues["Results"].Count / $totalCount * 100) -as [int]
			if ($percent -lt 0) { $percent = 0 }
			if ($percent -gt 100) { $percent = 100 }

			$status = "Completed: $($Workflow.Queues["Results"].Count) / $totalCount"

			Write-Progress -Id $progressID -Activity "Processing $($totalCount) Tests" -Status $status -PercentComplete $percent

			# Update progress dashboard summary counts
			$completedCount = $Workflow.Queues["Results"].Count
			$failedCount = ($failed | Measure-Object).Count
			$inProgressCount = $totalCount - $completedCount
			Update-ZtProgressState -TotalItems $totalCount -CompletedItems ($completedCount - $failedCount) -FailedItems $failedCount -InProgressItems $inProgressCount

			# Scan recent PSFMessages to update worker detail lines
			try {
				$recentMessages = Get-PSFMessage -Last 100 | Where-Object { $_.Timestamp -gt $lastMessageScan }
				$lastMessageScan = [datetime]::Now

				# Build runspace-to-test mapping from the progress state
				$rsMappings = @{}
				foreach ($key in @($script:__ZtSession.ProgressState.Value.Keys)) {
					if ($key -like 'rs_*') {
						$rsId = $key.Substring(3)
						$rsMappings[$rsId] = $script:__ZtSession.ProgressState.Value[$key]
					}
				}

				foreach ($msg in $recentMessages) {
					$rsId = $msg.Runspace.ToString()
					if ($rsMappings.ContainsKey($rsId)) {
						$testId = $rsMappings[$rsId]
						$workerKey = "worker_$testId"
						$worker = $null
						if ($script:__ZtSession.ProgressState.Value.TryGetValue($workerKey, [ref]$worker)) {
							if ($worker -and $worker.Status -eq 'Running') {
								Update-ZtProgressState -WorkerId $testId -WorkerName $worker.Name -WorkerStatus 'Running' -WorkerDetail $msg.LogMessage
							}
						}
					}
				}
			}
			catch {
				# Non-critical: don't let message scanning break the wait loop
				Write-PSFMessage -Level Verbose -Message "Error scanning PSFramework messages during Wait-ZtTest: $_" -ErrorRecord $_
			}
		}

		# Final summary update after the loop exits — ensures _inProgressItems is 0
		# and the dashboard shows correct totals before workers get cleared by next stage
		$finalCompleted = $Workflow.Queues["Results"].Count
		$finalFailed = ($failedTests.Keys | Measure-Object).Count
		Write-PSFMessage -Level VeryVerbose -Message "Wait-ZtTest is exiting after processing $finalCompleted out of $totalCount tests, with $finalFailed failures." -Target $Workflow
		Update-ZtProgressState -TotalItems $totalCount -CompletedItems ($finalCompleted - $finalFailed) -FailedItems $finalFailed -InProgressItems 0

		if ($Timeout -le ([DateTime]::Now - $StartedAt)) {
			Write-PSFMessage -Level Warning -Message "Timeout of $($Timeout) reached while waiting for tests to complete. Processed $($Workflow.Queues["Results"].Count) out of $totalCount tests (left $($Workflow.Queues["Input"].Count) to process)." -Target $Workflow
		}

		Write-Progress -Id $progressID -Activity "Processing $($totalCount) Tests" -Completed
	}
}
