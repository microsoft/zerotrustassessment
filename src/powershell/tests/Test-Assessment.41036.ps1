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

    # The Attack Simulation Training Graph API is published as Global-only.
    # National cloud (GCC High, DoD) tenants are silently skipped.
    if ((Get-MgContext).Environment -ne 'Global') {
        Write-PSFMessage 'The Attack Simulation Training Graph API is not available outside the Global cloud — skipping.' -Tag Test -Level VeryVerbose
        return
    }

    $activity    = 'Checking Attack Simulation Training configuration'
    $testTitle   = 'Attack Simulation Training is configured and a baseline simulation has been run in the last 12 months'
    $windowStart = (Get-Date).AddDays(-365).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

    # Q1: Enumerate simulations launched in the last 365 days.
    Write-ZtProgress -Activity $activity -Status 'Querying attack simulations in the last 12 months'
    $simulations      = @()
    $simulationsError = $null
    try {
        $simulations = @(Invoke-ZtGraphRequest -RelativeUri 'security/attackSimulation/simulations' -ApiVersion beta `
            -Filter "launchDateTime ge $windowStart" -ErrorAction Stop)
    }
    catch {
        $simulationsError = $_
        Write-PSFMessage "Failed to query attack simulations (filtered): $_" -Tag Test -Level Warning
    }

    # If the filtered query succeeded but returned zero results, probe without a filter to
    # distinguish "no simulations in the window" from "MDO P2 not licensed".
    $probeSimulations = $null
    $probeError       = $null
    if (-not $simulationsError -and $simulations.Count -eq 0) {
        Write-ZtProgress -Activity $activity -Status 'Probing attack simulation API for any simulations'
        try {
            $probeSimulations = @(Invoke-ZtGraphRequest -RelativeUri 'security/attackSimulation/simulations' -ApiVersion beta `
                -Top 1 -DisablePaging -ErrorAction Stop)
        }
        catch {
            $probeError = $_
            Write-PSFMessage "Probe query for attack simulations failed: $_" -Tag Test -Level Warning
        }
    }

    # Q2: Enumerate simulation automations to verify an ongoing program.
    Write-ZtProgress -Activity $activity -Status 'Querying simulation automations'
    $automations      = $null
    $automationsError = $null
    try {
        $automations = @(Invoke-ZtGraphRequest -RelativeUri 'security/attackSimulation/simulationAutomations' -ApiVersion beta -ErrorAction Stop)
    }
    catch {
        $automationsError = $_
        Write-PSFMessage "Failed to query simulation automations: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed       = $false
    $customStatus = $null

    # Handle Q1 error.
    if ($simulationsError) {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $simulationsError
        if ($httpStatus -in 401, 403) {
            $q1ErrorMessage = "Microsoft Graph returned HTTP $httpStatus when querying attack simulations. Ensure the **AttackSimulation.Read.All** permission has been consented and re-run."
        }
        else {
            $q1ErrorMessage = "Microsoft Graph returned an unexpected error while querying attack simulations. Ensure the assessment account has **AttackSimulation.Read.All** permission and re-run."
        }
        $params = @{
            TestId       = '41036'
            Title        = $testTitle
            Status       = $false
            Result       = "⚠️ $q1ErrorMessage`n`n%TestResult%"
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # If the filtered query returned zero results, use the probe to determine whether the API is
    # functional. Zero results on both the filtered and unfiltered calls indicates the tenant is
    # not licensed for MDO P2 or Attack Simulation Training is not provisioned.
    if ($simulations.Count -eq 0) {
        if ($null -ne $probeError) {
            $probeStatus = Get-ZtHttpStatusCode -ErrorRecord $probeError
            if ($probeStatus -in 401, 403) {
                # Auth error on probe — spec treats authorization error as "not licensed"; Skip.
                Add-ZtTestResultDetail -SkippedBecause NotApplicable `
                    -Result 'The Attack Simulation Training API returned an authorization error. Microsoft Defender for Office 365 Plan 2 (THREAT_INTELLIGENCE) is likely not licensed or Attack Simulation Training is not yet provisioned for this tenant.'
                return
            }
            # Transient or unexpected probe error — cannot determine license status; return Investigate.
            $params = @{
                TestId       = '41036'
                Title        = $testTitle
                Status       = $false
                Result       = "⚠️ The filtered simulation query returned no results and a follow-up probe also failed unexpectedly (HTTP $probeStatus). Re-run the assessment; if the issue persists verify **AttackSimulation.Read.All** is consented.`n`n%TestResult%"
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
            return
        }
        if ($probeSimulations.Count -eq 0) {
            # Both filtered and unfiltered queries returned empty — likely not licensed for MDO P2.
            Add-ZtTestResultDetail -SkippedBecause NotApplicable `
                -Result 'The Attack Simulation Training API returned no simulations. Microsoft Defender for Office 365 Plan 2 (THREAT_INTELLIGENCE) is likely not licensed or Attack Simulation Training is not yet provisioned for this tenant.'
            return
        }
        # Probe returned data — the API is reachable but no simulations were launched in the last 12 months.
    }

    # Identify simulations that completed successfully within the 365-day window.
    $cutoffDate = (Get-Date).AddDays(-365)
    $succeededInWindow = @($simulations | Where-Object {
        $_.status -eq 'succeeded' -and
        $null -ne $_.completionDateTime -and
        [datetime]$_.completionDateTime -ge $cutoffDate
    })

    # Determine whether all returned simulations are in non-operational states.
    # Spec lists draft, scheduled, failed, canceled; 'excluded' is added as it is also a
    # terminal non-operational simulationStatus value per the Graph resource type definition.
    $nonOperationalStatuses = @('draft', 'scheduled', 'failed', 'canceled', 'excluded')
    $hasOperationalSimulation = ($simulations | Where-Object { $_.status -notin $nonOperationalStatuses } | Measure-Object).Count -gt 0
    $allNonOperational = $simulations.Count -gt 0 -and -not $hasOperationalSimulation

    # Check whether at least one simulation automation is active.
    $hasActiveAutomation = (-not $automationsError) -and
        (($automations | Where-Object { $_.status -eq 'active' } | Measure-Object).Count -gt 0)

    if ($succeededInWindow.Count -gt 0 -and $hasActiveAutomation) {
        $passed             = $true
        $testResultMarkdown = "✅ At least one Attack Simulation Training campaign has completed in the last 12 months and a simulation automation is active.`n`n%TestResult%"
    }
    elseif ($succeededInWindow.Count -gt 0) {
        # Completed simulation exists but no active automation found.
        $passed       = $false
        $customStatus = 'Investigate'
        $automationNote = if ($automationsError) {
            "Simulation automations could not be queried; verify **AttackSimulation.Read.All** is consented."
        }
        else {
            "No active simulation automation was found; confirm an ongoing simulation program is configured."
        }
        $testResultMarkdown = "⚠️ A completed Attack Simulation Training campaign exists in the last 12 months but no active simulation automation was found. $automationNote Review [Attack simulation training](https://security.microsoft.com/attacksimulator) to confirm the program is ongoing.`n`n%TestResult%"
    }
    elseif ($allNonOperational) {
        $passed       = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Simulations exist but are all in **draft**, **scheduled**, **failed**, or **cancelled** status; manual review is required to confirm whether the program is operating. Review [Attack simulation training](https://security.microsoft.com/attacksimulator).`n`n%TestResult%"
    }
    else {
        $passed             = $false
        $testResultMarkdown = "❌ No Attack Simulation Training campaign has completed in the last 12 months; user susceptibility to phishing is unmeasured.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl  = 'https://security.microsoft.com/attacksimulator'
    $maxDisplay = 10
    $totalCount = $simulations.Count

    # Sort: succeeded first, then by launch date descending (most recent first within each status group).
    $statusPriority = @{ succeeded = 0; running = 1; scheduled = 2; draft = 3; failed = 4; canceled = 5; excluded = 6; unknown = 7; unknownFutureValue = 8 }
    $sortedSimulations = @($simulations | Sort-Object -Property @(
        @{ Expression = { if ($null -ne $statusPriority[$_.status]) { $statusPriority[$_.status] } else { 99 } }; Ascending = $true },
        @{ Expression = { $_.launchDateTime }; Descending = $true }
    ))
    $displaySimulations = @($sortedSimulations | Select-Object -First $maxDisplay)

    $tableRows = ''
    foreach ($sim in $displaySimulations) {
        $nameMd         = Get-SafeMarkdown -Text $sim.displayName
        $techniqueMd    = Get-SafeMarkdown -Text $sim.attackTechnique
        $typeMd         = Get-SafeMarkdown -Text $sim.attackType
        $platformMd     = Get-SafeMarkdown -Text $sim.payloadDeliveryPlatform
        $statusMd       = Get-SafeMarkdown -Text $sim.status
        $launchDateMd   = if ($sim.launchDateTime)      { Get-FormattedDate -DateString $sim.launchDateTime }      else { '—' }
        $completeDateMd = if ($sim.completionDateTime)  { Get-FormattedDate -DateString $sim.completionDateTime }  else { '—' }
        $automatedMd    = if ($sim.isAutomated -eq $true) { 'Yes' } else { 'No' }
        $tableRows += "| $nameMd | $techniqueMd | $typeMd | $platformMd | $statusMd | $launchDateMd | $completeDateMd | $automatedMd |`n"
    }

    if ($totalCount -gt $maxDisplay) {
        $tableRows += "| ... | ... | ... | ... | ... | ... | ... | ... |`n"
    }

    $preTableLines = ''
    if ($totalCount -gt $maxDisplay) {
        $preTableLines = "Showing $maxDisplay of $totalCount simulations. [View all in Microsoft 365 Defender > Email & collaboration > Attack simulation training]($portalUrl)`n`n"
    }

    # Only render the table when there is at least one simulation to show.
    if ($totalCount -gt 0) {
        $formatTemplate = @'
{0}
## [Attack simulation training]({2})

| Display name | Attack technique | Attack type | Delivery platform | Status | Launch date | Completion date | Automated |
| :----------- | :--------------- | :---------- | :---------------- | :----- | :---------- | :-------------- | :-------- |
{1}
'@
        $mdInfo = $formatTemplate -f $preTableLines, $tableRows, $portalUrl
    }
    else {
        $mdInfo = ''
    }

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
