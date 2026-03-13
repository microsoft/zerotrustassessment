function Get-ZtProgressSnapshot {
	<#
	.SYNOPSIS
		Reads the progress state DCO and builds a JSON-serializable snapshot.

	.DESCRIPTION
		Reads all entries from the ProgressState ConcurrentDictionary and assembles
		them into a structured object suitable for JSON serialization.
		Workers are grouped by status (active, completed, failed).

		This function is designed to be called from the HTTP server background runspace.
		It receives the raw ConcurrentDictionary (not the DCO wrapper) as a parameter.

	.PARAMETER ProgressDict
		The ConcurrentDictionary backing the ProgressState DCO.

	.EXAMPLE
		PS C:\> Get-ZtProgressSnapshot -ProgressDict $dict | ConvertTo-Json -Depth 5

		Returns the current progress state as a JSON string.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[System.Collections.Concurrent.ConcurrentDictionary[string, object]]
		$ProgressDict
	)
	process {
		# Read stage metadata
		$stage = $null
		$null = $ProgressDict.TryGetValue('_stage', [ref]$stage)
		$stageNumber = 0
		$null = $ProgressDict.TryGetValue('_stageNumber', [ref]$stageNumber)
		$stageName = $null
		$null = $ProgressDict.TryGetValue('_stageName', [ref]$stageName)
		$totalStages = 6
		$null = $ProgressDict.TryGetValue('_totalStages', [ref]$totalStages)
		$startedAt = $null
		$null = $ProgressDict.TryGetValue('_startedAt', [ref]$startedAt)
		$totalItems = 0
		$null = $ProgressDict.TryGetValue('_totalItems', [ref]$totalItems)
		$completedItems = 0
		$null = $ProgressDict.TryGetValue('_completedItems', [ref]$completedItems)
		$failedItems = 0
		$null = $ProgressDict.TryGetValue('_failedItems', [ref]$failedItems)
		$inProgressItems = 0
		$null = $ProgressDict.TryGetValue('_inProgressItems', [ref]$inProgressItems)

		# Build enriched stages array from definitions
		$stageDefs = $null
		$null = $ProgressDict.TryGetValue('_stageDefinitions', [ref]$stageDefs)
		$stagesArray = @()
		if ($stageDefs) {
			$stagesArray = @(foreach ($sd in $stageDefs) {
				$stageStatus = 'pending'
				$stageLabel = $sd.name
				if ($stage -eq 'done') {
					$stageStatus = 'completed'
				}
				elseif ($sd.number -lt $stageNumber) {
					$stageStatus = 'completed'
				}
				elseif ($sd.number -eq $stageNumber) {
					$stageStatus = 'active'
					$stageLabel = $stageName
				}
				[PSCustomObject]@{
					number = $sd.number
					name   = $stageLabel
					status = $stageStatus
				}
			})
		}

		# Collect workers
		$workers = [System.Collections.Generic.List[object]]::new()
		foreach ($kvp in $ProgressDict) {
			if ($kvp.Key -like 'worker_*') {
				$workers.Add($kvp.Value)
			}
		}

		# Calculate percent
		$percent = 0
		if ($totalItems -gt 0) {
			$percent = [math]::Min(100, [math]::Floor(($completedItems + $failedItems) / $totalItems * 100))
		}

		[PSCustomObject]@{
			stage        = $stage
			stageNumber  = $stageNumber
			totalStages  = $totalStages
			stageName    = $stageName
			startedAt    = $startedAt
			percent      = $percent
			stages       = $stagesArray
			summary      = [PSCustomObject]@{
				total      = $totalItems
				completed  = $completedItems
				failed     = $failedItems
				inProgress = $inProgressItems
				pending    = [math]::Max(0, $totalItems - $completedItems - $failedItems - $inProgressItems)
			}
			workers      = @($workers | Sort-Object -Property @{Expression = {
				switch ($_.Status) {
					'Running'   { 0 }
					'Waiting'   { 1 }
					'InProgress' { 0 }
					'Pending'   { 2 }
					'Failed'    { 3 }
					'TimedOut'  { 4 }
					'Done'      { 5 }
					default     { 6 }
				}
			}}, @{Expression = { $_.UpdatedAt }; Descending = $true })
		}
	}
}
