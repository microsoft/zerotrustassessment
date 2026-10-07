Describe "Get-ZtCurrentLicense" {
	BeforeAll {
		$srcRoot = Join-Path $PSScriptRoot "../../src/powershell"
		$hadCurrentLicense = $null -ne (Get-Variable -Name CurrentLicense -Scope Script -ErrorAction SilentlyContinue)
		$savedCurrentLicense = if ($hadCurrentLicense) { $script:CurrentLicense }

		function Write-PSFMessage {
			param($Level, $Message, $StringValues, $ErrorRecord, $Tag)
		}

		function Invoke-ZtGraphRequest {
			[CmdletBinding()]
			param([string[]] $RelativeUri)
			throw "Graph requests must be mocked."
		}

		. (Join-Path $srcRoot "private/core/Get-ZtHttpStatusCode.ps1")
		. (Join-Path $srcRoot "private/core/Test-ZtRetryableError.ps1")
		. (Join-Path $srcRoot "private/core/Invoke-ZtRetry.ps1")
		. (Join-Path $srcRoot "public/Get-ZtCurrentLicense.ps1")
	}

	BeforeEach {
		$script:CurrentLicense = @()
		Mock Write-PSFMessage {}
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequest {
			[pscustomobject]@{
				servicePlans = @(
					[pscustomobject]@{ capabilityStatus = "Enabled"; servicePlanName = "PLAN_B" }
					[pscustomobject]@{ capabilityStatus = "Deleted"; servicePlanName = "DELETED_PLAN" }
				)
			}
			[pscustomobject]@{
				servicePlans = @(
					[pscustomobject]@{ capabilityStatus = "Enabled"; servicePlanName = "PLAN_A" }
					[pscustomobject]@{ capabilityStatus = "Enabled"; servicePlanName = "PLAN_B" }
					[pscustomobject]@{ capabilityStatus = "Suspended"; servicePlanName = "PLAN_C" }
				)
			}
		}
	}

	AfterAll {
		if ($hadCurrentLicense) {
			$script:CurrentLicense = $savedCurrentLicense
		}
		else {
			Remove-Variable -Name CurrentLicense -Scope Script -ErrorAction SilentlyContinue
		}
	}

	It "retrieves sorted unique non-deleted service plans from all SKUs" {
		$result = @(Get-ZtCurrentLicense)

		$result | Should -Be @("PLAN_A", "PLAN_B", "PLAN_C")
		foreach ($plan in $result) {
			$plan | Should -BeOfType [string]
		}
		Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly
		Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly -ParameterFilter {
			$RelativeUri -eq "subscribedSkus" -and $ErrorAction -eq "Stop"
		}
		Should -Invoke Write-PSFMessage -Times 0 -Exactly
		Should -Invoke Start-Sleep -Times 0 -Exactly
	}

	It "reuses the cached licenses on subsequent calls" {
		$firstResult = @(Get-ZtCurrentLicense)
		$secondResult = @(Get-ZtCurrentLicense)

		$firstResult | Should -Be @("PLAN_A", "PLAN_B", "PLAN_C")
		$secondResult | Should -Be $firstResult
		Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly
	}

	It "replaces cached licenses when Force is specified" {
		$script:CurrentLicense = @("CACHED_PLAN")

		$result = @(Get-ZtCurrentLicense -Force)
		$cachedResult = @(Get-ZtCurrentLicense)

		$result | Should -Be @("PLAN_A", "PLAN_B", "PLAN_C")
		$cachedResult | Should -Be $result
		Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly
	}

	It "returns no licenses without a warning when every plan is deleted" {
		Mock Invoke-ZtGraphRequest {
			[pscustomobject]@{
				servicePlans = @(
					[pscustomobject]@{ capabilityStatus = "Deleted"; servicePlanName = "DELETED_PLAN" }
				)
			}
		}

		$result = @(Get-ZtCurrentLicense)

		$result | Should -HaveCount 0
		Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly
		Should -Invoke Write-PSFMessage -Times 0 -Exactly
	}

	It "looks up licenses again when the cached result is empty" {
		Mock Invoke-ZtGraphRequest { [pscustomobject]@{ servicePlans = @() } }

		$firstResult = @(Get-ZtCurrentLicense)
		$secondResult = @(Get-ZtCurrentLicense)

		$firstResult | Should -HaveCount 0
		$secondResult | Should -HaveCount 0
		Should -Invoke Invoke-ZtGraphRequest -Times 2 -Exactly
		Should -Invoke Write-PSFMessage -Times 0 -Exactly
	}

	It "calls the request helper only once and returns no licenses after <Failure>" -ForEach @(
		@{ Failure = "HTTP 500"; ErrorMessage = "Response status code does not indicate success: 500 (Internal Server Error)." }
		@{ Failure = "a status-less network error"; ErrorMessage = "No such host is known." }
		@{ Failure = "HTTP 429"; ErrorMessage = "Response status code does not indicate success: 429 (Too Many Requests)." }
		@{ Failure = "HTTP 403"; ErrorMessage = "Response status code does not indicate success: 403 (Forbidden)." }
	) {
		Mock Invoke-ZtGraphRequest { throw $ErrorMessage }

		$result = @(Get-ZtCurrentLicense)

		$result | Should -HaveCount 0
		$script:CurrentLicense | Should -HaveCount 0
		Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly
		Should -Invoke Write-PSFMessage -Times 1 -Exactly
		Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter {
			$Level -eq "Warning" -and
			$Message -like "Failed to retrieve current licenses.*" -and
			$ErrorRecord.Exception.Message -eq $ErrorMessage
		}
		Should -Invoke Start-Sleep -Times 0 -Exactly
	}

	It "clears stale cached licenses after a failed forced refresh and allows recovery" {
		$script:CurrentLicense = @("CACHED_PLAN")
		Mock Invoke-ZtGraphRequest { throw "No such host is known." }

		$failedResult = @(Get-ZtCurrentLicense -Force)

		$failedResult | Should -HaveCount 0
		$script:CurrentLicense | Should -HaveCount 0
		Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly

		Mock Invoke-ZtGraphRequest {
			[pscustomobject]@{
				servicePlans = @(
					[pscustomobject]@{ capabilityStatus = "Enabled"; servicePlanName = "RECOVERED_PLAN" }
				)
			}
		}

		$recoveredResult = @(Get-ZtCurrentLicense)
		$cachedResult = @(Get-ZtCurrentLicense)

		$recoveredResult | Should -Be @("RECOVERED_PLAN")
		$cachedResult | Should -Be $recoveredResult
		Should -Invoke Invoke-ZtGraphRequest -Times 2 -Exactly
		Should -Invoke Write-PSFMessage -Times 1 -Exactly
		Should -Invoke Start-Sleep -Times 0 -Exactly
	}
}
