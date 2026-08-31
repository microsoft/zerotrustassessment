Describe "Add-ZtDeviceOverview" {
	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		function Assert-ValidSankeyLinks {
			param(
				$Nodes,
				[string] $Because
			)

			foreach ($node in @($Nodes)) {
				$node.source | Should -Not -BeNullOrEmpty -Because $Because
				$node.target | Should -Not -BeNullOrEmpty -Because $Because
				$node.source | Should -Not -Be $node.target -Because $Because
				$node.value | Should -Not -BeNullOrEmpty -Because $Because
				$node.value | Should -BeGreaterThan 0 -Because $Because
			}
		}

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

		if (-not (Get-Command Get-ZtLicense -ErrorAction SilentlyContinue)) {
			function global:Get-ZtLicense {
				param([Parameter(ValueFromRemainingArguments)] $Args)
			}
		}

		if (-not (Get-Command Add-ZtTenantInfo -ErrorAction SilentlyContinue)) {
			function global:Add-ZtTenantInfo {
				param($Name, $Value)
			}
		}

		if (-not (Get-Command Get-ZtHttpStatusCode -ErrorAction SilentlyContinue)) {
			function global:Get-ZtHttpStatusCode {
				param($ErrorRecord)
			}
		}

		if (-not (Get-Command Invoke-ZtGraphRequest -ErrorAction SilentlyContinue)) {
			function global:Invoke-ZtGraphRequest {
				param($RelativeUri, $ApiVersion, $Method, $Body, $ErrorAction)
			}
		}

		if (-not (Get-Command Invoke-DatabaseQuery -ErrorAction SilentlyContinue)) {
			function global:Invoke-DatabaseQuery {
				param($Database, $Sql)
			}
		}

		. (Join-Path $srcRoot "private/tenantinfo/devices/Add-ZtDeviceOverview.ps1")
	}

	BeforeEach {
		$script:tenantInfo = $null

		Mock Write-PSFMessage {}
		Mock Write-ZtProgress {}
		# Default to the non-Intune branch (Entra-derived counts) so the Sankey
		# summaries are exercised without needing Graph mocks.
		Mock Get-ZtLicense { $false }
		Mock Add-ZtTenantInfo {
			param($Name, $Value)
			$script:tenantInfo = [pscustomobject]@{
				Name  = $Name
				Value = $Value
			}
		}

		# Default: every query returns no rows. Individual tests override the
		# specific queries they care about via -ParameterFilter.
		Mock Invoke-DatabaseQuery { @() }
	}

	It "Should summarize all devices across operating systems" {
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'group by operatingSystem' -and $Sql -notmatch 'group by operatingSystem, trustType' -and $Sql -notmatch 'group by operatingSystem, isCompliant' } -MockWith {
			@(
				[pscustomobject]@{ operatingSystem = 'Android'; count = 4 }
				[pscustomobject]@{ operatingSystem = 'IPhone'; count = 2 }
				[pscustomobject]@{ operatingSystem = 'Linux'; count = 1 }
				[pscustomobject]@{ operatingSystem = 'MacMDM'; count = 3 }
				[pscustomobject]@{ operatingSystem = 'Windows'; count = 6 }
			)
		}

		Add-ZtDeviceOverview -Database 'test'

		$script:tenantInfo.Value.DeviceSummary.deviceOperatingSystemSummary.windowsCount | Should -Be 6
		$script:tenantInfo.Value.DeviceSummary.deviceOperatingSystemSummary.macOSCount | Should -Be 3
		$script:tenantInfo.Value.DeviceSummary.deviceOperatingSystemSummary.iosCount | Should -Be 2
		$script:tenantInfo.Value.DeviceSummary.deviceOperatingSystemSummary.androidCount | Should -Be 4
		$script:tenantInfo.Value.DeviceSummary.deviceOperatingSystemSummary.linuxCount | Should -Be 1
		$script:tenantInfo.Value.DeviceSummary.totalDevices | Should -Be 16
	}

	It "Should add MDE sensor coverage from one Advanced Hunting aggregate" {
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'group by operatingSystem' -and $Sql -notmatch 'group by operatingSystem, trustType' -and $Sql -notmatch 'group by operatingSystem, isCompliant' } -MockWith {
			@(
				[pscustomobject]@{ operatingSystem = 'Windows'; count = 10 }
				[pscustomobject]@{ operatingSystem = 'macOS'; count = 5 }
				[pscustomobject]@{ operatingSystem = 'iOS'; count = 4 }
				[pscustomobject]@{ operatingSystem = 'Android'; count = 3 }
				[pscustomobject]@{ operatingSystem = 'Linux'; count = 2 }
			)
		}
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'security/runHuntingQuery' } -MockWith {
			[pscustomobject]@{
				results = @(
					[pscustomobject]@{ Platform = 'Windows'; MdeSensorInstalledCount = 8 }
					[pscustomobject]@{ Platform = 'macOS'; MdeSensorInstalledCount = 4 }
					[pscustomobject]@{ Platform = 'iOS/iPadOS'; MdeSensorInstalledCount = 2 }
					[pscustomobject]@{ Platform = 'Android'; MdeSensorInstalledCount = 1 }
					[pscustomobject]@{ Platform = 'Linux'; MdeSensorInstalledCount = 0 }
				)
			}
		}

		Add-ZtDeviceOverview -Database 'test'

		$coverage = $script:tenantInfo.Value.DeviceSummary.mdeSensorInstalledOperatingSystemSummary
		$coverage.windowsCount | Should -Be 8
		$coverage.macOSCount | Should -Be 4
		$coverage.iosCount | Should -Be 2
		$coverage.androidCount | Should -Be 1
		$coverage.linuxCount | Should -Be 0
		Should -Invoke Invoke-ZtGraphRequest -Exactly 1 -ParameterFilter {
			$RelativeUri -eq 'security/runHuntingQuery' -and
			$ApiVersion -eq 'v1.0' -and
			$Method -eq 'POST' -and
			($Body | ConvertFrom-Json).Timespan -eq 'P30D'
		}
	}

	It "Should omit MDE coverage when Advanced Hunting returns no result set" {
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'security/runHuntingQuery' } -MockWith {
			[pscustomobject]@{ results = $null }
		}

		Add-ZtDeviceOverview -Database 'test'

		$script:tenantInfo.Value.DeviceSummary.PSObject.Properties.Name | Should -Not -Contain 'mdeSensorInstalledOperatingSystemSummary'
		Should -Invoke Write-PSFMessage -Exactly 1 -ParameterFilter {
			$Level -eq 'Warning' -and $Message -eq 'Advanced hunting returned no result set for MDE sensor coverage.'
		}
	}

	It "Should omit MDE coverage when Advanced Hunting returns an empty result set" {
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'security/runHuntingQuery' } -MockWith {
			[pscustomobject]@{ results = @() }
		}

		Add-ZtDeviceOverview -Database 'test'

		$script:tenantInfo.Value.DeviceSummary.PSObject.Properties.Name | Should -Not -Contain 'mdeSensorInstalledOperatingSystemSummary'
		Should -Invoke Write-PSFMessage -Exactly 1 -ParameterFilter {
			$Level -eq 'Warning' -and $Message -eq 'Advanced hunting returned no result set for MDE sensor coverage.'
		}
	}

	It "Should continue without MDE coverage when Advanced Hunting fails" {
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'security/runHuntingQuery' } -MockWith {
			throw 'Advanced Hunting request failed'
		}

		{ Add-ZtDeviceOverview -Database 'test' } | Should -Not -Throw

		$script:tenantInfo.Value.DeviceSummary.PSObject.Properties.Name | Should -Not -Contain 'mdeSensorInstalledOperatingSystemSummary'
		Should -Invoke Write-PSFMessage -Exactly 1 -ParameterFilter {
			$Level -eq 'Warning' -and $Message -like 'Failed to retrieve MDE sensor coverage from advanced hunting:*'
		}
	}

	It "Should warn only when MDE coverage exceeds the platform total" {
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'security/runHuntingQuery' } -MockWith {
			[pscustomobject]@{
				results = @(
					[pscustomobject]@{ Platform = 'Windows'; MdeSensorInstalledCount = 1 }
					[pscustomobject]@{ Platform = 'macOS'; MdeSensorInstalledCount = 0 }
					[pscustomobject]@{ Platform = 'iOS/iPadOS'; MdeSensorInstalledCount = 0 }
					[pscustomobject]@{ Platform = 'Android'; MdeSensorInstalledCount = 0 }
					[pscustomobject]@{ Platform = 'Linux'; MdeSensorInstalledCount = 0 }
				)
			}
		}

		Add-ZtDeviceOverview -Database 'test'

		Should -Invoke Write-PSFMessage -Exactly 1 -ParameterFilter {
			$Level -eq 'Warning' -and $Message -like 'MDE sensor coverage is inconsistent for Windows:*'
		}
		Should -Invoke Write-PSFMessage -Exactly 0 -ParameterFilter {
			$Level -eq 'Warning' -and $Message -like 'MDE sensor coverage is inconsistent for macOS:*'
		}
	}

	It "Should sum Windows desktop devices across trust types and compliance, deriving unmanaged via subtraction" {
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'group by operatingSystem, trustType' } -MockWith {
			@(
				[pscustomobject]@{ operatingSystem = 'Windows'; trustType = 'AzureAd';   isCompliant = $true;  count = 83 }
				[pscustomobject]@{ operatingSystem = 'Windows'; trustType = 'AzureAd';   isCompliant = $false; count = 19 }
				[pscustomobject]@{ operatingSystem = 'Windows'; trustType = 'AzureAd';   isCompliant = $null;  count = 5 }
				[pscustomobject]@{ operatingSystem = 'Windows'; trustType = 'ServerAd';  isCompliant = $true;  count = 100 }
				[pscustomobject]@{ operatingSystem = 'Windows'; trustType = 'Workplace'; isCompliant = $false; count = 34 }
				[pscustomobject]@{ operatingSystem = 'MacMDM';  trustType = 'AzureAd';   isCompliant = $true;  count = 5 }
				[pscustomobject]@{ operatingSystem = 'MacMDM';  trustType = 'Workplace'; isCompliant = $true;  count = 3 }
			)
		}

		Add-ZtDeviceOverview -Database 'test'

		$script:tenantInfo.Name | Should -Be 'DeviceOverview'
		$nodes = $script:tenantInfo.Value.DesktopDevicesSummary.nodes

		($nodes | Where-Object { $_.source -eq 'Desktop devices' -and $_.target -eq 'Windows' }).value | Should -Be 241
		($nodes | Where-Object { $_.source -eq 'Desktop devices' -and $_.target -eq 'macOS' }).value | Should -Be 8

		($nodes | Where-Object { $_.source -eq 'Windows' -and $_.target -eq 'Entra joined' }).value | Should -Be 107
		($nodes | Where-Object { $_.source -eq 'Windows' -and $_.target -eq 'Entra hybrid joined' }).value | Should -Be 100
		($nodes | Where-Object { $_.source -eq 'Windows' -and $_.target -eq 'Entra registered' }).value | Should -Be 34

		($nodes | Where-Object { $_.source -eq 'Entra joined' -and $_.target -eq 'Compliant' }).value | Should -Be 83
		($nodes | Where-Object { $_.source -eq 'Entra joined' -and $_.target -eq 'Non-compliant' }).value | Should -Be 19
		# 107 total - (83 compliant + 19 non-compliant) = 5 with null compliance => Unmanaged
		($nodes | Where-Object { $_.source -eq 'Entra joined' -and $_.target -eq 'Unmanaged' }).value | Should -Be 5

		# macOS flows directly to compliance (no join-type split)
		($nodes | Where-Object { $_.source -eq 'macOS' -and $_.target -eq 'Compliant' }).value | Should -Be 8
		($nodes | Where-Object { $_.source -eq 'macOS' -and $_.target -eq 'Non-compliant' }) | Should -BeNullOrEmpty
		Assert-ValidSankeyLinks -Nodes $nodes -Because "desktop exports should never reintroduce malformed sankey links"
	}

	It "Should omit zero-value desktop sankey links while preserving real unmanaged paths" {
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'group by operatingSystem, trustType' } -MockWith {
			@(
				[pscustomobject]@{ operatingSystem = 'Windows'; trustType = 'AzureAd';   isCompliant = $null;  count = 2 }
				[pscustomobject]@{ operatingSystem = 'Windows'; trustType = 'Workplace'; isCompliant = $null;  count = 10 }
			)
		}

		Add-ZtDeviceOverview -Database 'test'

		$nodes = $script:tenantInfo.Value.DesktopDevicesSummary.nodes

		($nodes | Where-Object { $_.source -eq 'Desktop devices' -and $_.target -eq 'Windows' }).value | Should -Be 12
		($nodes | Where-Object { $_.source -eq 'Windows' -and $_.target -eq 'Entra joined' }).value | Should -Be 2
		($nodes | Where-Object { $_.source -eq 'Windows' -and $_.target -eq 'Entra registered' }).value | Should -Be 10
		($nodes | Where-Object { $_.source -eq 'Entra joined' -and $_.target -eq 'Unmanaged' }).value | Should -Be 2
		($nodes | Where-Object { $_.source -eq 'Entra registered' -and $_.target -eq 'Unmanaged' }).value | Should -Be 10

		($nodes | Where-Object { $_.target -eq 'macOS' }) | Should -BeNullOrEmpty
		($nodes | Where-Object { $_.target -eq 'Entra hybrid joined' }) | Should -BeNullOrEmpty
		($nodes | Where-Object { $_.target -eq 'Compliant' }) | Should -BeNullOrEmpty
		($nodes | Where-Object { $_.target -eq 'Non-compliant' }) | Should -BeNullOrEmpty
		Assert-ValidSankeyLinks -Nodes $nodes -Because "sparse desktop exports should stay safe for the sankey renderer"
	}

	It "Should collapse Android/iOS variants and split mobile devices by platform compliance" {
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'group by operatingSystem, isCompliant' } -MockWith {
			@(
				[pscustomobject]@{ operatingSystem = 'Android';           isCompliant = $true;  count = 10 }
				[pscustomobject]@{ operatingSystem = 'Android';           isCompliant = $false; count = 2 }
				[pscustomobject]@{ operatingSystem = 'AndroidEnterprise'; isCompliant = $true;  count = 3 }
				[pscustomobject]@{ operatingSystem = 'Android';           isCompliant = $null;  count = 7 }
				[pscustomobject]@{ operatingSystem = 'iOS';               isCompliant = $true;  count = 20 }
				[pscustomobject]@{ operatingSystem = 'IPhone';            isCompliant = $false; count = 1 }
				[pscustomobject]@{ operatingSystem = 'iPadOS';            isCompliant = $true;  count = 4 }
			)
		}

		Add-ZtDeviceOverview -Database 'test'

		$nodes = $script:tenantInfo.Value.MobileSummary.nodes

		($nodes | Where-Object { $_.source -eq 'Mobile devices' -and $_.target -eq 'Android' }).value | Should -Be 22
		($nodes | Where-Object { $_.source -eq 'Mobile devices' -and $_.target -eq 'iOS' }).value | Should -Be 25

		($nodes | Where-Object { $_.source -eq 'Android' -and $_.target -eq 'Compliant' }).value | Should -Be 13
		($nodes | Where-Object { $_.source -eq 'Android' -and $_.target -eq 'Non-compliant' }).value | Should -Be 9
		($nodes | Where-Object { $_.source -eq 'iOS' -and $_.target -eq 'Compliant' }).value | Should -Be 24
		($nodes | Where-Object { $_.source -eq 'iOS' -and $_.target -eq 'Non-compliant' }).value | Should -Be 1
		Assert-ValidSankeyLinks -Nodes $nodes -Because "mobile exports should never reintroduce malformed sankey links"
	}

	It "Should omit zero-value mobile sankey links while preserving real ownership paths" {
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'group by operatingSystem, isCompliant' } -MockWith {
			@(
				[pscustomobject]@{ operatingSystem = 'Android'; isCompliant = $true;  count = 4 }
				[pscustomobject]@{ operatingSystem = 'iOS';     isCompliant = $false; count = 3 }
			)
		}

		Add-ZtDeviceOverview -Database 'test'

		$nodes = $script:tenantInfo.Value.MobileSummary.nodes

		($nodes | Where-Object { $_.source -eq 'Mobile devices' -and $_.target -eq 'Android' }).value | Should -Be 4
		($nodes | Where-Object { $_.source -eq 'Mobile devices' -and $_.target -eq 'iOS' }).value | Should -Be 3
		($nodes | Where-Object { $_.source -eq 'Android' -and $_.target -eq 'Compliant' }).value | Should -Be 4
		($nodes | Where-Object { $_.source -eq 'Android' -and $_.target -eq 'Non-compliant' }) | Should -BeNullOrEmpty
		($nodes | Where-Object { $_.source -eq 'iOS' -and $_.target -eq 'Non-compliant' }).value | Should -Be 3
		($nodes | Where-Object { $_.source -eq 'iOS' -and $_.target -eq 'Compliant' }) | Should -BeNullOrEmpty
		Assert-ValidSankeyLinks -Nodes $nodes -Because "sparse mobile exports should stay safe for the sankey renderer"
	}

	It "Should report corporate and personal device ownership counts" {
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'group by deviceOwnership' } -MockWith {
			@(
				[pscustomobject]@{ deviceOwnership = 'Company';  count = 100 }
				[pscustomobject]@{ deviceOwnership = 'Personal'; count = 50 }
			)
		}

		Add-ZtDeviceOverview -Database 'test'

		$script:tenantInfo.Value.DeviceOwnership.corporateCount | Should -Be 100
		$script:tenantInfo.Value.DeviceOwnership.personalCount | Should -Be 50
	}

	It "Should omit empty desktop and mobile sankey links when device queries return no rows (issue 1310)" {
		# All queries fall through to the default empty mock from BeforeEach.
		Add-ZtDeviceOverview -Database 'test'

		$desktopNodes = $script:tenantInfo.Value.DesktopDevicesSummary.nodes
		$mobileNodes = $script:tenantInfo.Value.MobileSummary.nodes

		@($desktopNodes).Count | Should -Be 0
		@($mobileNodes).Count | Should -Be 0

		$script:tenantInfo.Value.ManagedDevices | Should -Not -BeNullOrEmpty
		$script:tenantInfo.Value.ManagedDevices.totalCount | Should -Be 0

		$script:tenantInfo.Value.DeviceOwnership.corporateCount | Should -Be 0
		$script:tenantInfo.Value.DeviceOwnership.personalCount | Should -Be 0
	}

	It "Should default compliance to 0 compliant and all discovered devices non-compliant when compliance rollups are empty" {
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'group by operatingSystem' -and $Sql -notmatch 'group by isCompliant' } -MockWith {
			@(
				[pscustomobject]@{ operatingSystem = 'MacMDM'; count = 2 }
				[pscustomobject]@{ operatingSystem = 'Windows'; count = 4 }
			)
		}
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'group by isCompliant' } -MockWith {
			@()
		}

		Add-ZtDeviceOverview -Database 'test'

		$script:tenantInfo.Value.ManagedDevices | Should -Not -BeNullOrEmpty
		$script:tenantInfo.Value.ManagedDevices.totalCount | Should -Be 0
		$script:tenantInfo.Value.DeviceCompliance.compliantDeviceCount | Should -Be 0
		$script:tenantInfo.Value.DeviceCompliance.nonCompliantDeviceCount | Should -Be 6
	}

	It "Should populate ManagedDevices from the Intune API when an Intune license is present" {
		Mock Get-ZtLicense { $true }
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'deviceManagement/managedDeviceOverview' } -MockWith {
			[pscustomobject]@{
				deviceOperatingSystemSummary = [pscustomobject]@{
					windowsCount = 10
					macOSCount   = 2
					iOSCount     = 5
					androidCount = 3
				}
			}
		}
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'deviceManagement/deviceCompliancePolicyDeviceStateSummary' } -MockWith {
			[pscustomobject]@{ compliantDeviceCount = 18; nonCompliantDeviceCount = 2 }
		}

		Add-ZtDeviceOverview -Database 'test'

		$managed = $script:tenantInfo.Value.ManagedDevices
		$managed.desktopCount | Should -Be 12
		$managed.mobileCount | Should -Be 8
		$managed.totalCount | Should -Be 20
	}

	It "Should fall back to database-derived managed devices when the Intune overview request fails" {
		Mock Get-ZtLicense { $true }
		Mock Invoke-ZtGraphRequest -ParameterFilter { $RelativeUri -eq 'deviceManagement/managedDeviceOverview' } -MockWith {
			throw 'Graph request failed'
		}
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'where accountEnabled and "isManaged"' } -MockWith {
			[pscustomobject]@{
				windowsCount = 4
				macOSCount = 1
				iOSCount = 2
				androidCount = 3
				linuxCount = 0
				totalCount = 10
			}
		}

		Add-ZtDeviceOverview -Database 'test'

		$script:tenantInfo.Name | Should -Be 'DeviceOverview'
		$managed = $script:tenantInfo.Value.ManagedDevices
		$managed.deviceOperatingSystemSummary.windowsCount | Should -Be 4
		$managed.deviceOperatingSystemSummary.macOSCount | Should -Be 1
		$managed.deviceOperatingSystemSummary.iosCount | Should -Be 2
		$managed.deviceOperatingSystemSummary.androidCount | Should -Be 3
		$managed.desktopCount | Should -Be 5
		$managed.mobileCount | Should -Be 5
		$managed.totalCount | Should -Be 10
	}
}
