Describe 'Invoke-ZtGraphBatchRequest API version' {
	BeforeAll {
		Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
		$srcRoot = Join-Path $PSScriptRoot '../../src/powershell'
		if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
			function global:Write-PSFMessage { param($Level, $Message, $StringValues, $ErrorRecord, $Tag) }
		}
		. (Join-Path $srcRoot 'private/graph/Invoke-ZtGraphBatchRequest.ps1')
	}

	BeforeEach {
		$script:requests = [System.Collections.Generic.List[hashtable]]::new()
		Mock Write-PSFMessage {}
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Uri, $Body)
			$script:requests.Add(@{ Uri = $Uri; Members = @($Body.requests) })
			@{ responses = @($Body.requests | ForEach-Object {
				@{ id = $_.id; status = 200; body = @{ id = $_.id } }
			}) }
		}
	}

	It 'uses the requested API version <Version> for the batch transport' -TestCases @(
		@{ Version = 'v1.0' }
		@{ Version = 'beta' }
	) {
		param($Version)
		$result = @(Invoke-ZtGraphBatchRequest -Request users, groups -ApiVersion $Version -Raw -NoPaging)

		$result | Should -HaveCount 2
		$script:requests | Should -HaveCount 1
		$script:requests[0].Uri | Should -Be "$Version/`$batch"
		$script:requests[0].Members.url | Should -Be @('users', 'groups')
	}

	It 'defaults the batch transport to v1.0 when ApiVersion is omitted' {
		$result = @(Invoke-ZtGraphBatchRequest -Request users, groups -Raw -NoPaging)

		$result | Should -HaveCount 2
		$script:requests | Should -HaveCount 1
		$script:requests[0].Uri | Should -Be 'v1.0/$batch'
	}
}
