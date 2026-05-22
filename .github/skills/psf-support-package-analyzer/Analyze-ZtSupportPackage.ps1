<#
.SYNOPSIS
    Analyzes a PSFramework support package (.cliDat) and outputs a structured JSON report.

.DESCRIPTION
    Imports a PSFramework support package created by New-PSFSupportPackage, extracts all
    errors, warnings, and critical messages with surrounding context, and outputs a JSON
    report suitable for automated or AI-assisted troubleshooting.

.PARAMETER Path
    Path to the .cliDat file to analyze.

.PARAMETER ContextLines
    Number of preceding log messages to include as context for each error/warning. Default: 5.

.PARAMETER OutputPath
    Optional. If specified, writes the JSON report to this file instead of stdout.

.EXAMPLE
    .\Analyze-ZtSupportPackage.ps1 -Path "C:\logs\support_pack.cliDat"

.EXAMPLE
    .\Analyze-ZtSupportPackage.ps1 -Path "C:\logs\support_pack.cliDat" -ContextLines 10 -OutputPath "C:\logs\analysis.json"
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter()]
    [int]$ContextLines = 5,

    [Parameter()]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

#region Validate Input
if (-not (Test-Path $Path)) {
    # If path is a directory, look for the .cliDat file inside
    if (Test-Path $Path -PathType Container) {
        $cliDatFile = Get-ChildItem -Path $Path -Filter "*.cliDat" -Recurse | Select-Object -First 1
        if ($cliDatFile) {
            $Path = $cliDatFile.FullName
        } else {
            throw "No .cliDat file found in directory: $Path"
        }
    } else {
        throw "File not found: $Path"
    }
}

if ($Path -notlike "*.cliDat") {
    # Check if it's a zip that needs extraction
    if ($Path -like "*.zip") {
        throw "Please extract the ZIP file first and point to the .cliDat file inside."
    }
}
#endregion

#region Import Package
if (-not (Get-Module PSFramework -ListAvailable)) {
    throw "PSFramework module is required. Install with: Install-Module PSFramework -Scope CurrentUser"
}
Import-Module PSFramework -ErrorAction Stop

Write-Verbose "Importing support package from: $Path"
$pack = Import-PSFClixml -Path $Path
#endregion

#region Build Function-to-Source Map
$functionSourceMap = @{
    'Connect-ZtAssessment'              = 'src/powershell/public/Connect-ZtAssessment.ps1'
    'Disconnect-ZtAssessment'           = 'src/powershell/public/Disconnect-ZtAssessment.ps1'
    'Invoke-ZtAssessment'               = 'src/powershell/public/Invoke-ZtAssessment.ps1'
    'Invoke-ZtGraphRequest'             = 'src/powershell/public/Invoke-ZtGraphRequest.ps1'
    'Invoke-ZtAzureRequest'             = 'src/powershell/public/Invoke-ZtAzureRequest.ps1'
    'Get-ZtTest'                        = 'src/powershell/public/Get-ZtTest.ps1'
    'Get-ZtExportStatistics'            = 'src/powershell/public/Get-ZtExportStatistics.ps1'
    'Get-ZtTestStatistics'              = 'src/powershell/public/Get-ZtTestStatistics.ps1'
    'Export-ZtGraphEntity'              = 'src/powershell/private/export/Export-ZtGraphEntity.ps1'
    'Export-ZtGraphEntityPrivilegedGroup' = 'src/powershell/private/export/Export-ZtGraphEntityPrivilegedGroup.ps1'
    'Invoke-ZtTenantDataExport'         = 'src/powershell/private/export/Invoke-ZtTenantDataExport.ps1'
    'Wait-ZtTenantDataExport'           = 'src/powershell/private/export/Wait-ZtTenantDataExport.ps1'
    'Start-ZtTenantDataExport'          = 'src/powershell/private/export/Start-ZtTenantDataExport.ps1'
    'Export-TenantData'                 = 'src/powershell/private/export/Export-TenantData.ps1'
    'Export-ZtTenantData'               = 'src/powershell/private/export/Export-ZtTenantData.ps1'
    'Export-Database'                    = 'src/powershell/private/export/Export-Database.ps1'
    'Write-ZtExportProgress'            = 'src/powershell/private/export/Write-ZtExportProgress.ps1'
    'Write-ZtExportLog'                 = 'src/powershell/private/export/Write-ZtExportLog.ps1'
    'Write-ZtDatabaseLog'               = 'src/powershell/private/export/Write-ZtDatabaseLog.ps1'
    'Invoke-ZtRetry'                    = 'src/powershell/private/core/Invoke-ZtRetry.ps1'
    'Test-ZtRetryableError'             = 'src/powershell/private/core/Test-ZtRetryableError.ps1'
    'Get-ZtHttpStatusCode'              = 'src/powershell/private/core/Get-ZtHttpStatusCode.ps1'
    'Get-ZtTestStatus'                  = 'src/powershell/private/core/Get-ZtTestStatus.ps1'
    'Get-ZtAssessmentResults'           = 'src/powershell/private/core/Get-ZtAssessmentResults.ps1'
    'Invoke-ZtGraphBatchRequest'        = 'src/powershell/private/graph/Invoke-ZtGraphBatchRequest.ps1'
    'Invoke-ZtGraphRequestCache'        = 'src/powershell/private/core/Invoke-ZtGraphRequestCache.ps1'
    'Invoke-ZtAzureRequestCache'        = 'src/powershell/private/core/Invoke-ZtAzureRequestCache.ps1'
    'New-PSFSupportPackage'             = '[PSFramework built-in]'
}
#endregion

