Describe 'Test-Assessment-21801' {
    BeforeAll {
        $srcRoot = Join-Path $PSScriptRoot '../../src/powershell'

        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function global:Write-PSFMessage {}
        }

        if (-not ('ZtTest' -as [type])) {
            . (Join-Path $srcRoot 'classes/ZtTest.ps1')
        }

        . (Join-Path $srcRoot 'tests/Test-Assessment.21801.ps1')
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-ZtLicense { $true }
        Mock Get-ZtLicenseInformation { 'P2' }
        Mock Invoke-DatabaseQuery { $script:testResults }
        Mock Get-FormattedDate { 'Unknown' }
        Mock Add-ZtTestResultDetail {
            param($Status, $Result)
            $script:capturedStatus = $Status
            $script:capturedResult = $Result
        }
        $script:testResults = @()
        $script:capturedStatus = $null
        $script:capturedResult = $null
    }

    It 'passes with no users and omits the empty failure table' {
        $script:testResults = @()

        Test-Assessment-21801 -Database 'test-database'

        $script:capturedStatus | Should -Be $true
        $script:capturedResult | Should -Match 'Total users assessed: 0'
        $script:capturedResult | Should -Match 'Users with phishing-resistant authentication methods: 0'
        $script:capturedResult | Should -Match 'Users without phishing-resistant authentication methods: 0'
        $script:capturedResult | Should -Not -Match 'User \| Last sign in'
    }

    It 'passes when all users have phishing-resistant methods and omits the failure table' {
        $script:testResults = 1..3 | ForEach-Object {
            [pscustomobject]@{
                id                              = "user-$_"
                displayName                     = 'User {0:D3}' -f $_
                phishResistantAuthMethod        = $true
                lastSuccessfulSignInDateTime    = $null
            }
        }

        Test-Assessment-21801 -Database 'test-database'

        $script:capturedStatus | Should -Be $true
        $script:capturedResult | Should -Match 'Total users assessed: 3'
        $script:capturedResult | Should -Match 'Users with phishing-resistant authentication methods: 3'
        $script:capturedResult | Should -Match 'Users without phishing-resistant authentication methods: 0'
        $script:capturedResult | Should -Not -Match 'User \| Last sign in'
    }

    It 'fails for mixed results and reports only users without phishing-resistant methods' {
        $script:testResults = @(
            [pscustomobject]@{
                id = 'user-pass'
                displayName = 'Compliant User'
                phishResistantAuthMethod = $true
                lastSuccessfulSignInDateTime = $null
            },
            [pscustomobject]@{
                id = 'user-fail'
                displayName = 'Noncompliant User'
                phishResistantAuthMethod = $false
                lastSuccessfulSignInDateTime = $null
            }
        )

        Test-Assessment-21801 -Database 'test-database'

        $script:capturedStatus | Should -Be $false
        $script:capturedResult | Should -Match 'Total users assessed: 2'
        $script:capturedResult | Should -Match 'Users with phishing-resistant authentication methods: 1'
        $script:capturedResult | Should -Match 'Users without phishing-resistant authentication methods: 1'
        $script:capturedResult | Should -Match '\[Noncompliant User\]'
        $script:capturedResult | Should -Not -Match '\[Compliant User\]'
        ([regex]::Matches($script:capturedResult, 'Found users that have not')).Count | Should -Be 1
    }

    It 'reports exactly 50 failing users without an omitted-users note' {
        $script:testResults = 1..50 | ForEach-Object {
            [pscustomobject]@{
                id                              = "user-$_"
                displayName                     = 'User {0:D3}' -f $_
                phishResistantAuthMethod        = $false
                lastSuccessfulSignInDateTime    = $null
            }
        }

        Test-Assessment-21801 -Database 'test-database'

        $script:capturedStatus | Should -Be $false
        $script:capturedResult | Should -Match 'Total users assessed: 50'
        $script:capturedResult | Should -Match 'Users without phishing-resistant authentication methods: 50'
        ([regex]::Matches($script:capturedResult, '\[User \d{3}\]')).Count | Should -Be 50
        $script:capturedResult | Should -Not -Match 'more were omitted'
    }

    It 'reports only 50 of 52 failing users and states how many were omitted' {
        $script:testResults = 1..52 | ForEach-Object {
            [pscustomobject]@{
                id                              = "user-$_"
                displayName                     = 'User {0:D3}' -f $_
                phishResistantAuthMethod        = $false
                lastSuccessfulSignInDateTime    = $null
            }
        }

        Test-Assessment-21801 -Database 'test-database'

        $script:capturedStatus | Should -Be $false
        $script:capturedResult | Should -Match 'Total users assessed: 52'
        $script:capturedResult | Should -Match 'Users without phishing-resistant authentication methods: 52'
        $script:capturedResult | Should -Match 'Showing 50 of 52 users.*2 more omitted\.'
        ([regex]::Matches($script:capturedResult, '\[User \d{3}\]')).Count | Should -Be 50
        $script:capturedResult | Should -Not -Match '\[User 051\]'
        $script:capturedResult | Should -Not -Match '\[User 052\]'
    }

    It 'fails when a noncompliant user appears after the first 50 assessed users' {
        $script:testResults = @(1..50 | ForEach-Object {
            [pscustomobject]@{
                id                              = "user-$_"
                displayName                     = 'User {0:D3}' -f $_
                phishResistantAuthMethod        = $true
                lastSuccessfulSignInDateTime    = $null
            }
        })
        $script:testResults += [pscustomobject]@{
            id = 'user-051'
            displayName = 'User 051'
            phishResistantAuthMethod = $false
            lastSuccessfulSignInDateTime = $null
        }

        Test-Assessment-21801 -Database 'test-database'

        $script:capturedStatus | Should -Be $false
        $script:capturedResult | Should -Match 'Total users assessed: 51'
        $script:capturedResult | Should -Match 'Users with phishing-resistant authentication methods: 50'
        $script:capturedResult | Should -Match 'Users without phishing-resistant authentication methods: 1'
        $script:capturedResult | Should -Match '\[User 051\]'
        ([regex]::Matches($script:capturedResult, '\[User \d{3}\]')).Count | Should -Be 1
    }
}
