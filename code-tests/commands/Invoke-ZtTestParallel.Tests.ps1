Describe "Invoke-ZtTestParallel" {
	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		. (Join-Path $srcRoot "private/tests/Invoke-ZtTestParallel.ps1")

		# Provide PSFramework message functions when PSFramework is unavailable.
		if (-not (Get-Command Clear-PSFMessage -ErrorAction SilentlyContinue)) {
			$script:__MessageStore = @()

			function Clear-PSFMessage {
				$script:__MessageStore = @()
			}

			function Write-PSFMessage {
				param(
					$Level,
					$Message,
					$StringValues,
					$Target,
					$Tag
				)

				$renderedMessage = if ($StringValues) {
					$Message -f $StringValues
				}
				else {
					$Message
				}

				$script:__MessageStore += [PSCustomObject]@{
					Timestamp = Get-Date
					Level = $Level
					Message = $renderedMessage
					Tag = $Tag
					Runspace = [runspace]::DefaultRunspace.InstanceId
					Target = $Target
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
				[string]$CommandName,
				[string]$Title = "Dummy Test"
			)

			[PSCustomObject]@{
				PSTypeName = 'ZeroTrustAssessment.Test'
				TestID = $TestId
				Command = $CommandName
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
		$script:__ZtSession = @{
			ProgressState = [PSCustomObject]@{
				Value = @{}
			}
		}
		$script:__ztCurrentTest = $null

		$script:logsPath = Join-Path $env:TEMP "zt-invokeztparallel-tests-$(Get-Random)"
		$null = New-Item -Path $script:logsPath -ItemType Directory -Force

		$script:testResult = [PSCustomObject]@{
			PSTypeName = 'ZeroTrustAssessment.TestStatistics'
			TestID = '91001'
			DisplayName = 'Parallel Test'
			Start = $null
			End = $null
			Duration = $null
			Attempts = 1
			Success = $true
			Error = $null
			Messages = $null
			TimedOut = $false
			Output = $null
		}

		# Requested setup: clear all messages, write two messages, retrieve for -PreviousMessages.
		Clear-PSFMessage
		Write-PSFMessage -Level Verbose -Message 'pre-message-1'
		Write-PSFMessage -Level Verbose -Message 'pre-message-2'
		$script:previousMessages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)

		Mock Get-ZtTestResult {
			$script:testResult
		}
		Mock Update-ZtProgressState {}
		Mock Write-ZtTestProgress {}
		Mock Write-ZtTestFinish { param($Result) $Result }
	}

	AfterEach {
		if ($script:logsPath -and (Test-Path $script:logsPath)) {
			Remove-Item -Path $script:logsPath -Recurse -Force -ErrorAction SilentlyContinue
		}
	}

	AfterAll {
		Clear-PSFMessage
		$gs = [PSFScope]::Global()
		$gs.EnableFunctions()
		$null = $gs.Functions.Remove("Test-Assessment.X91001")
		$null = $gs.Functions.Remove("Test-Assessment.X91002")
		$null = $gs.Functions.Remove("Test-Assessment.X91003")
	}

	Context "Successful execution" {
		It "Runs the test command, writes started progress/log stub, updates state, and forwards expected inputs to Write-ZtTestFinish" {
			$testItem = New-DummyZtTest -TestId '91001' -CommandName 'Test-Assessment.X91001' -Title 'Parallel Test'
			$script:testResult.TestID = $testItem.TestID
			$script:testResult.DisplayName = $testItem.Title

			function global:Test-Assessment.X91001 {
				[CmdletBinding()]
				param(
					$Database
				)
				'command-ok'
			}
			Mock 'Test-Assessment.X91001' {
				param($Database)
				'command-ok'
			}

			$result = Invoke-ZtTestParallel -Test $testItem -Database $database -LogsPath $script:logsPath -PreviousMessages $script:previousMessages

			$result | Should -Be $script:testResult
			$script:testResult.Output | Should -Be 'command-ok'
			$script:testResult.Start | Should -Not -BeNullOrEmpty
			$script:testResult.End | Should -Not -BeNullOrEmpty
			$script:testResult.Duration | Should -Not -BeNullOrEmpty

			$runspaceId = [runspace]::DefaultRunspace.InstanceId.ToString()
			$script:__ZtSession.ProgressState.Value["rs_$runspaceId"] | Should -Be $testItem.TestID
			$script:__ztCurrentTest | Should -BeNullOrEmpty

			$stubFile = Join-Path $script:logsPath "2-Tests/$($testItem.TestID).md"
			(Test-Path $stubFile) | Should -BeTrue

			Should -Invoke Get-ZtTestResult -Times 1 -Exactly -ParameterFilter {
				$Test -eq $testItem
			}
			Should -Invoke Update-ZtProgressState -Times 1 -Exactly -ParameterFilter {
				$WorkerId -eq $testItem.TestID -and
				$WorkerName -eq $script:testResult.DisplayName -and
				$WorkerStatus -eq 'Running' -and
				$WorkerDetail -eq 'Starting test...'
			}
			Should -Invoke 'Test-Assessment.X91001' -Times 1 -Exactly
			Should -Invoke Write-ZtTestProgress -Times 1 -Exactly -ParameterFilter {
				$TestID -eq $testItem.TestID -and
				$LogsPath -eq $script:logsPath -and
				$Action -eq 'Started'
			}
			Should -Invoke Write-ZtTestFinish -Times 1 -Exactly -ParameterFilter {
				$Result -eq $script:testResult -and
				$Test -eq $testItem -and
				$LogsPath -eq $script:logsPath -and
				$PassThru -and
				@($PreviousMessages).Count -eq @($script:previousMessages).Count
			}
		}

		It "Increments Attempts when Start is already present" {
			$testItem = New-DummyZtTest -TestId '91002' -CommandName 'Test-Assessment.X91002' -Title 'Retry Test'
			$script:testResult.TestID = $testItem.TestID
			$script:testResult.DisplayName = $testItem.Title
			$script:testResult.Start = Get-Date
			$script:testResult.Attempts = 2

			function global:Test-Assessment.X91002 {
				[CmdletBinding()]
				param()
				'command-retry'
			}
			Mock 'Test-Assessment.X91002' { 'command-retry' }

			Invoke-ZtTestParallel -Test $testItem -LogsPath $script:logsPath -PreviousMessages $script:previousMessages | Out-Null

			$script:testResult.Attempts | Should -Be 3
			Should -Invoke 'Test-Assessment.X91002' -Times 1 -Exactly
		}
	}

	Context "Database parameter handling" {
		It "Does not pass Database to command when the command has no Database parameter" {
			$testItem = New-DummyZtTest -TestId '91003' -CommandName 'Test-Assessment.X91003' -Title 'No DB Param Test'
			$script:testResult.TestID = $testItem.TestID
			$script:testResult.DisplayName = $testItem.Title
			$databaseObj = [DuckDB.NET.Data.DuckDBConnection]::new()

			function global:Test-Assessment.X91003 {
				[CmdletBinding()]
				param()
				'command-no-db'
			}
			Mock 'Test-Assessment.X91003' {
				param($Database)
				if ($PSBoundParameters.ContainsKey('Database')) {
					throw 'Database parameter should not have been bound'
				}
				'command-no-db'
			}

			Invoke-ZtTestParallel -Test $testItem -Database $databaseObj -PreviousMessages $script:previousMessages | Out-Null

			Should -Invoke 'Test-Assessment.X91003' -Times 1 -Exactly -ParameterFilter {
				$null -eq $Database
			}
			Should -Invoke Write-ZtTestProgress -Times 0 -Exactly
		}
	}

	Context "Command resolution failures" {
		It "Throws when test command cannot be resolved and does not call Write-ZtTestFinish" {
			$testItem = New-DummyZtTest -TestId '91004' -CommandName 'Test-Assessment.DoesNotExist' -Title 'Missing Command Test'
			$script:testResult.TestID = $testItem.TestID
			$script:testResult.DisplayName = $testItem.Title

			Mock Get-Command { $null } -ParameterFilter {
				$Name -eq $testItem.Command
			}

			{ Invoke-ZtTestParallel -Test $testItem -PreviousMessages $script:previousMessages } | Should -Throw "*not found*"

			Should -Invoke Get-Command -Times 1 -Exactly -ParameterFilter {
				$Name -eq $testItem.Command
			}
			Should -Invoke Update-ZtProgressState -Times 1 -Exactly -ParameterFilter {
				$WorkerId -eq $testItem.TestID -and
				$WorkerName -eq $script:testResult.DisplayName -and
				$WorkerStatus -eq 'Running'
			}
			Should -Invoke Write-ZtTestFinish -Times 0 -Exactly

			$messages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
			($messages.Message | Where-Object { $_ -like "*not found*" }).Count | Should -BeGreaterThan 0
		}
	}
}
