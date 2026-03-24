Describe "Export-Database" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        # Import via .psd1 so RequiredAssemblies (lib\DuckDB.NET.Data.dll) and
        # ScriptsToProcess (Initialize-Dependencies.ps1) are processed — without this
        # [DuckDB.NET.Data.DuckDBConnection] cannot be resolved as a PowerShell type.
        # Skip entirely if already loaded (e.g. when invoked via code-tests/pester.ps1)
        # to avoid re-running ScriptsToProcess and re-importing unnecessarily.
        $moduleName = 'ZeroTrustAssessment'
        if (-not (Get-Module -Name $moduleName -ErrorAction SilentlyContinue)) {
            Import-Module (Join-Path $srcRoot "ZeroTrustAssessment.psd1") -Global 3>$null
            Import-Module (Join-Path $srcRoot "ZeroTrustAssessment.psm1") -Global -Force 3>$null
        }

        # Stub Get-MgContext if not available (Microsoft.Graph.Authentication not installed)
        if (-not (Get-Command Get-MgContext -ErrorAction SilentlyContinue)) {
            function global:Get-MgContext {}
        }

        # Helper — creates a temp export folder with the minimum files needed for the
        # Identity pillar. Tables that have model files (Application, ServicePrincipalSignIn,
        # etc.) will get their schema from those; the four tables below have no model files
        # and therefore need at least one real data file.
        function script:New-TestExportPath ([string]$Suffix) {
            $path = Join-Path $env:TEMP "zt-test-$Suffix-$(Get-Random)"
            New-Item -ItemType Directory -Path $path -Force | Out-Null

            @(
                'User', 'Application', 'ServicePrincipal', 'ServicePrincipalSignIn',
                'SignIn', 'RoleDefinition', 'RoleAssignment', 'RoleAssignmentGroup',
                'RoleAssignmentScheduleInstance', 'RoleAssignmentScheduleInstanceGroup',
                'RoleEligibilityScheduleInstance', 'RoleEligibilityScheduleInstanceGroup',
                'RoleManagementPolicyAssignment', 'UserRegistrationDetails'
            ) | ForEach-Object {
                New-Item -ItemType Directory -Path (Join-Path $path $_) -Force | Out-Null
            }

            # RoleDefinition — required for the LEFT JOIN in vwRole (no model file)
            @{ value = @(@{
                id           = 'a0b1c2d3-0000-0000-0000-000000000001'
                displayName  = 'Global Administrator'
                isPrivileged = $true
                isBuiltIn    = $true
            }) } | ConvertTo-Json -Depth 5 |
                Set-Content (Join-Path $path "RoleDefinition\RoleDefinition-0.json")

            # User — minimal (no model file)
            @{ value = @(@{
                id                = 'u-00000001'
                displayName       = 'Test User'
                userPrincipalName = 'test@contoso.com'
            }) } | ConvertTo-Json -Depth 3 |
                Set-Content (Join-Path $path "User\User-0.json")

            # ServicePrincipal — minimal (no model file)
            @{ value = @(@{
                id          = 'sp-00000001'
                displayName = 'TestServicePrincipal'
            }) } | ConvertTo-Json -Depth 3 |
                Set-Content (Join-Path $path "ServicePrincipal\ServicePrincipal-0.json")

            return $path
        }
    }

    Context "When all role assignments are service principals only (no users)" {
        <#
            Tests the SP-only variant — same bug class as #727/#1079, different principal type.
            The filed issues report Candidate Entries: 'uniqueName' (groups-only); SP-only
            would show 'displayName', 'servicePrincipalType' instead.
        #>
        BeforeAll {
            $script:testPath1 = New-TestExportPath -Suffix 'sponly'

            # RoleAssignment — SP-only principals (no userPrincipalName in the struct)
            @{ value = @(@{
                id               = 'ra-00000001'
                principalId      = 'sp-00000001'
                directoryScopeId = '/'
                roleDefinitionId = 'a0b1c2d3-0000-0000-0000-000000000001'
                principal        = @{
                    '@odata.type' = '#microsoft.graph.servicePrincipal'
                    id            = 'sp-00000001'
                    displayName   = 'TestServicePrincipal'
                }
            }) } | ConvertTo-Json -Depth 5 |
                Set-Content (Join-Path $script:testPath1 "RoleAssignment\RoleAssignment-0.json")
        }

        AfterAll {
            if ($script:testPath1 -and (Test-Path $script:testPath1)) {
                Remove-Item $script:testPath1 -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        It "Should create vwRole without error when only service principals are assigned to roles" {
            Mock -ModuleName ZeroTrustAssessment Get-ZtLicenseInformation { return 'Free' }
            $db = $null
            try {
                { $db = Export-Database -ExportPath $script:testPath1 -Pillar Identity } |
                    Should -Not -Throw
            }
            finally {
                if ($db) { Disconnect-Database -Database $db }
            }
        }
    }

    Context "When all eligible role assignments are groups only (no users or service principals)" {
        <#
            Reproduces the user-reported failure:
            When every entry in RoleEligibilityScheduleInstance has a group principal,
            DuckDB infers the 'principal' struct with group-specific fields (e.g. uniqueName)
            but WITHOUT userPrincipalName. The view SQL then fails:
                "Could not find key 'userprincipalname' in struct
                 Candidate Entries: 'uniqueName'"
            Also validates that uniqueName and userPrincipalName are correctly populated
            per principal type in the resulting vwRole view.
        #>
        BeforeAll {
            $script:testPath2 = New-TestExportPath -Suffix 'grouponly'

            # RoleAssignment — normal user assignment; this is NOT the bug trigger
            @{ value = @(@{
                id               = 'ra-00000001'
                principalId      = 'u-00000001'
                directoryScopeId = '/'
                roleDefinitionId = 'a0b1c2d3-0000-0000-0000-000000000001'
                principal        = @{
                    '@odata.type'     = '#microsoft.graph.user'
                    id                = 'u-00000001'
                    displayName       = 'Test User'
                    userPrincipalName = 'test@contoso.com'
                }
            }) } | ConvertTo-Json -Depth 5 |
                Set-Content (Join-Path $script:testPath2 "RoleAssignment\RoleAssignment-0.json")

            # RoleEligibilityScheduleInstance — group-only principals.
            # Groups have 'uniqueName' but NOT 'userPrincipalName'.
            # DuckDB infers the struct schema from this data; accessing
            # r.principal.userPrincipalName in the view SQL then fails.
            @{ value = @(@{
                id               = 'rei-00000001'
                principalId      = 'grp-00000001'
                directoryScopeId = '/'
                roleDefinitionId = 'a0b1c2d3-0000-0000-0000-000000000001'
                principal        = @{
                    '@odata.type' = '#microsoft.graph.group'
                    id            = 'grp-00000001'
                    displayName   = 'TestGroup'
                    uniqueName    = 'testgroup@contoso.com'
                }
            }) } | ConvertTo-Json -Depth 5 |
                Set-Content (Join-Path $script:testPath2 "RoleEligibilityScheduleInstance\RoleEligibilityScheduleInstance-0.json")

            # Create the database ONCE and share it across all tests in this context
            # to avoid file-lock errors from repeated Export-Database calls on the same path.
            Mock -ModuleName ZeroTrustAssessment Get-ZtLicenseInformation { return 'Free' }
            { $script:dbGroupOnly = Export-Database -ExportPath $script:testPath2 -Pillar Identity } | Should -Not -Throw
        }

        AfterAll {
            if ($script:dbGroupOnly) {
                Disconnect-Database -Database $script:dbGroupOnly -ErrorAction SilentlyContinue
            }
            if ($script:testPath2 -and (Test-Path $script:testPath2)) {
                Remove-Item $script:testPath2 -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        It "Should create vwRole without error when eligible role assignments are all groups" {
            $script:dbGroupOnly | Should -Not -BeNull
        }

        It "Should populate uniqueName for group principals in vwRole" {
            # Use @() to ensure array even when Invoke-DatabaseQuery returns a single hashtable row,
            # since $singleHashtable[0] would be $null (hashtable key lookup, not index).
            $rows = @(Invoke-DatabaseQuery -Database $script:dbGroupOnly -Sql @"
select uniqueName, userPrincipalName
from vwRole
where "@odata.type" = '#microsoft.graph.group'
"@)
            $rows | Should -Not -BeNullOrEmpty
            $rows[0]['uniqueName']        | Should -Be 'testgroup@contoso.com'
            $rows[0]['userPrincipalName'] | Should -BeNullOrEmpty
        }

        It "Should populate userPrincipalName for user principals and leave uniqueName null" {
            $rows = @(Invoke-DatabaseQuery -Database $script:dbGroupOnly -Sql @"
select uniqueName, userPrincipalName
from vwRole
where "@odata.type" = '#microsoft.graph.user'
"@)
            $rows | Should -Not -BeNullOrEmpty
            $rows[0]['userPrincipalName'] | Should -Be 'test@contoso.com'
            $rows[0]['uniqueName']        | Should -BeNullOrEmpty
        }
    }

    Context "When all active role assignments are service principals only (P2/Governance path)" {
        <#
            Reproduces Issue #1079 for the P2/Governance-licensed RoleAssignmentScheduleInstance path.
            When a tenant is licensed for Entra P2/Governance, vwRole reads from
            RoleAssignmentScheduleInstance instead of RoleAssignment. If that table
            contains only service principals, DuckDB infers the 'principal' struct
            without a 'userPrincipalName' field and the view SQL fails with:
                "Could not find key 'userprincipalname' in struct ..."
        #>
        BeforeAll {
            $script:testPath3 = New-TestExportPath -Suffix 'p2sponly'

            # RoleAssignmentScheduleInstance — SP-only principals; no userPrincipalName in the struct.
            # This is the P2/Governance equivalent of the Free/P1 RoleAssignment SP-only case.
            @{ value = @(@{
                id               = 'rasi-00000001'
                principalId      = 'sp-00000001'
                directoryScopeId = '/'
                roleDefinitionId = 'a0b1c2d3-0000-0000-0000-000000000001'
                principal        = @{
                    '@odata.type' = '#microsoft.graph.servicePrincipal'
                    id            = 'sp-00000001'
                    displayName   = 'TestServicePrincipal'
                }
            }) } | ConvertTo-Json -Depth 5 |
                Set-Content (Join-Path $script:testPath3 "RoleAssignmentScheduleInstance\RoleAssignmentScheduleInstance-0.json")

            # RoleAssignment — still needs at least one file because it has no model file and
            # Import-EntraTable processes every directory unconditionally. In P2 mode the view
            # reads from RoleAssignmentScheduleInstance, so what's here doesn't affect the test.
            @{ value = @(@{
                id               = 'ra-00000001'
                principalId      = 'sp-00000001'
                directoryScopeId = '/'
                roleDefinitionId = 'a0b1c2d3-0000-0000-0000-000000000001'
                principal        = @{
                    '@odata.type' = '#microsoft.graph.servicePrincipal'
                    id            = 'sp-00000001'
                    displayName   = 'TestServicePrincipal'
                }
            }) } | ConvertTo-Json -Depth 5 |
                Set-Content (Join-Path $script:testPath3 "RoleAssignment\RoleAssignment-0.json")
        }

        AfterAll {
            if ($script:testPath3 -and (Test-Path $script:testPath3)) {
                Remove-Item $script:testPath3 -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        It "Should create vwRole without error when only service principals are assigned to roles (P2 path)" {
            Mock -ModuleName ZeroTrustAssessment Get-ZtLicenseInformation { return 'P2' }
            $db = $null
            try {
                { $db = Export-Database -ExportPath $script:testPath3 -Pillar Identity } |
                    Should -Not -Throw
            }
            finally {
                if ($db) { Disconnect-Database -Database $db }
            }
        }
    }

    Context "When all active role assignments are groups only (Free/P1 path, RoleAssignment)" {
        <#
            Regression for the group-only RoleAssignment (permanent active) path.
            Groups can be directly assigned to active roles without PIM. When RoleAssignment
            contains only group principals, DuckDB infers the struct with 'uniqueName' but
            without 'userPrincipalName'. The fix in Get-RoleSelectSql covers this path via
            the shared SQL, but this test ensures it is exercised and does not regress.
        #>
        BeforeAll {
            $script:testPath4 = New-TestExportPath -Suffix 'ragrouponly'

            # RoleAssignment — group-only principals; groups have 'uniqueName' but no 'userPrincipalName'.
            @{ value = @(@{
                id               = 'ra-00000001'
                principalId      = 'grp-00000001'
                directoryScopeId = '/'
                roleDefinitionId = 'a0b1c2d3-0000-0000-0000-000000000001'
                principal        = @{
                    '@odata.type' = '#microsoft.graph.group'
                    id            = 'grp-00000001'
                    displayName   = 'TestGroup'
                    uniqueName    = 'testgroup@contoso.com'
                }
            }) } | ConvertTo-Json -Depth 5 |
                Set-Content (Join-Path $script:testPath4 "RoleAssignment\RoleAssignment-0.json")
        }

        AfterAll {
            if ($script:testPath4 -and (Test-Path $script:testPath4)) {
                Remove-Item $script:testPath4 -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        It "Should create vwRole without error when only groups are directly assigned to roles (Free path)" {
            Mock -ModuleName ZeroTrustAssessment Get-ZtLicenseInformation { return 'Free' }
            $db = $null
            try {
                { $db = Export-Database -ExportPath $script:testPath4 -Pillar Identity } |
                    Should -Not -Throw
            }
            finally {
                if ($db) { Disconnect-Database -Database $db }
            }
        }
    }

    Context "When all active role assignments are groups only (P2/Governance path, RoleAssignmentScheduleInstance)" {
        <#
            Regression for the group-only RoleAssignmentScheduleInstance (PIM permanent active) path.
            When P2/Governance tenants have only group principals in RoleAssignmentScheduleInstance,
            DuckDB infers the struct with 'uniqueName' but without 'userPrincipalName'. The fix
            in Get-RoleSelectSql covers this path via the shared SQL, but this test ensures it
            is exercised and does not regress.
        #>
        BeforeAll {
            $script:testPath5 = New-TestExportPath -Suffix 'p2ragrouponly'

            # RoleAssignmentScheduleInstance — group-only principals.
            @{ value = @(@{
                id               = 'rasi-00000001'
                principalId      = 'grp-00000001'
                directoryScopeId = '/'
                roleDefinitionId = 'a0b1c2d3-0000-0000-0000-000000000001'
                principal        = @{
                    '@odata.type' = '#microsoft.graph.group'
                    id            = 'grp-00000001'
                    displayName   = 'TestGroup'
                    uniqueName    = 'testgroup@contoso.com'
                }
            }) } | ConvertTo-Json -Depth 5 |
                Set-Content (Join-Path $script:testPath5 "RoleAssignmentScheduleInstance\RoleAssignmentScheduleInstance-0.json")

            # RoleAssignment — stub required: no model file, so an empty directory throws.
            @{ value = @(@{
                id               = 'ra-00000001'
                principalId      = 'grp-00000001'
                directoryScopeId = '/'
                roleDefinitionId = 'a0b1c2d3-0000-0000-0000-000000000001'
                principal        = @{
                    '@odata.type' = '#microsoft.graph.group'
                    id            = 'grp-00000001'
                    displayName   = 'TestGroup'
                    uniqueName    = 'testgroup@contoso.com'
                }
            }) } | ConvertTo-Json -Depth 5 |
                Set-Content (Join-Path $script:testPath5 "RoleAssignment\RoleAssignment-0.json")
        }

        AfterAll {
            if ($script:testPath5 -and (Test-Path $script:testPath5)) {
                Remove-Item $script:testPath5 -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        It "Should create vwRole without error when only groups are assigned to roles (P2 path)" {
            Mock -ModuleName ZeroTrustAssessment Get-ZtLicenseInformation { return 'P2' }
            $db = $null
            try {
                { $db = Export-Database -ExportPath $script:testPath5 -Pillar Identity } |
                    Should -Not -Throw
            }
            finally {
                if ($db) { Disconnect-Database -Database $db }
            }
        }
    }
}
