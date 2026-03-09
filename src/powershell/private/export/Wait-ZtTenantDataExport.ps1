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
		$Workflow
	)
	begin {
		$failedExports = @{}
		$totalCount = $Workflow.Queues["Input"].TotalItemCount
		$progressID = Get-Random -Minimum 1 -Maximum 999
		$taskProgID = @{ }
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
				Write-PSFMessage -Level Warning -Message "Export '{0}' failed: {1}" -StringValues $failure.Name, $failure.Message
			}

			$status = "$($Workflow.Queues["Results"].Count) / $totalCount | Pending: $($countPending) | Waiting: $($countWaiting) | In Progress: $($countInProgress) | Done: $($countDone) | Failed: $($countFailed)"
			$percent = ($Workflow.Queues["Results"].Count / $totalCount * 100) -as [int]
			if ($percent -lt 0) { $percent = 0 }
			if ($percent -gt 100) { $percent = 100 }

			Write-Progress -Id $progressID -Activity "Processing $($totalCount) Exports" -Status $status -PercentComplete $percent

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

		Write-Progress -Id $progressID -Activity "Processing $($totalCount) Exports" -Completed
	}
}
