Describe "Test-Assessment-35004" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        # Mock external module dependencies if they are not present
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function Write-PSFMessage {}
        }
        if (-not (Get-Command Get-LabelPolicy -ErrorAction SilentlyContinue)) {
            function Get-LabelPolicy {}
        }

        # Load the class
        $classPath = Join-Path $srcRoot "classes/ZtTest.ps1"
        if (-not ("ZtTest" -as [type])) {
            . $classPath
        }

        # Load the SUT
        $sut = Join-Path $srcRoot "tests/Test-Assessment.35004.ps1"
        . $sut

        # Setup output file
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.35004.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
        "# Test Results for 35004`n" | Set-Content $script:outputFile
    }

    # Mock common module functions
    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }
    }

    Context "When querying label policies fails" {
        It "Should return Investigate status" {
            Mock Get-LabelPolicy { throw "Connection error" }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Error querying policies`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35004

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and $Result -match "Unable to query label policies"
            }
        }
    }

    Context "When no label policies exist" {
        It "Should fail" {
            Mock Get-LabelPolicy { return @() }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: No policies exist`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35004

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and
                $Result -match "No enabled label policies exist" -and
                $Result -notmatch "\| Policy Name \|"
            }
        }
    }

    Context "When policies exist but are disabled" {
        It "Should fail" {
            Mock Get-LabelPolicy {
                return @(
                    [PSCustomObject]@{
                        Name = "Disabled Policy"
                        Enabled = $false
                        Labels = @("Label1")
                        ExchangeLocation = @()
                        ModernGroupLocation = @()
                        SharePointLocation = @()
                        OneDriveLocation = @()
                    }
                )
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: All policies disabled`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35004

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and
                $Result -match "No enabled label policies exist" -and
                $Result -match "\| Policy Name \|"
            }
        }
    }

    Context "When enabled policies exist" {
        It "Should pass with 'All Users' scope" {
            Mock Get-LabelPolicy {
                return @(
                    [PSCustomObject]@{
                        Name = "Global Policy"
                        Enabled = $true
                        Labels = @("Label1", "Label2")
                        ExchangeLocation = @("All")
                        ModernGroupLocation = @()
                        SharePointLocation = @()
                        OneDriveLocation = @()
                    }
                )
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Enabled policy for All Users`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35004

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and
                $Result -match "At least one enabled label policy is published" -and
                $Result -match "Total Users/Groups with Label Access: All Users"
            }
        }

        It "Should pass with specific users/groups scope" {
            Mock Get-LabelPolicy {
                return @(
                    [PSCustomObject]@{
                        Name = "Specific Policy"
                        Enabled = $true
                        Labels = @("Label1")
                        ExchangeLocation = @("user1@contoso.com", "user2@contoso.com")
                        ModernGroupLocation = @("group1@contoso.com")
                        SharePointLocation = @()
                        OneDriveLocation = @()
                    }
                )
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Enabled policy for specific users`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35004

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and
                $Result -match "At least one enabled label policy is published" -and
                $Result -match "Total Users/Groups with Label Access: 3"
            }
        }
    }
}
