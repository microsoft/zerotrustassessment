<#
.SYNOPSIS
    Adds DLP policy coverage by workload to the tenant overview data.
#>

function Add-ZtDlpWorkloadCoverage {
    [CmdletBinding()]
    param()

    $tenantInfoName = 'DlpWorkloadCoverage'
    $activity = 'Collecting DLP workload coverage'
    Write-ZtProgress -Activity $activity -Status 'Getting DLP policies'

    try {
        if (-not (Get-Command Get-DlpCompliancePolicy -ErrorAction SilentlyContinue)) {
            throw 'Get-DlpCompliancePolicy is unavailable.'
        }

        # Q1: One collection supplies all workload counts.
        $policies = @(Get-DlpCompliancePolicy -ErrorAction Stop)
        $includedModes = @('Enable', 'TestWithNotifications', 'TestWithoutNotifications')
        $activePolicies = @($policies | Where-Object { [string]$_.Mode -in $includedModes })

        $requiredProperties = @(
            'Mode',
            'ExchangeLocation', 'ExchangeAdaptiveScopes',
            'SharePointLocation', 'SharePointAdaptiveScopes',
            'OneDriveLocation', 'OneDriveAdaptiveScopes',
            'TeamsLocation', 'TeamsAdaptiveScopes',
            'EndpointDlpLocation', 'EndpointDlpAdaptiveScopes',
            'Locations', 'EnforcementPlanes'
        )

        foreach ($policy in $policies) {
            $missingProperties = @($requiredProperties | Where-Object {
                $policy.PSObject.Properties.Name -notcontains $_
            })
            if ($missingProperties.Count -gt 0) {
                throw "Required DLP policy properties are unavailable: $($missingProperties -join ', ')."
            }
        }

        $workloadMappings = @(
            @{ Name = 'exchangePolicyCount'; Location = 'ExchangeLocation'; Adaptive = 'ExchangeAdaptiveScopes' }
            @{ Name = 'sharePointPolicyCount'; Location = 'SharePointLocation'; Adaptive = 'SharePointAdaptiveScopes' }
            @{ Name = 'oneDrivePolicyCount'; Location = 'OneDriveLocation'; Adaptive = 'OneDriveAdaptiveScopes' }
            @{ Name = 'teamsPolicyCount'; Location = 'TeamsLocation'; Adaptive = 'TeamsAdaptiveScopes' }
            @{ Name = 'endpointPolicyCount'; Location = 'EndpointDlpLocation'; Adaptive = 'EndpointDlpAdaptiveScopes' }
        )

        $coverage = [ordered]@{}
        foreach ($mapping in $workloadMappings) {
            $coverage[$mapping.Name] = @($activePolicies | Where-Object {
                $locationValues = @($_.($mapping.Location) | Where-Object {
                    -not [string]::IsNullOrWhiteSpace([string]$_)
                })
                $adaptiveScopeValues = @($_.($mapping.Adaptive) | Where-Object {
                    -not [string]::IsNullOrWhiteSpace([string]$_)
                })
                $locationValues.Count -gt 0 -or $adaptiveScopeValues.Count -gt 0
            }).Count
        }

        # Custom and default Copilot policies can serialize the same location as a GUID or Copilot.M365.
        $copilotLocationIdentifiers = @('470f2276-e011-4e9d-a6ec-20768be3a4b0', 'Copilot.M365')
        $copilotPolicyCount = 0
        foreach ($policy in $activePolicies) {
            $serializedLocations = [string]$policy.Locations
            if ([string]::IsNullOrWhiteSpace($serializedLocations)) {
                continue
            }

            $locations = @($serializedLocations | ConvertFrom-Json -ErrorAction Stop)
            if ($policy.EnforcementPlanes -contains 'CopilotExperiences' -and @($locations | Where-Object {
                $_.Workload -ieq 'Applications' -and
                $_.Location -in $copilotLocationIdentifiers
            }).Count -gt 0) {
                $copilotPolicyCount++
            }
        }

        $coverage.copilotPolicyCount = $copilotPolicyCount
        $coverage.coveredWorkloadCount = @($coverage.Values | Where-Object { $_ -gt 0 }).Count

        Add-ZtTenantInfo -Name $tenantInfoName -Value ([PSCustomObject]$coverage)
    }
    catch {
        Write-PSFMessage "Failed to collect DLP workload coverage: $_" -Tag TenantInfo -Level Warning
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
    }
}
