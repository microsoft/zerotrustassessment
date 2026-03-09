Describe "Test-Assessment-35008" {
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
        $sut = Join-Path $srcRoot "tests/Test-Assessment.35008.ps1"
        . $sut

        # Setup output file
        $script:outputFile = Join-Path $here "../TestResults/Report-Test-Assessment.35008.md"
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
        "# Test Results for 35008`n" | Set-Content $script:outputFile
    }

    # Mock common module functions
    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
    }

    Context "When querying SharePoint tenant settings fails" {
        It "Should return Fail status with Investigate message" {
            Mock Get-SPOTenant { throw "Connection error" }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Error querying settings`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35008

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and $Result -match "Unable to query SharePoint Tenant Settings"
            }
        }
    }

    Context "When Default Labeling is Disabled (Fail)" {
        It "Should return Fail status" {
            Mock Get-SPOTenant {
                return [PSCustomObject]@{
                    DisableDocumentLibraryDefaultLabeling = $true
                }
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Default Labeling Disabled`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35008

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $false -and $Result -match 'DisableDocumentLibraryDefaultLabeling: True'
            }
        }
    }

    Context "When Default Labeling is Enabled (Pass)" {
        It "Should return Pass status" {
            Mock Get-SPOTenant {
                return [PSCustomObject]@{
                    DisableDocumentLibraryDefaultLabeling = $false
                }
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Default Labeling Enabled`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35008

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and $Result -match 'DisableDocumentLibraryDefaultLabeling: False'
            }
        }
    }

    Context "When Default Labeling is Null (Pass)" {
        It "Should return Pass status" {
            Mock Get-SPOTenant {
                return [PSCustomObject]@{
                    DisableDocumentLibraryDefaultLabeling = $null
                }
            }
            Mock Add-ZtTestResultDetail {
                param($TestId, $Title, $Status, $Result)
                "## Scenario: Default Labeling Null`n`n$Result`n" | Add-Content $script:outputFile
            }

            Test-Assessment-35008

            Should -Invoke Add-ZtTestResultDetail -ParameterFilter {
                $Status -eq $true -and $Result -match 'DisableDocumentLibraryDefaultLabeling: False'
            }
        }
    }
}
