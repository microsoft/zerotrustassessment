function Write-ZtTestError {
	<#
	.SYNOPSIS
		Write the error that happened in a test.

	.DESCRIPTION
		Write the error that happened in a test.
		This handles the logging of an error, as well as updating the markdown.

	.PARAMETER Result
		The result object of the test.
		Used by Get-ZtTestStatistics.

	.PARAMETER Test
		The test object for the test that failed.

	.PARAMETER ErrorRecord
		The Error that happened.

	.EXAMPLE
		PS C:\> Write-ZtTestError -Test $this -Result $result -ErrorRecord $_

		Writes the error that happened in the specified test.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Result,

		[Parameter(Mandatory = $true)]
		$Test,

		$ErrorRecord
	)
	process {
		$safeError = New-ZtSafeErrorRecord -ErrorRecord $ErrorRecord
		Write-PSFMessage -Level Warning -Message "Error executing test '{0}': {1}" -StringValues $Test.TestID, $safeError.Exception.Message -Target $Test -ErrorRecord $safeError
		$Result.Success = $false
		$Result.Error = $safeError
		$message = Format-ZtTestErrorDetail -Test $Test -ErrorRecord $ErrorRecord
		Add-ZtTestResultDetail -TestId $Test.TestID -Title $Test.Title -Status $false -Result $message -CustomStatus 'Error'
		Update-ZtProgressState -WorkerId $Test.TestID -WorkerName $Result.DisplayName -WorkerStatus 'Error' -WorkerDetail "Error: $($safeError.Exception.Message)"
	}
}
