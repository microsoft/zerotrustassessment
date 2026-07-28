Describe 'Test-Assessment-27022' {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here '../../src/powershell'
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) { function global:Write-PSFMessage {} }
        if (-not (Get-Command Write-ZtProgress -ErrorAction SilentlyContinue)) { function global:Write-ZtProgress {} }
        if (-not (Get-Command Get-SafeMarkdown -ErrorAction SilentlyContinue)) { function global:Get-SafeMarkdown { param($Text) return $Text } }
        if (-not (Get-Command Get-ZtTestResultDetail -ErrorAction SilentlyContinue)) { function global:Get-ZtTestResultDetail { param($TestId) } }
        if (-not (Get-Command Add-ZtTenantInfo -ErrorAction SilentlyContinue)) { function global:Add-ZtTenantInfo { param($Name, $Value) } }
        if (-not (Get-Command Add-ZtTestResultDetail -ErrorAction SilentlyContinue)) {
            function global:Add-ZtTestResultDetail { param($TestId, $Status, $Result, $Data, $CustomStatus) }
        }
        if (-not ('ZtTest' -as [type])) { . (Join-Path $srcRoot 'classes/ZtTest.ps1') }
        . (Join-Path $srcRoot 'tests/Test-Assessment.27022.ps1')
        . (Join-Path $srcRoot 'private/tenantinfo/Add-ZtOverviewM365ProtectionCircuit.ps1')
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
        Mock Add-ZtTestResultDetail {}
    }

    It 'passes when acquisition and enforcement both pass' {
        Mock Get-ZtTestResultDetail {
            if ($TestId -eq '25376') { return @{ TestStatus = 'Passed'; TestData = @{ totalDeviceCount = 100; activeDeviceCount = 72; profileEnabled = $true } } }
            return @{ TestStatus = 'Passed' }
        }

        Test-Assessment-27022

        Assert-MockCalled Add-ZtTestResultDetail -Scope It -ParameterFilter {
            $Status -eq $true -and $Result -match 'acquired by Global Secure Access' -and $Data.countsAvailable
        }
    }

    It 'fails and explains the dependency when acquisition fails' {
        Mock Get-ZtTestResultDetail {
            if ($TestId -eq '25376') { return @{ TestStatus = 'Failed'; TestData = @{ totalDeviceCount = 100; activeDeviceCount = 0; profileEnabled = $false } } }
            return @{ TestStatus = 'Passed' }
        }

        Test-Assessment-27022

        Assert-MockCalled Add-ZtTestResultDetail -Scope It -ParameterFilter { $Status -eq $false -and -not $CustomStatus -and $Result -match 'never generated' }
    }

    It 'fails when enforcement is open after successful acquisition' {
        Mock Get-ZtTestResultDetail {
            if ($TestId -eq '25376') { return @{ TestStatus = 'Passed'; TestData = @{ totalDeviceCount = 100; activeDeviceCount = 72; profileEnabled = $true } } }
            return @{ TestStatus = 'Failed' }
        }

        Test-Assessment-27022

        Assert-MockCalled Add-ZtTestResultDetail -Scope It -ParameterFilter { $Status -eq $false -and $Result -match 'uncontrolled networks' -and -not $CustomStatus }
    }

    It 'propagates an investigate result when no stage fails' {
        Mock Get-ZtTestResultDetail {
            if ($TestId -eq '25376') { return @{ TestStatus = 'Passed'; TestData = @{ totalDeviceCount = 0; activeDeviceCount = 0; profileEnabled = $true } } }
            return @{ TestStatus = 'Investigate' }
        }

        Test-Assessment-27022

        Assert-MockCalled Add-ZtTestResultDetail -Scope It -ParameterFilter { $Status -eq $false -and $CustomStatus -eq 'Investigate' -and -not $Data.countsAvailable }
    }

    It 'surfaces not-applicable child results as investigate rather than failing' {
        Mock Get-ZtTestResultDetail {
            if ($TestId -eq '25376') { return @{ TestStatus = 'Skipped'; TestData = @{ totalDeviceCount = 0; activeDeviceCount = 0; profileEnabled = $false } } }
            return @{ TestStatus = 'Passed' }
        }

        Test-Assessment-27022

        Assert-MockCalled Add-ZtTestResultDetail -Scope It -ParameterFilter { $Status -eq $false -and $CustomStatus -eq 'Investigate' }
    }

    It 'returns investigate rather than pass when a child returns Error' {
        Mock Get-ZtTestResultDetail {
            if ($TestId -eq '25376') { return @{ TestStatus = 'Passed'; TestData = @{ totalDeviceCount = 100; activeDeviceCount = 72; profileEnabled = $true } } }
            return @{ TestStatus = 'Error' }
        }

        Test-Assessment-27022

        Assert-MockCalled Add-ZtTestResultDetail -Scope It -ParameterFilter { $Status -eq $false -and $CustomStatus -eq 'Investigate' }
    }
}

Describe 'Add-ZtOverviewM365ProtectionCircuit' {
    BeforeEach {
        Mock Add-ZtTenantInfo {}
    }

    It 'sizes the acquired and protected bands from active and total device counts' {
        Mock Get-ZtTestResultDetail {
            @{ TestData = @{ acquisitionStatus = 'Passed'; enforcementStatus = 'Passed'; countsAvailable = $true; totalDeviceCount = 100; activeDeviceCount = 72; profileEnabled = $true } }
        }

        Add-ZtOverviewM365ProtectionCircuit

        Assert-MockCalled Add-ZtTenantInfo -Scope It -ParameterFilter {
            $Name -eq 'OverviewM365ProtectionCircuit' -and
            ($Value.nodes | Where-Object { $_.target -eq 'Unprotected - not acquired (25376)' }).value -eq 28 -and
            ($Value.nodes | Where-Object { $_.target -eq 'Enforced - compliant network (25379)' }).value -eq 72
        }
    }

    It 'routes the acquired band to the unprotected terminal when enforcement fails' {
        Mock Get-ZtTestResultDetail {
            @{ TestData = @{ acquisitionStatus = 'Passed'; enforcementStatus = 'Failed'; countsAvailable = $true; totalDeviceCount = 100; activeDeviceCount = 72; profileEnabled = $true } }
        }

        Add-ZtOverviewM365ProtectionCircuit

        Assert-MockCalled Add-ZtTenantInfo -Scope It -ParameterFilter {
            ($Value.nodes | Where-Object { $_.target -eq 'Acquired but not enforced (25379)' }).value -eq 72
        }
    }

    It 'uses the normalized all-or-nothing flow when acquisition counts are unavailable' {
        Mock Get-ZtTestResultDetail {
            @{ TestData = @{ acquisitionStatus = 'Passed'; enforcementStatus = 'Passed'; countsAvailable = $false; totalDeviceCount = 0; activeDeviceCount = 0; profileEnabled = $true } }
        }

        Add-ZtOverviewM365ProtectionCircuit

        Assert-MockCalled Add-ZtTenantInfo -Scope It -ParameterFilter {
            $Value.totalDevices -eq 100 -and
            ($Value.nodes | Where-Object { $_.target -eq 'Enforced - compliant network (25379)' }).value -eq 100 -and
            $Value.description -match 'normalized all-or-nothing'
        }
    }
}
