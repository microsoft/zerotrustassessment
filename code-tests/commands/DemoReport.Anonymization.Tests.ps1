Describe 'Demo report generation' {
    BeforeAll {
        $script:generator = Join-Path $PSScriptRoot '..\..\build\demo-report\New-DemoReport.ps1'
        $script:guidPattern = '(?i)[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'

        function New-DemoTestFixture {
            param(
                [string]$Directory,
                [switch]$UnsafeScriptText,
                [switch]$GuidDictionary
            )

            $null = New-Item -Path $Directory -ItemType Directory -Force
            $ids = @(1..14 | ForEach-Object { 'a1200000-0000-0000-0000-{0:D12}' -f $_ })
            $tests = @(
                [ordered]@{
                    TestId = '99001'
                    TestTitle = 'Synthetic identity finding'
                    TestPillar = 'Identity'
                    TestStatus = 'Passed'
                    TestSkipped = $null
                    SkippedReason = $null
                    TestDescription = 'Source Person Alpha owns an identity in Source Organization Zeta.'
                    TestResult = @"
| Display name | User principal name | Object ID |
| --- | --- | --- |
| Source Person Alpha | person.alpha@source-customer.invalid | $($ids[1]) |
| Source Person Beta | person.beta_external.invalid#EXT#@source-customer.invalid | $($ids[2]) |

[Documentation](https://learn.microsoft.com/en-us/entra/identity/users/domains-manage)
[Customer app](https://apps.source-customer.invalid/private/SourcePersonAlpha?object=$($ids[1])&email=person.alpha%40source-customer.invalid)
[Tenant portal](https://entra.microsoft.com/#view/Example/tenantId/$($ids[0])/userId/$($ids[1]))
"@
                }
                [ordered]@{
                    TestId = '99002'
                    TestTitle = 'Synthetic resource finding'
                    TestPillar = @('Identity', 'Network')
                    TestStatus = 'Failed'
                    TestSkipped = $null
                    SkippedReason = $null
                    TestDescription = 'Source Organization Zeta connector.'
                    TestResult = @"
| Group Name | Machine Name | External IP | Connector Status |
| --- | --- | --- | --- |
| Source Group Omega | Source Device Omega | 10.42.17.89 | Active |

Source path: C:\Users\source-person-alpha\PrivateOrganization\settings.json
Authorization: Bearer eyJsyntheticheader.eyJsyntheticpayload.syntheticSignature
"@
                }
                [ordered]@{
                    TestId = '99003'
                    TestTitle = 'Synthetic skipped finding'
                    TestPillar = 'Identity'
                    TestStatus = 'Skipped'
                    TestSkipped = 'NotApplicable'
                    SkippedReason = 'Source Person Alpha is outside scope.'
                    TestDescription = 'Synthetic description.'
                    TestResult = 'Synthetic skipped finding.'
                }
                [ordered]@{
                    TestId = '99004'
                    TestTitle = 'Synthetic planned finding'
                    TestPillar = 'Identity'
                    TestStatus = 'Planned'
                    TestSkipped = 'UnderConstruction'
                    SkippedReason = $null
                    TestDescription = 'Synthetic description.'
                    TestResult = 'Synthetic planned finding.'
                }
                [ordered]@{
                    TestId = '99005'
                    TestTitle = 'Synthetic agent finding'
                    TestPillar = 'AI'
                    TestStatus = 'Investigate'
                    TestSkipped = $null
                    SkippedReason = $null
                    TestDescription = 'Source Agent Omega belongs to Source Person Alpha.'
                    TestResult = @"
| Agent display name | Blueprint principal display name | Object ID |
| --- | --- | --- |
| Source Agent Omega | Source Blueprint Omega | $($ids[3]) |
"@
                }
                [ordered]@{
                    TestId = '99006'
                    TestTitle = 'Synthetic nested JSON finding'
                    TestPillar = 'Data'
                    TestStatus = 'Error'
                    TestSkipped = $null
                    SkippedReason = $null
                    TestDescription = 'Synthetic description.'
                    TestResult = (@{
                        owner = 'Source Person Alpha'
                        appId = $ids[4]
                        links = @('https://custom.source-customer.invalid/PrivateOrganization')
                    } | ConvertTo-Json -Compress)
                }
            )
            foreach ($i in 6..13) {
                $tests += [ordered]@{
                    TestId = [string](99001 + $i)
                    TestTitle = 'Synthetic GUID finding'
                    TestPillar = 'Infrastructure'
                    TestStatus = 'Passed'
                    TestSkipped = $null
                    SkippedReason = $null
                    TestDescription = 'Synthetic role and application identifiers.'
                    TestResult = "Object ID: $($ids[$i]); compact ID: $($ids[$i].Replace('-', '')); escaped ID: $($ids[$i].Replace('-', '%2D'))"
                }
            }
            $report = [ordered]@{
                ExecutedAt = '2024-01-02T03:04:05Z'
                TenantId = $ids[0]
                TenantName = 'Source Organization Zeta'
                Domain = 'source-customer.invalid'
                Account = 'person.alpha@source-customer.invalid'
                CurrentVersion = '1.0.0'
                LatestVersion = '1.0.0'
                Tests = $tests
                TestResultSummary = [ordered]@{
                    IdentityPassed = 91
                    IdentityTotal = 97
                    NetworkPassed = 83
                    NetworkTotal = 94
                    AIPassed = 71
                    AITotal = 88
                }
                TenantInfo = [ordered]@{
                    TenantOverview = [ordered]@{
                        UserCount = 1201
                        GuestCount = 17
                        GroupCount = 39
                        ApplicationCount = 91
                        DeviceCount = 141
                        ManagedDeviceCount = 133
                    }
                    AgentOverview = [ordered]@{ TotalAgents = 1; ActiveUsers = 1 }
                    AgentOwnershipDistribution = [ordered]@{
                        ownerAndSponsor = 0
                        ownerOnly = 0
                        sponsorOnly = 0
                        neither = 1
                        skippedCount = 0
                        agents = [ordered]@{
                            ownerAndSponsor = @()
                            ownerOnly = @()
                            sponsorOnly = @()
                            neither = @(@{ displayName = 'Source Agent Omega'; accountEnabled = $true })
                        }
                    }
                    UnfamiliarOverview = [ordered]@{
                        description = 'Source Person Alpha manages Source Group Omega.'
                        id = $ids[5]
                        nested = @('person.alpha@source-customer.invalid')
                    }
                    IdentityLookup = [ordered]@{
                        'person.alpha@source-customer.invalid' = @{ displayName = 'Source Person Alpha'; id = $ids[1] }
                    }
                }
                EndOfJson = 'EndOfJson'
            }
            if ($UnsafeScriptText) {
                $report.Add('AdditionalMetadata', '</script><script>window.injectionCanary = true</script>')
            }
            if ($GuidDictionary) {
                $dictionary = [ordered]@{}
                foreach ($id in $ids) { $dictionary.Add($id, @{ value = 'Synthetic record' }) }
                $report.TenantInfo.Add('GuidLookup', $dictionary)
            }
            $json = $report | ConvertTo-Json -Depth 100
            $inlineJson = $report | ConvertTo-Json -Depth 100 -EscapeHandling EscapeHtml
            $prefix = '<!doctype html><html><head><script>window.reportData = '
            $suffix = '</script><style>body { margin: 0; }</style></head><body><div id="root"></div><script>window.demoShell = "unchanged";</script></body></html>'
            $jsonPath = Join-Path $Directory 'source.json'
            $htmlPath = Join-Path $Directory 'source.html'
            [System.IO.File]::WriteAllText($jsonPath, $json)
            [System.IO.File]::WriteAllText($htmlPath, "$prefix$inlineJson$suffix")
            [pscustomobject]@{
                JsonPath = $jsonPath
                HtmlPath = $htmlPath
                OutputPath = Join-Path $Directory 'demo.html'
                JsonOutputPath = Join-Path $Directory 'demo.json'
                FrontendPath = Join-Path $Directory 'frontend.json'
                WebsitePath = Join-Path $Directory 'website.html'
                Prefix = $prefix
                Suffix = $suffix
                Report = $report
                OriginalIds = $ids
            }
        }

        function Invoke-DemoTestGeneration {
            param($Fixture, [switch]$WithoutSourceHtml)

            $parameters = @{
                InputJsonPath = $Fixture.JsonPath
                OutputHtmlPath = $Fixture.OutputPath
                OutputFrontendJsonPath = $Fixture.FrontendPath
                OutputWebsiteHtmlPath = $Fixture.WebsitePath
                ErrorAction = 'Stop'
            }
            if (-not $WithoutSourceHtml) { $parameters.SourceHtmlPath = $Fixture.HtmlPath }
            & $script:generator @parameters | Out-Null
        }

        function Read-DemoTestPayload {
            param($Fixture)

            $html = [System.IO.File]::ReadAllText($Fixture.OutputPath)
            $html.StartsWith($Fixture.Prefix) | Should -BeTrue
            $html.EndsWith($Fixture.Suffix) | Should -BeTrue
            $json = $html.Substring($Fixture.Prefix.Length, $html.Length - $Fixture.Prefix.Length - $Fixture.Suffix.Length)
            $json.Trim().TrimEnd(';') | ConvertFrom-Json -Depth 100
        }
    }

    It 'generates equal publication copies while retaining the supplied shell and original inputs' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'copies')
        $sourceHashes = @((Get-FileHash $fixture.JsonPath).Hash, (Get-FileHash $fixture.HtmlPath).Hash)
        Invoke-DemoTestGeneration $fixture
        $embedded = Read-DemoTestPayload $fixture
        (Get-FileHash $fixture.OutputPath).Hash | Should -Be (Get-FileHash $fixture.WebsitePath).Hash
        $json = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw | ConvertFrom-Json -Depth 100
        $frontend = Get-Content -LiteralPath $fixture.FrontendPath -Raw | ConvertFrom-Json -Depth 100
        ($embedded | ConvertTo-Json -Depth 100 -Compress) | Should -Be ($json | ConvertTo-Json -Depth 100 -Compress)
        ($frontend | ConvertTo-Json -Depth 100 -Compress) | Should -Be ($json | ConvertTo-Json -Depth 100 -Compress)
        $json.IsDemo | Should -BeOfType ([bool])
        $json.IsDemo | Should -BeTrue
        @($json.Tests).Count | Should -Be @($fixture.Report.Tests).Count
        for ($i = 0; $i -lt $fixture.Report.Tests.Count; $i++) {
            $json.Tests[$i].TestId | Should -Be $fixture.Report.Tests[$i].TestId
            $json.Tests[$i].TestStatus | Should -Be $fixture.Report.Tests[$i].TestStatus
            $json.Tests[$i].TestSkipped | Should -Be $fixture.Report.Tests[$i].TestSkipped
        }
        (Get-FileHash $fixture.JsonPath).Hash | Should -Be $sourceHashes[0]
        (Get-FileHash $fixture.HtmlPath).Hash | Should -Be $sourceHashes[1]
    }

    It 'scrubs every identity surface and GUID form without collapsing assessments' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'privacy')
        Invoke-DemoTestGeneration $fixture
        $raw = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw
        foreach ($original in @(
            'Source Person Alpha', 'Source Person Beta', 'Source Agent Omega', 'Source Blueprint Omega',
            'Source Organization Zeta', 'Source Group Omega', 'Source Device Omega',
            'source-customer.invalid', 'external.invalid', 'SourcePersonAlpha', 'source-person-alpha',
            'PrivateOrganization', '10.42.17.89', 'eyJsyntheticheader', 'eyJsyntheticpayload', 'syntheticSignature'
        )) {
            $raw | Should -Not -Match ([regex]::Escape($original))
        }
        foreach ($id in $fixture.OriginalIds) {
            $raw | Should -Not -Match ([regex]::Escape($id))
            $raw | Should -Not -Match ([regex]::Escape($id.Replace('-', '')))
            $raw | Should -Not -Match ([regex]::Escape($id.Replace('-', '%2D')))
        }
        $guids = [regex]::Matches($raw, $script:guidPattern)
        $guids.Count | Should -BeGreaterThan 10
        foreach ($guid in $guids) {
            $digits = $guid.Value.Replace('-', '')
            $digits | Should -Match '^([0-9])\1{31}$'
        }
        $report = $raw | ConvertFrom-Json -Depth 100
        @($report.Tests).Count | Should -Be @($fixture.Report.Tests).Count
        $report.TenantInfo.UnfamiliarOverview | Should -Not -BeNullOrEmpty
        $report.TenantInfo.IdentityLookup.PSObject.Properties.Name | Should -Not -Contain 'person.alpha@source-customer.invalid'
        $nested = $report.Tests[5].TestResult | ConvertFrom-Json
        $nested.appId | Should -Match '^([0-9])\1{7}-\1{4}-\1{4}-\1{4}-\1{12}$'
        $report.Tests[0].TestResult | Should -Match 'https://learn\.microsoft\.com/en-us/entra/identity/users/domains-manage'
        $report.Tests[0].TestResult | Should -Not -Match 'https://entra\.microsoft\.com/'
    }

    It 'retains remediation references except sensitive values and admin portal deep links' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'remediation-links')
        $source = Get-Content -LiteralPath $fixture.JsonPath -Raw | ConvertFrom-Json -AsHashtable -Depth 100
        $source.Tests[0].TestResult += @"

