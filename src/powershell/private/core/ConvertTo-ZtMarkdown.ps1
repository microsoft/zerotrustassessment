function ConvertTo-ZtMarkdown {
	<#
	.SYNOPSIS
		Converts an HTML string to Markdown.

	.DESCRIPTION
		Converts an HTML string to Markdown. Handles common HTML elements including
		anchors, lists, line breaks, paragraphs, bold, italic, and HTML entities.
		Bare URLs are wrapped as Markdown links and inline numbered steps are
		split onto separate lines.

	.PARAMETER Html
		The HTML string to convert.

	.EXAMPLE
		PS C:\> ConvertTo-ZtMarkdown -Html $firstRow.description

		Converts the HTML description to a Markdown string.
	#>
	[CmdletBinding()]
	[OutputType([string])]
	param (
		[Parameter(Mandatory = $true, Position = 0)]
		[AllowNull()]
		[AllowEmptyString()]
		[string]
		$Html
	)

	if ([string]::IsNullOrWhiteSpace($Html)) { return $Html }

	$md = $Html

	# Convert anchor tags to Markdown links
	$md = [regex]::Replace($md, '<a\s+[^>]*href="([^"]*)"[^>]*>([^<]*)</a>', '[$2]($1)')

	# Convert ordered list items with sequential numbering
	$liCounter = [ref]0
	$md = [regex]::Replace($md, '<li[^>]*>', {
		$liCounter.Value++
		"`n$($liCounter.Value). "
	})

	$md = $md -replace '</li>', ''
	$md = $md -replace '<[ou]l[^>]*>', ''
	$md = $md -replace '</[ou]l>', ''
	$md = $md -replace '<br\s*/?>', "`n"
	$md = $md -replace '</?p[^>]*>', "`n"
	$md = $md -replace '</?div[^>]*>', "`n"
	$md = $md -replace '<(?:b|strong)[^>]*>([^<]*)</(?:b|strong)>', '**$1**'
	$md = $md -replace '<(?:i|em)[^>]*>([^<]*)</(?:i|em)>', '*$1*'

	# Strip any remaining HTML tags
	$md = $md -replace '<[^>]+>', ''

	# Decode HTML entities
	$md = $md -replace '&amp;', '&'
	$md = $md -replace '&lt;', '<'
	$md = $md -replace '&gt;', '>'
	$md = $md -replace '&quot;', '"'
	$md = $md -replace '&#39;', "'"
	$md = $md -replace '&nbsp;', ' '

	# Convert bare URLs (not already wrapped in a Markdown link) → [url](url)
	$md = [regex]::Replace($md, '(?<!\()(https?://[^\s<>"\[\]()]+?)([.,;]?)(?=\s|$)', '[${1}](${1})${2}')

	# Break inline numbered steps onto separate lines: "text 2. Word" → "text\n2. Word"
	$md = [regex]::Replace($md, '(?<=\S) (\d{1,2})\. ([A-Z])', "`n" + '$1. $2')

	$md = ($md -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }) -join "`n"

	return $md
}
