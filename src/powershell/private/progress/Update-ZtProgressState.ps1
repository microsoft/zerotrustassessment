function Update-ZtProgressState {
	<#
	.SYNOPSIS
		Updates the shared progress state used by the web-based progress dashboard.

	.DESCRIPTION
		Writes structured progress data to the process-wide PSFDynamicContentObject dictionary.
		This function is safe to call from any thread (main or worker runspaces) because the
		underlying ConcurrentDictionary is thread-safe.

		The progress state is read by the HTTP server (Start-ZtProgressServer) and served
		as JSON to the browser-based dashboard.

	.PARAMETER Stage
		The current top-level stage identifier (e.g. 'export', 'database', 'tests', 'tenantinfo', 'results', 'html', 'done').

	.PARAMETER StageNumber
		The numeric stage number (1-6) for display.

	.PARAMETER StageName
		Human-readable stage name (e.g. 'Exporting Tenant Data').

	.PARAMETER TotalStages
		Total number of stages. Defaults to 6.

	.PARAMETER TotalItems
		Total number of work items in the current stage.

	.PARAMETER CompletedItems
		Number of completed work items in the current stage.

	.PARAMETER FailedItems
		Number of failed work items in the current stage.

	.PARAMETER InProgressItems
		Number of work items currently in progress.

	.PARAMETER WorkerId
		Unique identifier for a worker (test ID or export name).

	.PARAMETER WorkerName
		Display name for the worker.

	.PARAMETER WorkerStatus
		Status of the worker: Pending, Waiting, Running, Done, Failed, TimedOut.

	.PARAMETER WorkerDetail
		The current detail/step the worker is executing. This is shown as the 'flashing' detail line.

	.PARAMETER ClearWorkers
		If specified, removes all worker entries from the progress state. Used when transitioning between stages.

	.EXAMPLE
		PS C:\> Update-ZtProgressState -Stage 'export' -StageNumber 1 -StageName 'Exporting Tenant Data' -TotalItems 30

		Updates the top-level stage to 'export' with 30 total items.

	.EXAMPLE
		PS C:\> Update-ZtProgressState -WorkerId '21770' -WorkerName 'MFA Registration Policy' -WorkerStatus 'Running' -WorkerDetail 'Querying policies...'

		Updates the progress for a specific worker.
	#>
	[CmdletBinding()]
	param (
		[string]$Stage,
		[int]$StageNumber,
		[string]$StageName,
		[int]$TotalStages = 6,
		[int]$TotalItems,
		[int]$CompletedItems,
		[int]$FailedItems,
		[int]$InProgressItems,

		[string]$WorkerId,
		[string]$WorkerName,
		[string]$WorkerStatus,
		[string]$WorkerDetail,

		[switch]$ClearWorkers
	)
	process {
		$state = $script:__ZtSession.ProgressState

		if ($Stage) {
			$state.Value['_stage'] = $Stage
			$state.Value['_stageNumber'] = $StageNumber
			$state.Value['_stageName'] = $StageName
			$state.Value['_totalStages'] = $TotalStages

			# Only set _startedAt on the first stage transition so the dashboard
			# elapsed timer reflects total assessment time, not per-stage time.
			if (-not $state.Value.ContainsKey('_startedAt')) {
				$state.Value['_startedAt'] = (Get-Date).ToString('o')
			}

			# Write the full stage definitions so the dashboard can render all stages.
			# Stored as a JSON string (not hashtable array) for reliable cross-runspace access.
			# The server runspace parses this with ConvertFrom-Json to get PSCustomObjects with
			# reliable property access, avoiding the issue where hashtable .property returns $null
			# in isolated runspaces.
			$state.Value['_stageDefinitions'] = '[{"number":1,"name":"Exporting Tenant Data"},{"number":2,"name":"Running Tests"},{"number":3,"name":"Adding Tenant Information"},{"number":4,"name":"Generating Test Results"},{"number":5,"name":"Writing Report Data"},{"number":6,"name":"Generating HTML Report"}]'
		}

		if ($PSBoundParameters.ContainsKey('TotalItems')) {
			$state.Value['_totalItems'] = $TotalItems
		}
		if ($PSBoundParameters.ContainsKey('CompletedItems')) {
			$state.Value['_completedItems'] = $CompletedItems
		}
		if ($PSBoundParameters.ContainsKey('FailedItems')) {
			$state.Value['_failedItems'] = $FailedItems
		}
		if ($PSBoundParameters.ContainsKey('InProgressItems')) {
			$state.Value['_inProgressItems'] = $InProgressItems
		}

		if ($ClearWorkers) {
			$workerKeys = @($state.Value.Keys | Where-Object { $_ -like 'worker_*' -or $_ -like 'rs_*' })
			foreach ($key in $workerKeys) {
				$null = $state.Value.TryRemove($key, [ref]$null)
			}
		}

		if ($WorkerId) {
			$workerKey = "worker_$WorkerId"
			$now = (Get-Date).ToString('o')

			# Preserve StartedAt from the existing worker entry if it exists
			$startedAt = $now
			$existingWorker = $null
			if ($state.Value.TryGetValue($workerKey, [ref]$existingWorker) -and $existingWorker.StartedAt) {
				$startedAt = $existingWorker.StartedAt
			}

			$state.Value[$workerKey] = [PSCustomObject]@{
				Id        = $WorkerId
				Name      = $WorkerName
				Status    = $WorkerStatus
				Detail    = $WorkerDetail
				StartedAt = $startedAt
				UpdatedAt = $now
			}
		}
	}
}
