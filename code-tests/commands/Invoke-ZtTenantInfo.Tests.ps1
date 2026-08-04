Describe "Invoke-ZtTenantInfo" {

	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		if (-not (Get-Command Add-ZtTenantOverview -ErrorAction SilentlyContinue)) {
			function global:Add-ZtTenantOverview {
				param()
			}
		}

		if (-not (Get-Command Add-ZtAgentOverview -ErrorAction SilentlyContinue)) {
			function global:Add-ZtAgentOverview {
				param()
			}
		}

		if (-not (Get-Command Add-ZtAgentOwnershipDistribution -ErrorAction SilentlyContinue)) {
			function global:Add-ZtAgentOwnershipDistribution {
				param($Database)
			}
		}

		if (-not (Get-Command Add-ZtOverviewCaMfa -ErrorAction SilentlyContinue)) {
			function global:Add-ZtOverviewCaMfa {
				param($Database)
			}
		}

		if (-not (Get-Command Add-ZtOverviewCaDevicesAllUsers -ErrorAction SilentlyContinue)) {
			function global:Add-ZtOverviewCaDevicesAllUsers {
				param($Database)
			}
		}

		if (-not (Get-Command Add-ZtOverviewAuthMethodsAllUsers -ErrorAction SilentlyContinue)) {
			function global:Add-ZtOverviewAuthMethodsAllUsers {
				param($Database)
			}
		}

		if (-not (Get-Command Add-ZtOverviewAuthMethodsPrivilegedUsers -ErrorAction SilentlyContinue)) {
			function global:Add-ZtOverviewAuthMethodsPrivilegedUsers {
				param($Database)
			}
		}

		if (-not (Get-Command Get-ZtLicenseInformation -ErrorAction SilentlyContinue)) {
			function global:Get-ZtLicenseInformation {
				param($Product)
			}
		}

		if (-not (Get-Command Add-ZtDeviceOverview -ErrorAction SilentlyContinue)) {
			function global:Add-ZtDeviceOverview {
				param($Database)
			}
		}

		if (-not (Get-Command Add-ZtDeviceWindowsEnrollment -ErrorAction SilentlyContinue)) {
			function global:Add-ZtDeviceWindowsEnrollment {
				param()
			}
		}

		if (-not (Get-Command Add-ZtDeviceEnrollmentRestriction -ErrorAction SilentlyContinue)) {
			function global:Add-ZtDeviceEnrollmentRestriction {
				param()
			}
		}

		if (-not (Get-Command Add-ZTDeviceCompliancePolicies -ErrorAction SilentlyContinue)) {
			function global:Add-ZTDeviceCompliancePolicies {
				param()
			}
		}

		if (-not (Get-Command Add-ZTDeviceAppProtectionPolicies -ErrorAction SilentlyContinue)) {
			function global:Add-ZTDeviceAppProtectionPolicies {
				param()
			}
		}

		. (Join-Path $srcRoot "private/tenantinfo/Invoke-ZtTenantInfo.ps1")
	}

	BeforeEach {
		Mock Add-ZtTenantOverview {}
		Mock Add-ZtAgentOverview {}
		Mock Add-ZtAgentOwnershipDistribution {}
		Mock Add-ZtOverviewCaMfa {}
		Mock Add-ZtOverviewCaDevicesAllUsers {}
		Mock Add-ZtOverviewAuthMethodsAllUsers {}
		Mock Add-ZtOverviewAuthMethodsPrivilegedUsers {}
		Mock Get-ZtLicenseInformation { $null }
		Mock Add-ZtDeviceOverview {}
		Mock Add-ZtDeviceWindowsEnrollment {}
		Mock Add-ZtDeviceEnrollmentRestriction {}
		Mock Add-ZTDeviceCompliancePolicies {}
		Mock Add-ZTDeviceAppProtectionPolicies {}
	}

	It "Should call Add-ZtDeviceOverview even when Intune is unavailable" {
		Invoke-ZtTenantInfo -Database 'test' -Pillar 'Devices'

		Should -Invoke Add-ZtDeviceOverview -Times 1 -Exactly
		Should -Invoke Add-ZtDeviceWindowsEnrollment -Times 0 -Exactly
		Should -Invoke Add-ZtDeviceEnrollmentRestriction -Times 0 -Exactly
		Should -Invoke Add-ZTDeviceCompliancePolicies -Times 0 -Exactly
		Should -Invoke Add-ZTDeviceAppProtectionPolicies -Times 0 -Exactly
	}

	It "Should collect agent ownership distribution for AI assessments" {
		Invoke-ZtTenantInfo -Database 'test' -Pillar 'AI'

		Should -Invoke Add-ZtAgentOwnershipDistribution -Times 1 -Exactly -ParameterFilter {
			$Database -eq 'test'
		}
	}

	It "Should not collect agent ownership distribution for unrelated pillar-only assessments" {
		Invoke-ZtTenantInfo -Database 'test' -Pillar 'Devices'

		Should -Invoke Add-ZtAgentOwnershipDistribution -Times 0 -Exactly
	}
}
