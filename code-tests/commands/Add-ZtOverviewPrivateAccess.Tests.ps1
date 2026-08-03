Describe "Add-ZtOverviewPrivateAccess" {

	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		if (-not (Get-Command Get-ZtTestData -ErrorAction SilentlyContinue)) {
			function global:Get-ZtTestData {
				param([string]$Name)
			}
		}

		if (-not (Get-Command Get-ZtTestResultStatus -ErrorAction SilentlyContinue)) {
			function global:Get-ZtTestResultStatus {
				param([string]$TestId)
			}
		}

		if (-not (Get-Command Add-ZtTenantInfo -ErrorAction SilentlyContinue)) {
			function global:Add-ZtTenantInfo {
				param([string]$Name, $Value)
			}
		}

		if (-not (Get-Command Write-ZtProgress -ErrorAction SilentlyContinue)) {
			function global:Write-ZtProgress {
				param([string]$Activity, [string]$Status)
			}
		}

		if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
			function global:Write-PSFMessage {
				param([Parameter(ValueFromRemainingArguments = $true)]$Args)
			}
		}

		function global:New-ZtAppRow {
			param([string]$AppId, [string]$Status)
			[PSCustomObject]@{ AppId = $AppId; Status = $Status }
		}

		function global:Get-ZtSankeyValue {
			param($Nodes, [string]$Source, [string]$Target)
			($Nodes | Where-Object { $_.source -eq $Source -and $_.target -eq $Target }).value
		}

		. (Join-Path $srcRoot "private/tenantinfo/Add-ZtOverviewPrivateAccess.ps1")
	}

	BeforeEach {
		$script:tenantInfo = 'not-set'

		Mock Write-ZtProgress {}
		Mock Write-PSFMessage {}
		Mock Add-ZtTenantInfo { $script:tenantInfo = $Value }
		Mock Get-ZtTestData { @() }
		Mock Get-ZtTestResultStatus { 'Passed' }
	}

	Context "Application partitioning" {

		It "Partitions apps into pass, fail and manual review" {
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessSegmentation' } -MockWith {
				@(
					(New-ZtAppRow -AppId 'a' -Status 'Pass'),
					(New-ZtAppRow -AppId 'b' -Status 'Fail'),
					(New-ZtAppRow -AppId 'c' -Status 'ManualReview')
				)
			}
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessAuthentication' } -MockWith {
				@(
					(New-ZtAppRow -AppId 'a' -Status 'Pass'),
					(New-ZtAppRow -AppId 'b' -Status 'Pass'),
					(New-ZtAppRow -AppId 'c' -Status 'Pass')
				)
			}

			Add-ZtOverviewPrivateAccess

			$script:tenantInfo.applicationCount | Should -Be 3
			Get-ZtSankeyValue $script:tenantInfo.nodes 'Private Access apps' 'Broad segments - at-risk' | Should -Be 1
			Get-ZtSankeyValue $script:tenantInfo.nodes 'Private Access apps' 'Segmentation manual review' | Should -Be 1
			Get-ZtSankeyValue $script:tenantInfo.nodes 'Private Access apps' 'Least-privilege segments' | Should -Be 1
			Get-ZtSankeyValue $script:tenantInfo.nodes 'Least-privilege segments' 'Strong auth - Zero Trust' | Should -Be 1
			$script:tenantInfo.populationMismatch | Should -BeFalse
		}

		It "Joins the gates on App ID rather than on row order" {
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessSegmentation' } -MockWith {
				@((New-ZtAppRow -AppId 'a' -Status 'Pass'), (New-ZtAppRow -AppId 'b' -Status 'Pass'))
			}
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessAuthentication' } -MockWith {
				@((New-ZtAppRow -AppId 'b' -Status 'Fail'), (New-ZtAppRow -AppId 'a' -Status 'Pass'))
			}

			Add-ZtOverviewPrivateAccess

			Get-ZtSankeyValue $script:tenantInfo.nodes 'Least-privilege segments' 'Strong auth - Zero Trust' | Should -Be 1
			Get-ZtSankeyValue $script:tenantInfo.nodes 'Least-privilege segments' 'Password-only - at-risk' | Should -Be 1
		}

		It "Collapses duplicate and case-variant App IDs into one application" {
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessSegmentation' } -MockWith {
				@(
					(New-ZtAppRow -AppId 'AAA' -Status 'Pass'),
					(New-ZtAppRow -AppId 'aaa' -Status 'Pass'),
					(New-ZtAppRow -AppId ' aaa ' -Status 'Pass')
				)
			}
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessAuthentication' } -MockWith {
				@((New-ZtAppRow -AppId 'aAa' -Status 'Pass'))
			}

			Add-ZtOverviewPrivateAccess

			$script:tenantInfo.applicationCount | Should -Be 1
			$script:tenantInfo.populationMismatch | Should -BeFalse
			Get-ZtSankeyValue $script:tenantInfo.nodes 'Least-privilege segments' 'Strong auth - Zero Trust' | Should -Be 1
		}
	}

	Context "Population mismatch" {

		It "Flags a mismatch when the gates evaluated different app counts" {
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessSegmentation' } -MockWith {
				@((New-ZtAppRow -AppId 'a' -Status 'Pass'), (New-ZtAppRow -AppId 'b' -Status 'Pass'))
			}
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessAuthentication' } -MockWith {
				@((New-ZtAppRow -AppId 'a' -Status 'Pass'))
			}

			Add-ZtOverviewPrivateAccess

			$script:tenantInfo.populationMismatch | Should -BeTrue
		}

		It "Flags a mismatch when the gates evaluated different apps but equal counts" {
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessSegmentation' } -MockWith {
				@((New-ZtAppRow -AppId 'a' -Status 'Pass'), (New-ZtAppRow -AppId 'b' -Status 'Pass'))
			}
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessAuthentication' } -MockWith {
				@((New-ZtAppRow -AppId 'a' -Status 'Pass'), (New-ZtAppRow -AppId 'c' -Status 'Pass'))
			}

			Add-ZtOverviewPrivateAccess

			$script:tenantInfo.populationMismatch | Should -BeTrue
		}

		It "Keeps authentication-only Quick Access apps in the population" {
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessSegmentation' } -MockWith {
				@((New-ZtAppRow -AppId 'a' -Status 'Pass'))
			}
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessAuthentication' } -MockWith {
				@((New-ZtAppRow -AppId 'a' -Status 'Pass'), (New-ZtAppRow -AppId 'quickaccess' -Status 'Fail'))
			}

			Add-ZtOverviewPrivateAccess

			$script:tenantInfo.applicationCount | Should -Be 2
			Get-ZtSankeyValue $script:tenantInfo.nodes 'Private Access apps' 'Segmentation unavailable' | Should -Be 1
		}
	}

	Context "Administration band" {

		It "Reports scoped assignments that fail their principal checks as at-risk" {
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessAdministration' } -MockWith {
				[PSCustomObject]@{ TenantWide = 0; Scoped = 5; ScopedAtRisk = 2 }
			}

			Add-ZtOverviewPrivateAccess

			Get-ZtSankeyValue $script:tenantInfo.nodes 'Application Administrator assignments' 'App-scoped admin - at-risk' | Should -Be 2
			Get-ZtSankeyValue $script:tenantInfo.nodes 'Application Administrator assignments' 'App-scoped admin - Zero Trust' | Should -Be 3
			$script:tenantInfo.adminAtRisk | Should -BeTrue
		}

		It "Does not report admin risk when every scoped assignment is clean" {
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessAdministration' } -MockWith {
				[PSCustomObject]@{ TenantWide = 0; Scoped = 4; ScopedAtRisk = 0 }
			}

			Add-ZtOverviewPrivateAccess

			$script:tenantInfo.adminAtRisk | Should -BeFalse
			Get-ZtSankeyValue $script:tenantInfo.nodes 'Application Administrator assignments' 'App-scoped admin - Zero Trust' | Should -Be 4
		}
	}

	Context "Child verdict propagation" {

		It "Reports Passed when every child passed" {
			Add-ZtOverviewPrivateAccess

			$script:tenantInfo.overallStatus | Should -Be 'Passed'
			$script:tenantInfo.degraded | Should -BeFalse
		}

		It "Reports Failed when any child failed" {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25396' } -MockWith { 'Failed' }

			Add-ZtOverviewPrivateAccess

			$script:tenantInfo.overallStatus | Should -Be 'Failed'
			($script:tenantInfo.gates | Where-Object { $_.testId -eq '25396' }).status | Should -Be 'Failed'
		}

		It "Reports Investigate when a child needs manual review" {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25395' } -MockWith { 'Investigate' }

			Add-ZtOverviewPrivateAccess

			$script:tenantInfo.overallStatus | Should -Be 'Investigate'
		}

		It "Does not report Passed when a child was skipped" {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25396' } -MockWith { 'Skipped' }

			Add-ZtOverviewPrivateAccess

			$script:tenantInfo.overallStatus | Should -Be 'Investigate'
			$script:tenantInfo.degraded | Should -BeTrue
			($script:tenantInfo.gates | Where-Object { $_.testId -eq '25396' }).status | Should -Be 'Unavailable'
			$script:tenantInfo.description | Should -BeLike '*Strong authentication*'
		}

		It "Treats errored children as unavailable" {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25384' } -MockWith { 'Error' }

			Add-ZtOverviewPrivateAccess

			($script:tenantInfo.gates | Where-Object { $_.testId -eq '25384' }).status | Should -Be 'Unavailable'
			$script:tenantInfo.degraded | Should -BeTrue
		}

		It "Treats children that never ran as unavailable" {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25395' } -MockWith { $null }

			Add-ZtOverviewPrivateAccess

			($script:tenantInfo.gates | Where-Object { $_.testId -eq '25395' }).status | Should -Be 'Unavailable'
			$script:tenantInfo.degraded | Should -BeTrue
		}
	}

	Context "Selective execution" {

		It "Reports unmatched apps as unavailable when only segmentation ran" {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25396' } -MockWith { $null }
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25384' } -MockWith { $null }
			Mock Get-ZtTestData -ParameterFilter { $Name -eq 'PrivateAccessSegmentation' } -MockWith {
				@((New-ZtAppRow -AppId 'a' -Status 'Pass'), (New-ZtAppRow -AppId 'b' -Status 'Pass'))
			}

			Add-ZtOverviewPrivateAccess

			Get-ZtSankeyValue $script:tenantInfo.nodes 'Least-privilege segments' 'Authentication unavailable' | Should -Be 2
			Get-ZtSankeyValue $script:tenantInfo.nodes 'Least-privilege segments' 'Authentication manual review' | Should -Be 0
			$script:tenantInfo.populationMismatch | Should -BeFalse
		}

		It "Publishes nothing when no child produced a result" {
			Mock Get-ZtTestResultStatus { $null }

			Add-ZtOverviewPrivateAccess

			Should -Invoke Add-ZtTenantInfo -Times 1 -Exactly
			$script:tenantInfo | Should -BeNullOrEmpty
		}
	}
}
