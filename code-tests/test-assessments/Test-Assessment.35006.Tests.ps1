Describe "Test-Assessment-35006" {
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
        $sut = Join-Path $srcRoot "tests/Test-Assessment.35006.ps1"
        . $sut

        # Setup output file
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.35006.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
        "# Test Results for 35006`n" | Set-Content $script:outputFile
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

            Test-Assessment-35006

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and $Result -match "Unable to query SharePoint Tenant Settings"
            }
        }
    }

    Context "When PDF labeling support is enabled" {
        It "Should return Pass status" {
            Mock Get-SPOTenant {
                return [PSCustomObject]@{
                    EnableSensitivityLabelforPDF = $true
                }
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: PDF labeling enabled`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35006

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and $Result -match 'EnableSensitivityLabelforPDF: True'
            }
        }
    }

    Context "When PDF labeling support is disabled" {
        It "Should return Fail status" {
            Mock Get-SPOTenant {
                return [PSCustomObject]@{
                    EnableSensitivityLabelforPDF = $false
                }
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: PDF labeling disabled`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35006

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and $Result -match 'EnableSensitivityLabelforPDF: False'
            }
        }
    }

    Context "When Get-SPOTenant returns null" {
        It "Should return Fail status" {
            Mock Get-SPOTenant { return $null }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Get-SPOTenant returns null`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35006

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and $Result -match 'EnableSensitivityLabelforPDF: False'
            }
        }
    }
}
