function Test-ZtDemoReportData {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Report,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$IdentityMap,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$OriginalReport,

        [string]$Html
    )

    if ($Report.IsDemo -isnot [bool] -or -not $Report.IsDemo -or $Report.EndOfJson -cne 'EndOfJson') {
        throw 'Demo report metadata failed validation.'
    }
    if (@($Report.Tests).Count -ne @($OriginalReport.Tests).Count) {
        throw 'Anonymization changed the assessment record count.'
    }
    $schemaFields = @('TestPillar', 'TestStatus', 'TestSkipped', 'TestCategory', 'TestTags', 'TestSfiPillar', 'TestAppliesTo', 'TestRisk', 'TestImpact', 'TestImplementationCost', 'TestMinimumLicense')
    $summary = @{}
    for ($i = 0; $i -lt @($OriginalReport.Tests).Count; $i++) {
        foreach ($field in $schemaFields) {
            $before = ConvertTo-Json -InputObject $OriginalReport.Tests[$i][$field] -Compress -Depth 100
            $after = ConvertTo-Json -InputObject $Report.Tests[$i][$field] -Compress -Depth 100
            if ($before -cne $after) { throw "Anonymization changed an assessment's $field contract at record $i." }
        }
        $originalId = [string]$OriginalReport.Tests[$i].TestId
        $guidLikeId = $originalId -match '^(?i:[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}|[a-f0-9]{32})$'
        if ($guidLikeId) {
            $maskedId = $IdentityMap.Guids[$originalId.Replace('-', '').ToLowerInvariant()]
            if ($Report.Tests[$i].TestId -cne $maskedId) { throw "Anonymization changed a recommendation's masked identifier at record $i." }
        }
        elseif ($Report.Tests[$i].TestId -cne $OriginalReport.Tests[$i].TestId) { throw "Anonymization changed a numeric assessment identifier at record $i." }
        $test = $Report.Tests[$i]
        foreach ($pillar in @($test.TestPillar)) {
            if (-not $summary.ContainsKey($pillar)) { $summary[$pillar] = @{ Passed = 0; Total = 0 } }
            if ($test.TestStatus -notin @('Skipped', 'Planned')) {
                $summary[$pillar].Total++
                if ($test.TestStatus -eq 'Passed') { $summary[$pillar].Passed++ }
            }
        }
    }
    foreach ($pillar in $summary.Keys) {
        if ($Report.TestResultSummary["${pillar}Passed"] -ne $summary[$pillar].Passed -or $Report.TestResultSummary["${pillar}Total"] -ne $summary[$pillar].Total) {
            throw 'The demo assessment summary does not match retained outcomes.'
        }
    }
    $staticDescriptions = @{
        'root.TenantInfo.OverviewM365ProtectionCircuit.description' = @(
            'Synthetic device population sizes the Microsoft 365 acquisition and enforcement circuit. Stage verdicts and unavailable stages retain the assessment findings.'
            'Device counts remain unavailable. The Microsoft 365 protection circuit uses a normalized width of 100 and retains the assessment stage verdicts.'
        )
        'root.TenantInfo.DeviceOverview.DeviceSummary.description' = 'Synthetic devices and Microsoft Defender for Endpoint sensor coverage by operating system.'
        'root.TenantInfo.DeviceOverview.DesktopDevicesSummary.description' = 'Synthetic desktop devices by operating system, join type, and compliance status.'
        'root.TenantInfo.DeviceOverview.MobileSummary.description' = 'Synthetic mobile devices by operating system and compliance status.'
        'root.TenantInfo.OverviewAuthMethodsPrivilegedUsers.description' = 'Strongest authentication method registered by synthetic privileged users.'
        'root.TenantInfo.OverviewAuthMethodsAllUsers.description' = 'Strongest authentication method registered by synthetic member and guest users.'
        'root.TenantInfo.OverviewCaMfaAllUsers.description' = 'Synthetic successful interactive sign-ins by Conditional Access and multifactor enforcement.'
        'root.TenantInfo.OverviewCaDevicesAllUsers.description' = 'Synthetic successful interactive sign-ins by device management and compliance status.'
        'root.TenantInfo.OverviewPrivateAccess.description' = 'Synthetic Private Access applications by segmentation and authentication posture. Administration uses a separate assignment population. Gate verdicts, unavailable stages, and population mismatches retain the assessment findings.'
        'root.TenantInfo.DlpWorkloadCoverage.description' = 'Synthetic policy counts by workload. Uncovered workloads and unavailable data retain their original meaning.'
        'root.TenantInfo.SensitivityLabelProtection.description' = 'Strongest protection applied by synthetic sensitivity labels. Empty protection categories remain empty.'
        'root.TenantInfo.OverviewCloudSecureScore[].description' = 'Synthetic secure score for this environment.'
        'root.TenantInfo.AgentOwnershipDistribution.description' = 'Synthetic agent ownership and effective sponsorship. Bucket counts match their available anonymized entity lists.'
        'root.TenantInfo.AgentOverview.description' = 'Synthetic agent population and distinct human users of agents.'
    }
    $authLabels = @('Users', 'Single factor', 'Phishable', 'Phone', 'Authenticator', 'Phish resistant', 'Passkey', 'WHfB')
    $desktopLabels = @('Desktop devices', 'Windows', 'macOS', 'Entra joined', 'Entra registered', 'Entra hybrid joined', 'Compliant', 'Non-compliant', 'Unmanaged')
    $staticChartLabels = @{
        'root.TenantInfo.OverviewAuthMethodsAllUsers.nodes[].source' = $authLabels
        'root.TenantInfo.OverviewAuthMethodsAllUsers.nodes[].target' = $authLabels
        'root.TenantInfo.OverviewAuthMethodsPrivilegedUsers.nodes[].source' = $authLabels
        'root.TenantInfo.OverviewAuthMethodsPrivilegedUsers.nodes[].target' = $authLabels
        'root.TenantInfo.DeviceOverview.DesktopDevicesSummary.nodes[].source' = $desktopLabels
        'root.TenantInfo.DeviceOverview.DesktopDevicesSummary.nodes[].target' = $desktopLabels
    }
    $counts = @{ Guid = 0; Identity = 0; Domain = 0; Url = 0; Credential = 0; Path = 0 }
    $scan = {
        param([string]$Text, [bool]$Shell, [bool]$DemoTenantName = $false, [bool]$SchemaValue = $false, [string]$FieldPath)
        if (-not $Shell -and $FieldPath -match '(?i)\.(authorization|cookie|set-cookie|x-api-key|password|client_?secret|access_?token|refresh_?token|connectionstring|accountkey|sharedaccesssignature|secret|token)(?:\[\])?$' -and $Text -and $Text -cne '[REDACTED]') { $counts.Credential++ }
        $isStaticText = ($staticDescriptions.ContainsKey($FieldPath) -and $Text -cin @($staticDescriptions[$FieldPath])) -or
            ($staticChartLabels.ContainsKey($FieldPath) -and $Text -cin $staticChartLabels[$FieldPath]) -or
            ($FieldPath -eq 'root.TenantInfo.OverviewCloudSecureScore[].environment' -and $Text -in @('All', 'Azure', 'AWS', 'GCP'))
        if (-not $Shell) {
            $Text = [regex]::Replace($Text, '(?i)(?:https?://|api://|mailto:)[^\s<>"`\\\]]+', {
                param($match)
                $url = $match.Value.TrimEnd(')', ',', ';', '.')
                if ((& $IdentityMap.IsPublicUrl $url) -or (& $IdentityMap.CanRetainRemediationUrl $url $Text $match.Index)) { return '' }
                return $match.Value
            })
        }
        for ($i = 0; $i -lt 3; $i++) {
            $next = [System.Net.WebUtility]::HtmlDecode([uri]::UnescapeDataString($Text))
            if ($next -ceq $Text) { break }
            $Text = $next
        }
        foreach ($match in [regex]::Matches($Text, '(?i)(?<![a-f0-9])(?:[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}|[a-f0-9]{32})(?![a-f0-9])')) {
            if ($match.Value.Replace('-', '') -notmatch '^([0-9])\1{31}$') { $counts.Guid++ }
        }
        $Text = [regex]::Replace($Text, '(?i)(?:https?://|api://|mailto:)[^\s<>"`\\\]]+', {
            param($match)
            $url = $match.Value.TrimEnd(')', ',', ';', '.')
            if ($Shell) { return '' }
            $uri = $null
            $isDemo = [uri]::TryCreate($url, [System.UriKind]::Absolute, [ref]$uri) -and $uri.Host -match '(?i)(^|\.)contoso\.(?:com|onmicrosoft\.com)$'
            if ($isDemo -or (& $IdentityMap.IsPublicUrl $url)) { return '' }
            $counts.Url++
            return ''
        })
        if (-not $Shell) {
            foreach ($match in [regex]::Matches($Text, '(?i)[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}')) {
                if ($match.Value -notmatch '(?i)@(contoso\.com|contoso\.onmicrosoft\.com|[a-z0-9.-]+\.contoso\.com)$') { $counts.Domain++ }
            }
            foreach ($match in [regex]::Matches($Text, '(?i)(?<![\w.])(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:com|net|org|io|dev|app|cloud|edu|gov|local|internal|invalid|co\.uk|us|uk|eu|in|de|fr|au|ca|biz|info|online|site|store|me|ai|test|example)(?![\w.])')) {
                if ($match.Value -notmatch '(?i)(^|\.)contoso\.(?:com|onmicrosoft\.com)$') { $counts.Domain++ }
            }
            if ($Text -match '(?i)(?:[a-z]:\\Users\\|\\\\(?!files\.contoso\.com)[a-z0-9._-]+\\|/(?:Users|home)/)') { $counts.Path++ }
        }
        $Text = $Text -replace '(?i)(?<![\w.])(?:\*?\.)?(?:[a-z0-9-]+\.)*contoso\.(?:onmicrosoft\.com|com)(?=$|[^\w.]|\.(?=\s|[^\w.]|$))', ''
        if ($DemoTenantName -and $Text -ceq 'Contoso') { $Text = '' }
        if ($Text -match '\bey[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}|(?i)Authorization\s*:\s*Bearer\s+\S+') { $counts.Credential++ }
        if ($Shell) {
            foreach ($identifier in $IdentityMap.RootIdentifiers) {
                if ($identifier -match '^(?i:contoso|contoso\.com|nivora\.admin@contoso\.com)$') { continue }
                $counts.Identity += [regex]::Matches($Text, [regex]::Escape($identifier), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase).Count
            }
        }
        elseif (-not $SchemaValue -and -not $isStaticText) { $counts.Identity += $IdentityMap.Matcher.CountMatches($Text) }
    }
    $walk = {
        param($Value, [bool]$DemoTenantName = $false, [bool]$SchemaValue = $false, [string]$FieldPath = 'root')
        if ($Value -is [System.Collections.IDictionary]) {
            foreach ($key in $Value.Keys) {
                & $scan ([string]$key) $false $false $false ($FieldPath + '.PropertyKey')
                $isSchemaValue = $FieldPath -eq 'root.Tests[]' -and $key -in $schemaFields
                & $walk $Value[$key] ([object]::ReferenceEquals($Value, $Report) -and $key -eq 'TenantName') $isSchemaValue ($FieldPath + '.' + $key)
            }
        }
        elseif ($Value -is [System.Collections.IList]) {
            foreach ($item in $Value) { & $walk $item $false $SchemaValue ($FieldPath + '[]') }
        }
        elseif ($Value -is [string]) { & $scan $Value $false $DemoTenantName $SchemaValue $FieldPath }
    }
    & $walk $Report
    if ($Html) { & $scan $Html $true $false $false 'Html' }
    $issues = @($counts.GetEnumerator() | Where-Object { $_.Value -gt 0 } | ForEach-Object { '{0}={1}' -f $_.Key, $_.Value })
    if ($issues.Count) { throw ('Demo privacy validation failed: ' + ($issues -join ', ') + '. No original values are included in this error.') }
    if ($OriginalReport.TenantInfo -is [System.Collections.IDictionary]) {
        foreach ($key in $OriginalReport.TenantInfo.Keys) {
            if (-not $Report.TenantInfo.Contains($key)) { throw 'A source overview dataset was lost.' }
        }
    }
    $ownership = $Report.TenantInfo.AgentOwnershipDistribution
    if ($ownership -is [System.Collections.IDictionary]) {
        $total = 0
        foreach ($bucket in @('ownerAndSponsor', 'ownerOnly', 'sponsorOnly', 'neither')) {
            if ($ownership[$bucket] -ne @($ownership.agents[$bucket]).Count) { throw 'Synthetic agent ownership lists and counts disagree.' }
            $total += $ownership[$bucket]
        }
        if ($Report.TenantInfo.AgentOverview -and $Report.TenantInfo.AgentOverview.TotalAgents -ne $total) { throw 'Synthetic agent overview totals disagree.' }
    }
    $dlp = $Report.TenantInfo.DlpWorkloadCoverage
    if ($dlp) {
        $covered = @($dlp.Keys | Where-Object { $_ -match 'PolicyCount$' -and $dlp[$_] -gt 0 }).Count
        if ($dlp.coveredWorkloadCount -ne $covered) { throw 'Synthetic DLP workload totals disagree.' }
    }
    $labels = $Report.TenantInfo.SensitivityLabelProtection
    if ($labels) {
        $total = 0
        foreach ($name in @('encryptionDkeCount', 'encryptionCount', 'classificationOnlyCount', 'visualMarkingOnlyCount')) { $total += $labels[$name] }
        if ($labels.totalLabelCount -ne $total) { throw 'Synthetic sensitivity label totals disagree.' }
    }
    $cloudScores = @($Report.TenantInfo.OverviewCloudSecureScore)
    $sourceScores = @($OriginalReport.TenantInfo.OverviewCloudSecureScore)
    for ($i = 0; $i -lt $sourceScores.Count; $i++) {
        if ($sourceScores[$i].environment -in @('All', 'Azure', 'AWS', 'GCP') -and $cloudScores[$i].environment -cne $sourceScores[$i].environment) {
            throw 'A standard public cloud environment name was changed.'
        }
    }
    $availableScores = @($cloudScores | Where-Object {
        $_ -is [System.Collections.IDictionary] -and $_.max -gt 0 -and
        $null -ne $_.current -and $null -ne $_.percentage
    })
    foreach ($score in $availableScores) {
        $expected = 100.0 * $score.current / $score.max
        if ($score.current -lt 0 -or $score.current -gt $score.max -or [Math]::Abs($score.percentage - $expected) -gt 0.00000001) {
            throw 'Synthetic cloud secure score ratios disagree.'
        }
        if ([Math]::Abs($score.percentage % 10) -lt 0.00000001) {
            throw 'An available synthetic cloud secure score is a round multiple of ten.'
        }
    }
    $environmentScores = @($availableScores | Where-Object environment -NE 'All')
    $allScores = @($availableScores | Where-Object environment -EQ 'All')
    if ($allScores.Count -and $environmentScores.Count) {
        $current = 0.0
        $maximum = 0.0
        foreach ($provider in $environmentScores) {
            $current += $provider.current
            $maximum += $provider.max
        }
        foreach ($score in $allScores) {
            if ($score.current -ne $current -or $score.max -ne $maximum) { throw 'Synthetic cloud secure score aggregate totals disagree.' }
        }
    }
    $environments = @($availableScores.environment | Sort-Object -Unique)
    $percentages = @($availableScores.percentage | Sort-Object -Unique)
    $providerCount = @($environmentScores.environment | Sort-Object -Unique).Count
    if ($providerCount -gt 1 -and $percentages.Count -lt $environments.Count) { throw 'Available synthetic cloud environments must have different scores.' }
    foreach ($key in $Report.TenantInfo.Keys) {
        $dataset = $Report.TenantInfo[$key]
        if ($dataset -isnot [System.Collections.IDictionary] -or -not $dataset.Contains('nodes')) { continue }
        $incoming = @{}
        $outgoing = @{}
        foreach ($node in @($dataset.nodes)) {
            if (-not $incoming.ContainsKey($node.target)) { $incoming[$node.target] = 0 }
            if (-not $outgoing.ContainsKey($node.source)) { $outgoing[$node.source] = 0 }
            $incoming[$node.target] += $node.value
            $outgoing[$node.source] += $node.value
        }
        foreach ($node in $incoming.Keys) {
            if ($outgoing.ContainsKey($node) -and $incoming[$node] -ne $outgoing[$node]) { throw 'Synthetic chart flows do not reconcile.' }
        }
    }
    return $true
}
