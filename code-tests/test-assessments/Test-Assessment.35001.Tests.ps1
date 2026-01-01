Describe "Test-Assessment-35001" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        # Mock external module dependencies
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function Write-PSFMessage {
            }
        }

        # Load the class
        $classPath = Join-Path $srcRoot "classes/ZtTest.ps1"
        if (-not ("ZtTest" -as [type])) {
            . $classPath
        }

        # Load the SUT
        $sut = Join-Path $srcRoot "tests/Test-Assessment.35001.ps1"
        . $sut

        # Setup output file
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.35001.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir | Out-Null
        }
        "# Test Results for 35001`n" | Set-Content $script:outputFile
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
    }

    Context "When no policies exist" {
        It "Should pass" {
            Mock Get-ZtConditionalAccessPolicy { return @() }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: No policies`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35001

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and $Result -match "Microsoft Rights Management Service \(RMS\) is excluded"
            }
        }
    }

    Context "When policies exist but RMS is excluded" {
        It "Should pass when 'All' apps included but RMS excluded" {
            Mock Get-ZtConditionalAccessPolicy {
                return @(
                    [PSCustomObject]@{
                        id          = "policy-1"
                        displayName = "Policy 1"
                        state       = "enabled"
                        conditions  = [PSCustomObject]@{
                            applications = [PSCustomObject]@{
                                includeApplications = @("All")
                                excludeApplications = @("00000012-0000-0000-c000-000000000000")
                            }
                        }
                    }
                )
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: All apps included, RMS excluded`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35001

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true
            }
        }
    }

    Context "When policies block RMS" {
        It "Should fail when 'All' apps included and RMS NOT excluded" {
            Mock Get-ZtConditionalAccessPolicy {
                return @(
                    [PSCustomObject]@{
                        id              = "policy-block-all"
                        displayName     = "Block All Policy"
                        state           = "enabled"
                        conditions      = [PSCustomObject]@{
                            applications = [PSCustomObject]@{
                                includeApplications = @("All")
                                excludeApplications = @("some-other-app-id")
                            }
                        }
                        grantControls   = [PSCustomObject]@{
                            builtInControls = @("mfa")
                        }
                        sessionControls = [PSCustomObject]@{
                            signInFrequency = [PSCustomObject]@{
                                isEnabled = $true
                                value     = 4
                                type      = "hours"
                            }
                        }
                    }
                )
            }

            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedResult = $Result
                "## Scenario: Block All Policy`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35001

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false
            }
            $script:capturedResult | Should -Match "Block All Policy"
            $script:capturedResult | Should -Match "mfa"
            $script:capturedResult | Should -Match "Sign-in Frequency"
        }

        It "Should fail when RMS explicitly included and NOT excluded" {
            Mock Get-ZtConditionalAccessPolicy {
                return @(
                    [PSCustomObject]@{
                        id          = "policy-block-rms"
                        displayName = "Block RMS Policy"
                        state       = "enabled"
                        conditions  = [PSCustomObject]@{
                            applications = [PSCustomObject]@{
                                includeApplications = @("00000012-0000-0000-c000-000000000000")
                                excludeApplications = @()
                            }
                        }
                    }
                )
            }

            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedResult = $Result
                "## Scenario: Block RMS Policy`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35001

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false
            }
            $script:capturedResult | Should -Match "None"
        }
    }

    Context "Error Handling" {
        It "Should handle errors gracefully" {
            Mock Get-ZtConditionalAccessPolicy { throw "Graph API Error" }

            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedResult = $Result
                "## Scenario: Error Handling`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35001

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false
            }
            $script:capturedResult | Should -Match "Unable to determine RMS exclusion status"
        }
    }

    Context "When policies are disabled" {
        It "Should pass when a blocking policy is disabled" {
            Mock Get-ZtConditionalAccessPolicy {
                return @(
                    [PSCustomObject]@{
                        id          = "policy-disabled-block"
                        displayName = "Disabled Block Policy"
                        state       = "disabled"
                        conditions  = [PSCustomObject]@{
                            applications = [PSCustomObject]@{
                                includeApplications = @("00000012-0000-0000-c000-000000000000")
                                excludeApplications = @()
                            }
                        }
                    }
                )
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Disabled Policy`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35001

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true
            }
        }
    }
}