#region Extract Environment Info
$psVer = "Unknown"
$osInfo = "Unknown"
$platform = "Unknown"
if ($pack.PSVersion) {
    if ($pack.PSVersion -is [hashtable]) {
        $psVer = if ($pack.PSVersion['PSVersion']) { "$($pack.PSVersion['PSVersion'])" } else { "Unknown" }
        $osInfo = if ($pack.PSVersion['OS']) { "$($pack.PSVersion['OS'])" } else { "Unknown" }
        $platform = if ($pack.PSVersion['Platform']) { "$($pack.PSVersion['Platform'])" } else { "Unknown" }
    } elseif ($pack.PSVersion.Major) {
        $psVer = "$($pack.PSVersion.Major).$($pack.PSVersion.Minor).$($pack.PSVersion.Patch)"
    }
}

$environment = @{
    PSVersion       = $psVer
    OperatingSystem = $osInfo
    Platform        = $platform
    CPU             = if ($pack.CPU) { ($pack.CPU | Select-Object -ExpandProperty Name -ErrorAction SilentlyContinue) -join ', ' } else { "Unknown" }
    Ram             = if ($pack.Ram) { "{0:N0} GB" -f (($pack.Ram | Measure-Object -Property Capacity -Sum).Sum / 1GB) } else { "Unknown" }
}

# Find ZTA module version
$ztaModule = $null
if ($pack.Modules) {
    $ztaModule = $pack.Modules | Where-Object { $_.Name -eq 'ZeroTrustAssessment' } | Select-Object -First 1
}
if ($ztaModule) {
    $environment['ZtaModuleVersion'] = "$($ztaModule.Version)"
}
#endregion

#region Analyze Messages
$allMsgs = @($pack.Messages | Sort-Object Timestamp)
$totalCount = $allMsgs.Count

$issues = [System.Collections.ArrayList]::new()
$issueIndex = 0

