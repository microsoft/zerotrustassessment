Describe 'Invoke-ZtGraphBatchRequest contracts' {
	BeforeAll {
		$srcRoot = Join-Path $PSScriptRoot '../../src/powershell'
		if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
			function global:Write-PSFMessage { param($Level, $Message, $StringValues, $ErrorRecord, $Tag) }
		}
		. (Join-Path $srcRoot 'private/core/Get-ZtHttpStatusCode.ps1')
		. (Join-Path $srcRoot 'private/core/Test-ZtRetryableError.ps1')
		. (Join-Path $srcRoot 'private/core/Invoke-ZtRetry.ps1')
		. (Join-Path $srcRoot 'private/graph/Invoke-ZtGraphBatchRequest.ps1')
	}

	BeforeEach {
		$script:requests = [System.Collections.Generic.List[object]]::new()
		Mock Write-PSFMessage {}
		Mock Start-Sleep {}
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Uri, $Body, $OutputType)
			$script:requests.Add(@{ Uri = $Uri; Members = @($Body.requests); OutputType = $OutputType })
			@{ responses = @($Body.requests | ForEach-Object {
				@{ id = $_.id; status = 200; body = @{ value = @(@{ id = $_.id }) } }
			}) }
		}
	}

	It 'uses the requested API version <Version>' -TestCases @(
		@{ Version = 'v1.0' }
		@{ Version = 'beta' }
	) {
		param($Version)
		Invoke-ZtGraphBatchRequest -Request users, groups -ApiVersion $Version -Raw -NoPaging | Out-Null
		$script:requests[0].Uri | Should -Be "$Version/`$batch"
	}

	It 'honors an explicit Graph service root <Root>' -TestCases @(
		@{ Root = 'https://graph.microsoft.us/' }
		@{ Root = 'https://graph.microsoft.us' }
	) {
		param($Root)
		Invoke-ZtGraphBatchRequest -Request users -GraphBaseUri $Root -ApiVersion beta -Raw | Out-Null
		$script:requests[0].Uri | Should -Be 'https://graph.microsoft.us/beta/$batch'
	}

	It 'rejects an invalid Graph service root <Root> before transport' -TestCases @(
		@{ Root = 'http://graph.microsoft.com/' }
		@{ Root = 'https://graph.microsoft.com/beta/' }
		@{ Root = 'https://graph.microsoft.com/?query=1' }
		@{ Root = 'https://graph.microsoft.com/#fragment' }
		@{ Root = 'https://user:password@graph.microsoft.com/' }
	) {
		param($Root)
		{ Invoke-ZtGraphBatchRequest -Request users -GraphBaseUri $Root } | Should -Throw
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 0 -Exactly
	}

	It 'splits <Count> requests into caller-sized batches of <Size>' -TestCases @(
		@{ Count = 1; Size = 1; Expected = @(1) }
		@{ Count = 4; Size = 1; Expected = @(1, 1, 1, 1) }
		@{ Count = 4; Size = 2; Expected = @(2, 2) }
		@{ Count = 20; Size = 20; Expected = @(20) }
		@{ Count = 21; Size = 20; Expected = @(20, 1) }
		@{ Count = 41; Size = 20; Expected = @(20, 20, 1) }
	) {
		param($Count, $Size, $Expected)
		$result = @(Invoke-ZtGraphBatchRequest -Path 'users/{0}' -ArgumentList (1..$Count) -BatchSize $Size -Raw)
		$result | Should -HaveCount $Count
		@($script:requests | ForEach-Object { $_.Members.Count }) | Should -Be $Expected
	}

	It 'rejects unsupported batch size <Size>' -TestCases @(@{ Size = 0 }, @{ Size = 21 }) {
		param($Size)
		{ Invoke-ZtGraphBatchRequest -Request users -BatchSize $Size } | Should -Throw
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 0 -Exactly
	}

	It 'preserves the Hashtable default and unwraps collections' {
		$result = @(Invoke-ZtGraphBatchRequest -Request users, groups)
		$result | Should -HaveCount 2
		$result[0] | Should -BeOfType [hashtable]
		$result[0].id | Should -Be '1'
		$script:requests[0].OutputType | Should -Be 'Hashtable'
	}

	It 'supports <Representation> output in <Mode> mode with NoPaging <FirstPageOnly>' -ForEach @(
		foreach ($representation in 'Hashtable', 'PSObject', 'PSCustomObject') {
			foreach ($mode in 'Plain', 'Raw', 'Matched') {
				foreach ($firstPageOnly in $true, $false) {
					@{ Representation = $representation; Mode = $mode; FirstPageOnly = $firstPageOnly }
				}
			}
		}
	) {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Uri, $Body, $OutputType)
			$script:requests.Add(@{ Uri = $Uri; Members = @($Body.requests); OutputType = $OutputType })
			$responseBody = @{ value = @(@{ id = "page$($script:requests.Count)" }) }
			if ($script:requests.Count -eq 1) {
				$responseBody['@odata.nextLink'] = 'https://graph.microsoft.com/v1.0/users?page=2'
			}
			$envelope = @{ responses = @(@{ id = $Body.requests[0].id; status = 200; body = $responseBody }) }
			if ($OutputType -eq 'Hashtable') { return $envelope }
			$envelope | ConvertTo-Json -Depth 10 | ConvertFrom-Json
		}
		$parameters = @{ Request = @(@{ url = 'users'; metadata = 'original' }); OutputType = $Representation; NoPaging = $FirstPageOnly }
		if ($Mode -ne 'Plain') { $parameters[$Mode] = $true }
		$result = @(Invoke-ZtGraphBatchRequest @parameters)
		$pageCount = if ($FirstPageOnly) { 1 } else { 2 }
		$script:requests | Should -HaveCount $pageCount
		$expectedRepresentation = if ($Representation -eq 'PSCustomObject') { 'PSObject' } else { $Representation }
		foreach ($transport in $script:requests) { $transport.OutputType | Should -Be $expectedRepresentation }
		$data = @(switch ($Mode) {
			'Raw' { $result.body.value }
			'Matched' {
				$result | Should -HaveCount 1
				$result[0].Argument.metadata | Should -Be 'original'
				$result[0].Result
			}
			default { $result }
		})
		@($data) | Should -HaveCount $pageCount
		$data[0].id | Should -Be 'page1'
		if ($Representation -eq 'Hashtable') { $data[0] | Should -BeOfType [hashtable] }
		else { $data[0] | Should -BeOfType [pscustomobject] }
	}

	It 'fails <Case> responses once without emitting partial results' -TestCases @(
		@{ Case = 'missing' }
		@{ Case = 'empty' }
		@{ Case = 'unknown' }
		@{ Case = 'duplicate' }
		@{ Case = 'invalid status' }
		@{ Case = 'missing envelope' }
	) {
		param($Case)
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			$script:requests.Add(@{ Members = @($Body.requests) })
			if ($script:requests.Count -gt 1) { throw 'Unexpected resubmission' }
			$first = @{ id = $Body.requests[0].id; status = 200; body = @{ result = 'first' } }
			$second = @{ id = $Body.requests[1].id; status = 200; body = @{ result = 'second' } }
			switch ($Case) {
				'missing' { @{ responses = @($first) } }
				'empty' { @{ responses = @() } }
				'unknown' { $second.id = 'unknown'; @{ responses = @($first, $second) } }
				'duplicate' { @{ responses = @($first, $first) } }
				'invalid status' { $second.status = 'invalid'; @{ responses = @($first, $second) } }
				'missing envelope' { @{} }
			}
		}
		$emitted = [System.Collections.Generic.List[object]]::new()
		{ Invoke-ZtGraphBatchRequest -Request users, groups -Raw -ErrorAction Stop | ForEach-Object { $emitted.Add($_) } } | Should -Throw '*Batch response is incomplete*'
		$script:requests | Should -HaveCount 1
		$emitted | Should -HaveCount 0
	}

	It 'removes an incomplete batch under nonterminating error handling' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' { @{ responses = @() } }
		$batchErrors = @()
		$result = @(Invoke-ZtGraphBatchRequest -Request users, groups -Raw -ErrorAction SilentlyContinue -ErrorVariable batchErrors)
		$result | Should -HaveCount 0
		$batchErrors | Should -HaveCount 1
		$batchErrors[0].FullyQualifiedErrorId | Should -BeLike 'InvalidGraphBatchResponse*'
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 1 -Exactly
	}

	It 'preserves zero and string IDs and avoids collisions with future explicit IDs' {
		$result = @(Invoke-ZtGraphBatchRequest -Request @('users', @{ id = '1'; url = 'groups' }, @{ id = 0; url = 'devices' }, @{ id = 'custom'; url = 'sites' }) -Raw)
		$result.id | Should -Be @('2', '1', '0', 'custom')
	}

	It 'rejects case-insensitive duplicate IDs before transport' {
		{ Invoke-ZtGraphBatchRequest -Request @(@{ id = 'custom'; url = 'users' }, @{ id = 'CUSTOM'; url = 'groups' }) } | Should -Throw '*unique*'
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 0 -Exactly
	}

	It 'retries an inner 429 without replaying successful siblings' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			$script:requests.Add(@{ Members = @($Body.requests) })
			if ($script:requests.Count -eq 1) {
				return @{ responses = @(
					@{ id = $Body.requests[0].id; status = 200; body = @{ result = 'users' } }
					@{ id = $Body.requests[1].id; status = 429; headers = @{ 'Retry-After' = '0' } }
				) }
			}
			@{ responses = @(@{ id = $Body.requests[0].id; status = 200; body = @{ result = 'groups' } }) }
		}
		$result = @(Invoke-ZtGraphBatchRequest -Request users, groups -Raw)
		$result.body.result | Should -Be @('users', 'groups')
		$script:requests | Should -HaveCount 2
		$script:requests[1].Members | Should -HaveCount 1
		$script:requests[1].Members[0].url | Should -Be 'groups'
	}

	It 'bounds throttling for Retry-After <RetryAfter>' -TestCases @(
		@{ RetryAfter = '0' }
		@{ RetryAfter = 'invalid' }
		@{ RetryAfter = $null }
		@{ RetryAfter = '-1' }
		@{ RetryAfter = '600' }
	) {
		param($RetryAfter)
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			@{ responses = @(@{ id = $Body.requests[0].id; status = 429; headers = @{ 'Retry-After' = $RetryAfter } }) }
		}
		{ Invoke-ZtGraphBatchRequest -Request users -Timeout ([timespan]::Zero) -ErrorAction Stop } | Should -Throw '*Retries for throttling exceeded*'
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 1 -Exactly
	}

	It 'retries a recoverable outer failure for read-only members' {
		$script:attempt = 0
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			$script:attempt++
			if ($script:attempt -eq 1) {
				$exception = [Exception]::new('Transient outer failure')
				$exception | Add-Member -NotePropertyName ResponseStatusCode -NotePropertyValue 502
				throw $exception
			}
			@{ responses = @($Body.requests | ForEach-Object { @{ id = $_.id; status = 200; body = @{ result = 'recovered' } } }) }
		}
		$result = @(Invoke-ZtGraphBatchRequest -Request users, groups -Raw)
		$result | Should -HaveCount 2
		$script:attempt | Should -Be 2
		Should -Invoke Start-Sleep -Times 1 -Exactly
	}

	It 'does not replay outer failures for <Method> members with status <Status>' -TestCases @(
		@{ Method = 'GET'; Status = 403 }
		@{ Method = 'POST'; Status = 502 }
		@{ Method = 'PATCH'; Status = 502 }
	) {
		param($Method, $Status)
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			$exception = [Exception]::new('Outer failure')
			$exception | Add-Member -NotePropertyName ResponseStatusCode -NotePropertyValue $Status
			throw $exception
		}
		{ Invoke-ZtGraphBatchRequest -Request @(@{ url = 'users'; method = $Method }) -ErrorAction Stop } | Should -Throw '*Outer failure*'
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 1 -Exactly
		Should -Invoke Start-Sleep -Times 0 -Exactly
	}

	It 'stops after bounded outer retries are exhausted' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			$exception = [Exception]::new('Persistent outer failure')
			$exception | Add-Member -NotePropertyName ResponseStatusCode -NotePropertyValue 502
			throw $exception
		}
		{ Invoke-ZtGraphBatchRequest -Request users -ErrorAction Stop } | Should -Throw '*Persistent outer failure*'
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 6 -Exactly
		Should -Invoke Start-Sleep -Times 5 -Exactly
	}

	It 'preserves original matched failure metadata and body errors' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			@{ responses = @(@{ id = $Body.requests[0].id; status = 403; body = @{ error = @{ code = 'Denied'; message = 'Denied' } } }) }
		}
		$batchErrors = @()
		$result = Invoke-ZtGraphBatchRequest -Request @(@{ url = 'users'; metadata = 'original' }) -Matched -ErrorAction SilentlyContinue -ErrorVariable batchErrors
		$result.Success | Should -BeFalse
		$result.Argument.metadata | Should -Be 'original'
		$result.Result.code | Should -Be 'Denied'
		$batchErrors[0].FullyQualifiedErrorId | Should -BeLike '403|Denied*'
	}
}