function New-ZtTimeoutErrorRecord {
	param (
		[Parameter(Mandatory)]
		$Test,

		[Parameter(Mandatory)]
		[timespan]
		$Timeout
	)

	$message = "Test '$($Test.TestID)' timed out after $($Timeout.ToString('hh\:mm\:ss'))"
	$exception = [System.TimeoutException]::new($message)
	[System.Management.Automation.ErrorRecord]::new(
		$exception,
		'ZtTestTimeout',
		[System.Management.Automation.ErrorCategory]::OperationTimeout,
		$Test
	)
}
