Describe "Export-ZtGraphEntity" {
    # Regression tests for the Add-GraphProperty guard:
    #
    #   Fix: Guard in Add-GraphProperty skips the batch call when Graph returns an empty page.
    #     if (-not $Results) { return }
    #
    #   Without this guard, passing @() to Invoke-ZtGraphBatchRequest -ArgumentList caused:
    #     "Cannot bind argument to parameter 'ArgumentList' because it is an empty array."

    BeforeAll {
        $srcRoot = Join-Path $PSScriptRoot "../../src/powershell"
        if (-not (Get-Module ZeroTrustAssessment -ErrorAction SilentlyContinue)) {
            Import-Module (Join-Path $srcRoot "ZeroTrustAssessment.psd1") -Global 3>$null
            Import-Module (Join-Path $srcRoot "ZeroTrustAssessment.psm1") -Global -Force 3>$null
        }
        if (-not (Get-Command Get-MgContext -ErrorAction SilentlyContinue)) {
            function global:Get-MgContext {}
        }
    }

    Context "Add-GraphProperty — guard skips batch when page is empty" {
        BeforeAll {
            $script:exportPath = Join-Path $env:TEMP "zt-test-graphentity-$(Get-Random)"
            New-Item -ItemType Directory -Path $script:exportPath -Force | Out-Null
        }

        AfterAll {
            Remove-Item $script:exportPath -Recurse -Force -ErrorAction SilentlyContinue
        }

        BeforeEach {
            Mock -ModuleName ZeroTrustAssessment Get-ZtConfig            { return $false }
            Mock -ModuleName ZeroTrustAssessment Set-ZtConfig            {}
            Mock -ModuleName ZeroTrustAssessment Update-ZtProgressState  {}
            Mock -ModuleName ZeroTrustAssessment Get-PSFConfigValue      { return 1073741824 }
        }

        It "Does not throw when Graph API returns an empty page" {
            # Invoke-ZtRetry returns { "value": [] } — same as the customer tenant.
            # The guard must return early without calling Invoke-ZtGraphBatchRequest.
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry { return @{ value = @() } }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {
                throw "Guard missing — called with empty ArgumentList"
            }

            {
                Export-ZtGraphEntity -Name 'ServicePrincipal' -Uri 'beta/servicePrincipals' `
                    -QueryString '$top=999' -RelatedPropertyNames @('oauth2PermissionGrants') `
                    -ExportPath $script:exportPath
            } | Should -Not -Throw
        }

        It "Invoke-ZtGraphBatchRequest is not called when the page is empty" {
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry { return @{ value = @() } }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {}

            Export-ZtGraphEntity -Name 'ServicePrincipal' -Uri 'beta/servicePrincipals' `
                -QueryString '$top=999' -RelatedPropertyNames @('oauth2PermissionGrants') `
                -ExportPath $script:exportPath

            Should -Invoke -ModuleName ZeroTrustAssessment -CommandName Invoke-ZtGraphBatchRequest -Times 0 -Exactly
        }

        It "Does not throw when Invoke-ZtRetry returns null" {
            # $null is distinct from @() — guard must handle both without calling Invoke-ZtGraphBatchRequest.
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry { return $null }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {
                throw "Guard missing — called with null Results"
            }

            {
                Export-ZtGraphEntity -Name 'ServicePrincipal' -Uri 'beta/servicePrincipals' `
                    -QueryString '$top=999' -RelatedPropertyNames @('oauth2PermissionGrants') `
                    -ExportPath $script:exportPath
            } | Should -Not -Throw
        }

        It "Invoke-ZtGraphBatchRequest is not called when Invoke-ZtRetry returns null" {
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry { return $null }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {}

            Export-ZtGraphEntity -Name 'ServicePrincipal' -Uri 'beta/servicePrincipals' `
                -QueryString '$top=999' -RelatedPropertyNames @('oauth2PermissionGrants') `
                -ExportPath $script:exportPath

            Should -Invoke -ModuleName ZeroTrustAssessment -CommandName Invoke-ZtGraphBatchRequest -Times 0 -Exactly
        }

        It "Invoke-ZtGraphBatchRequest is called once when the page has items" {
            # Verifies the guard does not suppress normal (non-empty) pages and correctly
            # skips the batch call on an empty second page.
            # The first page must include '@odata.nextLink' so the do-while loop makes a
            # second call; without it the loop breaks immediately and the second branch
            # of the mock is never reached.
            $script:call = 0
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry {
                $script:call++
                if ($script:call -eq 1) {
                    return @{
                        value             = @(@{ id = 'sp-1'; displayName = 'TestSP' })
                        '@odata.nextLink' = 'https://graph.microsoft.com/beta/servicePrincipals?$skiptoken=abc'
                    }
                }
                return @{ value = @() }
            }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest { return @() }

            Export-ZtGraphEntity -Name 'ServicePrincipal' -Uri 'beta/servicePrincipals' `
                -QueryString '$top=999' -RelatedPropertyNames @('oauth2PermissionGrants') `
                -ExportPath $script:exportPath

            Should -Invoke -ModuleName ZeroTrustAssessment -CommandName Invoke-ZtGraphBatchRequest -Times 1 -Exactly
        }
    }
}
