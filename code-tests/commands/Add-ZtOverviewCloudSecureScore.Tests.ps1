Describe 'Add-ZtOverviewCloudSecureScore' {
    BeforeAll {
        $script:createdAzureResourceGraphRequest = $false
        $script:createdTenantInfo = $false
        $script:createdPsfMessage = $false

        if (-not (Get-Command Invoke-ZtAzureResourceGraphRequest -ListImported -ErrorAction SilentlyContinue)) {
            function script:Invoke-ZtAzureResourceGraphRequest {
                param($Query, $SubscriptionId)
            }
            $script:createdAzureResourceGraphRequest = $true
        }
        if (-not (Get-Command Add-ZtTenantInfo -ListImported -ErrorAction SilentlyContinue)) {
            function script:Add-ZtTenantInfo {
                param($Name, $Value)
            }
            $script:createdTenantInfo = $true
        }
        if (-not (Get-Command Write-PSFMessage -ListImported -ErrorAction SilentlyContinue)) {
            function script:Write-PSFMessage {}
            $script:createdPsfMessage = $true
        }

        . (Join-Path $PSScriptRoot '../../src/powershell/private/tenantinfo/Add-ZtOverviewCloudSecureScore.ps1')
    }

    AfterAll {
        if ($script:createdAzureResourceGraphRequest) {
            Remove-Item function:script:Invoke-ZtAzureResourceGraphRequest
        }
        if ($script:createdTenantInfo) {
            Remove-Item function:script:Add-ZtTenantInfo
        }
        if ($script:createdPsfMessage) {
            Remove-Item function:script:Write-PSFMessage
        }
    }

    BeforeEach {
        $script:query = $null
        $script:subscriptionIds = $null
        $script:response = @()
        $script:tenantInfoAdded = $false
        $script:tenantInfoName = $null
        $script:score = 'not set'

        Mock Invoke-ZtAzureResourceGraphRequest {
            $script:query = $Query
            $script:subscriptionIds = $SubscriptionId
            $script:response
        }
        Mock Add-ZtTenantInfo {
            $script:tenantInfoAdded = $true
            $script:tenantInfoName = $Name
            $script:score = $Value
        }
        Mock Write-PSFMessage {}
    }

    It 'Builds both query branches with fractional source percentages and final aggregate rounding' {
        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        ([regex]::Matches($script:query, 'percentage=todecimal\(properties\.score\.percentage\)\*100')).Count | Should -Be 2
        ([regex]::Matches($script:query, 'subTotal = weight\*percentage')).Count | Should -Be 2
        ([regex]::Matches($script:query, 'weightedSum=sum\(subTotal\), totalWeight=sum\(weight\)')).Count | Should -Be 2
        ([regex]::Matches($script:query, 'percentage=round\(weightedSum/totalWeight\)')).Count | Should -Be 2
        $script:query | Should -Not -Match 'percentage=round\(todecimal'
    }

    It 'Builds both query branches to allow zero weights and reject invalid or nonpositive-total aggregates' {
        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        ([regex]::Matches($script:query, 'invalidCount=countif\(isnull\(percentage\) or percentage < 0 or percentage > 100 or isnull\(weight\)\)')).Count | Should -Be 2
        ([regex]::Matches($script:query, '\| where invalidCount == 0 and totalWeight > 0')).Count | Should -Be 2
        $script:query | Should -Not -Match 'weight <= 0'
    }

    It 'Stores one secure score as an array' {
        $expectedScore = [pscustomobject]@{ percentage = 75; environment = 'Azure'; current = 15; max = 20 }
        $script:response = @([pscustomobject]@{ secureScore = @($expectedScore) })

        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        $script:tenantInfoAdded | Should -BeTrue
        $script:tenantInfoName | Should -Be 'OverviewCloudSecureScore'
        $script:score.GetType().FullName | Should -Be 'System.Object[]'
        $script:score | Should -HaveCount 1
        $script:score[0] | Should -Be $expectedScore
    }

    It 'Stores several secure scores as an array' {
        $firstScore = [pscustomobject]@{ percentage = 75; environment = 'Azure' }
        $secondScore = [pscustomobject]@{ percentage = 50; environment = 'AWS' }
        $script:response = @([pscustomobject]@{ secureScore = @($firstScore, $secondScore) })

        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        $script:score.GetType().FullName | Should -Be 'System.Object[]'
        $script:score | Should -HaveCount 2
        $script:score[0] | Should -Be $firstScore
        $script:score[1] | Should -Be $secondScore
    }

    It 'Preserves a measured zero percent secure score' {
        $script:response = @([pscustomobject]@{
                secureScore = @([pscustomobject]@{ percentage = 0; environment = 'Azure'; current = 0; max = 20 })
            })

        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        $script:tenantInfoAdded | Should -BeTrue
        $script:score.GetType().FullName | Should -Be 'System.Object[]'
        $script:score | Should -HaveCount 1
        $script:score[0].percentage | Should -Be 0
    }

    It 'Stores null for an empty Azure Resource Graph response' {
        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        $script:tenantInfoAdded | Should -BeTrue
        ($null -eq $script:score) | Should -BeTrue
    }

    It 'Stores null for a response row containing an empty secure score list' {
        $script:response = @([pscustomobject]@{ secureScore = @() })

        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        $script:tenantInfoAdded | Should -BeTrue
        $script:tenantInfoName | Should -Be 'OverviewCloudSecureScore'
        ($null -eq $script:score) | Should -BeTrue
    }

    It 'Stores null for a response row containing a null secure score property' {
        $script:response = @([pscustomobject]@{ secureScore = $null })

        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        $script:tenantInfoAdded | Should -BeTrue
        $script:tenantInfoName | Should -Be 'OverviewCloudSecureScore'
        ($null -eq $script:score) | Should -BeTrue
    }

    It 'Warns and stores null when the Azure Resource Graph request fails' {
        Mock Invoke-ZtAzureResourceGraphRequest { throw 'Azure Resource Graph is unavailable' }

        { Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1' } | Should -Not -Throw

        Should -Invoke Write-PSFMessage -Times 1 -Exactly -ParameterFilter {
            $Level -eq 'Warning' -and $Message -eq 'Cloud secure score collection failed; the score will be unavailable.'
        }
        $script:tenantInfoAdded | Should -BeTrue
        ($null -eq $script:score) | Should -BeTrue
    }

    It 'Passes supplied subscription IDs to Azure Resource Graph unchanged' {
        $subscriptionIds = @('subscription-1', 'subscription-2')

        Add-ZtOverviewCloudSecureScore -SubscriptionId $subscriptionIds

        $script:subscriptionIds | Should -HaveCount 2
        $script:subscriptionIds[0] | Should -Be 'subscription-1'
        $script:subscriptionIds[1] | Should -Be 'subscription-2'
    }

    It 'Includes every scored recommendation environment in both branches' {
        Add-ZtOverviewCloudSecureScore -SubscriptionId 'subscription-1'

        ([regex]::Matches($script:query, '"DockerHub", "JFrog"')).Count | Should -Be 4
    }
}
