function Start-ZtProgressServer {
	<#
	.SYNOPSIS
		Starts a local HTTP server that serves the progress dashboard.

	.DESCRIPTION
		Creates a background runspace running a System.Net.HttpListener that serves:
		  GET /              - The progress dashboard HTML page
		  GET /api/progress  - JSON snapshot of current progress state

		The server reads from the ProgressState ConcurrentDictionary which is shared
		across all runspaces in the process via PSFDynamicContentObject.

		The server tries ports 8924-8934 and uses the first available one.

	.EXAMPLE
		PS C:\> Start-ZtProgressServer

		Starts the progress server and prints the URL to the console.
	#>
	[CmdletBinding()]
	param ()
	process {
		# Load the HTML content from the assets folder
		$htmlPath = Join-Path $script:ModuleRoot 'assets' 'progress.html'
		if (-not (Test-Path $htmlPath)) {
			Write-PSFMessage -Level Warning -Message "Progress dashboard HTML not found at '$htmlPath'. Progress server will not start."
			return
		}
		$htmlContent = [System.IO.File]::ReadAllText($htmlPath)

		# Get the ConcurrentDictionary backing the ProgressState DCO
		$progressDict = $script:__ZtSession.ProgressState.Value

		# Try to find an available port
		$selectedPort = $null
		foreach ($port in 8924..8934) {
			try {
				$testListener = [System.Net.HttpListener]::new()
				$testListener.Prefixes.Add("http://localhost:$port/")
				$testListener.Start()
				$testListener.Stop()
				$testListener.Close()
				$selectedPort = $port
				break
			}
			catch {
				continue
			}
		}

		if (-not $selectedPort) {
			Write-PSFMessage -Level Warning -Message "Could not find an available port (tried 8924-8934). Progress server will not start."
			return
		}

		$url = "http://localhost:$selectedPort"

		# Create a dedicated runspace for the HTTP server
		$runspace = [runspacefactory]::CreateRunspace()
		$runspace.Name = 'ZtProgressServer'
		$runspace.Open()

		$ps = [powershell]::Create()
		$ps.Runspace = $runspace

		$null = $ps.AddScript({
			param(
				[System.Collections.Concurrent.ConcurrentDictionary[string, object]]$ProgressDict,
				[string]$HtmlContent,
				[int]$Port
			)

			$listener = [System.Net.HttpListener]::new()
			$listener.Prefixes.Add("http://localhost:$Port/")

			try {
				$listener.Start()

				while ($listener.IsListening) {
					try {
						# Use GetContextAsync with a short wait to allow checking IsListening
						$contextTask = $listener.GetContextAsync()
						while (-not $contextTask.AsyncWaitHandle.WaitOne(500)) {
							if (-not $listener.IsListening) { return }
						}
						$context = $contextTask.GetAwaiter().GetResult()
					}
					catch [System.Net.HttpListenerException] {
						# Listener was stopped
						break
					}
					catch [System.ObjectDisposedException] {
						break
					}
					catch {
						continue
					}

					try {
						$request = $context.Request
						$response = $context.Response
						$localPath = $request.Url.LocalPath

						# CORS headers
						$response.Headers.Add('Access-Control-Allow-Origin', '*')
						$response.Headers.Add('Cache-Control', 'no-cache, no-store, must-revalidate')

						if ($localPath -eq '/api/progress') {
							# Build JSON snapshot from the ConcurrentDictionary
							$response.ContentType = 'application/json; charset=utf-8'

							# Read stage metadata
							$stage = $null; $null = $ProgressDict.TryGetValue('_stage', [ref]$stage)
							$stageNumber = 0; $null = $ProgressDict.TryGetValue('_stageNumber', [ref]$stageNumber)
							$stageName = $null; $null = $ProgressDict.TryGetValue('_stageName', [ref]$stageName)
							$totalStages = 6; $null = $ProgressDict.TryGetValue('_totalStages', [ref]$totalStages)
							$startedAt = $null; $null = $ProgressDict.TryGetValue('_startedAt', [ref]$startedAt)
							$totalItems = 0; $null = $ProgressDict.TryGetValue('_totalItems', [ref]$totalItems)
							$completedItems = 0; $null = $ProgressDict.TryGetValue('_completedItems', [ref]$completedItems)
							$failedItems = 0; $null = $ProgressDict.TryGetValue('_failedItems', [ref]$failedItems)
							$inProgressItems = 0; $null = $ProgressDict.TryGetValue('_inProgressItems', [ref]$inProgressItems)

							# Build enriched stages array from definitions
							# _stageDefinitions is stored as a JSON string for cross-runspace safety.
							# Parse it here with ConvertFrom-Json so we get PSCustomObjects with reliable
							# .number and .name property access in this isolated runspace.
							$stageDefsJson = $null; $null = $ProgressDict.TryGetValue('_stageDefinitions', [ref]$stageDefsJson)
							$stagesArray = [System.Collections.Generic.List[object]]::new()
							if ($stageDefsJson) {
								$stageDefs = $stageDefsJson | ConvertFrom-Json
								foreach ($sd in $stageDefs) {
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
										$stageLabel = $stageName  # Use the current sub-stage name (e.g. 'Importing Data into Database')
									}
									$stagesArray.Add(@{
										number = $sd.number
										name   = $stageLabel
										status = $stageStatus
									})
								}
							}

							# Collect workers - use .Keys and TryGetValue for cross-runspace safety
							$workers = [System.Collections.Generic.List[object]]::new()
							foreach ($key in @($ProgressDict.Keys)) {
								if ($key.StartsWith('worker_')) {
									$w = $null
									if ($ProgressDict.TryGetValue($key, [ref]$w) -and $null -ne $w) {
										$workers.Add(@{
											id        = $w.Id
											name      = $w.Name
											status    = $w.Status
											detail    = $w.Detail
											startedAt = $w.StartedAt
											updatedAt = $w.UpdatedAt
										})
									}
								}
							}

							$percent = 0
							if ($totalItems -gt 0) {
								$percent = [math]::Min(100, [math]::Floor(($completedItems + $failedItems) / $totalItems * 100))
							}

							$snapshot = @{
								stage       = $stage
								stageNumber = $stageNumber
								totalStages = $totalStages
								stageName   = $stageName
								startedAt   = $startedAt
								percent     = $percent
								stages      = @($stagesArray)
								summary     = @{
									total      = $totalItems
									completed  = $completedItems
									failed     = $failedItems
									inProgress = $inProgressItems
									pending    = [math]::Max(0, $totalItems - $completedItems - $failedItems - $inProgressItems)
								}
								workers     = @($workers)
							}

							$json = $snapshot | ConvertTo-Json -Depth 5 -Compress
							$buffer = [System.Text.Encoding]::UTF8.GetBytes($json)
							$response.ContentLength64 = $buffer.Length
							$response.OutputStream.Write($buffer, 0, $buffer.Length)
						}
						elseif ($localPath -eq '/' -or $localPath -eq '/index.html') {
							# Serve the progress dashboard HTML
							$response.ContentType = 'text/html; charset=utf-8'
							$buffer = [System.Text.Encoding]::UTF8.GetBytes($HtmlContent)
							$response.ContentLength64 = $buffer.Length
							$response.OutputStream.Write($buffer, 0, $buffer.Length)
						}
						else {
							$response.StatusCode = 404
							$buffer = [System.Text.Encoding]::UTF8.GetBytes('Not Found')
							$response.ContentLength64 = $buffer.Length
							$response.OutputStream.Write($buffer, 0, $buffer.Length)
						}
					}
					catch {
						# Best effort: don't crash the server on a single bad request
					}
					finally {
						try { $response.OutputStream.Close() } catch { }
					}
				}
			}
			finally {
				# Ensure the port is released regardless of how the server exits —
				# normal loop exit, exception, or forced PowerShell.Stop() (PipelineStoppedException).
				try { $listener.Stop() } catch { }
				try { $listener.Close() } catch { }
			}
		}).AddArgument($progressDict).AddArgument($htmlContent).AddArgument($selectedPort)

		# Start the server asynchronously
		$asyncResult = $ps.BeginInvoke()

		# Store server state for later cleanup
		$script:__ZtSession.ProgressServer = @{
			PowerShell  = $ps
			Runspace    = $runspace
			AsyncResult = $asyncResult
			Port        = $selectedPort
			Url         = $url
		}

		Write-Host
		Write-Host "Progress dashboard: " -NoNewline -ForegroundColor White
		Write-Host $url -ForegroundColor Cyan
		Write-Host

		# Auto-open the progress dashboard in the default browser
		Start-Process $url
	}
}
