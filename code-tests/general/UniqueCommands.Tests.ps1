Describe "Each Command should only be defined once" {
	$commandGroups = Get-ChildItem -Path $global:__testData.ModuleRoot -Recurse | Where-Object Name -Like "*.ps1" | Get-AstFunctionDefinition | Group-Object Name

	foreach ($commandGroup in $commandGroups) {
		It "Should have only one copy of $($commandGroup.Name)" -TestCases @{ commandGroup = $commandGroup} {
			$commandGroup.Group.FilePath | Should -HaveCount 1
		}
	}
}
