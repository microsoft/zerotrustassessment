<#
 .SYNOPSIS
   Helper module to run graph request that supports paging, batching and caching.

 .Description
    The version of Invoke-Graph request supports
    * Filter, Select and Unique IDs as parameters
    * Automatic paging if Graph returns a nextLink
    * Batching of requests to Graph if multiple requests are piped through
    * Caching of results for the duration of the session
    * Ability to skip cache and go directly to Graph
    * Specify consistency level as a parameter
    * Additional custom headers via the Headers parameter

	POST is intended for read/query Graph endpoints. POST requests require a JSON object body,
	are not cached or batched, and can target only one endpoint per invocation.

    :::info
    Note: Batch requests don't support caching.
    :::

	Batched GETs use Invoke-ZtGraphBatchRequest for scheduling and member throttling retries.
	Results are processed as the helper returns them; continuation pages use ordinary GET requests.
	Initial batches use the helper's SDK routing, fixed batch size, and output representation,
	rather than GraphBaseUri, BatchSize, or OutputType. The helper currently sends batches to v1.0.

 .Example

    Invoke-ZtGraphRequest -RelativeUri "users" -Filter "displayName eq 'John Doe'" -Select "displayName" -Top 10

    Get all users with a display name of "John Doe" and return the first 10 results.

 .Example

	 $body = @{ Query = 'DeviceProcessEvents | limit 2' } | ConvertTo-Json -Compress
	 Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -Method POST -Body $body

	 Run a Microsoft Defender advanced hunting query. POST is intended only for Graph query endpoints.

