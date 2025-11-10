#requires -Modules PSFramework
function Get-AstFunctionDefinition {
	<#
	.SYNOPSIS
		Reads all top-level function definitions from a script file.

	.DESCRIPTION
		Reads all top-level function definitions from a script file.
		Useful for Scanning & processing commands in a module.

	.PARAMETER Path
		Path to the files to scan.

	.EXAMPLE
		PS C:\> Get-ChildItem -Filter *.ps1 | Get-AstFunctionDefinition

		Get all functions from the current folder's files.
	#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		[PSFFile[]]
		$Path
	)
	process {
		foreach ($filePath in $Path) {
			$ast = [System.Management.Automation.Language.Parser]::ParseFile($filePath, [ref]$null, [ref]$null)
			$statements = $ast.BeginBlock.Statements, $ast.ProcessBlock.Statements, $ast.EndBlock.Statements | Remove-PSFNUll -Enumerate
			foreach ($statement in $statements) {
				if ($statement -isnot [System.Management.Automation.Language.FunctionDefinitionAst]) { continue }

				[PSCustomObject]@{
					Name = $statement.Name
					FileName = Split-Path -Path $filePath -Leaf
					FilePath = $filePath
					Line = $statement.Extent.StartLineNumber
					Code = $statement.Extent.Text
					Ast = $statement
				}
			}
		}
	}
}
