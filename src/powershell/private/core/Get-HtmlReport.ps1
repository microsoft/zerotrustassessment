<#
 .Synopsis
  Generates a formatted html report.

 .Description
    The generated html is a single file with the results of the assessment.

#>

function Get-HtmlReport {
    [CmdletBinding()]
    param(
        # The json of the results of the assessment.
        [Parameter(Mandatory = $true, Position = 0)]
        [psobject] $AssessmentResults,

        # Path to store temporary file used during generation
        [Parameter(Mandatory = $false)]
        [string] $Path,

        # Optional template path. Defaults to the primary report template.
        [Parameter(Mandatory = $false)]
        [string] $TemplatePath
    )

    #$json = $AssessmentResults | ConvertTo-Json -Depth 10 -WarningAction Ignore
    # Need to write to a file and read it back to avoid the json being escaped.
    # Fall back to OS temp path when a report path is not provided.
    $outputPath = if ([string]::IsNullOrWhiteSpace($Path)) {
        [System.IO.Path]::GetTempPath()
    }
    else {
        $Path
    }

    if (-not (Test-Path -Path $outputPath -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $outputPath -Force
    }

    $resultsJsonPath = Join-Path $outputPath "ZeroTrustAssessmentReportTemp.json"
    $AssessmentResults | Out-File -FilePath $resultsJsonPath
    $json = Get-Content -Path $resultsJsonPath -Raw
    Remove-Item -Path $resultsJsonPath -Force -ErrorAction SilentlyContinue | Out-Null

    Write-PSFMessage -Message $json -Level Debug
    $htmlFilePath = if ([string]::IsNullOrWhiteSpace($TemplatePath)) {
        Join-Path -Path $script:ModuleRoot -ChildPath 'assets/ReportTemplate.html'
    }
    else {
        $TemplatePath
    }

    if (-not (Test-Path -Path $htmlFilePath -PathType Leaf)) {
        throw "Report template not found at path: $htmlFilePath"
    }

    $templateHtml = Get-Content -Path $htmlFilePath -Raw

    # Insert the test results json into the template
    $startMarker = 'reportData={'
    $endMarker = 'EndOfJson:"EndOfJson"}'
    $insertLocationStart = $templateHtml.IndexOf($startMarker)
    $insertLocationEnd = $templateHtml.IndexOf($endMarker) + $endMarker.Length

    if ($insertLocationStart -lt 0 -or $insertLocationEnd -lt $endMarker.Length) {
        throw "Report template markers were not found in template: $htmlFilePath"
    }

    $outputHtml = $templateHtml.Substring(0, $insertLocationStart)
    $outputHtml += "reportData= $json"
    $outputHtml += $templateHtml.Substring($insertLocationEnd)

    return $outputHtml
}
