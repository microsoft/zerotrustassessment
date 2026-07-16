Describe 'Test-Assessment-41020' {
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
                param($RelativeUri, $Filter, $ApiVersion)
            }
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
        if (-not (Get-Command Get-SafeMarkdown -ErrorAction SilentlyContinue)) {
            function global:Get-SafeMarkdown { param($Text) return $Text }
        }
        if (-not (Get-Command Get-FormattedDate -ErrorAction SilentlyContinue)) {
            function global:Get-FormattedDate { param($DateString) return $DateString }
        }
        if (-not (Get-Command Get-ZtHttpStatusCode -ErrorAction SilentlyContinue)) {
            function global:Get-ZtHttpStatusCode { param($ErrorRecord) }
        }

        $classPath = Join-Path $srcRoot 'classes/ZtTest.ps1'
        if (-not ('ZtTest' -as [type])) {
            . $classPath
        }

        . (Join-Path $srcRoot 'tests/Test-Assessment.41020.ps1')

        function global:New-TestHealthIssue {
            param(
                [string] $CreatedDateTime,

                [string] $LastModifiedDateTime,

                [string] $DisplayName = 'Sensor health issue'
            )

            [PSCustomObject]@{
                displayName          = $DisplayName
                severity             = 'medium'
                createdDateTime      = $CreatedDateTime
                lastModifiedDateTime = $LastModifiedDateTime
                sensorDNSNames       = @('sensor.contoso.com')
                status               = 'open'
            }
        }

        function global:New-TestGraphError {
            param(
                [Parameter(Mandatory)]
                [string] $ResponseBody
            )

            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Exception]::new('Forbidden'),
                'GraphRequestFailed',
                [System.Management.Automation.ErrorCategory]::PermissionDenied,
                $null
            )
            $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($ResponseBody)
            $errorRecord
        }
    }

    BeforeEach {
        $script:now = [datetimeoffset]'2026-07-10T12:00:00Z'

        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
        Mock Get-FormattedDate { param($DateString) return $DateString }
        Mock Get-ZtHttpStatusCode { return 403 }
        Mock Get-Date { return $script:now }

        $script:capturedStatus = $null
        $script:capturedResult = $null
        $script:capturedCustomStatus = $null
        Mock Add-ZtTestResultDetail {
            param($TestId, $Title, $Status, $Result, $CustomStatus)
            $script:capturedStatus = $Status
            $script:capturedResult = $Result
            $script:capturedCustomStatus = $CustomStatus
        }
    }

    Context 'When timestamps contain non-zero UTC offsets' {
        It 'Should fail when the issue and its last modification are older than seven days' {
            $created = $script:now.AddDays(-8).ToOffset([timespan]::FromHours(13)).ToString('o')
            $modified = $script:now.AddDays(-8).ToOffset([timespan]::FromHours(-10)).ToString('o')
            Mock Invoke-ZtGraphRequest {
                @(New-TestHealthIssue -CreatedDateTime $created -LastModifiedDateTime $modified)
            }

            Test-Assessment-41020

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match '❌ Stale'
        }

        It 'Should investigate when an old issue was modified within seven days' {
            $created = $script:now.AddDays(-8).ToOffset([timespan]::FromHours(-11)).ToString('o')
            $modified = $script:now.AddDays(-1).ToOffset([timespan]::FromHours(12)).ToString('o')
            Mock Invoke-ZtGraphRequest {
                @(New-TestHealthIssue -CreatedDateTime $created -LastModifiedDateTime $modified)
            }

            Test-Assessment-41020

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult | Should -Match '⚠️ In remediation'
        }

        It 'Should pass when the issue is not older than seven days' {
            $created = $script:now.AddDays(-6).ToOffset([timespan]::FromHours(10)).ToString('o')
            $modified = $script:now.AddDays(-1).ToOffset([timespan]::FromHours(-12)).ToString('o')
            Mock Invoke-ZtGraphRequest {
                @(New-TestHealthIssue -CreatedDateTime $created -LastModifiedDateTime $modified)
            }

            Test-Assessment-41020

            $script:capturedStatus | Should -BeTrue
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match '✅ OK'
        }
    }

    Context 'At the seven-day boundary' {
        It 'Should pass for an issue exactly seven days old' {
            $created = $script:now.AddDays(-7).ToString('o')
            Mock Invoke-ZtGraphRequest {
                @(New-TestHealthIssue -CreatedDateTime $created -LastModifiedDateTime $created)
            }

            Test-Assessment-41020

            $script:capturedStatus | Should -BeTrue
            $script:capturedResult | Should -Match '✅ OK'
        }

        It 'Should fail for an issue slightly older than seven days with no recent modification' {
            $created = $script:now.AddDays(-7).AddSeconds(-1).ToString('o')
            Mock Invoke-ZtGraphRequest {
                @(New-TestHealthIssue -CreatedDateTime $created -LastModifiedDateTime $created)
            }

            Test-Assessment-41020

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match '❌ Stale'
        }
    }

    Context 'When timestamps are missing or malformed' {
        It 'Should conservatively fail an issue with missing timestamps' {
            Mock Invoke-ZtGraphRequest {
                @(New-TestHealthIssue -DisplayName 'Missing timestamps')
            }

            Test-Assessment-41020

            $script:capturedStatus | Should -BeFalse
            $script:capturedResult | Should -Match '❌ Stale'
        }

        It 'Should conservatively fail an issue with malformed timestamps instead of throwing' {
            Mock Invoke-ZtGraphRequest {
                @(New-TestHealthIssue -CreatedDateTime 'not-a-date' -LastModifiedDateTime 'also-not-a-date' -DisplayName 'Malformed timestamps')
            }

            { Test-Assessment-41020 } | Should -Not -Throw
            $script:capturedStatus | Should -BeFalse
            $script:capturedResult | Should -Match '❌ Stale'
        }
    }

    Context 'When Microsoft Graph returns HTTP 403' {
        It 'Should investigate a structured UnknownError response' {
            $script:queryError = New-TestGraphError -ResponseBody '{"error":{"code":"UnknownError","message":"Forbidden"}}'
            Mock Invoke-ZtGraphRequest {
                $PSCmdlet.ThrowTerminatingError($script:queryError)
            }

            Test-Assessment-41020

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult | Should -Match 'error code: UnknownError'
        }

        It 'Should investigate an unparseable response instead of skipping the test' {
            $script:queryError = New-TestGraphError -ResponseBody 'not-json'
            Mock Invoke-ZtGraphRequest {
                $PSCmdlet.ThrowTerminatingError($script:queryError)
            }

            Test-Assessment-41020

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult | Should -Match 'error code could not be determined'
        }
    }

    Context 'When stale and recently modified issues are returned together' {
        It 'Should apply fail-wins precedence and retain remediation context' {
            $staleCreated = $script:now.AddDays(-10).ToString('o')
            $recentlyModified = $script:now.AddDays(-1).ToString('o')
            Mock Invoke-ZtGraphRequest {
                @(
                    New-TestHealthIssue -CreatedDateTime $staleCreated -LastModifiedDateTime $staleCreated -DisplayName 'Stale issue'
                    New-TestHealthIssue -CreatedDateTime $staleCreated -LastModifiedDateTime $recentlyModified -DisplayName 'Active remediation'
                )
            }

            Test-Assessment-41020

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'Stale issue'
            $script:capturedResult | Should -Match '❌ Stale'
            $script:capturedResult | Should -Match 'Active remediation'
            $script:capturedResult | Should -Match '⚠️ Investigate'
        }
    }

    Context 'When more than ten issues are returned' {
        It 'Should sort by exact age, show the oldest ten, and report truncation' {
            $script:issues = @(foreach ($ageDays in 1..12) {
                $timestamp = $script:now.AddDays(-$ageDays).ToString('o')
                New-TestHealthIssue -CreatedDateTime $timestamp -LastModifiedDateTime $timestamp -DisplayName ('Issue-{0:d2}' -f $ageDays)
            })
            Mock Invoke-ZtGraphRequest { $script:issues }

            Test-Assessment-41020

            $script:capturedStatus | Should -BeFalse
            $script:capturedResult | Should -Match 'Showing 10 of 12 issues'
            $script:capturedResult | Should -Match 'Issue-12'
            $script:capturedResult | Should -Match 'Issue-03'
            $script:capturedResult | Should -Not -Match 'Issue-02'
            $script:capturedResult | Should -Not -Match 'Issue-01'
            $script:capturedResult | Should -Match '\| \.\.\. \| \.\.\. \|'
        }
    }
}
