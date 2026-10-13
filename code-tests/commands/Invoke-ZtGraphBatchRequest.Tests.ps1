Describe 'Invoke-ZtGraphBatchRequest contracts' {
	BeforeAll {
		Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
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

	It 'splits <Count> requests into fixed batches of at most 20' -TestCases @(
		@{ Count = 1; Expected = @(1) }
		@{ Count = 4; Expected = @(4) }
		@{ Count = 20; Expected = @(20) }
		@{ Count = 21; Expected = @(20, 1) }
		@{ Count = 41; Expected = @(20, 20, 1) }
	) {
		param($Count, $Expected)
		$result = @(Invoke-ZtGraphBatchRequest -Path 'users/{0}' -ArgumentList (1..$Count) -Raw)
		$result | Should -HaveCount $Count
		@($script:requests | ForEach-Object { $_.Members.Count }) | Should -Be $Expected
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
		$batchErrors | Should -HaveCount 2
		foreach ($batchError in $batchErrors) {
			$batchError.FullyQualifiedErrorId | Should -BeLike 'InvalidGraphBatchResponse*'
		}
		$batchErrors.TargetObject.url | Should -Be @('users', 'groups')
		$batchErrors.TargetObject.id | Should -Be @('1', '2')
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

	It 'preserves zero dependency <Dependency> as a string' -TestCases @(
		@{ Dependency = 0 }
		@{ Dependency = '0' }
		@{ Dependency = @(0) }
	) {
		param($Dependency)
		Invoke-ZtGraphBatchRequest -Request @(@{ id = 0; url = 'users' }, @{ id = 'dependent'; url = 'groups'; dependsOn = $Dependency }) -Raw | Out-Null
		$script:requests | Should -HaveCount 1
		$script:requests[0].Members[1].dependsOn | Should -Be @('0')
		$script:requests[0].Members[1].dependsOn[0] | Should -BeOfType [string]
	}

	It 'rejects a dependency workload exceeding 20 requests before transport' {
		$dependentRequests = @(1..21 | ForEach-Object { @{ id = "$_"; url = "users/$_" } })
		$dependentRequests[-1].dependsOn = @('1')
		{ Invoke-ZtGraphBatchRequest -Request $dependentRequests -Raw } | Should -Throw '*must fit within one batch of 20 requests*'
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 0 -Exactly
	}

	It 'keeps multiple string and numeric dependency IDs in one batch' {
		Invoke-ZtGraphBatchRequest -Request @(
			@{ id = 0; url = 'users' }
			@{ id = 'custom'; url = 'groups' }
			@{ id = 'dependent'; url = 'devices'; dependsOn = @(0, 'custom') }
		) -Raw | Out-Null
		$script:requests | Should -HaveCount 1
		$script:requests[0].Members[2].dependsOn | Should -Be @('0', 'custom')
		foreach ($dependency in $script:requests[0].Members[2].dependsOn) {
			$dependency | Should -BeOfType [string]
		}
	}

	It 'rejects invalid dependency <Dependency> before transport' -TestCases @(
		@{ Dependency = 'missing' }
		@{ Dependency = 'dependent' }
		@{ Dependency = '' }
	) {
		param($Dependency)
		{ Invoke-ZtGraphBatchRequest -Request @(@{ id = 'first'; url = 'users' }, @{ id = 'dependent'; url = 'groups'; dependsOn = @($Dependency) }) -Raw } | Should -Throw '*reference other requests*'
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 0 -Exactly
	}

	It 'retries a throttled dependent without replaying its successful write prerequisite' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			$script:requests.Add(@{ Members = @($Body.requests) })
			if ($script:requests.Count -eq 1) {
				return @{ responses = @(
					@{ id = 'dependent'; status = 429; headers = @{ 'Retry-After' = '0' } }
					@{ id = 'first'; status = 201; body = @{ result = 'created' } }
				) }
			}
			@{ responses = @(@{ id = 'dependent'; status = 200; body = @{ result = 'recovered' } }) }
		}
		$result = @(Invoke-ZtGraphBatchRequest -Request @(@{ id = 'first'; url = 'users'; method = 'POST' }, @{ id = 'dependent'; url = 'groups'; dependsOn = @('FIRST') }) -Raw)
		$result.id | Should -Be @('first', 'dependent')
		$script:requests | Should -HaveCount 2
		$script:requests[1].Members.id | Should -Be @('dependent')
		$script:requests[1].Members[0].ContainsKey('dependsOn') | Should -BeFalse
	}

	It 'retries pending dependencies together when both are ready' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			$script:requests.Add(@{ Members = @($Body.requests) })
			if ($script:requests.Count -eq 1) {
				return @{ responses = @($Body.requests | ForEach-Object {
					@{ id = $_.id; status = 429; headers = @{ 'Retry-After' = '0' } }
				}) }
			}
			@{ responses = @($Body.requests | ForEach-Object { @{ id = $_.id; status = 200; body = @{} } }) }
		}
		$result = @(Invoke-ZtGraphBatchRequest -Request @(@{ id = 'first'; url = 'users' }, @{ id = 'dependent'; url = 'groups'; dependsOn = @('first') }) -Raw)
		$result | Should -HaveCount 2
		$script:requests | Should -HaveCount 2
		$script:requests[1].Members.id | Should -Be @('first', 'dependent')
		$script:requests[1].Members[1].dependsOn | Should -Be @('first')
	}

	It 'rejects retry selection that separates pending dependencies' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			$script:requests.Add(@{ Members = @($Body.requests) })
			@{ responses = @(
				@{ id = 'first'; status = 429; headers = @{ 'Retry-After' = '60' } }
				@{ id = 'dependent'; status = 429; headers = @{ 'Retry-After' = '0' } }
			) }
		}
		{ Invoke-ZtGraphBatchRequest -Request @(@{ id = 'first'; url = 'users' }, @{ id = 'dependent'; url = 'groups'; dependsOn = @('first') }) -Raw } | Should -Throw '*cannot be submitted separately*'
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 1 -Exactly
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

	It 'retries an inner transient <Status> without replaying completed siblings' -TestCases @(
		@{ Status = 500 }, @{ Status = 502 }, @{ Status = 503 }, @{ Status = 504 }
	) {
		param($Status)
		$script:clock = [datetime]::UtcNow
		Mock Get-Date { $script:clock }
		Mock Start-Sleep { param($Seconds) $script:clock = $script:clock.AddSeconds($Seconds) }
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			$script:requests.Add(@{ Members = @($Body.requests); Time = $script:clock })
			if ($script:requests.Count -eq 1) {
				return @{ responses = @(
					@{ id = 'success'; status = 200; body = @{ result = 'users' } }
					@{ id = 'terminal'; status = 403; body = @{ error = @{ code = 'Denied' } } }
					@{ id = 'retry'; status = $Status; body = @{ error = @{ code = 'Transient' } } }
				) }
			}
			@{ responses = @(@{ id = 'retry'; status = 200; body = @{ result = 'groups' } }) }
		}
		$batchErrors = @()
		$result = @(Invoke-ZtGraphBatchRequest -Request @(
			@{ id = 'success'; url = 'users' }
			@{ id = 'terminal'; url = 'devices' }
			@{ id = 'retry'; url = 'groups' }
		) -Raw -ErrorVariable batchErrors)
		$result.id | Should -Be @('success', 'terminal', 'retry')
		$result.status | Should -Be @(200, 403, 200)
		$batchErrors | Should -HaveCount 0
		$script:requests | Should -HaveCount 2
		$script:requests[1].Members.id | Should -Be @('retry')
		($script:requests[1].Time - $script:requests[0].Time).TotalSeconds | Should -Be 3
	}

	Context 'Transient member retry limits' {
		BeforeEach {
			$script:clock = [datetime]::UtcNow
			Mock Get-Date { $script:clock }
			Mock Start-Sleep { param($Seconds) $script:clock = $script:clock.AddSeconds($Seconds) }
		}

		It 'exhausts status <Status> after six attempts in <Mode> mode' -ForEach @(
			foreach ($status in 500, 502, 503, 504) {
				foreach ($mode in 'Raw', 'Matched', 'Plain') {
					@{ Status = $status; Mode = $mode }
				}
			}
		) {
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				$script:requests.Add(@{ Members = @($Body.requests); Time = $script:clock })
				@{ responses = @($Body.requests | ForEach-Object {
					@{ id = $_.id; status = $Status; body = @{ error = @{ code = 'Transient'; message = 'Unavailable' } } }
				}) }
			}
			$parameters = @{ Request = @(@{ id = 'retry'; url = 'users'; metadata = 'original' }) }
			if ($Mode -ne 'Plain') { $parameters[$Mode] = $true }
			$result = @(Invoke-ZtGraphBatchRequest @parameters)
			$script:requests | Should -HaveCount 6
			$delays = @(1..5 | ForEach-Object { ($script:requests[$_].Time - $script:requests[$_ - 1].Time).TotalSeconds })
			$delays | Should -Be @(3, 6, 12, 24, 48)
			if ($Mode -eq 'Plain') { $result | Should -HaveCount 0 }
			else {
				$result | Should -HaveCount 1
				$result[0].Status | Should -Be $Status
				if ($Mode -eq 'Matched') {
					$result[0].Success | Should -BeFalse
					$result[0].Argument.metadata | Should -Be 'original'
					$result[0].Result.body.error.code | Should -Be 'Transient'
				}
				else { $result[0].body.error.code | Should -Be 'Transient' }
			}
			Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter {
				$Level -eq 'Warning' -and $Message -like 'Transient member retries exhausted*'
			}
		}

		It 'uses delay <Delay> for Retry-After <Header> in <Representation> output' -TestCases @(
			@{ Header = $null; Delay = 3; Representation = 'Hashtable' }
			@{ Header = 'invalid'; Delay = 3; Representation = 'Hashtable' }
			@{ Header = '-1'; Delay = 3; Representation = 'Hashtable' }
			@{ Header = '1.5'; Delay = 3; Representation = 'Hashtable' }
			@{ Header = '0'; Delay = 3; Representation = 'Hashtable' }
			@{ Header = '1'; Delay = 3; Representation = 'Hashtable' }
			@{ Header = '8'; Delay = 8; Representation = 'Hashtable' }
			@{ Header = 'future'; Delay = 120; Representation = 'Hashtable' }
			@{ Header = 'future'; Delay = 120; Representation = 'PSObject' }
			@{ Header = 'past'; Delay = 3; Representation = 'PSObject' }
		) {
			param($Header, $Delay, $Representation)
			$script:clock = [datetime]::SpecifyKind([datetime]'2026-10-13T12:00:00', [DateTimeKind]::Utc)
			$script:retryHeader = switch ($Header) {
				'future' { $script:clock.AddSeconds(120).ToString('r', [Globalization.CultureInfo]::InvariantCulture) }
				'past' { $script:clock.AddSeconds(-120).ToString('r', [Globalization.CultureInfo]::InvariantCulture) }
				default { $Header }
			}
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body, $OutputType)
				$script:requests.Add(@{ Members = @($Body.requests); Time = $script:clock })
				$status = if ($script:requests.Count -eq 1) { 503 } else { 200 }
				$envelope = @{ responses = @(@{ id = $Body.requests[0].id; status = $status; headers = @{ 'retry-after' = $script:retryHeader }; body = @{ result = 'recovered' } }) }
				if ($OutputType -eq 'Hashtable') { return $envelope }
				$envelope | ConvertTo-Json -Depth 10 | ConvertFrom-Json
			}
			$result = @(Invoke-ZtGraphBatchRequest -Request users -Raw -OutputType $Representation)
			$result.status | Should -Be @(200)
			$script:requests | Should -HaveCount 2
			($script:requests[1].Time - $script:requests[0].Time).TotalSeconds | Should -Be $Delay
		}

		It 'keeps exponential fallback independent of an earlier longer header' {
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				$script:requests.Add(@{ Time = $script:clock })
				$status = if ($script:requests.Count -lt 3) { 502 } else { 200 }
				$headers = if ($script:requests.Count -eq 1) { @{ 'Retry-After' = '20' } } else { @{} }
				@{ responses = @(@{ id = $Body.requests[0].id; status = $status; headers = $headers }) }
			}
			Invoke-ZtGraphBatchRequest -Request users -Raw | Out-Null
			$script:requests | Should -HaveCount 3
			($script:requests[1].Time - $script:requests[0].Time).TotalSeconds | Should -Be 20
			($script:requests[2].Time - $script:requests[1].Time).TotalSeconds | Should -Be 6
		}

		It 'does not retry status <Status> for write method <Method>' -ForEach @(
			foreach ($status in 500, 502, 503, 504) {
				foreach ($method in 'POST', 'PATCH', 'PUT', 'DELETE') {
					@{ Status = $status; Method = $method }
				}
			}
		) {
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				@{ responses = @(@{ id = $Body.requests[0].id; status = $Status; headers = @{ 'Retry-After' = '60' } }) }
			}
			$result = @(Invoke-ZtGraphBatchRequest -Request @(@{ url = 'users'; method = $Method }) -Raw)
			$result.status | Should -Be @($Status)
			Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 1 -Exactly
			Should -Invoke Start-Sleep -Times 0 -Exactly
		}

		It 'retries HEAD status <Status>' -TestCases @(
			@{ Status = 500 }, @{ Status = 502 }, @{ Status = 503 }, @{ Status = 504 }
		) {
			param($Status)
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				$script:requests.Add(@{ Members = @($Body.requests) })
				$status = if ($script:requests.Count -eq 1) { $Status } else { 200 }
				@{ responses = @(@{ id = $Body.requests[0].id; status = $status }) }
			}
			$result = @(Invoke-ZtGraphBatchRequest -Request @(@{ url = 'users'; method = 'HEAD' }) -Raw)
			$result.status | Should -Be @(200)
			$script:requests | Should -HaveCount 2
			$script:requests[1].Members.method | Should -Be @('HEAD')
		}

		It 'retains the final response when Timeout <Seconds> prevents a retry' -TestCases @(
			@{ Seconds = 0; Header = $null }
			@{ Seconds = 3; Header = $null }
			@{ Seconds = 60; Header = '600' }
			@{ Seconds = 60; Header = 'Fri, 31 Dec 9999 23:59:59 GMT' }
		) {
			param($Seconds, $Header)
			$script:timeoutHeader = $Header
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				@{ responses = @(@{ id = $Body.requests[0].id; status = 504; headers = @{ 'Retry-After' = $script:timeoutHeader }; body = @{ error = @{ code = 'TimedOut' } } }) }
			}
			$result = @(Invoke-ZtGraphBatchRequest -Request users -Raw -Timeout ([timespan]::FromSeconds($Seconds)))
			$result.status | Should -Be @(504)
			$result.body.error.code | Should -Be @('TimedOut')
			Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 1 -Exactly
			Should -Invoke Start-Sleep -Times 0 -Exactly
		}

		It 'preserves queued <Status> timeout outcomes after a slow consumer in <Mode> mode at <Elapsed> seconds' -ForEach @(
			foreach ($status in 500, 502, 503, 504) {
				foreach ($mode in 'Raw', 'Matched', 'Plain') {
					foreach ($elapsed in 5, 10) {
						@{ Status = $status; Mode = $mode; Elapsed = $elapsed }
					}
				}
			}
		) {
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				$script:requests.Add(@{ Members = @($Body.requests) })
				if ($script:requests.Count -gt 1) { throw 'Expired member must not be resent' }
				@{ responses = @(
					@{ id = 'retry'; status = $Status; body = @{ error = @{ code = 'Unavailable'; message = 'Transient failure' } } }
					@{ id = 'success'; status = 200; body = @{ id = 'user' } }
				) }
			}
			$parameters = @{
				Request = @(@{ id = 'retry'; url = 'users'; metadata = 'original' }, @{ id = 'success'; url = 'groups' })
				Timeout = [timespan]::FromSeconds(5)
			}
			if ($Mode -ne 'Plain') { $parameters[$Mode] = $true }
			$timeoutErrors = @()
			$result = @(Invoke-ZtGraphBatchRequest @parameters -ErrorAction SilentlyContinue -ErrorVariable timeoutErrors | ForEach-Object {
				$script:clock = $script:clock.AddSeconds($Elapsed)
				$_
			})
			$script:requests | Should -HaveCount 1
			Should -Invoke Start-Sleep -Times 0 -Exactly
			if ($Mode -eq 'Plain') {
				$result | Should -HaveCount 1
				$result[0].id | Should -Be 'user'
				$timeoutErrors | Should -HaveCount 1
				$timeoutErrors[0].FullyQualifiedErrorId | Should -BeLike 'TransientRetriesExhausted*'
				$timeoutErrors[0].TargetObject.url | Should -Be 'users'
				$timeoutErrors[0].Exception.Message | Should -BeLike "*status $Status*"
			}
			else {
				$result | Should -HaveCount 2
				$result[0].Id | Should -Be 'success'
				$result[1].Id | Should -Be 'retry'
				$result[1].Status | Should -Be $Status
				$timeoutErrors | Should -HaveCount 0
				if ($Mode -eq 'Matched') {
					$result[1].Success | Should -BeFalse
					$result[1].Argument.metadata | Should -Be 'original'
					$result[1].Result.body.error.code | Should -Be 'Unavailable'
				}
				else { $result[1].body.error.code | Should -Be 'Unavailable' }
			}
		}

		It 'rechecks ready members after a slow consumer handles an expired result' {
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				$script:requests.Add(@{ Members = @($Body.requests) })
				if ($script:requests.Count -gt 2) { throw 'Expired ready member must not be resent' }
				@{ responses = @($Body.requests | ForEach-Object {
					$status = if ($_.id -in '1', '21') { 503 } else { 200 }
					@{ id = $_.id; status = $status; body = @{ id = $_.id } }
				}) }
			}
			$result = @(Invoke-ZtGraphBatchRequest -Path 'users/{0}' -ArgumentList (1..22) -Raw -Timeout ([timespan]::FromSeconds(10)) | ForEach-Object {
				if ($_.id -eq '20') { $script:clock = $script:clock.AddSeconds(3) }
				if ($_.id -eq '22') { $script:clock = $script:clock.AddSeconds(8) }
				if ($_.id -eq '1') { $script:clock = $script:clock.AddSeconds(10) }
				$_
			})
			$script:requests | Should -HaveCount 2
			$result | Should -HaveCount 22
			@($result | Where-Object status -eq 503).id | Should -Be @('1', '21')
			@($result | Where-Object status -eq 200) | Should -HaveCount 20
		}

		It 'retains the most recent queued response in <Mode> mode' -TestCases @(
			@{ Mode = 'Raw' }, @{ Mode = 'Matched' }
		) {
			param($Mode)
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				$script:requests.Add(@{ Members = @($Body.requests) })
				if ($script:requests.Count -eq 1) {
					return @{ responses = @($Body.requests | ForEach-Object {
						@{ id = $_.id; status = 500; body = @{ error = @{ code = 'FirstFailure' } } }
					}) }
				}
				if ($script:requests.Count -gt 2) { throw 'Expired member must not be resent' }
				@{ responses = @(
					@{ id = 'retry'; status = 503; body = @{ error = @{ code = 'LatestFailure' } } }
					@{ id = 'success'; status = 200; body = @{ id = 'user' } }
				) }
			}
			$parameters = @{
				Request = @(@{ id = 'retry'; url = 'users' }, @{ id = 'success'; url = 'groups' })
				Timeout = [timespan]::FromSeconds(10)
			}
			$parameters[$Mode] = $true
			$result = @(Invoke-ZtGraphBatchRequest @parameters | ForEach-Object {
				$script:clock = $script:clock.AddSeconds(10)
				$_
			})
			$script:requests | Should -HaveCount 2
			$result | Should -HaveCount 2
			$result[1].Status | Should -Be 503
			$finalResponse = if ($Mode -eq 'Matched') { $result[1].Result } else { $result[1] }
			$finalResponse.body.error.code | Should -Be 'LatestFailure'
		}

		It 'keeps throttling expiry classification after a 5xx retry becomes a 429' {
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				$script:requests.Add(@{ Members = @($Body.requests) })
				$status = if ($script:requests.Count -eq 1) { 503 } else { 429 }
				$headers = if ($status -eq 429) { @{ 'Retry-After' = '600' } } else { @{} }
				@{ responses = @(@{ id = $Body.requests[0].id; status = $status; headers = $headers }) }
			}
			$throttleErrors = @()
			$result = @(Invoke-ZtGraphBatchRequest -Request users -Raw -Timeout ([timespan]::FromSeconds(5)) -ErrorAction SilentlyContinue -ErrorVariable throttleErrors)
			$result | Should -HaveCount 0
			$script:requests | Should -HaveCount 2
			$throttleErrors | Should -HaveCount 1
			$throttleErrors[0].FullyQualifiedErrorId | Should -BeLike 'ThrottlingRetriesExhausted*'
		}

		It 'terminates plain queued-timeout errors with ErrorAction Stop' {
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				$script:requests.Add(@{ Members = @($Body.requests) })
				@{ responses = @(
					@{ id = 'retry'; status = 502; body = @{ error = @{ code = 'Unavailable' } } }
					@{ id = 'success'; status = 200; body = @{ id = 'user' } }
				) }
			}
			$emitted = [System.Collections.Generic.List[object]]::new()
			{
				Invoke-ZtGraphBatchRequest -Request @(@{ id = 'retry'; url = 'users' }, @{ id = 'success'; url = 'groups' }) -Timeout ([timespan]::FromSeconds(5)) -ErrorAction Stop |
					ForEach-Object { $emitted.Add($_); $script:clock = $script:clock.AddSeconds(10) }
			} | Should -Throw '*Retries for transient member failures exceeded*status 502*'
			$emitted | Should -HaveCount 1
			$emitted[0].id | Should -Be 'user'
			$script:requests | Should -HaveCount 1
		}

		It 'resets the retry budget on successful paging for path-generated tasks' {
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				$script:requests.Add(@{ Url = $Body.requests[0].url })
				$status = if ($script:requests.Count -in 6, 12) { 200 } else { 503 }
				$responseBody = @{ value = @(@{ id = "page$($script:requests.Count)" }) }
				if ($script:requests.Count -eq 6) { $responseBody['@odata.nextLink'] = 'https://graph.microsoft.com/v1.0/users/user-1?page=2' }
				@{ responses = @(@{ id = $Body.requests[0].id; status = $status; body = $responseBody }) }
			}
			$result = @(Invoke-ZtGraphBatchRequest -Path 'users/{0}' -ArgumentList 'user-1' -Matched)
			$script:requests | Should -HaveCount 12
			@($script:requests | Select-Object -First 6 -ExpandProperty Url | Select-Object -Unique) | Should -Be @('users/user-1')
			@($script:requests | Select-Object -Last 6 -ExpandProperty Url | Select-Object -Unique) | Should -Be @('users/user-1?page=2')
			$result | Should -HaveCount 1
			$result[0].Success | Should -BeTrue
			$result[0].Argument | Should -Be 'user-1'
			$result[0].Result.id | Should -Be @('page6', 'page12')
		}

		It 'does not retry a terminal member status <Status>' -TestCases @(
			@{ Status = 501 }, @{ Status = 505 }, @{ Status = 507 }, @{ Status = 599 }
		) {
			param($Status)
			Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
				param($Body)
				@{ responses = @(@{ id = $Body.requests[0].id; status = $Status; headers = @{ 'Retry-After' = '60' } }) }
			}
			$result = @(Invoke-ZtGraphBatchRequest -Request users -Raw)
			$result.status | Should -Be @($Status)
			Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 1 -Exactly
			Should -Invoke Start-Sleep -Times 0 -Exactly
		}
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
		$batchErrors = @()
		$result = @(Invoke-ZtGraphBatchRequest -Request users, groups -Raw -ErrorAction SilentlyContinue -ErrorVariable batchErrors)
		$result | Should -HaveCount 2
		$batchErrors | Should -HaveCount 0
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

Describe 'Invoke-ZtGraphBatchRequest API version' {
	BeforeAll {
		Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
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
