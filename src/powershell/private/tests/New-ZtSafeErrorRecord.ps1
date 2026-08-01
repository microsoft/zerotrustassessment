function New-ZtSafeErrorRecord {
	<#
	.SYNOPSIS
		Creates a safe copy of an error record for assessment diagnostics.

	.DESCRIPTION
		Builds a new ErrorRecord without the original TargetObject, which can
		contain HTTP request or response objects with credentials. Its message is
		rebuilt from allow-listed diagnostic fields before use in reports and
		diagnostic artifacts.
	#>
	[CmdletBinding()]
	[OutputType([System.Management.Automation.ErrorRecord])]
	param (
		[Parameter(Mandatory)]
		[System.Management.Automation.ErrorRecord]
		$ErrorRecord
	)
	process {
		$message = Get-ZtSafeErrorMessage -ErrorRecord $ErrorRecord
		$exception = [System.Exception]::new($message)
		$errorId = $ErrorRecord.FullyQualifiedErrorId

		return [System.Management.Automation.ErrorRecord]::new(
			$exception,
			$errorId,
			$ErrorRecord.CategoryInfo.Category,
			$null
		)
	}
}
