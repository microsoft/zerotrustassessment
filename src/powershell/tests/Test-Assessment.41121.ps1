<#
.SYNOPSIS
    Checks that every open Microsoft Defender XDR alert is triaged across all Defender services,
    with no high-severity alert left unassigned or unworked past its triage window.

.NOTES
    Test ID: 41121
    Workshop Task: SECOPS-121
    Pillar: SecOps
    Category: Incident response operations
    Required permission: SecurityAlert.Read.All
#>

function Test-Assessment-41121 {

    [ZtTest(
        Category           = 'Incident response operations',
        CompatibleLicense  = ('WINDEFATP', 'MDE_LITE', 'ATP_ENTERPRISE', 'THREAT_INTELLIGENCE', 'ATA', 'ADALLOM_S_STANDALONE'),
        ImplementationCost = 'Low',
        Pillar             = 'SecOps',
        RiskLevel          = 'High',
        Service            = ('Graph'),
        SfiPillar          = 'Accelerate response and remediation',
        TenantType         = ('Workforce'),
        TestId             = 41121,
        Title              = 'Every open Microsoft Defender XDR alert is triaged across all Defender services, with no high-severity alert left unassigned or unworked past its triage window',
        UserImpact         = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Microsoft Defender XDR open alert triage status'

    $testTitle         = 'Every open Microsoft Defender XDR alert is triaged across all Defender services, with no high-severity alert left unassigned or unworked past its triage window'
    $highWindowHours   = 24
    $mediumWindowHours = 72
    $resolvedCutoff    = (Get-Date).AddDays(-30).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $preferHeaders     = @{ Prefer = 'include-unknown-enum-members' }

    $openAlerts     = $null
    $resolvedAlerts = $null

    # Q1: Enumerate the entire open Defender XDR alert backlog across every service.
    # serviceSource filter is deliberately omitted so results include every onboarded service.
    Write-ZtProgress -Activity $activity -Status 'Querying open Defender XDR alerts'
    try {
        $openAlerts = Invoke-ZtGraphRequest -RelativeUri 'security/alerts_v2' -ApiVersion beta `
            -Filter "status eq 'new' or status eq 'inProgress'" -Top 500 -DisablePaging `
            -Headers $preferHeaders -ErrorAction Stop
    }
    catch {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Failed to retrieve open security alerts (HTTP $httpStatus): $_" -Tag Test -Level Warning
        $msg = if ($httpStatus -in @(401, 403)) {
            '⚠️ **SecurityAlert.Read.All** permission is required to read Defender XDR alerts. Verify the permission is consented and the assessment identity has Security Reader or Security Operator role, then re-run.'
        } elseif ($httpStatus -eq 404) {
            '⚠️ The alerts_v2 endpoint returned 404. Verify that at least one Defender service is onboarded to stream alerts to the alerts_v2 endpoint, then re-run.'
        } else {
            '⚠️ Microsoft Graph returned an unexpected error while querying open Defender XDR alerts. Re-run after 5–10 minutes; file a support ticket if this persists.'
        }
        $params = @{
            TestId       = '41121'
            Title        = $testTitle
            Status       = $false
            Result       = $msg
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q2: Read recently resolved alerts (informational throughput context; does not affect Pass/Fail).
    Write-ZtProgress -Activity $activity -Status 'Querying recently resolved Defender XDR alerts'
    try {
        $resolvedAlerts = Invoke-ZtGraphRequest -RelativeUri 'security/alerts_v2' -ApiVersion beta `
            -Filter "status eq 'resolved' and lastUpdateDateTime ge $resolvedCutoff" -Top 500 -DisablePaging `
            -Headers $preferHeaders -ErrorAction Stop
    }
    catch {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Failed to retrieve resolved security alerts (HTTP $httpStatus): $_" -Tag Test -Level Warning
        $msg = if ($httpStatus -in @(401, 403)) {
            '⚠️ **SecurityAlert.Read.All** permission is required to read Defender XDR alerts. Verify the permission is consented and the assessment identity has Security Reader or Security Operator role, then re-run.'
        } elseif ($httpStatus -eq 404) {
            '⚠️ The alerts_v2 endpoint returned 404 while querying resolved alerts. Verify Defender onboarding and re-run.'
        } else {
            '⚠️ Microsoft Graph returned an unexpected error while querying resolved Defender XDR alerts. Re-run after 5–10 minutes; file a support ticket if this persists.'
        }
        $params = @{
            TestId       = '41121'
            Title        = $testTitle
            Status       = $false
            Result       = $msg
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    # -DisablePaging causes Invoke-ZtGraphRequest to return the raw response envelope; unwrap .value.
    $openAlerts     = @($openAlerts.value)
    $resolvedAlerts = @($resolvedAlerts.value)

    # Disambiguate empty results: both empty = licensed but onboarding cannot be confirmed.
    if ($openAlerts.Count -eq 0 -and $resolvedAlerts.Count -eq 0) {
        $params = @{
            TestId       = '41121'
            Title        = $testTitle
            Status       = $false
            Result       = '⚠️ No open or recently resolved alerts were returned for any Defender service. The tenant is licensed but this may indicate a workload that is not yet onboarded to stream alerts to the alerts_v2 endpoint. Verify Defender onboarding across all expected services and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $now              = Get-Date
    $severityRank     = @{ high = 0; medium = 1; low = 2; informational = 3 }
    $passed           = $true
    $customStatus     = $null
    $testResultMarkdown = $null

    if ($openAlerts.Count -eq 0) {
        # Q1 empty, Q2 non-empty: open queue is genuinely clear.
        $alertBandRows      = @()
        $criticalItems      = @()
        $importantItems     = @()
        $informationalItems = @()
        $acknowledgedItems  = @()
        $testResultMarkdown = "✅ Every open Microsoft Defender XDR alert has been triaged; no alerts are currently open across any Defender service.`n`n%TestResult%"
    }
    else {
        # Classify each open alert into a band. First matching rule wins.
        $alertBandRows = foreach ($alert in $openAlerts) {
            if ([string]::IsNullOrEmpty($alert.createdDateTime)) { continue }
            $created     = [DateTime]$alert.createdDateTime
            $lastUpdated = if (-not [string]::IsNullOrEmpty($alert.lastUpdateDateTime)) { [DateTime]$alert.lastUpdateDateTime } else { $created }
            $ageHours    = [math]::Round(($now - $created).TotalHours, 1)
            $staleHours  = [math]::Round(($now - $lastUpdated).TotalHours, 1)
            $assigned    = -not [string]::IsNullOrWhiteSpace($alert.assignedTo)
            $worked      = $alert.status -eq 'inProgress'
            $benignDisp  = $alert.classification -in @('falsePositive', 'informationalExpectedActivity')

            $band = if ($benignDisp -and $alert.status -ne 'resolved') {
                'Acknowledged'
            }
            elseif ($alert.severity -eq 'high' -and $ageHours -gt $highWindowHours -and (-not $assigned -or $alert.status -eq 'new')) {
                'Critical'
            }
            elseif (
                ($alert.severity -eq 'medium' -and $ageHours -gt $mediumWindowHours -and (-not $assigned -or $alert.status -eq 'new')) -or
                ($alert.severity -eq 'high' -and $assigned -and $worked -and $staleHours -gt $highWindowHours)
            ) {
                'Important'
            }
            else {
                'Informational'
            }

            # Append stale suffix when the alert is in-progress but has not been updated recently.
            $ageDisplay = if ($worked -and $staleHours -gt $highWindowHours) {
                "$ageHours • stale $($staleHours)h"
            }
            else {
                "$ageHours"
            }

            [PSCustomObject]@{
                Band           = $band
                Severity       = $alert.severity
                Title          = $alert.title
                AlertWebUrl    = $alert.alertWebUrl
                ServiceSource  = $alert.serviceSource
                AssignedTo     = $alert.assignedTo
                AgeHours       = $ageHours
                AgeDisplay     = $ageDisplay
                StaleHours     = $staleHours
                IncidentId     = $alert.incidentId
                IncidentWebUrl = $alert.incidentWebUrl
                Status         = $alert.status
            }
        }
        $alertBandRows = @($alertBandRows)

        $criticalItems      = @($alertBandRows | Where-Object { $_.Band -eq 'Critical' })
        $importantItems     = @($alertBandRows | Where-Object { $_.Band -eq 'Important' })
        $informationalItems = @($alertBandRows | Where-Object { $_.Band -eq 'Informational' })
        $acknowledgedItems  = @($alertBandRows | Where-Object { $_.Band -eq 'Acknowledged' })

        $passed = $criticalItems.Count -eq 0

        if ($criticalItems.Count -gt 0) {
            $testResultMarkdown = "❌ One or more high-severity Defender XDR alerts have remained unassigned or unworked (status is **new**) past the configurable triage window (default 24 hours). Review the prioritized backlog; Critical rows are listed first.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "✅ Every high-severity Defender XDR alert across all services has been assigned and is being worked within its triage window; no alert is left untriaged past the configurable threshold.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $alertsPortalUrl    = 'https://security.microsoft.com/alerts'
    $incidentsPortalUrl = 'https://security.microsoft.com/incidents'
    $maxBandRows        = 25

    $section1 = ''
    $section2 = ''
    $section3 = ''

    # ── Section 1: Open alert backlog (Critical, Important, Informational, Acknowledged) ─────

    if ($alertBandRows.Count -gt 0) {
        $critSorted     = @($criticalItems | Sort-Object -Property AgeHours -Descending)
        $importantSorted = @($importantItems | Sort-Object -Property @(
            @{ Expression = { if ($severityRank.ContainsKey($_.Severity)) { $severityRank[$_.Severity] } else { 99 } }; Ascending = $true },
            @{ Expression = 'AgeHours'; Descending = $true }
        ))

        $critDisplay = @($critSorted      | Select-Object -First $maxBandRows)
        $impDisplay  = @($importantSorted | Select-Object -First $maxBandRows)
        $critMore    = [math]::Max(0, $criticalItems.Count - $maxBandRows)
        $impMore     = [math]::Max(0, $importantItems.Count - $maxBandRows)

        $s1Rows = ''

        foreach ($row in $critDisplay) {
            $alertCell    = if ($row.AlertWebUrl) { "[$(Get-SafeMarkdown $row.Title)]($($row.AlertWebUrl))" } else { Get-SafeMarkdown $row.Title }
            $serviceCell  = if (-not [string]::IsNullOrEmpty($row.ServiceSource)) { $row.ServiceSource } else { '—' }
            $assignedCell = if ([string]::IsNullOrWhiteSpace($row.AssignedTo)) { '—' } else { Get-SafeMarkdown $row.AssignedTo }
            $incidentCell = if ($row.IncidentWebUrl) { "[Incident $($row.IncidentId)]($($row.IncidentWebUrl))" } elseif (-not [string]::IsNullOrEmpty($row.IncidentId)) { $row.IncidentId } else { '—' }
            $s1Rows += "| **Critical** | $($row.Severity) | $alertCell | $serviceCell | $assignedCell | $($row.AgeDisplay) | $incidentCell |`n"
        }
        if ($critMore -gt 0) {
            $s1Rows += "`n_... and $critMore more Critical alerts. [View in Defender XDR Alerts]($alertsPortalUrl)_`n`n"
        }

        foreach ($row in $impDisplay) {
            $alertCell    = if ($row.AlertWebUrl) { "[$(Get-SafeMarkdown $row.Title)]($($row.AlertWebUrl))" } else { Get-SafeMarkdown $row.Title }
            $serviceCell  = if (-not [string]::IsNullOrEmpty($row.ServiceSource)) { $row.ServiceSource } else { '—' }
            $assignedCell = if ([string]::IsNullOrWhiteSpace($row.AssignedTo)) { '—' } else { Get-SafeMarkdown $row.AssignedTo }
            $incidentCell = if ($row.IncidentWebUrl) { "[Incident $($row.IncidentId)]($($row.IncidentWebUrl))" } elseif (-not [string]::IsNullOrEmpty($row.IncidentId)) { $row.IncidentId } else { '—' }
            $s1Rows += "| Important | $($row.Severity) | $alertCell | $serviceCell | $assignedCell | $($row.AgeDisplay) | $incidentCell |`n"
        }
        if ($impMore -gt 0) {
            $s1Rows += "`n_... and $impMore more Important alerts. [View in Defender XDR Alerts]($alertsPortalUrl)_`n`n"
        }

        foreach ($row in $informationalItems) {
            $alertCell    = if ($row.AlertWebUrl) { "[$(Get-SafeMarkdown $row.Title)]($($row.AlertWebUrl))" } else { Get-SafeMarkdown $row.Title }
            $serviceCell  = if (-not [string]::IsNullOrEmpty($row.ServiceSource)) { $row.ServiceSource } else { '—' }
            $assignedCell = if ([string]::IsNullOrWhiteSpace($row.AssignedTo)) { '—' } else { Get-SafeMarkdown $row.AssignedTo }
            $incidentCell = if ($row.IncidentWebUrl) { "[Incident $($row.IncidentId)]($($row.IncidentWebUrl))" } elseif (-not [string]::IsNullOrEmpty($row.IncidentId)) { $row.IncidentId } else { '—' }
            $s1Rows += "| Informational | $($row.Severity) | $alertCell | $serviceCell | $assignedCell | $($row.AgeDisplay) | $incidentCell |`n"
        }

        foreach ($row in $acknowledgedItems) {
            $alertCell    = if ($row.AlertWebUrl) { "[$(Get-SafeMarkdown $row.Title)]($($row.AlertWebUrl))" } else { Get-SafeMarkdown $row.Title }
            $serviceCell  = if (-not [string]::IsNullOrEmpty($row.ServiceSource)) { $row.ServiceSource } else { '—' }
            $assignedCell = if ([string]::IsNullOrWhiteSpace($row.AssignedTo)) { '—' } else { Get-SafeMarkdown $row.AssignedTo }
            $incidentCell = if ($row.IncidentWebUrl) { "[Incident $($row.IncidentId)]($($row.IncidentWebUrl))" } elseif (-not [string]::IsNullOrEmpty($row.IncidentId)) { $row.IncidentId } else { '—' }
            $s1Rows += "| Acknowledged | $($row.Severity) | $alertCell | $serviceCell | $assignedCell | $($row.AgeDisplay) | $incidentCell |`n"
        }

        $section1 = @"


## Open Alert Backlog — [Defender XDR > Alerts]($alertsPortalUrl)

| Band | Severity | Alert | Service | Assigned To | Age (h) | Incident |
| :--- | :------- | :---- | :------ | :---------- | ------: | :------- |
$s1Rows
"@
    }

    # ── Section 2: Per-service triage map ─────────────────────────────────────

    if ($alertBandRows.Count -gt 0) {
        $serviceNames = @($alertBandRows | Select-Object -ExpandProperty ServiceSource -Unique | Sort-Object)
        $s2Rows = ''
        foreach ($svc in $serviceNames) {
            $svcAlerts       = @($alertBandRows | Where-Object { $_.ServiceSource -eq $svc })
            $openCount       = $svcAlerts.Count
            $highCount       = @($svcAlerts | Where-Object { $_.Severity -eq 'high' }).Count
            $mediumCount     = @($svcAlerts | Where-Object { $_.Severity -eq 'medium' }).Count
            $lowInfoCount    = @($svcAlerts | Where-Object { $_.Severity -in @('low', 'informational') }).Count
            $unassignedCount = @($svcAlerts | Where-Object { [string]::IsNullOrWhiteSpace($_.AssignedTo) }).Count
            $critHighCount   = @($svcAlerts | Where-Object { $_.Band -eq 'Critical' }).Count
            $oldestHours     = ($svcAlerts | Measure-Object -Property AgeHours -Maximum).Maximum
            $svcDisplay      = if (-not [string]::IsNullOrEmpty($svc)) { $svc } else { '—' }
            $s2Rows += "| $svcDisplay | $openCount | $highCount / $mediumCount / $lowInfoCount | $unassignedCount | $critHighCount | $oldestHours |`n"
        }

        $section2 = @"


## Per-Service Triage Map

| Service | Open Alerts | High / Medium / Low-Info | Unassigned | Untriaged High | Oldest Open (h) |
| :------ | ----------: | :----------------------- | ---------: | -------------: | --------------: |
$s2Rows
"@
    }

    # ── Section 3: Recently resolved (last 30 days, informational context) ────

    if ($resolvedAlerts.Count -gt 0) {
        $resolvedByService = @($resolvedAlerts | Group-Object -Property serviceSource | Sort-Object -Property Name)
        $s3Rows = ''
        foreach ($grp in $resolvedByService) {
            $svcDisplay    = if (-not [string]::IsNullOrEmpty($grp.Name)) { $grp.Name } else { '—' }
            $resolvedCount = $grp.Count

            # Compute median time to resolve from createdDateTime → resolvedDateTime.
            $durations = @(
                $grp.Group | ForEach-Object {
                    if (-not [string]::IsNullOrEmpty($_.createdDateTime) -and -not [string]::IsNullOrEmpty($_.resolvedDateTime)) {
                        [math]::Round(([DateTime]$_.resolvedDateTime - [DateTime]$_.createdDateTime).TotalHours, 1)
                    }
                } | Where-Object { $null -ne $_ } | Sort-Object
            )

            $medianHours = if ($durations.Count -eq 0) {
                '—'
            }
            elseif ($durations.Count % 2 -eq 1) {
                $durations[($durations.Count - 1) / 2]
            }
            else {
                [math]::Round(($durations[$durations.Count / 2 - 1] + $durations[$durations.Count / 2]) / 2, 1)
            }

            $s3Rows += "| $svcDisplay | $resolvedCount | $medianHours |`n"
        }

        $section3 = @"


## Recently Resolved Alerts (Last 30 Days) — [Defender XDR > Incidents]($incidentsPortalUrl)

_Informational throughput context; does not affect the verdict._

| Service | Resolved (30d) | Median Time to Resolve (h) |
| :------ | -------------: | -------------------------: |
$s3Rows
"@
    }

    $mdInfo             = "$section1$section2$section3"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41121'
        Title  = $testTitle
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
