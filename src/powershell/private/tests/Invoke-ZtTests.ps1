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

		[ValidateSet('All', 'Identity', 'Devices')]
		[string]
		$Pillar = 'All',

		[int]
		$ThrottleLimit = 5
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

	try {
		$workflow = Start-ZtTestExecution -Tests $testsToRun -DbPath $Database.Database -ThrottleLimit $ThrottleLimit
		Wait-ZtTest -Workflow $workflow
	}
	finally {
		if ($workflow) {
			# Disable CTRL+C to prevent impatient users from finishing the cleanup. Failing to do so may lead to a locked database, preventing a clean restart.
			Disable-PSFConsoleInterrupt
			$workflow | Stop-PSFRunspaceWorkflow
			$workflow | Remove-PSFRunspaceWorkflow
		}
		Enable-PSFConsoleInterrupt
	}
}
