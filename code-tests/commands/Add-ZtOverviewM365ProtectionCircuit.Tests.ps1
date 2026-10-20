Describe "Add-ZtOverviewM365ProtectionCircuit" {

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

		function global:Get-ZtSankeyValue {
			param($Nodes, [string]$Target)
			($Nodes | Where-Object { $_.target -eq $Target }).value
		}

		. (Join-Path $srcRoot "private/tenantinfo/Add-ZtOverviewM365ProtectionCircuit.ps1")
	}

	BeforeEach {
		$script:tenantInfo = 'not-set'

		Mock Write-ZtProgress {}
		Mock Write-PSFMessage {}
		Mock Add-ZtTenantInfo { $script:tenantInfo = $Value }
		Mock Get-ZtTestResultStatus { 'Passed' }
		Mock Get-ZtTestData {
			[PSCustomObject]@{ TotalDeviceCount = 100; ActiveDeviceCount = 72; ProfileEnabled = $true }
		}
	}

	Context "Circuit verdict" {

		It "Closes the circuit and sizes the acquisition axis from device counts" {
			Add-ZtOverviewM365ProtectionCircuit

			$script:tenantInfo.overallStatus | Should -Be 'Passed'
			$script:tenantInfo.degraded | Should -BeFalse
			Get-ZtSankeyValue -Nodes $script:tenantInfo.nodes -Target 'Unprotected - not acquired' | Should -Be 28
			Get-ZtSankeyValue -Nodes $script:tenantInfo.nodes -Target 'Enforced - compliant network' | Should -Be 72
		}

		It "Names enforcement as the open stage without failing acquisition" {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25379' } -MockWith { 'Failed' }

			Add-ZtOverviewM365ProtectionCircuit

			$script:tenantInfo.overallStatus | Should -Be 'Failed'
			$script:tenantInfo.openStages | Should -Be @('Enforcement (25379)')
			$script:tenantInfo.description | Should -Match 'uncontrolled networks'
			Get-ZtSankeyValue -Nodes $script:tenantInfo.nodes -Target 'Acquired but not enforced' | Should -Be 72
		}

		It "Explains that enforcement cannot function when acquisition is open" {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25376' } -MockWith { 'Failed' }

			Add-ZtOverviewM365ProtectionCircuit

			$script:tenantInfo.overallStatus | Should -Be 'Failed'
			$script:tenantInfo.openStages | Should -Be @('Acquisition (25376)')
			$script:tenantInfo.description | Should -Match 'cannot function'
			Get-ZtSankeyValue -Nodes $script:tenantInfo.nodes -Target 'Unprotected - not acquired' | Should -Be 100
		}

		It "Routes a child needing review to investigate" {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25379' } -MockWith { 'Investigate' }

			Add-ZtOverviewM365ProtectionCircuit

			$script:tenantInfo.overallStatus | Should -Be 'Investigate'
			Get-ZtSankeyValue -Nodes $script:tenantInfo.nodes -Target 'Acquired, enforcement needs review' | Should -Be 72
		}
	}

	Context "Unavailable children" {

		It "Reports <_> as unavailable instead of a confirmed failure" -ForEach @('Error', 'Planned', 'Skipped') {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25379' } -MockWith { $_ }

			Add-ZtOverviewM365ProtectionCircuit

			$script:tenantInfo.overallStatus | Should -Be 'Investigate'
			$script:tenantInfo.enforcementStatus | Should -Be 'Unavailable'
			$script:tenantInfo.degraded | Should -BeTrue
			Get-ZtSankeyValue -Nodes $script:tenantInfo.nodes -Target 'Enforcement unavailable' | Should -Be 72
			$script:tenantInfo.nodes | Where-Object target -eq 'Acquired but not enforced' | Should -BeNullOrEmpty
		}

		It "Keeps the flow when only one child produced a verdict" {
			Mock Get-ZtTestResultStatus -ParameterFilter { $TestId -eq '25379' } -MockWith { $null }

			Add-ZtOverviewM365ProtectionCircuit

			$script:tenantInfo | Should -Not -BeNullOrEmpty
			$script:tenantInfo.enforcementStatus | Should -Be 'Unavailable'
			Get-ZtSankeyValue -Nodes $script:tenantInfo.nodes -Target 'Enforcement unavailable' | Should -Be 72
		}

		It "Publishes no flow when neither child produced a verdict" {
			Mock Get-ZtTestResultStatus { $null }

			Add-ZtOverviewM365ProtectionCircuit

			$script:tenantInfo | Should -BeNullOrEmpty
		}
	}

	Context "Flow sizing" {

		It "Uses the normalized all-or-nothing width when counts are unavailable" {
			Mock Get-ZtTestData { $null }

			Add-ZtOverviewM365ProtectionCircuit

			$script:tenantInfo.countsAvailable | Should -BeFalse
			$script:tenantInfo.totalDevices | Should -Be 100
			$script:tenantInfo.description | Should -Match 'normalized all-or-nothing'
			Get-ZtSankeyValue -Nodes $script:tenantInfo.nodes -Target 'Enforced - compliant network' | Should -Be 100
		}

		It "Acquires nothing when the Microsoft traffic profile is disabled" {
			Mock Get-ZtTestData {
				[PSCustomObject]@{ TotalDeviceCount = 100; ActiveDeviceCount = 72; ProfileEnabled = $false }
			}

			Add-ZtOverviewM365ProtectionCircuit

			Get-ZtSankeyValue -Nodes $script:tenantInfo.nodes -Target 'Unprotected - not acquired' | Should -Be 100
			$script:tenantInfo.nodes | Where-Object target -eq 'Enforced - compliant network' | Should -BeNullOrEmpty
		}

		It "Omits zero-width links" {
			Mock Get-ZtTestData {
				[PSCustomObject]@{ TotalDeviceCount = 100; ActiveDeviceCount = 100; ProfileEnabled = $true }
			}

			Add-ZtOverviewM365ProtectionCircuit

			$script:tenantInfo.nodes | Where-Object value -eq 0 | Should -BeNullOrEmpty
		}
	}
}
