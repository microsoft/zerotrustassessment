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

	.PARAMETER IgnoreLanguageMode
		When specified, a Constrained Language Mode detection produces a warning instead of a
		terminating error and returns $true, allowing the caller to proceed.
		Use this only when your WDAC policy is configured to trust the module's signing certificate
		and you understand that some functionality may still fail under true CLM.

	.EXAMPLE
		PS C:\> Test-ZtLanguageMode

		Returns $true if running in Full Language Mode, $false otherwise.

	.EXAMPLE
		PS C:\> Test-ZtLanguageMode -IgnoreLanguageMode

		Returns $true even if running in Constrained Language Mode, but prints a warning.
	#>
	[CmdletBinding()]
	[OutputType([bool])]
	param (
		[switch]
		$IgnoreLanguageMode
	)

	$fullLanguage = [System.Management.Automation.PSLanguageMode]::FullLanguage

	# Check 1: Module's own language mode (works in real WDAC/AppLocker CLM where the module loads in CLM)
	$languageMode = $ExecutionContext.SessionState.LanguageMode
	if ($languageMode -ne $fullLanguage) {
		if ($IgnoreLanguageMode) {
			Write-PSFMessage -Level Warning -Message "PowerShell is running in $languageMode mode. Proceeding because -IgnoreLanguageMode was specified. Some functionality may fail."
			if (-not $script:IgnoreLanguageModeWarningShown) {
				Write-Host
				Write-Host "⚠️  WARNING: PowerShell is running in $languageMode mode." -ForegroundColor Yellow
				Write-Host "The -IgnoreLanguageMode switch was specified. The assessment will proceed, but some tests may" -ForegroundColor Yellow
				Write-Host "fail or produce incomplete results if your WDAC policy does not fully trust this module." -ForegroundColor Yellow
				Write-Host
				$script:IgnoreLanguageModeWarningShown = $true
			}
			return $true
		}
		Write-ZtLanguageModeError -LanguageMode $languageMode
		return $false
	}
<#
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
#>
	return $true
}
