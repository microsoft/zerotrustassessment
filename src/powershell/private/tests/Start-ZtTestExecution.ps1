function Start-ZtTestExecution {
	<#
	.SYNOPSIS
		Sets up and launches Test processing in multiple background runspaces in parallel.

	.DESCRIPTION
		Sets up and launches Test processing in multiple background runspaces in parallel.
		This allows accelerate calculating the Test results, though several factors may limit the performance gained by parallelizing:

		+ Disk IO: Parallel access to the disk-based database may limit performance on HDD disks.
		+ Graph Throttling: When raising the number of Runspaces, throttling Limits against the Graph API might limit performance.

	.PARAMETER Tests
		The Tests to process.

	.PARAMETER DbPath
		Path to the Database with the Cached results.

	.PARAMETER ThrottleLimit
		How many Runspaces to run in parallel to optimize tests processing.
		Defaults to: 5

	.EXAMPLE
		PS C:\> Start-ZtTestExecution -Tests $testsToRun -DbPath $Database.Database -ThrottleLimit $ThrottleLimit

		Starts parallel processing of the tests specified in $testsToRun.
	#>
	[OutputType([PSFramework.Runspace.RSWorkflow])]
	[CmdletBinding()]
	param (
		[object[]]
		$Tests,

		[string]
		$DbPath,

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
		$workflow = New-PSFRunspaceWorkflow -Name 'ZeroTrustAssessment.Tests' -Force
		$null = $workflow | Add-PSFRunspaceWorker -Name Tester @param -Begin {
			$global:database = Connect-Database -Path $databasePath -PassThru
		} -ScriptBlock {
			Invoke-ZtTest -Test $_ -Database $global:database
		} -End {
			Disconnect-Database -Database $global:database
		}
		$workflow | Write-PSFRunspaceQueue -Name Input -BulkValues @($Tests) -Close
		$workflow | Start-PSFRunspaceWorkflow
		$workflow
	}
}
