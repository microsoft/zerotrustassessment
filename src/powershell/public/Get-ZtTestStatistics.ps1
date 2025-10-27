function Get-ZtTestStatistics {
	<#
	.SYNOPSIS
		Retrieve the statistics of the previous Test run.

	.DESCRIPTION
		Retrieve the statistics of the previous Test run.
		Only execute after running INvoke-ZtAssessment.

		Used for debugging purposes, allowing analysis about individual tests and how they were processed.

	.PARAMETER TestID
		The IDs of tests for which to retrieve their statistics.

	.EXAMPLE
		PS C:\> Get-ZtTestStatistics

		List all processing statistics for all tests.
	#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$TestID
	)
	process {
		if (-not $TestID) {
			$script:__ZtSession.TestStatistics.Value.Values
			return
		}
		foreach ($test in $TestID) {
			$script:__ZtSession.TestStatistics.Value[$test]
		}
	}
}
