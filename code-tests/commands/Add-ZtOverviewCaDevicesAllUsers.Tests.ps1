Describe "Add-ZtOverviewCaDevicesAllUsers" {
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

		. (Join-Path $srcRoot "private/tenantinfo/Add-ZtOverviewCaDevicesAllUsers.ps1")
	}

	BeforeEach {
		$script:tenantInfo = $null

		Mock Write-PSFMessage {}
		Mock Write-ZtProgress {}
		Mock Get-ZtLicenseInformation { 'P2' }
		Mock Get-ZtSignInDuration { '30 days' }
		Mock Get-ZtPercentLabel { param($Value, $Total) "$Value/$Total" }
		Mock Add-ZtTenantInfo {
			param($Name, $Value)
			$script:tenantInfo = [pscustomobject]@{
				Name  = $Name
				Value = $Value
			}
		}
	}

	It "Should sum managed sign-ins across compliance buckets for Sankey data" {
		Mock Invoke-DatabaseQuery {
			@(
				[pscustomobject]@{ isManaged = $true;  isCompliant = $true;  cnt = 83 }
				[pscustomobject]@{ isManaged = $true;  isCompliant = $false; cnt = 19 }
				[pscustomobject]@{ isManaged = $false; isCompliant = $false; cnt = 455 }
			)
		}

		Add-ZtOverviewCaDevicesAllUsers -Database 'test'

		$script:tenantInfo.Name | Should -Be 'OverviewCaDevicesAllUsers'

		$nodes = $script:tenantInfo.Value.nodes
		($nodes | Where-Object { $_.source -eq 'User sign in' -and $_.target -eq 'Managed' }).value | Should -Be 102
		($nodes | Where-Object { $_.source -eq 'User sign in' -and $_.target -eq 'Unmanaged' }).value | Should -Be 455
		($nodes | Where-Object { $_.source -eq 'Managed' -and $_.target -eq 'Compliant' }).value | Should -Be 83
		($nodes | Where-Object { $_.source -eq 'Managed' -and $_.target -eq 'Non-compliant' }).value | Should -Be 19
	}

	It "Should emit zero (never null) for buckets with no matching rows (issue 1310)" {
		# Only unmanaged sign-ins present; managed/compliant buckets must resolve to 0,
		# not $null, so the report Sankey does not receive value:null and crash.
		Mock Invoke-DatabaseQuery {
			@(
				[pscustomobject]@{ isManaged = $false; isCompliant = $false; cnt = 2771 }
			)
		}

		Add-ZtOverviewCaDevicesAllUsers -Database 'test'

		$nodes = $script:tenantInfo.Value.nodes
		foreach ($node in $nodes) {
			$node.value | Should -Not -BeNullOrEmpty -Because "Sankey link $($node.source) -> $($node.target) must have a numeric value"
			$node.value | Should -BeOfType [int]
		}
		($nodes | Where-Object { $_.source -eq 'User sign in' -and $_.target -eq 'Managed' }).value | Should -Be 0
		($nodes | Where-Object { $_.source -eq 'Managed' -and $_.target -eq 'Compliant' }).value | Should -Be 0
		($nodes | Where-Object { $_.source -eq 'Managed' -and $_.target -eq 'Non-compliant' }).value | Should -Be 0
	}

	It "Should store null (no Sankey object) when the EntraID license is Free" {
		Mock Get-ZtLicenseInformation { 'Free' }
		Mock Invoke-DatabaseQuery { throw "Should not query the database on a Free license" }

		Add-ZtOverviewCaDevicesAllUsers -Database 'test'

		$script:tenantInfo.Name | Should -Be 'OverviewCaDevicesAllUsers'
		$script:tenantInfo.Value | Should -BeNullOrEmpty
		Should -Invoke Invoke-DatabaseQuery -Times 0 -Exactly
	}

	It "Should store null when the SignIn table is empty or missing" {
		Mock Invoke-DatabaseQuery { @() }

		Add-ZtOverviewCaDevicesAllUsers -Database 'test'

		$script:tenantInfo.Name | Should -Be 'OverviewCaDevicesAllUsers'
		$script:tenantInfo.Value | Should -BeNullOrEmpty
	}
}
