function Test-ZtRetryableError {
	<#
	.SYNOPSIS
		Determines whether an error is retryable based on the HTTP status code.

	.DESCRIPTION
		Inspects an ErrorRecord to determine if the underlying error represents a transient
		failure that should be retried (e.g., 500, 502, network errors) or a failure
		that should be propagated immediately (e.g., 401, 403, 404).
		HTTP 429, 503, and 504 are retried by the Graph SDK and are not retried again here.

		Network-level errors (no HTTP status code) are always considered retryable.

	.PARAMETER ErrorRecord
		The ErrorRecord from a catch block to inspect.

	.EXAMPLE
		PS C:\> try { Invoke-MgGraphRequest ... } catch { if (Test-ZtRetryableError $_) { # retry } }

		Returns $false for excluded client errors and SDK-handled statuses (429, 503, 504).
	#>
	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[Parameter(Mandatory)]
		[System.Management.Automation.ErrorRecord]
		$ErrorRecord
	)

	# Exclude permanent client errors and transient statuses whose retries belong to the Graph SDK.
	$nonRetryableStatusCodes = @(
		400  # Bad Request - malformed request
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
		429  # Too Many Requests - retries handled by the Graph SDK
		503  # Service Unavailable - retries handled by the Graph SDK
		504  # Gateway Timeout - retries handled by the Graph SDK
	)

	$statusCode = Get-ZtHttpStatusCode -ErrorRecord $ErrorRecord

	if ($null -eq $statusCode) {
		# No HTTP status code found - likely a network-level error (DNS, connection reset, timeout).
		# These are always retryable.
		return $true
	}

	# Excluded statuses fail immediately. All other errors
	# are retried up to the configured retry count, since they may be transient.
	return $statusCode -notin $nonRetryableStatusCodes
}
