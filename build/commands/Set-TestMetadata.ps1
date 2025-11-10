#requires -Modules Refactor
function Set-TestMetadata {
	<#
	.SYNOPSIS
		Update the test metadata included in the command attributes.

	.DESCRIPTION
		Update the test metadata included in the command attributes.
		Uses AST-Parsing to correctly insert & update the attribute used to maintain configuration data in our tests.

	.PARAMETER Test
		The Test ID to update. Used to select the command to modify.

	.PARAMETER TestId
		The actual ID to insert into the attribute.

	.PARAMETER Category
		What category the test belongs to.

	.PARAMETER ImplementationCost
		How high is the cost to implement the finding this test reports?

	.PARAMETER MinimumLicense
		What minimum license(s) are required for this test?

	.PARAMETER Pillar
		What pillar does the test belong to?

	.PARAMETER RiskLevel
		How high is the risk of not mitigating this?

	.PARAMETER SfiPillar
		What SFI pillar does the test map to?

	.PARAMETER TenantType
		What kind of tenant can apply this test?

	.PARAMETER Title
		The title the test uses in the test summary table.

	.PARAMETER UserImpact
		How high is the impact to users, when implementing this?

	.EXAMPLE
		PS C:\> Set-TestMetadata -Test 21771 -RiskLevel High

		Updates the Risk Level of test 21771 to high.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$Test,

		[string]
		$TestId,

		[string]
		$Category,

	[ValidateSet('Low', 'Medium', 'High')]
	[string]
	$ImplementationCost,

	[string[]]
	$MinimumLicense,

	[string]
	$Pillar,		[ValidateSet('Low', 'Medium', 'High')]
		[string]
		$RiskLevel,

		[string]
		$SfiPillar,

		[ValidateSet('Workforce', 'External')]
		[string[]]
		$TenantType,

		[string]
		$Title,

		[ValidateSet('Low', 'Medium', 'High')]
		[string]
		$UserImpact
	)
	begin {
		. "$PSScriptRoot\..\..\src\powershell\private\tests-metadata\Get-ZtTestMetadata.ps1"

		#region Utility Functions
		function New-ZtiAttribute {
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				[hashtable]
				$Update,

				[Parameter(Mandatory = $true)]
				$Current,

				[Parameter(Mandatory = $true)]
				$Definition
			)

			$data = @{}
			foreach ($label in $Definition.Keys) {
				$data[$label] = $Current.$label
			}
			foreach ($pair in $Update.GetEnumerator()) {
				$data[$pair.Key] = $pair.Value
			}

			$text = [System.Text.StringBuilder]::new()
			$null = $text.AppendLine('[ZtTest(')
			foreach ($pair in $Definition.GetEnumerator()) {
				switch ($pair.Value) {
					'string[]' {
						$entries = foreach ($item in $data[$pair.Key]) {
							"'$([System.Management.Automation.Language.CodeGeneration]::EscapeSingleQuotedStringContent($item))'"
						}
						$valueText = "($($entries -join ','))"
						if (-not $entries) {
							$valueText = '$null'
						}
					}
					'int' {
						$valueText = '{0}' -f ($data[$pair.Key] -as [int])
					}
					# Default to string
					default {
						$valueText = "'$([System.Management.Automation.Language.CodeGeneration]::EscapeSingleQuotedStringContent($data[$pair.Key]))'"
					}
				}
				$line = "`t$($pair.Key) = $($valueText),"
				if ($pair.Key -eq $($Definition.Keys)[-1]) {
					$line = $line.TrimEnd(',')
				}
				$null = $text.AppendLine($line)
			}
			$null = $text.Append(')]')

			$data.Text = $text.ToString()
			[PSCustomObject]$data
		}
		function Update-ZtiAttribute {
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				[Refactor.Component.AstResult]
				$Command,

				[Parameter(Mandatory = $true)]
				$Attribute
			)

			# 1) Grab Existing Attribute (if exists)
			$testAttribute = @($Command.Ast.Body.ParamBlock.Attributes).Where{ $_.TypeName.FullName -eq 'ZtTest' }[0]
			$bindingAttribute = @($Command.Ast.Body.ParamBlock.Attributes).Where{ $_.TypeName.FullName -eq 'CmdletBinding' }[0]
			$baseOffset = $Command.Ast.Extent.StartOffset
			$addBinding = $null -eq $bindingAttribute

			# 2A) If so, figure out offsets to insert into and indentation to use.
			if ($testAttribute) {
				$startAt = $testAttribute.Extent.StartOffset - $baseOffset
				$resumeAt = $testAttribute.Extent.EndOffset - $baseOffset
				$baseIndentation = $Command.Text.SubString($startAt - $testAttribute.Extent.StartColumnNumber + 1, $testAttribute.Extent.StartColumnNumber - 1)
			}

			# 2B) If not, figure out offsets & indentation above CmdletBinding
			elseif ($bindingAttribute) {
				$startAt = $bindingAttribute.Extent.StartOffset - $baseOffset
				$resumeAt = $startAt
				$baseIndentation = $Command.Text.SubString($startAt - $bindingAttribute.Extent.StartColumnNumber + 1, $bindingAttribute.Extent.StartColumnNumber - 1)
			}
			# 2C) ... or just above the param
			else {
				$paramBlock = $Command.Ast.Body.ParamBlock
				$startAt = $paramBlock.Extent.StartOffset - $baseOffset
				$resumeAt = $startAt
				$baseIndentation = $Command.Text.SubString($startAt - $paramBlock.Extent.StartColumnNumber + 1, $paramBlock.Extent.StartColumnNumber - 1)
			}

			# 3) Update Text with indentation
			$firstLine = $true
			$lines = foreach ($line in $Attribute.Text -split "`n") {
				if ($firstLine) {
					$firstLine = $false
					$line
					continue
				}

				"$($baseIndentation)$($line)"
			}
			if ($addBinding) {
				$lines += "$($baseIndentation)[CmdletBinding()]"
			}
			$newText = $lines -join "`n"
			if (-not $testAttribute) {
				$newText += "`n$($baseIndentation)"
			}

			# 4) Update Command Object
			$Command.NewText = $Command.Text.SubString(0, $startAt) + $newText + $Command.Text.SubString($resumeAt)
			$Command
		}
		#endregion Utility Functions

		$properties = [ordered]@{
			Category           = 'string'
			ImplementationCost = 'string'
			MinimumLicense     = 'string[]'
			Pillar             = 'string'
			RiskLevel          = 'string'
			SfiPillar          = 'string'
			TenantType         = 'string[]'
			TestId             = 'int'
			Title              = 'string'
			UserImpact         = 'string'
		}
	}
	process {
		foreach ($testID in $Test) {
			#region Preparation
			try {
				$metaData = Get-ZtTestMetadata -Test $testID -IncludeMetadata -ErrorAction Stop
			}
			catch {
				$PSCmdlet.WriteError($_)
				continue
			}

			$toUpdate = $PSBoundParameters | ConvertTo-PSFHashtable -Include $properties.Keys
			foreach ($key in $($toUpdate.Keys)) {
				if ($metaData.$key -eq $toUpdate[$key]) {
					$toUpdate.Remove($key)
				}
			}

			if ($toUpdate.Count -lt 1) {
				Write-PSFMessage -Level Verbose -Message 'Skipping {0}: Nothing to change' -StringValues $testID -Target $testID
				continue
			}
			#endregion Preparation

			$intendedAttribute = New-ZtiAttribute -Update $toUpdate -Current $metaData -Definition $properties
			$command = Read-ReAstComponent -LiteralPath $metaData.Path -Select FunctionDefinitionAst | Where-Object {
				$_.Ast.Name -eq "Test-Assessment-$testID"
			}
			$updCommand = Update-ZtiAttribute -Command $command -Attribute $intendedAttribute
			$updCommand | Write-ReAstComponent
		}
	}
}
