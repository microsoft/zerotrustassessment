function Get-SafeMarkdown {
	<#
	.SYNOPSIS
		Escapes text to be safe to use in markdown.

	.DESCRIPTION
		Escapes text to be safe to use in markdown.

	.PARAMETER Text
		The text to escape

	.EXAMPLE
		PS C:\> Get-SafeMarkdown -Text $tenantName

		Converts the content of $tenantName into something safe to use in markdown.
	#>
	[CmdletBinding()]
	[OutputType()]
	param (
		[Parameter(Position = 0)]
		[AllowNull()]
		[AllowEmptyString()]
		[string]
		$Text
	)
    $Text -replace "\[", "\[" -replace "\]", "\]"
}
