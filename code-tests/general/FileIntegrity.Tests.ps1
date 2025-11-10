. "$($global:__testData.TestRoot)\general\FileIntegrity.Exceptions.ps1"

Describe "Verifying integrity of module files" {
	Context "Validating PS1 Script files" {
		$allFiles = Get-ChildItem -Path $global:__testData.ModuleRoot -Recurse | Where-Object Name -like "*.ps1"

		foreach ($file in $allFiles)
		{
			$name = $file.FullName.Replace("$($global:__testData.ModuleRoot)\", '')

			It "[$name] Should have no trailing space" -TestCases @{ file = $file } {
				($file | Select-String "\s$" | Where-Object { $_.Line.Trim().Length -gt 0}).LineNumber | Should -BeNullOrEmpty
			}

			$tokens = $null
			$parseErrors = $null
			$null = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)

			It "[$name] Should have no syntax errors" -TestCases @{ parseErrors = $parseErrors } {
				$parseErrors | Should -BeNullOrEmpty
			}

			foreach ($command in $global:__testData.Tests.Integrity.BannedCommands)
			{
				if ($global:__testData.Tests.Integrity.MayContainCommand["$command"] -notcontains $file.Name)
				{
					It "[$name] Should not use $command" -TestCases @{ tokens = $tokens; command = $command } {
						$tokens | Where-Object Text -EQ $command | Should -BeNullOrEmpty
					}
				}
			}
		}
	}

	Context "Validating help.txt help files" {
		$allFiles = Get-ChildItem -Path $global:__testData.ModuleRoot -Recurse | Where-Object Name -like "*.help.txt"

		foreach ($file in $allFiles)
		{
			$name = $file.FullName.Replace("$($global:__testData.ModuleRoot)\", '')

			It "[$name] Should have no trailing space" -TestCases @{ file = $file } {
				($file | Select-String "\s$" | Where-Object { $_.Line.Trim().Length -gt 0 } | Measure-Object).Count | Should -Be 0
			}
		}
	}
}
