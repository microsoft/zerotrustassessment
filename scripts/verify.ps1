#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$failures = 0

Push-Location $root
try {
    Write-Host '== Syntax check: src PowerShell =='
    $targets = @(
        Get-ChildItem -Path (Join-Path $root 'src') -Recurse -File -Filter *.ps1 `
            -ErrorAction SilentlyContinue
    )

    if (-not $targets) {
        Write-Host '  WARN: no .ps1 files found under src/.'
    }

    foreach ($file in $targets) {
        $tokens = $null
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile(
            $file.FullName,
            [ref]$tokens,
            [ref]$errors
        ) | Out-Null

        if ($errors) {
            Write-Host "  SYNTAX: $($file.FullName)"
            $errors | ForEach-Object { Write-Host "    $($_.Message)" }
            $failures++
        }
    }

    if ($failures -eq 0) {
        Write-Host "  OK: $($targets.Count) file(s) parse cleanly."
    }

    Write-Host '== Config check: build PowerShell data files =='
    $configFiles = @(
        Get-ChildItem -Path (Join-Path $root 'build') -Recurse -File -Filter *.psd1 `
            -ErrorAction SilentlyContinue
    )

    foreach ($configFile in $configFiles) {
        try {
            Import-PowerShellDataFile -Path $configFile.FullName -ErrorAction Stop | Out-Null
            Write-Host "  OK: $($configFile.Name)"
        }
        catch {
            Write-Host "  INVALID: $($configFile.FullName) -> $($_.Exception.Message)"
            $failures++
        }
    }

    Write-Host '== Pester =='
    if (Get-Module -ListAvailable -Name Pester) {
        Write-Host "  INFO: run 'Invoke-Pester -Path ./code-tests' after building the module."
    }
    else {
        Write-Host '  SKIP: Pester is not installed.'
    }
}
finally {
    Pop-Location
}

if ($failures -gt 0) {
    Write-Host "verify.ps1 FAILED with $failures error(s)." -ForegroundColor Red
    exit 1
}

Write-Host 'verify.ps1 PASSED.' -ForegroundColor Green
exit 0
