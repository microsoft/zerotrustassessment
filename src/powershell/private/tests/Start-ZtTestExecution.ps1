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

	.PARAMETER TestTimeout
		Maximum time a single test is allowed to run.
		Passed through to Invoke-ZtTest for per-test timeout enforcement.

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
		$ThrottleLimit = 5,

		[string]
		$LogsPath,

		[timespan]
		$TestTimeout = [timespan]::Zero
	)
	begin {
		#region Calculate Resources to Import
		$variables = @{
			databasePath = $DbPath
			moduleRoot   = $script:ModuleRoot
			logsPath     = $LogsPath
		}
		# Explicitly including all modules required, as we later import the psm1, not the psd1 file
		#TODO: This is brittle
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

		# Get the modules loaded from the connected service
		# Add those modules in the runspace initialization to make the service cmdlets available
		# this should allow all tests to be run in parallel.

		#endregion Calculate Resources to Import

		#region Code
		$begin = {
			$script:ModuleRoot = $moduleRoot
			$global:database = Connect-Database -Path $databasePath -PassThru
			$global:msgSoFar = @{}
		}
		$process = {
			if (-not $global:msgSoFar[$_.TestID]) {
				$global:msgSoFar.Clear()
				$global:msgSoFar[$_.TestID] = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
			}
			Invoke-ZtTestParallel -Test $_ -Database $global:database -LogsPath $logsPath -PreviousMessages $global:msgSoFar[$_.TestID]
		}
		$end = {
			Disconnect-Database -Database $global:database
		}
		$condition = {
			$result = Get-ZtTestResult -Test $this

			# Check whether we should retry
			$retryCount = $__PSF_Worker.RetryCount
			if ($__PSF_Agent.CurrentItem.RetryCount) { $retryCount = $__PSF_Agent.CurrentItem.RetryCount }
			$retryTimeout = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Tests.RetryTimeout'
			if (
				$result.Attempts -lt $retryCount -and
				(
					$retryTimeout -or
					$_ -notmatch 'Workitem timed out'
				)
			) { return $true }

			$result.TimedOut = $_ -match 'Workitem timed out'

			# Let's fail this
			$result.End = Get-Date
			$result.Duration = $result.End - $result.Start

			Write-ZtTestError -Test $this -Result $result -ErrorRecord $_
			Write-PSFMessage -Message "Processing test '{0}' - Concluded" -StringValues $this.TestID -Target $this -Tag end
			Write-ZtTestFinish -Result $result -PreviousMessages $global:msgSoFar[$_.TestID] -Test $this -LogsPath $logsPath
		}
		#endregion Code

		$param = @{
			InQueue        = 'Input'
			OutQueue       = 'Results'
			Count          = $ThrottleLimit
			Variables      = $variables
			CloseOutQueue  = $true
			Modules        = $modules
			KillToStop     = $true
			RetryCount     = 1 + (Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Tests.RetryCount')
			RetryCondition = $condition
		}
		if ($TestTimeout.TotalSeconds -gt 0) {
			$param.Timeout = $TestTimeout
			$param.TimeoutType = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Tests.TimeoutType'
			$typeNames = [enum]::GetNames([PSFramework.Runspace.RSTimeout]) -notmatch '^None$|^Undefined$'
			if ($param.TimeoutType -notin $typeNames) {
				Write-PSFMessage -Level Warning -Message "Invalid Test-Timeout Type configured: {0}. Available types: {1}. Defaulting to 'Idle'" -StringValues $param.TimeoutType, ($typeNames -join ', ')
				$param.TimeoutType = 'Idle'
			}
		}
	}

	process {
		$workflow = New-PSFRunspaceWorkflow -Name 'ZeroTrustAssessment.Tests' -Force
		$null = $workflow | Add-PSFRunspaceWorker -Name Tester @param -Begin $begin -ScriptBlock $process -End $end
		$workflow | Write-PSFRunspaceQueue -Name Input -BulkValues @($Tests) -Close
		$workflow | Start-PSFRunspaceWorkflow
		$workflow
	}
}
