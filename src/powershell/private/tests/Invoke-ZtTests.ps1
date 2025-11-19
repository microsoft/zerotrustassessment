<#
.SYNOPSIS
    Runs all the Zero Trust Assessment tests.
#>

function Invoke-ZtTests {
	[CmdletBinding()]
	param (
		$Database,

		# The IDs of the specific test(s) to run. If not specified, all tests will be run.
		[string[]]
		$Tests,

		# The Zero Trust pillar to assess. Defaults to All.
		[ValidateSet('All', 'Identity', 'Devices')]
		[string]
		$Pillar = 'All'
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

	foreach ($test in $testsToRun) {
		# Check if the function exists and what parameters it has
		$command = Get-Command $test.Command -ErrorAction SilentlyContinue
		if (-not $command) {
			Write-PSFMessage -Level Warning -Message "Test command for test '{0}' not found" -StringValues $test.TestID -Target $test
		}

		$dbParam = @{}
		if ($command.Parameters.ContainsKey("Database") -and $Database) {
			$dbParam.Database = $Database
		}

		try {
			# Set Current Test for "Add-ZtTestResultDetail to pick up"
			$script:__ztCurrentTest = $test
			& $command @dbParam
		}
		catch {
			Write-PSFMessage -Level Warning -Message "Error executing test '{0}'" -StringValues $test.TestID -Target $test -ErrorRecord $_
		}
		finally {
			# Reset marker in an assured way, to prevent confusion about the current test being executed
			$script:__ztCurrentTest = $null
		}
	}
}
