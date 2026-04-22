Describe "Export-ZtGraphEntity" {
    # Regression tests for customer bug v2.2.0:
    #
    #   Error 1 (WARNING): Export 'ServicePrincipal' failed:
    #     Cannot bind argument to parameter 'ArgumentList' because it is an empty array.
    #
    #   Root cause: When a Graph API page returned { "value": [] }, Add-GraphProperty
    #   passed the empty $Results.Value directly to Invoke-ZtGraphBatchRequest -ArgumentList.
    #   PowerShell cannot bind @() to a mandatory [object[]] parameter.
    #
    #   Fix: Guard in Add-GraphProperty:
    #     if (-not $Results -or @($Results).Count -eq 0) { return }
    #
    #   Error 2 (Exception): Export-Database.ps1:115
    #     Binder Error: Could not find key "userprincipalname" in struct
    #
    #   Root cause: When all role principals are Service Principals, DuckDB inferred the
    #   principal struct without userPrincipalName, causing the vwRole SQL to fail.
    #
    #   Fix: Model JSON files pre-declare all principal fields as null.
    #   See Export-Database.Tests.ps1 for Error 2 regression tests.

    BeforeAll {
        $srcRoot = Join-Path $PSScriptRoot "../../src/powershell"
        if (-not (Get-Module ZeroTrustAssessment -ErrorAction SilentlyContinue)) {
            Import-Module (Join-Path $srcRoot "ZeroTrustAssessment.psd1") -Global 3>$null
            Import-Module (Join-Path $srcRoot "ZeroTrustAssessment.psm1") -Global -Force 3>$null
        }
        if (-not (Get-Command Get-MgContext -ErrorAction SilentlyContinue)) {
            function global:Get-MgContext {}
        }
        if (-not (Get-Command Invoke-MgGraphRequest -ErrorAction SilentlyContinue)) {
            function global:Invoke-MgGraphRequest { param($Method, $Uri, $OutputType) }
        }
    }

    Context "Error 1 reproduction — empty page triggers ArgumentList error (old behaviour)" {
        # Invoke-ZtGraphBatchRequest declares ArgumentList as mandatory [object[]].
        # Before the fix, Add-GraphProperty passed $Results.Value directly with no guard,
        # so an empty page caused the customer error.

        It "Invoke-ZtGraphBatchRequest throws when ArgumentList is empty" {
            { Invoke-ZtGraphBatchRequest -Path 'servicePrincipals/{0}/oauth2PermissionGrants' -ArgumentList @() } |
                Should -Throw
        }

        It "The error message matches the customer warning ('ArgumentList')" {
            $msg = $null
            try {
                Invoke-ZtGraphBatchRequest -Path 'servicePrincipals/{0}/oauth2PermissionGrants' -ArgumentList @()
            }
            catch { $msg = $_.Exception.Message }
            $msg | Should -Match 'ArgumentList'
        }
    }

    Context "Error 1 fix — guard in Add-GraphProperty skips batch when page is empty" {
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

        It "Invoke-ZtGraphBatchRequest is called once when the page has items" {
            # Verifies the guard does not suppress normal (non-empty) pages.
            $script:call = 0
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry {
                $script:call++
                if ($script:call -eq 1) { return @{ value = @(@{ id = 'sp-1'; displayName = 'TestSP' }) } }
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
