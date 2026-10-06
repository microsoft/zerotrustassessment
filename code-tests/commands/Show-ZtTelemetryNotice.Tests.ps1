Describe "Show-ZtTelemetryNotice" {
	BeforeAll {
		$srcRoot = Join-Path $PSScriptRoot "../../src/powershell"
		. (Join-Path $srcRoot "private/core/Show-ZtTelemetryNotice.ps1")
	}

	BeforeEach {
		$script:messages = [System.Collections.Generic.List[string]]::new()
		Mock Write-Host {
			param($Object)
			if ($null -ne $Object) {
				$script:messages.Add([string]$Object)
			}
		}
	}

	It "describes the enabled telemetry payload without an absolute collection guarantee" {
		Show-ZtTelemetryNotice -DisableTelemetry $false
		$message = $script:messages -join "`n"

		$message | Should -Match "Telemetry is enabled for this run"
		$message | Should -Match "(?s)tenant ID.*only tenant-specific custom property"
		$message | Should -Match "Standard network metadata"
		$message | Should -Match "source IP"
		$message | Should -Not -Match "This run will send ONLY|no other data will be collected"
		$message | Should -Match "private/Send-ZtAppInsightsTelemetry.ps1"
	}

	It "states that the telemetry event is not sent when disabled" {
		Show-ZtTelemetryNotice -DisableTelemetry $true
		$message = $script:messages -join "`n"

		$message | Should -Match "Telemetry is disabled for this run"
		$message | Should -Match "No assessment telemetry event will be sent"
		$message | Should -Not -Match "Telemetry is enabled for this run"
	}
}
