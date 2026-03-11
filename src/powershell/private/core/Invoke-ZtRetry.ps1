function Invoke-ZtRetry {
	<#
	.SYNOPSIS
		Invokes a scriptblock with retry logic for transient failures.

	.DESCRIPTION
		Executes the provided scriptblock, retrying on failure with exponential backoff.
		Designed for wrapping Graph API calls that may fail due to transient server errors, throttling, or timeouts.

	.PARAMETER ScriptBlock
		The scriptblock to execute.

	.PARAMETER RetryCount
		The maximum number of retry attempts. Default: 5.

	.PARAMETER RetryDelay
		The initial delay in seconds between retries. Doubles with each attempt (exponential backoff). Default: 3.

	.EXAMPLE
		PS C:\> Invoke-ZtRetry -ScriptBlock { Invoke-MgGraphRequest -Method GET -Uri $uri -OutputType HashTable }

		Executes the Graph request with up to 5 retries and exponential backoff on failure.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[scriptblock]
		$ScriptBlock,

		[Parameter()]
		[scriptblock]
		$RetryHandler,

		[Parameter()]
		[ValidateRange(1, 10)]
		[int]
		$RetryCount = 5,

		[Parameter()]
		[ValidateRange(1, 60)]
		[int]
		$RetryDelay = 3
	)

	$ErrorActionPreference = 'Stop'

	$currentDelay = $RetryDelay
	[int] $attempt = 0

	foreach ($attempt in 1..$RetryCount) {
		try {
			return & $ScriptBlock
		}
		catch {
			$isRetryable = Test-ZtRetryableError -ErrorRecord $_

			if (-not $isRetryable) {
				Write-PSFMessage -Level Warning -Message "Non-retryable error encountered: {0}. Failing immediately." -StringValues $_.Exception.Message -ErrorRecord $_ -Tag Retry
				$PSCmdlet.ThrowTerminatingError($_)
			}

			if ($attempt -ge $RetryCount) {
				$PSCmdlet.ThrowTerminatingError($_)
			}

			Write-PSFMessage -Level Warning -Message "Attempt $attempt of $RetryCount failed: {0}. Retrying in $currentDelay seconds..." -StringValues $_.Exception.Message -ErrorRecord $_ -Tag Retry

			if ($RetryHandler) {
				& $RetryHandler $_
			}

			Start-Sleep -Seconds $currentDelay
			$currentDelay = $currentDelay * 2
		}
	}
}
