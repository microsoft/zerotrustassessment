Describe "Test-Assessment-25392" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"
<#
        # Import required module functions
        @(
            "private/core/Add-ZtTestResultDetail.ps1"
            "public/Invoke-ZtGraphRequest.ps1"
            "private/core/Write-ZtProgress.ps1"
            "private/core/Get-ZtTestStatus.ps1"
            "private/core/Get-SafeMarkdown.ps1"
        ) | ForEach-Object { . (Join-Path $srcRoot $_) }
#>
        # Mock external module dependencies if they are not present
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function Write-PSFMessage {}
        }

        # Load the class
        $classPath = Join-Path $srcRoot "classes/ZtTest.ps1"
        if (-not ("ZtTest" -as [type])) {
            . $classPath
        }

        # Load the SUT
        $sut = Join-Path $srcRoot "tests/Test-Assessment.25392.ps1"
        . $sut

        # Setup output file
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.25392.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
        "# Test Results for 25392`n" | Set-Content $script:outputFile
    }

    # Mock common module functions
    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
    }

    Context "When no connectors are found" {
        It "Should pass with 'No connectors found' message" {
            Mock Invoke-ZtGraphRequest { return @() }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: No connectors found`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-25392

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and $Result -match "No private network connectors found"
            }
        }
    }

    Context "When connectors are found and up to date" {
        It "Should pass when connector has exact same version as latest" {
            Mock Invoke-ZtGraphRequest {
                return @(
                    [PSCustomObject]@{
                        id = "95381f60-3d8c-46d6-8c0a-5c97ee884739"
                        machineName = "PNC1.contoso.local"
                        externalIp = "10.0.0.1"
                        status = "active"
                        version = "1.5.4522.0"
                    }
                )
            }

            Mock Invoke-RestMethod {
                return "## Version 1.5.4522.0"
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Connectors found and up to date`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-25392

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and
                $Result -match "All private network connectors are running the latest version" -and
                $Result -match "1.5.4522.0"
            }
        }

        It "Should pass when connectors have newer version than documented (preview/canary)" {
            Mock Invoke-ZtGraphRequest {
                return @(
                    [PSCustomObject]@{
                        id = "95381f60-3d8c-46d6-8c0a-5c97ee884739"
                        machineName = "PNC1.contoso.local"
                        externalIp = "10.0.0.1"
                        status = "active"
                        version = "1.5.4522.0"
                    },
                    [PSCustomObject]@{
                        id = "ab4012b9-be31-497b-badc-f9d3f6d04098"
                        version = "1.5.4600.0"  # Newer than documented version
                    }
                )
            }

            Mock Invoke-RestMethod {
                return "## Version 1.5.4522.0"
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Connectors found (including preview version)`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-25392

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and
                $Result -match "All private network connectors are running the latest version"
            }
        }
    }

    Context "When connectors are found and some are outdated" {
        It "Should fail with 'At least one connector outdated' message and list outdated ones" {
            Mock Invoke-ZtGraphRequest {
                return @(
                    [PSCustomObject]@{
                        id = "95381f60-3d8c-46d6-8c0a-5c97ee884739"
                        machineName = "PNC1.contoso.local"
                        externalIp = "10.0.0.1"
                        status = "active"
                        version = "1.5.4522.0"
                    },
                    [PSCustomObject]@{
                        id = "ab4012b9-be31-497b-badc-f9d3f6d04098"
                        machineName = "PNC2.contoso.local"
                        externalIp = "10.0.0.2"
                        status = "active"
                        version = "1.5.4400.0"  # Older version
                    }
                )
            }

            Mock Invoke-RestMethod {
                return "## Version 1.5.4522.0"
            }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: Some connectors outdated`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-25392

            $script:capturedStatus | Should -Be $false
            $script:capturedResult | Should -Match "At least one private network connector is not running the latest version"
            $script:capturedResult | Should -Match "Outdated connectors"
            $script:capturedResult | Should -Match "PNC2.contoso.local"
            $script:capturedResult | Should -Match "1.5.4400.0"
        }

        It "Should fail when all connectors are outdated" {
            Mock Invoke-ZtGraphRequest {
                return @(
                    [PSCustomObject]@{
                        id = "95381f60-3d8c-46d6-8c0a-5c97ee884739"
                        machineName = "PNC1.contoso.local"
                        externalIp = "10.0.0.1"
                        status = "active"
                        version = "1.5.4400.0"  # Older version
                    },
                    [PSCustomObject]@{
                        id = "ab4012b9-be31-497b-badc-f9d3f6d04098"
                        machineName = "PNC2.contoso.local"
                        externalIp = "10.0.0.2"
                        status = "active"
                        version = "1.5.4300.0"  # Even older version
                    }
                )
            }

            Mock Invoke-RestMethod {
                return "## Version 1.5.4522.0"
            }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: All connectors outdated`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-25392

            $script:capturedStatus | Should -Be $false
            $script:capturedResult | Should -Match "At least one private network connector is not running the latest version"
            $script:capturedResult | Should -Match "Outdated connectors"
            $script:capturedResult | Should -Match "PNC1.contoso.local"
            $script:capturedResult | Should -Match "PNC2.contoso.local"
            $script:capturedResult | Should -Not -Match "Up-to-date connectors"
        }
    }

    Context "When latest version cannot be retrieved" {
        It "Should fail with 'Could not retrieve latest version' message on network error" {
            Mock Invoke-ZtGraphRequest {
                return @(
                    [PSCustomObject]@{
                        id = "95381f60-3d8c-46d6-8c0a-5c97ee884739"
                        machineName = "PNC1.contoso.local"
                        externalIp = "10.0.0.1"
                        status = "active"
                        version = "1.5.4522.0"
                    }
                )
            }

            Mock Invoke-RestMethod {
                throw "Network error"
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Network error retrieving version`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-25392

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and
                $Result -match "Could not retrieve the latest connector version"
            }
        }

        It "Should fail if version format is not found in markdown" {
            Mock Invoke-ZtGraphRequest {
                return @(
                    [PSCustomObject]@{
                        id = "95381f60-3d8c-46d6-8c0a-5c97ee884739"
                        machineName = "PNC1.contoso.local"
                        externalIp = "10.0.0.1"
                        status = "active"
                        version = "1.5.4522.0"
                    }
                )
            }

            Mock Invoke-RestMethod {
                return "Some content without version info"
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Version format not found`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-25392

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and
                $Result -match "Could not retrieve the latest connector version"
            }
        }
    }
}
