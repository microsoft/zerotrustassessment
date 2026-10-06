<#
.SYNOPSIS
Creates a validated, anonymized demo report and companion JSON.

.DESCRIPTION
Preserves assessment outcomes, replaces tenant-identifying content with
deterministic synthetic identities, and synthesizes coherent dashboard data.
An optional completed HTML report supplies the UX shell without rebuilding it.
All requested outputs are validated before publication.

.PARAMETER InputJsonPath
Assessment JSON export used as the primary report.

.PARAMETER OutputHtmlPath
Destination HTML file. Companion JSON is written beside it.

.PARAMETER SourceHtmlPath
Completed HTML from the same primary assessment run. Only its data payload is
replaced; its UI shell is preserved. Omit to use the repository template.

.PARAMETER SourceJsonPath
Optional secondary export whose Network and AI tests replace those pillars in
the primary data before comprehensive anonymization.

.PARAMETER OutputFrontendJsonPath
Optional additional JSON destination for the frontend development fixture.

.PARAMETER OutputWebsiteHtmlPath
Optional additional HTML destination for the website demo.

.EXAMPLE
.\New-DemoReport.ps1 -InputJsonPath 'C:\Reports\zt-export\ZeroTrustAssessmentReport.json' -SourceHtmlPath 'C:\Reports\ZeroTrustAssessmentReport.html' -OutputHtmlPath '.\SampleReport.html'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$InputJsonPath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputHtmlPath,

    [string]$SourceHtmlPath,
    [string]$SourceJsonPath,
    [string]$OutputFrontendJsonPath,
    [string]$OutputWebsiteHtmlPath
)

$ErrorActionPreference = 'Stop'
foreach ($helper in Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'private') -Filter '*.ps1' -File) {
    . $helper.FullName
}

