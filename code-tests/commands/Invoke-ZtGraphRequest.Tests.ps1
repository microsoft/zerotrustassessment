Describe 'Invoke-ZtGraphRequest POST and batch support' {
	BeforeAll {
		$srcRoot = Join-Path $PSScriptRoot '../../src/powershell'

		function global:Write-PSFMessage { param($Message, $Level, $Tag, $StringValues) }
		function global:Invoke-ZtGraphRequestCache { param($Method, $Uri, $Headers, $Body, $OutputType, $DisableCache, $OutputFilePath, $PageIndex) }
		function global:Get-ObjectProperty {
			param($InputObjects, $Property)
			$InputObjects.PSObject.Properties[$Property].Value
		}
		function global:ConvertTo-QueryString { param($InputObject) return $null }
		function global:ConvertFrom-QueryString { param($InputStrings, $AsHashtable) return @{} }
		function global:Get-MgContext { throw 'Graph context should not be resolved for validation failures.' }
		function global:Get-MgEnvironment { param($Name) throw 'Graph environment should not be resolved for validation failures.' }

		. (Join-Path $srcRoot 'public/Invoke-ZtGraphRequest.ps1')
	}

	BeforeEach {
		$script:requests = [System.Collections.Generic.List[hashtable]]::new()
		Mock Write-PSFMessage {}
		Mock Invoke-ZtGraphRequestCache {
			param($Method, $Uri, $Headers, $Body, $OutputType, $DisableCache, $OutputFilePath, $PageIndex)
			$script:requests.Add(@{
				Method = $Method
				Uri = $Uri
				Headers = $Headers
				Body = $Body
				PageIndex = $PageIndex
			})
			[pscustomobject]@{ result = 'success' }
		}
	}

	It 'forwards a valid POST body and adds the JSON content type' {
		$body = '{"Query":"DeviceProcessEvents | limit 2"}'
		$result = Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -Method POST -Body $body -GraphBaseUri 'https://graph.microsoft.com/'

		$result.result | Should -Be 'success'
		$script:requests | Should -HaveCount 1
		$script:requests[0].Method | Should -Be 'POST'
		$script:requests[0].Body | Should -Be $body
		$script:requests[0].Headers['Content-Type'] | Should -Be 'application/json'
	}

	It 'preserves a caller supplied content type for POST' {
		Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -Method POST -Body '{}' -Headers @{ 'Content-Type' = 'application/json; charset=utf-8' } -GraphBaseUri 'https://graph.microsoft.com/' | Out-Null

		$script:requests[0].Headers['Content-Type'] | Should -Be 'application/json; charset=utf-8'
	}

	It 'rejects a missing POST body before resolving Graph context' {
		{ Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -Method POST } | Should -Throw '*-Body is required*'
	}

	It 'rejects a non-object POST body before resolving Graph context' {
		{ Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -Method POST -Body '[]' } | Should -Throw '*JSON object*'
	}

	It 'rejects a body with GET before resolving Graph context' {
		{ Invoke-ZtGraphRequest -RelativeUri 'users' -Body '{}' } | Should -Throw '*only supported when -Method POST*'
	}

	It 'rejects POST-only incompatible parameters' {
		{ Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -Method POST -Body '{}' -DisableBatching } | Should -Throw '*DisableBatching*'
		{ Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -Method POST -Body '{}' -Select 'id' } | Should -Throw '*Select*'
		{ Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -Method POST -Body '{}' -Filter 'id ne null' } | Should -Throw '*Filter*'
		{ Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -Method POST -Body '{}' -Top 1 } | Should -Throw '*Top*'
	}

	It 'rejects multiple POST pipeline endpoints without issuing a request' {
		{ @('security/runHuntingQuery', 'directoryObjects/getByIds') | Invoke-ZtGraphRequest -Method POST -Body '{}' -GraphBaseUri 'https://graph.microsoft.com/' } | Should -Throw '*exactly one resolved endpoint*'
		Should -Invoke Invoke-ZtGraphRequestCache -Times 0 -Exactly
	}

	It 'uses GET without a body for a POST continuation link' {
		$script:callNumber = 0
		Mock Invoke-ZtGraphRequestCache {
			param($Method, $Uri, $Headers, $Body, $OutputType, $DisableCache, $OutputFilePath, $PageIndex)
			$script:requests.Add(@{ Method = $Method; Uri = $Uri; Body = $Body; PageIndex = $PageIndex })
			$script:callNumber++
			if ($script:callNumber -eq 1) {
				return [pscustomobject]@{ '@odata.nextLink' = 'https://graph.microsoft.com/v1.0/security/runHuntingQuery?page=2'; result = 'first' }
			}
			return [pscustomobject]@{ result = 'second' }
		}

		$result = Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -Method POST -Body '{}' -GraphBaseUri 'https://graph.microsoft.com/'

		$result.result | Should -Be @('first', 'second')
		$script:requests | Should -HaveCount 2
		$script:requests[0].Method | Should -Be 'POST'
		$script:requests[0].Body | Should -Be '{}'
		$script:requests[1].Method | Should -Be 'GET'
		$script:requests[1].Body | Should -BeNullOrEmpty
		$script:requests[1].PageIndex | Should -Be 1
	}

	It 'uses the session-resolved Graph endpoint for GET batch requests' {
		$script:__ZtSession = [pscustomobject]@{ GraphBaseUri = $null }
		Mock Get-MgContext { [pscustomobject]@{ Environment = 'Global' } }
		Mock Get-MgEnvironment { [pscustomobject]@{ GraphEndpoint = 'https://graph.microsoft.com/' } }
		Mock Invoke-ZtGraphRequestCache {
			param($Method, $Uri, $Body)
			$script:requests.Add(@{ Method = $Method; Uri = $Uri; Body = $Body })
			$batch = $Body | ConvertFrom-Json
			[pscustomobject]@{ responses = @($batch.requests | ForEach-Object { @{ id = $_.id; status = 200; body = @{ id = $_.url } } }) }
		}

		Invoke-ZtGraphRequest -RelativeUri @('users', 'groups') | Out-Null

		$script:requests | Should -HaveCount 1
		$script:requests[0].Method | Should -Be 'POST'
		([uri]$script:requests[0].Uri).AbsoluteUri | Should -Be 'https://graph.microsoft.com/v1.0/$batch'
		Should -Invoke Get-MgContext -Times 1 -Exactly
		Should -Invoke Get-MgEnvironment -Times 1 -Exactly
	}

	It 'retries only transient items and keeps matched outcomes in request order' {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache {
			param($Body)
			$script:requests.Add(@{ Body = $Body })
			if ($script:requests.Count -eq 1) {
				return @{ responses = @(
					@{ id = '2'; status = 503; headers = @{ 'Retry-After' = '12' }; body = @{ error = 'unavailable' } }
					@{ id = '1'; status = 429; headers = @{ 'Retry-After' = '7' }; body = @{ error = 'throttled' } }
					@{ id = '0'; status = 200; body = @{ id = 'first' } }
				) }
			}
			@{ responses = @(
				@{ id = '2'; status = 200; body = @{ id = 'third' } }
				@{ id = '1'; status = 200; body = @{ id = 'second' } }
			) }
		}

		$result = @(Invoke-ZtGraphRequest -RelativeUri 'users' -UniqueId 'first', 'second', 'third' -Matched -GraphBaseUri 'https://graph.microsoft.com/')

		$result.Id | Should -Be @(0, 1, 2)
		$result.Result.id | Should -Be @('first', 'second', 'third')
		$result.Attempts | Should -Be @(1, 2, 2)
		$result.Success | Should -Be @($true, $true, $true)
		(($script:requests[1].Body | ConvertFrom-Json).requests.id) | Should -Be @(1, 2)
		Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq 12 }
	}

	It 'uses fallback for retryable status <Status> and header <Header>' -ForEach @(
		@{ Status = 429; Header = $null }
		@{ Status = 503; Header = 'invalid' }
		@{ Status = 500; Header = '-1' }
		@{ Status = 502; Header = '1.5' }
		@{ Status = 504; Header = '0' }
		@{ Status = 501; Header = '1' }
		@{ Status = 599; Header = 'Wed, 01 Jan 2020 00:00:00 GMT' }
	) {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache {
			param($Body)
			$script:requests.Add(@{ Body = $Body })
			$statusCode = if ($script:requests.Count -eq 1) { $Status } else { 200 }
			@{ responses = @(@{ id = '0'; status = $statusCode; headers = @{ 'Retry-After' = $Header }; body = @{ id = 'user-1' } }) }
		}

		$result = Invoke-ZtGraphRequest -RelativeUri 'users' -UniqueId 'user-1' -Matched -GraphBaseUri 'https://graph.microsoft.com/'

		$result.Success | Should -BeTrue
		$result.Attempts | Should -Be 2
		Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq 3 }
	}

	It 'honors HTTP-date Retry-After on a 5xx response' {
		$script:retryDate = [DateTimeOffset]::UtcNow.AddMinutes(2).ToString('r', [Globalization.CultureInfo]::InvariantCulture)
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache {
			param($Body)
			$script:requests.Add(@{ Body = $Body })
			$statusCode = if ($script:requests.Count -eq 1) { 503 } else { 200 }
			@{ responses = @(@{ id = '0'; status = $statusCode; headers = [pscustomobject]@{ 'retry-after' = $script:retryDate }; body = @{ id = 'user-1' } }) }
		}

		Invoke-ZtGraphRequest -RelativeUri 'users' -Matched -GraphBaseUri 'https://graph.microsoft.com/' | Out-Null

		Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -gt 100 -and $Seconds -le 120 }
	}

	It 'keeps exponential fallback independent of a longer initial header' {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache {
			param($Body)
			$script:requests.Add(@{ Body = $Body })
			if ($script:requests.Count -le 2) {
				$headers = if ($script:requests.Count -eq 1) { @{ 'Retry-After' = '20' } } else { @{} }
				return @{ responses = @(@{ id = '0'; status = 429; headers = $headers }) }
			}
			@{ responses = @(@{ id = '0'; status = 200; body = @{ id = 'user-1' } }) }
		}

		$result = Invoke-ZtGraphRequest -RelativeUri 'users' -Matched -GraphBaseUri 'https://graph.microsoft.com/'

		$result.Attempts | Should -Be 3
		Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq 20 }
		Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq 6 }
	}

	It 'does not resend terminal status <Status> or apply its Retry-After' -ForEach @(
		@{ Status = 400 }, @{ Status = 401 }, @{ Status = 403 }, @{ Status = 404 }
		@{ Status = 408 }, @{ Status = 409 }, @{ Status = 422 }
	) {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache {
			@{ responses = @(@{ id = '0'; status = $Status; headers = @{ 'Retry-After' = '100' }; body = @{ error = @{ code = 'TerminalError' } } }) }
		}

		$result = Invoke-ZtGraphRequest -RelativeUri 'users' -Matched -GraphBaseUri 'https://graph.microsoft.com/'

		$result.StatusCode | Should -Be $Status
		$result.Success | Should -BeFalse
		$result.RetryExhausted | Should -BeFalse
		$result.Attempts | Should -Be 1
		$result.Result.error.code | Should -Be 'TerminalError'
		Should -Invoke Invoke-ZtGraphRequestCache -Times 1 -Exactly
		Should -Invoke Start-Sleep -Times 0 -Exactly
	}

	It 'retries only duplicated IDs with statuses <Statuses> in matched mode <Correlated>' -ForEach @(
		@{ Statuses = @(200, 500); Correlated = $false }
		@{ Statuses = @(500, 200); Correlated = $false }
		@{ Statuses = @(200, 403); Correlated = $false }
		@{ Statuses = @(403, 200); Correlated = $false }
		@{ Statuses = @(200, 200); Correlated = $false }
		@{ Statuses = @(200, 500, 200); Correlated = $false }
		@{ Statuses = @(200, 500); Correlated = $true }
		@{ Statuses = @(500, 200); Correlated = $true }
		@{ Statuses = @(200, 403); Correlated = $true }
		@{ Statuses = @(403, 200); Correlated = $true }
		@{ Statuses = @(200, 200); Correlated = $true }
		@{ Statuses = @(200, 500, 200); Correlated = $true }
	) {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache {
			param($Body)
			$script:requests.Add(@{ Body = $Body })
			if ($script:requests.Count -eq 1) {
				$duplicates = @($Statuses | ForEach-Object {
					@{ id = '1'; status = $_; headers = @{ 'Retry-After' = '100' }; body = @{ id = 'ambiguous' } }
				})
				return @{ responses = @(@{ id = '0'; status = 200; body = @{ id = 'first' } }) + $duplicates }
			}
			@{ responses = @(@{ id = 1; status = 200; body = @{ id = 'second' } }) }
		}

		$result = @(Invoke-ZtGraphRequest -RelativeUri 'users' -UniqueId 'first', 'second' -Matched:$Correlated -GraphBaseUri 'https://graph.microsoft.com/')

		$result | Should -HaveCount 2
		if ($Correlated) {
			$result.Id | Should -Be @(0, 1)
			$result.Result.id | Should -Be @('first', 'second')
			$result.Attempts | Should -Be @(1, 2)
			$result.Success | Should -Be @($true, $true)
			$result.RetryExhausted | Should -Be @($false, $false)
		}
		else {
			$result.id | Should -Be @('first', 'second')
		}
		$script:requests | Should -HaveCount 2
		(($script:requests[1].Body | ConvertFrom-Json).requests.id) | Should -Be 1
		Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq 3 }
	}

	It 'preserves exhaustion behavior for persistent duplicated IDs in matched mode <Correlated>' -ForEach @(
		@{ Correlated = $false }, @{ Correlated = $true }
	) {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache {
			param($Body)
			$script:requests.Add(@{ Body = $Body })
			$batch = $Body | ConvertFrom-Json
			@{ responses = @($batch.requests | ForEach-Object {
				if ($_.id -eq 0) {
					@{ id = '0'; status = 200; body = @{ id = 'first' } }
				}
				else {
					@{ id = 1; status = 500; body = @{ error = 'ambiguous' } }
					@{ id = '1'; status = 200; body = @{ id = 'ambiguous' } }
				}
			}) }
		}

		if ($Correlated) {
			$result = @(Invoke-ZtGraphRequest -RelativeUri 'users' -UniqueId 'first', 'second' -Matched -GraphBaseUri 'https://graph.microsoft.com/')
			$result | Should -HaveCount 2
			$result.Id | Should -Be @(0, 1)
			$result.Success | Should -Be @($true, $false)
			$result.RetryExhausted | Should -Be @($false, $true)
			$result.Attempts | Should -Be @(1, 6)
			$result[0].Result.id | Should -Be 'first'
			$result[1].Result | Should -BeNullOrEmpty
			$result[1].StatusCode | Should -BeNullOrEmpty
			Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter { $Level -eq 'Warning' -and $Message -like '*exhausted retries*' }
		}
		else {
			{ Invoke-ZtGraphRequest -RelativeUri 'users' -UniqueId 'first', 'second' -GraphBaseUri 'https://graph.microsoft.com/' } | Should -Throw '*after 6 attempts*'
		}
		$script:requests | Should -HaveCount 6
		foreach ($retryRequest in $script:requests | Select-Object -Skip 1) {
			(($retryRequest.Body | ConvertFrom-Json).requests.id) | Should -Be 1
		}
		Should -Invoke Start-Sleep -Times 5 -Exactly
	}

	It 'retries malformed response <Case> and reports null status on exhaustion' -ForEach @(
		@{ Case = 'missing response'; Responses = @() }
		@{ Case = 'missing status'; Responses = @(@{ id = '0'; body = @{ error = 'missing status' } }) }
		@{ Case = 'nonnumeric status'; Responses = @(@{ id = '0'; status = 'invalid' }) }
		@{ Case = 'out-of-range status'; Responses = @(@{ id = '0'; status = 600 }) }
		@{ Case = 'invalid response ID'; Responses = @(@{ id = 'unknown'; status = 200 }) }
	) {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache { @{ responses = $Responses } }

		$result = Invoke-ZtGraphRequest -RelativeUri 'users' -Matched -GraphBaseUri 'https://graph.microsoft.com/'

		$result.Success | Should -BeFalse
		$result.RetryExhausted | Should -BeTrue
		$result.StatusCode | Should -BeNullOrEmpty
		$result.Attempts | Should -Be 6
		Should -Invoke Invoke-ZtGraphRequestCache -Times 6 -Exactly
		Should -Invoke Start-Sleep -Times 5 -Exactly
	}

	It 'returns successes, terminal failures and exhausted outcomes without resending completed items' {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache {
			param($Body)
			$script:requests.Add(@{ Body = $Body })
			$batch = $Body | ConvertFrom-Json
			@{ responses = @($batch.requests | Sort-Object id -Descending | ForEach-Object {
				$statusCode = switch ($_.id) { 0 { 200 } 1 { 403 } 2 { 503 } }
				@{ id = $_.id; status = $statusCode; body = @{ id = $_.url; error = 'last error' } }
			}) }
		}

		$result = @(Invoke-ZtGraphRequest -RelativeUri 'users' -UniqueId 'first', 'second', 'third' -Matched -GraphBaseUri 'https://graph.microsoft.com/')

		$result.Id | Should -Be @(0, 1, 2)
		$result.Argument.UniqueId | Should -Be @('first', 'second', 'third')
		$result.Argument.Uri | Should -Be @('https://graph.microsoft.com/v1.0/users/first', 'https://graph.microsoft.com/v1.0/users/second', 'https://graph.microsoft.com/v1.0/users/third')
		$result.Success | Should -Be @($true, $false, $false)
		$result.RetryExhausted | Should -Be @($false, $false, $true)
		$result.StatusCode | Should -Be @(200, 403, 503)
		$result.Attempts | Should -Be @(1, 1, 6)
		$result[2].Result.error | Should -Be 'last error'
		$script:requests | Should -HaveCount 6
		foreach ($retryRequest in $script:requests | Select-Object -Skip 1) {
			(($retryRequest.Body | ConvertFrom-Json).requests.id) | Should -Be 2
		}
		Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter { $Level -eq 'Warning' -and $Message -like '*exhausted retries*' }
		foreach ($delay in @(3, 6, 12, 24, 48)) {
			Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq $delay }
		}
	}

	It 'throws on ordinary batch exhaustion after six attempts' {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache {
			param($Body)
			$script:requests.Add(@{ Body = $Body })
			$batch = $Body | ConvertFrom-Json
			@{ responses = @($batch.requests | ForEach-Object { @{ id = $_.id; status = 429 } }) }
		}

		{ Invoke-ZtGraphRequest -RelativeUri 'users', 'groups' -GraphBaseUri 'https://graph.microsoft.com/' } | Should -Throw '*after 6 attempts*'

		$script:requests | Should -HaveCount 6
		Should -Invoke Start-Sleep -Times 5 -Exactly
	}

	It 'keeps ordinary batch body output and numeric request order across chunks' {
		Mock Invoke-ZtGraphRequestCache {
			param($Body)
			$script:requests.Add(@{ Body = $Body })
			$batch = $Body | ConvertFrom-Json
			@{ responses = @($batch.requests | Sort-Object id -Descending | ForEach-Object { @{ id = [string]$_.id; status = 200; body = @{ id = $_.url } } }) }
		}
		$identifiers = @(0..22 | ForEach-Object { "user-$_" })

		$result = @(Invoke-ZtGraphRequest -RelativeUri 'users' -UniqueId $identifiers -BatchSize 12 -GraphBaseUri 'https://graph.microsoft.com/')

		$result.id | Should -Be @($identifiers | ForEach-Object { "users/$_" })
		$result | Should -HaveCount 23
		$script:requests | Should -HaveCount 2
		@(($script:requests[0].Body | ConvertFrom-Json).requests) | Should -HaveCount 12
		@(($script:requests[1].Body | ConvertFrom-Json).requests) | Should -HaveCount 11
	}

	It 'continues matched chunks after exhaustion and correlates pipeline endpoints' {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache {
			param($Body)
			$script:requests.Add(@{ Body = $Body })
			$batch = $Body | ConvertFrom-Json
			@{ responses = @($batch.requests | ForEach-Object {
				$statusCode = if ($_.id -eq 1) { 503 } else { 200 }
				@{ id = $_.id; status = $statusCode; body = @{ id = $_.url } }
			}) }
		}

		$result = @(@('users', 'groups', 'applications') | Invoke-ZtGraphRequest -UniqueId 'object-1' -BatchSize 2 -Matched -GraphBaseUri 'https://graph.microsoft.com/')

		$result.Id | Should -Be @(0, 1, 2)
		$result.Argument.RelativeUri | Should -Be @('users', 'groups', 'applications')
		$result.Success | Should -Be @($true, $false, $true)
		$result.Attempts | Should -Be @(1, 6, 1)
		$result[2].Result.id | Should -Be 'applications/object-1'
		$script:requests | Should -HaveCount 7
		(($script:requests[6].Body | ConvertFrom-Json).requests.id) | Should -Be 2
	}

	It 'preserves paging and raw first-page matched output with DisablePaging <Raw>' -ForEach @(
		@{ Raw = $false }, @{ Raw = $true }
	) {
		Mock Invoke-ZtGraphRequestCache {
			param($Method)
			if ($Method -eq 'POST') {
				return @{ responses = @(@{ id = '0'; status = 200; body = @{
					value = @(@{ id = 'first' }); '@odata.nextLink' = 'https://graph.microsoft.com/v1.0/users?page=2'
				} }) }
			}
			@{ value = @(@{ id = 'second' }) }
		}

		$result = @(Invoke-ZtGraphRequest -RelativeUri 'users' -Matched -DisablePaging:$Raw -GraphBaseUri 'https://graph.microsoft.com/')

		$result | Should -HaveCount 1
		$result[0].Attempts | Should -Be 1
		if ($Raw) {
			$result[0].Result.value[0].id | Should -Be 'first'
			$result[0].Result.'@odata.nextLink' | Should -Be 'https://graph.microsoft.com/v1.0/users?page=2'
			Should -Invoke Invoke-ZtGraphRequestCache -Times 0 -Exactly -ParameterFilter { $Method -eq 'GET' }
		}
		else {
			$result[0].Result.id | Should -Be @('first', 'second')
			Should -Invoke Invoke-ZtGraphRequestCache -Times 1 -Exactly -ParameterFilter { $Method -eq 'GET' -and $PageIndex -eq 1 -and -not $Body }
		}
	}

	It 'propagates transport failures without item retry in matched mode <Correlated>' -ForEach @(
		@{ Correlated = $false }, @{ Correlated = $true }
	) {
		Mock Start-Sleep {}
		Mock Invoke-ZtGraphRequestCache { throw 'outer transport failed' }

		{ Invoke-ZtGraphRequest -RelativeUri 'users', 'groups' -Matched:$Correlated -GraphBaseUri 'https://graph.microsoft.com/' } | Should -Throw '*outer transport failed*'

		Should -Invoke Invoke-ZtGraphRequestCache -Times 1 -Exactly
		Should -Invoke Start-Sleep -Times 0 -Exactly
	}

	It 'propagates continuation failures instead of emitting matched success' {
		Mock Invoke-ZtGraphRequestCache {
			param($Method)
			if ($Method -eq 'GET') { throw 'continuation failed' }
			@{ responses = @(@{ id = '0'; status = 200; body = @{
				value = @(@{ id = 'first' }); '@odata.nextLink' = 'https://graph.microsoft.com/v1.0/users?page=2'
			} }) }
		}
		$script:matchedOutput = [System.Collections.Generic.List[object]]::new()

		{ Invoke-ZtGraphRequest -RelativeUri 'users' -Matched -GraphBaseUri 'https://graph.microsoft.com/' | ForEach-Object { $script:matchedOutput.Add($_) } } | Should -Throw '*continuation failed*'

		$script:matchedOutput | Should -HaveCount 0
	}

	It 'rejects incompatible matched parameters before resolving context' {
		{ Invoke-ZtGraphRequest -RelativeUri 'users' -Matched -Method POST -Body '{}' } | Should -Throw '*only supports GET*'
		{ Invoke-ZtGraphRequest -RelativeUri 'users' -Matched -DisableBatching } | Should -Throw '*DisableBatching*'
		{ Invoke-ZtGraphRequest -RelativeUri 'users' -Matched -OutputFilePath 'response.json' } | Should -Throw '*OutputFilePath*'
		Should -Invoke Invoke-ZtGraphRequestCache -Times 0 -Exactly
	}
}

