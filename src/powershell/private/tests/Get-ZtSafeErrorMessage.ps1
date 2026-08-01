function Get-ZtSafeErrorMessage {
	<#
	.SYNOPSIS
		Builds a diagnostic summary that is safe to persist.

	.DESCRIPTION
		Extracts a small allow-list of HTTP and Microsoft Graph diagnostic fields
		from an ErrorRecord. It never returns an unstructured exception message,
		request header dump, response body, or URL query string.
	#>
	[CmdletBinding()]
	[OutputType([string])]
	param (
		[Parameter(Mandatory)]
		[System.Management.Automation.ErrorRecord]
		$ErrorRecord
	)
	process {
		$diagnostics = [System.Collections.Generic.List[string]]::new()
		$errorText = @(
			$ErrorRecord.Exception.Message
			$ErrorRecord.ErrorDetails.Message
		) -join [Environment]::NewLine

		$requestMatch = [regex]::Match($errorText, '(?i)\b(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)\s+(https?://[^\s"'']+)')
		if ($requestMatch.Success) {
			$method = $requestMatch.Groups[1].Value.ToUpperInvariant()
			$requestUri = $requestMatch.Groups[2].Value
			try {
				$uri = [System.Uri]$requestUri
				$requestUri = $uri.GetLeftPart([System.UriPartial]::Path)
			}
			catch {
				$requestUri = $requestUri -replace '\?[^\s"'']*$', ''
			}
			$diagnostics.Add("Graph request failed: $method $requestUri")
		}

		$statusCode = Get-ZtHttpStatusCode -ErrorRecord $ErrorRecord
		if ($null -ne $statusCode) {
			$reasonMatch = [regex]::Match($errorText, "(?im)^HTTP/\S+\s+$statusCode\s+([^\r\n]+)")
			$reason = if ($reasonMatch.Success) { $reasonMatch.Groups[1].Value.Trim() } else { $null }
			$statusDescription = if ($reason) { "$statusCode $reason" } else { "$statusCode" }
			$diagnostics.Add("HTTP status: $statusDescription")
		}

		$graphCodeMatch = [regex]::Match($errorText, '"code"\s*:\s*"([A-Za-z0-9_.-]+)"')
		if ($graphCodeMatch.Success) {
			$diagnostics.Add("Graph error code: $($graphCodeMatch.Groups[1].Value)")
		}

		$requestIdMatch = [regex]::Match($errorText, '(?im)^\s*request-id\s*:\s*([0-9a-f-]{36})\s*$')
		if ($requestIdMatch.Success) {
			$diagnostics.Add("Request ID: $($requestIdMatch.Groups[1].Value)")
		}

		$clientRequestIdMatch = [regex]::Match($errorText, '(?im)^\s*client-request-id\s*:\s*([0-9a-f-]{36})\s*$')
		if ($clientRequestIdMatch.Success) {
			$diagnostics.Add("Client request ID: $($clientRequestIdMatch.Groups[1].Value)")
		}

		if ($diagnostics.Count -eq 0) {
			return 'An unexpected error occurred. See the error details for the exception type and error ID.'
		}

		$diagnostics -join '; '
	}
}
