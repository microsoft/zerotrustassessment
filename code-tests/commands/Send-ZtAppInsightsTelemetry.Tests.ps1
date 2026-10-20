Describe "Send-ZtAppInsightsTelemetry" {
	BeforeAll {
		$srcRoot = Join-Path $PSScriptRoot "../../src/powershell"

		function Write-PSFMessage {
			param($Level, $Message)
		}

		. (Join-Path $srcRoot "private/Send-ZtAppInsightsTelemetry.ps1")
	}

	BeforeEach {
		$script:request = $null
		Mock Invoke-WebRequest {
			param($Uri, $Method, $Body, $Headers, $UserAgent, $UseBasicParsing)
			$script:request = @{
				Uri = $Uri
				Method = $Method
				Body = $Body
				Headers = $Headers
				UserAgent = $UserAgent
				UseBasicParsing = $UseBasicParsing
			}
		}
	}

	It "sends privacy tags and the dedicated user agent" {
		Send-ZtAppInsightsTelemetry -EventName "ZTv2TenantId" -Properties @{ TenantId = "00000000-0000-0000-0000-000000000000" }

		$memoryStream = [System.IO.MemoryStream]::new($script:request.Body)
		$gzipStream = [System.IO.Compression.GZipStream]::new(
			$memoryStream,
			[System.IO.Compression.CompressionMode]::Decompress
		)
		$reader = [System.IO.StreamReader]::new($gzipStream)
		try {
			$payload = $reader.ReadToEnd() | ConvertFrom-Json
		}
		finally {
			$reader.Dispose()
			$gzipStream.Dispose()
			$memoryStream.Dispose()
		}

		$payload.iKey | Should -Be "a534a7fd-1eac-44b9-a128-0f40f497e7eb"
		$payload.name | Should -Be "AppEvents"
		$payload.tags."ai.location.ip" | Should -Be "0.0.0.0"
		$payload.tags."ai.device.osVersion" | Should -Be "Unknown"
		$payload.data.baseType | Should -Be "EventData"
		$payload.data.baseData.name | Should -Be "ZTv2TenantId"
		$payload.data.baseData.properties.PSObject.Properties.Name | Should -Be "TenantId"
		$payload.data.baseData.properties.TenantId | Should -Be "00000000-0000-0000-0000-000000000000"
		$script:request.UserAgent | Should -Be "ZeroTrustAssessmentTelemetry/1.0"
		$script:request.Headers["Content-Encoding"] | Should -Be "gzip"

		Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
			$Uri -eq "https://dc.services.visualstudio.com/v2/track" -and
			$Method -eq "Post" -and
			$UserAgent -eq "ZeroTrustAssessmentTelemetry/1.0" -and
			$UseBasicParsing
		}
	}
}
