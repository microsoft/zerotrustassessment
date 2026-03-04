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
	[OutputType([bool])]
	param ()

	$fullLanguage = [System.Management.Automation.PSLanguageMode]::FullLanguage

	# Check 1: Module's own language mode (works in real WDAC/AppLocker CLM where the module loads in CLM)
	$languageMode = $ExecutionContext.SessionState.LanguageMode
	if ($languageMode -ne $fullLanguage) {
		Write-ZtLanguageModeError -LanguageMode $languageMode
		return $false
	}

	# Check 2: Global session state language mode (catches manual CLM testing where module was imported in FLM)
	try {
		$globalLanguageMode = [runspace]::DefaultRunspace.SessionStateProxy.GetVariable('ExecutionContext').SessionState.LanguageMode
		if ($globalLanguageMode -ne $fullLanguage) {
			Write-ZtLanguageModeError -LanguageMode $globalLanguageMode
			return $false
		}
	}
	catch {
		# If we can't read the global language mode, assume it's not FullLanguage
		Write-ZtLanguageModeError -LanguageMode ([System.Management.Automation.PSLanguageMode]::ConstrainedLanguage)
		return $false
	}

	return $true
}
