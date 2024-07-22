BeforeAll {
    $script:dscModuleName = 'ZeroTrustAssessment'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe Invoke-ZeroTrustAssessment {

    Context 'Return values' {
        BeforeEach {
            $return = Invoke-ZeroTrustAssessment -Data 'value'
        }

        It 'Returns a single object' {
            ($return | Measure-Object).Count | Should -Be 1
        }

    }

    Context 'Pipeline' {
        It 'Accepts values from the pipeline by value' {
            $return = 'value1', 'value2' | Invoke-ZeroTrustAssessment

            $return[0] | Should -Be 'value1'
            $return[1] | Should -Be 'value2'
        }

        It 'Accepts value from the pipeline by property name' {
            $return = 'value1', 'value2' | ForEach-Object {
                [PSCustomObject]@{
                    Data = $_
                    OtherProperty = 'other'
                }
            } | Invoke-ZeroTrustAssessment


            $return[0] | Should -Be 'value1'
            $return[1] | Should -Be 'value2'
        }
    }

    Context 'ShouldProcess' {
        It 'Supports WhatIf' {
            (Get-Command Invoke-ZeroTrustAssessment).Parameters.ContainsKey('WhatIf') | Should -Be $true
            { Invoke-ZeroTrustAssessment -Data 'value' -WhatIf } | Should -Not -Throw
        }


    }
}
