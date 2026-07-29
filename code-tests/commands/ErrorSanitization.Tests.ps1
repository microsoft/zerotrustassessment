Describe "Error sanitization" {
	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		. (Join-Path $srcRoot "private/core/Protect-ZtReportText.ps1")
		. (Join-Path $srcRoot "private/core/Get-ZtHttpStatusCode.ps1")
		. (Join-Path $srcRoot "private/core/Get-ZtTestStatus.ps1")
		. (Join-Path $srcRoot "private/tests/Get-ZtSafeErrorMessage.ps1")
		. (Join-Path $srcRoot "private/tests/New-ZtSafeErrorRecord.ps1")
		. (Join-Path $srcRoot "private/tests/Format-ZtTestErrorDetail.ps1")
		. (Join-Path $srcRoot "private/tests/Write-ZtTestError.ps1")
		. (Join-Path $srcRoot "private/tests/Write-ZtTestLog.ps1")
		. (Join-Path $srcRoot "private/core/Add-ZtTestResultDetail.ps1")

		function New-CanaryErrorRecord {
			$script:canaryToken = 'eyJhbGciOiJub25lIn0.eyJhcHBpZCI6InJlZGFjdGlvbi10ZXN0In0.signature'
			$request = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get, "https://graph.microsoft.com/beta/example?access_token=$script:canaryToken")
			$request.Headers.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', $script:canaryToken)
			$exception = [System.Exception]::new(@"
Exception calling ""InvokeGlobal"" with ""1"" argument(s): ""GET https://graph.microsoft.com/beta/example?access_token=$script:canaryToken
HTTP/1.1 401 Unauthorized
request-id: 11111111-1111-1111-1111-111111111111
client-request-id: 22222222-2222-2222-2222-222222222222
Authorization: Bearer $script:canaryToken
Cookie: session=example-cookie
{"error":{"code":"UnknownError","message":"example response body"}}
"@)

			return [System.Management.Automation.ErrorRecord]::new(
				$exception,
				'GraphRequestFailed',
				[System.Management.Automation.ErrorCategory]::PermissionDenied,
				$request
			)
		}
	}

	BeforeEach {
		$script:__ZtSession = @{
			TestResultDetail = [PSCustomObject]@{ Value = @{} }
		}
		$script:loggedErrorRecord = $null
		$script:addedResult = $null

		function Write-PSFMessage {
			param($Level, $Message, $StringValues, $Target, $ErrorRecord, $Tag)
			$script:loggedErrorRecord = $ErrorRecord
		}

		function Update-ZtProgressState {}
		function Write-ZtProgress {}

		function Get-ZtTest {
			param([switch] $Current, $Tests)
			return [PSCustomObject]@{
				TestId = '99999'
				Title = 'Canary test'
				Pillar = 'Identity'
				SfiPillar = $null
				MinimumLicense = $null
				CompatibleLicense = $null
			}
		}
	}

	It "formats Graph failures with safe troubleshooting details only" {
		$errorRecord = New-CanaryErrorRecord
		$test = [PSCustomObject]@{ TestID = '99999' }

		$result = Format-ZtTestErrorDetail -Test $test -ErrorRecord $errorRecord

		$result | Should -Match 'Graph request failed: GET https://graph.microsoft.com/beta/example'
		$result | Should -Match 'HTTP status: 401 Unauthorized'
		$result | Should -Match 'Graph error code: UnknownError'
		$result | Should -Match 'Request ID: 11111111-1111-1111-1111-111111111111'
		$result | Should -Match 'Client request ID: 22222222-2222-2222-2222-222222222222'
		$result | Should -Match 'HTTP Status Code: 401'
		$result | Should -Match 'GraphRequestFailed'
		$result | Should -Not -Match [regex]::Escape($script:canaryToken)
		$result | Should -Not -Match 'Authorization:|Cookie:|example response body|access_token='
	}

	It "stores and logs only a sanitized error record for parallel failures" {
		$errorRecord = New-CanaryErrorRecord
		$test = [PSCustomObject]@{ TestID = '99999'; Title = 'Canary test' }
		$executionResult = [PSCustomObject]@{ Success = $true; Error = $null; DisplayName = 'Canary test' }

		Mock Add-ZtTestResultDetail {
			param($TestId, $Title, $Status, $Result, $CustomStatus)
			$script:addedResult = $Result
		}

		Write-ZtTestError -Test $test -Result $executionResult -ErrorRecord $errorRecord

		$executionResult.Error.TargetObject | Should -BeNullOrEmpty
		$script:loggedErrorRecord.TargetObject | Should -BeNullOrEmpty
		$script:addedResult | Should -Not -Match [regex]::Escape($script:canaryToken)
		$script:addedResult | Should -Not -Match 'Authorization:'
	}

	It "redacts credential headers at the TestResult persistence boundary" {
		$unsafeResult = @(
			'Authorization: Bearer example-canary-token'
			'Cookie: session=example-cookie'
			'X-Api-Key: example-api-key'
			'https://example.test/callback?access_token=example-access-token&client_secret=example-client-secret&sig=example-signature'
		) -join "`n"

		Add-ZtTestResultDetail -TestId '99999' -Title 'Canary test' -Description 'Canary description' -Status $false -Result $unsafeResult -CustomStatus Error

		$storedResult = $script:__ZtSession.TestResultDetail.Value['99999'].TestResult
		$storedResult | Should -Not -Match 'example-canary-token|example-cookie|example-api-key|example-access-token|example-client-secret|example-signature'
		$storedResult | Should -Match '<redacted>'
	}

	It "writes only the safe error summary to optional test logs" {
		$errorRecord = New-CanaryErrorRecord
		$safeError = New-ZtSafeErrorRecord -ErrorRecord $errorRecord
		$logsPath = Join-Path $TestDrive 'logs'
		$test = [PSCustomObject]@{ TestID = '99999'; Title = 'Canary test' }
		$executionResult = [PSCustomObject]@{
			TestID = '99999'
			Test = $test
			Success = $false
			TimedOut = $false
			Duration = [TimeSpan]::Zero
			Start = Get-Date
			End = Get-Date
			Error = $safeError
			Messages = @()
		}

		Write-ZtTestLog -Result $executionResult -LogsPath $logsPath

		$logContent = Get-Content (Join-Path $logsPath '2-Tests/99999.md') -Raw
		$logContent | Should -Not -Match [regex]::Escape($script:canaryToken)
		$logContent | Should -Not -Match 'Authorization:'
	}
}
