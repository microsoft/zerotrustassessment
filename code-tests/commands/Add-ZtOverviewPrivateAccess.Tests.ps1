Describe "Add-ZtOverviewPrivateAccess" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        if (-not (Get-Command Add-ZtTenantInfo -ErrorAction SilentlyContinue)) { function Add-ZtTenantInfo { param($Name, $Value) } }

        . (Join-Path $srcRoot "private/tenantinfo/Add-ZtOverviewPrivateAccess.ps1")
    }

    BeforeEach {
        $script:tenantInfo = $null
        Mock Add-ZtTenantInfo {
            param($Name, $Value)
            $script:tenantInfo = [pscustomobject]@{ Name = $Name; Value = $Value }
        }
    }

    It "Builds the app funnel and separate administration band from child test data" {
        $testResults = @(
            [pscustomobject]@{ TestId = '25395'; TestData = @{ TotalApps = 3; Applications = @(
                [pscustomobject]@{ AppId = 'a'; Status = 'Pass' },
                [pscustomobject]@{ AppId = 'b'; Status = 'Fail' },
                [pscustomobject]@{ AppId = 'c'; Status = 'Manual Review' }) } },
            [pscustomobject]@{ TestId = '25396'; TestData = @{ TotalApps = 4; Applications = @(
                [pscustomobject]@{ AppId = 'a'; Status = 'Protected' },
                [pscustomobject]@{ AppId = 'b'; Status = 'Unprotected' },
                [pscustomobject]@{ AppId = 'c'; Status = 'Manual Review' },
                [pscustomobject]@{ AppId = 'd'; Status = 'Protected' }) } },
            [pscustomobject]@{ TestId = '25384'; TestData = @{ Assignments = @(
                [pscustomobject]@{ directoryScopeId = '/' },
                [pscustomobject]@{ directoryScopeId = '/servicePrincipals/a' }) } }
        )

        Add-ZtOverviewPrivateAccess -TestResults $testResults

        $script:tenantInfo.Name | Should -Be 'OverviewPrivateAccess'
    ($script:tenantInfo.Value.nodes | Where-Object { $_.source -eq 'Private Access apps' -and $_.target -eq 'Broad segments - at-risk' }).value | Should -Be 1
    ($script:tenantInfo.Value.nodes | Where-Object { $_.source -eq 'Least-privilege segments' -and $_.target -eq 'Strong auth - Zero Trust' }).value | Should -Be 1
        ($script:tenantInfo.Value.nodes | Where-Object { $_.source -eq 'Private Access apps' }).Count | Should -Be 3
    ($script:tenantInfo.Value.nodes | Where-Object { $_.source -eq 'Application Administrator assignments' -and $_.target -eq 'Tenant-wide admin - at-risk' }).value | Should -Be 1
        $script:tenantInfo.Value.adminAtRisk | Should -Be $true
        $script:tenantInfo.Value.populationMismatch | Should -Be $true
    }
}