for ($i = 0; $i -lt $allMsgs.Count; $i++) {
    $msg = $allMsgs[$i]
    if ($msg.Level -notin 'Warning', 'Error', 'Critical') { continue }

    # Skip the New-PSFSupportPackage "Gathering information" critical message
    if ($msg.FunctionName -eq 'New-PSFSupportPackage') { continue }

    $issueIndex++
    $contextStart = [Math]::Max(0, $i - $ContextLines)
    $context = @()
    for ($j = $contextStart; $j -lt $i; $j++) {
        $ctx = $allMsgs[$j]
        $context += @{
            Timestamp    = $ctx.Timestamp.ToString('yyyy-MM-dd HH:mm:ss')
            Level        = "$($ctx.Level)"
            FunctionName = $ctx.FunctionName
            Message      = $ctx.Message
        }
    }

    $errorDetail = $null
    if ($msg.ErrorRecord) {
        $errorDetail = @{
            Exception    = "$($msg.ErrorRecord.Exception.Message)"
            Category     = "$($msg.ErrorRecord.CategoryInfo.Category)"
            TargetObject = "$($msg.ErrorRecord.TargetObject)"
            ScriptTrace  = "$($msg.ErrorRecord.ScriptStackTrace)"
        }
    }

    $sourceFile = $null
    if ($msg.FunctionName -and $functionSourceMap.ContainsKey($msg.FunctionName)) {
        $sourceFile = $functionSourceMap[$msg.FunctionName]
    }

    $null = $issues.Add(@{
        Index        = $issueIndex
        Timestamp    = $msg.Timestamp.ToString('yyyy-MM-dd HH:mm:ss')
        Level        = "$($msg.Level)"
        FunctionName = $msg.FunctionName
        SourceFile   = $sourceFile
        Message      = $msg.Message
        Tags         = @($msg.Tags)
        ErrorRecord  = $errorDetail
        Context      = $context
    })
}

# Compute time range
$timeRange = @{
    Start    = if ($allMsgs.Count -gt 0) { $allMsgs[0].Timestamp.ToString('yyyy-MM-dd HH:mm:ss') } else { $null }
    End      = if ($allMsgs.Count -gt 0) { $allMsgs[-1].Timestamp.ToString('yyyy-MM-dd HH:mm:ss') } else { $null }
    Duration = if ($allMsgs.Count -gt 1) { ($allMsgs[-1].Timestamp - $allMsgs[0].Timestamp).ToString() } else { $null }
}
#endregion

#region Extract Export Statistics
$exportStats = $null
if ($pack._ZTA_ExportStatistics) {
    $exportStats = @($pack._ZTA_ExportStatistics | ForEach-Object {
        @{
            Name     = $_.Name
            Success  = $_.Success
            Duration = if ($_.Duration) { $_.Duration.ToString() } else { $null }
            Error    = if ($_.Error) { "$($_.Error)" } else { $null }
        }
    })
}
#endregion

#region Extract Test Statistics
$testStats = $null
if ($pack._ZTA_TestStatistics) {
    $testStats = @($pack._ZTA_TestStatistics | ForEach-Object {
        @{
            Name   = $_.Name
            Status = $_.Status
            Error  = if ($_.Error) { "$($_.Error)" } else { $null }
        }
    })
}
#endregion

#region Categorize Issues
$categories = @{}
foreach ($issue in $issues) {
    $category = switch -Regex ($issue.Message) {
        'Skip token'                    { 'SkipTokenExpiration' }
        'requested name is valid'       { 'DNSResolutionFailure' }
        'HttpClient\.Timeout'           { 'HTTPTimeout' }
        'copying content to a stream'   { 'StreamError' }
        'InteractiveBrowserCredential'  { 'AuthenticationFailure' }
        'size limit'                    { 'SignInLogSizeLimit' }
        'null-valued expression'        { 'NullReference' }
        'Non-retryable error'           { 'NonRetryableError' }
        'Stuck paging'                  { 'StuckPaging' }
        default                         { 'Other' }
    }
    if (-not $categories[$category]) { $categories[$category] = 0 }
    $categories[$category]++
}
#endregion

#region Build Report
$report = @{
    AnalysisTimestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    PackagePath       = $Path
    Summary           = @{
        TotalMessages = $totalCount
        Errors        = @($issues | Where-Object { $_.Level -eq 'Error' }).Count
        Warnings      = @($issues | Where-Object { $_.Level -eq 'Warning' }).Count
        Critical      = @($issues | Where-Object { $_.Level -eq 'Critical' }).Count
        TimeRange     = $timeRange
        Categories    = $categories
    }
    Environment       = $environment
    Issues            = @($issues)
    ExportStatistics  = $exportStats
    TestStatistics    = $testStats
    FunctionSourceMap = $functionSourceMap
}
#endregion

#region Output
$json = $report | ConvertTo-Json -Depth 10 -EnumsAsStrings

if ($OutputPath) {
    $json | Set-Content -Path $OutputPath -Encoding UTF8
    Write-Host "Analysis report written to: $OutputPath"
} else {
    $json
}
#endregion
