function Invoke-ZtGraphBatchRequest {
	<#
	.SYNOPSIS
		Executes a graph Batch requests, sending multiple requests in a single invocation.

	.DESCRIPTION
		Executes a graph Batch requests, sending multiple requests in a single invocation.
		This allows optimizing code performance, where iteratively sending requests does not scale.

		There are two ways to call this command:
		+ By providing the full request (by using the "-Request" parameter)
		+ By Providing a Path with placeholders and for multiple items calculate the actual url based on inserting the values into the placeholder positions (by using the "-Path" parameter)

		See the documentation on the respective parameters or the example on how to use them.

		Up to 20 requests can be sent in one batch, but this command will automatically split larger workloads into separate
		sets of 20 before sending them.

	.PARAMETER Request
		The requests to send. Provide either a url string or a request hashtables with any combination of the following keys:
		+ id:        A nonempty string correlation ID, unique without regard to case. Generated if omitted.
		+ method:    The REST method to use (GET, POST, PATCH, ...)
		+ url:       The relative url to call
		+ body:      The body to provide with the request
		+ headers:   Headers to include with the request
		+ dependsOn: The id of another request that must be successful, in order to run this request. Prevents executing requests invalidated by another request's failure.

		Dependency IDs are normalized to strings. Workloads containing dependencies must fit within one batch of 20 requests.
		Dependencies must reference other requests in the same workload.

		The only mandatory value to provide (whether as plain string or via hashtable) is the "url".
		The rest are filled by default values either provided via other parameters (Method, Body, Header) or the system (id) or omitted (dependsOn).

		In all cases, "url" should be the relative path - e.g. "users" - and NOT the absolute one (e.g. "https://graph.microsoft.com/v1.0/users")

		For more documentation on the properties, see the online documentation on batch requests:
		https://learn.microsoft.com/en-us/graph/json-batching

	.PARAMETER Path
		The path(s) to execute for each item in ArgumentList against.
		Example: "users/{0}/authentication/methods"
		Assuming a list of 50 user IDs, this will then insert the respective IDs into the url when building the request batches.
		After which it would execute the 50 paths in three separate batches (20 / 20 / 10 | Due to the 20 requests per batch limit enforced by the API).

		In combination with the "-Properties" parameter, it is also possible to insert multiple values per path.
		Example: "sites/{0}/lists/{1}/items?expand=fields"
		Assuming the parameter "-Properties" contains "'SiteID', 'ListID'" and the ArgumentList provides objects that contain those properties, this allows bulkrequesting all items from many lists in one batch.

		All requests generated from this parameter use the default Method, Body & Header provided via the parameters of the same name.

	.PARAMETER ArgumentList
		The list of values, for each of which for each "-Path" provided a request is sent.
		In combination with the "-Properties" parameter, you can also select one or more properties from these objects to format into the path,
		rather than inserting the full value of the argument.

	.PARAMETER Properties
		The properties from the arguments provided via "-ArgumentList" to format into the paths provided.
		This allows inserting multiple values into the request url.

	.PARAMETER Method
		The default method to use for batched requests, if not defined otherwise in the request.
		Defaults to "GET"

	.PARAMETER Body
		The default body to provide with batched requests, if not defined otherwise in the request.
		Defaults to not being specified at all.

	.PARAMETER Header
		The default header to provide with batched requests, if not defined otherwise in the request.
		Defaults to not being specified at all.

	.PARAMETER Timeout
		How long to retry batched requests that are being throttled or return retryable transient errors.
		By default, requests are re-attempted until 5 minutes have expired (specifically, until the "notAfter" response would lead the next attempt beyond that time limit).
		Set to 0 minutes to never retry throttled or transient member responses.

	.PARAMETER Matched
		Rather than returning the results alone, match the results to the input object.
		This will create a custom object with ...
		- Id: The batch ID (generally cosmetic).
		- Argument: The original value provided to "-ArgumentList" or "-Request".
		- Result: The return value (if any) or the error result.
		- Success: Boolean truth of whether the request was successful.

	.PARAMETER Raw
		Do not process the responses provided by the batched requests.
		This will cause the batching metadata to be included with the actual result data.
		This can be useful to correlate responses to the original requests.

	.PARAMETER NoPaging
		Disables paging for each individual request.
		If not specified, all batches that has more data will automatically page through all pages, until there is no more data.

	.PARAMETER ApiVersion
		The Graph API version used for the batch endpoint. Defaults to v1.0.

	.PARAMETER OutputType
		The SDK response representation: PSObject, PSCustomObject, or Hashtable.
		PSCustomObject is an alias for the SDK's PSObject representation.
		Defaults to Hashtable to preserve existing private-helper callers.

	.NOTES
		Incomplete or invalid member responses fail the submitted batch without resubmission.
		Under nonterminating error handling, each affected request receives an error targeting its batch request descriptor.
		GET and HEAD members returning 500, 502, 503 or 504 allow five retries per page, within Timeout.
		Retry delays use the greater of exponential backoff (3, 6, 12, 24, 48 seconds) and Retry-After seconds or an HTTP date.
		Successful and terminal members are not resent. Exhausted transient members retain the existing failure output behavior.
		Queued transient timeout returns the final response in Raw or Matched mode; plain output receives a TransientRetriesExhausted error.
		Member 429 handling is unchanged; writes are not retried for transient 5xx member responses.
		Outer transport failures use Invoke-ZtRetry only when every submitted member is GET or HEAD.
		Intermediate retry errors are isolated from caller error variables when the batch recovers.
		Batches containing writes are not replayed by this helper after an outer failure.
		Successful prerequisites are not replayed for dependent retries; their dependency references are removed.
		Failed-dependency responses wait for pending prerequisites to recover and are not retried after a prerequisite fails permanently.
		Pending dependencies that cannot be submitted together are rejected rather than sent as dangling references.

	.EXAMPLE
		PS C:\> Invoke-ZtGraphBatchRequest -Path 'users/{0}/authentication/methods' -ArgumentList $users.id

		Retrieves the authentication methods for all users in $users

	.EXAMPLE
		PS C:\> Invoke-ZtGraphBatchRequest -Path 'users/{0}/authentication/methods' -ArgumentList $users.id -Matched

		Retrieves the authentication methods for all users in $users.
		Will return a set of objects, matching the authentication methods to the ID of the user.

	.EXAMPLE
		PS C:\> Invoke-ZtGraphBatchRequest -Path 'users/{0}/authentication/methods' -ArgumentList $users -Properties id -Matched

		Retrieves the authentication methods for all users in $users.
		Will return a set of objects, matching the authentication methods to the user object.

	.EXAMPLE
		PS C:\> Invoke-ZtGraphBatchRequest -Path 'users/{0}/authentication/methods' -ArgumentList $users -Properties id -ServiceMap GraphBeta

		Retrieves the authentication methods for all users in $users while using the GraphBeta EntraAuth service.

	.EXAMPLE
		PS C:\> Invoke-ZtGraphBatchRequest -Path 'sites/{0}/lists/{1}/items?expand=fields' -ArgumentList $lists -Properties SiteID, ListID

		Retrieves all the items from all lists in $lists.
		Assumes that each object in $lists has the properties "SiteID" and "ListID" (not case sensitive).

	.EXAMPLE
		PS C:\> $requests = @(
			@{
				url    = "users"
				method = "GET"
			},
			@{
				url     = "users?`$filter=country eq 'Denmark' and accountEnabled eq true and startswith(jobTitle, 'TECH') and onPremisesSyncEnabled eq true&`$select=id,displayName,userPrincipalName&`$expand=memberOf&`$count=true"
				method  = "GET"
				headers = @{
					"ConsistencyLevel" = "eventual"
					"Content-Type"     = "application/json"
				}
			},
			@{
				url     = "users"
				method  = "PATCH"
				body    = @{
					businessPhones = @(
						"+1 425 555 0109"
					)
					officeLocation = "18/2111"
				}
				headers = @{ "Content-Type" = "application/json" }
			},
			@{
				url    = "users/{user-id}"
				method = "DELETE"
			},
			@{
				url    = "groups"
				method = "POST"
				body   = @{
					description     = "Self help community for library"
					displayName     = "Library Assist"
					groupTypes      = @(
						"Unified"
					)
					mailEnabled     = $true
					mailNickname    = "library"
					securityEnabled = $false
				}
			},
			@{
				url     = "users/{user-id}/manager/´$ref"
				method  = "PUT"
				body    = @{
					"@odata.id" = "https://graph.microsoft.com/v1.0/users/{manager-id}"
				}
				headers = @{
					"Content-Type" = "application/json"
				}
			}
		)
		PS C:\> Invoke-ZtGraphBatchRequest -Request $requests -Method GET -Header @{ 'Content-Type' = 'application/json' }

		Executes all the requests provided in $requests, defaulting to the method "GET" and providing the content-type via header,
		unless otherwise specified in individual requests.

	.EXAMPLE
		PS C:\> $requests = @(
			@{ url = 'users/12345'; method = 'GET' },
			@{ url = 'users/67890'; method = 'GET' }
		)
		PS C:\> Invoke-ZtGraphBatchRequest -Request $requests -Method GET -Raw

		Executes both requests in one batch, returning the raw response as provided.

	.LINK
		https://learn.microsoft.com/en-us/graph/json-batching
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Request')]
		[object[]]
		$Request,

		[Parameter(Mandatory = $true, ParameterSetName = 'Path')]
		[string[]]
		$Path,

		[Parameter(Mandatory = $true, ParameterSetName = 'Path')]
		[object[]]
		$ArgumentList,

		[Parameter(ParameterSetName = 'Path')]
		[Alias('Property')]
		[string[]]
		$Properties,

		[Microsoft.PowerShell.Commands.WebRequestMethod]
		$Method = 'Get',

		[hashtable]
		$Body,

		[hashtable]
		$Header,

		[timespan]
		$Timeout = '00:05:00',

		[switch]
		$Matched,

		[switch]
		$Raw,

		[ValidateSet('v1.0', 'beta')]
		[string]
		$ApiVersion = 'v1.0',

		[ValidateSet('PSObject', 'PSCustomObject', 'Hashtable')]
		[string]
		$OutputType = 'Hashtable',

		[switch]
		$NoPaging
	)
	begin {
		#region Utility Functions
		function ConvertFrom-PathRequest {
			<#
			.SYNOPSIS
				Convert a combination of path and argument into a batch request task.

			.DESCRIPTION
				Convert a combination of path and argument into a batch request task.

			.PARAMETER Path
				The path to add argument data to.

			.PARAMETER Argument
				The argument to insert values from into the path.

			.PARAMETER Parameters
				The parameters provided to the Invoke-EagBatchRequest.

			.PARAMETER TaskList
				The overall list of tasks to add the new task to.

			.PARAMETER Tracking
				Hashtable to track what batch request id was already assigned.
				Needs to be tracked to prevent accidentally assigning the same id multiple times.

			.EXAMPLE
				PS C:\> ConvertFrom-PathRequest -Path $pathItem -Argument $argumentItem -Parameters $parameters -TaskList $allTasks -Tracking $idTracking

				Combines $pathItem and $argumentItem into a batch request task.
			#>
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				$Path,

				[Parameter(Mandatory = $true)]
				$Argument,

				[Parameter(Mandatory = $true)]
				[hashtable]
				$Parameters,

				[Parameter(Mandatory = $true)]
				[AllowEmptyCollection()]
				[System.Collections.Generic.List[object]]
				$TaskList,

				[hashtable]
				$Tracking
			)
			process {
				$task = [PSCustomObject]@{
					PSTypeName = 'ZeroTrustAssessment.Graph.BatchTask'
					# Core Settings
					Id         = $Tracking.CurrentID
					Method     = $Parameters.Method
					Url        = $null
					Body       = $Parameters.Body
					Header     = $Parameters.Header
					DependsOn  = $null

					Batch      = $null

					# Operations
					Result     = @()
					Start      = $null
					WaitUntil  = $null
					WaitLimit  = $null
					TransientRetries = 0
					LastTransientResponse = $null
					LastDependencyResponse = $null

					# Metadata
					Argument   = $Argument
					Path       = $Path
					Request    = $null
					Parameters = $Parameters
				}
				$Tracking.CurrentID += 1
				$values = $Argument
				if ($Parameters.Properties) {
					$values = foreach ($property in $Parameters.Properties) {
						$Argument.$property
					}
				}
				$task.Url = $Path -f $values
				# Url Cleanup. Beta/v1.0 is handled at the batch request itself.
				if ($task.Url -match '^https:') {
					$task.Url = ($task.Url -replace '^https://' -split '/', 3)[-1]
				}
				if ($task.Url -match '^beta/|^v1.0/') {
					$task.Url = ($task.Url -split '/',2)[1]
				}

				$batch = @{
					id     = $task.Id -as [string]
					method = "$($task.Method)".ToUpper()
					url    = $task.Url
				}
				if ($task.Body) {
					$batch.body = $task.Body
				}
				if ($task.Header) {
					$batch.headers = $task.Header
				}
				$task.Batch = $batch

				$TaskList.Add($task)
			}
		}

		function ConvertTo-BatchRequest {
			<#
			.SYNOPSIS
				Converts raw batch requests provided by the user into a task object.

			.DESCRIPTION
				Converts raw batch requests provided by the user into a task object.
				Needed for later task processing (especially paging).
				Task object will be added to the task-list provided.

			.PARAMETER Request
				The Request object to convert.

			.PARAMETER Parameters
				The parameters provided to the Invoke-EagBatchRequest.

			.PARAMETER TaskList
				The overall list of tasks to add the new task to.

			.PARAMETER Tracking
				Hashtable to track what batch request id was already assigned.
				Needs to be tracked to prevent accidentally assigning the same id multiple times.

			.EXAMPLE
				PS C:\> ConvertTo-BatchRequest -Request $requestItem -Parameters $parameters -TaskList $allTasks -Tracking $idTracking

				Converts the specified request item into a task object and adds it to $allTasks.
			#>
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				$Request,

				[Parameter(Mandatory = $true)]
				[hashtable]
				$Parameters,

				[Parameter(Mandatory = $true)]
				[AllowEmptyCollection()]
				[System.Collections.Generic.List[object]]
				$TaskList,

				[hashtable]
				$Tracking
			)
			process {
				$task = [PSCustomObject]@{
					PSTypeName = 'ZeroTrustAssessment.Graph.BatchTask'
					# Core Settings
					Id         = $null
					Method     = $Parameters.Method
					Url        = $null
					Body       = $Parameters.Body
					Header     = $Parameters.Header
					DependsOn  = $null

					Batch      = $null

					# Operations
					Result     = @()
					Start      = $null
					WaitUntil  = $null
					WaitLimit  = $null
					TransientRetries = 0
					LastTransientResponse = $null
					LastDependencyResponse = $null

					# Metadata
					Argument   = $Request
					Path       = $null
					Request    = $Request
					Parameters = $Parameters
				}

				#region ID
				if ($null -ne $Request.id) {
					$task.Id = [string]$Request.id
					if ([string]::IsNullOrWhiteSpace($task.Id) -or $task.Id -in $TaskList.Id) {
						throw [System.ArgumentException]::new('Batch request IDs must be nonempty and unique.')
					}
				}
				else {
					while ([string]$Tracking.CurrentID -in $Tracking.ReservedIDs -or [string]$Tracking.CurrentID -in $TaskList.Id) {
						$Tracking.CurrentID++
					}
					$task.Id = $Tracking.CurrentID
				}
				$Tracking.CurrentID++
				#endregion ID

				#region Other Metadata
				if ($Request.Method) {
					$task.Method = $Request.Method
				}
				if ($Request.Body) {
					$task.Body = $Request.Body
				}
				if ($Request.Headers) {
					$task.Header = $Request.Headers
				}
				if ($Request -is [string]) {
					$task.Url = $Request
				}
				elseif ($Request.Url) {
					$task.Url = $Request.url
				}
				elseif ($Request -is [uri]) {
					$task.Url = $Request -as [string]
				}
				else {
					Stop-PSFFunction -Cmdlet $Cmdlet -Message "Invalid batch request: No Url found! $Request" -Category InvalidArgument -EnableException+ $true
				}

				# Url Cleanup. Beta/v1.0 is handled at the batch request itself.
				if ($task.Url -match '^https:') {
					$task.Url = ($task.Url -replace '^https://' -split '/', 3)[-1]
				}
				if ($task.Url -match '^beta/|^v1.0/') {
					$task.Url = ($task.Url -split '/',2)[1]
				}

				if ($null -ne $Request.DependsOn) {
					$task.DependsOn = @($Request.DependsOn | ForEach-Object { [string]$_ })
				}
				#endregion Other Metadata

				$batch = @{
					id     = $task.Id -as [string]
					method = "$($task.Method)".ToUpper()
					url    = $task.Url
				}
				if ($task.Body) {
					$batch.body = $task.Body
				}
				if ($task.Header) {
					$batch.headers = $task.Header
				}
				if ($null -ne $task.DependsOn) {
					$batch.dependsOn = @($task.DependsOn)
				}
				$task.Batch = $batch

				$TaskList.Add($task)
			}
		}

		function Get-NextBatch {
			[CmdletBinding()]
			param (
				$Tasks,

				[System.Collections.Generic.List[object]]
				$ExpiredTransientTasks,

				$Cmdlet
			)

			$count = 0
			$selectedTasks = [System.Collections.Generic.List[object]]::new()
			$now = Get-Date
			foreach ($task in $Tasks) {
				if ($task.LastDependencyResponse -and $task.Batch.dependsOn.Count -gt 0) {
					continue
				}
				if ($task.LastTransientResponse -and $task.WaitLimit -le $now) {
					continue
				}
				if ($task.WaitUntil -and $task.WaitUntil -gt $now) {
					continue
    } # Not ready yet
				if ($task.WaitUntil -and $task.WaitLimit -lt $now) {
					continue
    } # We waited too long already
				if ($task.WaitUntil -and $task.WaitLimit -lt $task.WaitUntil) {
					continue
    } # Waiting will take longer than we are willing to wait

				$selectedTasks.Add($task)
				$count++

				if ($count -ge 20) {
					break
    }
			}

			# Cleanup Throttling Limits
			foreach ($task in $Tasks.ToArray()) {
				if (-not $task.WaitUntil) {
					continue
    }
				if ($task.WaitLimit -gt $now -and $task.WaitUntil -lt $task.WaitLimit) {
					continue
    }

				$null = $Tasks.Remove($task)
				if ($task.LastTransientResponse) {
					$ExpiredTransientTasks.Add($task)
					continue
				}
				$Cmdlet.WriteError(
					[System.Management.Automation.ErrorRecord]::new(
						[Exception]::new("Retries for throttling exceeded, giving up on: $($task.id)"),
						"ThrottlingRetriesExhausted",
						[System.Management.Automation.ErrorCategory]::LimitsExceeded,
						$task
					)
				)
			}
			foreach ($task in $selectedTasks) {
				foreach ($dependency in $task.Batch.dependsOn) {
					if ($dependency -notin $selectedTasks.Id) {
						throw [System.InvalidOperationException]::new('Pending dependent requests cannot be submitted separately from their prerequisites.')
					}
				}
			}
			$selectedTasks.ToArray()
		}

		function Invoke-GraphBatch {
			<#
			.SYNOPSIS
				Executes a batch graph request.

			.DESCRIPTION
				Executes a batch graph request.
				Expects the batches to be presized to its natural limit (20) and correctly designed.

			.PARAMETER Tasks
				The tasks to execute.
				Expects the result objects of either ConvertFrom-PathRequest or ConvertTo-BatchRequest.

			.PARAMETER TaskList
				The entire list of tasks that need batching.
				Tasks that have completed - including any paging that needs doing - should be removed from this list.

			.PARAMETER Cmdlet
				The $PSCmdlet variable of the calling command, to make sure all errors happen within the context of the caller
				and hence respect the ErrorActionPreference of the same.

			.EXAMPLE
				PS C:\> Invoke-GraphBatch -Tasks $tasks -TaskList $allTasks -ServiceMap $services -Cmdlet $PSCmdlet

				Executes all tasks in $tasks
			#>
			[CmdletBinding()]
			param (
				[object[]]
				$Tasks,

				[System.Collections.Generic.List[object]]
				$TaskList,

				[ValidateSet('v1.0', 'beta')]
				[string]
				$ApiVersion = 'v1.0',

				[string]
				$OutputType,

				[Parameter(Mandatory = $true)]
				$Cmdlet
			)
			process {
				$start = Get-Date
				foreach ($task in $Tasks) {
					$task.LastDependencyResponse = $null
					if (-not $task.Start) {
						$task.Start = $start
						$task.WaitLimit = $start.Add($task.Parameters.Timeout)
					}
				}
				$transportParameters = @{
					Uri = "$ApiVersion/`$batch"
					Method = 'Post'
					Body = @{ requests = @($Tasks.Batch) }
					ContentType = 'application/json'
					OutputType = $(if ($OutputType -eq 'PSCustomObject') { 'PSObject' } else { $OutputType })
					ErrorAction = 'Stop'
				}
				$innerResult = try {
					if (@($Tasks | Where-Object { $_.Batch.method -notin 'GET', 'HEAD' }).Count -eq 0) {
						$retryPipeline = [System.Management.Automation.PowerShell]::Create([System.Management.Automation.RunspaceMode]::CurrentRunspace)
						try {
							$null = $retryPipeline.AddCommand('Invoke-Command').AddParameter('ScriptBlock', {
								param($Parameters)
								try { @{ Response = Invoke-ZtRetry -ScriptBlock { Microsoft.Graph.Authentication\Invoke-MgGraphRequest @Parameters } } }
								catch { @{ ErrorRecord = $_ } }
							}).AddParameter('ArgumentList', @($transportParameters))
							$retryResult = $retryPipeline.Invoke()[0]
						}
						finally { $retryPipeline.Dispose() }
						if ($retryResult.ErrorRecord) { throw $retryResult.ErrorRecord }
						$response = $retryResult.Response
					}
					else { $response = Microsoft.Graph.Authentication\Invoke-MgGraphRequest @transportParameters }
					$response.responses
				}
				catch {
					$Cmdlet.WriteError(
						[System.Management.Automation.ErrorRecord]::new(
							[Exception]::new("Error sending batch: $($_.Exception.Message)", $_.Exception),
							"$($_.FullyQualifiedErrorId)",
							$_.CategoryInfo.Category,
							@{ requests = @($Tasks.Batch) }
						)
					)
					# Remove workload to prevent infinite loop
					foreach ($task in $Tasks) {
						$null = $TaskList.Remove($task)
					}
					return
				}

				$submittedIDs = @{}
				foreach ($task in $Tasks) {
					$submittedIDs[[string]$task.Batch.id] = $task
				}
				$returnedIDs = @{}
				$invalidResponse = $false
				foreach ($result in $innerResult) {
					$responseID = [string]$result.id
					$status = 0
					if (-not $submittedIDs.ContainsKey($responseID) -or $returnedIDs.ContainsKey($responseID) -or
						-not [int]::TryParse([string]$result.status, [ref]$status) -or $status -lt 200 -or $status -gt 599) {
						$invalidResponse = $true
					}
					$returnedIDs[$responseID] = $true
				}
				if ($invalidResponse -or $returnedIDs.Count -ne $submittedIDs.Count) {
					foreach ($task in $Tasks) {
						$null = $TaskList.Remove($task)
					}
					foreach ($task in $Tasks) {
						$Cmdlet.WriteError([System.Management.Automation.ErrorRecord]::new(
							[System.IO.InvalidDataException]::new('Batch response is incomplete or contains invalid or duplicate member IDs or statuses.'),
							'InvalidGraphBatchResponse',
							[System.Management.Automation.ErrorCategory]::InvalidData,
							$task.Batch
						))
					}
					return
				}

				if ($Tasks[0].Parameters.HasDependencies) {
					$successfulIDs = @($innerResult | Where-Object { $_.status -ge 200 -and $_.status -le 299 } | ForEach-Object { [string]$_.id })
					foreach ($pendingTask in $TaskList) {
						if (-not $pendingTask.Batch.ContainsKey('dependsOn')) {
							continue
						}
						$remainingDependencies = @($pendingTask.Batch.dependsOn | Where-Object { $_ -notin $successfulIDs })
						$retryBatch = $pendingTask.Batch.Clone()
						if ($remainingDependencies.Count -gt 0) {
							$retryBatch.dependsOn = $remainingDependencies
						}
						else {
							$retryBatch.Remove('dependsOn')
						}
						$pendingTask.Batch = $retryBatch
					}
				}

				foreach ($result in $innerResult) {
					$task = $submittedIDs[[string]$result.id]

					#region Case: Success
					if (200 -le $result.status -and 299 -ge $result.status) {
						$task.TransientRetries = 0
						$task.LastTransientResponse = $null
						$task.WaitUntil = $null
						# Update for paging or complete task
						if ($result.body.'@odata.nextLink' -and -not $task.Parameters.NoPaging) {
							$task.Batch.url = ($result.body.'@odata.nextLink' -replace '^https://' -split '/', 3)[-1]
						}
						else {
							$null = $TaskList.Remove($task)
						}

						# Raw Output
						if ($task.Parameters.Raw) {
							$result
							continue
						}

						# Matched Output
						if ($task.Parameters.Matched) {
							$data = $result.body
							if (($data -is [System.Collections.IDictionary] -and $data.Contains('value')) -or
								$data.PSObject.Properties.Name -contains 'value') {
								$data = $data.value
							}
							if (-not $task.Result) {
								$task.Result = @($data)
							}
							else {
								$task.Result = $task.Result + @($data)
							}

							# Only return matched result after completing the batching
							if ($result.body.'@odata.nextLink' -and -not $task.Parameters.NoPaging) {
								continue
							}

							[PSCustomObject]@{
								PSTypeName = 'ZeroTrustAssessment.Graph.BatchResult'
								Id         = "$($task.Id)"
								Argument   = $task.Argument
								Success    = $true
								Result     = $task.Result
								Status     = $result.status
							}
							continue
						}

						# Plain Output
						if (($result.body -is [System.Collections.IDictionary] -and $result.body.Contains('value')) -or
							$result.body.PSObject.Properties.Name -contains 'value') {
							$result.body.value
						}
						else {
							$result.body
						}

						continue
					}
					#endregion Case: Success
					#region Case: Throttled
					if (429 -eq $result.status) {
						$task.LastTransientResponse = $null
						$retryAfter = 0
						if (-not [int]::TryParse([string]$result.Headers.'Retry-After', [ref]$retryAfter) -or $retryAfter -lt 0) {
							$retryAfter = 3
						}
						$task.WaitUntil = (Get-Date).AddSeconds($retryAfter)
						continue
					}
					#endregion Case: Throttled
					if ($result.status -in 500, 502, 503, 504 -and $task.Batch.method -in 'GET', 'HEAD') {
						if ($task.TransientRetries -lt 5) {
							$now = Get-Date
							$retryDelay = 3 * [Math]::Pow(2, $task.TransientRetries)
							$headerValue = [string]$result.headers.'Retry-After'
							$retryAfter = 0
							if ([int]::TryParse($headerValue, [ref]$retryAfter) -and $retryAfter -ge 0) {
								$retryDelay = [Math]::Max($retryDelay, $retryAfter)
							}
							else {
								$retryDate = [DateTimeOffset]::MinValue
								if ([DateTimeOffset]::TryParseExact($headerValue, 'r', [Globalization.CultureInfo]::InvariantCulture,
									[Globalization.DateTimeStyles]::AssumeUniversal, [ref]$retryDate)) {
									$retryDelay = [Math]::Max($retryDelay, [Math]::Ceiling(($retryDate - [DateTimeOffset]$now).TotalSeconds))
								}
							}
							if ($retryDelay -lt ($task.WaitLimit - $now).TotalSeconds) {
								$task.LastTransientResponse = $result
								$task.TransientRetries++
								$task.WaitUntil = $now.AddSeconds($retryDelay)
								continue
							}
						}
						Write-PSFMessage -Level Warning -Message "Transient member retries exhausted or timeout reached for request id $($task.Id) (status $($result.status))."
					}
					if ($result.status -eq 424 -and $task.Batch.dependsOn.Count -gt 0) {
						$task.LastDependencyResponse = $result
						continue
					}
					#region Case: Failed
					if (400 -le $result.status -and 499 -ge $result.Status ) {
						$null = $TaskList.Remove($task)

						if ($task.Parameters.Raw) {
							$result
							continue
						}

						$Cmdlet.WriteError(
							[System.Management.Automation.ErrorRecord]::new(
								[Exception]::new("Error in batch request $($result.id): $($result.body.error.message)"),
								('{0}|{1}' -f $result.status, $result.body.error.code),
								[System.Management.Automation.ErrorCategory]::NotSpecified,
								$task.Batch
							)
						)

						if ($task.Parameters.Matched) {
							[PSCustomObject]@{
								PSTypeName = 'ZeroTrustAssessment.Graph.BatchResult'
								Id         = "$($task.Id)"
								Argument   = $task.Argument
								Success    = $false
								Result     = $result.body.error
								Status     = $result.status
							}
						}
						continue
					}
					#endregion Case: Failed
					#region Case: Other
					$null = $TaskList.Remove($task)

					if ($task.Parameters.Raw) {
						$result
						continue
					}

					if ($task.Parameters.Matched) {
						[PSCustomObject]@{
							PSTypeName = 'ZeroTrustAssessment.Graph.BatchResult'
							Id         = "$($task.Id)"
							Argument   = $task.Argument
							Success    = $false
							Result     = $result
							Status     = $result.status
						}
						continue
					}

					Write-PSFMessage -Level Warning -Message "Unexpected response code: $($result.status) on request id $($result.Id) ($($task.Url))"
					#endregion Case: Other
				}
			}
		}
		#endregion Utility Functions

		$allTasks = [System.Collections.Generic.List[object]]::new()
		$idTracking = @{ CurrentID = 1; ReservedIDs = @($Request | ForEach-Object { if ($null -ne $_.id) { [string]$_.id } }) }
		$parameters = @{}
		foreach ($key in $PSBoundParameters.Keys) {
			$parameters[$key] = $PSBoundParameters.$Key
		}
		$parameters.Method = $Method
		$parameters.Timeout = $Timeout

		foreach ($requestItem in $Request) {
			ConvertTo-BatchRequest -Request $requestItem -Parameters $parameters -TaskList $allTasks -Tracking $idTracking
		}
		foreach ($pathItem in $Path) {
			foreach ($argumentItem in $ArgumentList) {
				ConvertFrom-PathRequest -Path $pathItem -Argument $argumentItem -Parameters $parameters -TaskList $allTasks -Tracking $idTracking
			}
		}
		$parameters.HasDependencies = @($allTasks | Where-Object { $_.Batch.ContainsKey('dependsOn') -and $_.Batch.dependsOn.Count -gt 0 }).Count -gt 0
		if ($parameters.HasDependencies) {
			if ($allTasks.Count -gt 20) {
				throw [System.ArgumentException]::new('Workloads containing dependsOn must fit within one batch of 20 requests; dependency-bearing workloads cannot be split across batches.')
			}
			foreach ($task in $allTasks) {
				foreach ($dependency in $task.Batch.dependsOn) {
					if ([string]::IsNullOrWhiteSpace($dependency) -or $dependency -eq $task.Id -or $dependency -notin $allTasks.Id) {
						throw [System.ArgumentException]::new('Dependency IDs must reference other requests in the same workload.')
					}
				}
			}
		}
	}
	process {
		do {
			do {
				$now = Get-Date
				$runnableDependencyTasks = @($allTasks | Where-Object { -not $_.LastDependencyResponse -or -not $_.Batch.ContainsKey('dependsOn') -or $_.Batch.dependsOn.Count -eq 0 })
				$failedDependencyTasks = @(
					foreach ($pendingTask in $allTasks) {
						if (-not $pendingTask.LastDependencyResponse) { continue }
						$missingDependencies = @()
						if ($pendingTask.Batch.ContainsKey('dependsOn')) {
							$missingDependencies = @($pendingTask.Batch.dependsOn | Where-Object { $_ -notin $allTasks.Id })
						}
						if ($missingDependencies.Count -gt 0 -or $pendingTask.WaitLimit -le $now -or $runnableDependencyTasks.Count -eq 0) {
							$pendingTask
						}
					}
				)
				foreach ($task in $failedDependencyTasks) {
					$null = $allTasks.Remove($task)
					$dependencyResponse = $task.LastDependencyResponse
					if ($task.Parameters.Raw) {
						$dependencyResponse
						continue
					}
					$PSCmdlet.WriteError([System.Management.Automation.ErrorRecord]::new(
						[Exception]::new("Error in batch request $($task.Id): prerequisite failed or dependency recovery expired."),
						('424|{0}' -f $dependencyResponse.body.error.code),
						[System.Management.Automation.ErrorCategory]::NotSpecified,
						$task.Batch
					))
					if ($task.Parameters.Matched) {
						[PSCustomObject]@{
							PSTypeName = 'ZeroTrustAssessment.Graph.BatchResult'
							Id         = "$($task.Id)"
							Argument   = $task.Argument
							Success    = $false
							Result     = $dependencyResponse.body.error
							Status     = 424
						}
					}
				}
			} while ($failedDependencyTasks.Count -gt 0)
			$expiredTransientTasks = [System.Collections.Generic.List[object]]::new()
			$tasks = Get-NextBatch -Tasks $allTasks -ExpiredTransientTasks $expiredTransientTasks -Cmdlet $PSCmdlet
			foreach ($task in $expiredTransientTasks) {
				$lastResponse = $task.LastTransientResponse
				Write-PSFMessage -Level Warning -Message "Transient member retries exhausted or timeout reached for request id $($task.Id) (status $($lastResponse.status))."
				if ($task.Parameters.Raw) {
					$lastResponse
				}
				elseif ($task.Parameters.Matched) {
					[PSCustomObject]@{
						PSTypeName = 'ZeroTrustAssessment.Graph.BatchResult'
						Id         = "$($task.Id)"
						Argument   = $task.Argument
						Success    = $false
						Result     = $lastResponse
						Status     = $lastResponse.status
					}
				}
				else {
					$PSCmdlet.WriteError([System.Management.Automation.ErrorRecord]::new(
						[Exception]::new("Retries for transient member failures exceeded, giving up on request id $($task.Id) (status $($lastResponse.status))."),
						'TransientRetriesExhausted',
						[System.Management.Automation.ErrorCategory]::LimitsExceeded,
						$task.Batch
					))
				}
			}
			if ($expiredTransientTasks.Count -gt 0) {
				continue
			}

			# Case: All remaining tasks have expired
			if ($allTasks.Count -lt 1) {
				return
			}

			# Case: The only remaining tasks are throttled and wait to continue
			if (-not $tasks) {
				Start-Sleep -Seconds 1
				continue
			}

			Invoke-GraphBatch -Tasks $tasks -TaskList $allTasks -Cmdlet $PSCmdlet -ApiVersion $ApiVersion -OutputType $OutputType
		}
		while ($allTasks.Count -gt 0)
	}
}
