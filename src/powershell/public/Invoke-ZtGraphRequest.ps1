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

    :::info
    Note: Batch requests don't support caching.
    :::

 .Example

    Invoke-ZtGraphRequest -RelativeUri "users" -Filter "displayName eq 'John Doe'" -Select "displayName" -Top 10

    Get all users with a display name of "John Doe" and return the first 10 results.

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
		if (-not $GraphBaseUri) {
			if (-not $script:__ZtSession.GraphBaseUri) {
				Write-PSFMessage -Message 'Setting GraphBaseUri to default value from MgContext.'
				$script:__ZtSession.GraphBaseUri = (Get-MgEnvironment -Name (Get-MgContext).Environment).GraphEndpoint
			}
		}
		$GraphBaseUri = $script:__ZtSession.GraphBaseUri

		$batchRequests = New-Object 'System.Collections.Generic.List[psobject]'

		$requestHeaders = if ($Headers) { $Headers.Clone() } else { @{} }
		$requestHeaders['ConsistencyLevel'] = $ConsistencyLevel

		$requestParam = @{
			Headers = $requestHeaders
			OutputType = $OutputType
			DisableCache = $DisableCache
			OutputFilePath = $OutputFilePath
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
			$pageIndex = 1
			while (Get-ObjectProperty -InputObjects $Results -Property '@odata.nextLink') {
				$Results = Invoke-ZtGraphRequestCache -Method GET -Uri $results.'@odata.nextLink' @RequestParam -PageIndex $pageIndex
				$pageIndex++
				Format-Result -Results $Results -RawOutput $DisablePaging
			}
		}
		#endregion Utility Functions
	}

	process {
		$results = $null

		if ($DisableBatching -and ($RelativeUri.Count -gt 1 -or $UniqueId.Count -gt 1)) {
			Write-Warning ('This command is invoking {0} individual Graph requests. For better performance, remove the -DisableBatching parameter.' -f ($RelativeUri.Count * $UniqueId.Count))
		}
		$doBatch = -not $DisableBatching -and ($RelativeUri.Count -gt 1 -or $UniqueId.Count -gt 1)

		## Process Each RelativeUri
		foreach ($uri in $RelativeUri) {
			$uriQueryEndpoint = [System.UriBuilder]::new([IO.Path]::Combine($GraphBaseUri.AbsoluteUri, $ApiVersion, $uri))

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

			#region Execute individual or queue batch
			foreach ($id in $UniqueId) {
				$uriQueryEndpointFinal = New-Object System.UriBuilder -ArgumentList $uriQueryEndpoint.Uri
				$uriQueryEndpointFinal.Path = ([IO.Path]::Combine($uriQueryEndpointFinal.Path, $id))

				if ($doBatch) {
					$batchHeaders = if ($Headers) { $Headers.Clone() } else { @{} }
					$batchHeaders['ConsistencyLevel'] = $ConsistencyLevel

					$request = [PSCustomObject]@{
						id      = $batchRequests.Count
						method  = 'GET'
						url     = $uriQueryEndpointFinal.Uri.AbsoluteUri -replace ('{0}{1}/' -f $GraphBaseUri.AbsoluteUri, $ApiVersion)
						headers = $batchHeaders
					}
					$batchRequests.Add($request)
				}
				else {

					$results = Invoke-ZtGraphRequestCache -Method GET -Uri $uriQueryEndpointFinal.Uri.AbsoluteUri @requestParam

					Format-Result -Results $results -RawOutput $DisablePaging
					Complete-Result -Results $results -DisablePaging $DisablePaging -RequestParam $requestParam
				}
			}
			#endregion Execute individual or queue batch
		}
	}

	end {
		if ($batchRequests.Count -lt 1) {
			return
		}

		$uriQueryEndpoint = [System.UriBuilder]::new([IO.Path]::Combine($GraphBaseUri.AbsoluteUri, $ApiVersion, '$batch'))
		for ($iRequest = 0; $iRequest -lt $batchRequests.Count; $iRequest += $BatchSize) {
			$indexEnd = [System.Math]::Min($iRequest + $BatchSize - 1, $batchRequests.Count - 1)
			$jsonRequests = New-Object psobject -Property @{ requests = $batchRequests[$iRequest..$indexEnd] } | ConvertTo-Json -Depth 5
			Write-Debug $jsonRequests

			$resultsBatch = Invoke-ZtGraphRequestCache -Method POST -Uri $uriQueryEndpoint.Uri.AbsoluteUri -Body $jsonRequests -OutputType $OutputType -DisableCache:$DisableCache
			$resultsBatch = $resultsBatch.responses | Sort-Object -Property id

			foreach ($results in $resultsBatch.body) {
				Format-Result -Results $results -RawOutput $DisablePaging
				Complete-Result -Results $results -DisablePaging $DisablePaging -RequestParam $requestParam
			}
		}
	}
}
