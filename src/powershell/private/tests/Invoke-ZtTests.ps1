function Invoke-ZtTests {
	<#
	.SYNOPSIS
		Runs all the Zero Trust Assessment tests.

	.DESCRIPTION
		Runs all the Zero Trust Assessment tests.

	.PARAMETER Database
		The Database object where the cached tenant data is stored

	.PARAMETER Tests
		The IDs of the specific test(s) to run. If not specified, all tests will be run.

	.PARAMETER Pillar
		The Zero Trust pillar to assess.
		Defaults to: All.

	.PARAMETER ThrottleLimit
		Maximum number of tests processed in parallel.
		Defaults to: 5

	.EXAMPLE
		PS C:\> Invoke-ZtTests -Database $database -Tests $Tests -Pillar $Pillar -ThrottleLimit $TestThrottleLimit

		Executes all tests specified.
	#>
	[CmdletBinding()]
	param (
		[DuckDB.NET.Data.DuckDBConnection]
		$Database,

		[string[]]
		$Tests,

		[ValidateSet('All', 'Identity', 'Devices', 'Network', 'Data')]
		[string]
		$Pillar = 'All',

		[int]
		$ThrottleLimit = 5,

		[string]
		$LogsPath,

		[Parameter(DontShow)]
		[ValidateSet('Graph', 'Azure', 'AipService', 'ExchangeOnline', 'SecurityCompliance', 'SharePointOnline')]
		[string[]]
		$Service = $script:ConnectedService
	)

	# Get Tenant Type (AAD = Workforce, CIAM = EEID)
	$org = Invoke-ZtGraphRequest -RelativeUri 'organization'
	$tenantType = $org.TenantType
	Write-PSFMessage "$tenantType tenant detected. This will determine the tests that are run."

	# Map input parameters to config file values
	$tenantTypeMapping = @{
		"AAD"  = "Workforce"
		"CIAM" = "External"
	}

	$testsToRun = Get-ZtTest -Tests $Tests -Pillar $Pillar -TenantType $tenantTypeMapping[$TenantType]

	# Filter based on preview feature flag
	if (-not $script:__ZtSession.PreviewEnabled) {
		# Non-preview mode: Only include stable/released pillars
		$stablePillars = @('Identity', 'Devices','Devices', 'Network', 'Data')
		$testsToRun = $testsToRun.Where{ $_.Pillar -in $stablePillars }
	}

	# Filter based on service connection.
	$skippedTestsForService = $testsToRun.Where{ $_.Service.count -gt 0 -and $_.Service -notin $Service }
	$testsToRun = $testsToRun.Where{ $_.Service.count -eq 0 -or $_.Service -in $Service }

	# Separate Sync Tests (Compliance/ExchangeOnline/SharePointOnline) from Parallel Tests (because of DLL order to manage in runspaces & remoting into WPS)
	[int[]]$syncTestIds   = $testsToRun.Where{ $_.Pillar -eq 'Data'}.TestId #@($testsToRun | Where-Object { $_.Pillar -eq 'Data' } | Select-Object -ExpandProperty TestId)
	$syncTests     = $testsToRun.Where{ $_.TestId -in $syncTestIds }
	$parallelTests = $testsToRun.Where{ $_.TestId -notin $syncTestIds }

	#TODO: Remove tests that depend service connection not available

	$workflow = $null
	try {
		# Run Sync Tests in the main thread
		foreach ($test in $syncTests) {
			$null = Invoke-ZtTest -Test $test -Database $Database -LogsPath $LogsPath
		}

		# Then run Parallel Tests
		if ($parallelTests) {
			$workflow = Start-ZtTestExecution -Tests $parallelTests -DbPath $Database.Database -ThrottleLimit $ThrottleLimit -LogsPath $LogsPath
			Wait-ZtTest -Workflow $workflow
		}
	}
	finally {
		if ($workflow) {
			# Disable CTRL+C to prevent impatient users from finishing the cleanup. Failing to do so may lead to a locked database, preventing a clean restart.
			Disable-PSFConsoleInterrupt
			$workflow | Stop-PSFRunspaceWorkflow
			$workflow | Remove-PSFRunspaceWorkflow
			Enable-PSFConsoleInterrupt
		}
	}
}
