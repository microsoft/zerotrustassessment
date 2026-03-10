function Write-ZtLanguageModeError {
	<#
	.SYNOPSIS
		Writes the language mode error message to the host.

	.DESCRIPTION
		Helper function to write the Constrained Language Mode error to avoid duplicating the message.

	.PARAMETER LanguageMode
		The detected language mode to display in the error message.
	#>
	[CmdletBinding()]
	param (
		[System.Management.Automation.PSLanguageMode]
		$LanguageMode
	)

	$message = "UNSUPPORTED: PowerShell is running in $LanguageMode mode. ZeroTrustAssessment requires Full Language Mode to function properly."
	Write-PSFMessage -Level Error -Message $message

	Write-Host
	Write-Host "UNSUPPORTED: PowerShell is running in $LanguageMode mode" -ForegroundColor Red
	Write-Host "ZeroTrustAssessment requires Full Language Mode to function properly." -ForegroundColor Yellow
	Write-Host "Constrained Language Mode is typically enforced by AppLocker or Windows Defender Application Control (WDAC) policies." -ForegroundColor Yellow
	Write-Host "Please run this assessment on a device where PowerShell is not running in a constrained mode." -ForegroundColor Yellow
	Write-Host
}
