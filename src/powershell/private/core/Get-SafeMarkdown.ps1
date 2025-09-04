function Get-SafeMarkdown
{
	[CmdletBinding()]
	param (
		$text
	)
    $text = $text -replace "\[", "\["
    $text = $text -replace "\]", "\]"
    return $text
}
