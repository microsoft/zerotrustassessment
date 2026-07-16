Describe "Test-Assessment-41022" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        # global:-stub every module-provided command the SUT calls, so the test also runs standalone
        # (harness debug tree) where the ZeroTrustAssessment module is not imported. The guards are
        # no-ops under the upstream pester.ps1 runner.
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) { function global:Write-PSFMessage {} }
        if (-not (Get-Command Write-ZtProgress -ErrorAction SilentlyContinue)) { function global:Write-ZtProgress {} }
        if (-not (Get-Command Invoke-ZtGraphRequest -ErrorAction SilentlyContinue)) {
            function global:Invoke-ZtGraphRequest {
                param($RelativeUri, $Filter, $Select, $Top, $ApiVersion, [switch]$DisablePaging)
            }
        }
        if (-not (Get-Command Get-ZtHttpStatusCode -ErrorAction SilentlyContinue)) {
            function global:Get-ZtHttpStatusCode { param($ErrorRecord) return $null }
        }
        # Add-ZtTestResultDetail needs a faithful param block so -ParameterFilter can bind named args.
        if (-not (Get-Command Add-ZtTestResultDetail -ErrorAction SilentlyContinue)) {
            function global:Add-ZtTestResultDetail {
                param(
                    [string] $Description, [bool] $Status, [string] $Result,
                    [Object[]] $GraphObjects, [string] $GraphObjectType,
                    [string] $TestId, [string] $Title, [string] $SkippedBecause,
                    [string] $UserImpact, [string] $Risk, [string] $ImplementationCost,
                    [string[]] $AppliesTo, [string[]] $Tag, [string] $CustomStatus,
                    [string[]] $NotConnectedService, [string] $Pillar, [string] $Category
                )
            }
        }

        # Load the ZtTest class (the [ZtTest()] attribute needs it), then the SUT.
        $classPath = Join-Path $srcRoot "classes/ZtTest.ps1"
        if (-not ("ZtTest" -as [type])) { . $classPath }

        . (Join-Path $srcRoot "tests/Test-Assessment.41022.ps1")

        # Capture each scenario's markdown for manual inspection.
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.41022.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
        "# Test Results for 41022`n" | Set-Content $script:outputFile
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
    }

    # Build an MDI alert with a createdDateTime N days in the past (UTC).
    function script:New-MdiAlert {
        param([string]$Id, [string]$Classification, [string]$Status, [int]$AgeDays)
        [PSCustomObject]@{
            id              = $Id
            title           = "MDI alert $Id"
            classification  = $Classification
            status          = $Status
            createdDateTime = (Get-Date).ToUniversalTime().AddDays(-$AgeDays).ToString("yyyy-MM-ddTHH:mm:ssZ")
        }
    }

    Context "When >=5 alerts, classification ratio >= 80%, and no stale unclassified alerts" {
        It "Should pass" {
            Mock Invoke-ZtGraphRequest {
                if ($Filter -match 'createdDateTime') {
                    return @(
                        (New-MdiAlert 'a1' 'truePositive'  'resolved' 2),
                        (New-MdiAlert 'a2' 'truePositive'  'resolved' 3),
                        (New-MdiAlert 'a3' 'falsePositive' 'resolved' 4),
                        (New-MdiAlert 'a4' 'falsePositive' 'resolved' 5),
                        (New-MdiAlert 'a5' 'informationalExpectedActivity' 'resolved' 6),
                        (New-MdiAlert 'a6' 'truePositive'  'resolved' 7),
                        (New-MdiAlert 'a7' 'truePositive'  'resolved' 8),
                        (New-MdiAlert 'a8' 'falsePositive' 'resolved' 9),
                        (New-MdiAlert 'a9' 'truePositive'  'resolved' 10),
                        # unclassified but recent (1 day) -> not stale
                        (New-MdiAlert 'a10' 'unknown' 'new' 1)
                    )
                }
            }
            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: Pass — high ratio, no stale`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter { $Status -eq $true }
            $script:capturedResult | Should -Match 'triaged consistently'
            $script:capturedResult | Should -Match '✅ Pass'
            $script:capturedResult | Should -Match '90\s?%'
        }
    }

    Context "When the classification ratio is below 80%" {
        It "Should fail" {
            Mock Invoke-ZtGraphRequest {
                if ($Filter -match 'createdDateTime') {
                    return @(
                        (New-MdiAlert 'a1' 'truePositive'  'resolved' 2),
                        (New-MdiAlert 'a2' 'falsePositive' 'resolved' 3),
                        (New-MdiAlert 'a3' 'truePositive'  'resolved' 4),
                        (New-MdiAlert 'a4' 'unknown' 'new' 1),
                        (New-MdiAlert 'a5' 'unknown' 'new' 1),
                        (New-MdiAlert 'a6' 'unknown' 'new' 2)
                    )
                }
            }
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                $script:capturedResult = $Result
                "## Scenario: Fail — low ratio`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter { $Status -eq $false }
            $script:capturedResult | Should -Match 'accumulating untriaged'
            $script:capturedResult | Should -Match '❌ Fail'
            $script:capturedResult | Should -Match 'security.microsoft.com/alerts'
        }
    }

    Context "When ratio is >= 80% but a stale unclassified alert exists" {
        It "Should fail" {
            Mock Invoke-ZtGraphRequest {
                if ($Filter -match 'createdDateTime') {
                    return @(
                        (New-MdiAlert 'a1' 'truePositive'  'resolved' 2),
                        (New-MdiAlert 'a2' 'truePositive'  'resolved' 3),
                        (New-MdiAlert 'a3' 'falsePositive' 'resolved' 4),
                        (New-MdiAlert 'a4' 'falsePositive' 'resolved' 5),
                        (New-MdiAlert 'a5' 'informationalExpectedActivity' 'resolved' 6),
                        (New-MdiAlert 'a6' 'truePositive'  'resolved' 7),
                        (New-MdiAlert 'a7' 'truePositive'  'resolved' 8),
                        (New-MdiAlert 'a8' 'falsePositive' 'resolved' 9),
                        (New-MdiAlert 'a9' 'truePositive'  'resolved' 10),
                        # unclassified, still new, older than 7 days -> stale
                        (New-MdiAlert 'a10' 'unknown' 'new' 20)
                    )
                }
            }
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                $script:capturedResult = $Result
                "## Scenario: Fail — stale unclassified`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter { $Status -eq $false }
            $script:capturedResult | Should -Match 'accumulating untriaged'
            $script:capturedResult | Should -Match '❌ Fail'
        }
    }

    Context "When fewer than five alerts were generated in the window" {
        It "Should return Investigate" {
            Mock Invoke-ZtGraphRequest {
                if ($Filter -match 'createdDateTime') {
                    return @(
                        (New-MdiAlert 'a1' 'truePositive' 'resolved' 2),
                        (New-MdiAlert 'a2' 'unknown' 'new' 1),
                        (New-MdiAlert 'a3' 'unknown' 'new' 1)
                    )
                }
            }
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                $script:capturedResult = $Result
                "## Scenario: Investigate — too few alerts`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $Status -eq $false -and $CustomStatus -eq 'Investigate'
            }
            $script:capturedResult | Should -Match 'Fewer than'
        }
    }

    Context "When there are no alerts in the window but MDI has historical alerts" {
        It "Should return Investigate" {
            Mock Invoke-ZtGraphRequest {
                if ($Filter -match 'createdDateTime') { return @() }
                # existence probe uses -DisablePaging -> return the raw wrapper with one alert under .value
                return [PSCustomObject]@{ value = @( (New-MdiAlert 'old1' 'truePositive' 'resolved' 400) ) }
            }
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                $script:capturedResult = $Result
                "## Scenario: Investigate — deployed, no recent alerts`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $Status -eq $false -and $CustomStatus -eq 'Investigate'
            }
            $script:capturedResult | Should -Match 'Fewer than'
        }
    }

    Context "When MDI has never generated an alert" {
        It "Should be Skipped as NotApplicable" {
            Mock Invoke-ZtGraphRequest {
                if ($Filter -match 'createdDateTime') { return @() }
                # existence probe uses -DisablePaging -> raw wrapper with an empty .value
                return [PSCustomObject]@{ value = @() }
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                "## Scenario: Skipped — MDI not deployed`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $SkippedBecause -eq 'NotApplicable'
            }
        }
    }

    Context "When Q1 succeeds with zero alerts but the historical existence probe fails" {
        It "Should return Investigate (not silently skip)" {
            Mock Invoke-ZtGraphRequest {
                if ($Filter -match 'createdDateTime') { return @() }
                # existence probe fails unexpectedly after a successful Q1
                throw "503 Service Unavailable"
            }
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                $script:capturedResult = $Result
                "## Scenario: Investigate — probe failed`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $Status -eq $false -and $CustomStatus -eq 'Investigate'
            }
            $script:capturedResult | Should -Match 'failed unexpectedly'
            $script:capturedResult | Should -Match 'Service Unavailable'
        }
    }

    Context "When the alerts query returns HTTP 401 (unauthorized)" {
        It "Should return Investigate prompting a permission check" {
            Mock Invoke-ZtGraphRequest { throw "401 Unauthorized" }
            Mock Get-ZtHttpStatusCode { return 401 }
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                $script:capturedResult = $Result
                "## Scenario: Investigate — 401`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $Status -eq $false -and $CustomStatus -eq 'Investigate'
            }
            $script:capturedResult | Should -Match 'SecurityAlert.Read.All'
        }
    }

    Context "When the alerts query returns HTTP 403 (forbidden)" {
        It "Should return Investigate prompting a permission check" {
            Mock Invoke-ZtGraphRequest { throw "403 Forbidden" }
            Mock Get-ZtHttpStatusCode { return 403 }
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                $script:capturedResult = $Result
                "## Scenario: Investigate — 403`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $Status -eq $false -and $CustomStatus -eq 'Investigate'
            }
            $script:capturedResult | Should -Match 'not authorized'
        }
    }

    Context "When the alerts query returns HTTP 404 (MDI not onboarded)" {
        It "Should be Skipped as NotApplicable" {
            Mock Invoke-ZtGraphRequest { throw "404 Not Found" }
            Mock Get-ZtHttpStatusCode { return 404 }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                "## Scenario: Skipped — 404 MDI not onboarded`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $SkippedBecause -eq 'NotApplicable'
            }
        }
    }

    Context "When the alerts query returns an HTTP 5xx service error" {
        It "Should return Investigate advising a re-run" {
            Mock Invoke-ZtGraphRequest { throw "503 Service Unavailable" }
            Mock Get-ZtHttpStatusCode { return 503 }
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                $script:capturedResult = $Result
                "## Scenario: Investigate — 503`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $Status -eq $false -and $CustomStatus -eq 'Investigate'
            }
            $script:capturedResult | Should -Match 'service error'
            $script:capturedResult | Should -Match 're-run'
        }
    }

    Context "When the alerts query fails with no determinable HTTP status code" {
        It "Should return Error and include the error in the result" {
            Mock Invoke-ZtGraphRequest { throw "The remote name could not be resolved" }
            Mock Get-ZtHttpStatusCode { return $null }
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
                $script:capturedResult = $Result
                "## Scenario: Error — unexpected failure`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41022

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $Status -eq $false -and $CustomStatus -eq 'Error'
            }
            $script:capturedResult | Should -Match 'unexpected error occurred'
            $script:capturedResult | Should -Match 'could not be resolved'
        }
    }
}
