Describe 'Test-Assessment-21825' {
    BeforeAll {
        $srcRoot = Join-Path $PSScriptRoot '../../src/powershell'
        if (-not ('ZtTest' -as [type])) {
            . (Join-Path $srcRoot 'classes/ZtTest.ps1')
        }
        if (-not (Get-Command Write-PSFMessage -ListImported -ErrorAction SilentlyContinue)) {
            function Write-PSFMessage {}
        }
        foreach ($path in @(
            'private/core/Write-ZtProgress.ps1'
            'private/core/Add-ZtTestResultDetail.ps1'
            'private/graph/Get-ZtLicense.ps1'
            'private/graph/Get-ZtRole.ps1'
            'public/Invoke-ZtGraphRequest.ps1'
            'tests/Test-Assessment.21825.ps1'
        )) {
            . (Join-Path $srcRoot $path)
        }
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-ZtLicense { $true }
        Mock Get-ZtRole { @([pscustomobject]@{ id = 'role-1'; displayName = 'Privileged Role' }) }
        $script:policy = [pscustomobject]@{
            id = 'policy-1'
            displayName = 'Session policy'
            state = 'enabled'
            conditions = @{ users = @{ includeRoles = @('role-1') } }
            sessionControls = @{
                signInFrequency = @{
                    isEnabled = $true
                    frequencyInterval = 'timeBased'
                    type = 'hours'
                    value = 4
                }
            }
        }
        Mock Invoke-ZtGraphRequest { @($script:policy) }
        $script:result = $null
        Mock Add-ZtTestResultDetail {
            param($Status, $Result, $SkippedBecause)
            $script:result = @{ Status = $Status; Markdown = $Result; SkippedBecause = $SkippedBecause }
        }
    }

    It 'evaluates <Name> consistently in the verdict, count, role status, and policy row' -ForEach @(
        @{ Name = 'every time'; Interval = 'everyTime'; Type = $null; Value = $null; Enabled = $true; Expected = $true; Display = 'Every time' }
        @{ Name = 'every time with stale periodic fields'; Interval = 'everyTime'; Type = 'days'; Value = 30; Enabled = $true; Expected = $true; Display = 'Every time' }
        @{ Name = 'one hour'; Interval = 'timeBased'; Type = 'hours'; Value = 1; Enabled = $true; Expected = $true; Display = '1 hours' }
        @{ Name = 'four hours'; Interval = 'timeBased'; Type = 'hours'; Value = 4; Enabled = $true; Expected = $true; Display = '4 hours' }
        @{ Name = 'five hours'; Interval = 'timeBased'; Type = 'hours'; Value = 5; Enabled = $true; Expected = $false; Display = '5 hours' }
        @{ Name = 'one day'; Interval = 'timeBased'; Type = 'days'; Value = 1; Enabled = $true; Expected = $false; Display = '1 days' }
        @{ Name = 'disabled every time'; Interval = 'everyTime'; Type = $null; Value = $null; Enabled = $false; Expected = $false; Display = 'Disabled' }
        @{ Name = 'disabled four hours'; Interval = 'timeBased'; Type = 'hours'; Value = 4; Enabled = $false; Expected = $false; Display = 'Disabled' }
        @{ Name = 'every time without enablement'; Interval = 'everyTime'; Type = $null; Value = $null; Enabled = $null; Expected = $false; Display = 'Disabled' }
        @{ Name = 'unknown interval'; Interval = 'unknownFutureValue'; Type = 'hours'; Value = 4; Enabled = $true; Expected = $false; Display = '4 hours' }
        @{ Name = 'default periodic interval'; Interval = $null; Type = 'hours'; Value = 4; Enabled = $true; Expected = $true; Display = '4 hours' }
    ) {
        $script:policy.sessionControls.signInFrequency = @{
            isEnabled = $Enabled
            frequencyInterval = $Interval
            type = $Type
            value = $Value
        }

        Test-Assessment-21825

        $script:result.Status | Should -Be $Expected
        $count = [int]$Expected
        $script:result.Markdown | Should -Match ([regex]::Escape("**Policies with Compliant Frequency (≤4 hours):** $count"))
        $roleStatus = if ($Expected) { '✅ Covered' } else { '❌ Not Covered' }
        $script:result.Markdown | Should -Match ([regex]::Escape("**Status:** $roleStatus"))
        $marker = if ($Expected) { '✅' } else { '(?:❌|⚠️)' }
        $script:result.Markdown | Should -Match ("\| " + [regex]::Escape($Display) + " \| $marker")
    }

    It 'does not count or accept <State> every-time policies' -ForEach @(
        @{ State = 'disabled' }
        @{ State = 'enabledForReportingButNotEnforced' }
    ) {
        $script:policy.state = $State
        $script:policy.sessionControls.signInFrequency.frequencyInterval = 'everyTime'

        Test-Assessment-21825

        $script:result.Status | Should -BeFalse
        $script:result.Markdown | Should -Match ([regex]::Escape('**Policies with Compliant Frequency (≤4 hours):** 0'))
    }

    It 'requires compliant coverage for every privileged role' {
        Mock Get-ZtRole {
            @(
                [pscustomobject]@{ id = 'role-1'; displayName = 'Covered Role' }
                [pscustomobject]@{ id = 'role-2'; displayName = 'Uncovered Role' }
            )
        }
        $script:policy.sessionControls.signInFrequency.frequencyInterval = 'everyTime'

        Test-Assessment-21825

        $script:result.Status | Should -BeFalse
        $script:result.Markdown | Should -Match '✅ Covered'
        $script:result.Markdown | Should -Match '❌ No CA policies assigned'
    }

    It 'preserves the P1-only periodic limit of 24 hours' {
        Mock Get-ZtLicense { $Product -eq 'EntraIDP1' }
        $script:policy.sessionControls.signInFrequency.value = 24

        Test-Assessment-21825

        $script:result.Status | Should -BeTrue
        $script:result.Markdown | Should -Match ([regex]::Escape('**Policies with Compliant Frequency (≤24 hours):** 1'))
    }

    It 'passes with every-time coverage while reporting a noncompliant policy for the same role' {
        $script:policy.sessionControls.signInFrequency.frequencyInterval = 'everyTime'
        Mock Invoke-ZtGraphRequest {
            @(
                $script:policy
                [pscustomobject]@{
                    id = 'policy-2'
                    displayName = 'Long session policy'
                    state = 'enabled'
                    conditions = @{ users = @{ includeRoles = @('role-1') } }
                    sessionControls = @{
                        signInFrequency = @{ isEnabled = $true; frequencyInterval = 'timeBased'; type = 'hours'; value = 8 }
                    }
                }
            )
        }

        Test-Assessment-21825

        $script:result.Status | Should -BeTrue
        $script:result.Markdown | Should -Match ([regex]::Escape('**Policies with Compliant Frequency (≤4 hours):** 1'))
        $script:result.Markdown | Should -Match '\| Every time \| ✅ \|'
        $script:result.Markdown | Should -Match '\| 8 hours \| ⚠️ \(8h > 4h\) \|'
    }

    It 'fails when sign-in frequency is not configured' {
        $script:policy.sessionControls = $null

        Test-Assessment-21825

        $script:result.Status | Should -BeFalse
        $script:result.Markdown | Should -Match '\| Not Configured \| ❌ \|'
    }
}
