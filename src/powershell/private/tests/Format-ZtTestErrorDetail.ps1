function Format-ZtTestErrorDetail {
	<#
	.SYNOPSIS
		Formats safe diagnostic details for a failed assessment test.

	.DESCRIPTION
		Creates the existing failed-test markdown structure from allow-listed
		error properties. It intentionally does not format arbitrary ErrorRecord
		properties such as TargetObject, request headers, or exception data.
	#>
	[CmdletBinding()]
	[OutputType([string])]
	param (
		[Parameter(Mandatory)]
		$Test,

		[Parameter(Mandatory)]
		[System.Management.Automation.ErrorRecord]
		$ErrorRecord
	)
	process {
		$safeError = New-ZtSafeErrorRecord -ErrorRecord $ErrorRecord
		$details = [System.Collections.Generic.List[string]]::new()
		$details.Add("Exception Type: $($ErrorRecord.Exception.GetType().FullName)")
		$details.Add("Fully Qualified Error ID: $($safeError.FullyQualifiedErrorId)")

		$statusCode = Get-ZtHttpStatusCode -ErrorRecord $ErrorRecord
		if ($null -ne $statusCode) {
			$details.Add("HTTP Status Code: $statusCode")
		}

		if ($ErrorRecord.InvocationInfo -and $ErrorRecord.InvocationInfo.ScriptName) {
			$details.Add("Location: $($ErrorRecord.InvocationInfo.ScriptName):$($ErrorRecord.InvocationInfo.ScriptLineNumber)")
		}

		return @(
			'❌  Test {0} failed due to an unexpected error.' -f $Test.TestID
			' - **Error Message**: {0}.' -f $safeError.Exception.Message
			'```'
			($details -join [Environment]::NewLine)
			'```'
		) -join "`r`n"
	}
}
