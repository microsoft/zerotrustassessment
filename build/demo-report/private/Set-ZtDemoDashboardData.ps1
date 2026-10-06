function Set-ZtDemoDashboardData {
    <#
    .SYNOPSIS
        Sets coherent synthetic dashboard populations on an anonymized demo report.

    .DESCRIPTION
        Mutates known, available dashboard metrics in place, retaining unfamiliar fields,
        configuration values, gate verdicts, and missing-data states. Recomputes assessment
        summaries from the unchanged tests using the production pillar/status semantics.
        Entity lists must already have been anonymized before this command is called.

    .PARAMETER Report
        The report dictionary, including dictionaries loaded with ConvertFrom-Json -AsHashtable.

    .EXAMPLE
        $report = Set-ZtDemoDashboardData -Report $report

        Updates the dashboard populations and returns the same report as a single object.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.IDictionary] $Report
    )

    $isNumber = {
        param($Value)
        $null -ne $Value -and [System.Type]::GetTypeCode($Value.GetType()) -in @(
            'Byte', 'SByte', 'Int16', 'UInt16', 'Int32', 'UInt32', 'Int64', 'UInt64',
            'Single', 'Double', 'Decimal'
        )
    }
    $setNumbers = {
        param($Object, [System.Collections.IDictionary] $Values)
        if ($Object -isnot [System.Collections.IDictionary]) { return }
        foreach ($key in $Values.Keys) {
            if ($Object.Contains($key) -and (& $isNumber $Object[$key])) {
                $Object[$key] = [System.Convert]::ChangeType(
                    $Values[$key], $Object[$key].GetType(), [cultureinfo]::InvariantCulture
                )
            }
        }
    }
    $setDescription = {
        param($Object, [string] $Text)
        if ($Object -is [System.Collections.IDictionary] -and $Object['description'] -is [string]) {
            $Object['description'] = $Text
        }
    }
    $setFlow = {
        param($Object, [System.Collections.IDictionary] $Values)
        if ($Object -isnot [System.Collections.IDictionary] -or
            $Object['nodes'] -isnot [System.Collections.IList] -or $Object['nodes'].Count -eq 0) {
            return
        }
        $nodes = [System.Collections.Generic.List[object]]::new()
        $represented = @{}
        $numberType = [long]
        foreach ($node in $Object['nodes']) {
            $nodes.Add($node)
            if ($node -isnot [System.Collections.IDictionary]) { continue }
            if (& $isNumber $node['value']) { $numberType = $node['value'].GetType() }
            $source = [string]$node['source']
            $target = [string]$node['target']
            if ($Values.Contains($source) -and $Values[$source].Contains($target)) {
                & $setNumbers $node @{ value = $Values[$source][$target] }
                $represented["$source`n$target"] = $true
            }
        }
        # Production omits zero-width links. Add newly positive links without losing node metadata.
        foreach ($source in $Values.Keys) {
            foreach ($target in $Values[$source].Keys) {
                $value = $Values[$source][$target]
                if ($value -gt 0 -and -not $represented.ContainsKey("$source`n$target")) {
                    $nodes.Add([System.Management.Automation.OrderedHashtable]::new([ordered]@{
                        source = $source
                        target = $target
                        value = [System.Convert]::ChangeType($value, $numberType, [cultureinfo]::InvariantCulture)
                    }))
                }
            }
        }
        $Object['nodes'] = $nodes.ToArray()
    }
    $getGateStatus = {
        param($Object, [string] $TestId)
        if ($Object -is [System.Collections.IDictionary]) {
            foreach ($gate in $Object['gates']) {
                if ($gate -is [System.Collections.IDictionary] -and $gate['testId'] -eq $TestId) {
                    return [string]$gate['status']
                }
            }
        }
        'Unavailable'
    }
    $setMarkdownCounts = {
        param($Test, [System.Collections.IDictionary] $Counts)
        if ($Test['TestResult'] -isnot [string] -or $Test['TestStatus'] -in 'Skipped', 'Planned', 'Error') {
            return
        }
        $text = $Test['TestResult']
        # Match complete count values, not identifier prefixes or 32-digit compact GUIDs.
        $integerCount = '(?:[0-9]{1,19}|[0-9]{1,3}(?:,[0-9]{3}){1,6})'
        foreach ($label in $Counts.Keys) {
            $number = ([long]$Counts[$label]).ToString([cultureinfo]::InvariantCulture)
            $escaped = [regex]::Escape($label)
            $text = [regex]::Replace($text, "(?im)(^\|[ \t]*$escaped[ \t]*\|[ \t]*)$integerCount(?=[ \t]*\|)", "`${1}$number")
            $text = [regex]::Replace($text, "(?im)(^[ \t]*-[ \t]+\*\*$escaped`:\*\*[ \t]*)$integerCount(?=[ \t]*\r?$)", "`${1}$number")
        }
        $Test['TestResult'] = $text
    }

    $summary = $Report['TestResultSummary']
    if ($summary -isnot [System.Collections.IDictionary]) {
        $summary = [System.Management.Automation.OrderedHashtable]::new()
        $Report['TestResultSummary'] = $summary
    }
    foreach ($pillar in 'Identity', 'Devices', 'Network', 'Data', 'Infrastructure', 'SecOps', 'AI') {
        $passed = 0
        $total = 0
        foreach ($test in $Report['Tests']) {
            if ($test -isnot [System.Collections.IDictionary] -or $pillar -notin @($test['TestPillar'])) { continue }
            if ($test['TestStatus'] -eq 'Passed') { $passed++ }
            if ($test['TestStatus'] -notin 'Skipped', 'Planned') { $total++ }
        }
        foreach ($metric in @{ "${pillar}Passed" = $passed; "${pillar}Total" = $total }.GetEnumerator()) {
            if ($summary.Contains($metric.Key) -and (& $isNumber $summary[$metric.Key])) {
                & $setNumbers $summary @{ $metric.Key = $metric.Value }
            }
            else {
                $summary[$metric.Key] = $metric.Value
            }
        }
    }

    $tenantInfo = $Report['TenantInfo']
    if ($tenantInfo -isnot [System.Collections.IDictionary]) { return ,$Report }

    # UserCount excludes guests; authentication partitions include both populations.
    $members = 1000
    $guests = 120
    $deviceTotal = 300
    $managedTotal = 250
    $compliantTotal = 208
    & $setNumbers $tenantInfo['TenantOverview'] @{
        UserCount = $members; GuestCount = $guests; GroupCount = 64; ApplicationCount = 48
        DeviceCount = $deviceTotal; ManagedDeviceCount = $managedTotal
    }

    $devices = $tenantInfo['DeviceOverview']
    if ($devices -is [System.Collections.IDictionary]) {
        $allOs = @{ windowsCount = 180; macOSCount = 40; iosCount = 45; androidCount = 25; linuxCount = 10 }
        $managedOs = @{
            windowsCount = 160; macOSCount = 35; iosCount = 35; androidCount = 20; linuxCount = 0
            windowsMobileCount = 0; unknownCount = 0; androidDedicatedCount = 0; androidDeviceAdminCount = 0
            androidFullyManagedCount = 8; androidWorkProfileCount = 8; androidCorporateWorkProfileCount = 4
            configMgrDeviceCount = 0; aospUserlessCount = 0; aospUserAssociatedCount = 0; chromeOSCount = 0
        }
        $deviceSummary = $devices['DeviceSummary']
        if ($deviceSummary -is [System.Collections.IDictionary]) {
            & $setNumbers $deviceSummary @{ totalDevices = $deviceTotal }
            & $setNumbers $deviceSummary['deviceOperatingSystemSummary'] $allOs
            & $setNumbers $deviceSummary['mdeSensorInstalledOperatingSystemSummary'] @{
                windowsCount = 150; macOSCount = 30; iosCount = 25; androidCount = 15; linuxCount = 6
            }
            & $setDescription $deviceSummary 'Synthetic devices and Microsoft Defender for Endpoint sensor coverage by operating system.'
        }
        $managed = $devices['ManagedDevices']
        if ($managed -is [System.Collections.IDictionary]) {
            & $setNumbers $managed @{
                enrolledDeviceCount = $managedTotal; mdmEnrolledCount = $managedTotal; dualEnrolledDeviceCount = 0
                desktopCount = 195; mobileCount = 55; totalCount = $managedTotal
            }
            & $setNumbers $managed['deviceOperatingSystemSummary'] $managedOs
            & $setNumbers $managed['deviceExchangeAccessStateSummary'] @{
                allowedDeviceCount = 210; blockedDeviceCount = 15; quarantinedDeviceCount = 5
                unknownDeviceCount = 10; unavailableDeviceCount = 10
            }
        }
        & $setNumbers $devices['DeviceCompliance'] @{
            compliantDeviceCount = $compliantTotal; nonCompliantDeviceCount = ($deviceTotal - $compliantTotal)
            inGracePeriodCount = 0; configManagerCount = 0; unknownDeviceCount = 0; notApplicableDeviceCount = 0
            remediatedDeviceCount = 0; errorDeviceCount = 0; conflictDeviceCount = 0
        }
        & $setNumbers $devices['DeviceOwnership'] @{ corporateCount = 210; personalCount = 40 }
        & $setNumbers $devices['DeviceAntivirusProtection'] @{ protectedDeviceCount = 180 }
        $desktop = $devices['DesktopDevicesSummary']
        & $setNumbers $desktop @{ totalDevices = 220; entrajoined = 100; entrahybridjoined = 50; entrareigstered = 30 }
        & $setFlow $desktop ([ordered]@{
            'Desktop devices' = [ordered]@{ Windows = 180; macOS = 40 }
            Windows = [ordered]@{ 'Entra joined' = 100; 'Entra registered' = 30; 'Entra hybrid joined' = 50 }
            'Entra joined' = [ordered]@{ Compliant = 90; 'Non-compliant' = 5; Unmanaged = 5 }
            'Entra hybrid joined' = [ordered]@{ Compliant = 40; 'Non-compliant' = 5; Unmanaged = 5 }
            'Entra registered' = [ordered]@{ Compliant = 10; 'Non-compliant' = 10; Unmanaged = 10 }
            macOS = [ordered]@{ Compliant = 28; 'Non-compliant' = 7; Unmanaged = 5 }
        })
        & $setDescription $desktop 'Synthetic desktop devices by operating system, join type, and compliance status.'
        $mobile = $devices['MobileSummary']
        & $setNumbers $mobile @{ totalDevices = 70 }
        & $setFlow $mobile ([ordered]@{
            'Mobile devices' = [ordered]@{ Android = 25; iOS = 45 }
            Android = [ordered]@{ Compliant = 15; 'Non-compliant' = 10 }
            iOS = [ordered]@{ Compliant = 25; 'Non-compliant' = 20 }
        })
        & $setDescription $mobile 'Synthetic mobile devices by operating system and compliance status.'
    }

    foreach ($name in 'OverviewAuthMethodsAllUsers', 'OverviewAuthMethodsPrivilegedUsers') {
        $auth = $tenantInfo[$name]
        $privileged = $name -eq 'OverviewAuthMethodsPrivilegedUsers'
        $single = if ($privileged) { 1 } else { 80 }
        $phone = if ($privileged) { 2 } else { 160 }
        $authenticator = if ($privileged) { 5 } else { 320 }
        $passkey = if ($privileged) { 8 } else { 220 }
        $whfb = if ($privileged) { 8 } else { $members + $guests - $single - $phone - $authenticator - $passkey }
        & $setFlow $auth ([ordered]@{
            Users = [ordered]@{ 'Single factor' = $single; Phishable = ($phone + $authenticator); 'Phish resistant' = ($passkey + $whfb) }
            Phishable = [ordered]@{ Phone = $phone; Authenticator = $authenticator }
            'Phish resistant' = [ordered]@{ Passkey = $passkey; WHfB = $whfb }
        })
        $description = if ($privileged) {
            'Strongest authentication method registered by synthetic privileged users.'
        }
        else {
            'Strongest authentication method registered by synthetic member and guest users.'
        }
        & $setDescription $auth $description
    }
    & $setFlow $tenantInfo['OverviewCaMfaAllUsers'] ([ordered]@{
        'User sign in' = [ordered]@{ 'No CA applied' = 480; 'CA applied' = 1920 }
        'CA applied' = [ordered]@{ 'No MFA' = 120; MFA = 1800 }
    })
    & $setDescription $tenantInfo['OverviewCaMfaAllUsers'] 'Synthetic successful interactive sign-ins by Conditional Access and multifactor enforcement.'
    & $setFlow $tenantInfo['OverviewCaDevicesAllUsers'] ([ordered]@{
        'User sign in' = [ordered]@{ Unmanaged = 480; Managed = 1920 }
        Managed = [ordered]@{ 'Non-compliant' = 240; Compliant = 1680 }
    })
    & $setDescription $tenantInfo['OverviewCaDevicesAllUsers'] 'Synthetic successful interactive sign-ins by device management and compliance status.'

    $privateAccess = $tenantInfo['OverviewPrivateAccess']
    if ($privateAccess -is [System.Collections.IDictionary]) {
        $appCount = if ((& $isNumber $privateAccess['applicationCount']) -and $privateAccess['applicationCount'] -eq 0) { 0 } else { 12 }
        $segmentation = & $getGateStatus $privateAccess '25395'
        $authentication = & $getGateStatus $privateAccess '25396'
        $administration = & $getGateStatus $privateAccess '25384'
        $broad = 0
        $segmentationReview = 0
        $segmentationUnavailable = 0
        switch ($segmentation) {
            'Passed' { }
            'Failed' { $broad = [Math]::Min(4, $appCount) }
            'Investigate' { $segmentationReview = [Math]::Min(3, $appCount) }
            default { $segmentationUnavailable = $appCount }
        }
        if ($privateAccess['populationMismatch'] -eq $true -and $segmentation -ne 'Unavailable' -and $appCount -gt 0) {
            $segmentationUnavailable = 1
        }
        $leastPrivilege = $appCount - $broad - $segmentationReview - $segmentationUnavailable
        $passwordOnly = 0
        $authenticationReview = 0
        $authenticationUnavailable = 0
        switch ($authentication) {
            'Passed' { }
            'Failed' { $passwordOnly = [Math]::Min(3, $leastPrivilege) }
            'Investigate' { $authenticationReview = [Math]::Min(2, $leastPrivilege) }
            default { $authenticationUnavailable = $leastPrivilege }
        }
        $strongAuth = $leastPrivilege - $passwordOnly - $authenticationReview - $authenticationUnavailable
        $tenantWide = 0
        $scopedRisk = 0
        $scopedSafe = 0
        if ($administration -ne 'Unavailable') {
            $scopedSafe = 5
            if ($privateAccess['adminAtRisk'] -eq $true) {
                $tenantWide = 2
                $scopedRisk = 1
            }
        }
        & $setNumbers $privateAccess @{ applicationCount = $appCount; tenantWideAdmin = $tenantWide; scopedAdminAtRisk = $scopedRisk }
        & $setFlow $privateAccess ([ordered]@{
            'Private Access apps' = [ordered]@{
                'Broad segments - at-risk' = $broad; 'Segmentation manual review' = $segmentationReview
                'Segmentation unavailable' = $segmentationUnavailable; 'Least-privilege segments' = $leastPrivilege
            }
            'Least-privilege segments' = [ordered]@{
                'Password-only - at-risk' = $passwordOnly; 'Authentication manual review' = $authenticationReview
                'Authentication unavailable' = $authenticationUnavailable; 'Strong auth - Zero Trust' = $strongAuth
            }
            'Application Administrator assignments' = [ordered]@{
                'Tenant-wide admin - at-risk' = $tenantWide; 'App-scoped admin - at-risk' = $scopedRisk
                'App-scoped admin - Zero Trust' = $scopedSafe; 'Administration unavailable' = [int]($administration -eq 'Unavailable')
            }
        })
        & $setDescription $privateAccess 'Synthetic Private Access applications by segmentation and authentication posture. Administration uses a separate assignment population. Gate verdicts, unavailable stages, and population mismatches retain the assessment findings.'
        $unprotectedApps = if ($authentication -eq 'Failed') { [Math]::Min(3, $appCount) } else { 0 }
        $reviewApps = if ($authentication -eq 'Investigate') { [Math]::Min(2, $appCount) } else { 0 }
        $protectedApps = $appCount - $unprotectedApps - $reviewApps
        $phishingResistantApps = [int][Math]::Floor($protectedApps * 2 / 3)
        $appsWithoutCsa = [Math]::Min($segmentationReview, $appCount)
        $filterPolicies = if ($appCount -gt 0) { 2 } else { 0 }
        foreach ($test in $Report['Tests']) {
            if ($test -isnot [System.Collections.IDictionary]) { continue }
            switch ([string]$test['TestId']) {
                '25395' {
                    & $setMarkdownCounts $test @{
                        'Total Private Access apps' = $appCount; 'Apps with broad segments' = $broad
                        'Apps with CSA assigned' = ($appCount - $appsWithoutCsa); 'Apps without CSA' = $appsWithoutCsa
                        'CA policies using applicationFilter' = $filterPolicies
                    }
                }
                '25396' {
                    & $setMarkdownCounts $test @{
                        'Total Private Access Apps' = $appCount; 'Apps with Phishing-Resistant MFA' = $phishingResistantApps
                        'Apps with Passwordless MFA' = ($protectedApps - $phishingResistantApps); 'Apps with MFA (baseline)' = 0
                        'Apps without Strong Auth' = $unprotectedApps; 'Apps Requiring Manual Review' = $reviewApps
                        'Apps without CSAs' = $appsWithoutCsa; 'CA Policies using applicationFilter' = $filterPolicies
                    }
                }
                '25384' {
                    & $setMarkdownCounts $test @{
                        'Total Assignments' = ($tenantWide + $scopedRisk + $scopedSafe)
                        'Tenant-Wide Assignments' = $tenantWide; 'Scoped Assignments' = ($scopedRisk + $scopedSafe)
                        'Problematic Assignments' = $scopedRisk
                    }
                }
            }
        }
    }

    $circuit = $tenantInfo['OverviewM365ProtectionCircuit']
    if ($circuit -is [System.Collections.IDictionary]) {
        $total = if ($circuit['countsAvailable'] -eq $true) { $deviceTotal } else { 100 }
        $acquisition = & $getGateStatus $circuit '25376'
        $enforcement = & $getGateStatus $circuit '25379'
        $acquired = if ($acquisition -eq 'Passed') {
            if ($circuit['countsAvailable'] -eq $true) { 240 } else { $total }
        }
        else { 0 }
        $circuitFlows = [ordered]@{
            'Total M365 traffic' = [ordered]@{
                'Unprotected - not acquired' = 0; 'Acquired via Global Secure Access' = $acquired
                'Acquisition needs review' = 0; 'Acquisition unavailable' = 0
            }
            'Acquired via Global Secure Access' = [ordered]@{
                'Enforced - compliant network' = 0; 'Acquired but not enforced' = 0
                'Acquired, enforcement needs review' = 0; 'Enforcement unavailable' = 0
            }
        }
        $acquisitionTarget = switch ($acquisition) {
            'Passed' { 'Unprotected - not acquired' }
            'Failed' { 'Unprotected - not acquired' }
            'Investigate' { 'Acquisition needs review' }
            default { 'Acquisition unavailable' }
        }
        $circuitFlows['Total M365 traffic'][$acquisitionTarget] = $total - $acquired
        $enforcementTarget = switch ($enforcement) {
            'Passed' { 'Enforced - compliant network' }
            'Failed' { 'Acquired but not enforced' }
            'Investigate' { 'Acquired, enforcement needs review' }
            default { 'Enforcement unavailable' }
        }
        $circuitFlows['Acquired via Global Secure Access'][$enforcementTarget] = $acquired
        & $setNumbers $circuit @{ totalDevices = $total }
        & $setFlow $circuit $circuitFlows
        $description = if ($circuit['countsAvailable'] -eq $true) {
            'Synthetic device population sizes the Microsoft 365 acquisition and enforcement circuit. Stage verdicts and unavailable stages retain the assessment findings.'
        }
        else {
            'Device counts remain unavailable. The Microsoft 365 protection circuit uses a normalized width of 100 and retains the assessment stage verdicts.'
        }
        & $setDescription $circuit $description
        if ($circuit['countsAvailable'] -eq $true) {
            foreach ($test in $Report['Tests']) {
                if ($test -is [System.Collections.IDictionary] -and $test['TestId'] -eq '25376') {
                    & $setMarkdownCounts $test @{
                        'Total Devices' = $total; 'Active Devices' = $acquired; 'Inactive Devices' = ($total - $acquired)
                    }
                }
            }
        }
    }

    $dlp = $tenantInfo['DlpWorkloadCoverage']
    if ($dlp -is [System.Collections.IDictionary]) {
        $workloads = [ordered]@{
            exchangePolicyCount = 4; sharePointPolicyCount = 3; oneDrivePolicyCount = 3
            teamsPolicyCount = 2; endpointPolicyCount = 2; copilotPolicyCount = 1
        }
        $covered = 0
        $available = $true
        foreach ($key in $workloads.Keys) {
            if (-not (& $isNumber $dlp[$key])) { $available = $false; continue }
            $value = if ($dlp[$key] -gt 0) { $workloads[$key] } else { 0 }
            & $setNumbers $dlp @{ $key = $value }
            if ($value -gt 0) { $covered++ }
        }
        if ($available) { & $setNumbers $dlp @{ coveredWorkloadCount = $covered } }
        & $setDescription $dlp 'Synthetic policy counts by workload. Uncovered workloads and unavailable data retain their original meaning.'
    }
    $labels = $tenantInfo['SensitivityLabelProtection']
    if ($labels -is [System.Collections.IDictionary]) {
        $categories = [ordered]@{
            classificationOnlyCount = 3; visualMarkingOnlyCount = 2; encryptionCount = 5; encryptionDkeCount = 1
        }
        $total = 0
        $available = $true
        foreach ($key in @($categories.Keys)) {
            if (-not (& $isNumber $labels[$key])) { $available = $false; continue }
            $categories[$key] = if ($labels[$key] -gt 0) { $categories[$key] } else { 0 }
            & $setNumbers $labels @{ $key = $categories[$key] }
            $total += $categories[$key]
        }
        if ($available) {
            & $setNumbers $labels @{ totalLabelCount = $total }
            $source = "$total labels"
            $targets = [ordered]@{
                'Classification only' = $categories['classificationOnlyCount']
                'Visual marking only' = $categories['visualMarkingOnlyCount']
                Encryption = $categories['encryptionCount']; 'Encryption + DKE' = $categories['encryptionDkeCount']
            }
            foreach ($node in $labels['nodes']) {
                if ($node -is [System.Collections.IDictionary] -and $targets.Contains([string]$node['target']) -and
                    $node['source'] -match '^\d[\d,. ]* labels$') {
                    $node['source'] = $source
                }
            }
            & $setFlow $labels @{ $source = $targets }
        }
        & $setDescription $labels 'Strongest protection applied by synthetic sensitivity labels. Empty protection categories remain empty.'
    }

    $scores = $tenantInfo['OverviewCloudSecureScore']
    $allScores = [System.Collections.Generic.List[object]]::new()
    $providerScores = [System.Collections.Generic.List[object]]::new()
    $providerPercentages = @{ AZURE = 73; AWS = 62; GCP = 48 }
    $unknownProviders = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($score in $scores) {
        if ($score -isnot [System.Collections.IDictionary] -or
            -not (& $isNumber $score['max']) -or -not (& $isNumber $score['current']) -or
            -not (& $isNumber $score['percentage'])) { continue }
        if ($score['max'] -gt 0) {
            if ($score['environment'] -isnot [string] -or [string]::IsNullOrWhiteSpace($score['environment'])) {
                throw 'An available cloud secure score requires a public environment name.'
            }
            $provider = $score['environment'].Trim().ToUpperInvariant()
            if ($provider -eq 'ALL') { $allScores.Add($score) }
            else {
                $providerScores.Add([pscustomobject]@{ Score = $score; Provider = $provider; Percentage = 0; Weight = 1 })
                if (-not $providerPercentages.ContainsKey($provider)) { $null = $unknownProviders.Add($provider) }
            }
        }
        else {
            & $setNumbers $score @{ current = 0; percentage = 0 }
        }
        & $setDescription $score 'Synthetic secure score for this environment.'
    }

    $scorePool = @(1..99 | Where-Object { $_ % 10 -ne 0 -and $_ -notin 73, 62, 48, 61 })
    if ($unknownProviders.Count -gt $scorePool.Count) {
        throw 'Too many distinct cloud environments for distinct non-round synthetic secure scores.'
    }
    $usedPercentages = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($percentage in 73, 62, 48, 61) { $null = $usedPercentages.Add($percentage) }
    $providerNames = [string[]]@($unknownProviders)
    [Array]::Sort($providerNames, [StringComparer]::Ordinal)
    foreach ($provider in $providerNames) {
        $hash = [System.Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($provider))
        $index = [Convert]::ToUInt32([Convert]::ToHexString($hash).Substring(0, 8), 16) % $scorePool.Count
        while ($usedPercentages.Contains($scorePool[$index])) { $index = ($index + 1) % $scorePool.Count }
        $providerPercentages[$provider] = $scorePool[$index]
        $null = $usedPercentages.Add($scorePool[$index])
    }
    foreach ($model in $providerScores) { $model.Percentage = $providerPercentages[$model.Provider] }

    $getScorePopulation = {
        $population = [pscustomobject]@{
            Count = $providerScores.Count
            Total = [long]0
            Minimum = 100
            Maximum = 0
            Percentages = [System.Collections.Generic.HashSet[int]]::new()
        }
        foreach ($model in $providerScores) {
            $population.Total += $model.Percentage
            $population.Minimum = [Math]::Min($population.Minimum, $model.Percentage)
            $population.Maximum = [Math]::Max($population.Maximum, $model.Percentage)
            $null = $population.Percentages.Add($model.Percentage)
        }
        $population
    }
    $getAggregateCandidates = {
        param($Population)
        1..99 | Where-Object {
            $_ -gt $Population.Minimum -and $_ -lt $Population.Maximum -and
            $_ % 10 -ne 0 -and -not $Population.Percentages.Contains($_)
        }
    }
    $aggregateCurrent = 61
    $aggregateMaximum = 100
    $aggregatePercentage = 61
    if ($providerScores.Count -gt 0) {
        $population = & $getScorePopulation
        if ($population.Minimum -eq $population.Maximum) {
            $aggregatePercentage = $population.Minimum
        }
        else {
            $candidates = @(& $getAggregateCandidates $population)
            if ($candidates.Count -eq 0 -and $providerNames.Count -gt 0) {
                # Leave a whole-percent gap when hashed provider scores occupy adjacent values.
                $replacement = @($scorePool | Where-Object { -not $population.Percentages.Contains($_) } |
                    Sort-Object @{ Expression = { [Math]::Abs($_ * $population.Count - $population.Total) }; Descending = $true }, @{ Expression = { $_ } })
                if ($replacement.Count -gt 0) {
                    foreach ($model in $providerScores) {
                        if ($model.Provider -eq $providerNames[0]) { $model.Percentage = $replacement[0] }
                    }
                    $population = & $getScorePopulation
                    $candidates = @(& $getAggregateCandidates $population)
                }
            }
            if ($candidates.Count -eq 0) {
                throw 'Cloud secure scores cannot form a distinct non-round whole-percent aggregate.'
            }
            $aggregatePercentage = @($candidates |
                Sort-Object @{ Expression = { [Math]::Abs($_ * $population.Count - $population.Total) } }, @{ Expression = { $_ } })[0]

            # Integer capacity weights make the selected aggregate exact without rounding its ratio.
            $delta = $population.Total - $population.Count * $aggregatePercentage
            if ($delta -ne 0) {
                $baseWeight = if ($delta -gt 0) {
                    $aggregatePercentage - $population.Minimum
                }
                else {
                    $population.Maximum - $aggregatePercentage
                }
                $extraWeight = [Math]::Abs($delta)
                $divisor = $baseWeight
                $remainder = $extraWeight
                while ($remainder -ne 0) {
                    $next = $divisor % $remainder
                    $divisor = $remainder
                    $remainder = $next
                }
                $adjusted = $false
                foreach ($model in $providerScores) {
                    $model.Weight = [long]($baseWeight / $divisor)
                    if (-not $adjusted -and (
                        ($delta -gt 0 -and $model.Percentage -eq $population.Minimum) -or
                        ($delta -lt 0 -and $model.Percentage -eq $population.Maximum)
                    )) {
                        $model.Weight += [long]($extraWeight / $divisor)
                        $adjusted = $true
                    }
                }
            }
        }
        $aggregateCurrent = [long]0
        $aggregateMaximum = [long]0
        foreach ($model in $providerScores) {
            $current = $model.Percentage * $model.Weight
            $maximum = 100 * $model.Weight
            & $setNumbers $model.Score @{ current = $current; max = $maximum; percentage = $model.Percentage }
            $aggregateCurrent += $current
            $aggregateMaximum += $maximum
        }
    }
    foreach ($score in $allScores) {
        & $setNumbers $score @{ current = $aggregateCurrent; max = $aggregateMaximum; percentage = $aggregatePercentage }
    }

    $ownership = $tenantInfo['AgentOwnershipDistribution']
    $agentTotal = 17
    if ($ownership -is [System.Collections.IDictionary]) {
        $buckets = [ordered]@{ ownerAndSponsor = 8; ownerOnly = 4; sponsorOnly = 3; neither = 2 }
        $agents = $ownership['agents']
        $usedNames = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        if ($agents -is [System.Collections.IDictionary]) {
            foreach ($bucket in $buckets.Keys) {
                foreach ($entry in $agents[$bucket]) {
                    if ($entry -is [System.Collections.IDictionary] -and $entry['displayName'] -is [string]) {
                        $null = $usedNames.Add($entry['displayName'])
                    }
                }
            }
        }
        $needsPadding = $false
        foreach ($bucket in $buckets.Keys) {
            if ($agents -is [System.Collections.IDictionary] -and $agents[$bucket] -is [System.Collections.IList] -and
                (& $isNumber $ownership[$bucket]) -and $agents[$bucket].Count -lt $buckets[$bucket]) {
                $needsPadding = $true
                break
            }
        }
        if ($needsPadding) {
            # Aliases in findings and other overviews also belong to existing identity mappings.
            $reserveAgentNames = {
                param($Value)
                if ($Value -is [string]) {
                    foreach ($match in [regex]::Matches($Value, '\bVezuni Ralovi [0-9]{5,}\b', 'IgnoreCase')) {
                        $null = $usedNames.Add($match.Value)
                    }
                }
                elseif ($Value -is [System.Collections.IDictionary]) {
                    foreach ($key in $Value.Keys) {
                        & $reserveAgentNames $key
                        & $reserveAgentNames $Value[$key]
                    }
                }
                elseif ($Value -is [System.Collections.IList]) {
                    foreach ($entry in $Value) { & $reserveAgentNames $entry }
                }
            }
            & $reserveAgentNames $Report
        }
        $sequence = 1
        $agentTotal = 0
        foreach ($bucket in $buckets.Keys) {
            if ($agents -is [System.Collections.IDictionary] -and $agents[$bucket] -is [System.Collections.IList] -and
                (& $isNumber $ownership[$bucket])) {
                $entries = [System.Collections.Generic.List[object]]::new()
                foreach ($entry in $agents[$bucket]) {
                    if ($entries.Count -ge $buckets[$bucket]) { break }
                    $entries.Add($entry)
                }
                while ($entries.Count -lt $buckets[$bucket]) {
                    do {
                        $name = 'Vezuni Ralovi {0:D5}' -f $sequence
                        $sequence++
                    } while (-not $usedNames.Add($name))
                    $entries.Add([System.Management.Automation.OrderedHashtable]::new(
                        [ordered]@{ displayName = $name; accountEnabled = $true }
                    ))
                }
                $agents[$bucket] = $entries.ToArray()
                & $setNumbers $ownership @{ $bucket = $entries.Count }
            }
            else {
                & $setNumbers $ownership @{ $bucket = $buckets[$bucket] }
            }
            if (& $isNumber $ownership[$bucket]) { $agentTotal += [int]$ownership[$bucket] }
        }
        if ((& $isNumber $ownership['skippedCount']) -and $ownership['skippedCount'] -gt 0) {
            & $setNumbers $ownership @{ skippedCount = 2 }
        }
        & $setDescription $ownership 'Synthetic agent ownership and effective sponsorship. Bucket counts match their available anonymized entity lists.'
    }
    # These twelve distinct demo human accounts can each use several agents.
    $activeHumanUsers = 12
    & $setNumbers $tenantInfo['AgentOverview'] @{ TotalAgents = $agentTotal; ActiveUsers = $activeHumanUsers }
    & $setDescription $tenantInfo['AgentOverview'] 'Synthetic agent population and distinct human users of agents.'

    return ,$Report
}
