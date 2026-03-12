function Test-ZtRetryableError {
	<#
	.SYNOPSIS
		Determines whether an error is retryable based on the HTTP status code.

	.DESCRIPTION
		Inspects an ErrorRecord to determine if the underlying error represents a transient
		failure that should be retried (e.g., 429, 5xx, network errors) or a permanent failure
		that should fail immediately (e.g., 401, 403, 404).

		Network-level errors (no HTTP status code) are always considered retryable.

	.PARAMETER ErrorRecord
		The ErrorRecord from a catch block to inspect.

	.EXAMPLE
		PS C:\> try { Invoke-MgGraphRequest ... } catch { if (Test-ZtRetryableError $_) { # retry } }

		Returns $true for transient errors (429, 5xx, network errors) and $false for client errors (4xx).
	#>
	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[Parameter(Mandatory)]
		[System.Management.Automation.ErrorRecord]
		$ErrorRecord
	)

	$retryableStatusCodes = @(408, 429, 500, 502, 503, 504, 507)

	$statusCode = Get-ZtHttpStatusCode -ErrorRecord $ErrorRecord

	if ($null -eq $statusCode) {
		# No HTTP status code found - likely a network-level error (DNS, connection reset, timeout).
		# These are always retryable.
		return $true
	}

	return $statusCode -in $retryableStatusCodes
}
