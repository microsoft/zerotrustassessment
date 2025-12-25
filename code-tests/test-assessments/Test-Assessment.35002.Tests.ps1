Describe "Test-Assessment-35002" {
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
        # Mock external module dependencies
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function Write-PSFMessage {}
        }

        # Load the class
        $classPath = Join-Path $srcRoot "classes/ZtTest.ps1"
        if (-not ("ZtTest" -as [type])) {
            . $classPath
        }

        # Load the SUT
        $sut = Join-Path $srcRoot "tests/Test-Assessment.35002.ps1"
        . $sut

        # Setup output file
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.35002.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
        "# Test Results for 35002`n" | Set-Content $script:outputFile
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
        $script:defaultPolicyResponse = $null
        $script:partnersResponse = @()
    }

    Context "When Default Policy allows RMS" {
        It "Should pass when Inbound and Outbound allow RMS explicitly" {
            $script:defaultPolicyResponse = [PSCustomObject]@{
                b2bCollaborationInbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "00000012-0000-0000-c000-000000000000" })
                    }
                }
                b2bCollaborationOutbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "00000012-0000-0000-c000-000000000000" })
                    }
                }
            }
            $script:partnersResponse = @()

            Mock Invoke-ZtGraphRequest {
                if ($RelativeUri -match "default") { return $script:defaultPolicyResponse }
                if ($RelativeUri -match "partners") { return $script:partnersResponse }
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Default Allowed Explicitly`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35002

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and $Result -match "RMS application is allowed"
            }
        }

        It "Should pass when Inbound and Outbound allow All Apps" {
             $script:defaultPolicyResponse = [PSCustomObject]@{
                b2bCollaborationInbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "AllApplications" })
                    }
                }
                b2bCollaborationOutbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "AllApplications" })
                    }
                }
            }
            $script:partnersResponse = @()

            Mock Invoke-ZtGraphRequest {
                if ($RelativeUri -match "default") { return $script:defaultPolicyResponse }
                if ($RelativeUri -match "partners") { return $script:partnersResponse }
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Default Allowed All Apps`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35002

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true
            }
        }

        It "Should pass when Inbound and Outbound Block specific apps but NOT RMS (Implicit Allow)" {
             $script:defaultPolicyResponse = [PSCustomObject]@{
                b2bCollaborationInbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "blocked"
                        targets = @([PSCustomObject]@{ target = "some-other-app-id" })
                    }
                }
                b2bCollaborationOutbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "blocked"
                        targets = @([PSCustomObject]@{ target = "some-other-app-id" })
                    }
                }
            }
            $script:partnersResponse = @()

            Mock Invoke-ZtGraphRequest {
                if ($RelativeUri -match "default") { return $script:defaultPolicyResponse }
                if ($RelativeUri -match "partners") { return $script:partnersResponse }
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Default Implicit Allow`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35002

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true
            }
        }
    }

    Context "When Default Policy blocks RMS" {
        It "Should fail when Inbound explicitly blocks RMS" {
            $script:defaultPolicyResponse = [PSCustomObject]@{
                b2bCollaborationInbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "blocked"
                        targets = @([PSCustomObject]@{ target = "00000012-0000-0000-c000-000000000000" })
                    }
                }
                b2bCollaborationOutbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "AllApplications" })
                    }
                }
            }
            $script:partnersResponse = @()

            Mock Invoke-ZtGraphRequest {
                if ($RelativeUri -match "default") { return $script:defaultPolicyResponse }
                if ($RelativeUri -match "partners") { return $script:partnersResponse }
            }

            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedResult = $Result
                "## Scenario: Default Inbound Blocked Explicitly`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35002

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false
            }
            $script:capturedResult | Should -Match "Blocked \(Explicit\)"
        }

        It "Should fail when Inbound allows specific apps but NOT RMS (Implicit Block)" {
            $script:defaultPolicyResponse = [PSCustomObject]@{
                b2bCollaborationInbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "some-other-app-id" })
                    }
                }
                b2bCollaborationOutbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "AllApplications" })
                    }
                }
            }
            $script:partnersResponse = @()

            Mock Invoke-ZtGraphRequest {
                if ($RelativeUri -match "default") { return $script:defaultPolicyResponse }
                if ($RelativeUri -match "partners") { return $script:partnersResponse }
            }

            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedResult = $Result
                "## Scenario: Default Inbound Blocked Implicitly`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35002

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false
            }
            $script:capturedResult | Should -Match "Blocked \(Implicit\)"
        }
    }

    Context "When Partner Policies exist" {
        It "Should fail if a Partner Policy blocks RMS" {
            $script:defaultPolicyResponse = [PSCustomObject]@{
                b2bCollaborationInbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "AllApplications" })
                    }
                }
                b2bCollaborationOutbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "AllApplications" })
                    }
                }
            }
            $script:partnersResponse = @(
                [PSCustomObject]@{
                    tenantId = "partner-tenant-id"
                    b2bCollaborationInbound = [PSCustomObject]@{
                        applications = [PSCustomObject]@{
                            accessType = "blocked"
                            targets = @([PSCustomObject]@{ target = "00000012-0000-0000-c000-000000000000" })
                        }
                    }
                }
            )

            Mock Invoke-ZtGraphRequest {
                if ($RelativeUri -match "default") { return $script:defaultPolicyResponse }
                if ($RelativeUri -match "partners") { return $script:partnersResponse }
            }

            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedResult = $Result
                "## Scenario: Partner Blocked`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35002

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false
            }
            $script:capturedResult | Should -Match "Partner \(partner-tenant-id\)"
            $script:capturedResult | Should -Match "Blocked \(Explicit\)"
        }

        It "Should ignore inherited partner settings" {
             $script:defaultPolicyResponse = [PSCustomObject]@{
                b2bCollaborationInbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "AllApplications" })
                    }
                }
                b2bCollaborationOutbound = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        accessType = "allowed"
                        targets = @([PSCustomObject]@{ target = "AllApplications" })
                    }
                }
            }
            # Partner with null/empty settings implies inheritance
            $script:partnersResponse = @(
                [PSCustomObject]@{
                    tenantId = "partner-tenant-id"
                    b2bCollaborationInbound = $null
                    b2bCollaborationOutbound = [PSCustomObject]@{
                        applications = $null
                    }
                }
            )

            Mock Invoke-ZtGraphRequest {
                if ($RelativeUri -match "default") { return $script:defaultPolicyResponse }
                if ($RelativeUri -match "partners") { return $script:partnersResponse }
            }

            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Partner Inherited`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35002

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true
            }
        }
    }

    Context "Error Handling" {
        It "Should handle Graph API errors" {
            Mock Invoke-ZtGraphRequest { throw "Graph API Error" }

            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedResult = $Result
                "## Scenario: Error Handling`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35002

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false
            }
            $script:capturedResult | Should -Match "Cross-tenant access policy settings cannot be determined"
        }
    }
}
