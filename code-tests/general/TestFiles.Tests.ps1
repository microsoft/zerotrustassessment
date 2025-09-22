Describe "The Tests should be properly configured" {
	BeforeAll {
		$ps1Files = Get-ChildItem -Path "$($global:__testData.ModuleRoot)/tests/*.ps1"
		$mdFiles = Get-ChildItem -Path "$($global:__testData.ModuleRoot)/tests/*.md"
		$tests = Get-ZtTest
	}

	Context "All Code Files should have a matching test & document" {
		$ps1Files = Get-ChildItem -Path "$($global:__testData.ModuleRoot)/tests/*.ps1"
		foreach ($file in $ps1Files) {
			It "should have a test for $($file.Name)" -TestCases @{ file = $file } {
				$testId = $file.BaseName -replace '\D'
				$commandName = $file.BaseName -replace '\.','-'
				$tests | Where-Object { $_.TestId -eq $testId -and $_.Command -eq $commandName} | Should -HaveCount 1
			}
			It "should have a matching markdown file for $($file.Name)" -TestCases @{ file = $file } {
				$file.BaseName | Should -BeIn $mdFiles.BaseName
			}
		}
	}

	Context "All Markdown Files should have a matching test & document" {
		$mdFiles = Get-ChildItem -Path "$($global:__testData.ModuleRoot)/tests/*.md"
		foreach ($file in $mdFiles) {
			It "should have a test for $($file.Name)" -TestCases @{ file = $file } {
				$testId = $file.BaseName -replace '\D'
				$commandName = $file.BaseName -replace '\.','-'
				$tests | Where-Object { $_.TestId -eq $testId -and $_.Command -eq $commandName} | Should -HaveCount 1
			}
			It "should have a matching code file for $($file.Name)" -TestCases @{ file = $file } {
				$file.BaseName | Should -BeIn $ps1Files.BaseName
			}
		}
	}

	Context "All Tests should be properly configured" {
		$tests = Get-ZtTest
		foreach ($test in $tests) {
			It "should have a matching code file for $($test.TestId)" -TestCases @{ test = $test } {
				$name = $test.Command -replace '-(\d+)$','.$1'
				$name | Should -BeIn $ps1Files.BaseName
			}
			It "should have a matching markdown file for $($test.TestId)" -TestCases @{ test = $test } {
				$name = $test.Command -replace '-(\d+)$','.$1'
				$name | Should -BeIn $mdFiles.BaseName
			}
			It "should have an ImplementationCost defined for $($test.TestId)" -TestCases @{ test = $test } {
				$test.ImplementationCost | Should -Not -BeNullOrEmpty
			}
			It "should have a RiskLevel defined for $($test.TestId)" -TestCases @{ test = $test } {
				$test.RiskLevel | Should -Not -BeNullOrEmpty
			}
			It "should have a UserImpact defined for $($test.TestId)" -TestCases @{ test = $test } {
				$test.UserImpact | Should -Not -BeNullOrEmpty
			}
			It "should have a Title defined for $($test.TestId)" -TestCases @{ test = $test } {
				$test.Title | Should -Not -BeNullOrEmpty
			}
			It "should have a TenantType defined for $($test.TestId)" -TestCases @{ test = $test } {
				$test.TenantType | Should -Not -BeNullOrEmpty
			}
		}
	}
}
