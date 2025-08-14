<#
.SYNOPSIS
Runs the Zero Trust Assessment against the signed in tenant and generates a report of the findings.

.DESCRIPTION
This function runs the Zero Trust Assessment against the signed in tenant and generates a report of the findings.
The assessment can be configured using command-line parameters, a configuration file, or through interactive prompts.

.PARAMETER Path
The path to the folder to output the report to. If not specified, the report will be output to the current directory.

.PARAMETER Days
Optional. Number of days (between 1 and 30) to query sign-in logs. Defaults to 30 days.

.PARAMETER MaximumSignInLogQueryTime
Optional. The maximum time (in minutes) the assessment should spend on querying sign-in logs. Defaults to 60 minutes. Set to 0 for no limit.

.PARAMETER Resume
If specified, the previously exported data will be used to generate the report.

.PARAMETER ShowLog
If specified, the script will output a high level summary of log messages. Useful for debugging. Use -Verbose and -Debug for more detailed logs.

.PARAMETER ExportLog
If specified, writes the log to a file.

.PARAMETER DisableTelemetry
If specified, disables the collection of telemetry. The only telemetry collected is the tenant id. Defaults to false.

.PARAMETER Tests
The IDs of the specific test(s) to run. If not specified, all tests will be run.

.PARAMETER ConfigurationFile
Path to a configuration file. Parameters specified on the command line will override values from the configuration file.

.PARAMETER Interactive
If specified, prompts the user interactively for input values using a text-based user interface.

.EXAMPLE
Invoke-ZtAssessment

Run the Zero Trust Assessment against the signed in tenant and generates a report of the findings using default settings.

.EXAMPLE
Invoke-ZtAssessment -Path "C:\Reports\ZT" -Days 7 -ShowLog

Run the Zero Trust Assessment with a custom output path, querying 7 days of logs, and showing detailed logging.

.PARAMETER Pillar
The Zero Trust pillar to assess. Valid values are 'All', 'Identity', or 'Devices'. Defaults to 'All' which runs all tests.

.EXAMPLE
Invoke-ZtAssessment -ConfigurationFile "C:\Config\zt-config.json"

Run the Zero Trust Assessment using settings from a configuration file.

.EXAMPLE
Invoke-ZtAssessment -ConfigurationFile "C:\Config\zt-config.json" -Days 14 -ShowLog

Run the Zero Trust Assessment using settings from a configuration file, but override the Days parameter to 14 and enable ShowLog.

.EXAMPLE
Invoke-ZtAssessment -Interactive

Run the Zero Trust Assessment with an interactive text-based user interface to configure all parameters.

.EXAMPLE
Invoke-ZeroTrustAssessment -Pillar Identity

Run only the Identity pillar tests of the Zero Trust Assessment.

.EXAMPLE
Invoke-ZeroTrustAssessment -Pillar Devices

Run only the Devices pillar tests of the Zero Trust Assessment.
#>

function Invoke-ZtAssessment {
    [Alias('Invoke-ZeroTrustAssessment')]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        # The path to the folder folder to output the report to. If not specified, the report will be output to the current directory.
        [Parameter(ParameterSetName = 'Default')]
        [string]
        $Path = "./ZeroTrustReport",

        # Optional. Number of days (between 1 and 30) to query sign-in logs. Defaults to last two days.
        [Parameter(ParameterSetName = 'Default')]
        [ValidateScript({
                $_ -ge 1 -and $_ -le 30
            },
            ErrorMessage = "Logs are only available for 30 days. Please enter a number between 1 and 30.")]
        [int]
        $Days = 30,

        # Optional. The maximum time (in minutes) the assessment should spend on querying sign-in logs. Defaults to collecting sign logs for 60 minutes. Set to 0 for no limit.
        [Parameter(ParameterSetName = 'Default')]
        [int]
        $MaximumSignInLogQueryTime = 60,

        # If specified, the previously exported data will be used to generate the report.
        [Parameter(ParameterSetName = 'Default')]
        [switch]
        $Resume,

        # If specified, the script will output a high level summary of log messages. Useful for debugging. Use -Verbose and -Debug for more detailed logs.
        [Parameter(ParameterSetName = 'Default')]
        [switch]
        $ShowLog,

        # If specified, writes the log to a file.
        [Parameter(ParameterSetName = 'Default')]
        [switch]
        $ExportLog,

        # If specified, disables the collection of telemetry. The only telemetry collected is the tenant id. Defaults to true.
        [Parameter(ParameterSetName = 'Default')]
        [switch]
        $DisableTelemetry = $false,

        # The IDs of the specific test(s) to run. If not specified, all tests will be run.
        [Parameter(ParameterSetName = 'Default')]
        [string[]]
        $Tests,

        # Path to a configuration file. Parameters specified on the command line will override values from the configuration file.
        [Parameter(ParameterSetName = 'Default')]
        [ValidateScript({
                if (Test-Path $_ -PathType Leaf) {
                    $true
                } else {
                    throw "Configuration file '$_' does not exist."
                }
            })]
        [string]
        $ConfigurationFile,

        # If specified, prompts the user interactively for input values.
        [Parameter(ParameterSetName = 'Interactive', Mandatory)]
        [switch]
        $Interactive,
        
        # The Zero Trust pillar to assess. Defaults to All.
        [ValidateSet('All', 'Identity', 'Devices')]
        [string]
        $Pillar = 'All'
    )

    $banner = @"
