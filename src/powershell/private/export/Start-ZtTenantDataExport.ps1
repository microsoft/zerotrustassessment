function Start-ZtTenantDataExport {
	<#
	.SYNOPSIS
		Prepares everything for the parallelized export of data from Entra.

	.DESCRIPTION
		Prepares everything for the parallelized export of data from Entra.
		This includes setting up the PSFramework runspace workflow, including all the metadata to pass in:

		+ List of modules to import (ideally the exact versions we have loaded in the main runspace)
		+ Where to export data to

		It also prepares the metadata used for progress reporting.

	.PARAMETER ExportConfig
		The configuration entries directing the system what to export.
		This should be processed and validated config entries previously imported and refined in Export-ZtTenantData.

	.PARAMETER ExportPath
		The path where all the data gets exported (into subfolders each).

	.PARAMETER ThrottleLimit
		Up to how many runspaces should act in parallel.
		Too many will risk getting throttled, but a few should be fine.

	.EXAMPLE
		PS C:\> Start-ZtTenantDataExport -ExportConfig $exportCFGs -ExportPath $ExportPath

		Starts the export processing of all the provided export configuration sets.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[hashtable[]]
		$ExportConfig,

		[Parameter(Mandatory = $true)]
		[string]
		$ExportPath,

		[int]
		$ThrottleLimit = 5
	)
	begin {
		#region Calculate Resources to Import
		$variables = @{
			exportPath        = $ExportPath
			dependencyTimeout = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Export.DependencyWaitLimit'
			moduleRoot        = $script:ModuleRoot
		}

		# Explicitly including all modules required, as we later import the psm1, not the psd1 file
		$modulePsd1Path = Join-Path $script:ModuleRoot "$($PSCmdlet.MyInvocation.MyCommand.Module.Name).psd1"
		$modules = (Import-PSFPowerShellDataFile $modulePsd1Path).RequiredModules | ForEach-Object {
			if ($_ -is [string]) {
				$name = $_
			}
			else {
				$name = $_.ModuleName
			}
			if (-not $name) {
				return
			}
			# Prefer loading the exact same version currently loaded, rather than just by name, in order to respect explicit import choice by the user
			if ($module = Get-Module $name) {
				$module.ModuleBase
			}
			else {
				$name
			}
		}
		# Loading the PSM1 to make internal commands directly accessible
		$modulePsm1Path = Join-Path $script:ModuleRoot "$($PSCmdlet.MyInvocation.MyCommand.Module.Name).psm1"
		$modules = @($modules) + $modulePsm1Path
		#endregion Calculate Resources to Import

		$param = @{
			InQueue       = 'Input'
			OutQueue      = 'Results'
			Count         = $ThrottleLimit
			Variables     = $variables
			CloseOutQueue = $true
			Modules       = $modules
			KillToStop    = $true # Otherwise, longrunning exports will try to keep running
		}
	}
	process {
		Write-PSFMessage "Starting Tenant Data Export Workflow with ThrottleLimit: $ThrottleLimit"
		$workflow = New-PSFRunspaceWorkflow -Name 'ZeroTrustAssessment.Export' -Force
		$null = $workflow | Add-PSFRunspaceWorker -Name Exporter @param -Begin {
			$script:ModuleRoot = $moduleRoot
		} -ScriptBlock {
			Invoke-ZtTenantDataExport -Export $_ -DependencyTimeout $dependencyTimeout -ExportPath $exportPath
		}
		$workflow | Write-PSFRunspaceQueue -Name Input -BulkValues @($ExportConfig) -Close
		foreach ($export in $ExportConfig) {
			$workflow.Data[$export.Name] = [PSCustomObject]@{
				Status  = 'Pending'
				Name    = $export.Name
				Updated = Get-Date
				Message = ''
			}
		}
		$workflow | Start-PSFRunspaceWorkflow
		$workflow
	}
}
