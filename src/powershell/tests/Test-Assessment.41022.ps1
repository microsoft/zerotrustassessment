<#
.SYNOPSIS
    Microsoft Defender for Identity security alerts have been triaged and tuned

.DESCRIPTION
    Microsoft Defender for Identity alerts on directory attacks such as Kerberoasting, DCSync, and
    suspicious LDAP enumeration. When the alert backlog is not triaged and tuned, real intrusions are
    missed in the noise and response time stretches past the containment window. Because no Microsoft
    Graph API exposes Defender XDR alert tuning configuration, this check uses classification activity
    over the trailing 30 days as a proxy for tuning discipline: it passes when at least 80% of MDI
    alerts are classified and no alert older than 7 days is still new and unclassified.

.NOTES
    Test ID: 41022
    Workshop Task: SECOPS-022
    Category: Identity threat protection
    Pillar: SecOps
    Required Module: Microsoft.Graph.Authentication
    Required Connection: Connect-ZtAssessment
    Required permission (least privileged): SecurityAlert.Read.All
#>

function Test-Assessment-41022 {
    [ZtTest(
        Category = 'Identity threat protection',
        CompatibleLicense = ('ATA'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41022,
        Title = 'Microsoft Defender for Identity security alerts have been triaged and tuned',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Microsoft Defender for Identity alert triage and tuning'

    # Tunable thresholds (see spec 41022).
    $lookbackDays = 30
    $staleDays = 7
    $minAlertsToEvaluate = 5
    $classificationThreshold = 0.80

    # Microsoft Graph OData $filter does not support a relative-date function like KQL ago(), so the
    # lookback boundaries must be materialized into literal ISO 8601 timestamps at execution time.
    $nowUtc = (Get-Date).ToUniversalTime()
    $cutoff30 = $nowUtc.AddDays(-$lookbackDays).ToString("yyyy-MM-ddTHH:mm:ssZ")
    $cutoff7 = $nowUtc.AddDays(-$staleDays)

    $queryError = $null
    $alerts = @()

    Write-ZtProgress -Activity $activity -Status 'Querying MDI alerts from the last 30 days'

    try {
        # Q1: All MDI alerts created in the lookback window. Only the fields needed to compute the
        # triage aggregates are projected (performance guardrail A.1).
        $filter = "serviceSource eq 'microsoftDefenderForIdentity' and createdDateTime ge $cutoff30"
        $alerts = @(Invoke-ZtGraphRequest `
                -RelativeUri 'security/alerts_v2' `
                -Filter $filter `
                -Select 'id,title,classification,status,createdDateTime' `
                -ApiVersion beta `
                -ErrorAction Stop)
        Write-PSFMessage "Q1 returned $($alerts.Count) MDI alert(s) in the last $lookbackDays days" -Tag Test -Level Debug
    }
    catch {
        $queryError = $_
        Write-PSFMessage "Failed to query MDI alerts: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $title = 'Microsoft Defender for Identity security alerts have been triaged and tuned'

    # Query failure: branch on the HTTP status code so the result is actionable.
    #   401/403 -> permission issue      -> Investigate (prompt for permission checks)
    #   404      -> MDI not onboarded     -> Skipped (NotApplicable)
    #   5xx      -> transient service err -> Investigate (re-run the test)
    #   anything else / no status code    -> Error (surface the raw error in the report)
    if ($queryError) {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $queryError

        if ($httpStatus -in (401, 403)) {
            Write-PSFMessage "Test-Assessment-41022: INVESTIGATE — HTTP $httpStatus from alerts_v2 (permission)" -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -TestId '41022' `
                -Title $title `
                -Status $false -CustomStatus 'Investigate' `
                -Result "⚠️ The Microsoft Defender for Identity alert backlog could not be read because the request was not authorized (HTTP $httpStatus). Verify the caller has the least-privileged Graph permission ``SecurityAlert.Read.All`` (Entra role: Security Reader), then re-run."
            return
        }

        if ($httpStatus -eq 404) {
            Write-PSFMessage 'Test-Assessment-41022: SKIPPED — HTTP 404 from alerts_v2 (MDI not onboarded)' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
            return
        }

        if ($null -ne $httpStatus -and $httpStatus -ge 500 -and $httpStatus -le 599) {
            Write-PSFMessage "Test-Assessment-41022: INVESTIGATE — HTTP $httpStatus from alerts_v2 (transient service error)" -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -TestId '41022' `
                -Title $title `
                -Status $false -CustomStatus 'Investigate' `
                -Result "⚠️ The Microsoft Defender for Identity alert query returned a service error (HTTP $httpStatus). This is typically transient — re-run the test. If it persists, check Microsoft Graph service health."
            return
        }

        # Unexpected failure (no determinable HTTP status, e.g. a network/parse error) — surface it.
        $errorText = $queryError.Exception.Message
        Write-PSFMessage "Test-Assessment-41022: ERROR — unexpected failure querying MDI alerts: $queryError" -Tag Test -Level Warning
        Add-ZtTestResultDetail -TestId '41022' `
            -Title $title `
            -Status $false -CustomStatus 'Error' `
            -Result ("❌ An unexpected error occurred while reading the Microsoft Defender for Identity alert backlog. Error: " + $errorText)
        return
    }

    $totalAlerts = $alerts.Count

    # No alerts in the window: probe whether MDI has ever generated an alert to tell 'not deployed'
    # (Skipped) apart from 'deployed but no recent activity' (Investigate).
    if ($totalAlerts -eq 0) {
        $historicalAlerts = @()
        try {
            # -DisablePaging returns the raw Graph response wrapper (not the results array), so the
            # actual alert(s) live under .value. Unwrap it before counting.
            $probeResponse = Invoke-ZtGraphRequest `
                -RelativeUri 'security/alerts_v2' `
                -Filter "serviceSource eq 'microsoftDefenderForIdentity'" `
                -Select 'id' `
                -Top 1 `
                -DisablePaging `
                -ApiVersion beta `
                -ErrorAction Stop
            $historicalAlerts = @($probeResponse.value)
        }
        catch {
            # Q1 already succeeded, so access and onboarding are confirmed. A probe failure here is
            # therefore unexpected (transient fault or an unusual Graph response), not evidence that
            # MDI is absent — surface it for investigation instead of silently skipping the check.
            $probeError = $_
            Write-PSFMessage "Test-Assessment-41022: INVESTIGATE — MDI existence probe failed after a successful Q1: $probeError" -Tag Test -Level Warning
            Add-ZtTestResultDetail -TestId '41022' `
                -Title $title `
                -Status $false -CustomStatus 'Investigate' `
                -Result ("⚠️ Microsoft Defender for Identity returned no alerts in the last $lookbackDays days, and the follow-up check for any historical alert failed unexpectedly. This is likely transient — re-run the test. Error: " + $probeError.Exception.Message)
            return
        }

        if ($historicalAlerts.Count -eq 0) {
            Write-PSFMessage 'Test-Assessment-41022: SKIPPED — no MDI alerts ever generated (MDI not deployed)' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
            return
        }

        Write-PSFMessage 'Test-Assessment-41022: INVESTIGATE — MDI deployed but no alerts in the lookback window' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -TestId '41022' `
            -Title $title `
            -Status $false -CustomStatus 'Investigate' `
            -Result "⚠️ Fewer than $minAlertsToEvaluate Microsoft Defender for Identity alerts have been generated in the last $lookbackDays days; tuning practice cannot be evaluated."
        return
    }

    # Fewer than the minimum volume needed to meaningfully evaluate the classification ratio.
    if ($totalAlerts -lt $minAlertsToEvaluate) {
        Write-PSFMessage "Test-Assessment-41022: INVESTIGATE — only $totalAlerts MDI alert(s) in the last $lookbackDays days (< $minAlertsToEvaluate)" -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -TestId '41022' `
            -Title $title `
            -Status $false -CustomStatus 'Investigate' `
            -Result "⚠️ Fewer than $minAlertsToEvaluate Microsoft Defender for Identity alerts have been generated in the last $lookbackDays days; tuning practice cannot be evaluated."
        return
    }

    # Q2 (in-memory): classified = one of the three explicit classification values.
    $classifiedValues = @('truePositive', 'falsePositive', 'informationalExpectedActivity')
    $classifiedAlerts = @($alerts | Where-Object { $_.classification -in $classifiedValues })
    $classifiedCount = $classifiedAlerts.Count
    $classificationRatio = $classifiedCount / $totalAlerts

    # Q3 (in-memory): stale = still 'new' AND unclassified ('unknown' or null/empty) AND older than 7 days.
    $staleAlerts = @($alerts | Where-Object {
            $_.status -eq 'new' -and
            ($_.classification -eq 'unknown' -or [string]::IsNullOrEmpty($_.classification)) -and
            ([datetime]$_.createdDateTime -lt $cutoff7)
        })
    $staleCount = $staleAlerts.Count

    $passed = ($classificationRatio -ge $classificationThreshold -and $staleCount -eq 0)

    if ($passed) {
        $testResultMarkdown = "✅ Microsoft Defender for Identity alerts are being triaged consistently in the last $lookbackDays days.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Microsoft Defender for Identity alerts are accumulating untriaged in the last $lookbackDays days; review and classify the backlog.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalLink = 'https://security.microsoft.com/alerts'
    $ratioDisplay = '{0:P0}' -f $classificationRatio
    $statusDisplay = if ($passed) { '✅ Pass' } else { '❌ Fail' }

    # On Fail, surface the alerts-queue portal link before the summary table.
    $preTableLines = ''
    if (-not $passed) {
        $preTableLines = "[Defender XDR > Investigation & response > Alerts]($portalLink)`n`n"
    }

    $formatTemplate = @'

{0}| Total Alerts (last {1} days) | Classified Alerts | Classification Ratio | Stale Unclassified Alerts | Status |
| --------------------------: | ----------------: | :------------------- | ------------------------: | :----- |
| {2} | {3} | {4} | {5} | {6} |
'@

    $mdInfo = $formatTemplate -f $preTableLines, $lookbackDays, $totalAlerts, $classifiedCount, $ratioDisplay, $staleCount, $statusDisplay

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    if ($passed) {
        Write-PSFMessage "Test-Assessment-41022: PASS — $classifiedCount/$totalAlerts classified ($ratioDisplay), $staleCount stale unclassified" -Tag Test -Level VeryVerbose
    }
    else {
        Write-PSFMessage "Test-Assessment-41022: FAIL — $classifiedCount/$totalAlerts classified ($ratioDisplay), $staleCount stale unclassified" -Tag Test -Level VeryVerbose
    }

    Add-ZtTestResultDetail -TestId '41022' `
        -Title $title `
        -Status $passed -Result $testResultMarkdown
}
