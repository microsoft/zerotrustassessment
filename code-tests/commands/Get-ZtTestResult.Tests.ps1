Describe "Get-ZtTestResult" {
	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		# Load the command under test.
		. (Join-Path $srcRoot "private/tests/Get-ZtTestResult.ps1")

		function New-DummyZtTest {
			param(
				[string]$TestId,
				[AllowNull()][string]$Title = "Dummy Test"
			)

			# Mimic the object shape returned by Get-ZtTest.
			[PSCustomObject]@{
				PSTypeName = 'ZeroTrustAssessment.TestMetadata'
				TestID = $TestId
				Command = "Test-Assessment.$TestId"
				Title = $Title
				Pillar = @('Identity')
				TenantType = @('Workforce')
				ImplementationCost = 'Medium'
				RiskLevel = 'Medium'
				UserImpact = 'Low'
			}
		}
	}

	BeforeEach {
		$script:_testCache = $null
	}

	Context "Result creation" {
		It "Creates a new result object with expected defaults" {
			$test = New-DummyZtTest -TestId '35001' -Title 'MFA Coverage'

			$result = Get-ZtTestResult -Test $test

			$result.PSTypeNames | Should -Contain 'ZeroTrustAssessment.TestStatistics'
			$result.TestID | Should -Be '35001'
			$result.Test | Should -Be $test
			$result.DisplayName | Should -Be 'MFA Coverage'
			$result.Start | Should -BeNullOrEmpty
			$result.End | Should -BeNullOrEmpty
			$result.Duration | Should -BeNullOrEmpty
			$result.Attempts | Should -Be 1
			$result.Success | Should -BeTrue
			$result.Error | Should -BeNullOrEmpty
			$result.Messages | Should -BeNullOrEmpty
			$result.TimedOut | Should -BeFalse
			$result.Output | Should -BeNullOrEmpty
		}

		It "Initializes the script cache when it does not yet exist" {
			$script:_testCache = $null
			$test = New-DummyZtTest -TestId '35002' -Title 'Conditional Access'

			$result = Get-ZtTestResult -Test $test

			$script:_testCache | Should -Not -BeNullOrEmpty
			$script:_testCache.GetType().Name | Should -Be 'Hashtable'
			$script:_testCache.ContainsKey('35002') | Should -BeTrue
			$script:_testCache['35002'] | Should -Be $result
		}

		It "Uses TestID as display name when title is null" {
			$test = New-DummyZtTest -TestId '35003' -Title $null

			$result = Get-ZtTestResult -Test $test

			$result.DisplayName | Should -Be '35003'
		}

		It "Uses TestID as display name when title is empty" {
			$test = New-DummyZtTest -TestId '35004' -Title ''

			$result = Get-ZtTestResult -Test $test

			$result.DisplayName | Should -Be '35004'
		}
	}

	Context "Caching behavior" {
		It "Returns the same object instance for repeated calls with the same TestID" {
			$test = New-DummyZtTest -TestId '35005' -Title 'Same ID'

			$first = Get-ZtTestResult -Test $test
			$second = Get-ZtTestResult -Test $test

			$first | Should -Be $second
			[object]::ReferenceEquals($first, $second) | Should -BeTrue
		}

		It "Reflects property updates made to the first output object in the next call for the same TestID" {
			$test = New-DummyZtTest -TestId '35006' -Title 'Mutable Cache'

			$first = Get-ZtTestResult -Test $test
			$first.Success = $false
			$first.Attempts = 3
			$first.TimedOut = $true
			$first.Duration = '00:00:42'
			$first.Output = 'diagnostic payload'
			$first.Messages = @([PSCustomObject]@{ Message = 'mutated-message' })

			$second = Get-ZtTestResult -Test $test

			$second.Success | Should -BeFalse
			$second.Attempts | Should -Be 3
			$second.TimedOut | Should -BeTrue
			$second.Duration | Should -Be '00:00:42'
			$second.Output | Should -Be 'diagnostic payload'
			$second.Messages | Should -HaveCount 1
			$second.Messages[0].Message | Should -Be 'mutated-message'
		}

		It "Creates distinct result objects for different TestIDs" {
			$testA = New-DummyZtTest -TestId '35007' -Title 'Test A'
			$testB = New-DummyZtTest -TestId '35008' -Title 'Test B'

			$resultA = Get-ZtTestResult -Test $testA
			$resultB = Get-ZtTestResult -Test $testB

			$resultA | Should -Not -Be $resultB
			[object]::ReferenceEquals($resultA, $resultB) | Should -BeFalse
			$script:_testCache.Keys | Should -Contain '35007'
			$script:_testCache.Keys | Should -Contain '35008'
		}
	}
}
