Describe 'Test-Assessment-41116' {
    BeforeAll {
        $srcRoot = Join-Path $PSScriptRoot '../../src/powershell'

        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function global:Write-PSFMessage {}
        }
        if (-not (Get-Command Write-ZtProgress -ErrorAction SilentlyContinue)) {
            function global:Write-ZtProgress {}
        }
        if (-not (Get-Command Invoke-ZtGraphRequest -ErrorAction SilentlyContinue)) {
            function global:Invoke-ZtGraphRequest {
                [CmdletBinding()]
                param($RelativeUri, $ApiVersion, $Method, $Body)
            }
        }
        if (-not (Get-Command Get-ZtHttpStatusCode -ErrorAction SilentlyContinue)) {
            function global:Get-ZtHttpStatusCode { param($ErrorRecord) return $null }
        }
        if (-not (Get-Command Get-SafeMarkdown -ErrorAction SilentlyContinue)) {
            function global:Get-SafeMarkdown { param($Text) return $Text }
        }
        if (-not (Get-Command Add-ZtTestResultDetail -ErrorAction SilentlyContinue)) {
            function global:Add-ZtTestResultDetail {
                param(
                    [string]   $Description, [bool]     $Status,    [string]   $Result,
                    [Object[]] $GraphObjects,[string]   $GraphObjectType,
                    [string]   $TestId,      [string]   $Title,     [string]   $SkippedBecause,
                    [string]   $UserImpact,  [string]   $Risk,      [string]   $ImplementationCost,
                    [string[]] $AppliesTo,   [string[]] $Tag,       [string]   $CustomStatus,
                    [string[]] $NotConnectedService,    [string]   $Pillar,    [string]   $Category
                )
            }
        }

        $classPath = Join-Path $srcRoot 'classes/ZtTest.ps1'
        if (-not ('ZtTest' -as [type])) {
            . $classPath
        }

        . (Join-Path $srcRoot 'tests/Test-Assessment.41116.ps1')

        function global:New-TestGraphError {
            param(
                [Parameter(Mandatory)]
                [string] $Message,

                [string] $ResponseBody
            )

            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Exception]::new($Message),
                'GraphRequestFailed',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $null
            )
            if ($ResponseBody) {
                $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($ResponseBody)
            }
            $errorRecord
        }
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
        Mock Get-ZtHttpStatusCode { return $null }

        $script:capturedRequestBody = $null
        $script:capturedStatus = $null
        $script:capturedResult = $null
        $script:capturedCustomStatus = $null
        $script:capturedSkippedBecause = $null

        Mock Add-ZtTestResultDetail {
            param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
            $script:capturedStatus = $Status
            $script:capturedResult = $Result
            $script:capturedCustomStatus = $CustomStatus
            $script:capturedSkippedBecause = $SkippedBecause
        }
    }

    Context 'When the advanced hunting query succeeds' {
        It 'Should send the expected Graph POST request and pass for a positive count' {
            Mock Invoke-ZtGraphRequest {
                param($Body)
                $script:capturedRequestBody = $Body
                [PSCustomObject]@{
                    results = @([PSCustomObject]@{ Count = 42L })
                }
            }

            Test-Assessment-41116

            Should -Invoke Invoke-ZtGraphRequest -Times 1 -Exactly -ParameterFilter {
                $RelativeUri -eq 'security/runHuntingQuery' -and
                $ApiVersion -eq 'beta' -and
                $Method -eq 'POST'
            }
            $requestBody = $script:capturedRequestBody | ConvertFrom-Json
            $requestBody.Query | Should -Be 'EmailEvents | where Timestamp > ago(1d) | summarize Count=count()'
            $requestBody.Timespan | Should -Be 'P1D'
            $script:capturedStatus | Should -BeTrue
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'data is queryable from automation'
            $script:capturedResult | Should -Match '\| /beta/security/runHuntingQuery \| 200 \|'
            $script:capturedResult | Should -Match '\| 42 \| Pass \|'
        }

        It 'Should investigate when the count is zero' {
            Mock Invoke-ZtGraphRequest {
                [PSCustomObject]@{
                    results = @([PSCustomObject]@{ Count = 0L })
                }
            }

            Test-Assessment-41116

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'zero recent EmailEvents'
            $script:capturedResult | Should -Match '\| 0 \| Investigate \|'
        }

        It 'Should preserve a count above the 32-bit integer limit' {
            Mock Invoke-ZtGraphRequest {
                [PSCustomObject]@{
                    results = @([PSCustomObject]@{ Count = 3000000000L })
                }
            }

            Test-Assessment-41116

            $script:capturedStatus | Should -BeTrue
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match '\| 3000000000 \| Pass \|'
        }

        It 'Should investigate when the results array is empty' {
            Mock Invoke-ZtGraphRequest {
                [PSCustomObject]@{ results = @() }
            }

            Test-Assessment-41116

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult | Should -Match 'No results were returned'
        }

        It 'Should investigate when the count cannot be parsed' {
            Mock Invoke-ZtGraphRequest {
                [PSCustomObject]@{
                    results = @([PSCustomObject]@{ Count = 'not-a-number' })
                }
            }

            { Test-Assessment-41116 } | Should -Not -Throw
            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult | Should -Match 'could not be parsed'
        }
    }

    Context 'When Microsoft Graph returns an error' {
        It 'Should skip a license-related HTTP 403 response' {
            $script:queryError = New-TestGraphError `
                -Message 'Forbidden' `
                -ResponseBody '{"error":{"code":"Forbidden","message":"The tenant is not licensed for Defender for Office 365 Plan 2."}}'
            Mock Get-ZtHttpStatusCode { return 403 }
            Mock Invoke-ZtGraphRequest {
                $PSCmdlet.ThrowTerminatingError($script:queryError)
            }

            Test-Assessment-41116

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedSkippedBecause | Should -Be 'NotApplicable'
            $script:capturedResult | Should -Match 'does not have the required Microsoft Defender for Office 365 Plan 2'
            $script:capturedResult | Should -Match '\| 403 \| Forbidden \|'
        }

        It 'Should investigate a permission-related HTTP 403 response' {
            $script:queryError = New-TestGraphError `
                -Message 'Forbidden' `
                -ResponseBody '{"error":{"code":"Forbidden","message":"Access denied."}}'
            Mock Get-ZtHttpStatusCode { return 403 }
            Mock Invoke-ZtGraphRequest {
                $PSCmdlet.ThrowTerminatingError($script:queryError)
            }

            Test-Assessment-41116

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'ThreatHunting.Read.All'
            $script:capturedResult | Should -Match 'Global Reader'
            $script:capturedResult | Should -Match 'Security Administrator'
            $script:capturedResult | Should -Match 'Defender XDR Unified RBAC'
        }

        It 'Should fail when HTTP 400 reports an unknown EmailEvents table' {
            $script:queryError = New-TestGraphError `
                -Message 'Bad Request' `
                -ResponseBody '{"error":{"code":"BadRequest","message":"Failed to resolve table expression named EmailEvents."}}'
            Mock Get-ZtHttpStatusCode { return 400 }
            Mock Invoke-ZtGraphRequest {
                $PSCmdlet.ThrowTerminatingError($script:queryError)
            }

            Test-Assessment-41116

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'schema is unavailable'
            $script:capturedResult | Should -Match '\| Fail \|'
        }

        It 'Should investigate an HTTP 429 throttling response' {
            $script:queryError = New-TestGraphError -Message 'Too Many Requests'
            Mock Get-ZtHttpStatusCode { return 429 }
            Mock Invoke-ZtGraphRequest {
                $PSCmdlet.ThrowTerminatingError($script:queryError)
            }

            Test-Assessment-41116

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult | Should -Match 'quota was exceeded'
        }

        It 'Should investigate an unexpected Graph failure' {
            $script:queryError = New-TestGraphError -Message 'Service Unavailable'
            Mock Get-ZtHttpStatusCode { return 503 }
            Mock Invoke-ZtGraphRequest {
                $PSCmdlet.ThrowTerminatingError($script:queryError)
            }

            Test-Assessment-41116

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'unexpected error'
        }

        It 'Should investigate an unparseable error response' {
            $script:queryError = New-TestGraphError -Message 'Forbidden' -ResponseBody 'not-json'
            Mock Get-ZtHttpStatusCode { return 403 }
            Mock Invoke-ZtGraphRequest {
                $PSCmdlet.ThrowTerminatingError($script:queryError)
            }

            { Test-Assessment-41116 } | Should -Not -Throw
            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'ThreatHunting.Read.All'
        }
    }
}
