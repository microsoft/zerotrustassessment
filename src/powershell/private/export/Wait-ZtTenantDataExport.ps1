function Wait-ZtTenantDataExport {
	<#
	.SYNOPSIS
		Wait for the parallelized data export to complete.

	.DESCRIPTION
		Wait for the parallelized data export to complete.

	.PARAMETER Workflow
		The runspace workflow we are waiting to complete.

	.EXAMPLE
		PS C:\> Wait-ZtTenantDataExport -Workflow $workflow

		Wait for the parallelized data export to complete.
	#>
	[CmdletBinding()]
	param (
		[PSFramework.Runspace.RSWorkflow]
		$Workflow,

		[string]
		$LogsPath
	)
	begin {
		$failedExports = @{}
		$totalCount = $Workflow.Queues["Input"].TotalItemCount
		$progressID = Get-Random -Minimum 1 -Maximum 999
		$taskProgID = @{ }
		$lastMessageScan = [datetime]::MinValue
		$lastStatusSnapshot = [datetime]::MinValue

		# Initialize progress dashboard summary for the export stage
		Update-ZtProgressState -TotalItems $totalCount -CompletedItems 0 -FailedItems 0 -InProgressItems 0
	}
	process {
		Write-Progress -Id $progressID -Activity "Processing $($totalCount) Exports" -PercentComplete 0
		while (-not $Workflow.Queues["Results"].Closed) {
			Start-Sleep -Milliseconds 500

			$groups = $Workflow.Data.Values | Group-Object Status
			$countPending = @($groups).Where{$_.Name -eq 'Pending'}.Group.Count
			$countWaiting = @($groups).Where{$_.Name -eq 'Waiting'}.Group.Count
			$countInProgress = @($groups).Where{$_.Name -eq 'InProgress'}.Group.Count
			$countDone = @($groups).Where{$_.Name -eq 'Done'}.Group.Count
			$countFailed = @($groups).Where{$_.Name -eq 'Failed'}.Group.Count

			foreach ($failure in @($groups).Where{$_.Name -eq 'Failed'}.Group) {
				if ($failedExports[$failure.Name]) { continue }
				$failedExports[$failure.Name] = $true

				# SignIn timeout is expected for large tenants - log to file, not console WARNING
				if ($failure.Name -eq 'SignIn' -and $failure.Message -like '*HttpClient.Timeout*') {
					Write-ZtExportProgress -ExportName $failure.Name -LogsPath $LogsPath -Action Error -ErrorMessage "Timed out after 300s (Graph SDK limit). Partial data collected."
				} else {
					Write-PSFMessage -Level Warning -Message "Export '{0}' failed: {1}" -StringValues $failure.Name, $failure.Message
				}
			}

			$status = "$($Workflow.Queues["Results"].Count) / $totalCount | Pending: $($countPending) | Waiting: $($countWaiting) | In Progress: $($countInProgress) | Done: $($countDone) | Failed: $($countFailed)"
			$percent = ($Workflow.Queues["Results"].Count / $totalCount * 100) -as [int]
			if ($percent -lt 0) { $percent = 0 }
			if ($percent -gt 100) { $percent = 100 }

			Write-Progress -Id $progressID -Activity "Processing $($totalCount) Exports" -Status $status -PercentComplete $percent

			# Update progress dashboard summary counts
			Update-ZtProgressState -TotalItems $totalCount -CompletedItems $countDone -FailedItems $countFailed -InProgressItems ($countInProgress + $countWaiting)

			# Scan recent PSFMessages to update worker detail lines
			try {
				$recentMessages = Get-PSFMessage -Last 100 | Where-Object { $_.Timestamp -gt $lastMessageScan }
				$lastMessageScan = [datetime]::Now

				# Build runspace-to-export mapping from the progress state
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
						$exportName = $rsMappings[$rsId]
						$workerKey = "worker_$exportName"
						$worker = $null
						if ($script:__ZtSession.ProgressState.Value.TryGetValue($workerKey, [ref]$worker)) {
							if ($worker -and $worker.Status -in @('Running', 'InProgress', 'Waiting')) {
								Update-ZtProgressState -WorkerId $exportName -WorkerName $exportName -WorkerStatus $worker.Status -WorkerDetail $msg.LogMessage
							}
						}
					}
				}
			}
			catch {
				# Non-critical: don't let message scanning break the wait loop
			}

			# Write periodic status snapshot to export progress log (~every 60 seconds)
			if ($LogsPath -and ([datetime]::Now - $lastStatusSnapshot).TotalSeconds -ge 60) {
				$statusMsg = "Pending:$countPending Waiting:$countWaiting InProgress:$countInProgress Done:$countDone Failed:$countFailed"
				Write-ZtExportProgress -ExportName '_overall_' -LogsPath $LogsPath -Action Status -StatusMessage $statusMsg
				$lastStatusSnapshot = [datetime]::Now
			}

			foreach ($task in $Workflow.Data.Values) {
				if ($task.Status -in 'Waiting', 'InProgress') {
					if (-not $taskProgID[$task.Name]) {
						$taskProgID[$task.Name] = Get-Random -Minimum 1000 -Maximum 9999
					}
					Write-Progress -Id $taskProgID[$task.Name] -ParentId $progressID -Activity "$($task.Name) : $($task.Status)" -Status "$((Get-Date) - $task.Updated)" -PercentComplete 0
				}
				if ($task.Status -notin 'Waiting', 'InProgress' -and $taskProgID[$task.Name]) {
					Write-Progress -Id $taskProgID[$task.Name] -ParentId $progressID -Completed
					$taskProgID.Remove($task.Name)
				}
			}
		}

		# Final summary update after the loop exits — ensures _inProgressItems is 0
		# and the dashboard shows correct totals before workers get cleared by next stage
		$finalGroups = $Workflow.Data.Values | Group-Object Status
		$finalDone = @($finalGroups).Where{$_.Name -eq 'Done'}.Group.Count
		$finalFailed = @($finalGroups).Where{$_.Name -eq 'Failed'}.Group.Count
		Update-ZtProgressState -TotalItems $totalCount -CompletedItems $finalDone -FailedItems $finalFailed -InProgressItems 0

		Write-Progress -Id $progressID -Activity "Processing $($totalCount) Exports" -Completed
	}
}