#>
function Invoke-ZtGraphRequest {
	[CmdletBinding()]
	param(
		# Graph endpoint such as "users".
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[string[]] $RelativeUri,
		# Specifies unique Id(s) for the URI endpoint. For example, users endpoint accepts Id or UPN.
		[Parameter(Mandatory = $false)]
		[string[]] $UniqueId = '',
		# Filters properties (columns).
		[Parameter(Mandatory = $false)]
		[string[]] $Select,
		# Filters results (rows). https://docs.microsoft.com/en-us/graph/query-parameters#filter-parameter
		[Parameter(Mandatory = $false)]
		[string] $Filter,
		# The number of items to be included in the result.
		[Parameter(Mandatory = $false)]
		[string] $Top,
		# Parameters
		[Parameter(Mandatory = $false)]
		[hashtable] $QueryParameters,
		# API Version.
		[Parameter(Mandatory = $false)]
		[ValidateSet('v1.0', 'beta')]
		[string] $ApiVersion = 'v1.0',
		# HTTP method. POST is intended for read/query endpoints.
		[Parameter(Mandatory = $false)]
		[ValidateSet('GET', 'POST')]
		[string] $Method = 'GET',
		# JSON object request body for POST requests.
		[Parameter(Mandatory = $false)]
		[string] $Body,
		# Specifies consistency level.
		[Parameter(Mandatory = $false)]
		[string] $ConsistencyLevel = 'eventual',
		# Only return first page of results.
		[Parameter(Mandatory = $false)]
		[switch] $DisablePaging,
		# Force individual requests to MS Graph.
		[Parameter(Mandatory = $false)]
		[switch] $DisableBatching,
		# Specify Batch size.
		[Parameter(Mandatory = $false)]
		[int] $BatchSize = 20,
		# Base URL for Microsoft Graph API.
		[Parameter(Mandatory = $false)]
		[uri] $GraphBaseUri,
		# Specify if this request should skip cache and go directly to Graph.
		[Parameter(Mandatory = $false)]
		[switch] $DisableCache,
		# Specify the output type
		[Parameter(Mandatory = $false)]
		[ValidateSet('PSObject', 'PSCustomObject', 'Hashtable')]
		[string] $OutputType = 'PSObject',
		# If specified, writes the raw results to disk
		[Parameter(Mandatory = $false)]
		[string] $OutputFilePath,
		# Additional headers to include in the request
		[Parameter(Mandatory = $false)]
		[hashtable] $Headers
	)

	begin {
		$batchRequests = New-Object 'System.Collections.Generic.List[psobject]'
		$postRelativeUris = New-Object 'System.Collections.Generic.List[string]'

		if ($Method -eq 'GET') {
			if ($PSBoundParameters.ContainsKey('Body')) {
				throw [System.ArgumentException]::new('-Body is only supported when -Method POST is specified.', 'Body')
			}
		}
		else {
			if ([string]::IsNullOrWhiteSpace($Body)) {
				throw [System.ArgumentException]::new('-Body is required when -Method POST is specified and must be a JSON object.', 'Body')
			}
			if (-not (Test-Json -Json $Body -ErrorAction SilentlyContinue)) {
				throw [System.ArgumentException]::new('-Body must be valid JSON.', 'Body')
			}
			try {
				$bodyObject = $Body | ConvertFrom-Json -AsHashtable -ErrorAction Stop
			}
			catch {
				throw [System.ArgumentException]::new('-Body must be a JSON object.', 'Body', $_.Exception)
			}
			if ($bodyObject -isnot [System.Collections.IDictionary]) {
				throw [System.ArgumentException]::new('-Body must be a JSON object.', 'Body')
			}
			if ($DisableBatching) {
				throw [System.ArgumentException]::new('-DisableBatching cannot be used with -Method POST because POST requests are never batched.', 'DisableBatching')
			}
			foreach ($parameterName in 'Select', 'Filter', 'Top') {
				if ($PSBoundParameters.ContainsKey($parameterName)) {
					throw [System.ArgumentException]::new("-$parameterName cannot be used with -Method POST.", $parameterName)
				}
			}
			if ($UniqueId.Count -ne 1) {
				throw [System.ArgumentException]::new('-Method POST supports exactly one resolved endpoint.', 'UniqueId')
			}
		}

		$requestHeaders = if ($Headers) { $Headers.Clone() } else { @{} }
		$requestHeaders['ConsistencyLevel'] = $ConsistencyLevel
		if ($Method -eq 'POST' -and -not $requestHeaders.ContainsKey('Content-Type')) {
			$requestHeaders['Content-Type'] = 'application/json'
		}

		$requestParam = @{
			Headers = $requestHeaders
			OutputType = $OutputType
			DisableCache = $DisableCache
			OutputFilePath = $OutputFilePath
			Method = $Method
		}
		if ($Method -eq 'POST') {
			$requestParam['Body'] = $Body
		}

		#region Utility Functions
		function Format-Result {
			[CmdletBinding()]
			param (
				$Results,

				$RawOutput
			)
			# Do nothing on null
			if (-not $Results) {
				return
			}
			if ($RawOutput) {
				return $Results
			}

			$hasValueProperty = $Results.PSObject.Properties.Name -contains "value" -or $Results.Keys -contains 'value'
			if (-not $hasValueProperty) {
				return $Results
			}

			$dataContextName = '@odata.context'
			foreach ($result in $Results.value) {
				if ($result.$dataContextName) {
					$result
					continue
				}

				if ($result -is [hashtable]) {
					$result[$dataContextName] = '{0}/$entity' -f $Results.'@odata.context'
				}
				else {
					[PSFramework.Object.ObjectHost]::AddNoteProperty($result, $dataContextName, ('{0}/$entity' -f $Results.'@odata.context'), $true)
				}
				$result
			}
		}

		function Complete-Result {
			[CmdletBinding()]
			param (
				$Results,

				$DisablePaging,

				$RequestParam
			)
			if ($DisablePaging -or -not $Results) {
				return
			}
			$pagingRequestParam = $RequestParam.Clone()
			$pagingRequestParam.Remove('Method')
			$pagingRequestParam.Remove('Body')
			$pageIndex = 1
			while ($Results.'@odata.nextLink') {
				$Results = Invoke-ZtGraphRequestCache -Method GET -Uri $results.'@odata.nextLink' @pagingRequestParam -PageIndex $pageIndex
				$pageIndex++
				Format-Result -Results $Results -RawOutput $DisablePaging
			}
		}

		function Resolve-GraphBaseUri {
			if ($GraphBaseUri) {
				return $GraphBaseUri
			}
			if (-not $script:__ZtSession.GraphBaseUri) {
				Write-PSFMessage -Message 'Setting GraphBaseUri to default value from MgContext.'
				$mgContext = Get-MgContext
				if (-not $mgContext) {
					throw 'No Microsoft Graph context found. Please connect to Microsoft Graph using Connect-ZtAssessment.'
				}

				$script:__ZtSession.GraphBaseUri = (Get-MgEnvironment -Name $mgContext.Environment).GraphEndpoint
			}

			return [uri] $script:__ZtSession.GraphBaseUri
		}

		function Invoke-ResolvedGraphRequest {
			param(
				[string[]] $Uris
			)

			$resolvedGraphBaseUri = Resolve-GraphBaseUri
			if ($DisableBatching -and ($Uris.Count -gt 1 -or $UniqueId.Count -gt 1)) {
				Write-Warning ('This command is invoking {0} individual Graph requests. For better performance, remove the -DisableBatching parameter.' -f ($Uris.Count * $UniqueId.Count))
			}
			$doBatch = ($Method -eq 'GET') -and -not $DisableBatching -and ($Uris.Count -gt 1 -or $UniqueId.Count -gt 1)

			foreach ($uri in $Uris) {
				$uriQueryEndpoint = [System.UriBuilder]::new([IO.Path]::Combine($resolvedGraphBaseUri.AbsoluteUri, $ApiVersion, $uri))

				#region Process Uri & Query
				if ($uriQueryEndpoint.Query) {
					$finalQueryParameters = ConvertFrom-QueryString -InputStrings $uriQueryEndpoint.Query -AsHashtable
					if ($QueryParameters) {
						foreach ($ParameterName in $QueryParameters.Keys) {
							$finalQueryParameters[$ParameterName] = $QueryParameters[$ParameterName]
						}
					}
				}
				elseif ($QueryParameters) {
					$finalQueryParameters = $QueryParameters
				}
				else {
					$finalQueryParameters = @{ }
				}
				if ($Select) {
					$finalQueryParameters['$select'] = $Select -join ','
				}
				if ($Filter) {
					$finalQueryParameters['$filter'] = $Filter
				}
				if ($Top) {
					$finalQueryParameters['$top'] = $Top
				}
				$uriQueryEndpoint.Query = ConvertTo-QueryString $finalQueryParameters
				#endregion Process Uri & Query

				foreach ($id in $UniqueId) {
					$uriQueryEndpointFinal = New-Object System.UriBuilder -ArgumentList $uriQueryEndpoint.Uri
					$uriQueryEndpointFinal.Path = ([IO.Path]::Combine($uriQueryEndpointFinal.Path, $id))

					if ($doBatch) {
						$batchHeaders = if ($Headers) { $Headers.Clone() } else { @{} }
						$batchHeaders['ConsistencyLevel'] = $ConsistencyLevel

						$request = [PSCustomObject]@{
							id      = $batchRequests.Count + 1
							method  = 'GET'
							url     = $uriQueryEndpointFinal.Uri.AbsoluteUri -replace ('{0}{1}/' -f $resolvedGraphBaseUri.AbsoluteUri, $ApiVersion)
							headers = $batchHeaders
						}
						$batchRequests.Add($request)
					}
					else {
						$results = Invoke-ZtGraphRequestCache -Uri $uriQueryEndpointFinal.Uri.AbsoluteUri @requestParam

						Format-Result -Results $results -RawOutput $DisablePaging
						Complete-Result -Results $results -DisablePaging $DisablePaging -RequestParam $requestParam
					}
				}
			}
		}
		#endregion Utility Functions
	}

	process {
		if ($Method -eq 'POST') {
			foreach ($uri in $RelativeUri) {
				$postRelativeUris.Add($uri)
			}
			return
		}

		Invoke-ResolvedGraphRequest -Uris $RelativeUri
	}

	end {
		if ($Method -eq 'POST') {
			if ($postRelativeUris.Count -ne 1) {
				throw [System.ArgumentException]::new('-Method POST supports exactly one resolved endpoint.', 'RelativeUri')
			}
			Invoke-ResolvedGraphRequest -Uris $postRelativeUris.ToArray()
		}

		if ($batchRequests.Count -lt 1) {
			return
		}

		Invoke-ZtGraphBatchRequest -Request $batchRequests.ToArray() -Raw -NoPaging -ApiVersion $ApiVersion | ForEach-Object {
			$results = $_.body
			Format-Result -Results $results -RawOutput $DisablePaging
			Complete-Result -Results $results -DisablePaging $DisablePaging -RequestParam $requestParam
		}
	}
}
