<#
.SYNOPSIS
Runs the Zero Trust Assessment against the signed in tenant and generates a report of the findings.

.DESCRIPTION
This function is only a sample Advanced function that returns the Data given via parameter Data.

.EXAMPLE
Invoke-ZeroTrustAssessment

Run the Zero Trust Assessment against the signed in tenant and generates a report of the findings.
#>

function Invoke-ZtAssessment {
    [Alias('Invoke-ZeroTrustAssessment')]
    [CmdletBinding()]
    param (
        # The path to the folder folder to output the report to. If not specified, the report will be output to the current directory.
        [string]
        $Path = "./ZeroTrustReport",

        # Optional. Number of days (between 1 and 30) to query sign-in logs. Defaults to last two days.
        [ValidateScript({
                $_ -ge 1 -and $_ -le 30
            },
            ErrorMessage = "Logs are only available for 30 days. Please enter a number between 1 and 30.")]
        [int]
        $Days = 30,

        # Optional. The maximum time (in minutes) the assessment should spend on querying sign-in logs. Defaults to collecting sign logs for 60 minutes. Set to 0 for no limit.
        [int]
        $MaximumSignInLogQueryTime = 60,

        # If specified, the previously exported data will be used to generate the report.
        [switch]
        $Resume,

        # If specified, the script will output a high level summary of log messages. Useful for debugging. Use -Verbose and -Debug for more detailed logs.
        [switch]
        $ShowLog,

        # If specified, writes the log to a file.
        [switch]
        $ExportLog,

        # If specified, disables the collection of telemetry. The only telemetry collected is the tenant id. Defaults to true.
        [switch]
        $DisableTelemetry = $false
    )

    $banner = @"
╔═══════════════════════════════════════════════════════════════╗
║ Microsoft Zero Trust Assessment v2                            ║
╚═══════════════════════════════════════════════════════════════╝
"@

Write-Host $banner -ForegroundColor Cyan

    #$ExportLog = $true # Always create support package during public preview TODO: Remove this line after public preview

    if ($ShowLog) {
        $null = New-PSFMessageLevelModifier -Name ZeroTrustAssessmentV2.VeryVerbose -Modifier -1 -IncludeModuleName ZeroTrustAssessmentV2
    }
    else {
        Get-PSFMessageLevelModifier -Name ZeroTrustAssessmentV2.VeryVerbose | Remove-PSFMessageLevelModifier
    }

    $exportPath = Join-Path $Path "zt-export"

    # Stop if folder has items inside it
    if (!$Resume.IsPresent -and (Test-Path $Path)) {
        if ((Get-ChildItem $Path).Count -gt 0) {
            # Prompt user if it's okay to delete the folder and get confirmation
            Write-Host "`nFolder $Path is not empty. Do you want to delete the contents and continue (y/n)?" -ForegroundColor Yellow -NoNewline
            $deleteFolder = Read-Host
            if ($deleteFolder -eq "y") {
                Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop | Out-Null
            }
            else {
                Write-Error "Folder $Path is not empty. Please provide a path to an empty folder."
                return
            }
        }
    }

    if (!(Test-ZtContext)) {
        return
    }

    # Send telemetry if not disabled
    if (!$DisableTelemetry) {
        try {
            $tenantId = (Get-MgContext).TenantId
            if ($tenantId) {
                Send-ZtAppInsightsTelemetry -EventName "ZTv2TenantId" -Properties @{ TenantId = $tenantId }
            }
        }
        catch {
            # Silently continue if sending telemetry fails
            Write-PSFMessage -Level Debug -Message "Failed to send telemetry: $_"
        }
    }

    Clear-ZtModuleVariable # Reset the graph cache and urls to avoid stale data

    Write-PSFMessage 'Creating report folder $Path'
    New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null

    # Collect data
    Export-TenantData -ExportPath $exportPath -Days $Days -MaximumSignInLogQueryTime $MaximumSignInLogQueryTime
    $db = Export-Database -ExportPath $exportPath

    # Get Tenant Type (AAD = Workforce, CIAM = EEID)
    $tenantType = Get-MgOrganization | Select-Object -ExpandProperty TenantType
    Write-Host $tenantType "tenant detected. This will determine the tests that are run." -ForegroundColor Yellow

    # Run the tests
    Invoke-ZtTests -Database $db -TenantType $tenantType
    Invoke-ZtTenantInfo -Database $db

    $assessmentResults = Get-ZtAssessmentResults

    Disconnect-Database -Db $db

    $assessmentResultsJson = $assessmentResults | ConvertTo-Json -Depth 10
    $resultsJsonPath = Join-Path $Path "ZeroTrustAssessmentReport.json"
    $assessmentResultsJson | Out-File -FilePath $resultsJsonPath

    Write-ZtProgress -Activity "Creating html report"
    $htmlReportPath = Join-Path $Path "ZeroTrustAssessmentReport.html"
    $output = Get-HtmlReport -AssessmentResults $assessmentResultsJson -Path $Path
    $output | Out-File -FilePath $htmlReportPath -Encoding UTF8

    Write-Host
    Write-Host "🛡️ Zero Trust Assessment report generated at $htmlReportPath" -ForegroundColor Green
    Write-Host
    Write-Host "▶▶▶ ✨ Your feedback matters! Help us improve 👉 https://aka.ms/ztworkshop/v2/feedback ◀◀◀" -ForegroundColor Yellow
    Write-Host
    Write-Host
    Invoke-Item $htmlReportPath | Out-Null

    if ($ExportLog) {
        Write-ZtProgress -Activity "Creating support package"
        $logPath = Join-Path $Path "log"
        if(!(Test-Path $logPath)) {
            New-Item -ItemType Directory -Path $logPath -Force -ErrorAction Stop | Out-Null
        }
        New-PSFSupportPackage -Path $logPath
    }
}
