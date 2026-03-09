Describe "Each function file should only contain one command" {
	$fileGroups = Get-ChildItem -Path "$($global:__testData.ModuleRoot)\public", "$($global:__testData.ModuleRoot)\private" -Recurse | Where-Object Name -Like "*.ps1" | Get-AstFunctionDefinition | Group-Object FilePath

	foreach ($fileGroup in $fileGroups) {
		It "Should have only one command in $($fileGroup.Name)" -TestCases @{ fileGroup = $fileGroup} {
			$fileGroup.Group.Name | Should -HaveCount 1
		}
	}
}
