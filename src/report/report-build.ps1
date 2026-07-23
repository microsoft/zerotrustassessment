# Run this in the ./src/report directory to build the report template and copy it to the powershell assets directory.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Default', 'Classic', 'Both')]
    [string]$Template = 'Both'
)

function Build-TemplateVariant {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('default', 'classic')]
        [string]$Variant,

        [Parameter(Mandatory = $true)]
        [ValidateSet('build', 'build:current')]
        [string]$BuildScript,

        [Parameter(Mandatory = $true)]
        [string]$BuildOutput,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    Write-Host "Building $Variant report template"
    npm run $BuildScript

    if ($LASTEXITCODE -ne 0) {
        throw "Build failed for template variant '$Variant'."
    }

    Write-Host "Updating $Variant report template: $Destination"
    Copy-Item $BuildOutput $Destination -Force
}

Write-Host "Building report"
$assetPath = "../powershell/assets"

if ($Template -eq 'Default' -or $Template -eq 'Both') {
    Build-TemplateVariant -Variant 'default' -BuildScript 'build:current' -BuildOutput './dist/index.current.html' -Destination "$assetPath/ReportTemplate.html"
}

if ($Template -eq 'Classic' -or $Template -eq 'Both') {
    Build-TemplateVariant -Variant 'classic' -BuildScript 'build' -BuildOutput './dist/index.html' -Destination "$assetPath/ReportTemplate.classic.html"
}
