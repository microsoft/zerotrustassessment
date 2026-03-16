Describe "Invoke-ZtRetry" {
	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		# Mock external module dependencies
		if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
			function global:Write-PSFMessage {
				param($Level, $Message, $StringValues, $ErrorRecord, $Tag)
			}
		}

		# Load the SUT and its dependencies
		. (Join-Path $srcRoot "private/core/Get-ZtHttpStatusCode.ps1")
		. (Join-Path $srcRoot "private/core/Test-ZtRetryableError.ps1")
		. (Join-Path $srcRoot "private/core/Invoke-ZtRetry.ps1")
	}

	BeforeEach {
		Mock Write-PSFMessage {}
		Mock Start-Sleep {}
	}

	Context "Core Retry Logic" {
		It "Should return result immediately when scriptblock succeeds on first attempt" {
			$result = Invoke-ZtRetry -ScriptBlock { "success" }

			$result | Should -Be "success"
			Should -Invoke Start-Sleep -Times 0 -Exactly
			Should -Invoke Write-PSFMessage -Times 0 -Exactly
		}

		It "Should return the correct result type (hashtable)" {
			$result = Invoke-ZtRetry -ScriptBlock { @{ key = "value"; count = 42 } }

			$result | Should -BeOfType [hashtable]
			$result.key | Should -Be "value"
			$result.count | Should -Be 42
		}

		It "Should retry and succeed after transient failures" {
			$script:callCount = 0
			$result = Invoke-ZtRetry -RetryCount 5 -RetryDelay 1 -ScriptBlock {
				$script:callCount++
				if ($script:callCount -le 2) {
					throw "Response status code does not indicate success: 500 (Internal Server Error)."
				}
				"recovered"
			}

			$result | Should -Be "recovered"
			$script:callCount | Should -Be 3
			Should -Invoke Start-Sleep -Times 2 -Exactly
		}

		It "Should throw after exhausting all retry attempts" {
			$script:callCount = 0
			{
				Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
					$script:callCount++
					throw "Response status code does not indicate success: 500 (Internal Server Error)."
				}
			} | Should -Throw "*500*"

			# 1 initial + 3 retries = 4 total attempts (attempt > RetryCount on the 4th catch)
			$script:callCount | Should -Be 4
			Should -Invoke Start-Sleep -Times 3 -Exactly
		}

		It "Should use exponential backoff for retry delays" {
			$script:delays = @()
			Mock Start-Sleep { $script:delays += $Seconds }

			$script:callCount = 0
			{
				Invoke-ZtRetry -RetryCount 5 -RetryDelay 3 -ScriptBlock {
					$script:callCount++
					throw "Response status code does not indicate success: 500 (Internal Server Error)."
				}
			} | Should -Throw

			# Delays should be: 3, 6, 12, 24, 48 (doubling each time)
			$script:delays | Should -HaveCount 5
			$script:delays[0] | Should -Be 3
			$script:delays[1] | Should -Be 6
			$script:delays[2] | Should -Be 12
			$script:delays[3] | Should -Be 24
			$script:delays[4] | Should -Be 48
		}

		It "Should respect custom RetryCount parameter" {
			$script:callCount = 0
			{
				Invoke-ZtRetry -RetryCount 2 -RetryDelay 1 -ScriptBlock {
					$script:callCount++
					throw "Response status code does not indicate success: 500 (Internal Server Error)."
				}
			} | Should -Throw

			# 1 initial + 2 retries = 3 total attempts
			$script:callCount | Should -Be 3
			Should -Invoke Start-Sleep -Times 2 -Exactly
		}

		It "Should respect custom RetryDelay parameter" {
			$script:delays = @()
			Mock Start-Sleep { $script:delays += $Seconds }

			$script:callCount = 0
			{
				Invoke-ZtRetry -RetryCount 3 -RetryDelay 5 -ScriptBlock {
					$script:callCount++
					throw "Response status code does not indicate success: 500 (Internal Server Error)."
				}
			} | Should -Throw

			# Starting at 5, doubling: 5, 10, 20
			$script:delays[0] | Should -Be 5
			$script:delays[1] | Should -Be 10
			$script:delays[2] | Should -Be 20
		}

		It "Should invoke RetryHandler on each failure" {
			$script:handlerCalls = @()
			$handler = { param($err) $script:handlerCalls += $err.Exception.Message }

			$script:callCount = 0
			{
				Invoke-ZtRetry -RetryCount 2 -RetryDelay 1 -RetryHandler $handler -ScriptBlock {
					$script:callCount++
					throw "Response status code does not indicate success: 500 (Internal Server Error)."
				}
			} | Should -Throw

			$script:handlerCalls | Should -HaveCount 2
			$script:handlerCalls[0] | Should -Match "500"
		}

		It "Should log warning with Retry tag on each retryable failure" {
			$script:callCount = 0
			{
				Invoke-ZtRetry -RetryCount 2 -RetryDelay 1 -ScriptBlock {
					$script:callCount++
					throw "Response status code does not indicate success: 500 (Internal Server Error)."
				}
			} | Should -Throw

			# 2 retries produce "Retrying in" warnings
			Should -Invoke Write-PSFMessage -Times 2 -Exactly -ParameterFilter {
				$Message -match "Retrying in"
			}
		}
	}

	Context "Error Filtering - Retryable Errors (5xx, 429, network)" {
		It "Should retry on HTTP 500 Internal Server Error" {
			$script:callCount = 0
			$result = Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
				$script:callCount++
				if ($script:callCount -eq 1) {
					throw "Response status code does not indicate success: 500 (Internal Server Error)."
				}
				"ok"
			}

			$result | Should -Be "ok"
			$script:callCount | Should -Be 2
		}

		It "Should retry on HTTP 429 Too Many Requests" {
			$script:callCount = 0
			$result = Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
				$script:callCount++
				if ($script:callCount -eq 1) {
					throw "Response status code does not indicate success: 429 (Too Many Requests)."
				}
				"ok"
			}

			$result | Should -Be "ok"
			$script:callCount | Should -Be 2
		}

		It "Should retry on HTTP 502 Bad Gateway" {
			$script:callCount = 0
			$result = Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
				$script:callCount++
				if ($script:callCount -eq 1) {
					throw "Response status code does not indicate success: 502 (Bad Gateway)."
				}
				"ok"
			}

			$result | Should -Be "ok"
			$script:callCount | Should -Be 2
		}

		It "Should retry on HTTP 503 Service Unavailable" {
			$script:callCount = 0
			$result = Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
				$script:callCount++
				if ($script:callCount -eq 1) {
					throw "Response status code does not indicate success: 503 (Service Unavailable)."
				}
				"ok"
			}

			$result | Should -Be "ok"
			$script:callCount | Should -Be 2
		}

		It "Should retry on HTTP 504 Gateway Timeout" {
			$script:callCount = 0
			$result = Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
				$script:callCount++
				if ($script:callCount -eq 1) {
					throw "Response status code does not indicate success: 504 (Gateway Timeout)."
				}
				"ok"
			}

			$result | Should -Be "ok"
			$script:callCount | Should -Be 2
		}

		It "Should retry on network-level errors (no HTTP status code)" {
			$script:callCount = 0
			$result = Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
				$script:callCount++
				if ($script:callCount -eq 1) {
					throw "The underlying connection was closed: An unexpected error occurred on a send."
				}
				"ok"
			}

			$result | Should -Be "ok"
			$script:callCount | Should -Be 2
		}

		It "Should retry on DNS resolution failures" {
			$script:callCount = 0
			$result = Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
				$script:callCount++
				if ($script:callCount -eq 1) {
					throw "No such host is known."
				}
				"ok"
			}

			$result | Should -Be "ok"
			$script:callCount | Should -Be 2
		}
	}

	Context "Error Filtering - Non-Retryable Errors (4xx)" {
		It "Should NOT retry on HTTP 401 Unauthorized" {
			$script:callCount = 0
			{
				Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
					$script:callCount++
					throw "Response status code does not indicate success: 401 (Unauthorized)."
				}
			} | Should -Throw "*401*"

			# Should fail immediately - only 1 attempt, no retries
			$script:callCount | Should -Be 1
			Should -Invoke Start-Sleep -Times 0 -Exactly
		}

		It "Should NOT retry on HTTP 403 Forbidden" {
			$script:callCount = 0
			{
				Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
					$script:callCount++
					throw "Response status code does not indicate success: 403 (Forbidden)."
				}
			} | Should -Throw "*403*"

			$script:callCount | Should -Be 1
			Should -Invoke Start-Sleep -Times 0 -Exactly
		}

		It "Should NOT retry on HTTP 404 Not Found" {
			$script:callCount = 0
			{
				Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
					$script:callCount++
					throw "Response status code does not indicate success: 404 (Not Found)."
				}
			} | Should -Throw "*404*"

			$script:callCount | Should -Be 1
			Should -Invoke Start-Sleep -Times 0 -Exactly
		}

		It "Should retry on HTTP 400 Bad Request" {
			$script:callCount = 0
			{
				Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
					$script:callCount++
					throw "Response status code does not indicate success: 400 (Bad Request)."
				}
			} | Should -Throw "*400*"

			$script:callCount | Should -Be 4
			Should -Invoke Start-Sleep -Times 3 -Exactly
		}

		It "Should log non-retryable warning before failing" {
			{
				Invoke-ZtRetry -RetryCount 3 -RetryDelay 1 -ScriptBlock {
					throw "Response status code does not indicate success: 403 (Forbidden)."
				}
			} | Should -Throw

			Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter {
				$Message -match "Non-retryable"
			}
		}
	}
}
