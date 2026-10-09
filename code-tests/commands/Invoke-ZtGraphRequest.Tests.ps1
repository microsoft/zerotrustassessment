Describe 'Invoke-ZtGraphRequest POST support' {
	BeforeAll {
		$srcRoot = Join-Path $PSScriptRoot '../../src/powershell'

		function global:Write-PSFMessage { param($Message, $Level, $Tag) }
		function global:Get-ObjectProperty {
			param($InputObjects, $Property)
			$InputObjects.PSObject.Properties[$Property].Value
		}
		function global:ConvertTo-QueryString { param($InputObject) return $null }
		function global:ConvertFrom-QueryString { param($InputStrings, $AsHashtable) return @{} }
		function global:Get-MgContext { throw 'Graph context should not be resolved for validation failures.' }
		function global:Get-MgEnvironment { param($Name) throw 'Graph environment should not be resolved for validation failures.' }

		. (Join-Path $srcRoot 'public/Invoke-ZtGraphRequest.ps1')
		. (Join-Path $srcRoot 'private/graph/Invoke-ZtGraphBatchRequest.ps1')
	}

	BeforeEach {
		$script:requests = [System.Collections.Generic.List[hashtable]]::new()
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' { throw 'Unexpected SDK request' }
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

	It 'delegates prepared relative requests using the session-resolved Graph endpoint' {
		$script:__ZtSession = [pscustomobject]@{ GraphBaseUri = $null }
		Mock Get-MgContext { [pscustomobject]@{ Environment = 'Global' } }
		Mock Get-MgEnvironment { [pscustomobject]@{ GraphEndpoint = 'https://graph.microsoft.com/' } }
		Mock Invoke-ZtGraphBatchRequest {
			param($Request, $Raw, $NoPaging, $ApiVersion)
			$script:requests.Add(@{ Members = $Request; Raw = $Raw; NoPaging = $NoPaging; ApiVersion = $ApiVersion })
		}

		Invoke-ZtGraphRequest -RelativeUri @('users', 'groups') | Out-Null

		$script:requests | Should -HaveCount 1
		$script:requests[0].Members.url | Should -Be @('users', 'groups')
		$script:requests[0].Raw | Should -BeTrue
		$script:requests[0].NoPaging | Should -BeTrue
		$script:requests[0].ApiVersion | Should -Be 'v1.0'
		Should -Invoke Invoke-ZtGraphRequestCache -Times 0 -Exactly
		Should -Invoke Get-MgContext -Times 1 -Exactly
		Should -Invoke Get-MgEnvironment -Times 1 -Exactly
	}

	It 'delegates 41 prepared requests with unique IDs and headers to the unchanged scheduler' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Uri, $Body)
			$members = @($Body.requests)
			$script:requests.Add(@{ Uri = $Uri; Members = $members })
			@{ responses = @($members | ForEach-Object { @{ id = $_.id; status = 200; body = @{ result = $_.url } } }) }
		}
		$headers = @{ 'X-Test' = 'retained' }
		$result = @(Invoke-ZtGraphRequest -RelativeUri users -UniqueId (1..41) -GraphBaseUri 'https://graph.microsoft.com/' -Headers $headers -ConsistencyLevel eventual)

		$result | Should -HaveCount 41
		$script:requests | Should -HaveCount 3
		@($script:requests | ForEach-Object { $_.Members.Count }) | Should -Be @(19, 19, 3)
		$members = @($script:requests | ForEach-Object { $_.Members })
		@($members.id | Select-Object -Unique) | Should -HaveCount 41
		$members[0].id | Should -Be '1'
		$members[0].url | Should -Be 'users/1'
		$members[0].headers.'X-Test' | Should -Be 'retained'
		$members[0].headers.ConsistencyLevel | Should -Be 'eventual'
		$headers.ContainsKey('ConsistencyLevel') | Should -BeFalse
		foreach ($request in $script:requests) {
			$request.Uri | Should -Be 'v1.0/$batch'
		}
	}

	It 'retries an inner 429 without resending a successful sibling' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			$members = @($Body.requests)
			$script:requests.Add(@{ Members = $members })
			if ($script:requests.Count -eq 1) {
				return @{ responses = @(
					@{ id = $members[0].id; status = 200; body = @{ result = 'users' } }
					@{ id = $members[1].id; status = 429; headers = @{ 'Retry-After' = '0' }; body = @{ error = @{ code = 'TooManyRequests' } } }
				) }
			}
			@{ responses = @(@{ id = $members[0].id; status = 200; body = @{ result = 'groups' } }) }
		}

		$result = @(Invoke-ZtGraphRequest -RelativeUri users, groups -GraphBaseUri 'https://graph.microsoft.com/')

		$result.result | Should -Be @('users', 'groups')
		$script:requests | Should -HaveCount 2
		$script:requests[1].Members | Should -HaveCount 1
		$script:requests[1].Members[0].url | Should -Be 'groups'
	}

	It 'streams continuation GETs before submitting the next chunk' {
		Mock Invoke-ZtGraphRequestCache {
			param($Method, $Uri, $Headers, $OutputFilePath, $PageIndex)
			$script:requests.Add(@{ Method = $Method; Uri = $Uri; Headers = $Headers; OutputFilePath = $OutputFilePath; PageIndex = $PageIndex })
			@{ result = 'continued' }
		}
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Method, $Body)
			$script:requests.Add(@{ Method = $Method })
			$members = @($Body.requests)
			@{ responses = @($members | ForEach-Object {
				$responseBody = @{ result = $_.url }
				if ($_.id -eq '1') { $responseBody['@odata.nextLink'] = 'https://graph.microsoft.com/v1.0/users?page=2' }
				@{ id = $_.id; status = 200; body = $responseBody }
			}) }
		}

		$result = @(Invoke-ZtGraphRequest -RelativeUri users -UniqueId (1..20) -GraphBaseUri 'https://graph.microsoft.com/' -OutputFilePath 'pages.json' -Headers @{ 'X-Test' = 'retained' })

		$result | Should -HaveCount 21
		$result[0].result | Should -Be 'users/1'
		$result[1].result | Should -Be 'continued'
		$result[-1].result | Should -Be 'users/20'
		$script:requests.Method | Should -Be @('POST', 'GET', 'POST')
		$script:requests[1].PageIndex | Should -Be 1
		$script:requests[1].OutputFilePath | Should -Be 'pages.json'
		$script:requests[1].Headers.'X-Test' | Should -Be 'retained'
	}

	It 'returns first-page envelopes without continuation GETs when paging is disabled' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Body)
			@{ responses = @($Body.requests | ForEach-Object {
				@{ id = $_.id; status = 200; body = @{ value = @(@{ id = $_.id }); '@odata.nextLink' = 'https://graph.microsoft.com/v1.0/users?page=2' } }
			}) }
		}
		$result = @(Invoke-ZtGraphRequest -RelativeUri users, groups -DisablePaging -GraphBaseUri 'https://graph.microsoft.com/')
		$result | Should -HaveCount 2
		$result[0].ContainsKey('value') | Should -BeTrue
		Should -Invoke Invoke-ZtGraphRequestCache -Times 0 -Exactly
	}

	It 'formats collections and retains raw member failure bodies' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			@{ responses = @(
				@{ id = '2'; status = 403; body = @{ error = @{ code = 'Authorization_RequestDenied' } } }
				@{ id = '1'; status = 200; body = @{ value = @(@{ id = 'user' }); '@odata.context' = 'context' } }
			) }
		}
		$result = @(Invoke-ZtGraphRequest -RelativeUri users, groups -GraphBaseUri 'https://graph.microsoft.com/')
		$result | Should -HaveCount 2
		$result[0].error.code | Should -Be 'Authorization_RequestDenied'
		$result[1].'@odata.context' | Should -Be 'context/$entity'
	}

	It 'stops batch submission when a continuation GET terminates' {
		Mock Invoke-ZtGraphRequestCache {
			param($Method)
			$script:requests.Add(@{ Method = $Method })
			throw 'Continuation failed'
		}
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
			param($Method, $Body)
			$script:requests.Add(@{ Method = $Method })
			$member = $Body.requests[0]
			@{ responses = @(@{ id = $member.id; status = 200; body = @{ result = 'first'; '@odata.nextLink' = 'https://graph.microsoft.com/v1.0/users?page=2' } }) }
		}
		$emitted = [System.Collections.Generic.List[object]]::new()
		{ Invoke-ZtGraphRequest -RelativeUri users -UniqueId (1..20) -GraphBaseUri 'https://graph.microsoft.com/' -ErrorAction Stop | ForEach-Object { $emitted.Add($_) } } | Should -Throw '*Continuation failed*'
		$script:requests.Method | Should -Be @('POST', 'GET')
		$emitted | Should -HaveCount 1
		$emitted[0].result | Should -Be 'first'
	}

	It 'surfaces batch transport errors with ErrorAction Stop' {
		Mock 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' { throw 'Batch transport failed' }
		{ Invoke-ZtGraphRequest -RelativeUri users, groups -GraphBaseUri 'https://graph.microsoft.com/' -ErrorAction Stop } | Should -Throw '*Batch transport failed*'
		Should -Invoke 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 1 -Exactly
	}

	It 'does not delegate disabled batching or scalar pipeline records' {
		Mock Invoke-ZtGraphBatchRequest { throw 'Unexpected batch delegation' }
		Invoke-ZtGraphRequest -RelativeUri users, groups -DisableBatching -GraphBaseUri 'https://graph.microsoft.com/' -WarningAction SilentlyContinue | Out-Null
		@('users', 'groups') | Invoke-ZtGraphRequest -GraphBaseUri 'https://graph.microsoft.com/' | Out-Null
		Should -Invoke Invoke-ZtGraphBatchRequest -Times 0 -Exactly
		Should -Invoke Invoke-ZtGraphRequestCache -Times 4 -Exactly
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
