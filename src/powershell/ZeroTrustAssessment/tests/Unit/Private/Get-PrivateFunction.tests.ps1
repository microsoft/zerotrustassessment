BeforeAll {
    $script:dscModuleName = 'ZeroTrustAssessment'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe Get-PrivateFunction {
    Context 'When calling the function with string value' {
        It 'Should return a single object' {
            InModuleScope -ModuleName $dscModuleName {
                $return = Get-PrivateFunction -PrivateData 'string'

                ($return | Measure-Object).Count | Should -Be 1
            }
        }

        It 'Should return a string based on the parameter PrivateData' {
            InModuleScope -ModuleName $dscModuleName {
                $return = Get-PrivateFunction -PrivateData 'string'

                $return | Should -Be 'string'
            }
        }
    }
}

