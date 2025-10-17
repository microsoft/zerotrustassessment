function Write-ZtTestStatistics {
	<#
	.SYNOPSIS
		Writes the execution statistics of a Test to the process-wide cache.

	.DESCRIPTION
		Writes the execution statistics of a Test to the process-wide cache.

	.PARAMETER Result
		The execution statistics to write.
		Should nclude the Test ID, all messages, duration, errors, etc.

	.EXAMPLE
		PS C:\> Write-ZtTestStatistics -Result $result

		Writes the execution statistics of the specified test to the process-wide cache.
	#>
	[CmdletBinding()]
	param (
		$Result
	)
	process {
		$script:__ZtSession.TestStatistics.Value[$Result.TestID] = $Result
	}
}
