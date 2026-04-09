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
If specified, the assessment reuses the previously exported data and existing database,
skipping data export and database rebuild.

.PARAMETER ShowLog
If specified, the script will output a high level summary of log messages. Useful for debugging. Use -Verbose and -Debug for more detailed logs.

.PARAMETER ExportLog
If specified, writes the log to a file.

.PARAMETER NoBrowser
If specified, suppresses automatic browser opening for both the progress dashboard and the final HTML report.
The progress dashboard server will not be started and the report will not be opened in the browser at the end.

.PARAMETER DisableTelemetry
If specified, disables the collection of telemetry. The only telemetry collected is the tenant id. Defaults to false.

.PARAMETER Tests
The IDs of the specific test(s) to run. If not specified, all tests will be run.

.PARAMETER ConfigurationFile
Path to a configuration file. Parameters specified on the command line will override values from the configuration file.

.PARAMETER ExportThrottleLimit
Maximum number of data collectors processed in parallel.
Raising this number may improve performance, but risk hitting throttling limits.

.PARAMETER TestThrottleLimit
Maximum number of tests processed in parallel.
Raising this number may improve performance, but risk hitting throttling limits.

.PARAMETER Timeout
	The maximum time to wait for all tests to complete before giving up and writing a warning message.
	Defaults to: 24 hours. Adjust this value if you have a large number of tests or expect some tests to take a long time.

.PARAMETER TestTimeout
Maximum time in minutes a single test is allowed to run before it is stopped.
Defaults to 60 minutes. Set to 0 to disable the timeout.
Tests that exceed this limit are recorded as timed out and execution continues with the next test.
For Data pillar tests and other external-module/remoting-heavy operations, timeout is a
best-effort interruption rather than a guaranteed hard stop of the underlying operation.

