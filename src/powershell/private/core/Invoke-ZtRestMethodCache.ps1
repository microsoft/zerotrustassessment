function Invoke-ZtRestMethodCache {
	<#
	.SYNOPSIS
		Executes an Azure REST Method request unless it has previously been cached.

	.DESCRIPTION
		Executes an Azure REST Method request unless it has previously been cached.
		Caches all successful GET requests, whether cache is disabled or not.
		Only GET requests are cached, no matter what.

		Throws an exception on non-2xx status codes unless -FullResponse is specified.

	.PARAMETER Path
		Path of target resource URL including api-version query parameter.
		Hostname of Resource Manager should not be added.

	.PARAMETER Method
		The HTTP Method to execute.
		Defaults to "GET"

	.PARAMETER DisableCache
		Specify if this request should skip cache and go directly to Azure.

	.PARAMETER DisablePaging
		Only return first page of results. By default, paging is enabled.

	.PARAMETER FullResponse
		Return the full PSHttpResponse object instead of just the parsed content.
		When specified, does not throw on non-2xx status codes.

	.EXAMPLE
		PS C:\> Invoke-ZtRestMethodCache -Path '/subscriptions?api-version=2022-01-01'

		Lists all subscriptions and caches the result.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]
		$Path,

		[string]
		$Method = 'GET',

		[switch]
		$DisableCache,

		[switch]
		$DisablePaging,

		[switch]
		$FullResponse
	)

	$cacheBlocked = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Azure.DisableCache'
	if ($cacheBlocked) { $DisableCache = $true }

	$isMethodGet = $Method -eq 'GET'
	$cacheKey = $Path

	# Check cache for GET requests
	if (-not $cacheBlocked -and -not $DisableCache -and $isMethodGet) {
		$isInCache = $script:__ZtSession.AzureCache.Value.ContainsKey($cacheKey)
		if ($isInCache) {
			Write-PSFMessage "Using Azure cache: $($cacheKey)" -Level Debug
			$cachedResult = $script:__ZtSession.AzureCache.Value[$cacheKey]
			if ($cachedResult) {
				if ($FullResponse) {
					# Return a synthetic response object for cached content
					return [PSCustomObject]@{
						StatusCode = 200
						Content    = $cachedResult | ConvertTo-Json -Depth 100
						Headers    = @{}
						Method     = 'GET'
					}
				}
				return $cachedResult
			}
		}
	}

	Write-PSFMessage "Invoking Azure REST: $Path" -Level Debug -Tag Azure

	# Build request parameters
	$requestParams = @{
		Path   = $Path
		Method = $Method
	}

	# Add paging parameters for GET requests
	if ($isMethodGet -and -not $DisablePaging) {
		$requestParams['Paginate'] = $true
	}

	$response = Invoke-AzRestMethod @requestParams

	# Check for success (2xx status codes)
	$isSuccess = $response.StatusCode -ge 200 -and $response.StatusCode -lt 300

	if ($FullResponse) {
		# Return full response without throwing
		return $response
	}

	if (-not $isSuccess) {
		$errorContent = $response.Content
		try {
			$errorJson = $response.Content | ConvertFrom-Json
			if ($errorJson.error.message) {
				$errorContent = $errorJson.error.message
			}
		}
		catch {
			# Keep raw content if JSON parsing fails
		}
		throw "Azure REST request failed with status $($response.StatusCode): $errorContent"
	}

	# Parse the response content
	$results = $null
	if (-not [string]::IsNullOrWhiteSpace($response.Content)) {
		$results = $response.Content | ConvertFrom-Json
	}

	# Cache successful GET responses
	if ($isMethodGet -and -not $DisableCache) {
		$script:__ZtSession.AzureCache.Value[$cacheKey] = $results
	}

	$results
}
