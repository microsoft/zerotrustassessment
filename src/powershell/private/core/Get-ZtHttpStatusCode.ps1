function Get-ZtHttpStatusCode {
	<#
	.SYNOPSIS
		Extracts the HTTP status code from an ErrorRecord, if present.

	.DESCRIPTION
		Attempts to extract the HTTP status code from an ErrorRecord using multiple strategies:
		1. The exception's Response.StatusCode property (WebException, HttpResponseException)
		2. The exception's StatusCode property (HttpRequestException in .NET 5+)
		3. Regex parsing of the exception message (fallback for Graph SDK exceptions)

		Returns $null if no HTTP status code can be determined (e.g., pure network errors).

	.PARAMETER ErrorRecord
		The ErrorRecord from a catch block to inspect.

	.EXAMPLE
		PS C:\> try { Invoke-MgGraphRequest ... } catch { Get-ZtHttpStatusCode -ErrorRecord $_ }

		Returns the HTTP status code (e.g., 500) or $null if not determinable.
	#>
	[CmdletBinding()]
	[OutputType([int])]
	param (
		[Parameter(Mandatory)]
		[System.Management.Automation.ErrorRecord]
		$ErrorRecord
	)

	$exception = $ErrorRecord.Exception

	# Walk the exception chain to find an HTTP status code
	$current = $exception
	while ($current) {
		# Strategy 1: Response.StatusCode (WebException, HttpResponseException)
		if ($current.Response -and $current.Response.StatusCode) {
			return [int]$current.Response.StatusCode
		}

		# Strategy 2: Direct StatusCode property (HttpRequestException in .NET 5+)
		if ($null -ne $current.PSObject.Properties['StatusCode'] -and $null -ne $current.StatusCode) {
			return [int]$current.StatusCode
		}

		$current = $current.InnerException
	}

	# Strategy 3: Regex fallback - Graph SDK often includes status codes in the message
	# e.g., "Response status code does not indicate success: 500 (Internal Server Error)."
	if ($exception.Message -match ':\s*(4\d{2}|5\d{2})\s') {
		return [int]$Matches[1]
	}

	# Strategy 4: Match raw HTTP status line in error message
	# e.g., "HTTP/2.0 400 Bad Request" or "HTTP/1.1 503 Service Unavailable"
	if ($exception.Message -match 'HTTP/\S+\s+(4\d{2}|5\d{2})\s') {
		return [int]$Matches[1]
	}

	# Could not determine the HTTP status code
	return $null
}
