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
        # The folder to output the report to. If not specified, the report will be output to the current directory.
        [string]
        $OutputFolder = "./ZeroTrustReport"
    )

    if (!(Test-ZtContext))
    {
        return
    }

    Clear-ZtModuleVariable # Reset the graph cache and urls to avoid stale data

    Write-Verbose 'Creating report folder $OutputFolder'
    Remove-Item $OutputFolder -Recurse -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $OutputFolder -ErrorAction Stop

    Export-TenantData -OutputFolder $OutputFolder

    # Create database
    $dbPath = Join-Path $OutputFolder "ZeroTrustAssessment.db"
    $db = New-ZtDbConnection -Path $dbPath


}
