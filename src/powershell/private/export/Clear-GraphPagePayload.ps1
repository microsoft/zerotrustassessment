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
