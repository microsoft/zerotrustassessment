Describe "Test-Assessment-35041" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        # Mock external module dependencies if they are not present
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function global:Write-PSFMessage {}
        }
        if (-not (Get-Command Write-ZtProgress -ErrorAction SilentlyContinue)) {
            function global:Write-ZtProgress {}
        }
        if (-not (Get-Command Get-SafeMarkdown -ErrorAction SilentlyContinue)) {
            function global:Get-SafeMarkdown { param($Text) return $Text }
        }
        if (-not (Get-Command Get-DlpCompliancePolicy -ErrorAction SilentlyContinue)) {
            function global:Get-DlpCompliancePolicy {}
        }
        if (-not (Get-Command Get-DlpComplianceRule -ErrorAction SilentlyContinue)) {
            function global:Get-DlpComplianceRule {}
        }
        if (-not (Get-Command Add-ZtTestResultDetail -ErrorAction SilentlyContinue)) {
            function global:Add-ZtTestResultDetail {}
        }

        # Load the class
        $classPath = Join-Path $srcRoot "classes/ZtTest.ps1"
        if (-not ("ZtTest" -as [type])) {
            . $classPath
        }

        # Load the SUT
        $sut = Join-Path $srcRoot "tests/Test-Assessment.35041.ps1"
        . $sut

        # Setup output file
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.35041.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir | Out-Null
        }
        "# Test Results for 35041`n" | Set-Content $script:outputFile
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
    }

    Context "When no Browser DLP policies exist" {
        It "Should fail when no policies with Browser enforcement plane exist" {
            Mock Get-DlpCompliancePolicy { return @() }
            Mock Get-DlpComplianceRule { return @() }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: No Browser DLP policies`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35041

            $script:capturedStatus | Should Be $false
            $script:capturedResult | Should Match "Browser DLP for AI apps is not configured"
        }
    }

    Context "When Browser DLP policies exist but no rules" {
        It "Should fail when policies exist but have no rules" {
            Mock Get-DlpCompliancePolicy {
                return @(
                    [PSCustomObject]@{
                        Name              = "AI Apps Browser Protection"
                        Identity          = "ai-apps-browser-policy-001"
                        Enabled           = $true
                        Mode              = "Enable"
                        EnforcementPlanes = @("Browser", "Endpoint")
                        PolicyCategory    = "ApplicableToAI"
                        CreatedBy         = "admin@contoso.com"
                        CreationTimeUtc   = [DateTime]::Parse("2025-11-15T10:30:00Z")
                    }
                )
            }
            Mock Get-DlpComplianceRule { return @() }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: Policies exist but no rules`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35041

            $script:capturedStatus | Should Be $false
            $script:capturedResult | Should Match "Browser DLP for AI apps is not configured"
        }
    }

    Context "When all Browser DLP policies are disabled" {
        It "Should fail when policies and rules exist but all policies are disabled" {
            Mock Get-DlpCompliancePolicy {
                return @(
                    [PSCustomObject]@{
                        Name              = "AI Apps Browser Protection - Disabled"
                        Identity          = "ai-apps-browser-policy-disabled"
                        Enabled           = $false
                        Mode              = "TestWithNotifications"
                        EnforcementPlanes = @("Browser")
                        PolicyCategory    = "ApplicableToAI"
                        CreatedBy         = "admin@contoso.com"
                        CreationTimeUtc   = [DateTime]::Parse("2025-10-01T08:00:00Z")
                    },
                    [PSCustomObject]@{
                        Name              = "Generative AI Data Protection - Disabled"
                        Identity          = "genai-browser-policy-disabled"
                        Enabled           = $false
                        Mode              = "Enable"
                        EnforcementPlanes = @("Browser", "Endpoint")
                        PolicyCategory    = "ApplicableToAI"
                        CreatedBy         = "compliance@contoso.com"
                        CreationTimeUtc   = [DateTime]::Parse("2025-09-20T14:15:00Z")
                    }
                )
            }
            Mock Get-DlpComplianceRule {
                return @(
                    [PSCustomObject]@{
                        Name             = "Block Sensitive Data to AI Apps"
                        Policy           = "ai-apps-browser-policy-disabled"
                        ParentPolicyName = "AI Apps Browser Protection - Disabled"
                        Disabled         = $false
                        Actions          = @("BlockAccess", "NotifyUser")
                    },
                    [PSCustomObject]@{
                        Name             = "Audit GenAI Data Transfers"
                        Policy           = "genai-browser-policy-disabled"
                        ParentPolicyName = "Generative AI Data Protection - Disabled"
                        Disabled         = $false
                        Actions          = @("Audit")
                    }
                )
            }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: All policies disabled`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35041

            $script:capturedStatus | Should Be $false
            $script:capturedResult | Should Match "Browser DLP for AI apps is not configured"
        }
    }

    Context "When Browser DLP is properly configured" {
        It "Should pass when at least one enabled policy with rules exists" {
            Mock Get-DlpCompliancePolicy {
                return @(
                    [PSCustomObject]@{
                        Name              = "AI Apps Browser Protection"
                        Identity          = "ai-apps-browser-policy-001"
                        Enabled           = $true
                        Mode              = "Enable"
                        EnforcementPlanes = @("Browser", "Endpoint")
                        PolicyCategory    = "ApplicableToAI"
                        CreatedBy         = "admin@contoso.com"
                        CreationTimeUtc   = [DateTime]::Parse("2025-11-15T10:30:00Z")
                    },
                    [PSCustomObject]@{
                        Name              = "ChatGPT & Gemini Block Policy"
                        Identity          = "chatgpt-gemini-block-002"
                        Enabled           = $true
                        Mode              = "TestWithNotifications"
                        EnforcementPlanes = @("Browser")
                        PolicyCategory    = "ApplicableToAI"
                        CreatedBy         = "security@contoso.com"
                        CreationTimeUtc   = [DateTime]::Parse("2025-12-01T09:00:00Z")
                    },
                    [PSCustomObject]@{
                        Name              = "Legacy Policy - Disabled"
                        Identity          = "legacy-browser-003"
                        Enabled           = $false
                        Mode              = "Enable"
                        EnforcementPlanes = @("Browser")
                        PolicyCategory    = $null
                        CreatedBy         = "old-admin@contoso.com"
                        CreationTimeUtc   = [DateTime]::Parse("2024-06-15T11:45:00Z")
                    }
                )
            }
            Mock Get-DlpComplianceRule {
                return @(
                    [PSCustomObject]@{
                        Name             = "Block Credit Card to AI Apps"
                        Policy           = "ai-apps-browser-policy-001"
                        ParentPolicyName = "AI Apps Browser Protection"
                        Disabled         = $false
                        Actions          = @("BlockAccess", "NotifyUser", "GenerateIncidentReport")
                    },
                    [PSCustomObject]@{
                        Name             = "Block SSN to AI Apps"
                        Policy           = "ai-apps-browser-policy-001"
                        ParentPolicyName = "AI Apps Browser Protection"
                        Disabled         = $false
                        Actions          = @("BlockAccess", "NotifyUser")
                    },
                    [PSCustomObject]@{
                        Name             = "Warn on Confidential Data"
                        Policy           = "chatgpt-gemini-block-002"
                        ParentPolicyName = "ChatGPT & Gemini Block Policy"
                        Disabled         = $false
                        Actions          = @("NotifyUser", "OverrideWithJustification")
                    },
                    [PSCustomObject]@{
                        Name             = "Audit Financial Data"
                        Policy           = "chatgpt-gemini-block-002"
                        ParentPolicyName = "ChatGPT & Gemini Block Policy"
                        Disabled         = $true
                        Actions          = @("Audit")
                    }
                )
            }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: Properly configured (PASS)`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35041

            $script:capturedStatus | Should Be $true
            $script:capturedResult | Should Match "Browser Data Loss Prevention for AI Apps is configured and enabled"
        }

        It "Should pass with single enabled policy and single rule" {
            Mock Get-DlpCompliancePolicy {
                return @(
                    [PSCustomObject]@{
                        Name              = "Minimal Browser DLP"
                        Identity          = "minimal-browser-dlp"
                        Enabled           = $true
                        Mode              = "Enable"
                        EnforcementPlanes = @("Browser")
                        PolicyCategory    = "ApplicableToAI"
                        CreatedBy         = "admin@contoso.com"
                        CreationTimeUtc   = [DateTime]::Parse("2026-01-10T16:00:00Z")
                    }
                )
            }
            Mock Get-DlpComplianceRule {
                return @(
                    [PSCustomObject]@{
                        Name             = "Block All Sensitive Info"
                        Policy           = "minimal-browser-dlp"
                        ParentPolicyName = "Minimal Browser DLP"
                        Disabled         = $false
                        Actions          = @("BlockAccess")
                    }
                )
            }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: Minimal config (single policy, single rule)`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35041

            $script:capturedStatus | Should Be $true
            $script:capturedResult | Should Match "Browser Data Loss Prevention for AI Apps is configured and enabled"
        }
    }

    Context "Mixed scenarios with non-Browser policies" {
        It "Should fail when policies exist but none have Browser enforcement" {
            Mock Get-DlpCompliancePolicy {
                return @(
                    [PSCustomObject]@{
                        Name              = "Endpoint Only Policy"
                        Identity          = "endpoint-only-001"
                        Enabled           = $true
                        Mode              = "Enable"
                        EnforcementPlanes = @("Endpoint")
                        PolicyCategory    = "General"
                        CreatedBy         = "admin@contoso.com"
                        CreationTimeUtc   = [DateTime]::Parse("2025-08-01T12:00:00Z")
                    },
                    [PSCustomObject]@{
                        Name              = "Exchange DLP Policy"
                        Identity          = "exchange-dlp-002"
                        Enabled           = $true
                        Mode              = "Enable"
                        EnforcementPlanes = @("Exchange")
                        PolicyCategory    = "General"
                        CreatedBy         = "admin@contoso.com"
                        CreationTimeUtc   = [DateTime]::Parse("2025-07-15T09:30:00Z")
                    }
                )
            }
            Mock Get-DlpComplianceRule { return @() }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: Policies exist but none with Browser enforcement`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35041

            $script:capturedStatus | Should Be $false
            $script:capturedResult | Should Match "Browser DLP for AI apps is not configured"
        }
    }

    Context "Error Handling" {
        It "Should handle query errors gracefully" {
            Mock Get-DlpCompliancePolicy { throw "Connection error" }

            $script:capturedStatus = $null
            $script:capturedResult = $null
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                $script:capturedStatus = $Status
                $script:capturedResult = $Result
                "## Scenario: Error Handling`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35041

            $script:capturedStatus | Should Be $false
            $script:capturedResult | Should Match "Browser DLP for AI apps is not configured"
        }
    }
}
