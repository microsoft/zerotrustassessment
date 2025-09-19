function Get-ZtTest {
	<#
	.SYNOPSIS
		Lists the available tests.

	.DESCRIPTION
		Lists the available tests.

	.PARAMETER Tests
		The IDs of the test to return.
		Must be exact matches, no wildcards.

	.PARAMETER Pillar
		The Pillar(s) to which the tests belong.

	.PARAMETER TenantType
		The type of tenant the tests apply to.

	.PARAMETER Current
		The test currently being processed.
		Internal use only.

	.EXAMPLE
		PS C:\> Get-ZtTest

		Lists all available tests.

	.EXAMPLE
		PS C:\> Get-ZtTest -Id 21770, 21771

		Returns the test data for tests 21770 and 21771
	#>
	[CmdletBinding()]
	param (
		[AllowEmptyCollection()]
		[AllowNull()]
		[Alias('ID')]
		[string[]]
		$Tests,

		[AllowEmptyCollection()]
		[AllowNull()]
		[string[]]
		$Pillar,

		[ValidateSet('Workforce', 'External')]
		[string]
		$TenantType,

		[Parameter(DontShow = $true)]
		[switch]
		$Current
	)
	begin {
		if (-not $script:__ZtSession.TestMeta) {
			$script:__ZtSession.TestMeta = foreach ($command in Get-Command Test-Assessment-* -Module $PSCmdlet.MyInvocation.MyCommand.Module.Name) {
				Get-ZtTestMetadata -Command $command
			}
		}
	}
	process {
		if ($Current) {
			return $script:__ztCurrentTest
		}

		$script:__ZtSession.TestMeta | Where-Object {
			(-not $Tests -or $_.TestID -in $Tests) -and
			(-not $Pillar -or $Pillar -contains 'All' -or $_.Pillar -in $Pillar) -and
			(-not $TenantType -or $_.TenantType -contains $TenantType)
		}
	}
}
