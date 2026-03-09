function Export-ZtTenantData {
	<#
	.SYNOPSIS
		Exports all the required tenant information onto disk for later processing into a database.

	.DESCRIPTION
		Exports all the required tenant information onto disk for later processing into a database.
		This database will then be used for optimized test result processing, as data is cached once, rather than repeatedly requesting the same from the API.

		It also allows optimized SQL queries for data analysis that would be more expensive to process in script.

	.PARAMETER ExportPath
		The path to where all the data from Entra gets exported.

	.PARAMETER Days
		The maximum number of days signin log data is requested for.
		Larger is usually better, but may take correspondingly more time in larger tenants.

	.PARAMETER MaximumSignInLogQueryTime
		# The maximum time (in minutes) the assessment should spend on querying sign-in logs.
		Defaults to collecting sign logs for 60 minutes. Set to 0 for no limit.

	.PARAMETER Pillar
		What Zero Trust pillars to asses.
		Defaults to 'All'

	.PARAMETER ThrottleLimit
		Up to how many exports should be executed in parallel.
		A higher number may offer better performance, but also risk throttling.
		Defaults to 5.

	.EXAMPLE
		PS C:\> Export-ZtTenantData -ExportPath $exportPath -Days $Days -MaximumSignInLogQueryTime $MaximumSignInLogQueryTime -Pillar $Pillar

		Exports all the required tenant information onto disk.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PSFDirectorySingle]
		$ExportPath,

		[int]
		$Days,

		[int]
		$MaximumSignInLogQueryTime,

		[ValidateSet('All', 'Identity', 'Devices', 'Network', 'Data')]
		[string]
		$Pillar = 'All',

		[int]
		$ThrottleLimit = (Get-PSFConfigValue -FullName 'ZeroTrustAssessment.ThrottleLimit.Export' -Fallback 5)
	)

	#region Helper Functions
	function Get-ZtiAuditQueryString {
		[CmdletBinding()]
		param (
			[int]
			$PastDays
		)

		# Get the date range to query by subtracting the number of days from today set to midnight
		$statusFilter = "status/errorcode eq 0"

		$dateStart = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-$pastDays)

		# convert the date to the correct format
		$tmzFormat = "yyyy-MM-ddTHH:mm:ssZ"
		$dateStartString = $dateStart.ToString($tmzFormat)

		$dateFilter = "createdDateTime ge $dateStartString"

		"$dateFilter and $statusFilter and appid eq '89bee1f7-5e6e-4d8a-9f3d-ecd601259da7'" # 89bee1f7-5e6e-4d8a-9f3d-ecd601259da7 -> Office365 Shell WCSS-Client
	}
	#endregion Helper Functions

	$entraIDPlan = Get-ZtLicenseInformation -Product EntraID
	$graphContext = Get-MgContext
	$azureEnvironment = $graphContext.Environment
	$previousTenantID = Get-ZtConfig -ExportPath $ExportPath -Property TenantID
	if ($previousTenantID -and $previousTenantID -ne $graphContext.TenantId) {
		Stop-PSFFunction -Message "Error resuming export! Previously exported data was created for another tenant then the currently connected one! Previous: $($previousTenantID) | Current: $($graphContext.TenantId)" -EnableException $true -Cmdlet $PSCmdlet
	}
	Set-ZtConfig -ExportPath $ExportPath -Property TenantID -Value $graphContext.TenantId


	# Data that may be inserted into configured exports with placeholders
	$configVariables = [PSFramework.Object.PsfHashtable]@{
		AuditQueryString = Get-ZtiAuditQueryString -PastDays $Days
		MaximumSignInLogQueryTime = $MaximumSignInLogQueryTime
	}
	# If they key does not exist, pass through the original key, rather than return nothing
	$configVariables.SetCalculator({
		Write-PSFMessage -Level Warning -Message "Unexpected Export Variable: %$_%. This is likely a bug, please report this here: https://github.com/microsoft/zerotrustassessment/issues"
		"%$_%"
	})

	$exportConfigPath = Join-Path $script:ModuleRoot 'assets' 'export-tenant.config.psd1'
	Write-PSFMessage "Checking applicable exports for the current configuration... $exportConfigPath"
	$exportConfig = Import-PSFPowerShellDataFile -Path $exportConfigPath -Psd1Mode Safe
	$includedExports = @()
	$applicableExports = foreach ($exportCfg in $exportConfig) {
		if (-not $exportCfg.Name) {
			Write-PSFMessage -Level Error -Message @"
Invalid configuration detected! Configuration entry lacks a name: $($exportCfg)
This is very likely a configuration error in the ZeroTrustAssessment module, please report this on:
https://github.com/microsoft/zerotrustassessment/issues
"@ -Target $exportCfg -Tag config, error, fail, devfail
			continue
		}
		if ($Pillar -notcontains 'All' -and $Pillar -notcontains $exportCfg.Pillar) { continue }
		if ($exportCfg.Environment -and $exportCfg.Environment -notcontains $azureEnvironment) { continue }
		if ($exportCfg.IncludePlan -and $entraIDPlan -notin $exportCfg.IncludePlan) { continue }
		if ($exportCfg.ExcludePlan -and $entraIDPlan -in $exportCfg.IncludePlan) { continue }

		if ($exportCfg.DependsOn -and $includedExports -notcontains $exportCfg.DependsOn) {
			# Dependencies must exist, be viable and come first in the order within the config file
			Write-PSFMessage -Level Warning -Message @"
The Data Export $($exportCfg.Name) would meet requirements but depends on the Export $($exportCfg.DependsOn), which does not.
This is very likely a configuration error in the ZeroTrustAssessment module, please report this on:
https://github.com/microsoft/zerotrustassessment/issues
"@ -Target $exportCfg -Tag config, error, fail, devfail
			continue
		}
		$includedExports += $exportCfg.Name

		# Insert dynamic data as prepared above
		if ($exportCfg.Uri -like "%*%") { $exportCfg.Uri = $configVariables[$exportCfg.Uri.Trim("%")] }
		if ($exportCfg.QueryString -like "%*%") { $exportCfg.QueryString = $configVariables[$exportCfg.QueryString.Trim("%")] }
		if ($exportCfg.MaximumQueryTime -like "%*%") { $exportCfg.MaximumQueryTime = $configVariables[$exportCfg.MaximumQueryTime.Trim("%")] }

		$exportCfg
	}

	if (-not $applicableExports -or $applicableExports.Count -eq 0) {
		Write-PSFMessage "No applicable exports found for the current configuration. Nothing to export."
		return
	}

	try {
		Write-PSFMessage "Starting Tenant Data Export to path: $ExportPath"
		# Show $applicableExports
		Write-PSFMessage "Applicable exports: $($applicableExports | ForEach-Object { $_.Name } | Sort-Object | Out-String)"

		$workflow = Start-ZtTenantDataExport -ExportConfig $applicableExports -ThrottleLimit $ThrottleLimit -ExportPath $ExportPath
		Wait-ZtTenantDataExport -Workflow $workflow
	}
	finally {
		if ($workflow) {
			Disable-PSFConsoleInterrupt
			$workflow | Stop-PSFRunspaceWorkflow

			# Collect statistical data for later troubleshooting. Retrieve via Get-ZtExportStatistics
			$script:__ZtSession.ExportStatistics = @{}
			foreach ($result in $workflow.Queues.Results) {
				$script:__ZtSession.ExportStatistics[$result.Name] = $result
			}

			$workflow | Remove-PSFRunspaceWorkflow
		}

		Enable-PSFConsoleInterrupt
	}
}
