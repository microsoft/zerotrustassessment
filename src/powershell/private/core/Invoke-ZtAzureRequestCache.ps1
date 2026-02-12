function Invoke-ZtAzureRequestCache {
	<#
	.SYNOPSIS
		Executes an Azure REST Method request unless it has previously been cached.

	.DESCRIPTION
		Executes an Azure REST Method request unless it has previously been cached.
		Caches successful GET responses for the duration of the session.
		When -DisableCache is specified, both cache reads and writes are skipped.

		Throws an exception on non-2xx status codes unless -FullResponse is specified.

		This function is called by Invoke-ZtAzureRequest and receives pre-built
		Invoke-AzRestMethod parameters to forward directly.

	.PARAMETER CacheKey
		A unique string key for the cache (typically the Path or Uri).

	.PARAMETER AzParams
		Hashtable of parameters to splat to Invoke-AzRestMethod.
		The HTTP method is inferred from AzParams.Method (defaults to GET if absent).

	.PARAMETER DisableCache
		Specify if this request should skip cache and go directly to Azure.

	.PARAMETER FullResponse
		Return the full PSHttpResponse object instead of just the parsed content.
		When specified, does not throw on non-2xx status codes.

	.EXAMPLE
		PS C:\> Invoke-ZtAzureRequestCache -CacheKey '/subscriptions?api-version=2022-01-01' -AzParams @{ Path = '/subscriptions?api-version=2022-01-01'; Paginate = $true }

		Lists all subscriptions (GET is the default) and caches the result.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]
		$CacheKey,

		[Parameter(Mandatory = $true)]
		[hashtable]
		$AzParams,

		[switch]
		$DisableCache,

		[switch]
		$FullResponse
	)

	$cacheBlocked = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Azure.DisableCache'
	if ($cacheBlocked) { $DisableCache = $true }
	$isGet = -not $AzParams.ContainsKey('Method') -or $AzParams['Method'] -eq 'GET'
	$isInCache = $script:__ZtSession.AzureCache.Value.ContainsKey($CacheKey)

	# Check cache for GET requests
	if (-not $cacheBlocked -and -not $DisableCache -and $isGet -and $isInCache) {
		Write-PSFMessage "Using Azure cache: $($CacheKey)" -Level Debug
		$cachedResult = $script:__ZtSession.AzureCache.Value[$CacheKey]
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

	Write-PSFMessage "Invoking Azure REST: $CacheKey" -Level Debug -Tag Azure

	# Forward all parameters directly to Invoke-AzRestMethod
	$response = Invoke-AzRestMethod @AzParams

	# Check for success (2xx status codes)
	$isSuccess = $response.StatusCode -ge 200 -and $response.StatusCode -lt 300

	if ($FullResponse) {
		# Cache the parsed content so subsequent non-FullResponse calls benefit,
		# then return the full response without throwing.
		if ($isGet -and -not $DisableCache -and $isSuccess) {
			$parsedForCache = $null
			if (-not [string]::IsNullOrWhiteSpace($response.Content)) {
				$parsedForCache = $response.Content | ConvertFrom-Json
			}
			$script:__ZtSession.AzureCache.Value[$CacheKey] = $parsedForCache
		}
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
	if ($isGet -and -not $DisableCache) {
		$script:__ZtSession.AzureCache.Value[$CacheKey] = $results
	}

	$results
}
