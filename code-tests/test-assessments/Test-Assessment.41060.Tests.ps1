Describe "Test-Assessment-41060" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        # global:-stub every module-provided command the SUT calls so the test also runs
        # standalone (harness debug tree) where the ZeroTrustAssessment module is not imported.
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function global:Write-PSFMessage {}
        }
        if (-not (Get-Command Write-ZtProgress -ErrorAction SilentlyContinue)) {
            function global:Write-ZtProgress {}
        }
        if (-not (Get-Command Invoke-ZtGraphRequest -ErrorAction SilentlyContinue)) {
            function global:Invoke-ZtGraphRequest {
                param($RelativeUri, $Filter, $ApiVersion, $Top, [switch]$DisablePaging)
            }
        }
        # Add-ZtTestResultDetail needs a faithful param block: Should -Invoke -ParameterFilter can
        # only bind named args if the mocked command exposes those parameters.
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

        $classPath = Join-Path $srcRoot "classes/ZtTest.ps1"
        if (-not ("ZtTest" -as [type])) { . $classPath }

        . (Join-Path $srcRoot "tests/Test-Assessment.41060.ps1")

        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.41060.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
        "# Test Results for 41060`n" | Set-Content $script:outputFile

        # Shared mock data — three pinned MDATP control profiles with the titles the Graph API returns.
        # Defined in BeforeAll (run phase) so the variable is available when mocks execute.
        $script:allProfiles = @(
            [PSCustomObject]@{
                id                   = 'scid_2016'
                title                = 'Enable cloud-delivered protection'
                maxScore             = 8
                lastModifiedDateTime = '2026-06-27T00:00:00Z'
                controlStateUpdates  = @()
            },
            [PSCustomObject]@{
                id                   = 'scid_5094'
                title                = 'Enable Microsoft Defender Antivirus cloud-delivered protection in macOS'
                maxScore             = 8
                lastModifiedDateTime = '2026-06-27T00:00:00Z'
                controlStateUpdates  = @()
            },
            [PSCustomObject]@{
                id                   = 'scid_6094'
                title                = 'Enable Microsoft Defender Antivirus cloud-delivered protection for Linux'
                maxScore             = 8
                lastModifiedDateTime = '2026-06-27T00:00:00Z'
                controlStateUpdates  = @()
            }
        )
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
        Mock Get-FormattedDate { param($DateString) return $DateString }
    }

    Context "When all pinned cloud-protection controls are fully scored" {
        It "Should pass and report every control as passing" {
            Mock Invoke-ZtGraphRequest {
                if ($RelativeUri -eq 'security/secureScoreControlProfiles') {
                    return $script:allProfiles
                }
                elseif ($RelativeUri -eq 'security/secureScores') {
                    return [PSCustomObject]@{
                        value = @(
                            [PSCustomObject]@{
                                id              = '536279f6-15cc-45f2-be2d-61e352b51eef_2026-06-26'
                                azureTenantId   = '536279f6-15cc-45f2-be2d-61e352b51eef'
                                createdDateTime = '2026-06-26T00:00:00Z'
                                currentScore    = 1032.09
                                maxScore        = 1717
                                controlScores   = @(
                                    [PSCustomObject]@{ controlCategory = 'Device'; controlName = 'scid_2016'; score = 8; scoreInPercentage = 100 },
                                    [PSCustomObject]@{ controlCategory = 'Device'; controlName = 'scid_5094'; score = 8; scoreInPercentage = 100 },
                                    [PSCustomObject]@{ controlCategory = 'Device'; controlName = 'scid_6094'; score = 8; scoreInPercentage = 100 }
                                )
                            }
                        )
                    }
                }
            }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: All pinned controls fully scored`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-41060

            $script:capturedStatus | Should -Be $true
            $script:capturedResult | Should -Match ([regex]::Escape('✅ Cloud-delivered protection is enabled in Microsoft Defender Antivirus.'))
            $script:capturedResult | Should -Match 'scid_2016'
            $script:capturedResult | Should -Match 'scid_5094'
            $script:capturedResult | Should -Match 'scid_6094'
            $script:capturedResult | Should -Match ([regex]::Escape('✅ Pass'))
            $script:capturedResult | Should -Not -Match ([regex]::Escape('❌ Fail'))
        }
    }

}
