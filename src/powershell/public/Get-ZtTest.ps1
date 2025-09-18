function Get-ZtTest {
	[CmdletBinding()]
	param (
		[string[]]
		$ID,

		[string[]]
		$Pillar,

		[ValidateSet('Workforce', 'External')]
		[string]
		$TenantType
	)
	begin {
		if (-not $script:__ZtSession.TestMeta) {
			$script:__ZtSession.TestMeta = foreach ($command in Get-Command Test-Assessment-* -Module ZeroTrustAssessmentV2) {
				Get-ZtTestMetadata -Command $command
			}
		}
	}
	process {

	}
}
