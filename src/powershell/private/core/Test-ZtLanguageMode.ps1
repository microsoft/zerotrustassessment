function Test-ZtLanguageMode {
	<#
	.SYNOPSIS
		Validates that PowerShell is running in Full Language Mode.

	.DESCRIPTION
		Validates that PowerShell is running in Full Language Mode.
		Constrained Language Mode (enforced by AppLocker or WDAC policies) is not supported
		because PSFramework runspace workers will refuse to execute untrusted script blocks.

		Checks both the module's own session state (for real WDAC/AppLocker CLM)
		and the global session state via the runspace proxy (for manual CLM testing).

	.EXAMPLE
		PS C:\> Test-ZtLanguageMode

		Returns $true if running in Full Language Mode, $false otherwise.
	#>
	[CmdletBinding()]
	param ()

	# Check 1: Module's own language mode (works in real WDAC/AppLocker CLM where the module loads in CLM)
	$languageMode = $ExecutionContext.SessionState.LanguageMode
	if ($languageMode -ne 'FullLanguage') {
		Write-ZtLanguageModeError -LanguageMode $languageMode
		return $false
	}

	# Check 2: Global session state language mode (catches manual CLM testing where module was imported in FLM)
	try {
		$globalLanguageMode = [runspace]::DefaultRunspace.SessionStateProxy.GetVariable('ExecutionContext').SessionState.LanguageMode
		if ($globalLanguageMode -ne 'FullLanguage') {
			Write-ZtLanguageModeError -LanguageMode $globalLanguageMode
			return $false
		}
	}
	catch {
		# If we can't read the global language mode, assume it's not FullLanguage
		Write-ZtLanguageModeError -LanguageMode 'Constrained Language'
		return $false
	}

	return $true
}

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
		$LanguageMode
	)

	Write-Host
	Write-Host "UNSUPPORTED: PowerShell is running in $LanguageMode mode" -ForegroundColor Red
	Write-Host "ZeroTrustAssessment requires Full Language Mode to function properly." -ForegroundColor Yellow
	Write-Host "Constrained Language Mode is typically enforced by AppLocker or Windows Defender Application Control (WDAC) policies." -ForegroundColor Yellow
	Write-Host "Please run this assessment on a device where PowerShell is not running in a constrained mode." -ForegroundColor Yellow
	Write-Host
}
