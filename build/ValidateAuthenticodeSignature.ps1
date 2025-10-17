# ------------------------------------------------------------------------------
#  Copyright (c) Microsoft Corporation.  All Rights Reserved.  Licensed under the MIT License.  See License in the project root for license information.
# ------------------------------------------------------------------------------

Set-StrictMode -Version 5

# Import Pester for the Should assertions
Import-Module Pester -Force

# Define the output directory where built modules should be located
$outputPath = Join-Path (Split-Path -Parent $PSScriptRoot) "bin"

if (-not (Test-Path $outputPath)) {
    Write-Warning "Output directory not found: $outputPath"
    exit 1
}

# Find all PowerShell module files to validate
$moduleFiles = Get-ChildItem -Path $outputPath -Recurse -Include "*.psd1", "*.psm1" -ErrorAction SilentlyContinue

if ($moduleFiles.Count -eq 0) {
    Write-Warning "No PowerShell module files found in: $outputPath"
    exit 0
}

foreach ($file in $moduleFiles) {
    Write-Host "Validating signature for: $($file.Name)"

    # Skip .psm1 files for ZeroTrustAssessmentv2 as specified in original logic
    if ($file.Name -like "*ZeroTrustAssessmentv2*" -and $file.Extension -eq ".psm1") {
        Write-Host "Skipping .psm1 validation for ZeroTrustAssessmentv2 as configured"
        continue
    }

    ($file.FullName | Get-AuthenticodeSignature).Status | Should -Be "Valid"
}
