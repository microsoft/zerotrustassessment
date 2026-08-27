<#
.SYNOPSIS
    Attack Simulation Training is configured and a baseline simulation has been run in the last 12 months.

.NOTES
    Test ID: 41036
    Workshop Task: SECOPS-036
    Pillar: SecOps
    Category: Email and collaboration security
    Required permission: AttackSimulation.Read.All
    Supported Clouds: Global only — the Attack Simulation Training Graph API is not available in
    national clouds (GCC High, DoD, or other sovereign environments).
#>

function Test-Assessment-41036 {
    [ZtTest(
        Category           = 'Email and collaboration security',
        CompatibleLicense  = ('THREAT_INTELLIGENCE'),
        ImplementationCost = 'Medium',
        Pillar             = 'SecOps',
        RiskLevel          = 'Medium',
        Service            = ('Graph'),
        SfiPillar          = 'Protect tenants and isolate production systems',
        TenantType         = ('Workforce'),
        TestId             = 41036,
        Title              = 'Attack Simulation Training is configured and a baseline simulation has been run in the last 12 months',
        UserImpact         = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity   = 'Checking Attack Simulation Training configuration'
    $testTitle  = 'Attack Simulation Training is configured and a baseline simulation has been run in the last 12 months'
    $now        = (Get-Date).ToUniversalTime()
    $cutoffDate = $now.AddDays(-365)

    $allSimulations   = @()
    $automations      = @()
    $simulationsError = $null
    $automationsError = $null
    $cloudUnsupported = $false

    # Non-Global cloud: the Graph Attack Simulation API is Global-only. Per spec: unsupported
    # cloud → Investigate (API unreachable), not Skip. Skip is emitted only by the assessment
    # engine's Minimum License gate — the check body never emits it.
    if ((Get-MgContext).Environment -ne 'Global') {
        $cloudUnsupported = $true
        Write-PSFMessage 'The Attack Simulation Training Graph API is not available outside the Global cloud.' -Tag Test -Level VeryVerbose
    }
    else {
        # Q1: Simulations ordered newest-first. Server-side $filter on launchDateTime is
        # unreliable (confirmed: returns empty even for a qualifying simulation on the beta
        # endpoint). Fetch pages until the 395-day boundary covers the 365-day window plus
        # the maximum 30-day simulation duration.
        Write-ZtProgress -Activity $activity -Status 'Querying attack simulations'
        try {
            $simulationPage = Invoke-ZtGraphRequest -RelativeUri 'security/attackSimulation/simulations' -QueryParameters @{ '$orderby' = 'launchDateTime desc' } -Top 50 -ApiVersion beta -DisablePaging -ErrorAction Stop
            while ($simulationPage) {
                $pageSimulations = @($simulationPage.value)
                $allSimulations += $pageSimulations

                $pageBoundaryReached = $false
                if ($pageSimulations.Count -gt 0) {
                    if ($pageSimulations[-1].launchDateTime) {
                        try {
                            $oldestLaunch = [datetime]$pageSimulations[-1].launchDateTime
                            $pageBoundaryReached = $oldestLaunch -lt $cutoffDate.AddDays(-30)
                        }
                        catch {
                            $pageBoundaryReached = $false
                        }
                    }
                }

                if ($pageBoundaryReached -or -not $simulationPage.'@odata.nextLink') {
                    break
                }

                $nextPageUri = [uri]$simulationPage.'@odata.nextLink'
                $nextPageRelativeUri = $nextPageUri.AbsolutePath.TrimStart('/') -replace '^beta/', ''
                if ($nextPageUri.Query) {
                    $nextPageRelativeUri += $nextPageUri.Query
                }
                $simulationPage = Invoke-ZtGraphRequest -RelativeUri $nextPageRelativeUri -ApiVersion beta -DisablePaging -ErrorAction Stop
            }
        }
        catch {
            $simulationsError = $_
            Write-PSFMessage "Failed to query attack simulations: $_" -Tag Test -Level Warning
        }

        # Q2: Simulation automations — paged automatically via @odata.nextLink.
        Write-ZtProgress -Activity $activity -Status 'Querying simulation automations'
        try {
            $automations = @(Invoke-ZtGraphRequest -RelativeUri 'security/attackSimulation/simulationAutomations' -ApiVersion beta -ErrorAction Stop)
        }
        catch {
            $automationsError = $_
            Write-PSFMessage "Failed to query simulation automations: $_" -Tag Test -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed       = $false
    $customStatus = $null

    # Classify each simulation.
    # Baseline       : status == 'succeeded' AND completionDateTime in [cutoffDate, now] (future completionDateTime excluded — running sims carry projected end dates).
    # Recent activity: launchDateTime OR completionDateTime in [cutoffDate, now] but not a baseline.
    # Out of window  : neither date falls in the window.
    # A succeeded simulation with a missing/unparseable completionDateTime is undecidable for recency.
    $classifiedSims                = [System.Collections.Generic.List[PSCustomObject]]::new()
    $hasSucceededMissingCompletion = $false
    $hasUnparseableLaunchDate      = $false

    foreach ($sim in $allSimulations) {
        $launchInWindow     = $false
        $completionInWindow = $false
        $launchParsed       = $null
        $completionParsed   = $null
        $launchValid        = $false
        $completionValid    = $false

        if ($sim.launchDateTime) {
            try {
                $launchParsed   = [datetime]$sim.launchDateTime
                $launchValid    = $true
                $launchInWindow = $launchParsed -ge $cutoffDate -and $launchParsed -le $now
            }
            catch {
                $hasUnparseableLaunchDate = $true
                Write-PSFMessage "Could not parse launchDateTime '$($sim.launchDateTime)' for simulation '$($sim.displayName)'." -Tag Test -Level Warning
            }
        }
        if ($sim.completionDateTime) {
            try {
                $completionParsed   = [datetime]$sim.completionDateTime
                $completionValid    = $true
                $completionInWindow = $completionParsed -ge $cutoffDate -and $completionParsed -le $now
            }
            catch {
                Write-PSFMessage "Could not parse completionDateTime '$($sim.completionDateTime)' for simulation '$($sim.displayName)'." -Tag Test -Level Warning
            }
        }

        if ($sim.status -eq 'succeeded' -and -not $completionValid) {
            $hasSucceededMissingCompletion = $true
        }

        $ztSignal = if ($sim.status -eq 'succeeded' -and $completionInWindow) { 'Baseline' }
                    elseif ($launchInWindow -or $completionInWindow)           { 'Recent activity' }
                    else                                                        { 'Out of window' }

        $classifiedSims.Add([PSCustomObject]@{
            Sim             = $sim
            ZtSignal        = $ztSignal
            LaunchDt        = if ($launchValid)     { $launchParsed }     else { [datetime]::MinValue }
            CompletionDt    = if ($completionValid) { $completionParsed } else { $null }
            LaunchValid     = $launchValid
            CompletionValid = $completionValid
        })
    }

    $hasBaseline            = ($classifiedSims | Where-Object { $_.ZtSignal -eq 'Baseline' }      | Measure-Object).Count -gt 0
    $hasActivityInWindow    = ($classifiedSims | Where-Object { $_.ZtSignal -ne 'Out of window' } | Measure-Object).Count -gt 0
    $runningAutomationCount = ($automations     | Where-Object { $_.status -eq 'running' }        | Measure-Object).Count
    $hasRunningAutomation   = $runningAutomationCount -gt 0

    # Result summary (always emitted, including on error/unsupported cloud).
    $statusCounts    = ($allSimulations | Group-Object status | ForEach-Object { "$($_.Name): $($_.Count)" }) -join ', '
    $cutoffFormatted = Get-FormattedDate -DateString $cutoffDate.ToString('o')
    $summaryCounts   = "Evaluated cutoff: **$cutoffFormatted**. Simulations: **$($allSimulations.Count)**$(if ($statusCounts) { " ($statusCounts)" }). Automations: **$($automations.Count)** ($runningAutomationCount running)."

    if ($cloudUnsupported) {
        $customStatus       = 'Investigate'
        $reason             = 'Unsupported cloud: the Attack Simulation Training Graph API is only available in the Global cloud; it cannot be evaluated for this tenant.'
        $testResultMarkdown = "⚠️ A completed baseline and a running automation could not both be confirmed. $reason Review [Attack simulation training](https://security.microsoft.com/attacksimulator).`n`n$summaryCounts`n`n%TestResult%"
    }
    elseif ($simulationsError -or $automationsError) {
        # Any query error (auth/permission, 404, throttling, or service error)
        # → Investigate immediately. Never Skip, never Fail for errors.
        $errorParts = @()
        if ($simulationsError) {
            $q1Status = Get-ZtHttpStatusCode -ErrorRecord $simulationsError
            $errorParts += "Q1 (simulations) — HTTP $q1Status"
        }
        if ($automationsError) {
            $q2Status = Get-ZtHttpStatusCode -ErrorRecord $automationsError
            $errorParts += "Q2 (automations) — HTTP $q2Status"
        }
        $customStatus       = 'Investigate'
        $reason             = "Query error: $($errorParts -join '; '). Ensure the assessment account has **AttackSimulation.Read.All** permission and re-run."
        $testResultMarkdown = "⚠️ A completed baseline and a running automation could not both be confirmed. $reason Review [Attack simulation training](https://security.microsoft.com/attacksimulator).`n`n$summaryCounts`n`n%TestResult%"
    }
    # Precedence: Pass > Investigate > Fail.
    elseif ($hasBaseline -and $hasRunningAutomation) {
        $passed             = $true
        $testResultMarkdown = "✅ A baseline Attack Simulation Training campaign completed (**succeeded**) within the last 12 months and a simulation automation is configured and running.`n`n$summaryCounts`n`n%TestResult%"
    }
    elseif ($hasUnparseableLaunchDate) {
        $customStatus       = 'Investigate'
        $reason             = 'At least one simulation had an unparseable **launchDateTime** — recency could not be confirmed.'
        $testResultMarkdown = "⚠️ A completed baseline and a running automation could not both be confirmed. $reason Review [Attack simulation training](https://security.microsoft.com/attacksimulator).`n`n$summaryCounts`n`n%TestResult%"
    }
    elseif ($hasBaseline) {
        $customStatus       = 'Investigate'
        $reason             = "A baseline simulation succeeded in the last 12 months but no simulation automation is **running**."
        $testResultMarkdown = "⚠️ A completed baseline and a running automation could not both be confirmed. $reason Review [Attack simulation training](https://security.microsoft.com/attacksimulator).`n`n$summaryCounts`n`n%TestResult%"
    }
    elseif ($hasSucceededMissingCompletion) {
        $customStatus       = 'Investigate'
        $reason             = "A **succeeded** simulation was missing a usable **completionDateTime** — recency could not be confirmed."
        $testResultMarkdown = "⚠️ A completed baseline and a running automation could not both be confirmed. $reason Review [Attack simulation training](https://security.microsoft.com/attacksimulator).`n`n$summaryCounts`n`n%TestResult%"
    }
    elseif ($hasActivityInWindow) {
        $customStatus     = 'Investigate'
        $observedStatuses = ($classifiedSims | Where-Object { $_.ZtSignal -ne 'Out of window' } | ForEach-Object { $_.Sim.status } | Select-Object -Unique | Sort-Object) -join ', '
        $reason = "Simulations exist in the last 12 months but none reached **succeeded** in the window. Observed statuses: **$observedStatuses**."
        if ($hasSucceededMissingCompletion) {
            $reason += ' Additionally, a **succeeded** simulation was missing a usable **completionDateTime** — recency could not be confirmed.'
        }
        $testResultMarkdown = "⚠️ A completed baseline and a running automation could not both be confirmed. $reason Review [Attack simulation training](https://security.microsoft.com/attacksimulator).`n`n$summaryCounts`n`n%TestResult%"
    }
    else {
        $passed             = $false
        $testResultMarkdown = "❌ No Attack Simulation Training simulation has run in the last 12 months; user susceptibility to phishing is unmeasured.`n`n$summaryCounts`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl  = 'https://security.microsoft.com/attacksimulator'
    $maxDisplay = 10

    # Sort: baseline rows first (never truncated), then all remaining rows newest-first
    # (Recent activity and Out of window are not separately grouped — just sorted by launch date).
    $sortedClassified = @($classifiedSims | Sort-Object -Property @(
        @{ Expression = { if ($_.ZtSignal -eq 'Baseline') { 0 } else { 1 } }; Ascending = $true },
        @{ Expression = 'LaunchDt'; Descending = $true }
    ))

    # Baseline rows are never truncated — decisive evidence takes precedence over the 10-row display
    # cap. When more than 10 baselines exist the output intentionally exceeds the stated limit.
    $baselineRows    = @($sortedClassified | Where-Object { $_.ZtSignal -eq 'Baseline' })
    $nonBaselineRows = @($sortedClassified | Where-Object { $_.ZtSignal -ne 'Baseline' })
    $remainingSlots  = [Math]::Max(0, $maxDisplay - $baselineRows.Count)
    $displayRows     = $baselineRows + @($nonBaselineRows | Select-Object -First $remainingSlots)
    $totalCount      = $sortedClassified.Count

    # Table 1 — Simulations
    if ($simulationsError -or $cloudUnsupported) {
        $simTableRows = "| — | — | Simulation data unavailable (query error) | — | — | — | — | — | — |`n"
    }
    elseif ($totalCount -eq 0) {
        $simTableRows = "| — | — | No simulations found in the last 365 days | — | — | — | — | — | — |`n"
    }
    else {
        $simTableRows = ''
        foreach ($entry in $displayRows) {
            $sim            = $entry.Sim
            $ztSignalMd     = Get-SafeMarkdown -Text $entry.ZtSignal
            $simStatusMd    = Get-SafeMarkdown -Text $sim.status
            $nameMd         = Get-SafeMarkdown -Text $sim.displayName
            $techniqueMd    = Get-SafeMarkdown -Text $sim.attackTechnique
            $typeMd         = Get-SafeMarkdown -Text $sim.attackType
            $platformMd     = Get-SafeMarkdown -Text $sim.payloadDeliveryPlatform
            $launchDateMd   = if ($entry.LaunchValid)     { Get-FormattedDate -DateString $entry.LaunchDt.ToString('o') }     else { '—' }
            $completeDateMd = if ($entry.CompletionValid) { Get-FormattedDate -DateString $entry.CompletionDt.ToString('o') } else { '—' }
            $automatedMd    = if ($sim.isAutomated -eq $true) { 'Yes' } else { 'No' }
            $simTableRows  += "| $ztSignalMd | $simStatusMd | $nameMd | $techniqueMd | $typeMd | $platformMd | $launchDateMd | $completeDateMd | $automatedMd |`n"
        }
        if ($totalCount -gt $maxDisplay) {
            $simTableRows += "| ... | ... | ... | ... | ... | ... | ... | ... | ... |`n"
        }
    }

    $preTableLines = if ($totalCount -gt $maxDisplay) {
        "Showing $($displayRows.Count) of $totalCount simulations (baseline always shown). [View all in Microsoft 365 Defender > Email & collaboration > Attack simulation training]($portalUrl)`n`n"
    } else { '' }

    # Table 2 — Simulation automations (always rendered)
    if ($automationsError -or $cloudUnsupported) {
        $autoTableRows = "| Automation data unavailable (query error) | — | — | — |`n"
    }
    elseif ($automations.Count -eq 0) {
        $autoTableRows = "| No simulation automation configured | — | — | — |`n"
    }
    else {
        $autoTableRows = ''
        foreach ($auto in $automations) {
            $autoNameMd   = Get-SafeMarkdown -Text $auto.displayName
            $autoStatusMd = Get-SafeMarkdown -Text $auto.status
            $lastRunMd = '—'
            if ($auto.lastRunDateTime) {
                try { $lastRunMd = Get-FormattedDate -DateString ([datetime]$auto.lastRunDateTime).ToString('o') }
                catch { Write-PSFMessage "Could not parse lastRunDateTime '$($auto.lastRunDateTime)' for automation '$($auto.displayName)'." -Tag Test -Level Warning }
            }
            $nextRunMd = '—'
            if ($auto.nextRunDateTime) {
                try { $nextRunMd = Get-FormattedDate -DateString ([datetime]$auto.nextRunDateTime).ToString('o') }
                catch { Write-PSFMessage "Could not parse nextRunDateTime '$($auto.nextRunDateTime)' for automation '$($auto.displayName)'." -Tag Test -Level Warning }
            }
            $autoTableRows += "| $autoNameMd | $autoStatusMd | $lastRunMd | $nextRunMd |`n"
        }
    }

    $formatTemplate = @'
{0}
## [Attack simulation training]({3})

### Simulations

| ZT signal | Simulation status | Display name | Attack technique | Attack type | Delivery platform | Launch date | Completion date | Automated |
| :-------- | :----------------- | :----------- | :---------------- | :----------- | :----------------- | :----------- | :---------------- | :-------- |
{1}

### Simulation automations

| Automation name | Automation status | Last run | Next run |
| :--------------- | :----------------- | :------- | :------- |
{2}
'@
    $mdInfo = $formatTemplate -f $preTableLines, $simTableRows, $autoTableRows, $portalUrl

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41036'
        Title  = $testTitle
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
