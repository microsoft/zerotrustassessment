<#

    .SYNOPSIS
        Checks if the MetaConfig file is valid and contains all the commands in the tests folders
#>


$hasMissingCommands = $false

$testMetaPath = "$($PSScriptRoot)../../../src/powershell/private/tests/TestMeta.json"
$testMeta = Get-Content -Path $testMetaPath | ConvertFrom-Json -AsHashtable

$testsCmdletPath = "$($PSScriptRoot)../../../src/powershell/private/tests"

$testCmdletFiles = Get-ChildItem -Path $testsCmdletPath -Recurse -Filter "Test-*.ps1"

# Check if all commands in the TestMeta.json file exist in the tests folder
foreach ($test in $testMeta.Values) {
    $testName = "Test-Assessment.$($test.TestId)"
    $testCmdletFile = $testCmdletFiles | Where-Object { $_.Name -eq "$testName.ps1" }

    if (-not $testCmdletFile) {
        $hasMissingCommands = $true
        Write-Host "🟦 Test command '$testName' not found in the tests folder." -ForegroundColor Red
    }
    else {
        Write-Verbose "Test command '$testName' found in the tests folder."
    }
}

# Check if all commands in the tests folder are present in the TestMeta.json file
$testCmdletNames = $testCmdletFiles | ForEach-Object { $_.BaseName }
foreach ($testCmdletName in $testCmdletNames) {

    $testId = $testCmdletName -replace "^Test-Assessment.", ""
    $testExists = $testMeta.Values | Where-Object { $_.TestId -eq $testId }

    if (-not $testExists) {
        $hasMissingCommands = $true
        Write-Host "🟨 Test command '$testCmdletName' is not defined in the TestMeta.json file." -ForegroundColor Red
    }
    else {
        Write-Verbose "Test command '$testCmdletName' is defined in the TestMeta.json file."
    }
}

if ($hasMissingCommands) {
    Write-Host "MetaConfig validation failed. Please check the output for missing commands." -ForegroundColor Red
    return
}
Write-Host "MetaConfig validation completed successfully."
