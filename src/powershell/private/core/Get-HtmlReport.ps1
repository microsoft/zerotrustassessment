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
        [string] $Path
    )

    #$json = $AssessmentResults | ConvertTo-Json -Depth 10 -WarningAction Ignore
    # Need to write to a file and read it back to avoid the json being escaped
    $resultsJsonPath = Join-Path $Path "ZeroTrustAssessmentReportTemp.json"
    $AssessmentResults | Out-File -FilePath $resultsJsonPath
    $json = Get-Content -Path $resultsJsonPath -Raw
    Remove-Item -Path $resultsJsonPath -Force -ErrorAction SilentlyContinue | Out-Null

    Write-Verbose "$json"
    $htmlFilePath = Join-Path -Path $PSScriptRoot -ChildPath '../../assets/ReportTemplate.html'
    $templateHtml = Get-Content -Path $htmlFilePath -Raw

    # Insert the test results json into the template
    $startMarker = 'reportData={'
    $endMarker = 'EndOfJson:"EndOfJson"}'
    $insertLocationStart = $templateHtml.IndexOf($startMarker)
    $insertLocationEnd = $templateHtml.IndexOf($endMarker) + $endMarker.Length

    $outputHtml = $templateHtml.Substring(0, $insertLocationStart)
    $outputHtml += "reportData= $json"
    $outputHtml += $templateHtml.Substring($insertLocationEnd)

    return $outputHtml
}
