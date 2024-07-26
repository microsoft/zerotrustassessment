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
        [psobject] $AssessmentResults
    )

    $json = $AssessmentResults | ConvertTo-Json -Depth 10 -WarningAction Ignore

    $htmlFilePath = Join-Path -Path $PSScriptRoot -ChildPath '../../assets/ReportTemplate.html'
    $templateHtml = Get-Content -Path $htmlFilePath -Raw

    # Insert the test results json into the template
    $insertLocationStart = $templateHtml.IndexOf("const assessmentResults = {")
    $insertLocationEnd = $templateHtml.IndexOf("function App() {")

    $outputHtml = $templateHtml.Substring(0, $insertLocationStart)
    $outputHtml += "const assessmentResults = $json;`n"
    $outputHtml += $templateHtml.Substring($insertLocationEnd)

    return $outputHtml
}
