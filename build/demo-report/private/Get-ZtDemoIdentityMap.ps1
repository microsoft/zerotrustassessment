function Get-ZtDemoIdentityMap {
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Report,

        [System.Collections.IDictionary[]]$AdditionalReports = @()
    )

    $context = @{
        Replacements = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        Categories = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        Guids = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        Urls = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        Addresses = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        AliasSeeds = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        Next = @{ Human = 1; Agent = 1; Resource = 1; Domain = 1; Url = 1; Address = 1 }
        RootIdentifiers = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        Matcher = $null
    }
    $emptyValues = '^(?:[-\s]*|none|unknown|not configured|not applicable|n/?a|null|default|all|all users|all devices|all applications|all groups|all resources|true|false|enabled|disabled|active|inactive|yes|no|users|groups|devices|applications|service principals|user|group|device|application|member|guest|system|inherited|not available|unavailable)$'
    $decode = {
        param([string]$Text)
        for ($i = 0; $i -lt 3; $i++) {
            $next = [System.Net.WebUtility]::HtmlDecode([uri]::UnescapeDataString($Text))
            if ($next -ceq $Text) { break }
            $Text = $next
        }
        return $Text
    }
    $register = {
        param([string]$Text, [string]$Category, [string]$Seed)
        $Text = (& $decode $Text).Trim().Trim('`', '"', "'")
        if (-not $Text -or $Text -match $emptyValues -or $Text -match '^\d+([.,]\d+)?$') { return }
        if ($Text -match '^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$' -or $Text -match '^[a-f0-9]{32}$') { return }
        if ($Text -match '^https?://' -or $Text.Length -gt 500) { return }
        if ($Text -match '\[[^\]]+\]\(' -or $Text -match '<br\s*/?>') {
            foreach ($match in [regex]::Matches($Text, '\[([^\]]+)\]\([^)]+\)')) {
                & $register $match.Groups[1].Value $Category $null
            }
            foreach ($piece in ($Text -split '(?i)<br\s*/?>')) {
                if ($piece -notmatch '\[[^\]]+\]\(') { & $register $piece $Category $null }
            }
            return
        }
        if ($context.Replacements.ContainsKey($Text)) {
            if ($Category -ne 'Agent' -or $context.Categories[$Text] -eq 'Agent') { return }
        }
        if (-not $Seed) { $Seed = $Text }
        $seedKey = $Category + ':' + $Seed.ToLowerInvariant()
        if (-not $context.AliasSeeds.ContainsKey($seedKey)) {
            $number = $context.Next[$Category]
            $context.Next[$Category]++
            $alias = switch ($Category) {
                'Human' { 'Nivora Teluvi {0:D5}' -f $number }
                'Agent' { 'Vezuni Ralovi {0:D5}' -f $number }
                'Domain' { 'resource{0:D5}.contoso.com' -f $number }
                default { 'Suvexa {0:D5}' -f $number }
            }
            $context.AliasSeeds[$seedKey] = $alias
        }
        $context.Replacements[$Text] = $context.AliasSeeds[$seedKey]
        $context.Categories[$Text] = $Category
    }
    $scanText = {
        param([string]$Text, [bool]$Ai)
        $Text = & $decode $Text
        foreach ($email in [regex]::Matches($Text, '(?i)[a-z0-9._%+\-]+(?:_[a-z0-9.\-]+#EXT#)?@[a-z0-9.\-]+\.[a-z]{2,}')) {
            & $register $email.Value 'Human' $email.Value
        }
        $lines = $Text -split '\r?\n'
        $headers = $null
        for ($i = 0; $i -lt $lines.Length; $i++) {
            $line = $lines[$i]
            if ($line -notmatch '^\s*\|') { $headers = $null; continue }
            $cells = [regex]::Split($line.Trim().Trim('|'), '(?<!\\)\|')
            if ($i + 1 -lt $lines.Length -and $lines[$i + 1] -match '^\s*\|?(\s*:?-{2,}:?\s*\|)+\s*$') {
                $headers = @($cells | ForEach-Object { $_.Trim() -replace '\s+', ' ' })
                continue
            }
            if (-not $headers -or $line -match '^\s*\|?(\s*:?-{2,}:?\s*\|)+\s*$') { continue }
            $emailSeed = $null
            for ($c = 0; $c -lt [Math]::Min($cells.Length, $headers.Length); $c++) {
                if ($headers[$c] -match '(?i)\b(upn|user principal name|principal name)\b') {
                    $emailSeed = $cells[$c].Trim()
                    break
                }
            }
            for ($c = 0; $c -lt [Math]::Min($cells.Length, $headers.Length); $c++) {
                $header = $headers[$c]
                $value = $cells[$c].Trim()
                $category = $null
                if ($header -match '(?i)(agent|blueprint).*name') { $category = 'Agent' }
                elseif ($emailSeed -and $header -match '(?i)display\s*name|^name$|principal|role member') { $category = 'Human' }
                elseif ($header -match '(?i)compromised user|assigned to|initiated by|created by|owner|sponsor|approver|recipient|review mailbox|user.*name|account.*name|^user$|^upn$|^principal$') { $category = 'Human' }
                elseif ($header -match '(?i)authentication method|role (display )?name|control title|recommendation title|asr rule') { continue }
                elseif ($header -match '(?i)(^name$|display\s*name|policy|profile|group|machine|device|resource|subscription|workspace|connector|network|certificate|common name|access package|assignment policy|application|^app name$|^identity$|^label name$|parent label|sample labels|diagnostic settings|^principal name$)' -and $header -notmatch '(?i)count|status|type|state|date|rule[s ]count|configured|app id|application id|scope|version|permission|minimum|maximum|target kind|resource type|^policy category$') {
                    $category = if ($Ai -and $header -match '(?i)app|display|^name$') { 'Agent' } else { 'Resource' }
                }
                if ($category) {
                    & $register $value $category $(if ($category -eq 'Human') { $emailSeed } else { $null })
                }
            }
        }
    }
    $walk = {
        param($Value, [string]$Field, [string]$Path, [bool]$Ai)
        if ($Value -is [System.Collections.IDictionary]) {
            foreach ($key in $Value.Keys) {
                & $scanText ([string]$key) $Ai
                & $walk $Value[$key] ([string]$key) ($Path + '.' + $key) $Ai
            }
        }
        elseif ($Value -is [System.Collections.IList]) {
            foreach ($item in $Value) { & $walk $item $Field $Path $Ai }
        }
        elseif ($Value -is [string]) {
            if ($Field -match '^(?i:TenantName)$') { & $register $Value 'Resource' $null }
            elseif ($Field -match '^(?i:Domain)$') { & $register $Value 'Domain' $null }
            elseif ($Field -match '^(?i:displayName|Name|PolicyName|DeviceName|GroupName|agentName|owner|sponsor|userPrincipalName|mail|email|principalName|subscriptionName|resourceGroup|IncludedGroups|ExcludedGroups|Groups|AssignedTo)$' -and $Path -notmatch '(?i)\.gates\.|\.nodes\.|\.Tests\.') {
                $category = if ($Path -match '(?i)Agent|Blueprint') { 'Agent' } elseif ($Field -match '(?i)owner|sponsor|user|mail|email|principal') { 'Human' } else { 'Resource' }
                & $register $Value $category $null
            }
            & $scanText $Value $Ai
            if ($Value.TrimStart() -match '^[\[{]') {
                try { $nested = $Value | ConvertFrom-Json -AsHashtable -Depth 100 -ErrorAction Stop }
                catch { $nested = $null }
                if ($null -ne $nested) { & $walk $nested '' ($Path + '.NestedJson') $Ai }
            }
        }
    }
    foreach ($source in @($Report) + @($AdditionalReports)) {
        foreach ($field in @('TenantName', 'Domain', 'Account', 'TenantId')) {
            if ($source[$field]) { $null = $context.RootIdentifiers.Add([string]$source[$field]) }
        }
        foreach ($key in $source.Keys) {
            if ($key -eq 'Tests') {
                foreach ($test in $source.Tests) {
                    & $walk $test '' 'root.Tests' (@($test.TestPillar) -contains 'AI')
                }
            }
            else { & $walk $source[$key] ([string]$key) ('root.' + $key) $false }
        }
        if ($source.Domain -and $source.Domain -match '^([^.]+)\.') {
            & $register $matches[1] 'Resource' $null
        }
    }
    foreach ($key in @($context.Replacements.Keys)) {
        if ($key -match '@') {
            $alias = $context.Replacements[$key]
            if ($alias -match '(\d+)$') {
                $context.Replacements[$key] = 'nivora.teluvi' + $matches[1] + '@contoso.com'
            }
        }
    }
    $context.Matcher = New-ZtDemoTextMatcher -Names @($context.Replacements.Keys)
    return $context
}