if ([System.IO.Path]::GetExtension($OutputHtmlPath) -ine '.html') {
    throw 'The HTML output must have a .html extension.'
}
$inputs = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($path in @($InputJsonPath, $SourceJsonPath, $SourceHtmlPath)) {
    if (-not $path) { continue }
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw 'A required source report file does not exist.'
    }
    $null = $inputs.Add([System.IO.Path]::GetFullPath($path))
}
$targets = [ordered]@{
    Html = [System.IO.Path]::GetFullPath($OutputHtmlPath)
    Json = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetFullPath($OutputHtmlPath), '.json')
}
if ($OutputFrontendJsonPath) { $targets.Frontend = [System.IO.Path]::GetFullPath($OutputFrontendJsonPath) }
if ($OutputWebsiteHtmlPath) { $targets.Website = [System.IO.Path]::GetFullPath($OutputWebsiteHtmlPath) }
$uniqueTargets = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($target in $targets.Values) {
    if ($inputs.Contains($target) -or -not $uniqueTargets.Add($target)) {
        throw 'Output destinations must be distinct and must not overwrite a source report.'
    }
}
$readReport = {
    param([string]$Path)
    try {
        $text = [System.IO.File]::ReadAllText([System.IO.Path]::GetFullPath($Path))
        $data = ConvertFrom-Json -InputObject $text -AsHashtable -Depth 100 -ErrorAction Stop
    }
    catch {
        throw 'A source report could not be read as JSON.'
    }
    if ($data -isnot [System.Collections.IDictionary] -or -not $data.Contains('Tests')) {
        throw 'A source report must be a JSON object containing assessments.'
    }
    return $data
}
try {
    $originalText = [System.IO.File]::ReadAllText([System.IO.Path]::GetFullPath($InputJsonPath))
}
catch {
    throw 'The primary source report could not be read.'
}
$original = & $readReport $InputJsonPath
$report = & $readReport $InputJsonPath
$htmlPath = if ($SourceHtmlPath) {
    [System.IO.Path]::GetFullPath($SourceHtmlPath)
}
else {
    [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\src\powershell\assets\ReportTemplate.html'))
}
try {
    $sourceHtml = [System.IO.File]::ReadAllText($htmlPath)
}
catch {
    throw 'The report HTML shell could not be read.'
}
if ($SourceHtmlPath) {
    $null = Get-ZtDemoReportHtml -Json $originalText -Html $sourceHtml -OriginalJson $originalText
}
if ($SourceJsonPath) {
    $secondary = & $readReport $SourceJsonPath
    $pillars = @('Network', 'AI')
    $overlaid = [System.Collections.Generic.List[object]]::new()
    foreach ($test in $report.Tests) {
        if (@($test.TestPillar | Where-Object { $_ -in $pillars }).Count -eq 0) { $overlaid.Add($test) }
    }
    foreach ($test in $secondary.Tests) {
        $matching = @($test.TestPillar | Where-Object { $_ -in $pillars })
        if (-not $matching.Count) { continue }
        $test.TestPillar = if ($matching.Count -eq 1) { $matching[0] } else { $matching }
        $overlaid.Add($test)
    }
    $report.Tests = $overlaid.ToArray()
    $original = $report | ConvertTo-Json -Depth 100 | ConvertFrom-Json -AsHashtable -Depth 100
}

$staged = [System.Collections.Generic.List[object]]::new()
$published = [System.Collections.Generic.List[object]]::new()
$identityMap = $null
try {
    Write-Verbose 'Discovering demo identities.'
    $mapParameters = @{ Report = $report }
    if ($SourceJsonPath) { $mapParameters.AdditionalReports = @($secondary) }
    $identityMap = Get-ZtDemoIdentityMap @mapParameters
    $report = ConvertTo-ZtDemoReportData -Report $report -IdentityMap $identityMap
    $report = Set-ZtDemoDashboardData -Report $report
    $null = Test-ZtDemoReportData -Report $report -IdentityMap $identityMap -OriginalReport $original

    $json = $report | ConvertTo-Json -Depth 100
    $renderParameters = @{ Json = $json; Html = $sourceHtml }
    if ($SourceHtmlPath) { $renderParameters.OriginalJson = $originalText }
    $html = Get-ZtDemoReportHtml @renderParameters
    $null = Test-ZtDemoReportData -Report ($json | ConvertFrom-Json -AsHashtable -Depth 100) -IdentityMap $identityMap -OriginalReport $original -Html $html

    foreach ($entry in $targets.GetEnumerator()) {
        $directory = [System.IO.Path]::GetDirectoryName($entry.Value)
        $null = New-Item -Path $directory -ItemType Directory -Force
        $temporary = Join-Path $directory ('.zt-demo-' + [guid]::NewGuid().ToString('N') + '.tmp')
        $backup = Join-Path $directory ('.zt-demo-' + [guid]::NewGuid().ToString('N') + '.bak')
        $content = if ($entry.Key -in @('Html', 'Website')) { $html } else { $json }
        $staged.Add([pscustomobject]@{ Target = $entry.Value; Temporary = $temporary; Backup = $backup; Replaced = $false; RestoreFailed = $false })
        [System.IO.File]::WriteAllText($temporary, $content, [System.Text.UTF8Encoding]::new($false))
        if ([System.IO.File]::ReadAllText($temporary) -cne $content) {
            throw 'A staged demo output failed verification.'
        }
    }
    foreach ($item in $staged) {
        if ([System.IO.File]::Exists($item.Target)) {
            [System.IO.File]::Replace($item.Temporary, $item.Target, $item.Backup)
            $item.Replaced = $true
        }
        else {
            [System.IO.File]::Move($item.Temporary, $item.Target)
        }
        $published.Add($item)
    }
    Write-Host ('Published {0} validated demo files containing {1} assessments.' -f $targets.Count, @($report.Tests).Count)
}
catch {
    for ($i = $published.Count - 1; $i -ge 0; $i--) {
        $item = $published[$i]
        try {
            if ($item.Replaced) {
                [System.IO.File]::Replace($item.Backup, $item.Target, $item.Temporary)
            }
            elseif ([System.IO.File]::Exists($item.Target)) {
                [System.IO.File]::Delete($item.Target)
            }
        }
        catch {
            $item.RestoreFailed = $true
        }
    }
    if (@($published | Where-Object RestoreFailed).Count) {
        throw 'Demo publication failed and some outputs could not be restored. Recovery backups were retained in their output directories.'
    }
    throw
}
finally {
    foreach ($item in $staged) {
        if ($item.RestoreFailed) { continue }
        foreach ($path in @($item.Temporary, $item.Backup)) {
            if ([System.IO.File]::Exists($path)) { [System.IO.File]::Delete($path) }
        }
    }
    $identityMap = $null
    $original = $null
    $report = $null
    $originalText = $null
}