.PARAMETER IgnoreLanguageMode
When specified, bypasses the Constrained Language Mode safety check and allows the assessment to
proceed even when PowerShell reports a non-Full language mode (e.g. in WDAC-managed environments
where the module's signing certificate is trusted by policy).
WARNING: Some tests may fail or return incomplete results if CLM restrictions are truly in effect.

.EXAMPLE
Invoke-ZtAssessment

Run the Zero Trust Assessment against the signed in tenant and generates a report of the findings using default settings.

.EXAMPLE
Invoke-ZtAssessment -Path "C:\Reports\ZT" -Days 7 -ShowLog

Run the Zero Trust Assessment with a custom output path, querying 7 days of logs, and showing detailed logging.

.PARAMETER Pillar
The Zero Trust pillar to assess. Valid values are 'All', 'Identity', 'Devices', 'Network', or 'Data'. Defaults to 'All' which runs all tests.

.EXAMPLE
Invoke-ZtAssessment -ConfigurationFile "C:\Config\zt-config.json"

Run the Zero Trust Assessment using settings from a configuration file.

.EXAMPLE
Invoke-ZtAssessment -ConfigurationFile "C:\Config\zt-config.json" -Days 14 -ShowLog

Run the Zero Trust Assessment using settings from a configuration file, but override the Days parameter to 14 and enable ShowLog.

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
				}
				else {
					throw "Configuration file '$_' does not exist."
				}
			})]
		[string]
		$ConfigurationFile,

		[PsfArgumentCompleter('ZeroTrustAssessment.Tests.Pillar')]
		# The Zero Trust pillar to assess. Defaults to All.
		[ValidateSet('All', 'Identity', 'Devices', 'Network', 'Data', 'Infrastructure', 'SecOps', 'AI')]
		[string]
		$Pillar = 'All',

		# Enable preview features
		[Parameter(ParameterSetName = 'Default')]
		[switch]
		$Preview,

		[int]
		$ExportThrottleLimit = (Get-PSFConfigValue -FullName 'ZeroTrustAssessment.ThrottleLimit.Export' -Fallback 5),

		[int]
		$TestThrottleLimit = (Get-PSFConfigValue -FullName 'ZeroTrustAssessment.ThrottleLimit.Tests' -Fallback 5),

		[TimeSpan]
		$Timeout = '1.00:00:00',

		# Maximum time in minutes a single test is allowed to run. Defaults to 60 minutes. Set to 0 to disable.
		# For Data pillar tests, timeout is best-effort because some external modules/remoting
		# operations cannot be deterministically hard-stopped from within the current process.
		[int]
		$TestTimeout = [math]::Floor((Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Tests.Timeout' -Fallback ([timespan]::FromMinutes(60))).TotalMinutes),

		# If specified, suppresses automatic browser opening for both the progress dashboard and the final HTML report.
		[Parameter(ParameterSetName = 'Default')]
		[switch]
		$NoBrowser,

		# When specified, bypasses the Constrained Language Mode check. Use only in WDAC-managed environments
		# where the session reports CLM but the module is trusted and runs with full capability.
		[Parameter(ParameterSetName = 'Default')]
		[switch]
		$IgnoreLanguageMode
	)

	if ($script:ConnectedService.Count -le 0) {
		Connect-ZtAssessment -IgnoreLanguageMode:$IgnoreLanguageMode
	}

	#region Utility Functions
	function Show-ZtiSecurityWarning {
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

	function Show-ZtiBanner {
		[CmdletBinding()]
		param ()

		$version = $script:__ZtSession.ModuleVersion
		$title = "🛡️  Microsoft Zero Trust Assessment v$version"
		# Center the title within the 77-character inner box width.
		# The shield emoji displays as 2 cells but has .Length of 3, so subtract 1.
		$displayLen = $title.Length - 1
		$totalPad = 77 - $displayLen
		$leftPad = [math]::Ceiling($totalPad / 2)
		$rightPad = $totalPad - $leftPad
		$titleLine = "║$(' ' * $leftPad)$title$(' ' * $rightPad)║"

		$banner = @"
╔═════════════════════════════════════════════════════════════════════════════╗
$titleLine
║                                                                             ║
║    Comprehensive security posture evaluation for your Microsoft 365 tenant  ║
╚═════════════════════════════════════════════════════════════════════════════╝
"@

		Write-Host $banner -ForegroundColor Cyan
		Write-Host
		Write-Host "🚀 " -NoNewline -ForegroundColor Green
		Write-Host "Starting Zero Trust Assessment..." -ForegroundColor White
		Write-Host
	}
	#endregion Utility Functions

	#region Preparation
	Show-ZtiBanner

	$effectiveIgnore = $IgnoreLanguageMode -or $script:IgnoreLanguageMode
	if (-not (Test-ZtLanguageMode -IgnoreLanguageMode:$effectiveIgnore)) {
		Stop-PSFFunction -Message "PowerShell is running in Constrained Language Mode, which is not supported." -EnableException $true -Cmdlet $PSCmdlet
		return
	}

	# TODO: Cleanup below (aligning -Preview with all pillars)
	# Validate preview pillar requirements
	# if ($Pillar -in ('Network', 'Data') -and -not $Preview) {
	# 	Write-Host
	# 	Write-Host "❌ " -NoNewline -ForegroundColor Red
	# 	Write-Host "The '$Pillar' pillar is currently in preview and requires the " -NoNewline -ForegroundColor Red
	# 	Write-Host "-Preview" -NoNewline -ForegroundColor Yellow
	# 	Write-Host " switch." -ForegroundColor Red
	# 	Write-Host
	# 	Write-Host "Please run the command again with the " -NoNewline -ForegroundColor White
	# 	Write-Host "-Preview" -NoNewline -ForegroundColor Yellow
	# 	Write-Host " parameter to assess the $Pillar pillar." -ForegroundColor White
	# 	Write-Host
	# 	return
	# }

	# Handle configuration file parameter
	if ($ConfigurationFile) {
		try {
			Write-Host "📄 " -NoNewline -ForegroundColor Blue
			Write-Host "Loading configuration from file: " -NoNewline -ForegroundColor White
			Write-Host $ConfigurationFile -ForegroundColor Cyan
			$configContent = Get-Content -Path $ConfigurationFile -Raw | ConvertFrom-Json

			# Define parameters that can be configured
			$configurableParameters = @('Path', 'Days', 'MaximumSignInLogQueryTime', 'ShowLog', 'ExportLog', 'DisableTelemetry', 'Resume', 'Tests', 'TestTimeout')

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
				}
				else {
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

	# # Handle interactive parameter collection
	# if ($Interactive) {
	# 	try {
	# 		Write-Host "🎮 " -NoNewline -ForegroundColor Magenta
	# 		Write-Host "Starting interactive parameter collection..." -ForegroundColor White
	# 		Write-Host
	# 		$tempConfigFile = New-ZtInteractiveConfig

	# 		# Check if user cancelled the configuration creation
	# 		if ($null -eq $tempConfigFile -or -not $tempConfigFile) {
	# 			Write-Host "⏹️ " -NoNewline -ForegroundColor Yellow
	# 			Write-Host "Interactive configuration cancelled by user. Exiting." -ForegroundColor Yellow
	# 			return
	# 		}

	# 		# Verify the file exists before trying to read it (only if tempConfigFile is not null)
	# 		if (-not (Test-Path $tempConfigFile.FullName -ErrorAction SilentlyContinue)) {
	# 			Write-Host "❌ " -NoNewline -ForegroundColor Red
	# 			Write-Host "Configuration file was not created. Exiting." -ForegroundColor Red
	# 			return
	# 		}

	# 		# Import the configuration data from JSON
	# 		$config = Import-PSFJson -Path $tempConfigFile.FullName

	# 		# Assign interactive parameter values to variables
	# 		$Path = $config.Path
	# 		$Days = $config.Days
	# 		$MaximumSignInLogQueryTime = $config.MaximumSignInLogQueryTime
	# 		$ShowLog = $config.ShowLog
	# 		$ExportLog = $config.ExportLog
	# 		$DisableTelemetry = $config.DisableTelemetry
	# 		$Resume = $config.Resume

	# 		if ($config.PSObject.Properties.Name -contains 'Tests' -and $config.Tests.Count -gt 0) {
	# 			$Tests = $config.Tests
	# 		}

	# 		Write-Host "✅ " -NoNewline -ForegroundColor Green
	# 		Write-Host "Interactive configuration complete. Starting assessment..." -ForegroundColor Green
	# 		Write-Host
	# 	}
	# 	catch {
	# 		Write-Host "❌ " -NoNewline -ForegroundColor Red
	# 		Write-Host "Failed to collect interactive parameters: $($_.Exception.Message)" -ForegroundColor Red
	# 		return
	# 	}
	# }

	#$ExportLog = $true # Always create support package during public preview TODO: Remove this line after public preview

	if ($ShowLog) {
		$null = New-PSFMessageLevelModifier -Name ZeroTrustAssessment.VeryVerbose -Modifier -1 -IncludeModuleName ZeroTrustAssessment
	}
	else {
		Get-PSFMessageLevelModifier -Name ZeroTrustAssessment.VeryVerbose | Remove-PSFMessageLevelModifier
	}

	if (-not (Test-DatabaseAssembly)) {
		return
	}

	if (-not (Test-ZtContext)) {
		return
	}

	# Resolve to absolute paths so .NET APIs (DuckDB, System.IO) use the correct location.
	# .NET resolves relative paths against [Environment]::CurrentDirectory, which can differ
	# from PowerShell's Get-Location after Set-Location / cd.
	$Path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
	$exportPath = Join-Path $Path "zt-export"
	$dbPath = Join-Path $exportPath 'db' 'zt.db'

	# Stop if folder has items inside it
	if (-not $Resume -and (Test-Path $Path)) {
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
				Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop -ProgressAction SilentlyContinue | Out-Null
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

	# Create a timestamped run folder under logs/ so each assessment run is isolated.
	# Use .FullName to get the absolute path because .NET file APIs ([System.IO.File]::WriteAllText etc.)
	# resolve relative paths against [Environment]::CurrentDirectory (process CWD), which
	# differs from PowerShell's Get-Location after Set-Location / cd.
	$runFolder = (Get-Date).ToString('yy-MM-dd-HHmmss')
	$logsPath = (New-Item -ItemType Directory -Path (Join-Path $exportPath "logs/$runFolder") -Force -ErrorAction Stop).FullName
	$null = New-Item -ItemType Directory -Path (Join-Path $logsPath '1-Export') -Force -ErrorAction Stop
	$null = New-Item -ItemType Directory -Path (Join-Path $logsPath '2-Tests') -Force -ErrorAction Stop


	# Send telemetry if not disabled
	if (-not $DisableTelemetry) {
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
	$script:__ZtSession.PreviewEnabled = $Preview.IsPresent

	Write-PSFMessage 'Creating report folder $Path'
	$null = New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop

	# Start the progress dashboard web server (interactive mode only)
	$isInteractive = [Environment]::UserInteractive -and ($Host.Name -ne 'Default Host')
	if ($isInteractive -and -not $NoBrowser) {
		try {
			Start-ZtProgressServer
		}
		catch {
			Write-PSFMessage -Level Warning -Message "Failed to start progress dashboard: $_"
		}
	}

	try {
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
	#endregion Preparation

	# Collect data
	if ($Resume) {
		# Guard: verify the requested pillar is compatible with the exported data
		$exportedPillar = Get-ZtConfig -ExportPath $ExportPath -Property Pillar
		if ($exportedPillar -and $exportedPillar -ne $Pillar) {
			if ($Pillar -eq 'All' -and $exportedPillar -ne 'All') {
				throw "Resume requested with -Pillar All, but the existing export only contains '$exportedPillar' data. Run without -Resume to export all pillars."
			}
			if ($exportedPillar -ne 'All' -and $Pillar -ne $exportedPillar) {
				throw "Resume requested with -Pillar $Pillar, but the existing export was created with -Pillar $exportedPillar. Run without -Resume or use -Pillar $exportedPillar."
			}
		}
	}

	Write-PSFMessage -Message "Stage 1: Exporting Tenant Data" -Tag stage
	Update-ZtProgressState -Stage 'export' -StageNumber 1 -StageName 'Exporting Tenant Data'
	Export-ZtTenantData -ExportPath $exportPath -Days $Days -MaximumSignInLogQueryTime $MaximumSignInLogQueryTime -Pillar $Pillar -ThrottleLimit $ExportThrottleLimit -LogsPath $logsPath

	Update-ZtProgressState -Stage 'database' -StageNumber 1 -StageName 'Importing Data into Database' -ClearWorkers
	$database = Export-Database -ExportPath $exportPath -Pillar $Pillar -LogsPath $logsPath

	try {
		# Run the tests
		Write-PSFMessage -Message "Stage 2: Running Tests" -Tag stage
		Update-ZtProgressState -Stage 'tests' -StageNumber 2 -StageName 'Running Tests' -ClearWorkers -TotalItems 0 -CompletedItems 0 -FailedItems 0 -InProgressItems 0
		Invoke-ZtTests -Database $database -Tests $Tests -Pillar $Pillar -ThrottleLimit $TestThrottleLimit -LogsPath $logsPath -Timeout $Timeout -TestTimeout $TestTimeout

		Write-PSFMessage -Message "Stage 3: Adding Tenant Information" -Tag stage
		Update-ZtProgressState -Stage 'tenantinfo' -StageNumber 3 -StageName 'Adding Tenant Information' -ClearWorkers -TotalItems 0
		Invoke-ZtTenantInfo -Database $database -Pillar $Pillar

		Write-PSFMessage -Message "Stage 4: Generating Test-Results" -Tag stage
		Update-ZtProgressState -Stage 'results' -StageNumber 4 -StageName 'Generating Test Results' -ClearWorkers -TotalItems 0
		$assessmentResults = Get-ZtAssessmentResults
	}
	finally {
		if ($database) {
			Disconnect-Database -Database $database
		}
	}

	Write-PSFMessage -Message "Stage 5: Writing Assessment report data" -Tag stage
	Update-ZtProgressState -Stage 'json' -StageNumber 5 -StageName 'Writing Assessment Report Data' -ClearWorkers -TotalItems 0
	$assessmentResultsJson = $assessmentResults | ConvertTo-Json -Depth 10
	$resultsJsonPath = Join-Path -Path $exportPath -ChildPath "ZeroTrustAssessmentReport.json"
	$assessmentResultsJson | Set-PSFFileContent -Path $resultsJsonPath

	Write-PSFMessage -Message "Stage 6: Generating Html Report" -Tag stage
	Update-ZtProgressState -Stage 'html' -StageNumber 6 -StageName 'Generating HTML Report' -ClearWorkers -TotalItems 0
	Write-ZtProgress -Activity "Creating html report"
	$htmlReportPath = Join-Path -Path $Path -ChildPath "ZeroTrustAssessmentReport.html"
	$output = Get-HtmlReport -AssessmentResults $assessmentResultsJson -Path $Path
	$output | Set-PSFFileContent -Path $htmlReportPath -Encoding UTF8NoBom

	# Signal completion to the progress dashboard
	Update-ZtProgressState -Stage 'done' -StageNumber 6 -StageName 'Assessment Complete' -ClearWorkers -TotalItems 0

	#region Post Processing
	Write-Host
	Write-Host "🛡️ Zero Trust Assessment report generated at $htmlReportPath" -ForegroundColor Green
	Show-ZtiSecurityWarning -ExportPath $exportPath
	Write-Host "▶▶▶ ✨ Your feedback matters! Help us improve 👉 https://aka.ms/ztassess/feedback ◀◀◀" -ForegroundColor Yellow
	Write-Host
	Write-Host
	if (-not $NoBrowser) {
		Invoke-Item $htmlReportPath | Out-Null
	}

	if ($ExportLog) {
		Write-ZtProgress -Activity "Creating support package"
		$logPath = Join-Path $Path "log"
		if (-not (Test-Path $logPath)) {
			$null = New-Item -ItemType Directory -Path $logPath -Force -ErrorAction Stop
		}
		New-PSFSupportPackage -Path $logPath
	}

	# Give the progress dashboard a moment to show the completion state before shutting down
	Start-Sleep -Seconds 2
	#endregion Post Processing
	}
	finally {
		Stop-ZtProgressServer
	}
}
