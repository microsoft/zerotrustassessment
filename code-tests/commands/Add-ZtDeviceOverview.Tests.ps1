Describe "Add-ZtDeviceOverview" {
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

		if (-not (Get-Command Get-ZtLicense -ErrorAction SilentlyContinue)) {
			function global:Get-ZtLicense {
				param([Parameter(ValueFromRemainingArguments)] $Args)
			}
		}

		if (-not (Get-Command Invoke-ZtGraphRequest -ErrorAction SilentlyContinue)) {
			function global:Invoke-ZtGraphRequest {
				param($RelativeUri, $ApiVersion)
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
		($nodes | Where-Object { $_.source -eq 'macOS' -and $_.target -eq 'Non-compliant' }).value | Should -Be 0
	}

	It "Should collapse Android/iOS variants and split mobile devices by ownership and compliance" {
		Mock Invoke-DatabaseQuery -ParameterFilter { $Sql -match 'group by operatingSystem, deviceOwnership' } -MockWith {
			@(
				[pscustomobject]@{ operatingSystem = 'Android';           deviceOwnership = 'Company';  isCompliant = $true;  count = 10 }
				[pscustomobject]@{ operatingSystem = 'Android';           deviceOwnership = 'Company';  isCompliant = $false; count = 2 }
				[pscustomobject]@{ operatingSystem = 'AndroidEnterprise'; deviceOwnership = 'Company';  isCompliant = $true;  count = 3 }
				[pscustomobject]@{ operatingSystem = 'Android';           deviceOwnership = 'Personal'; isCompliant = $true;  count = 7 }
				[pscustomobject]@{ operatingSystem = 'iOS';               deviceOwnership = 'Company';  isCompliant = $true;  count = 20 }
				[pscustomobject]@{ operatingSystem = 'IPhone';            deviceOwnership = 'Company';  isCompliant = $false; count = 1 }
				[pscustomobject]@{ operatingSystem = 'iOS';               deviceOwnership = 'Personal'; isCompliant = $true;  count = 4 }
			)
		}

		Add-ZtDeviceOverview -Database 'test'

		$nodes = $script:tenantInfo.Value.MobileSummary.nodes

		($nodes | Where-Object { $_.source -eq 'Mobile devices' -and $_.target -eq 'Android' }).value | Should -Be 22
		($nodes | Where-Object { $_.source -eq 'Mobile devices' -and $_.target -eq 'iOS' }).value | Should -Be 25

		# Android variants (Android + AndroidEnterprise) collapse into "Android"
		($nodes | Where-Object { $_.source -eq 'Android' -and $_.target -eq 'Android (Company)' }).value | Should -Be 15
		($nodes | Where-Object { $_.source -eq 'Android' -and $_.target -eq 'Android (Personal)' }).value | Should -Be 7
		($nodes | Where-Object { $_.source -eq 'Android (Company)' -and $_.target -eq 'Compliant' }).value | Should -Be 13
		($nodes | Where-Object { $_.source -eq 'Android (Company)' -and $_.target -eq 'Non-compliant' }).value | Should -Be 2

		# iOS + IPhone collapse into "iOS"
		($nodes | Where-Object { $_.source -eq 'iOS' -and $_.target -eq 'iOS (Company)' }).value | Should -Be 21
		($nodes | Where-Object { $_.source -eq 'iOS (Company)' -and $_.target -eq 'Compliant' }).value | Should -Be 20
		($nodes | Where-Object { $_.source -eq 'iOS (Company)' -and $_.target -eq 'Non-compliant' }).value | Should -Be 1
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

	It "Should emit zero (never null) for every Sankey value when device queries return no rows (issue 1310)" {
		# All queries fall through to the default empty mock from BeforeEach.
		Add-ZtDeviceOverview -Database 'test'

		$desktopNodes = $script:tenantInfo.Value.DesktopDevicesSummary.nodes
		$mobileNodes = $script:tenantInfo.Value.MobileSummary.nodes

		foreach ($node in @($desktopNodes) + @($mobileNodes)) {
			$node.value | Should -Not -BeNullOrEmpty -Because "Sankey link $($node.source) -> $($node.target) must have a numeric value"
			$node.value | Should -BeGreaterOrEqual 0
		}

		$script:tenantInfo.Value.DeviceOwnership.corporateCount | Should -Be 0
		$script:tenantInfo.Value.DeviceOwnership.personalCount | Should -Be 0
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
}
