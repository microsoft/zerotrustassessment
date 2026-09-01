Describe "Add-ZtDlpWorkloadCoverage" {

	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

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

		if (-not (Get-Command Get-DlpCompliancePolicy -ErrorAction SilentlyContinue)) {
			function global:Get-DlpCompliancePolicy {
				param()
			}
		}

		. (Join-Path $srcRoot "private/tenantinfo/Add-ZtDlpWorkloadCoverage.ps1")
	}

	BeforeEach {
		$script:tenantInfo = 'not-set'
		Mock Write-ZtProgress {}
		Mock Write-PSFMessage {}
		Mock Add-ZtTenantInfo { $script:tenantInfo = $Value }
		Mock Get-DlpCompliancePolicy { @() }
	}

	It "Counts active and simulation policies once for every targeted workload" {
		Mock Get-DlpCompliancePolicy {
			@(
				[PSCustomObject]@{
					Mode = 'Enable'
					ExchangeLocation = @('All'); ExchangeAdaptiveScopes = @()
					SharePointLocation = @('All'); SharePointAdaptiveScopes = @()
					OneDriveLocation = @(); OneDriveAdaptiveScopes = @()
					TeamsLocation = @(); TeamsAdaptiveScopes = @('Scope 1')
					EndpointDlpLocation = @(); EndpointDlpAdaptiveScopes = @()
					Locations = '[]'; EnforcementPlanes = @()
				},
				[PSCustomObject]@{
					Mode = 'TestWithoutNotifications'
					ExchangeLocation = @(); ExchangeAdaptiveScopes = @()
					SharePointLocation = @(); SharePointAdaptiveScopes = @()
					OneDriveLocation = @(); OneDriveAdaptiveScopes = @()
					TeamsLocation = @(); TeamsAdaptiveScopes = @()
					EndpointDlpLocation = @('All'); EndpointDlpAdaptiveScopes = @()
					Locations = '[{"Workload":"Applications","Location":"Copilot.M365"}]'
					EnforcementPlanes = @('CopilotExperiences')
				},
				[PSCustomObject]@{
					Mode = 'Disable'
					ExchangeLocation = @('All'); ExchangeAdaptiveScopes = @()
					SharePointLocation = @(); SharePointAdaptiveScopes = @()
					OneDriveLocation = @('All'); OneDriveAdaptiveScopes = @()
					TeamsLocation = @(); TeamsAdaptiveScopes = @()
					EndpointDlpLocation = @(); EndpointDlpAdaptiveScopes = @()
					Locations = '[]'; EnforcementPlanes = @()
				}
			)
		}

		Add-ZtDlpWorkloadCoverage

		$script:tenantInfo.exchangePolicyCount | Should -Be 1
		$script:tenantInfo.sharePointPolicyCount | Should -Be 1
		$script:tenantInfo.oneDrivePolicyCount | Should -Be 0
		$script:tenantInfo.teamsPolicyCount | Should -Be 1
		$script:tenantInfo.endpointPolicyCount | Should -Be 1
		$script:tenantInfo.copilotPolicyCount | Should -Be 1
		$script:tenantInfo.coveredWorkloadCount | Should -Be 5
	}

	It "Recognizes the documented Copilot location GUID" {
		Mock Get-DlpCompliancePolicy {
			[PSCustomObject]@{
				Mode = 'Enable'
				ExchangeLocation = @(); ExchangeAdaptiveScopes = @()
				SharePointLocation = @(); SharePointAdaptiveScopes = @()
				OneDriveLocation = @(); OneDriveAdaptiveScopes = @()
				TeamsLocation = @(); TeamsAdaptiveScopes = @()
				EndpointDlpLocation = @(); EndpointDlpAdaptiveScopes = @()
				Locations = '[{"Workload":"Applications","Location":"470f2276-e011-4e9d-a6ec-20768be3a4b0"}]'
				EnforcementPlanes = @('CopilotExperiences')
			}
		}

		Add-ZtDlpWorkloadCoverage

		$script:tenantInfo.copilotPolicyCount | Should -Be 1
		$script:tenantInfo.coveredWorkloadCount | Should -Be 1
	}

	It "Publishes six zero counts when the query succeeds with no policies" {
		Add-ZtDlpWorkloadCoverage

		$script:tenantInfo.exchangePolicyCount | Should -Be 0
		$script:tenantInfo.sharePointPolicyCount | Should -Be 0
		$script:tenantInfo.oneDrivePolicyCount | Should -Be 0
		$script:tenantInfo.teamsPolicyCount | Should -Be 0
		$script:tenantInfo.endpointPolicyCount | Should -Be 0
		$script:tenantInfo.copilotPolicyCount | Should -Be 0
		$script:tenantInfo.coveredWorkloadCount | Should -Be 0
	}

	It "Publishes no data when a Copilot locations payload is malformed" {
		Mock Get-DlpCompliancePolicy {
			[PSCustomObject]@{
				Mode = 'Enable'
				ExchangeLocation = @(); ExchangeAdaptiveScopes = @()
				SharePointLocation = @(); SharePointAdaptiveScopes = @()
				OneDriveLocation = @(); OneDriveAdaptiveScopes = @()
				TeamsLocation = @(); TeamsAdaptiveScopes = @()
				EndpointDlpLocation = @(); EndpointDlpAdaptiveScopes = @()
				Locations = '{invalid'; EnforcementPlanes = @('CopilotExperiences')
			}
		}

		Add-ZtDlpWorkloadCoverage

		$script:tenantInfo | Should -BeNullOrEmpty
	}
}
