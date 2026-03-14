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

	.PARAMETER LogsPath
		Optional path to output logs for each test. If not specified, logs will not be written
		to disk but will still be available in the database.

	.PARAMETER Timeout
		The maximum time to wait for all tests to complete before giving up and writing a warning message.
		Defaults to: 24 hours. Adjust this value if you have a large number of tests or expect some tests to take a long time.

	.PARAMETER ConnectedService
		The services that are connected and can be used for testing.
		This is used to skip tests that require a service connection when the service is not connected.
		If not specified, it will use the value from $script:ConnectedService, which is set based on the
		connected services populated by Connect-ZtAssessment.

	.PARAMETER TestTimeout
		Maximum time in minutes a single test is allowed to run.
		Defaults to: 60. Set to 0 to disable.
		For Data pillar tests and external-module/remoting-heavy operations,
		this is a best-effort interruption rather than a guaranteed hard stop.

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
		$ConnectedService = $script:ConnectedService,

		[TimeSpan]
		$Timeout = '1.00:00:00',

		[int]
		$TestTimeout = 60
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
		$stablePillars = @('Identity', 'Devices', 'Network', 'Data')
		$testsToRun = $testsToRun.Where{ $_.Pillar -in $stablePillars }
	}

	# Filter based on service connection. If no service is specified in the test metadata, it will be run.
	$skippedTestsForService = $testsToRun.Where{ $_.Service.count -gt 0 -and $_.Service.Count -notin $_.Service.Where{ $_ -in $ConnectedService}.count }
	$skippedTestsForService.ForEach{
		$notConnectedService = ($_).Service.Where{ $_ -notin $ConnectedService }
		# Mark the test as skipped.
		Write-ZtTestProgress -TestID $_.TestId -LogsPath $LogsPath -Action 'Skipped' -ErrorMessage "Required service(s) not connected: $($notConnectedService -join ', ')"
		Add-ZtTestResultDetail -SkippedBecause NotConnectedToService -TestId $_.TestId -NotConnectedService $notConnectedService
	}

	$testsToRun = $testsToRun.Where{ $_.TestId -notin $skippedTestsForService.TestId }

	# Filter based on Compatible licenses
	$skippedTestsForLicense = $testsToRun.Where{$_.CompatibleLicense.Count -gt 0 -and (-not (Test-ZtLicense -CompatibleLicense $_.CompatibleLicense)) }
	$skippedTestsForLicense.ForEach{
		Write-PSFMessage -Message ('Test {0} is skipped because no compatible license was found' -f $_.TestId) -Level Verbose
		Add-ZtTestResultDetail -SkippedBecause NoCompatibleLicenseFound -TestId $_.TestId
		Write-ZtTestProgress -TestID $_.TestId -LogsPath $LogsPath -Action 'Skipped' -ErrorMessage "No compatible license found. Required: $($_.CompatibleLicense -join ', ')"
	}

	$testsToRun = $testsToRun.Where{ $_.TestId -notin $skippedTestsForLicense.TestId }

	# Separate Sync Tests (Compliance/ExchangeOnline/SharePointOnline) from Parallel Tests (because of DLL order to manage in runspaces & remoting into WPS)
	[int[]]$syncTestIds   = $testsToRun.Where{ $_.Pillar -eq 'Data'}.TestId
	$syncTests     = $testsToRun.Where{ $_.TestId -in $syncTestIds }
	$parallelTests = $testsToRun.Where{ $_.TestId -notin $syncTestIds }

	[dateTime] $startTime = [datetime]::Now
	$workflow = $null
	try {
		# Convert timeout minutes to timespan (0 = disabled)
		$timeoutSpan = if ($TestTimeout -gt 0) { [timespan]::FromMinutes($TestTimeout) } else { [timespan]::Zero }

		# Run Sync Tests in the main thread
		foreach ($test in $syncTests) {
			$null = Invoke-ZtTest -Test $test -Database $Database -LogsPath $LogsPath -TestTimeout $timeoutSpan
		}

		# Then run Parallel Tests
		if ($parallelTests) {
			$workflow = Start-ZtTestExecution -Tests $parallelTests -DbPath $Database.Database -ThrottleLimit $ThrottleLimit -LogsPath $LogsPath -TestTimeout $timeoutSpan
			Wait-ZtTest -Workflow $workflow -StartedAt $startTime -Timeout $Timeout
			$workflow.Queues['Input'].ForEach{
				Write-PSFMessage -Level Debug -Message "Test $_ was not processed before timeout was reached."
				Add-ZtTestResultDetail -SkippedBecause TimeoutReached -TestId $_
			}
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
