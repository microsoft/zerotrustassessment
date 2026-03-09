function Get-ZtPercentLabel {
	<#
	.SYNOPSIS
		Utility. Calculates percentage into something humanly readable.

	.DESCRIPTION
		Utility. Calculates percentage into something humanly readable.
		Will return "0%" in case of invalid data or > 100% percent.

	.PARAMETER Value
		The current value.

	.PARAMETER Total
		The total value the current value is part of.

	.EXAMPLE
		PS C:\> Get-ZtPercentLabel -Value 64 -Total 80

		Will return "80%"
	#>
	[OutputType([string])]
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[double]
		$Value,

		[Parameter(Mandatory = $true)]
		[double]
		$Total
	)

	# Handle null, empty, or zero total to prevent division by zero
	if ($total -le 0) {
		return "0%"
	}

	# Handle null or invalid value
	if ($value -le 0) {
		return "0%"
	}

	$percent = ($value / $total) * 100

	if ($percent -lt 0 -or $percent -gt 100) {
		return "0%"
	}

	if ($percent -gt 0 -and $percent -lt 1) {
		return "less than 1%"
	}
	else {
		$percentRounded = [math]::Round($percent, 1)
		return "$percentRounded%"
	}
}
