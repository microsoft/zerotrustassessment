function Get-ZtTestResult {
	<#
	.SYNOPSIS
		Retrieve the test result object for the specified test.

	.DESCRIPTION
		Retrieve the test result object for the specified test.
		This will - on first call - generate a new, mostly empty object.
		On subsequent calls - during retries or when considering on whether to retry at all - it will return the same object, which presumably has been updated since.

		Note: The cached result object is cleared from the test cache when calling Write-ZtTestFinish.
		Calling Get-ZtTestResult after that will again create a new result object.

	.PARAMETER Test
		The test object for which we need a result dataset

	.EXAMPLE
		PS C:\> Get-ZtTestResult -Test $Test

		Retrieve the test result object for the specified test.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Test
	)
	begin {
		if (-not $script:_testCache) {
			$script:_testCache = @{}
		}
	}
	process {
		if ($script:_testCache[$Test.TestID]) {
			return $script:_testCache[$Test.TestID]
		}
		$script:_testCache[$Test.TestID] = [PSCustomObject]@{
			PSTypeName  = 'ZeroTrustAssessment.TestStatistics'
			TestID      = $Test.TestID
			Test        = $Test
			DisplayName = $Test.Title ? $Test.Title : $Test.TestID

			# Performance Metrics, in case we want to identify problematic tests
			Start       = $null
			End         = $null
			Duration    = $null
			Attempts    = 1

			# What Happened?
			Success     = $true
			Error       = $null
			Messages    = $null
			TimedOut    = $false

			# Test should have no output, but we'll catch it anyways, just in case
			Output      = $null
		}
		$script:_testCache[$Test.TestID]
	}
}
