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
    # National cloud (GCC High, DoD) tenants are skipped.
    if ((Get-MgContext).Environment -ne 'Global') {
        Write-PSFMessage 'The Attack Simulation Training Graph API is not available outside the Global cloud — skipping.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable `
            -Result 'The Attack Simulation Training Graph API is only available in the Global cloud. This check is skipped for national cloud tenants (GCC High, DoD, and other sovereign environments).'
        return
    }

    $activity    = 'Checking Attack Simulation Training configuration'
    $testTitle   = 'Attack Simulation Training is configured and a baseline simulation has been run in the last 12 months'
    $cutoffDate  = (Get-Date).ToUniversalTime().AddDays(-365)

    # Q1: Enumerate all attack simulations and filter in memory.
    # Note: the beta API does not reliably support $filter on launchDateTime — fetching
    # all simulations and applying the 365-day window in memory avoids silent empty results.
    # -DisablePaging issues a single request; items are unwrapped from the .value property.
    Write-ZtProgress -Activity $activity -Status 'Querying attack simulations'
    $allSimulations   = @()
    $simulationsError = $null
    try {
        $rawSimulations = Invoke-ZtGraphRequest -RelativeUri 'security/attackSimulation/simulations' -ApiVersion beta -DisablePaging -ErrorAction Stop
        # Guard against $null response or missing .value to avoid @($null) producing a single-null-element array.
        $allSimulations = if ($null -ne $rawSimulations -and $null -ne $rawSimulations.value) { @($rawSimulations.value) } else { @() }
    }
    catch {
        $simulationsError = $_
        Write-PSFMessage "Failed to query attack simulations: $_" -Tag Test -Level Warning
    }

    # Restrict the working set to simulations launched within the 365-day assessment window.
    $simulations = @($allSimulations | Where-Object {
        $null -ne $_.launchDateTime -and [datetime]$_.launchDateTime -ge $cutoffDate
    })

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
    # Per spec: authorization errors (HTTP 401/403) signal MDO P2 is not licensed → Skip.
    # Any other error means the state cannot be determined → Investigate.
    if ($simulationsError) {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $simulationsError
        if ($httpStatus -in 401, 403) {
            Add-ZtTestResultDetail -SkippedBecause NotApplicable `
                -Result "The Attack Simulation Training API returned an authorization error (HTTP $httpStatus). Microsoft Defender for Office 365 Plan 2 (THREAT_INTELLIGENCE) is likely not licensed for this tenant."
        }
        else {
            $params = @{
                TestId       = '41036'
                Title        = $testTitle
                Status       = $false
                Result       = "⚠️ Microsoft Graph returned an unexpected error (HTTP $httpStatus) while querying attack simulations. Ensure the assessment account has **AttackSimulation.Read.All** permission and re-run."
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        return
    }

    # Identify simulations that completed successfully within the 365-day window.
    $succeededInWindow = @($simulations | Where-Object {
        $_.status -eq 'succeeded' -and
        $null -ne $_.completionDateTime -and
        [datetime]$_.completionDateTime -ge $cutoffDate
    })

    # Check whether at least one simulation automation is active.
    $hasActiveAutomation = (-not $automationsError) -and
        (($automations | Where-Object { $_.status -eq 'active' } | Measure-Object).Count -gt 0)

    # Evaluate in precedence order: Pass → Investigate → Fail.
    # Per spec (PR #1073): an empty authorized result is never Skipped — Skip is reserved for
    # auth errors only. A licensed tenant with zero simulations in the window must Fail.
    if ($succeededInWindow.Count -gt 0 -and $hasActiveAutomation) {
        $passed             = $true
        $testResultMarkdown = "✅ At least one Attack Simulation Training campaign has completed in the last 12 months and a simulation automation is active.`n`n%TestResult%"
    }
    elseif ($simulations.Count -gt 0) {
        # Simulations exist in the window but Pass not met — either a baseline succeeded but no
        # active automation, or no simulation succeeded and all are in non-operational statuses.
        $passed       = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Simulations exist but an active program could not be confirmed — either a baseline simulation succeeded but no simulation automation is **active**, or no simulation succeeded and all are in **draft**, **scheduled**, **failed**, or **canceled** status; manual review is required to confirm whether the program is operating. Review [Attack simulation training](https://security.microsoft.com/attacksimulator).`n`n%TestResult%"
    }
    else {
        # Authorized call returned zero simulations in the 365-day window.
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
        $launchDateMd   = if ($sim.launchDateTime)      { Get-FormattedDate -DateString ([datetime]$sim.launchDateTime).ToString('o') }      else { '—' }
        $completeDateMd = if ($sim.completionDateTime)  { Get-FormattedDate -DateString ([datetime]$sim.completionDateTime).ToString('o') }  else { '—' }
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
