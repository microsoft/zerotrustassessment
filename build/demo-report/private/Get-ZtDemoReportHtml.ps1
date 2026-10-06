function Get-ZtDemoReportHtml {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Json,

        [Parameter(Mandatory)]
        [string]$Html,

        [string]$OriginalJson
    )

    $assignments = [regex]::Matches($Html, '(?<![\w$])(?:window\.)?reportData\s*=\s*(?=\{)')
    if ($assignments.Count -ne 1) {
        throw 'The report HTML must contain exactly one report-data assignment.'
    }

    $start = $assignments[0].Index + $assignments[0].Length
    $depth = 0
    $inString = $false
    $escaped = $false
    $end = -1
    for ($i = $start; $i -lt $Html.Length; $i++) {
        $character = $Html[$i]
        if ($inString) {
            if ($escaped) { $escaped = $false }
            elseif ($character -eq '\') { $escaped = $true }
            elseif ($character -eq '"') { $inString = $false }
            continue
        }
        if ($character -eq '"') { $inString = $true }
        elseif ($character -eq '{' -or $character -eq '[') { $depth++ }
        elseif ($character -eq '}' -or $character -eq ']') {
            $depth--
            if ($depth -eq 0) {
                $end = $i + 1
                break
            }
        }
    }
    if ($end -lt 0 -or $inString) {
        throw 'The report HTML contains an incomplete report-data payload.'
    }
    $parseJson = {
        param([string]$Text)
        try {
            $parsed = ConvertFrom-Json -InputObject $Text -AsHashtable -Depth 100 -ErrorAction Stop
        }
        catch {
            throw 'A report-data payload is not valid JSON.'
        }
        if ($parsed -isnot [System.Collections.IDictionary]) {
            throw 'Report data must be a JSON object.'
        }
        return $parsed
    }
    $replacement = & $parseJson $Json
    if ($OriginalJson) {
        $existing = & $parseJson $Html.Substring($start, $end - $start)
        $original = & $parseJson $OriginalJson
        $normalize = {
            param($Value)
            if ($Value -is [System.Collections.IDictionary]) {
                $sorted = [ordered]@{}
                foreach ($key in @($Value.Keys | Sort-Object -CaseSensitive)) {
                    $sorted[$key] = & $normalize $Value[$key]
                }
                return $sorted
            }
            if ($Value -is [System.Collections.IList]) {
                $items = [System.Collections.Generic.List[object]]::new()
                foreach ($item in $Value) { $items.Add((& $normalize $item)) }
                return ,$items.ToArray()
            }
            return $Value
        }
        $left = (& $normalize $existing) | ConvertTo-Json -Depth 100 -Compress
        $right = (& $normalize $original) | ConvertTo-Json -Depth 100 -Compress
        if ($left -cne $right) {
            throw 'The source HTML and input JSON are from different report payloads.'
        }
    }
    if ($replacement.EndOfJson -cne 'EndOfJson') {
        throw 'The generated report data is missing its end sentinel.'
    }
    $scriptSafeJson = $replacement | ConvertTo-Json -Depth 100 -Compress -EscapeHandling EscapeHtml
    return $Html.Substring(0, $start) + $scriptSafeJson + $Html.Substring($end)
}
