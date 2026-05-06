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

	# Convert <a href="url">text</a> → [text](url)
	# <a\s+[^>]*href="([^"]*)"[^>]*> — opening <a> tag with any attributes; captures href value in group 1
	# ([^<]*) — captures the visible link text (no nested tags) in group 2
	# </a>    — closing tag
	$md = [regex]::Replace($md, '<a\s+[^>]*href="([^"]*)"[^>]*>([^<]*)</a>', '[$2]($1)')

	# Process <ol> and <ul> blocks: numbered items for <ol>, '-' bullets for <ul>.
	# The counter resets to 0 for each list so separate <ol> blocks both start at 1.
	# (?si)          — s: dot matches newlines (multi-line list content); i: case-insensitive tags
	# <(ol|ul)[^>]*> — opening list tag; captures tag name (ol/ul) in group 1
	# (.*?)          — lazily captures everything inside the list in group 2
	# </\1>          — closing tag matching the same tag name captured in group 1 (ol or ul)
	$md = [regex]::Replace($md, '(?si)<(ol|ul)[^>]*>(.*?)</\1>', {
		param($m)
		$isOrdered = $m.Groups[1].Value -ieq 'ol'
		$inner     = $m.Groups[2].Value
		$idx       = 0
		$liOut     = [System.Text.StringBuilder]::new()
		$last      = 0
		# (?si)<li[^>]*>(.*?)</li> — matches each list item; group 1 is the item content
		foreach ($li in ([regex]'(?si)<li[^>]*>(.*?)</li>').Matches($inner)) {
			$null = $liOut.Append($inner.Substring($last, $li.Index - $last))
			$content = $li.Groups[1].Value.Trim()
			if ($isOrdered) { $idx++; $null = $liOut.Append("`n$idx. $content") }
			else             {         $null = $liOut.Append("`n- $content") }
			$last = $li.Index + $li.Length
		}
		if ($last -lt $inner.Length) { $null = $liOut.Append($inner.Substring($last)) }
		# Remove any <li>/</ li> tags not matched above (e.g. malformed HTML without closing </li>)
		$processedInner = [regex]::Replace($liOut.ToString(), '</?li[^>]*>', '')
		return $processedInner + "`n"
	})

	# <br\s*/?> — self-closing or open <br>, with optional whitespace before the slash
	$md = $md -replace '<br\s*/?>', "`n"

	# </?p[^>]*>  — opening or closing <p> with any attributes
	# </?div[^>]*> — opening or closing <div> with any attributes
	$md = $md -replace '</?p[^>]*>', "`n"
	$md = $md -replace '</?div[^>]*>', "`n"

	# <(?:b|strong)[^>]*>([^<]*)</(?:b|strong)> — bold tags wrapping plain text; group 1 = content
	# (?:...) is a non-capturing group so $1 refers to the text content, not the tag name
	$md = $md -replace '<(?:b|strong)[^>]*>([^<]*)</(?:b|strong)>', '**$1**'

	# <(?:i|em)[^>]*>([^<]*)</(?:i|em)> — italic tags wrapping plain text; group 1 = content
	$md = $md -replace '<(?:i|em)[^>]*>([^<]*)</(?:i|em)>', '*$1*'

	# <[^>]+> — any remaining HTML tag: one or more non-'>' characters between angle brackets
	$md = $md -replace '<[^>]+>', ''

	# Decode HTML entities (handles named entities, numeric, and hex forms)
	$md = [System.Net.WebUtility]::HtmlDecode($md)
	# Normalize non-breaking spaces (&nbsp; decodes to U+00A0) to regular spaces
	$md = $md -replace '\u00A0', ' '

	# Convert bare URLs that are not already inside a Markdown link → [url](url)
	# (?<!\()                      — negative lookbehind: not preceded by '(' (already a Markdown link)
	# (https?://[^\s<>"\[\]()]+?)  — captures the URL lazily (stops before whitespace or special chars)
	# ([.,;]?)                     — optionally captures a trailing punctuation character
	# (?=\s|$)                     — lookahead: must be followed by whitespace or end of string
	$md = [regex]::Replace($md, '(?<!\()(https?://[^\s<>"\[\]()]+?)([.,;]?)(?=\s|$)', '[${1}](${1})${2}')

	# Break inline numbered steps onto separate lines: "text 2. Word" → "text\n2. Word"
	# (?<=\S)      — positive lookbehind: preceded by a non-whitespace character (mid-sentence)
	# (\d{1,2})\. — captures 1–2 digit number followed by a literal dot
	# ([A-Z])      — lookahead-style capture: next word starts with uppercase (new sentence/step)
	$md = [regex]::Replace($md, '(?<=\S) (\d{1,2})\. ([A-Z])', "`n" + '$1. $2')

	# Trim each line and remove blank lines
	$md = ($md -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }) -join "`n"

	return $md
}
