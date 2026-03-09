function Get-ZtExportStatistics {
	<#
	.SYNOPSIS
		Retrieve the last Entra data export's statistics.

	.DESCRIPTION
		Retrieve the last Entra data export's statistics.
		This allows analyzing issues with the data collecting and retrieving any errors that happened originally.

	.PARAMETER Name
		The name of the export step to retrieve.
		Will return the full list if not specified.

	.EXAMPLE
		PS C:\> Get-ZtExportStatistics

		Retrieve the last Entra data export's statistics.
	#>
	[CmdletBinding()]
	param (
		[string[]]
		$Name
	)
	process {
		$script:__ZtSession.ExportStatistics.Values | Where-Object {
			-not $Name -or
			$_.Name -in $Name
		}
	}
}
