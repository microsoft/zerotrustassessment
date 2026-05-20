function Set-ZtTimedOutResult {
	param (
		[Parameter(Mandatory)]
		$Result,

		[Parameter(Mandatory)]
		$Test,

		[Parameter(Mandatory)]
		[timespan]
		$Timeout
	)

	if ($Result.TimedOut) {
		return
	}

	$Result.TimedOut = $true
	$Result.Success = $false
	$Result.Output = $null
	$Result.Error = New-ZtTimeoutErrorRecord -Test $Test -Timeout $Timeout

	try {
		Add-ZtTestResultDetail -TestId $Test.TestID -Status $false -CustomStatus 'Error' -Result "The test did not complete within the configured timeout of $($Timeout.ToString('hh\:mm\:ss')). Partial results, if any, were discarded."
	}
	catch {
		Write-PSFMessage -Level Warning -Message "Failed to overwrite timed-out test result detail for test '{0}': {1}" -StringValues $Test.TestID, $_ -Target $Test -Tag timeout
	}

	Write-PSFMessage -Level Warning -Message "Test '{0}' timed out after {1}" -StringValues $Test.TestID, $Timeout.ToString('hh\:mm\:ss') -Target $Test -ErrorRecord $Result.Error -Tag timeout
}
