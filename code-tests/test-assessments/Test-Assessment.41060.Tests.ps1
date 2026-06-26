Describe "Test-Assessment-41060" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        # Mock external module dependencies that may not be loaded in the test host
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function Write-PSFMessage {
            }
        }
        if (-not (Get-Command Write-ZtProgress -ErrorAction SilentlyContinue)) {
            function Write-ZtProgress {
            }
        }
        if (-not (Get-Command Invoke-ZtGraphRequest -ErrorAction SilentlyContinue)) {
            function Invoke-ZtGraphRequest {
                param($RelativeUri, $Filter, $ApiVersion, $Top, [switch]$DisablePaging)
            }
        }
        if (-not (Get-Command Add-ZtTestResultDetail -ErrorAction SilentlyContinue)) {
            function Add-ZtTestResultDetail {
            }
        }
        if (-not (Get-Command Get-SafeMarkdown -ErrorAction SilentlyContinue)) {
            function Get-SafeMarkdown {
                param($Text) return $Text
            }
        }
        if (-not (Get-Command Get-FormattedDate -ErrorAction SilentlyContinue)) {
            function Get-FormattedDate {
                param($DateString) return $DateString
            }
        }

        # Load the class
        $classPath = Join-Path $srcRoot "classes/ZtTest.ps1"
        if (-not ("ZtTest" -as [type])) {
            . $classPath
        }

        # Load the SUT
        $sut = Join-Path $srcRoot "tests/Test-Assessment.41060.ps1"
        . $sut

        # Setup output file
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.41060.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir | Out-Null
        }
        "# Test Results for 41060`n" | Set-Content $script:outputFile
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
        Mock Get-FormattedDate { param($DateString) return $DateString }
    }

    Context "When all pinned cloud-protection controls are fully scored" {
        It "Should pass" {
            # Q1a: the three pinned MDATP Secure Score control profiles, each with a maxScore.
            # Q1b: the latest Secure Score snapshot whose controlScores meet or exceed each maxScore.
            # The mock branches on $RelativeUri to mirror the two Graph calls the test makes.
            Mock Invoke-ZtGraphRequest {
                if ($RelativeUri -eq 'security/secureScoreControlProfiles') {
                    return @(
                        [PSCustomObject]@{
                            id                   = 'scid_2016'
                            title                = 'Turn on cloud-delivered protection in Microsoft Defender Antivirus'
                            maxScore             = 10
                            lastModifiedDateTime = '2026-06-26T00:00:00Z'
                            controlStateUpdates  = @()
                        },
                        [PSCustomObject]@{
                            id                   = 'scid_5094'
                            title                = 'Set cloud-delivered protection to advanced'
                            maxScore             = 8
                            lastModifiedDateTime = '2026-06-26T00:00:00Z'
                            controlStateUpdates  = @()
                        },
                        [PSCustomObject]@{
                            id                   = 'scid_6094'
                            title                = 'Enable cloud protection sample submission'
                            maxScore             = 9
                            lastModifiedDateTime = '2026-06-26T00:00:00Z'
                            controlStateUpdates  = @()
                        }
                    )
                }
                elseif ($RelativeUri -eq 'security/secureScores') {
                    # Shaped like GET /v1.0/security/secureScores?$top=1 (response wrapper with .value).
                    return [PSCustomObject]@{
                        '@odata.context' = 'https://graph.microsoft.com/v1.0/$metadata#security/secureScores'
                        value            = @(
                            [PSCustomObject]@{
                                id            = '536279f6-15cc-45f2-be2d-61e352b51eef_2026-06-26'
                                azureTenantId = '536279f6-15cc-45f2-be2d-61e352b51eef'
                                createdDateTime = '2026-06-26T00:00:00Z'
                                currentScore  = 1032.09
                                maxScore      = 1717
                                controlScores = @(
                                    [PSCustomObject]@{
                                        controlCategory = 'Device'
                                        controlName     = 'scid_2016'
                                        score           = 10
                                        scoreInPercentage = 100
                                    },
                                    [PSCustomObject]@{
                                        controlCategory = 'Device'
                                        controlName     = 'scid_5094'
                                        score           = 8
                                        scoreInPercentage = 100
                                    },
                                    [PSCustomObject]@{
                                        controlCategory = 'Device'
                                        controlName     = 'scid_6094'
                                        score           = 9
                                        scoreInPercentage = 100
                                    }
                                )
                            }
                        )
                    }
                }
            }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result, $CustomStatus)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: All pinned controls fully scored`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41060

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly -ParameterFilter {
                $Status -eq $true
            }
            $script:capturedResult | Should -Match 'Cloud-delivered protection is enabled'
            $script:capturedResult | Should -Match 'scid_2016'
            $script:capturedResult | Should -Match 'scid_5094'
            $script:capturedResult | Should -Match 'scid_6094'
            $script:capturedResult | Should -Match '✅ Pass'
            $script:capturedResult | Should -Not -Match '❌ Fail'
        }
    }
}
