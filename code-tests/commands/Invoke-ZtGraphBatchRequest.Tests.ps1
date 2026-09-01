Describe 'Invoke-ZtGraphBatchRequest' {
    BeforeAll {
        $srcRoot = Join-Path $PSScriptRoot '../../src/powershell'
        if (-not (Get-Module ZeroTrustAssessment -ErrorAction SilentlyContinue)) {
            Import-Module (Join-Path $srcRoot 'ZeroTrustAssessment.psd1') -Global 3>$null
            Import-Module (Join-Path $srcRoot 'ZeroTrustAssessment.psm1') -Global -Force 3>$null
        }
    }

    Context 'When a matched batch response has one page' {
        BeforeEach {
            Mock -ModuleName ZeroTrustAssessment 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
                return @{
                    responses = @(
                        @{
                            id = '1'
                            status = 200
                            headers = @{}
                            body = @{ value = @(@{ id = 'owner-1' }, @{ id = 'owner-2' }) }
                        }
                    )
                }
            }
        }

        It 'returns the first page as an array' {
            $argument = @{ id = 'sp-1' }

            $result = Invoke-ZtGraphBatchRequest `
                -Path 'servicePrincipals/{0}/owners' `
                -ArgumentList @($argument) `
                -Properties id `
                -Matched

            $result.Success | Should -BeTrue
            $result.Argument.id | Should -Be $argument.id
            $result.Result.GetType() | Should -Be ([object[]])
            @($result.Result.id) | Should -Be @('owner-1', 'owner-2')
            Should -Invoke -ModuleName ZeroTrustAssessment 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 1 -Exactly
        }
    }

    Context 'When a matched batch response is paginated' {
        BeforeEach {
            $script:batchCall = 0
            Mock -ModuleName ZeroTrustAssessment 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' {
                $script:batchCall++
                if ($script:batchCall -eq 1) {
                    return @{
                        responses = @(
                            @{
                                id = '1'
                                status = 200
                                headers = @{}
                                body = @{
                                    value = @(@{ id = 'owner-1' }, @{ id = 'owner-2' })
                                    '@odata.nextLink' = 'https://graph.microsoft.com/v1.0/servicePrincipals/sp-1/owners?$skiptoken=next'
                                }
                            }
                        )
                    }
                }

                return @{
                    responses = @(
                        @{
                            id = '1'
                            status = 200
                            headers = @{}
                            body = @{ value = @(@{ id = 'owner-3' }) }
                        }
                    )
                }
            }
        }

        It 'returns all pages in order as an array' {
            $argument = @{ id = 'sp-1' }

            $result = Invoke-ZtGraphBatchRequest `
                -Path 'servicePrincipals/{0}/owners' `
                -ArgumentList @($argument) `
                -Properties id `
                -Matched

            $result.Success | Should -BeTrue
            $result.Argument.id | Should -Be $argument.id
            $result.Result.GetType() | Should -Be ([object[]])
            @($result.Result.id) | Should -Be @('owner-1', 'owner-2', 'owner-3')
            Should -Invoke -ModuleName ZeroTrustAssessment 'Microsoft.Graph.Authentication\Invoke-MgGraphRequest' -Times 2 -Exactly
        }
    }
}