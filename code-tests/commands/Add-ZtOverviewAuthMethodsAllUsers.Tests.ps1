Describe "Add-ZtOverviewAuthMethodsAllUsers" {
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

		. (Join-Path $srcRoot "private/tenantinfo/Add-ZtOverviewAuthMethodsAllUsers.ps1")
	}

	BeforeEach {
		$script:tenantInfo = $null

		Mock Write-PSFMessage {}
		Mock Write-ZtProgress {}
		Mock Get-ZtLicenseInformation { 'P2' }
		Mock Add-ZtTenantInfo {
			param($Name, $Value)
			$script:tenantInfo = [pscustomobject]@{
				Name  = $Name
				Value = $Value
			}
		}
	}

	It "Should compute Sankey values from registration counts" {
		Mock Invoke-DatabaseQuery { [pscustomobject]@{ count = 5 } }

		Add-ZtOverviewAuthMethodsAllUsers -Database 'test'

		$script:tenantInfo.Name | Should -Be 'OverviewAuthMethodsAllUsers'
		$nodes = $script:tenantInfo.Value.nodes
		($nodes | Where-Object { $_.source -eq 'Users' -and $_.target -eq 'Single factor' }).value | Should -Be 5
		($nodes | Where-Object { $_.source -eq 'Users' -and $_.target -eq 'Phishable' }).value | Should -Be 10
		($nodes | Where-Object { $_.source -eq 'Users' -and $_.target -eq 'Phish resistant' }).value | Should -Be 10
	}

	It "Should emit zero (never null) when registration queries return null counts (issue 1310)" {
		Mock Invoke-DatabaseQuery { [pscustomobject]@{ count = $null } }

		Add-ZtOverviewAuthMethodsAllUsers -Database 'test'

		$nodes = $script:tenantInfo.Value.nodes
		foreach ($node in $nodes) {
			$node.value | Should -Not -BeNullOrEmpty -Because "Sankey link $($node.source) -> $($node.target) must have a numeric value"
			$node.value | Should -BeOfType [int]
			$node.value | Should -Be 0
		}
	}

	It "Should store null (no Sankey object) when the EntraID license is Free" {
		Mock Get-ZtLicenseInformation { 'Free' }
		Mock Invoke-DatabaseQuery { throw "Should not query the database on a Free license" }

		Add-ZtOverviewAuthMethodsAllUsers -Database 'test'

		$script:tenantInfo.Name | Should -Be 'OverviewAuthMethodsAllUsers'
		$script:tenantInfo.Value | Should -BeNullOrEmpty
		Should -Invoke Invoke-DatabaseQuery -Times 0 -Exactly
	}
}