Describe 'Invoke-ZtGraphRequestCache non-GET output handling' {
	BeforeAll {
		$srcRoot = Join-Path $PSScriptRoot '../../src/powershell'

		function global:Write-PSFMessage { param($Message, $Level, $Tag) }
		function global:Get-PSFConfigValue { param($FullName) return $false }
		function global:Invoke-ZtRetry { param($ScriptBlock) & $ScriptBlock }
		function global:Invoke-MgGraphRequest { param($Method, $Uri, $Headers, $OutputType, $Body) }
		function global:Get-ExportJsonFilePath { param($Path, $PageIndex) return (Join-Path $TestDrive 'post-response.json') }
		function global:Set-PSFFileContent { param($Path, $InputObject) }

		. (Join-Path $srcRoot 'private/core/Invoke-ZtGraphRequestCache.ps1')
	}

	BeforeEach {
		$script:__ZtSession = [pscustomobject]@{ GraphCache = [pscustomobject]@{ Value = @{} } }
		$script:__ZtThrottling = [pscustomobject]@{ Value = @{} }
		Mock Invoke-MgGraphRequest { '{"result":"success"}' }
		Mock Set-PSFFileContent {}
		Mock New-Item { [pscustomobject]@{ FullName = $Path } }
	}

	It 'does not read or write cache entries for POST' {
		$uri = [uri]'https://graph.microsoft.com/v1.0/security/runHuntingQuery'
		$script:__ZtSession.GraphCache.Value[$uri.AbsoluteUri] = [pscustomobject]@{ result = 'cached' }

		$result = Invoke-ZtGraphRequestCache -Uri $uri -Method POST -Body '{}' -OutputType PSObject

		$result | Should -Be '{"result":"success"}'
		Should -Invoke Invoke-MgGraphRequest -Times 1 -Exactly -ParameterFilter { $Method -eq 'POST' -and $Body -eq '{}' }
		$script:__ZtSession.GraphCache.Value[$uri.AbsoluteUri].result | Should -Be 'cached'
	}

	It 'writes and returns a parsed POST response when OutputFilePath is specified' {
		$result = Invoke-ZtGraphRequestCache -Uri 'https://graph.microsoft.com/v1.0/security/runHuntingQuery' -Method POST -Body '{}' -OutputFilePath 'response.json'

		$result.result | Should -Be 'success'
		Should -Invoke Invoke-MgGraphRequest -Times 1 -Exactly -ParameterFilter { $Method -eq 'POST' -and $OutputType -eq 'Json' }
		Should -Invoke Set-PSFFileContent -Times 1 -Exactly
	}
}