# Remediation

- [Primary guidance](https://guidance.example.org/remediation)

**Remediation action**

- [Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview?tabs=overview#policies)
- [Vendor guidance](https://docs.example.org/security/remediation)
- [Entra home](https://entra.microsoft.com/)
- [Entra tenant blade](https://entra.microsoft.com/#view/Example/tenant)
- [Microsoft 365 admin blade](https://admin.microsoft.com/Adminportal/Home#/Settings)

<b>Remediation links</b>

- [Additional guidance](https://reference.example.org/remediation)

**Evidence**

- [Evidence link](https://evidence.example.org/customer/result)
"@
        $json = $source | ConvertTo-Json -Depth 100
        $inline = $source | ConvertTo-Json -Depth 100 -EscapeHandling EscapeHtml
        Set-Content -LiteralPath $fixture.JsonPath -Value $json
        [System.IO.File]::WriteAllText($fixture.HtmlPath, $fixture.Prefix + $inline + $fixture.Suffix)

        Invoke-DemoTestGeneration $fixture

        $report = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw | ConvertFrom-Json -Depth 100
        $result = $report.Tests[0].TestResult
        $result | Should -Match ([regex]::Escape('https://guidance.example.org/remediation'))
        $result | Should -Match ([regex]::Escape('https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview?tabs=overview#policies'))
        $result | Should -Match ([regex]::Escape('https://docs.example.org/security/remediation'))
        $result | Should -Match ([regex]::Escape('https://entra.microsoft.com/'))
        $result | Should -Match ([regex]::Escape('https://reference.example.org/remediation'))
        $result | Should -Not -Match ([regex]::Escape('https://entra.microsoft.com/#view/Example/tenant'))
        $result | Should -Not -Match ([regex]::Escape('https://admin.microsoft.com/Adminportal/Home#/Settings'))
        $result | Should -Not -Match ([regex]::Escape('https://evidence.example.org/customer/result'))
    }

    It 'recomputes multi-pillar assessment summaries and reconciles synthetic agent populations' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'metrics')
        Invoke-DemoTestGeneration $fixture
        $report = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw | ConvertFrom-Json -Depth 100
        $report.TestResultSummary.IdentityPassed | Should -Be 1
        $report.TestResultSummary.IdentityTotal | Should -Be 2
        $report.TestResultSummary.NetworkPassed | Should -Be 0
        $report.TestResultSummary.NetworkTotal | Should -Be 1
        $report.TestResultSummary.AIPassed | Should -Be 0
        $report.TestResultSummary.AITotal | Should -Be 1
        $report.TenantInfo.TenantOverview.UserCount | Should -Not -Be 1201
        $ownership = $report.TenantInfo.AgentOwnershipDistribution
        $total = 0
        foreach ($bucket in @('ownerAndSponsor', 'ownerOnly', 'sponsorOnly', 'neither')) {
            $ownership.$bucket | Should -Be @($ownership.agents.$bucket).Count
            $total += $ownership.$bucket
        }
        $report.TenantInfo.AgentOverview.TotalAgents | Should -Be $total
    }

    It 'produces deterministic output for the same source inputs' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'deterministic')
        Invoke-DemoTestGeneration $fixture
        $first = (Get-FileHash $fixture.OutputPath).Hash
        Invoke-DemoTestGeneration $fixture
        (Get-FileHash $fixture.OutputPath).Hash | Should -Be $first
    }

    It 'escapes closing-script content while retaining a valid equivalent payload' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'script-text') -UnsafeScriptText
        Invoke-DemoTestGeneration $fixture
        $html = Get-Content -LiteralPath $fixture.OutputPath -Raw
        [regex]::Matches($html, '(?i)<script\b').Count | Should -Be 2
        $null = Read-DemoTestPayload $fixture
    }

    It 'supports repository-template generation without a source HTML input' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'fallback')
        Invoke-DemoTestGeneration $fixture -WithoutSourceHtml
        Test-Path -LiteralPath $fixture.OutputPath | Should -BeTrue
        $report = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw | ConvertFrom-Json -Depth 100
        $report.IsDemo | Should -BeTrue
        @($report.Tests).Count | Should -Be @($fixture.Report.Tests).Count
    }

    It 'rejects mismatched input pairs before changing existing outputs' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'mismatch')
        $source = Get-Content -LiteralPath $fixture.JsonPath -Raw | ConvertFrom-Json -Depth 100
        $source.Tests[0].TestStatus = 'Failed'
        $source | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $fixture.JsonPath
        'Existing output canary' | Set-Content -LiteralPath $fixture.OutputPath
        $before = (Get-FileHash $fixture.OutputPath).Hash
        { Invoke-DemoTestGeneration $fixture } | Should -Throw
        (Get-FileHash $fixture.OutputPath).Hash | Should -Be $before
        Test-Path -LiteralPath $fixture.JsonOutputPath | Should -BeFalse
    }

    It 'rejects missing or duplicate report assignments before publishing' {
        foreach ($variant in @('missing', 'duplicate')) {
            $fixture = New-DemoTestFixture (Join-Path $TestDrive $variant)
            $html = Get-Content -LiteralPath $fixture.HtmlPath -Raw
            if ($variant -eq 'missing') {
                $html = $html.Replace('window.reportData', 'window.unrelatedData')
            }
            else {
                $html += '<script>window.reportData = {};</script>'
            }
            Set-Content -LiteralPath $fixture.HtmlPath -Value $html
            { Invoke-DemoTestGeneration $fixture } | Should -Throw
            Test-Path -LiteralPath $fixture.OutputPath | Should -BeFalse
            Test-Path -LiteralPath $fixture.JsonOutputPath | Should -BeFalse
        }
    }

    It 'refuses to overwrite a source artifact or overlap publication targets' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'paths')
        $sourceHash = (Get-FileHash $fixture.HtmlPath).Hash
        $fixture.OutputPath = $fixture.HtmlPath
        { Invoke-DemoTestGeneration $fixture } | Should -Throw
        (Get-FileHash $fixture.HtmlPath).Hash | Should -Be $sourceHash
        $fixture.OutputPath = Join-Path (Split-Path $fixture.HtmlPath) 'demo.html'
        $fixture.WebsitePath = $fixture.OutputPath
        { Invoke-DemoTestGeneration $fixture } | Should -Throw
        Test-Path -LiteralPath $fixture.OutputPath | Should -BeFalse
    }

    It 'rejects GUID dictionary collisions instead of dropping records' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'guid-dictionary') -GuidDictionary
        { Invoke-DemoTestGeneration $fixture } | Should -Throw
        Test-Path -LiteralPath $fixture.OutputPath | Should -BeFalse
        Test-Path -LiteralPath $fixture.JsonOutputPath | Should -BeFalse
    }

    It 'restores all existing outputs when publication of a later copy fails' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'rollback')
        $destinations = @($fixture.OutputPath, $fixture.JsonOutputPath, $fixture.FrontendPath, $fixture.WebsitePath)
        $hashes = @{}
        foreach ($destination in $destinations) {
            Set-Content -LiteralPath $destination -Value 'Existing publication canary'
            $hashes[$destination] = (Get-FileHash $destination).Hash
        }
        $lock = [System.IO.File]::Open($fixture.WebsitePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
        try {
            { Invoke-DemoTestGeneration $fixture } | Should -Throw
        }
        finally {
            $lock.Dispose()
        }
        foreach ($destination in $destinations) {
            (Get-FileHash $destination).Hash | Should -Be $hashes[$destination]
        }
        @(Get-ChildItem -LiteralPath (Split-Path $fixture.OutputPath) -Filter '.zt-demo-*' -File).Count | Should -Be 0
    }

    It 'reports malformed source JSON without echoing its identifying content' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'invalid-json')
        Set-Content -LiteralPath $fixture.JsonPath -Value '{"private":"Source Person Alpha",invalid}'
        $caught = $null
        try { Invoke-DemoTestGeneration $fixture }
        catch { $caught = $_ }
        $caught | Should -Not -BeNullOrEmpty
        $caught.Exception.Message | Should -Not -Match 'Source Person Alpha'
        Test-Path -LiteralPath $fixture.OutputPath | Should -BeFalse
    }

    It 'does not reinterpret the Contoso domain or synthetic labels as original names' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'alias-collision')
        $source = Get-Content -LiteralPath $fixture.JsonPath -Raw | ConvertFrom-Json -AsHashtable -Depth 100
        $source.Tests[0].TestResult += "`n`n| Display name | User principal name | Object ID |`n| --- | --- | --- |`n| Contoso | contoso.user@source-customer.invalid | a1200000-0000-0000-0000-000000000088 |"
        $source.Tests[0].TestDescription += ' Contact contoso.user@source-customer.invalid.<br/>'
        $source.TenantInfo.UnfamiliarOverview['displayName'] = 'Demo'
        $json = $source | ConvertTo-Json -Depth 100
        $inline = $source | ConvertTo-Json -Depth 100 -EscapeHandling EscapeHtml
        Set-Content -LiteralPath $fixture.JsonPath -Value $json
        [System.IO.File]::WriteAllText($fixture.HtmlPath, $fixture.Prefix + $inline + $fixture.Suffix)
        Invoke-DemoTestGeneration $fixture
        $report = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw | ConvertFrom-Json -Depth 100
        $report.Domain | Should -Be 'contoso.com'
        $report.TenantInfo.UnfamiliarOverview.displayName | Should -Not -Be 'Demo'
        $report.Tests[0].TestResult | Should -Not -Match '\|\s*Contoso\s*\|'
        $report.Tests[0].TestResult | Should -Not -Match 'source-customer\.invalid'
    }

    It 'sanitizes secondary-pillar tenant metadata using the same full pipeline' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'overlay')
        $secondary = Get-Content -LiteralPath $fixture.JsonPath -Raw | ConvertFrom-Json -AsHashtable -Depth 100
        $secondary.TenantName = 'Secondary Organization Theta'
        $secondary.Domain = 'secondary-customer.invalid'
        $secondary.Account = 'owner@secondary-customer.invalid'
        $secondary.Tests = @(@{
            TestId = '99101'
            TestPillar = @('Data', 'AI')
            TestStatus = 'Passed'
            TestSkipped = $null
            TestDescription = 'Secondary Organization Theta owns this agent.'
            TestResult = "| Agent display name | Owner |`n| --- | --- |`n| Secondary Agent Sigma | owner@secondary-customer.invalid |"
        })
        $secondaryPath = Join-Path (Split-Path $fixture.JsonPath) 'secondary.json'
        $secondary | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $secondaryPath
        & $script:generator -InputJsonPath $fixture.JsonPath -SourceJsonPath $secondaryPath `
            -SourceHtmlPath $fixture.HtmlPath -OutputHtmlPath $fixture.OutputPath -ErrorAction Stop | Out-Null
        $raw = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw
        $raw | Should -Not -Match 'Secondary Organization Theta|Secondary Agent Sigma|secondary-customer\.invalid'
        $report = $raw | ConvertFrom-Json -Depth 100
        $brought = @($report.Tests | Where-Object TestId -EQ '99101')
        $brought.Count | Should -Be 1
        $brought[0].TestPillar | Should -Be 'AI'
        $report.TestResultSummary.AIPassed | Should -Be 1
        $report.TestResultSummary.AITotal | Should -Be 1
    }

    It 'masks cloud recommendation GUID test IDs while retaining every assessment row' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'recommendation-ids')
        $source = Get-Content -LiteralPath $fixture.JsonPath -Raw | ConvertFrom-Json -AsHashtable -Depth 100
        $ids = @(1..14 | ForEach-Object { 'a1200000-0000-0000-0000-{0:D12}' -f $_ })
        for ($i = 0; $i -lt $source.Tests.Count; $i++) { $source.Tests[$i].TestId = $ids[$i] }
        $json = $source | ConvertTo-Json -Depth 100
        $inline = $source | ConvertTo-Json -Depth 100 -EscapeHandling EscapeHtml
        Set-Content -LiteralPath $fixture.JsonPath -Value $json
        [System.IO.File]::WriteAllText($fixture.HtmlPath, $fixture.Prefix + $inline + $fixture.Suffix)
        Invoke-DemoTestGeneration $fixture
        $report = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw | ConvertFrom-Json -Depth 100
        @($report.Tests).Count | Should -Be 14
        foreach ($test in $report.Tests) {
            $test.TestId.Replace('-', '') | Should -Match '^([0-9])\1{31}$'
        }
        @($report.Tests.TestId | Sort-Object -Unique).Count | Should -BeLessOrEqual 10
    }

    It 'preserves closed chart labels without preserving identically named entities' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'schema-labels')
        $source = Get-Content -LiteralPath $fixture.JsonPath -Raw | ConvertFrom-Json -AsHashtable -Depth 100
        $source.TenantInfo.UnfamiliarOverview['DeviceName'] = 'WHfB'
        foreach ($key in @('OverviewAuthMethodsAllUsers', 'OverviewAuthMethodsPrivilegedUsers')) {
            $source.TenantInfo[$key] = @{
                description = 'Source Organization Zeta authentication registration.'
                nodes = @(
                    @{ source = 'Users'; target = 'Phish resistant'; value = 2 }
                    @{ source = 'Phish resistant'; target = 'Passkey'; value = 1 }
                    @{ source = 'Phish resistant'; target = 'WHfB'; value = 1 }
                )
            }
        }
        $json = $source | ConvertTo-Json -Depth 100
        $inline = $source | ConvertTo-Json -Depth 100 -EscapeHandling EscapeHtml
        Set-Content -LiteralPath $fixture.JsonPath -Value $json
        [System.IO.File]::WriteAllText($fixture.HtmlPath, $fixture.Prefix + $inline + $fixture.Suffix)
        Invoke-DemoTestGeneration $fixture
        $report = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw | ConvertFrom-Json -Depth 100
        $report.TenantInfo.UnfamiliarOverview.DeviceName | Should -Not -Be 'WHfB'
        foreach ($key in @('OverviewAuthMethodsAllUsers', 'OverviewAuthMethodsPrivilegedUsers')) {
            @($report.TenantInfo.$key.nodes | Where-Object target -EQ 'WHfB').Count | Should -Be 1
        }
    }

    It 'redacts standalone credential values as well as inline diagnostic credentials' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'credential-values')
        $source = Get-Content -LiteralPath $fixture.JsonPath -Raw | ConvertFrom-Json -AsHashtable -Depth 100
        $canary = 'SYNTHETIC-PRIVATE-VALUE-NOT-A-REAL-CREDENTIAL'
        $source.TenantInfo.UnfamiliarOverview['clientSecret'] = $canary
        $source.Tests[0].TestResult += "`nCookie: session=$canary`nX-Api-Key: $canary"
        $source.Tests[5].TestResult = @{ owner = 'Source Person Alpha'; password = $canary } | ConvertTo-Json -Compress
        $json = $source | ConvertTo-Json -Depth 100
        $inline = $source | ConvertTo-Json -Depth 100 -EscapeHandling EscapeHtml
        Set-Content -LiteralPath $fixture.JsonPath -Value $json
        [System.IO.File]::WriteAllText($fixture.HtmlPath, $fixture.Prefix + $inline + $fixture.Suffix)
        Invoke-DemoTestGeneration $fixture
        $raw = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw
        $raw | Should -Not -Match $canary
        $report = $raw | ConvertFrom-Json -Depth 100
        $report.TenantInfo.UnfamiliarOverview.clientSecret | Should -Be '[REDACTED]'
        ($report.Tests[5].TestResult | ConvertFrom-Json).password | Should -Be '[REDACTED]'
    }

    It 'preserves public cloud environment names and produces distinct coherent non-round scores' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'cloud-environments')
        $source = Get-Content -LiteralPath $fixture.JsonPath -Raw | ConvertFrom-Json -AsHashtable -Depth 100
        $source.TenantInfo.UnfamiliarOverview['displayName'] = 'AWS'
        $source.TenantInfo.UnfamiliarOverview['environment'] = 'AWS'
        $source.TenantInfo['OverviewCloudSecureScore'] = @(
            @{ environment = 'GCP'; current = 40.0; max = 100; percentage = 40.0; extra = 'Keep metadata' }
            @{ environment = 'AWS'; current = 60.0; max = 100; percentage = 60.0; extra = 'Keep metadata' }
            @{ environment = 'Azure'; current = 80.0; max = 100; percentage = 80.0; extra = 'Keep metadata' }
            @{ environment = 'All'; current = 180.0; max = 300; percentage = 60.0; extra = 'Keep metadata' }
        )
        $json = $source | ConvertTo-Json -Depth 100
        $inline = $source | ConvertTo-Json -Depth 100 -EscapeHandling EscapeHtml
        Set-Content -LiteralPath $fixture.JsonPath -Value $json
        [System.IO.File]::WriteAllText($fixture.HtmlPath, $fixture.Prefix + $inline + $fixture.Suffix)
        Invoke-DemoTestGeneration $fixture
        $report = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw | ConvertFrom-Json -Depth 100
        $scores = @($report.TenantInfo.OverviewCloudSecureScore)
        @($scores.environment) | Should -Be @('GCP', 'AWS', 'Azure', 'All')
        @($scores.percentage | Sort-Object -Unique).Count | Should -Be 4
        foreach ($score in $scores) {
            ($score.percentage % 10) | Should -Not -Be 0
            $score.percentage | Should -Be (100.0 * $score.current / $score.max)
            $score.extra | Should -Be 'Keep metadata'
        }
        $providers = @($scores | Where-Object environment -NE 'All')
        $all = $scores | Where-Object environment -EQ 'All'
        $all.current | Should -Be ($providers | Measure-Object -Property current -Sum).Sum
        $all.max | Should -Be ($providers | Measure-Object -Property max -Sum).Sum
        $report.TenantInfo.UnfamiliarOverview.displayName | Should -Not -Be 'AWS'
        $report.TenantInfo.UnfamiliarOverview.environment | Should -Not -Be 'AWS'
    }

    It 'retains unavailable cloud metrics and aggregates only available providers' {
        $fixture = New-DemoTestFixture (Join-Path $TestDrive 'cloud-unavailable')
        $source = Get-Content -LiteralPath $fixture.JsonPath -Raw | ConvertFrom-Json -AsHashtable -Depth 100
        $source.TenantInfo['OverviewCloudSecureScore'] = @(
            @{ environment = 'Azure'; current = $null; max = 100; percentage = $null; extra = 'Unavailable metadata' }
            @{ environment = 'AWS'; current = 0.0; max = 0; percentage = 0.0; extra = 'No capacity' }
            @{ environment = 'GCP'; current = 46.0; max = 100; percentage = 46.0 }
            @{ environment = 'All'; current = 46.0; max = 100; percentage = 46.0 }
        )
        $json = $source | ConvertTo-Json -Depth 100
        $inline = $source | ConvertTo-Json -Depth 100 -EscapeHandling EscapeHtml
        Set-Content -LiteralPath $fixture.JsonPath -Value $json
        [System.IO.File]::WriteAllText($fixture.HtmlPath, $fixture.Prefix + $inline + $fixture.Suffix)
        Invoke-DemoTestGeneration $fixture
        $report = Get-Content -LiteralPath $fixture.JsonOutputPath -Raw | ConvertFrom-Json -Depth 100
        $scores = @($report.TenantInfo.OverviewCloudSecureScore)
        $scores[0].current | Should -BeNullOrEmpty
        $scores[0].percentage | Should -BeNullOrEmpty
        $scores[0].extra | Should -Be 'Unavailable metadata'
        $scores[1].max | Should -Be 0
        $scores[1].current | Should -Be 0
        $scores[1].extra | Should -Be 'No capacity'
        $scores[3].current | Should -Be $scores[2].current
        $scores[3].max | Should -Be $scores[2].max
        $scores[3].percentage | Should -Be $scores[2].percentage
        ($scores[3].percentage % 10) | Should -Not -Be 0
    }
}
