function Start-ZtTenantDataExport {
	[CmdletBinding()]
	param (
		[hashtable[]]
		$ExportConfig,

		[int]
		$ThrottleLimit = 5
	)
	begin {
		#region Calculate Resources to Import
		$variables = @{
			databasePath = $DbPath
		}

		# Explicitly including all modules required, as we later import the psm1, not the psd1 file
		$modules = (Import-PSFPowerShellDataFile "$($script:ModuleRoot)\$($PSCmdlet.MyInvocation.MyCommand.Module.Name).psd1").RequiredModules | ForEach-Object {
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
		$modules = @($modules) + "$($script:ModuleRoot)\$($PSCmdlet.MyInvocation.MyCommand.Module.Name).psm1"
		#endregion Calculate Resources to Import

		$param = @{
			InQueue       = 'Input'
			OutQueue      = 'Results'
			Count         = $ThrottleLimit
			Variables     = $variables
			CloseOutQueue = $true
			Modules       = $modules
		}
	}
	process {
		$workflow = New-PSFRunspaceWorkflow -Name 'ZeroTrustAssessment.Export' -Force
		$null = $workflow | Add-PSFRunspaceWorker -Name Exporter @param -ScriptBlock {
			Invoke-ZtTenantDataExport -Export $_
		}
		$workflow | Write-PSFRunspaceQueue -Name Input -BulkValues @($Tests) -Close
		$workflow | Start-PSFRunspaceWorkflow
		$workflow
	}
}
