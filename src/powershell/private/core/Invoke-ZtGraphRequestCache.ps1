function Invoke-ZtGraphRequestCache {
	<#
	.SYNOPSIS
		Executes a Graph Request unless it has previously been cached.

	.DESCRIPTION
		Executes a Graph Request unless it has previously been cached.
		Caches all requests, whether cache is disabled or not.
		Only GET requests are cached, no matter what.

		Batch Requests are never cached or read from cache.

	.PARAMETER Uri
		The Uri to send the request to.

	.PARAMETER Method
		The HTTP Method to execute.
		Defaults to "Get"

	.PARAMETER OutputType
		The format of data to return.
		Defaults to PSObject.

	.PARAMETER Headers
		Any headers to include with the request.

	.PARAMETER DisableCache
		Specify if this request should skip cache and go directly to Graph.

	.PARAMETER Body
		The request body.
		Only used for methods other than "Get"

	.PARAMETER OutputFilePath
		If specified, writes the raw results to disk.
		Will also force object return, overriding any choice in OutputType.

	.PARAMETER PageIndex
		The index of Graph request page. If not specified, the first page is assumed (0).

	.EXAMPLE
		PS C:\> Invoke-ZtGraphRequestCache -Uri 'https://graph.microsoft.com/v1.0/users'

		Lists all users in the tenant and caches the result.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[Uri]
		$Uri,

		[string]
		$Method = 'GET',

		[ValidateSet('PSObject', 'PSCustomObject', 'Hashtable')]
		[string]
		$OutputType = 'PSObject',

		[System.Collections.IDictionary]
		$Headers,

		[switch]
		$DisableCache,

		[string]
		$Body,

		[string]
		$OutputFilePath,

		[string]
		$PageIndex
	)

	$cacheBlocked = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Graph.DisableCache'
	if ($cacheBlocked) { $DisableCache = $true }
	$results = $null
	$isBatch = $uri.AbsoluteUri.EndsWith('$batch')
	$isInCache = $script:__ZtSession.GraphCache.Value.ContainsKey($Uri.AbsoluteUri)
	$cacheKey = $Uri.AbsoluteUri
	$isMethodGet = $Method -eq 'GET'

	if (-not $cacheBlocked -and -not $DisableCache -and -not $isBatch -and $isInCache -and $isMethodGet) {
		# Don't read from cache for batch requests.
		Write-PSFMessage "Using graph cache: $($cacheKey)" -Level Debug
		$results = $script:__ZtSession.GraphCache.Value[$cacheKey]
		if ($results) {
			return $results
		}
	}

	Write-PSFMessage "Invoking Graph: $($Uri.AbsoluteUri)" -Level Debug -Tag Graph
	Write-PSFMessage ([string]::IsNullOrEmpty($Body)) -Level Debug -Tag Graph

	# Throttling
	$relativeUrl = ($Uri.LocalPath -split '/',2)[1]
	$urlBase = $relativeUrl.Trim("/").Split("/")[0]
	foreach ($urlPath in "$Uri", $relativeUrl, $urlBase) {
		if ($script:__ZtThrottling.Value[$urlPath]) {
			$script:__ZtThrottling.Value[$urlPath].GetSlot()
			break
		}
	}

	if (-not $isMethodGet) {
		Invoke-MgGraphRequest -Method $Method -Uri $Uri -Headers $Headers -OutputType $OutputType -Body $Body
		return
	}

	if ($OutputFilePath) {
		$OutputType = 'Json' # Force JSON output if writing to file so we get the raw results
	}

	$results = Invoke-MgGraphRequest -Method $Method -Uri $Uri -Headers $Headers -OutputType $OutputType # -Body $Body # Cannot use Body with GET in PS 5.1
	if ($OutputFilePath) {
		$filePath = Get-ExportJsonFilePath -Path $OutputFilePath -PageIndex $PageIndex
		$results | Set-PSFFileContent -Path (New-Item -Path $filePath -Force) # Write raw results to disk
		$results = $results | ConvertFrom-Json -Depth 100 # Convert back to PSObject
	}

	if (-not $isBatch -and -not $DisableCache) {
		# Update cache
		$script:__ZtSession.GraphCache.Value[$cacheKey] = $results
	}
	$results
}
