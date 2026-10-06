function ConvertTo-ZtDemoReportData {
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Report,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$IdentityMap
    )

    $guidPattern = '(?i)(?<![a-f0-9])[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}(?![a-f0-9])'
    $compactPattern = '(?i)(?<![a-f0-9])[a-f0-9]{32}(?![a-f0-9])'
    $authLabels = @('Users', 'Single factor', 'Phishable', 'Phone', 'Authenticator', 'Phish resistant', 'Passkey', 'WHfB')
    $desktopLabels = @('Desktop devices', 'Windows', 'macOS', 'Entra joined', 'Entra registered', 'Entra hybrid joined', 'Compliant', 'Non-compliant', 'Unmanaged')
    $guidAlias = {
        param([string]$Value)
        $key = $Value.Replace('-', '').ToLowerInvariant()
        if (-not $IdentityMap.Guids.ContainsKey($key)) {
            $digit = if ($key -eq ('0' * 32)) { '0' } else {
                $bytes = [System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($key))
                [string](1 + ($bytes[0] % 9))
            }
            $IdentityMap.Guids[$key] = ($digit * 8) + '-' + ($digit * 4) + '-' + ($digit * 4) + '-' + ($digit * 4) + '-' + ($digit * 12)
        }
        return $IdentityMap.Guids[$key]
    }
    $isPublicUrl = {
        param([string]$Value)
        $uri = $null
        if (-not [uri]::TryCreate($Value, [System.UriKind]::Absolute, [ref]$uri)) { return $false }
        $decodedValue = $Value
        for ($i = 0; $i -lt 3; $i++) { $decodedValue = [System.Net.WebUtility]::HtmlDecode([uri]::UnescapeDataString($decodedValue)) }
        if ($uri.UserInfo -or $uri.Query -or $decodedValue -match '(?i)(?<![a-f0-9])(?:[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}|[a-f0-9]{32})(?![a-f0-9])' -or $decodedValue -match '(?i)@|tenantId|access_token|client_secret|signature=') { return $false }
        if ($uri.Host -eq 'learn.microsoft.com' -and $uri.AbsolutePath -match '^/(?:[a-z]{2}-[a-z]{2}/)?(?:azure|entra|microsoft-365|windows|intune|defender|purview|security|compliance|powershell|graph|mem|office|sharepoint|microsoftteams|exchange|information-protection|dynamics365|fabric|dotnet)/') { return $true }
        if ($uri.Host -eq 'github.com' -and $uri.AbsolutePath -match '^/microsoft/(?:zerotrustassessment|Microsoft365DSC)(?:/|$)') { return $true }
        if ($uri.Host -eq 'microsoft.github.io' -and $uri.AbsolutePath -match '^/zerotrustassessment(?:/|$)') { return $true }
        if ($uri.Host -eq 'aka.ms' -and $uri.AbsolutePath -match '^/(?:zerotrust|ZeroTrust|zero-trust|mfa|sspr|entra|intune|defender|purview|mcra|Azure|azure|M365|m365)[a-z0-9/_-]*$') { return $true }
        if ($uri.Host -in @('privacy.microsoft.com', 'www.microsoft.com') -and $uri.AbsolutePath -match '^/(?:[a-z]{2}-[a-z]{2}/)?(?:privacy|legal|security|trust-center|licensing|microsoft-365)(?:/|$)') { return $true }
        return $false
    }
    $canRetainRemediationUrl = {
        param([string]$Value, [string]$Text, [int]$Index)

        $remediationHeadingPattern = '(?im)(?:^\s*(?:#{1,6}\s+(?<hash>[^#\r\n]+?)\s*#*\s*|\*{1,2}(?<bold>[^*\r\n]+?)\*{1,2}\s*|_{1,2}(?<italic>[^_\r\n]+?)_{1,2}\s*|(?<plain>Remediation(?:\s+(?:action|links?))?)\s*:?\s*)$|<(?:b|strong|h[1-6])\b[^>]*>\s*(?<html>[^<]+?)\s*</(?:b|strong|h[1-6])>)'
        $headings = [regex]::Matches($Text.Substring(0, $Index), $remediationHeadingPattern)
        if (-not $headings.Count) { return $false }
        $heading = $headings[$headings.Count - 1]
        $title = @('hash', 'bold', 'italic', 'plain', 'html') |
            ForEach-Object { $heading.Groups[$_].Value } |
            Where-Object { $_ } |
            Select-Object -First 1
        if (([string]$title).Trim().TrimEnd(':') -notmatch '^(?i:remediation(?:\s+(?:action|links?))?)$') { return $false }

        $uri = $null
        if (-not [uri]::TryCreate($Value, [System.UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -notin @('http', 'https')) { return $false }
        $decodedValue = $Value
        for ($i = 0; $i -lt 3; $i++) { $decodedValue = [System.Net.WebUtility]::HtmlDecode([uri]::UnescapeDataString($decodedValue)) }
        if ($uri.UserInfo -or $decodedValue -match '(?i)(?<![a-f0-9])(?:[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}|[a-f0-9]{32})(?![a-f0-9])' -or
            $decodedValue -match '(?i)@|tenantId|access_token|client_secret|signature=') {
            return $false
        }

        $adminPortal = $uri.Host -match '^(?i:portal\.azure\.com|entra\.microsoft\.com|portal\.cloud\.microsoft|(?:admin|security|compliance|endpoint|intune|defender|purview)\.microsoft\.com|admin\.(?:exchange|teams)\.microsoft\.com|[^.]+\.admin\.microsoft\.com|admin\.powerplatform\.microsoft\.com|make\.powerapps\.com|admin\.fabric\.microsoft\.com)$'
        $deepLink = $uri.AbsolutePath -notin @('', '/') -or $uri.Query -or $uri.Fragment
        return -not ($adminPortal -and $deepLink)
    }
    $IdentityMap.IsPublicUrl = $isPublicUrl
    $IdentityMap.CanRetainRemediationUrl = $canRetainRemediationUrl
    $transform = {
        param([string]$Text, [string]$Field)
        if (-not $Text) { return $Text }
        if ($Field -match '^(?i:authorization|cookie|set-cookie|x-api-key|password|client_?secret|access_?token|refresh_?token|connectionstring|accountkey|sharedaccesssignature|secret|token)$') { return '[REDACTED]' }
        if ($Field -eq 'TestId') {
            $Text = [regex]::Replace($Text, $guidPattern, { param($match) & $guidAlias $match.Value })
            return [regex]::Replace($Text, $compactPattern, { param($match) & $guidAlias $match.Value })
        }
        if ($Field -in @('TestPillar', 'TestStatus', 'TestSkipped', 'TestCategory', 'TestTags', 'TestSfiPillar', 'TestAppliesTo', 'TestRisk', 'TestImpact', 'TestImplementationCost', 'TestMinimumLicense')) { return $Text }
        if ($Text.TrimStart() -match '^[\[{]') {
            try { $nested = $Text | ConvertFrom-Json -AsHashtable -Depth 100 -ErrorAction Stop }
            catch { $nested = $null }
            if ($null -ne $nested) {
                $result = & $walk $nested $Field
                return ConvertTo-Json -InputObject $result -Depth 100 -Compress
            }
        }
        $Text = $Text -replace '(?i)(Authorization\s*:\s*)(?:Bearer\s+)?[^\r\n|]+', '${1}[REDACTED]'
        $Text = $Text -replace '(?i)((?:Cookie|Set-Cookie|X-Api-Key)\s*:\s*)[^\r\n|]+', '${1}[REDACTED]'
        $Text = $Text -replace '(?i)\bBearer\s+[A-Za-z0-9._~+/=-]+', '[REDACTED]'
        $Text = $Text -replace '\bey[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}', '[REDACTED]'
        $Text = $Text -replace '(?i)((?:client_secret|access_token|refresh_token|password|connectionstring|AccountKey|SharedAccessSignature)\s*[:=]\s*)[^;\s|]+', '${1}[REDACTED]'
        $public = [System.Collections.Generic.List[string]]::new()
        $Text = [regex]::Replace($Text, '(?i)(?:https?://|api://|mailto:)[^\s<>"''`\\\]]+', {
            param($match)
            $url = $match.Value.TrimEnd(')', ',', ';', '.')
            $tail = $match.Value.Substring($url.Length)
            $retained = (& $isPublicUrl $url) -or (& $canRetainRemediationUrl $url $Text $match.Index)
            if (-not $retained -and -not $IdentityMap.Urls.ContainsKey($url)) {
                $number = $IdentityMap.Next.Url
                $IdentityMap.Next.Url++
                $IdentityMap.Urls[$url] = 'https://app{0:D5}.contoso.com/demo/resource{0:D5}' -f $number
            }
            $index = $public.Count
            $public.Add($(if ($retained) { $url } else { $IdentityMap.Urls[$url] }))
            return "~ZTDEMOPUBLIC$index~" + $tail
        })
        $Text = $Text -replace '(?i)(?:[a-z]:\\|\\\\)[^\r\n|<>"]+', 'C:\Demo\Resources\sample.json'
        $Text = $Text -replace '(?i)/(?:Users|home)/[^\s|<>"`]+', '/demo/resources/sample'
        for ($i = 0; $i -lt 3; $i++) {
            $decoded = [System.Net.WebUtility]::HtmlDecode([uri]::UnescapeDataString($Text))
            if ($decoded -ceq $Text) { break }
            $Text = $decoded
        }
        $Text = $IdentityMap.Matcher.Replace($Text, $IdentityMap.Replacements)
        $Text = [regex]::Replace($Text, $guidPattern, { param($match) & $guidAlias $match.Value })
        $Text = [regex]::Replace($Text, $compactPattern, { param($match) & $guidAlias $match.Value })
        $Text = [regex]::Replace($Text, '(?i)[a-z0-9._%+\-]+(?:_[a-z0-9.\-]+#EXT#)?@[a-z0-9.\-]+\.[a-z]{2,}', {
            param($match)
            if ($match.Value -match '(?i)@contoso\.(?:com|onmicrosoft\.com)$') { return $match.Value }
            if ($IdentityMap.Replacements.ContainsKey($match.Value)) { return $IdentityMap.Replacements[$match.Value] }
            $digest = [System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($match.Value.ToLowerInvariant()))
            return 'nivora.teluvi' + [Convert]::ToHexString($digest[0..5]).ToLowerInvariant() + '@contoso.com'
        })
        $Text = [regex]::Replace($Text, '(?i)(?<![\w.])(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:com|net|org|io|dev|app|cloud|edu|gov|local|internal|invalid|co\.uk|us|uk|eu|in|de|fr|au|ca|biz|info|online|site|store|me|ai|test|example)(?![\w.])', {
            param($match)
            if ($match.Value -match '(?i)(^|\.)contoso\.(?:com|onmicrosoft\.com)$') { return $match.Value.ToLowerInvariant() }
            if (-not $IdentityMap.Replacements.ContainsKey($match.Value)) {
                $number = $IdentityMap.Next.Domain
                $IdentityMap.Next.Domain++
                $IdentityMap.Replacements[$match.Value] = 'resource{0:D5}.contoso.com' -f $number
                $IdentityMap.Categories[$match.Value] = 'Domain'
            }
            $alias = $IdentityMap.Replacements[$match.Value]
            if ($alias -notmatch '\.contoso\.com$|^contoso\.com$') { return 'contoso.com' }
            return $alias
        })
        if ($Field -notmatch '(?i)version|minver|maxver|osversion|build') {
            $Text = [regex]::Replace($Text, '(?<![\w.])(?:\d{1,3}\.){3}\d{1,3}(?:/\d{1,2})?(?![\w.])', {
                param($match)
                $address = $null
                $candidate = ($match.Value -split '/')[0]
                if (-not [System.Net.IPAddress]::TryParse($candidate, [ref]$address)) { return $match.Value }
                if (-not $IdentityMap.Addresses.ContainsKey($match.Value)) {
                    $number = $IdentityMap.Next.Address
                    $IdentityMap.Next.Address++
                    if ($number -gt 762) { throw 'The demo address pool is exhausted.' }
                    $prefixes = @('192.0.2.', '198.51.100.', '203.0.113.')
                    $IdentityMap.Addresses[$match.Value] = $prefixes[[int][Math]::Floor(($number - 1) / 254)] + (1 + (($number - 1) % 254))
                }
                return $IdentityMap.Addresses[$match.Value] + $(if ($match.Value -match '(/\d{1,2})$') { $matches[1] } else { '' })
            })
            $Text = [regex]::Replace($Text, '(?i)(?<![\w:])(?:[a-f0-9]{0,4}:){2,}[a-f0-9:]{0,39}(?:/\d{1,3})?(?![\w:])', {
                param($match)
                $address = $null
                if (-not [System.Net.IPAddress]::TryParse(($match.Value -split '/')[0], [ref]$address)) { return $match.Value }
                if (-not $IdentityMap.Addresses.ContainsKey($match.Value)) {
                    $number = $IdentityMap.Next.Address
                    $IdentityMap.Next.Address++
                    $IdentityMap.Addresses[$match.Value] = '2001:db8::' + $number.ToString('x')
                }
                return $IdentityMap.Addresses[$match.Value]
            })
        }
        for ($i = 0; $i -lt $public.Count; $i++) {
            $Text = $Text.Replace("~ZTDEMOPUBLIC$i~", $public[$i])
        }
        return $Text
    }
    $walk = {
        param($Value, [string]$Field, [string]$FieldPath = 'root')
        if ($Value -is [System.Collections.IDictionary]) {
            $result = [ordered]@{}
            foreach ($key in $Value.Keys) {
                $newKey = if ([string]$key -match '@|(?i)[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}|^[a-f0-9]{32}$') {
                    & $transform ([string]$key) 'PropertyKey'
                }
                else { [string]$key }
                if ($result.Contains($newKey)) { throw 'Anonymization would collide dictionary keys and discard records.' }
                $result[$newKey] = & $walk $Value[$key] ([string]$key) ($FieldPath + '.' + $key)
            }
            return $result
        }
        if ($Value -is [System.Collections.IList]) {
            $items = [System.Collections.Generic.List[object]]::new()
            foreach ($item in $Value) { $items.Add((& $walk $item $Field ($FieldPath + '[]'))) }
            return ,$items.ToArray()
        }
        if ($Value -is [string]) {
            $authLabel = $FieldPath -match '^root\.TenantInfo\.OverviewAuthMethods(?:AllUsers|PrivilegedUsers)\.nodes\[\]\.(source|target)$' -and $Value -cin $authLabels
            $desktopLabel = $FieldPath -match '^root\.TenantInfo\.DeviceOverview\.DesktopDevicesSummary\.nodes\[\]\.(source|target)$' -and $Value -cin $desktopLabels
            $cloudEnvironment = $FieldPath -eq 'root.TenantInfo.OverviewCloudSecureScore[].environment' -and $Value -in @('All', 'Azure', 'AWS', 'GCP')
            if ($authLabel -or $desktopLabel -or $cloudEnvironment) { return $Value }
            return & $transform $Value $Field
        }
        return $Value
    }
    $result = & $walk $Report ''
    $result.TenantName = 'Contoso'
    $result.Domain = 'contoso.com'
    $result.Account = 'nivora.admin@contoso.com'
    $result.ExecutedAt = '2026-01-01T00:00:00Z'
    $result.IsDemo = $true
    $result.EndOfJson = 'EndOfJson'
    return $result
}
