function Get-ZtTestMetadata {
	<#
	.SYNOPSIS
		Reads the configured Test Metadata tracking information from commands.

	.DESCRIPTION
		Reads the configured Test Metadata tracking information from commands.
		This is added to the function definitions as a "ZtTest" attribute.

	.PARAMETER Test
		Select the command to process by Test ID.
		Will automatically look through the tests folder, pick the test and process.

	.PARAMETER Path
		Path to a script file to process.
		Will scan all top-level functions and return a result for each of them.

	.PARAMETER Command
		The command object to process.
		Must be a function definition.

	.PARAMETER IncludeMetadata
		Include PowerShell Metadata:
		- Path to the file containing the test
		- AST of the test code (the PowerShell Parser view of the test code)

	.EXAMPLE
		PS C:\> Get-ZtTestMetadata -Test 21770

		Returns the metadata for the test with ID "21770"
	#>
	[CmdletBinding()]
	param (
		[string[]]
		$Test,

		[PSFFile]
		$Path,

		[System.Management.Automation.FunctionInfo[]]
		$Command,

		[switch]
		$IncludeMetadata
	)
	begin {
		#region Utility Functions
		function Get-TestFunctionAst {
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				[string]
				$TestRoot,

				[Parameter(Mandatory = $true)]
				[string]
				$Test
			)

			$filePath = Join-Path -Path $TestRoot -ChildPath "Test-Assessment.$Test.ps1"
			if (-not (Test-Path -Path $filePath)) {
				Write-Error "Test not found: $Test"
				return
			}

			$testItem = Get-PathFunctionAst -Path $filePath | Where-Object Name -EQ "Test-Assessment-$Test"
			if (-not $testItem) {
				Write-Error "Test File found, but does not contain a command 'Test-Assessment-$Test'!"
				return
			}
			$testItem
		}

		function Get-PathFunctionAst {
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				[string]
				$Path
			)

			$ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$null)
			$functionDefinitions = [System.Collections.Generic.List[object]]::new()
			foreach ($statement in $ast.BeginBlock.Statements) {
				if ($statement -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
					$functionDefinitions.Add($statement)
				}
			}
			foreach ($statement in $ast.ProcessBlock.Statements) {
				if ($statement -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
					$functionDefinitions.Add($statement)
				}
			}
			foreach ($statement in $ast.EndBlock.Statements) {
				if ($statement -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
					$functionDefinitions.Add($statement)
				}
			}

			foreach ($functionDefinition in $functionDefinitions) {
				[PSCustomObject]@{
					Name = $functionDefinition.Name
					Ast  = $functionDefinition
					File = $functionDefinition.Extent.File -replace '^.+(\\|/)'
					Path = $functionDefinition.Extent.File
				}
			}
		}

		function Get-FunctionAst {
			[CmdletBinding()]
			param (
				[System.Management.Automation.FunctionInfo]
				$Command
			)

			[PSCustomObject]@{
				Name = $Command.Name
				Ast  = $Command.ScriptBlock.Ast
				File = $Command.ScriptBlock.Ast.Extent.File -replace '^.+(\\|/)'
				Path = $Command.ScriptBlock.Ast.Extent.File
			}
		}
		#endregion Utility Functions

		# Case: Loaded through the module
		if ($script:ModuleRoot) {
			$testRoot = Join-Path $script:ModuleRoot 'tests'
		}
		# Case: Called Directly from the build tools
		else {
			$testRoot = Join-Path $PSScriptRoot '..' '..' 'tests'
		}
	}
	process {
		$commandAsts = [System.Collections.Generic.List[object]]::new()
		$astResults = foreach ($testID in $Test) {
			Get-TestFunctionAst -TestRoot $testRoot -Test $testID
		}
		if ($astResults) {
			$commandAsts.AddRange(@($astResults))
		}
		$astResults = foreach ($filePath in $Path) {
			Get-PathFunctionAst -Path $filePath
		}
		if ($astResults) {
			$commandAsts.AddRange(@($astResults))
		}
		$astResults = foreach ($functionDefinition in $Command) {
			Get-FunctionAst -Command $functionDefinition
		}
		if ($astResults) {
			$commandAsts.AddRange(@($astResults))
		}

		foreach ($commandItem in $commandAsts) {
			$result = [PSCustomObject]@{
				PSTypeName         = 'ZeroTrustAssessment.Test'
				Command            = $commandItem.Name
				TestId             = $commandItem.Ast.Name -replace '^Test-Assessment-'
				Category           = $null
				ImplementationCost = $null
				MinimumLicense     = $null
				Pillar             = $null
				RiskLevel          = $null
				SfiPillar          = $null
				TenantType         = $null
				Title              = $null
				UserImpact         = $null
			}
			if ($IncludeMetadata) {
				$extra = @{
					Path = $commandItem.Path
					Ast  = $commandItem.Ast
				}
				if ($extra.Path -and (Test-Path -Path $extra.Path)) {
					$extra.Path = (Get-Item -LiteralPath $extra.Path).FullName
				}
				[PSFramework.Object.ObjectHost]::AddNoteProperty($result, $extra)
			}

			$testAttribute = $commandItem.Ast.Body.ParamBlock.Attributes.Where{ $_.TypeName.FullName -eq 'ZtTest' }
			if ($testAttribute) {
				foreach ($argument in $testAttribute.NamedArguments) {
					if ($result.PSObject.Properties.Name -notcontains $argument.ArgumentName) {
						continue
					}

					$result.$($argument.ArgumentName) = $argument.Argument.SafeGetValue()
				}
			}

			$result
		}
	}
}
