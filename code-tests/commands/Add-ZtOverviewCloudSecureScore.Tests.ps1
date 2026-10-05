Describe 'Add-ZtOverviewCloudSecureScore' {
    BeforeAll {
        if (-not (Get-Command Invoke-ZtAzureResourceGraphRequest -ErrorAction SilentlyContinue)) {
            function global:Invoke-ZtAzureResourceGraphRequest {
                param($Query, $SubscriptionId)
            }
        }
        if (-not (Get-Command Add-ZtTenantInfo -ErrorAction SilentlyContinue)) {
            function global:Add-ZtTenantInfo {
                param($Name, $Value)
            }
        }
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function global:Write-PSFMessage {}
        }

        . (Join-Path $PSScriptRoot '../../src/powershell/private/tenantinfo/Add-ZtOverviewCloudSecureScore.ps1')
    }

    BeforeEach {
        $script:query = $null
        $script:score = $null
        Mock Invoke-ZtAzureResourceGraphRequest {
            $script:query = $Query
            @()
        }
        Mock Add-ZtTenantInfo {
            $script:score = $Value
        }
    }

    It 'Keeps fractional source scores until the weighted average crosses the display boundary' {
        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        $weightedPercentage = ([decimal]50.49 * 4 + [decimal]51.49) / 5
        $weightedPercentage | Should -Be ([decimal]50.69)
        [math]::Round($weightedPercentage, 0, [MidpointRounding]::AwayFromZero) | Should -Be 51
        ([regex]::Matches($script:query, 'percentage=todecimal\(properties\.score\.percentage\)\*100')).Count | Should -Be 2
        ([regex]::Matches($script:query, 'percentage=round\(weightedSum/totalWeight\)')).Count | Should -Be 2
        $script:query | Should -Not -Match 'percentage=round\(todecimal'
    }

    It 'Omits incomplete or zero-weight aggregates rather than publishing an artificial zero' {
        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        ([regex]::Matches($script:query, 'invalidCount=countif\(isnull\(percentage\).*isnull\(weight\) or weight <= 0\)')).Count | Should -Be 2
        ([regex]::Matches($script:query, 'invalidCount == 0 and totalWeight > 0')).Count | Should -Be 2
        $script:query | Should -Not -Match '0\.00, percentage'
        $script:score | Should -BeNullOrEmpty
    }

    It 'Includes every scored recommendation environment in both branches' {
        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        ([regex]::Matches($script:query, '"DockerHub", "JFrog"')).Count | Should -Be 4
    }
}