╔═════════════════════════════════════════════════════════════════════════════╗
║                    🛡️  Microsoft Zero Trust Assessment v2                   ║
║                                                                             ║
║    Comprehensive security posture evaluation for your Microsoft 365 tenant  ║
╚═════════════════════════════════════════════════════════════════════════════╝
"@

    Write-Host $banner -ForegroundColor Cyan
    Write-Host
    Write-Host "🚀 " -NoNewline -ForegroundColor Green
    Write-Host "Starting Zero Trust Assessment..." -ForegroundColor White
    Write-Host

    # Handle configuration file parameter
    if ($ConfigurationFile) {
        try {
            Write-Host "📄 " -NoNewline -ForegroundColor Blue
            Write-Host "Loading configuration from file: " -NoNewline -ForegroundColor White
            Write-Host $ConfigurationFile -ForegroundColor Cyan
            $configContent = Get-Content -Path $ConfigurationFile -Raw | ConvertFrom-Json

            # Define parameters that can be configured
            $configurableParameters = @('Path', 'Days', 'MaximumSignInLogQueryTime', 'ShowLog', 'ExportLog', 'DisableTelemetry', 'Resume', 'Tests')

            # Apply configuration values only if parameters weren't explicitly provided
            foreach ($paramName in $configurableParameters) {
                # Skip if parameter was explicitly provided or config doesn't contain the property
                if ($PSBoundParameters.ContainsKey($paramName) -or
                    $configContent.PSObject.Properties.Name -notcontains $paramName) {
                    continue
                }

                # Special handling for Tests array to ensure it has items
                if ($paramName -eq 'Tests') {
                    if ($configContent.$paramName -and $configContent.$paramName.Count -gt 0) {
                        Set-Variable -Name $paramName -Value $configContent.$paramName
                    }
                } else {
                    Set-Variable -Name $paramName -Value $configContent.$paramName
                }
            }

            Write-Host "✅ " -NoNewline -ForegroundColor Green
            Write-Host "Configuration loaded successfully. Command line parameters will override configuration file values." -ForegroundColor White
            Write-Host
        }
        catch {
            Write-Host "❌ " -NoNewline -ForegroundColor Red
            Write-Host "Failed to load configuration from file '$ConfigurationFile': $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }

    # Handle interactive parameter collection
    if ($Interactive) {
        try {
            Write-Host "🎮 " -NoNewline -ForegroundColor Magenta
            Write-Host "Starting interactive parameter collection..." -ForegroundColor White
            Write-Host
            $tempConfigFile = New-ZtInteractiveConfig

            # Check if user cancelled the configuration creation
            if ($null -eq $tempConfigFile -or -not $tempConfigFile) {
                Write-Host "⏹️ " -NoNewline -ForegroundColor Yellow
                Write-Host "Interactive configuration cancelled by user. Exiting." -ForegroundColor Yellow
                return
            }

            # Verify the file exists before trying to read it (only if tempConfigFile is not null)
            if (-not (Test-Path $tempConfigFile.FullName -ErrorAction SilentlyContinue)) {
                Write-Host "❌ " -NoNewline -ForegroundColor Red
                Write-Host "Configuration file was not created. Exiting." -ForegroundColor Red
                return
            }

            # Import the configuration data from JSON
            $config = Get-Content -Path $tempConfigFile.FullName | ConvertFrom-Json

            # Assign interactive parameter values to variables
            $Path = $config.Path
            $Days = $config.Days
            $MaximumSignInLogQueryTime = $config.MaximumSignInLogQueryTime
            $ShowLog = $config.ShowLog
            $ExportLog = $config.ExportLog
            $DisableTelemetry = $config.DisableTelemetry
            $Resume = $config.Resume

            if ($config.PSObject.Properties.Name -contains 'Tests' -and $config.Tests.Count -gt 0) {
                $Tests = $config.Tests
            }

            Write-Host "✅ " -NoNewline -ForegroundColor Green
            Write-Host "Interactive configuration complete. Starting assessment..." -ForegroundColor Green
            Write-Host
        }
        catch {
            Write-Host "❌ " -NoNewline -ForegroundColor Red
            Write-Host "Failed to collect interactive parameters: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }

    #$ExportLog = $true # Always create support package during public preview TODO: Remove this line after public preview

    if ($ShowLog) {
        $null = New-PSFMessageLevelModifier -Name ZeroTrustAssessmentV2.VeryVerbose -Modifier -1 -IncludeModuleName ZeroTrustAssessmentV2
    }
    else {
        Get-PSFMessageLevelModifier -Name ZeroTrustAssessmentV2.VeryVerbose | Remove-PSFMessageLevelModifier
    }

    if(!(Test-DuckDb)) {
        return
    }

    if (!(Test-ZtContext)) {
        return
    }

    $exportPath = Join-Path $Path "zt-export"

    # Stop if folder has items inside it
    if (!$Resume.IsPresent -and (Test-Path $Path)) {
        if ((Get-ChildItem $Path).Count -gt 0) {
            Write-Host
            Write-Host "⚠️ " -NoNewline -ForegroundColor Yellow
            Write-Host "Output folder is not empty" -ForegroundColor Yellow
            Write-Host "📁 Path: " -NoNewline -ForegroundColor White
            Write-Host $Path -ForegroundColor Cyan
            Write-Host
            Write-Host "To generate a new report, the existing contents need to be removed." -ForegroundColor White
            Write-Host "Do you want to delete the contents and continue? " -NoNewline -ForegroundColor White
            Write-Host "[y/n]" -NoNewline -ForegroundColor Yellow
            $deleteFolder = Read-Host " "

            if ($deleteFolder -eq "y") {
                Write-Host "🗑️ " -NoNewline -ForegroundColor Red
                Write-Host "Cleaning up existing files..." -ForegroundColor White
                Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop | Out-Null
                Write-Host "✅ " -NoNewline -ForegroundColor Green
                Write-Host "Folder cleaned successfully" -ForegroundColor Green
                Write-Host
            }
            else {
                Write-Host "❌ " -NoNewline -ForegroundColor Red
                Write-Host "Assessment cancelled. Please provide a path to an empty folder or use -Resume to continue from existing data." -ForegroundColor Red
                return
            }
        }
    }

    # Create the export path if it doesn't exist
    if (!(Test-Path $exportPath)) {
        New-Item -ItemType Directory -Path $exportPath -Force -ErrorAction Stop | Out-Null
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

    # Move the interactive configuration file to the report directory if it exists
    if ($Interactive -and $tempConfigFile) {
        try {
            $finalConfigPath = Join-Path $Path "zt-interactive-config.json"
            Move-Item -Path $tempConfigFile.FullName -Destination $finalConfigPath -Force
            Write-Host "Configuration file moved to report directory: $finalConfigPath" -ForegroundColor Green
        }
        catch {
            Write-PSFMessage -Level Warning -Message "Failed to move configuration file to report directory: $_"
        }
    }

    # Collect data
    Export-TenantData -ExportPath $exportPath -Days $Days -MaximumSignInLogQueryTime $MaximumSignInLogQueryTime -Pillar $Pillar
    $db = Export-Database -ExportPath $exportPath -Pillar $Pillar

    # Run the tests
    Invoke-ZtTests -Database $db -Tests $Tests -Pillar $Pillar
    Invoke-ZtTenantInfo -Database $db -Pillar $Pillar

    $assessmentResults = Get-ZtAssessmentResults

    Disconnect-Database -Db $db

    $assessmentResultsJson = $assessmentResults | ConvertTo-Json -Depth 10
    $resultsJsonPath = Join-Path $exportPath "ZeroTrustAssessmentReport.json"
    $assessmentResultsJson | Out-File -FilePath $resultsJsonPath -Force

    Write-ZtProgress -Activity "Creating html report"
    $htmlReportPath = Join-Path $Path "ZeroTrustAssessmentReport.html"
    $output = Get-HtmlReport -AssessmentResults $assessmentResultsJson -Path $Path
    $output | Out-File -FilePath $htmlReportPath -Encoding UTF8

    Write-Host
    Write-Host "🛡️ Zero Trust Assessment report generated at $htmlReportPath" -ForegroundColor Green
    Show-ZtSecurityWarning -ExportPath $exportPath
    Write-Host "▶▶▶ ✨ Your feedback matters! Help us improve 👉 https://aka.ms/ztassess/feedback ◀◀◀" -ForegroundColor Yellow
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

function Show-ZtSecurityWarning {
    [CmdletBinding()]
    param (
        [string]
        $ExportPath
    )

    Write-Host
    Write-Host "⚠️ SECURITY REMINDER: The report and export folder contain sensitive tenant information." -ForegroundColor Yellow
    Write-Host "Please delete the export folder and restrict access to the report." -ForegroundColor Yellow
    Write-Host "Export folder: $ExportPath" -ForegroundColor Yellow
    Write-Host "Share the report only with authorized personnel in your organization." -ForegroundColor Yellow
    Write-Host
}
