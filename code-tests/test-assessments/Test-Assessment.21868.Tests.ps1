Describe 'Test-Assessment-21868' {
    BeforeAll {
        $srcRoot = Join-Path $PSScriptRoot '../../src/powershell'

        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function global:Write-PSFMessage {}
        }

        if (-not ('ZtTest' -as [type])) {
            . (Join-Path $srcRoot 'classes/ZtTest.ps1')
        }

        . (Join-Path $srcRoot 'tests/Test-Assessment.21868.ps1')
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
    }

    It 'fails and reports guest application owners from cached owner data' {
        Mock Invoke-DatabaseQuery {
            param($Database, $Sql)
            $Sql | Should -Match 'json_type\(owners\) = ''ARRAY'''
            $Sql | Should -Match 'json_array\(owners\)'

            if ($Sql -match 'from Application') {
                return @{ id = 'guest-1'; displayName = 'Guest User'; userPrincipalName = 'guest@contoso.com'; appDisplayName = 'App One'; appObjectId = 'app-object-1'; appId = 'app-id-1' }
            }

            return @()
        }
        Mock Invoke-ZtGraphRequest { throw 'The assessment must only query cached data.' }
        Mock Add-ZtTestResultDetail {}

        Test-Assessment-21868 -Database 'test-database'

        Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
            $Status -eq $false -and $Result -match 'Guest User' -and $Result -match 'App One'
        }
        Should -Invoke Invoke-ZtGraphRequest -Times 0 -Exactly
    }

    It 'fails and reports guest service principal owners from cached owner data' {
        Mock Invoke-DatabaseQuery {
            param($Database, $Sql)
            if ($Sql -match 'from Application') {
                return @()
            }

            return @{ id = 'guest-2'; displayName = 'Guest User'; userPrincipalName = 'guest@contoso.com'; spDisplayName = 'Service Principal One'; spObjectId = 'sp-object-1'; spAppId = 'sp-app-id-1' }
        }
        Mock Add-ZtTestResultDetail {}

        Test-Assessment-21868 -Database 'test-database'

        Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
            $Status -eq $false -and $Result -match 'Guest User' -and $Result -match 'Service Principal One'
        }
    }

    It 'handles persisted owner arrays and objects' {
        $database = [DuckDB.NET.Data.DuckDBConnection]::new('DataSource=:memory:')
        $database.Open()
        try {
            $command = $database.CreateCommand()
            $command.CommandText = @'
create table User (id varchar, displayName varchar, userPrincipalName varchar, userType varchar);
create table Application (id varchar, appId varchar, displayName varchar, owners json);
create table ServicePrincipal (id varchar, appId varchar, displayName varchar, owners json);
insert into User values ('guest-1', 'Guest User', 'guest@contoso.com', 'Guest');
insert into Application values ('app-object-1', 'app-id-1', 'Array App', '[{"id":"guest-1"}]');
insert into ServicePrincipal values ('sp-object-1', 'sp-app-id-1', 'Object Service Principal', '{"id":"guest-1"}');
'@
            $command.ExecuteNonQuery() | Out-Null
            $command.Dispose()

            Mock Add-ZtTestResultDetail {}

            Test-Assessment-21868 -Database $database

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $Status -eq $false -and
                $Result -match 'Array App' -and
                $Result -match 'Object Service Principal'
            }
        }
        finally {
            $database.Dispose()
        }
    }

    It 'passes when cached ownership data has no guest owners' {
        Mock Invoke-DatabaseQuery { return @() }
        Mock Invoke-ZtGraphRequest { throw 'The assessment must only query cached data.' }
        Mock Add-ZtTestResultDetail {}

        Test-Assessment-21868 -Database 'test-database'

        Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
            $Status -eq $true -and $Result -eq 'No guest users own any applications or service principals in the tenant.'
        }
        Should -Invoke Invoke-ZtGraphRequest -Times 0 -Exactly
    }
}
