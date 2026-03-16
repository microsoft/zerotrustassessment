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

	# Well-known permanent 4xx errors that will never succeed on retry
	$nonRetryableStatusCodes = @(
		401  # Unauthorized - invalid/missing credentials
		403  # Forbidden - insufficient permissions
		404  # Not Found - resource doesn't exist
		405  # Method Not Allowed - wrong HTTP verb
		409  # Conflict - resource state conflict
		410  # Gone - resource permanently removed
		411  # Length Required - missing Content-Length
		413  # Payload Too Large - request body too big
		415  # Unsupported Media Type - wrong content type
		422  # Unprocessable Entity - validation failure
	)

	$statusCode = Get-ZtHttpStatusCode -ErrorRecord $ErrorRecord

	if ($null -eq $statusCode) {
		# No HTTP status code found - likely a network-level error (DNS, connection reset, timeout).
		# These are always retryable.
		return $true
	}

	# Permanent client errors fail immediately. All other errors (including 400, 429, 5xx)
	# are retried up to the configured retry count, since they may be transient.
	return $statusCode -notin $nonRetryableStatusCodes
}
