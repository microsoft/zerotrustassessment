Describe "Add-ZtAgentOwnershipDistribution" {
	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
			function global:Write-PSFMessage {
				param($Level, $Message, $Tag, $ErrorRecord)
			}
		}

		if (-not (Get-Command Write-ZtProgress -ErrorAction SilentlyContinue)) {
			function global:Write-ZtProgress {
				param($Activity, $Status)
			}
		}

		if (-not (Get-Command Add-ZtTenantInfo -ErrorAction SilentlyContinue)) {
			function global:Add-ZtTenantInfo {
				param($Name, $Value)
			}
		}

		if (-not (Get-Command Invoke-DatabaseQuery -ErrorAction SilentlyContinue)) {
			function global:Invoke-DatabaseQuery {
				param($Database, $Sql)
			}
		}

		if (-not (Get-Command Invoke-ZtGraphBatchRequest -ErrorAction SilentlyContinue)) {
			function global:Invoke-ZtGraphBatchRequest {
				[CmdletBinding()]
				param($Path, $ArgumentList, $Header, [switch] $NoPaging, [switch] $Matched)
			}
		}

		function New-AgentOwnershipRow {
			param(
				[string] $Id,
				[string] $DisplayName,
				[int] $OwnerCount = 0,
				[object[]] $Sponsors = @(),
				[bool] $HasSponsorSnapshot = $true,
				[bool] $HasOwnerSnapshot = $true
			)

			[pscustomobject]@{
				id                 = $Id
				displayName        = $DisplayName
				accountEnabled     = $true
				sponsorsJson       = if ($Sponsors.Count -gt 0) { $Sponsors | ConvertTo-Json -Compress -Depth 5 } else { $null }
				hasSponsorSnapshot = $HasSponsorSnapshot
				hasOwnerSnapshot   = $HasOwnerSnapshot
				ownerCount         = $OwnerCount
			}
		}

		. (Join-Path $srcRoot "private/tenantinfo/ai/Add-ZtAgentOwnershipDistribution.ps1")
	}

	BeforeEach {
		$script:tenantInfo = $null
		$script:batchArguments = @()

		Mock Write-PSFMessage {}
		Mock Write-ZtProgress {}
		Mock Add-ZtTenantInfo {
			param($Name, $Value)
			$script:tenantInfo = [pscustomobject]@{
				Name  = $Name
				Value = $Value
			}
		}
		Mock Invoke-DatabaseQuery { @() }
		Mock Invoke-ZtGraphBatchRequest { @() }
	}

	Context "Four-way classification" {
		It "Classifies each matched identity into exactly one bucket" {
			$userSponsor = [pscustomobject]@{ id = 'user-1'; '@odata.type' = '#microsoft.graph.user' }
			Mock Invoke-DatabaseQuery {
				@(
					New-AgentOwnershipRow -Id 'both' -DisplayName 'Both' -OwnerCount 1 -Sponsors @($userSponsor)
					New-AgentOwnershipRow -Id 'owner' -DisplayName 'Owner' -OwnerCount 1
					New-AgentOwnershipRow -Id 'sponsor' -DisplayName 'Sponsor' -Sponsors @($userSponsor)
					New-AgentOwnershipRow -Id 'neither' -DisplayName 'Neither'
				)
			}

			Add-ZtAgentOwnershipDistribution -Database 'test'

			$distribution = $script:tenantInfo.Value
			$distribution.ownerAndSponsor | Should -Be 1
			$distribution.ownerOnly | Should -Be 1
			$distribution.sponsorOnly | Should -Be 1
			$distribution.neither | Should -Be 1
			$distribution.skippedCount | Should -Be 0
			$allAgents = @($distribution.agents.ownerAndSponsor) + @($distribution.agents.ownerOnly) + @($distribution.agents.sponsorOnly) + @($distribution.agents.neither)
			$allAgents.Count | Should -Be 4
			@($allAgents.displayName | Sort-Object -Unique).Count | Should -Be 4
			@($distribution.agents.ownerAndSponsor).Count | Should -Be $distribution.ownerAndSponsor
			@($distribution.agents.ownerOnly).Count | Should -Be $distribution.ownerOnly
			@($distribution.agents.sponsorOnly).Count | Should -Be $distribution.sponsorOnly
			@($distribution.agents.neither).Count | Should -Be $distribution.neither
		}
	}

	Context "Group sponsor resolution" {
		It "Uses successful counts and deduplicates repeated sponsor groups" {
			$populatedGroup = [pscustomobject]@{ id = 'group-1'; '@odata.type' = '#microsoft.graph.group' }
			$emptyGroup = [pscustomobject]@{ id = 'group-2'; '@odata.type' = '#microsoft.graph.group' }
			Mock Invoke-DatabaseQuery {
				@(
					New-AgentOwnershipRow -Id 'first' -DisplayName 'First' -Sponsors @($populatedGroup)
					New-AgentOwnershipRow -Id 'second' -DisplayName 'Second' -Sponsors @($populatedGroup)
					New-AgentOwnershipRow -Id 'third' -DisplayName 'Third' -Sponsors @($emptyGroup)
				)
			}
			Mock Invoke-ZtGraphBatchRequest {
				$script:batchArguments = @($ArgumentList)
				@(
					[pscustomobject]@{ Argument = 'group-1'; Success = $true; Result = @(3); Status = 200 }
					[pscustomobject]@{ Argument = 'group-2'; Success = $true; Result = @(0); Status = 200 }
				)
			}

			Add-ZtAgentOwnershipDistribution -Database 'test'

			$script:batchArguments.Count | Should -Be 2
			@($script:batchArguments | Sort-Object -Unique).Count | Should -Be 2
			$script:tenantInfo.Value.sponsorOnly | Should -Be 2
			$script:tenantInfo.Value.neither | Should -Be 1
			Should -Invoke Invoke-ZtGraphBatchRequest -Times 1 -Exactly
		}
	}

	Context "Snapshot consistency" {
		It "Skips the symmetric difference without altering bucket counts" {
			Mock Invoke-DatabaseQuery {
				param($Database, $Sql)
				$script:query = $Sql
				@(
					New-AgentOwnershipRow -Id 'matched' -DisplayName 'Matched'
					New-AgentOwnershipRow -Id 'sponsor-only-snapshot' -DisplayName 'Sponsor snapshot only' -HasOwnerSnapshot $false
					New-AgentOwnershipRow -Id 'owner-only-snapshot' -DisplayName $null -HasSponsorSnapshot $false
				)
			}

			Add-ZtAgentOwnershipDistribution -Database 'test'

			$distribution = $script:tenantInfo.Value
			$distribution.neither | Should -Be 1
			$distribution.ownerAndSponsor + $distribution.ownerOnly + $distribution.sponsorOnly + $distribution.neither | Should -Be 1
			$distribution.skippedCount | Should -Be 2
			$distribution.neither + $distribution.skippedCount | Should -Be 3
			$script:query | Should -Match 'full outer join agent_owners'
			$script:query | Should -Match '"@odata.type" = ''#microsoft.graph.agentIdentity'''
			Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter {
				$Level -eq 'Warning' -and $Message -match '^2 agent identities were excluded'
			}
		}
	}

	Context "Failure handling" {
		BeforeEach {
			$script:groupSponsor = [pscustomobject]@{ id = 'group-1'; '@odata.type' = '#microsoft.graph.group' }
			Mock Invoke-DatabaseQuery {
				@(New-AgentOwnershipRow -Id 'agent' -DisplayName 'Agent' -Sponsors @($script:groupSponsor))
			}
		}

		It "Publishes null when the database query throws" {
			Mock Invoke-DatabaseQuery { throw 'database failed' }

			Add-ZtAgentOwnershipDistribution -Database 'test'

			$script:tenantInfo.Value | Should -BeNullOrEmpty
			Should -Invoke Invoke-ZtGraphBatchRequest -Times 0 -Exactly
		}

		It "Publishes null when the batch request throws" {
			Mock Invoke-ZtGraphBatchRequest { throw 'batch failed' }

			Add-ZtAgentOwnershipDistribution -Database 'test'

			$script:tenantInfo.Value | Should -BeNullOrEmpty
		}

		It "Publishes null for an unsuccessful batch result without using its argument" {
			Mock Invoke-ZtGraphBatchRequest {
				[pscustomobject]@{
					Argument = @{ url = 'groups/group-1/transitiveMembers/$count' }
					Success  = $false
					Result   = $null
					Status   = 503
				}
			}

			Add-ZtAgentOwnershipDistribution -Database 'test'

			$script:tenantInfo.Value | Should -BeNullOrEmpty
		}

		It "Publishes null when a requested group result is omitted" {
			$secondGroup = [pscustomobject]@{ id = 'group-2'; '@odata.type' = '#microsoft.graph.group' }
			Mock Invoke-DatabaseQuery {
				@(
					New-AgentOwnershipRow -Id 'first' -DisplayName 'First' -Sponsors @($script:groupSponsor)
					New-AgentOwnershipRow -Id 'second' -DisplayName 'Second' -Sponsors @($secondGroup)
				)
			}
			Mock Invoke-ZtGraphBatchRequest {
				[pscustomobject]@{ Argument = 'group-1'; Success = $true; Result = @(1); Status = 200 }
			}

			Add-ZtAgentOwnershipDistribution -Database 'test'

			$script:tenantInfo.Value | Should -BeNullOrEmpty
		}
	}

	Context "Empty tenant" {
		It "Publishes zero counts and empty detail arrays" {
			Add-ZtAgentOwnershipDistribution -Database 'test'

			$distribution = $script:tenantInfo.Value
			$distribution.ownerAndSponsor | Should -Be 0
			$distribution.ownerOnly | Should -Be 0
			$distribution.sponsorOnly | Should -Be 0
			$distribution.neither | Should -Be 0
			$distribution.skippedCount | Should -Be 0
			@($distribution.agents.ownerAndSponsor).Count | Should -Be 0
			@($distribution.agents.ownerOnly).Count | Should -Be 0
			@($distribution.agents.sponsorOnly).Count | Should -Be 0
			@($distribution.agents.neither).Count | Should -Be 0
			Should -Invoke Invoke-ZtGraphBatchRequest -Times 0 -Exactly
		}
	}
}
