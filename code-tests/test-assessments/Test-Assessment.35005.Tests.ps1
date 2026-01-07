Describe "Test-Assessment-35005" {
    BeforeAll {
        $here = $PSScriptRoot
        $srcRoot = Join-Path $here "../../src/powershell"

        # Mock external module dependencies if they are not present
        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function Write-PSFMessage {}
        }
        if (-not (Get-Command Get-SPOTenant -ErrorAction SilentlyContinue)) {
            function Get-SPOTenant {}
        }

        # Load the class
        $classPath = Join-Path $srcRoot "classes/ZtTest.ps1"
        if (-not ("ZtTest" -as [type])) {
            . $classPath
        }

        # Load the SUT
        $sut = Join-Path $srcRoot "tests/Test-Assessment.35005.ps1"
        . $sut

        # Setup output file
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.35005.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
        "# Test Results for 35005`n" | Set-Content $script:outputFile
    }

    # Mock common module functions
    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
    }

    Context "When querying SharePoint tenant settings fails" {
        It "Should return Investigate status" {
            Mock Get-SPOTenant { throw "Connection error" }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Error querying settings`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35005

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and $Result -match "Unable to query SharePoint Tenant Settings"
            }
        }
    }

    Context "When EnableAIPIntegration is disabled" {
        It "Should fail" {
            Mock Get-SPOTenant {
                return [PSCustomObject]@{
                    EnableAIPIntegration = $false
                }
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: EnableAIPIntegration disabled`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35005

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and
                $Result -match "Sensitivity labels are NOT enabled" -and
                $Result -match "EnableAIPIntegration: False"
            }
        }
    }

    Context "When EnableAIPIntegration is enabled" {
        It "Should pass" {
            Mock Get-SPOTenant {
                return [PSCustomObject]@{
                    EnableAIPIntegration = $true
                }
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: EnableAIPIntegration enabled`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35005

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and
                $Result -match "Sensitivity labels are enabled" -and
                $Result -match "EnableAIPIntegration: True"
            }
        }
    }
}
