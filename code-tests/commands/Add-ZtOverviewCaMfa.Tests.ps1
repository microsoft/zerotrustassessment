Describe "Add-ZtOverviewCaMfa" {
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

		. (Join-Path $srcRoot "private/tenantinfo/Add-ZtOverviewCaMfa.ps1")
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

	It "Should compute Sankey values from sign-in conditional access buckets" {
		Mock Invoke-DatabaseQuery {
			@(
				[pscustomobject]@{ conditionalAccessStatus = 'success';    authenticationRequirement = 'multiFactorAuthentication';  cnt = 2121 }
				[pscustomobject]@{ conditionalAccessStatus = 'success';    authenticationRequirement = 'singleFactorAuthentication'; cnt = 5 }
				[pscustomobject]@{ conditionalAccessStatus = 'notApplied'; authenticationRequirement = 'multiFactorAuthentication';  cnt = 6 }
				[pscustomobject]@{ conditionalAccessStatus = 'notApplied'; authenticationRequirement = 'singleFactorAuthentication'; cnt = 6 }
			)
		}

		Add-ZtOverviewCaMfa -Database 'test'

		$script:tenantInfo.Name | Should -Be 'OverviewCaMfaAllUsers'
		$nodes = $script:tenantInfo.Value.nodes
		($nodes | Where-Object { $_.source -eq 'User sign in' -and $_.target -eq 'CA applied' }).value | Should -Be 2126
		($nodes | Where-Object { $_.source -eq 'User sign in' -and $_.target -eq 'No CA applied' }).value | Should -Be 12
		($nodes | Where-Object { $_.source -eq 'CA applied' -and $_.target -eq 'MFA' }).value | Should -Be 2121
		($nodes | Where-Object { $_.source -eq 'CA applied' -and $_.target -eq 'No MFA' }).value | Should -Be 5
	}

	It "Should emit zero (never null) for buckets with no matching rows (issue 1310)" {
		# Only one bucket present; the other three must resolve to 0, not $null,
		# so the report Sankey does not receive value:null and crash.
		Mock Invoke-DatabaseQuery {
			@(
				[pscustomobject]@{ conditionalAccessStatus = 'notApplied'; authenticationRequirement = 'singleFactorAuthentication'; cnt = 88 }
			)
		}

		Add-ZtOverviewCaMfa -Database 'test'

		$nodes = $script:tenantInfo.Value.nodes
		foreach ($node in $nodes) {
			$node.value | Should -Not -BeNullOrEmpty -Because "Sankey link $($node.source) -> $($node.target) must have a numeric value"
			$node.value | Should -BeOfType [int]
		}
		($nodes | Where-Object { $_.source -eq 'CA applied' -and $_.target -eq 'MFA' }).value | Should -Be 0
		($nodes | Where-Object { $_.source -eq 'CA applied' -and $_.target -eq 'No MFA' }).value | Should -Be 0
	}

	It "Should store null (no Sankey object) when the EntraID license is Free" {
		Mock Get-ZtLicenseInformation { 'Free' }
		Mock Invoke-DatabaseQuery { throw "Should not query the database on a Free license" }

		Add-ZtOverviewCaMfa -Database 'test'

		$script:tenantInfo.Name | Should -Be 'OverviewCaMfaAllUsers'
		$script:tenantInfo.Value | Should -BeNullOrEmpty
		Should -Invoke Invoke-DatabaseQuery -Times 0 -Exactly
	}

	It "Should store null when the SignIn table is empty or missing" {
		Mock Invoke-DatabaseQuery { @() }

		Add-ZtOverviewCaMfa -Database 'test'

		$script:tenantInfo.Name | Should -Be 'OverviewCaMfaAllUsers'
		$script:tenantInfo.Value | Should -BeNullOrEmpty
	}
}
