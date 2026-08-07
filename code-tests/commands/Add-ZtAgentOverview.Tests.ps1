Describe "Add-ZtAgentOverview" {
	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
			function global:Write-PSFMessage {
				param($Level, $Message, $Tag)
			}
		}

		if (-not (Get-Command Write-ZtProgress -ErrorAction SilentlyContinue)) {
			function global:Write-ZtProgress {
				param($Activity, $Status)
			}
		}

		if (-not (Get-Command Invoke-ZtGraphRequest -ErrorAction SilentlyContinue)) {
			function global:Invoke-ZtGraphRequest {
				param(
					$RelativeUri,
					$ApiVersion,
					$Select,
					$Filter,
					$Top,
					$QueryParameters,
					$ConsistencyLevel,
					$Headers,
					[switch] $DisablePaging,
					[switch] $DisableCache
				)
			}
		}

		if (-not (Get-Command Add-ZtTenantInfo -ErrorAction SilentlyContinue)) {
			function global:Add-ZtTenantInfo {
				param($Name, $Value)
			}
		}

		. (Join-Path $srcRoot "private/tenantinfo/ai/Add-ZtAgentOverview.ps1")
	}

	BeforeEach {
		$script:tenantInfo = $null
		$script:activeUserFilter = $null

		Mock Write-PSFMessage {}
		Mock Write-ZtProgress {}
		Mock Add-ZtTenantInfo {
			param($Name, $Value)
			$script:tenantInfo = [pscustomobject]@{
				Name  = $Name
				Value = $Value
			}
		}
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'servicePrincipals' } -MockWith {
			@{ '@odata.count' = 42; value = @(@{ id = 'agent-1' }) }
		}
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -like 'auditLogs/getSummarizedNonInteractiveSignIns*' } -MockWith {
			$script:activeUserFilter = $Filter
			@(
				[pscustomobject]@{ userPrincipalName = 'alice@contoso.com' }
				[pscustomobject]@{ userPrincipalName = 'Alice@Contoso.com' }
				[pscustomobject]@{ userPrincipalName = 'bob@contoso.com' }
				[pscustomobject]@{ userPrincipalName = $null }
				[pscustomobject]@{ userPrincipalName = '   ' }
			)
		}
	}

	It "Should collect total agents and unique active users using the expected Graph requests" {
		Add-ZtAgentOverview

		$script:tenantInfo.Name | Should -Be 'AgentOverview'
		$script:tenantInfo.Value.TotalAgents | Should -Be 42
		$script:tenantInfo.Value.TotalAgents | Should -BeOfType [int]
		$script:tenantInfo.Value.ActiveUsers | Should -Be 2
		$script:tenantInfo.Value.ActiveUsers | Should -BeOfType [int]
		$startMatch = [regex]::Match($script:activeUserFilter, 'firstSignInDateTime ge (?<Start>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)')
		$endMatch = [regex]::Match($script:activeUserFilter, 'firstSignInDateTime lt (?<End>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)')
		$startMatch.Success | Should -BeTrue
		$endMatch.Success | Should -BeTrue
		$lookbackStart = [datetimeoffset]::ParseExact($startMatch.Groups['Start'].Value, 'yyyy-MM-ddTHH:mm:ssZ', [Globalization.CultureInfo]::InvariantCulture)
		$lookbackEnd = [datetimeoffset]::ParseExact($endMatch.Groups['End'].Value, 'yyyy-MM-ddTHH:mm:ssZ', [Globalization.CultureInfo]::InvariantCulture)
		($lookbackEnd - $lookbackStart).TotalDays | Should -Be 30

		Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly -ParameterFilter {
			$RelativeUri -eq 'servicePrincipals' -and
			$ApiVersion -eq 'v1.0' -and
			$Select -eq 'id' -and
			$Filter -eq "(isof('microsoft.graph.agentIdentity') OR (tags/any(p:startswith(p, 'power-virtual-agents-')) OR tags/any(p:p eq 'AgenticInstance')))" -and
			$Top -eq 1 -and
			$QueryParameters['$count'] -eq 'true' -and
			$ConsistencyLevel -eq 'eventual' -and
			$DisablePaging -and
			$DisableCache
		}
		Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly -ParameterFilter {
			$RelativeUri -eq "auditLogs/getSummarizedNonInteractiveSignIns(aggregationWindow='d1')" -and
			$ApiVersion -eq 'beta' -and
			$Select -eq 'userPrincipalName' -and
			$Filter -match "agent/agentType eq 'agenticAppInstance'" -and
			$Filter -match "agent/agentSubjectType ne 'agentIDuser'" -and
			$Filter -match 'firstSignInDateTime ge \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z' -and
			$Filter -match 'firstSignInDateTime lt \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z' -and
			$Top -eq 1000 -and
			$QueryParameters['$orderby'] -eq 'firstSignInDateTime desc' -and
			$Headers.Prefer -eq 'include-unknown-enum-members' -and
			$DisableCache
		}
		Should -Invoke Add-ZtTenantInfo -Times 1 -Exactly -ParameterFilter { $Name -eq 'AgentOverview' }
		Should -Invoke Write-PSFMessage -Times 0 -Exactly
		Should -Invoke Write-ZtProgress -Times 1 -Exactly -ParameterFilter { $Status -eq 'Processing' }
		Should -Invoke Write-ZtProgress -Times 1 -Exactly -ParameterFilter { $Status -eq 'Completed' }
	}

	It "Should emit zero values when Graph returns no agents or sign-ins" {
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'servicePrincipals' } -MockWith {
			@{ '@odata.count' = 0; value = @() }
		}
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -like 'auditLogs/getSummarizedNonInteractiveSignIns*' } -MockWith { @() }

		Add-ZtAgentOverview

		$script:tenantInfo.Value.TotalAgents | Should -Be 0
		$script:tenantInfo.Value.ActiveUsers | Should -Be 0
		Should -Invoke Write-PSFMessage -Times 0 -Exactly
	}

	It "Should preserve active users when the total-agent query fails" {
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'servicePrincipals' } -MockWith {
			throw 'Agent count request failed'
		}

		Add-ZtAgentOverview

		$script:tenantInfo.Value.TotalAgents | Should -BeNullOrEmpty
		$script:tenantInfo.Value.ActiveUsers | Should -Be 2
		Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly -ParameterFilter { $RelativeUri -like 'auditLogs/getSummarizedNonInteractiveSignIns*' }
		Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter {
			$Level -eq 'Warning' -and $Message -eq 'Unable to retrieve the total agent count from Microsoft Graph.'
		}
	}

	It "Should preserve total agents when the active-user query fails" {
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -like 'auditLogs/getSummarizedNonInteractiveSignIns*' } -MockWith {
			throw 'Active user request failed'
		}

		Add-ZtAgentOverview

		$script:tenantInfo.Value.TotalAgents | Should -Be 42
		$script:tenantInfo.Value.ActiveUsers | Should -BeNullOrEmpty
		Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter {
			$Level -eq 'Warning' -and $Message -eq 'Unable to retrieve active agent users from Microsoft Graph.'
		}
		Should -Invoke Add-ZtTenantInfo -Times 1 -Exactly -ParameterFilter { $Name -eq 'AgentOverview' }
	}

	It "Should treat a missing agent count as a failed total-agent query" {
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'servicePrincipals' } -MockWith {
			@{ value = @() }
		}

		Add-ZtAgentOverview

		$script:tenantInfo.Value.TotalAgents | Should -BeNullOrEmpty
		$script:tenantInfo.Value.ActiveUsers | Should -Be 2
		Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter {
			$Level -eq 'Warning' -and $Message -eq 'Unable to retrieve the total agent count from Microsoft Graph.'
		}
	}
}
