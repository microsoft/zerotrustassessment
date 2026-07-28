Describe "Add-ZtTestResultDetail" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        function global:Get-ZtTestStatus {
            param()
        }

        function global:Write-ZtProgress {
            param()
        }

        function global:Write-PSFMessage {
            param()
        }

        . (Join-Path $srcRoot "private/core/Add-ZtTestResultDetail.ps1")
    }

    BeforeEach {
        $script:__ZtSession = [pscustomobject]@{
            TestResultDetail = [pscustomobject]@{ Value = @{} }
        }

        Mock Get-ZtTest { [pscustomobject]@{ TestId = '27021'; Title = 'Test title'; Pillar = 'Network'; MinimumLicense = @(); CompatibleLicense = @(); SfiPillar = 'Protect networks' } }
        Mock Get-ZtTestStatus { 'Passed' }
        Mock Write-ZtProgress {}
        Mock Write-PSFMessage {}
    }

    It "Retains optional structured result data for report visualizations" {
        $resultData = @{
            Applications = @([pscustomobject]@{ AppId = 'app-1'; Status = 'Pass' })
        }

        Add-ZtTestResultDetail -TestId '27021' -Title 'Test title' -Description 'Description' -Status $true -Result 'Result' -ResultData $resultData

        $script:__ZtSession.TestResultDetail.Value['27021'].TestData.Applications[0].AppId | Should -Be 'app-1'
        $script:__ZtSession.TestResultDetail.Value['27021'].TestData.Applications[0].Status | Should -Be 'Pass'
    }
}
