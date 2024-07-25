<#
.SYNOPSIS
Runs the Zero Trust Assessment against the signed in tenant and generates a report of the findings.

.DESCRIPTION
This function is only a sample Advanced function that returns the Data given via parameter Data.

.EXAMPLE
Invoke-ZeroTrustAssessment

Run the Zero Trust Assessment against the signed in tenant and generates a report of the findings.
#>

function Invoke-ZtAssessment
{
    [Alias('Invoke-ZeroTrustAssessment')]
    [CmdletBinding()]
    param (
        # The path to the folder folder to output the report to. If not specified, the report will be output to the current directory.
        [string]
        $Path = "./ZeroTrustReport"
    )

    # Stop if folder has items inside it
    if (Test-Path $Path) {
        if ((Get-ChildItem $Path).Count -gt 0) {
            Write-Error "Folder $Path is not empty. Please provide a path to an empty folder."
            return
        }
    }

    if (!(Test-ZtContext)){ return }

    Clear-ZtModuleVariable # Reset the graph cache and urls to avoid stale data

    Write-Verbose 'Creating report folder $OutputFolder'
    New-Item -ItemType Directory -Path $Path -ErrorAction Stop | Out-Null

    Export-TenantData -Path $Path

    # Create database
    # $dbPath = Join-Path $Path "ZeroTrustAssessment.db"
    # $db = New-ZtDbConnection -Path $dbPath

    # $assessmentResults = Get-ZtAssessmentResults $ TODO:

    #Write-ZtProgress -Activity "Creating html report"
    # $assessmentResults = @("Test1", "Test2", "Test3")
    # $htmlReportPath = Join-Path $Path "ZeroTrustAssessmentReport.html"
    # $output = Get-HtmlReport -AssessmentResults $assessmentResults
    # $output | Out-File -FilePath $htmlReportPath -Encoding UTF8

    # Write-Host "🛡️ Zero Trust Assessmet report generated at $htmlReportPath" -ForegroundColor Green

    # Invoke-Item $htmlReportPath | Out-Null
}
