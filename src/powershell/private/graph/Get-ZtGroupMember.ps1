function Get-ZtGroupMember {
	<#
	.SYNOPSIS
		Returns all members of the specified group.

	.DESCRIPTION
		Returns all members of the specified group.
		Uses the caching from "Invoke-ZtGraphRequest"

	.PARAMETER GroupId
		The group to retrieve members for.

	.PARAMETER Recurse
		Whether to resolve nested group memberships instead.

	.PARAMETER OutputType
		The datatype to return the members in.
		Defaults to: PSObject

	.EXAMPLE
		PS C:\> Get-ZtGroupMember -GroupId $myGroup

		Returns all members of the group stored in $myGroup
	#>
	[CmdletBinding()]
	param(
		[Parameter(Position = 0, mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('id')]
		[guid]
		$GroupId,

		[Alias('Recursive')]
		[switch]
		$Recurse,

		[ValidateSet('PSObject', 'PSCustomObject', 'Hashtable')]
		[string]
		$OutputType = 'PSObject'
	)

	process {
		Write-PSFMessage -Message "Retrieving group members for {0}." -StringValues "$GroupId"

		if ($Recurse) {
			Invoke-ZtGraphRequest -RelativeUri "groups/$GroupId/transitiveMembers" -ApiVersion v1.0 -OutputType $OutputType
		}
		else {
			Invoke-ZtGraphRequest -RelativeUri "groups/$GroupId/members" -ApiVersion v1.0 -OutputType $OutputType
		}
	}
}
