function Update-ZtTestMetadata {
	<#
	.SYNOPSIS
		Reloads all tests and updates the metadata.

	.DESCRIPTION
		Reloads all tests and updates the metadata.

		Note:
		This command only works when the Tests available in dedicated files under "<moduleroot>/tests".
		If future plans to merge everything into the psm1 file during build prosper, this command will not have any effect outside of dev environments.

	.EXAMPLE
		PS C:\> Update-ZtTestMetadata

		Reloads all tests and updates the metadata.
	#>
	[CmdletBinding()]
	param ()
	process {
		if (-not (Test-Path -LiteralPath "$($script:ModuleRoot)/tests")) {
			return
		}

		#region Copy test content into module scope
		# Step 1: Prepare Scopes
		$currentScope = [psfscope]::Current()
		$currentScope.EnableFunctions()
		$currentScope.EnableVariables()
		$currentScope.EnableAliases()

		$moduleScope = [psfscope]::Module()
		$moduleScope.EnableFunctions()
		$moduleScope.EnableVariables()
		$moduleScope.EnableAliases()

		$stateBefore = @{
			# Enumerate (through subexpressions) to ensure we are NOT storing references that get updated on us
			Functions = $($currentScope.Functions.Keys)
			Variables = $($currentScope.Variables.Keys)
			Aliases   = $($currentScope.Aliases.Keys)
		}

		# Step 2: Load all test files into the current context
		foreach ($file in Get-ChildItem -LiteralPath "$($script:ModuleRoot)/tests" -Filter *.ps1) {
			try {
				. $file.FullName
			}
			catch {
				Write-PSFMessage -Level Warning -Message "Failed to reload {0}" -StringValues $file.Name -ErrorRecord $_ -Target $file
			}
		}

		# Step 3: Copy changes to the current context into the module scope
		foreach ($functionKey in $($currentScope.Functions.Keys)) {
			if ($functionKey -in $stateBefore.Functions) {
				continue
			}
			$moduleScope.Functions[$functionKey] = $currentScope.Functions[$functionKey]
		}
		foreach ($variablesKey in $($currentScope.Variables.Keys)) {
			if ($variablesKey -in $stateBefore.Variables) {
				continue
			}
			$moduleScope.Variables[$variablesKey] = $currentScope.Variables[$variablesKey]
		}
		foreach ($aliasKey in $($currentScope.Aliases.Keys)) {
			if ($aliasKey -in $stateBefore.Aliases) {
				continue
			}
			$moduleScope.Aliases[$aliasKey] = $currentScope.Aliases[$aliasKey]
		}

		#endregion Copy test content into module scope

		# Clear the tests cache
		$script:__ZtSession.TestMeta = @()
	}
}
