Describe "Write-ZtTestFinish" {
	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		# Load SUT and helper used to build the real result object for tests.
		. (Join-Path $srcRoot "private/tests/Get-ZtTestResult.ps1")
		. (Join-Path $srcRoot "private/tests/Write-ZtTestFinish.ps1")

		# Ensure PSFramework message commands exist for message setup/validation.
		if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
			Import-Module PSFramework -ErrorAction Stop
		}

		if (-not (Get-Command Clear-PSFMessage -ErrorAction SilentlyContinue)) {
			$script:__MessageStore = @()

			function Clear-PSFMessage {
				$script:__MessageStore = @()
			}

			function Write-PSFMessage {
				param(
					$Level,
					$Message,
					$Tag
				)
				$script:__MessageStore += [PSCustomObject]@{
					Timestamp = Get-Date
					Level = $Level
					Message = $Message
					Tags = @($Tag)
					Runspace = [runspace]::DefaultRunspace.InstanceId
				}
			}

			function Get-PSFMessage {
				param($Runspace)
				if ($Runspace) {
					return @($script:__MessageStore | Where-Object Runspace -eq $Runspace)
				}
				return @($script:__MessageStore)
			}
		}

		function New-DummyZtTest {
			param(
				[string]$TestId,
				[string]$Title = "Dummy Test"
			)

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
		# Start each test from a clean PSF message state, then add baseline messages.
		Clear-PSFMessage
		Write-PSFMessage -Level Verbose -Message "baseline-message-1"
		Write-PSFMessage -Level Verbose -Message "baseline-message-2"

		$script:__PSF_Worker = [PSCustomObject]@{ OutQueue = 'OutQueue' }
		$script:_testCache = @{}

		Mock Get-PSFConfigValue {
			50
		} -ParameterFilter {
			$FullName -eq 'ZeroTrustAssessment.Tests.Statistics.MaxMessageCount'
		}

		Mock Write-ZtTestStatistics {}
		Mock Update-ZtProgressState {}
		Mock Write-ZtTestLog {}
		Mock Write-ZtTestProgress {}
		Mock Write-PSFRunspaceQueue {}
	}

	Context "When using -PassThru" {
		It "Returns the same result object, updates Done progress and writes completed test progress" {
			$test = New-DummyZtTest -TestId '99901' -Title 'Successful Test'
			$testResult = Get-ZtTestResult -Test $test
			$testResult.Success = $true
			$testResult.TimedOut = $false
			$testResult.Duration = '00:00:12'

			$previousMessages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
			Write-PSFMessage -Level Verbose -Message 'new-message-success-1'
			Write-PSFMessage -Level Verbose -Message 'new-message-success-2'

			$actual = Write-ZtTestFinish -Result $testResult -PreviousMessages $previousMessages -Test $test -LogsPath 'C:\temp\logs' -PassThru

			$actual | Should -Be $testResult
			$testResult.Messages | Should -HaveCount 2
			$testResult.Messages.Message | Should -Contain 'new-message-success-1'
			$testResult.Messages.Message | Should -Contain 'new-message-success-2'
			$testResult.Messages.Message | Should -Not -Contain 'baseline-message-1'

			Should -Invoke Get-PSFConfigValue -Times 1 -Exactly -ParameterFilter {
				$FullName -eq 'ZeroTrustAssessment.Tests.Statistics.MaxMessageCount'
			}
			Should -Invoke Write-ZtTestStatistics -Times 1 -Exactly -ParameterFilter {
				$Result -eq $testResult
			}
			Should -Invoke Update-ZtProgressState -Times 1 -Exactly -ParameterFilter {
				$WorkerId -eq $test.TestID -and
				$WorkerName -eq $testResult.DisplayName -and
				$WorkerStatus -eq 'Done' -and
				$WorkerDetail -eq ''
			}
			Should -Invoke Write-ZtTestLog -Times 1 -Exactly -ParameterFilter {
				$Result -eq $testResult -and $LogsPath -eq 'C:\temp\logs'
			}
			Should -Invoke Write-ZtTestProgress -Times 1 -Exactly -ParameterFilter {
				$TestID -eq $testResult.TestID -and
				$LogsPath -eq 'C:\temp\logs' -and
				$Action -eq 'Completed' -and
				$Duration -eq $testResult.Duration
			}
			Should -Invoke Write-PSFRunspaceQueue -Times 0 -Exactly

			$script:_testCache.ContainsKey($test.TestID) | Should -BeFalse
		}
	}

	Context "When omitting -PassThru" {
		It "Writes result to runspace queue and handles timeout state" {
			$test = New-DummyZtTest -TestId '99902' -Title 'Timed Out Test'
			$testResult = Get-ZtTestResult -Test $test
			$testResult.Success = $false
			$testResult.TimedOut = $true
			$testResult.Duration = '00:00:30'
			$testResult.Error = 'timeout exceeded'

			$previousMessages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
			Write-PSFMessage -Level Verbose -Message 'new-message-timeout'

			$actual = Write-ZtTestFinish -Result $testResult -PreviousMessages $previousMessages -Test $test -LogsPath 'C:\temp\logs'

			$actual | Should -BeNullOrEmpty
			$testResult.Messages | Should -HaveCount 1
			$testResult.Messages[0].Message | Should -Be 'new-message-timeout'

			Should -Invoke Write-ZtTestStatistics -Times 1 -Exactly -ParameterFilter {
				$Result -eq $testResult
			}
			Should -Invoke Update-ZtProgressState -Times 1 -Exactly -ParameterFilter {
				$WorkerId -eq $test.TestID -and
				$WorkerName -eq $testResult.DisplayName -and
				$WorkerStatus -eq 'TimedOut' -and
				$WorkerDetail -eq "Timed out after $($testResult.Duration)"
			}
			Should -Invoke Write-ZtTestLog -Times 1 -Exactly -ParameterFilter {
				$Result -eq $testResult -and $LogsPath -eq 'C:\temp\logs'
			}
			Should -Invoke Write-ZtTestProgress -Times 1 -Exactly -ParameterFilter {
				$TestID -eq $testResult.TestID -and
				$LogsPath -eq 'C:\temp\logs' -and
				$Action -eq 'TimedOut' -and
				$Duration -eq $testResult.Duration -and
				$ErrorMessage -eq 'timeout exceeded'
			}
			Should -Invoke Write-PSFRunspaceQueue -Times 1 -Exactly -ParameterFilter {
				$Name -eq 'OutQueue' -and
				$Value -eq $testResult -and
				$UseCurrent
			}

			$script:_testCache.ContainsKey($test.TestID) | Should -BeFalse
		}
	}

	Context "Error and failed logging paths" {
		It "Writes Error progress action with exception message when Result.Error exists" {
			$test = New-DummyZtTest -TestId '99903' -Title 'Error Test'
			$result = Get-ZtTestResult -Test $test
			$result.Success = $false
			$result.TimedOut = $false
			$result.Duration = '00:00:05'
			$result.Error = [System.Management.Automation.ErrorRecord]::new(
				[System.Exception]::new('failed to execute test logic'),
				'WriteZtTestFinish.Error',
				[System.Management.Automation.ErrorCategory]::NotSpecified,
				$null
			)

			$previousMessages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
			Write-PSFMessage -Level Verbose -Message 'new-message-error'

			Write-ZtTestFinish -Result $result -PreviousMessages $previousMessages -Test $test -LogsPath 'C:\temp\logs' -PassThru | Out-Null

			Should -Invoke Update-ZtProgressState -Times 0 -Exactly
			Should -Invoke Write-ZtTestProgress -Times 1 -Exactly -ParameterFilter {
				$Action -eq 'Error' -and
				$Duration -eq $result.Duration -and
				$ErrorMessage -eq 'Error: failed to execute test logic'
			}
		}

		It "Writes Failed progress action when there is no Result.Error" {
			$test = New-DummyZtTest -TestId '99904' -Title 'Failed Test'
			$result = Get-ZtTestResult -Test $test
			$result.Success = $false
			$result.TimedOut = $false
			$result.Duration = '00:00:09'
			$result.Error = $null

			$previousMessages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
			Write-PSFMessage -Level Verbose -Message 'new-message-failed'

			Write-ZtTestFinish -Result $result -PreviousMessages $previousMessages -Test $test -LogsPath 'C:\temp\logs' -PassThru | Out-Null

			Should -Invoke Update-ZtProgressState -Times 0 -Exactly
			Should -Invoke Write-ZtTestProgress -Times 1 -Exactly -ParameterFilter {
				$Action -eq 'Failed' -and
				$Duration -eq $result.Duration -and
				$null -eq $ErrorMessage
			}
		}
	}

	Context "Log path optionality and message truncation" {
		It "Does not write test log/progress when -LogsPath is empty" {
			$test = New-DummyZtTest -TestId '99905' -Title 'No Logs Test'
			$result = Get-ZtTestResult -Test $test
			$result.Success = $true
			$result.Duration = '00:00:02'

			$previousMessages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
			Write-PSFMessage -Level Verbose -Message 'new-message-no-logs'

			Write-ZtTestFinish -Result $result -PreviousMessages $previousMessages -Test $test -PassThru | Out-Null

			Should -Invoke Write-ZtTestLog -Times 0 -Exactly
			Should -Invoke Write-ZtTestProgress -Times 0 -Exactly
		}

		It "Truncates message objects to selected properties when count exceeds configured limit" {
			Mock Get-PSFConfigValue {
				1
			} -ParameterFilter {
				$FullName -eq 'ZeroTrustAssessment.Tests.Statistics.MaxMessageCount'
			}

			$test = New-DummyZtTest -TestId '99906' -Title 'Message Limit Test'
			$result = Get-ZtTestResult -Test $test
			$result.Success = $true
			$result.Duration = '00:00:03'

			$previousMessages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
			Write-PSFMessage -Level Verbose -Message 'new-message-limit-1' -Tag 'Tag1'
			Write-PSFMessage -Level Verbose -Message 'new-message-limit-2' -Tag 'Tag2'

			Write-ZtTestFinish -Result $result -PreviousMessages $previousMessages -Test $test -PassThru | Out-Null

			$result.Messages.Count | Should -Be 2
			$propertyNames = $result.Messages[0].PSObject.Properties.Name
			$propertyNames | Should -Contain 'Timestamp'
			$propertyNames | Should -Contain 'Level'
			$propertyNames | Should -Contain 'Message'
			$propertyNames | Should -Contain 'Tags'
			$propertyNames | Should -Contain 'Runspace'
			$propertyNames | Should -Not -Contain 'FunctionName'
		}
	}
}
