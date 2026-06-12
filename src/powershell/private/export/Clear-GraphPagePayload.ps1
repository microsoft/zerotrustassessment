<#
	.SYNOPSIS
		Removes the Graph page payload from an export results object.

	.DESCRIPTION
		Removes the value property from a Microsoft Graph page results object so the
		page payload can be released after it has been processed. Supports both
		dictionary-based results and PowerShell objects with a value property.

	.PARAMETER Results
		The Graph page results object to clear.

	#>
function Clear-GraphPagePayload {
	[CmdletBinding()]
	param (
		$Results
	)

	if (-not $Results) {
		return
	}

	if ($Results -is [System.Collections.IDictionary]) {
		if ($Results.Contains('value')) {
			$Results.Remove('value')
		}
		return
	}

	$valueProperty = $Results.PSObject.Properties['value']
	if (-not $valueProperty) {
		return
	}

	try {
		$Results.PSObject.Properties.Remove('value')
	}
	catch {
		$valueProperty.Value = $null
	}
}
