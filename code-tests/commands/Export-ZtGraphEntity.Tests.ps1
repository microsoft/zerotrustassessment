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
        if (-not (Get-Command Export-ZtGraphEntity -ErrorAction SilentlyContinue)) {
            if (-not (Get-Module ZeroTrustAssessment -ErrorAction SilentlyContinue)) {
				Import-Module (Join-Path $srcRoot "ZeroTrustAssessment.psd1") -Global 3>$null
            }
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

        It "Uses related-property query options while preserving the result property name" {
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry {
                return @{ value = @(@{ id = 'app-1'; displayName = 'Test application' }) }
            }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {
                param($Path, $ArgumentList)

                $script:relatedPropertyPath = $Path
                return @([pscustomobject]@{
                    Success = $true
                    Argument = $ArgumentList[0]
                    Result = @(@{ id = 'owner-1'; displayName = 'Test owner' })
                })
            }

            Export-ZtGraphEntity -Name 'Application' -Uri 'beta/applications' `
                -QueryString '$top=999' -RelatedPropertyNames @('owners?$select=id,displayName') `
                -ExportPath $script:exportPath

            $script:relatedPropertyPath | Should -Be 'beta/applications/{0}/owners?$select=id,displayName'
            $exportedApplication = Get-Content (Join-Path $script:exportPath 'Application/Application-0.json') -Raw | ConvertFrom-Json
            $exportedApplication.value[0].owners[0].id | Should -Be 'owner-1'
        }
    }

    Context "Schedule-instance principal enrichment" {
        BeforeEach {
            $script:roleExportPath = Join-Path $TestDrive 'schedule-export'
            Mock -ModuleName ZeroTrustAssessment Get-ZtConfig { return $false }
            Mock -ModuleName ZeroTrustAssessment Set-ZtConfig {}
            Mock -ModuleName ZeroTrustAssessment Update-ZtProgressState {}
            Mock -ModuleName ZeroTrustAssessment Get-PSFConfigValue { return 1073741824 }
            Mock -ModuleName ZeroTrustAssessment Write-PSFMessage {}
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {
                param($Path, $ArgumentList)
                foreach ($principalId in $ArgumentList) {
                    $principal = @{ id = $principalId; displayName = 'Principal' }
                    if ($Path -like 'users/*') { $principal.userPrincipalName = $UserName }
                    if ($Path -like 'groups/*') { $principal.uniqueName = $UniqueName }
                    [pscustomobject]@{
                        Argument = $principalId
                        Success = $true
                        Status = 200
                        Result = @($principal)
                    }
                }
            }
        }

        It "Persists minimal scalar principals for <PrincipalType>" -TestCases @(
            @{ PrincipalType = 'user'; Endpoint = 'users'; UserName = 'user@contoso.com'; UniqueName = $null }
            @{ PrincipalType = 'group'; Endpoint = 'groups'; UserName = $null; UniqueName = 'group@contoso.com' }
            @{ PrincipalType = 'servicePrincipal'; Endpoint = 'servicePrincipals'; UserName = $null; UniqueName = $null }
            @{ PrincipalType = 'agentUser'; Endpoint = 'users'; UserName = 'agent@contoso.com'; UniqueName = $null }
            @{ PrincipalType = 'agentIdentity'; Endpoint = 'servicePrincipals'; UserName = $null; UniqueName = $null }
            @{ PrincipalType = 'agentIdentityBlueprintPrincipal'; Endpoint = 'servicePrincipals'; UserName = $null; UniqueName = $null }
        ) {
            param($PrincipalType, $Endpoint, $UserName, $UniqueName)
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry {
                @{ value = @(@{ id = 'assignment'; principalId = 'principal'; principal = @{ id = 'principal'; '@odata.type' = "#microsoft.graph.$PrincipalType" } }) }
            }
            Export-ZtGraphEntity -Name RoleEligibilityScheduleInstance -Uri 'beta/roleManagement/directory/roleEligibilityScheduleInstances' -ResolveRolePrincipals -ExportPath $script:roleExportPath

            $export = Get-Content (Join-Path $script:roleExportPath 'RoleEligibilityScheduleInstance/RoleEligibilityScheduleInstance-0.json') -Raw | ConvertFrom-Json
            $export.value[0].principal | Should -BeOfType PSCustomObject
            @($export.value[0].principal.PSObject.Properties.Name) | Should -HaveCount 5
            $export.value[0].principal.'@odata.type' | Should -Be "#microsoft.graph.$PrincipalType"
            $export.value[0].principal.displayName | Should -Be 'Principal'
            $export.value[0].principal.userPrincipalName | Should -Be $UserName
            $export.value[0].principal.uniqueName | Should -Be $UniqueName
            Should -Invoke -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest -Times 1 -Exactly -ParameterFilter {
                $Path.StartsWith("$Endpoint/{0}?") -and
                $ApiVersion -eq 'beta' -and $Matched -and $OutputType -eq 'Hashtable'
            }
        }

        It "Caches repeated <Outcome> principals across pages" -TestCases @(
            @{ Outcome = 'resolved' }
            @{ Outcome = 'deleted' }
            @{ Outcome = 'unknown type' }
        ) {
            param($Outcome)
            $script:rolePage = 0
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry {
                $script:rolePage++
                $principal = if ($Outcome -eq 'unknown type') { $null } else { @{ id = 'principal'; '@odata.type' = '#microsoft.graph.group' } }
                $page = @{ value = @(@{ id = "assignment-$script:rolePage"; principalId = 'principal'; principal = $principal }) }
                if ($script:rolePage -lt 3) { $page['@odata.nextLink'] = "https://graph.microsoft.com/beta/roleManagement/directory/roleAssignmentScheduleInstances?page=$script:rolePage" }
                $page
            }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphRequest {
                if ($Outcome -eq 'resolved') { @{ id = 'principal'; displayName = 'Group' } }
            }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {
                if ($Outcome -eq 'resolved') {
                    [pscustomobject]@{ Argument = 'principal'; Success = $true; Status = 200; Result = @(@{ id = 'principal'; displayName = 'Group' }) }
                }
                elseif ($Outcome -eq 'deleted') {
                    [pscustomobject]@{ Argument = 'principal'; Success = $false; Status = 404; Result = @() }
                }
            }

            Export-ZtGraphEntity -Name RoleAssignmentScheduleInstance -Uri 'beta/roleManagement/directory/roleAssignmentScheduleInstances' -ResolveRolePrincipals -ExportPath $script:roleExportPath

            $expectedBatchCalls = if ($Outcome -eq 'unknown type') { 0 } else { 1 }
            Should -Invoke -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest -Times $expectedBatchCalls -Exactly
            $export = Get-Content (Join-Path $script:roleExportPath 'RoleAssignmentScheduleInstance/RoleAssignmentScheduleInstance-2.json') -Raw | ConvertFrom-Json
            $export.value[0].principal.id | Should -Be 'principal'
            if ($Outcome -eq 'resolved') { $export.value[0].principal.displayName | Should -Be 'Group' }
            else { $export.value[0].principal.displayName | Should -BeNullOrEmpty }
        }

        It "Retries a failed <Lookup> lookup and requests terminating errors" -TestCases @(
            @{ Lookup = 'typed' }
            @{ Lookup = 'type discovery' }
        ) {
            param($Lookup)
            $script:rolePage = 0
            $script:lookupAttempt = 0
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry {
                $script:rolePage++
                $principal = if ($Lookup -eq 'typed') { @{ id = 'principal'; '@odata.type' = '#microsoft.graph.group' } } else { $null }
                $page = @{ value = @(@{ id = "assignment-$script:rolePage"; principalId = 'principal'; principal = $principal }) }
                if ($script:rolePage -eq 1) { $page['@odata.nextLink'] = 'https://graph.microsoft.com/beta/roleManagement/directory/roleAssignmentScheduleInstances?page=2' }
                $page
            }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphRequest {
                $script:lookupAttempt++
                if ($script:lookupAttempt -eq 1) { Write-Error 'Type discovery failed' -ErrorAction Stop }
                @{ id = 'principal'; '@odata.type' = '#microsoft.graph.group' }
            } -ParameterFilter { $RelativeUri -eq 'directoryObjects/getByIds' }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {
                $script:lookupAttempt++
                if ($script:lookupAttempt -eq 1) {
                    [pscustomobject]@{ Argument = 'principal'; Success = $false; Status = 503; Result = @{ status = 503 } }
                }
                else {
                    [pscustomobject]@{ Argument = 'principal'; Success = $true; Status = 200; Result = @(@{ id = 'principal'; '@odata.type' = '#microsoft.graph.group'; displayName = 'Recovered' }) }
                }
            }

            Export-ZtGraphEntity -Name RoleAssignmentScheduleInstance -Uri 'beta/roleManagement/directory/roleAssignmentScheduleInstances' -ResolveRolePrincipals -ExportPath $script:roleExportPath

            $expectedBatchCalls = if ($Lookup -eq 'typed') { 2 } else { 1 }
            Should -Invoke -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest -Times $expectedBatchCalls -Exactly
            $expectedTypeDiscoveryCalls = if ($Lookup -eq 'typed') { 0 } else { 2 }
            Should -Invoke -ModuleName ZeroTrustAssessment Invoke-ZtGraphRequest -Times $expectedTypeDiscoveryCalls -Exactly -ParameterFilter { $RelativeUri -eq 'directoryObjects/getByIds' }
            $export = Get-Content (Join-Path $script:roleExportPath 'RoleAssignmentScheduleInstance/RoleAssignmentScheduleInstance-1.json') -Raw | ConvertFrom-Json
            $export.value[0].principal.displayName | Should -Be 'Recovered'
        }

        It "Retries only a transiently failed member after a mixed-result batch on the next page" {
            $script:rolePage = 0
            $script:principalBatchCalls = [System.Collections.Generic.List[object]]::new()
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry {
                $script:rolePage++
                $assignments = if ($script:rolePage -eq 1) {
                    @(
                        @{ id = 'assignment-1'; principalId = 'principal-success'; principal = @{ id = 'principal-success'; '@odata.type' = '#microsoft.graph.group' } }
                        @{ id = 'assignment-2'; principalId = 'principal-transient'; principal = @{ id = 'principal-transient'; '@odata.type' = '#microsoft.graph.group' } }
                    )
                }
                else {
                    @(@{ id = 'assignment-3'; principalId = 'principal-transient'; principal = @{ id = 'principal-transient'; '@odata.type' = '#microsoft.graph.group' } })
                }
                $page = @{ value = $assignments }
                if ($script:rolePage -eq 1) { $page['@odata.nextLink'] = 'https://graph.microsoft.com/beta/roleManagement/directory/roleAssignmentScheduleInstances?page=2' }
                $page
            }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {
                param($ArgumentList)
                $script:principalBatchCalls.Add(@($ArgumentList))
                if ($script:principalBatchCalls.Count -eq 1) {
                    @(
                        [pscustomobject]@{ Argument = 'principal-success'; Success = $true; Status = 200; Result = @(@{ id = 'principal-success'; displayName = 'Resolved' }) }
                        [pscustomobject]@{ Argument = 'principal-transient'; Success = $false; Status = 503; Result = @{ status = 503 } }
                    )
                }
                else {
                    [pscustomobject]@{ Argument = 'principal-transient'; Success = $true; Status = 200; Result = @(@{ id = 'principal-transient'; displayName = 'Recovered' }) }
                }
            }

            Export-ZtGraphEntity -Name RoleAssignmentScheduleInstance -Uri 'beta/roleManagement/directory/roleAssignmentScheduleInstances' -ResolveRolePrincipals -ExportPath $script:roleExportPath

            $script:principalBatchCalls | Should -HaveCount 2
            @($script:principalBatchCalls[0]) | Should -Contain 'principal-success'
            @($script:principalBatchCalls[0]) | Should -Contain 'principal-transient'
            @($script:principalBatchCalls[1]) | Should -Be @('principal-transient')
            $export = Get-Content (Join-Path $script:roleExportPath 'RoleAssignmentScheduleInstance/RoleAssignmentScheduleInstance-1.json') -Raw | ConvertFrom-Json
            $export.value[0].principal.displayName | Should -Be 'Recovered'
        }

        It "Uses richer duplicate data on the same page without a lookup" {
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry {
                @{ value = @(
                    @{ id = 'first'; principalId = 'principal'; principal = $null }
                    @{ id = 'second'; principalId = 'principal'; principal = @{ id = 'principal'; '@odata.type' = '#microsoft.graph.group'; displayName = 'Group' } }
                ) }
            }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphRequest {}

            Export-ZtGraphEntity -Name RoleAssignmentScheduleInstance -Uri 'beta/roleManagement/directory/roleAssignmentScheduleInstances' -ResolveRolePrincipals -ExportPath $script:roleExportPath

            Should -Invoke -ModuleName ZeroTrustAssessment Invoke-ZtGraphRequest -Times 0 -Exactly
            $export = Get-Content (Join-Path $script:roleExportPath 'RoleAssignmentScheduleInstance/RoleAssignmentScheduleInstance-0.json') -Raw | ConvertFrom-Json
            @($export.value.principal.displayName) | Should -Be @('Group', 'Group')
        }

        It "Refines an unresolved cached base type from a later page" {
            $script:rolePage = 0
            $script:lookupAttempt = 0
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry {
                $script:rolePage++
                $type = if ($script:rolePage -eq 1) { '#microsoft.graph.servicePrincipal' } else { '#microsoft.graph.agentIdentity' }
                $page = @{ value = @(@{ id = "assignment-$script:rolePage"; principalId = 'principal'; principal = @{ id = 'principal'; '@odata.type' = $type } }) }
                if ($script:rolePage -eq 1) { $page['@odata.nextLink'] = 'https://graph.microsoft.com/beta/roleManagement/directory/roleAssignmentScheduleInstances?page=2' }
                $page
            }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {
                $script:lookupAttempt++
                $displayName = if ($script:lookupAttempt -gt 1) { 'Agent' } else { $null }
                [pscustomobject]@{
                    Argument = 'principal'
                    Success = $true
                    Status = 200
                    Result = @(@{ id = 'principal'; '@odata.type' = '#microsoft.graph.servicePrincipal'; displayName = $displayName })
                }
            }

            Export-ZtGraphEntity -Name RoleAssignmentScheduleInstance -Uri 'beta/roleManagement/directory/roleAssignmentScheduleInstances' -ResolveRolePrincipals -ExportPath $script:roleExportPath

            Should -Invoke -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest -Times 2 -Exactly
            $export = Get-Content (Join-Path $script:roleExportPath 'RoleAssignmentScheduleInstance/RoleAssignmentScheduleInstance-1.json') -Raw | ConvertFrom-Json
            $export.value[0].principal.'@odata.type' | Should -Be '#microsoft.graph.agentIdentity'
            $export.value[0].principal.displayName | Should -Be 'Agent'
        }

        It "Discovers unknown types in chunks of at most 1000 IDs" {
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry {
                @{ value = @(1..1001 | ForEach-Object { @{ id = "assignment-$_"; principalId = "principal-$_"; principal = $null } }) }
            }
            $script:lookupSizes = [System.Collections.Generic.List[int]]::new()
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphRequest {
                param($Body)
                $requestBody = $Body | ConvertFrom-Json
                $script:lookupSizes.Add($requestBody.ids.Count)
                foreach ($principalId in $requestBody.ids) { @{ id = $principalId; '@odata.type' = '#microsoft.graph.user' } }
            } -ParameterFilter { $RelativeUri -eq 'directoryObjects/getByIds' }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphRequest {
                param($UniqueId)
                foreach ($principalId in $UniqueId) { @{ id = $principalId; '@odata.type' = '#microsoft.graph.agentUser'; displayName = 'Agent' } }
            } -ParameterFilter { $RelativeUri -eq 'users' }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {
                param($ArgumentList)
                foreach ($principalId in $ArgumentList) {
                    [pscustomobject]@{
                        Argument = $principalId
                        Success = $true
                        Status = 200
                        Result = @(@{ id = $principalId; '@odata.type' = '#microsoft.graph.agentUser'; displayName = 'Agent' })
                    }
                }
            }

            Export-ZtGraphEntity -Name RoleEligibilityScheduleInstance -Uri 'beta/roleManagement/directory/roleEligibilityScheduleInstances' -ResolveRolePrincipals -ExportPath $script:roleExportPath

            @($script:lookupSizes) | Should -Be @(1000, 1)
            $export = Get-Content (Join-Path $script:roleExportPath 'RoleEligibilityScheduleInstance/RoleEligibilityScheduleInstance-0.json') -Raw | ConvertFrom-Json
            $export.value | Should -HaveCount 1001
            @($export.value.principal.'@odata.type' | Select-Object -Unique) | Should -Be @('#microsoft.graph.agentUser')
        }

        It "Limits enrichment configuration to the two schedule exports" {
            $srcRoot = Join-Path $PSScriptRoot '../../src/powershell'
            $config = Import-PSFPowerShellDataFile -Path (Join-Path $srcRoot 'assets/export-tenant.config.psd1') -Psd1Mode Safe
            $scheduleExports = @($config | Where-Object ResolveRolePrincipals)
            $scheduleExports.Name | Should -Be @('RoleAssignmentScheduleInstance', 'RoleEligibilityScheduleInstance')
            foreach ($scheduleExport in $scheduleExports) {
                $scheduleExport.QueryString | Should -BeLike '*$expand=principal($select=id)*'
                $model = Get-Content (Join-Path $srcRoot "assets/export-model/$($scheduleExport.Name)-model.json") -Raw | ConvertFrom-Json
                @($model.value[0].principal.PSObject.Properties.Name | Sort-Object) | Should -Be @('@odata.type', 'displayName', 'id', 'uniqueName', 'userPrincipalName')
            }
            $scheduleExports[0].QueryString | Should -BeLike "*assignmentType eq 'Assigned'*"
        }

        It "Does not perform principal lookups for an empty schedule page" {
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtRetry { @{ value = @() } }
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphRequest {}
            Mock -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest {}

            Export-ZtGraphEntity -Name RoleEligibilityScheduleInstance -Uri 'beta/roleManagement/directory/roleEligibilityScheduleInstances' -ResolveRolePrincipals -ExportPath $script:roleExportPath

            Should -Invoke -ModuleName ZeroTrustAssessment Invoke-ZtGraphRequest -Times 0 -Exactly
            Should -Invoke -ModuleName ZeroTrustAssessment Invoke-ZtGraphBatchRequest -Times 0 -Exactly
        }
    }
}
