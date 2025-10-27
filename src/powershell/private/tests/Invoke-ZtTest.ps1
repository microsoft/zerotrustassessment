function Invoke-ZtTest {
	<#
	.SYNOPSIS
		Execute individual tests and collect execution statistics.

	.DESCRIPTION
		Execute individual tests and collect execution statistics.
		This command is expected to be run from background runspaces launched by Start-ZtTestExecution.

		Use Get-ZtTestStatistics to retrieve the results of these executions.

	.PARAMETER Test
		The test object to process.
		Expects an object as returned by Get-ZtTest.

	.PARAMETER Database
		The Database used for accessing cached tenant data.

	.EXAMPLE
		PS C:\> Invoke-ZtTest -Test $_ -Database $global:database

		Executes the current test with the globally cached database connection.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Test,

		[DuckDB.NET.Data.DuckDBConnection]
		$Database
	)
	begin {
		$previousMessages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
		$result = [PSCustomObject]@{
			PSTypeName = 'ZeroTrustAssessment.TestStatistics'
			TestID     = $Test.TestID
			Test       = $Test

			# Performance Metrics, in case we want to identify problematic tests
			Start      = $null
			End        = $null
			Duration   = $null

			# What Happened?
			Success    = $true
			Error      = $null
			Messages   = $null

			# Test should have no output, but we'll catch it anyways, just in case
			Output     = $null
		}
	}
	process {
		Write-PSFMessage -Message "Processing test '{0}'" -StringValues $Test.TestID -Target $Test -Tag start

		# Check if the function exists and what parameters it has
		$command = Get-Command $Test.Command -ErrorAction SilentlyContinue
		if (-not $command) {
			Write-PSFMessage -Level Warning -Message "Test command for test '{0}' not found" -StringValues $Test.TestID -Target $Test
		}

		$dbParam = @{}
		if ($command.Parameters.ContainsKey("Database") -and $Database) {
			$dbParam.Database = $Database
		}

		try {
			# Set Current Test for "Add-ZtTestResultDetail to pick up"
			$script:__ztCurrentTest = $Test

			$result.Start = Get-Date
			$result.Output = & $command @dbParam -ErrorAction Stop
		}
		catch {
			Write-PSFMessage -Level Warning -Message "Error executing test '{0}'" -StringValues $Test.TestID -Target $Test -ErrorRecord $_
			$result.Success = $false
			$result.Error = $_
		}
		finally {
			$result.End = Get-Date
			$result.Duration = $result.End - $result.Start

			# Reset marker in an assured way, to prevent confusion about the current test being executed
			$script:__ztCurrentTest = $null
		}
		Write-PSFMessage -Message "Processing test '{0}' - Concluded" -StringValues $Test.TestID -Target $Test -Tag end
	}
	end {
		$result.Messages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId) | Where-Object { $_ -notin $previousMessages }
		Write-ZtTestStatistics -Result $result
		$result
	}
}
