Describe "Test-Assessment-35003" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        # Mock external module dependencies
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function Write-PSFMessage {}
        }

        # Define Get-Label if it doesn't exist (required for mocking in some environments)
        if (-not (Get-Command Get-Label -ErrorAction SilentlyContinue)) {
            function Get-Label {}
        }

        # Load the class
        $classPath = Join-Path $srcRoot "classes/ZtTest.ps1"
        if (-not ("ZtTest" -as [type])) {
            . $classPath
        }

        # Load the SUT
        $sut = Join-Path $srcRoot "tests/Test-Assessment.35003.ps1"
        . $sut

        # Setup output file
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.35003.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
        "# Test Results for 35003`n" | Set-Content $script:outputFile
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
    }

    Context "When labels exist" {
        It "Should pass when at least one label exists" {
            Mock Get-Label {
                return @(
                    [PSCustomObject]@{
                        DisplayName = "Confidential"
                        Priority = 1
                        ParentId = $null
                        ParentLabelDisplayName = $null
                    },
                    [PSCustomObject]@{
                        DisplayName = "Public"
                        Priority = 0
                        ParentId = $null
                        ParentLabelDisplayName = $null
                    }
                )
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Labels Exist`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35003

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and $Result -match "At least one sensitivity label is configured"
            }
        }
    }

    Context "When no labels exist" {
        It "Should fail when no labels are returned" {
            Mock Get-Label { return @() }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: No Labels`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35003

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and $Result -match "No sensitivity labels are configured"
            }
        }
    }

    Context "Error Handling" {
        It "Should handle errors gracefully" {
            Mock Get-Label { throw "Connection Error" }

            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedResult = $Result
                "## Scenario: Error Handling`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35003

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false
            }
            $script:capturedResult | Should -Match "Unable to query sensitivity labels"
            $script:capturedResult | Should -Match "Connection Error"
        }
    }
}
