<#
.SYNOPSIS
    Checks that Microsoft Defender XDR incidents from the last 24 hours are triaged and remediated.

.NOTES
    Test ID: 41061
    Workshop Task: SECOPS-061
    Pillar: SecOps
    Category: Threat investigation and response
    Required permission: SecurityIncident.Read.All
#>

function Test-Assessment-41061 {
    [ZtTest(
        Category           = 'Threat investigation and response',
        CompatibleLicense  = ('WINDEFATP', 'MDE_LITE', 'ATP_ENTERPRISE', 'THREAT_INTELLIGENCE', 'ATA', 'ADALLOM_S_STANDALONE', 'MDE_SMB'),
        ImplementationCost = 'Medium',
        Pillar             = 'SecOps',
        RiskLevel          = 'High',
        Service            = ('Graph'),
        SfiPillar          = 'Accelerate response and remediation',
        TenantType         = ('Workforce'),
        TestId             = 41061,
        Title              = 'All active Microsoft Defender XDR incidents are triaged and remediated',
        UserImpact         = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Microsoft Defender XDR incident triage and remediation'

    $now          = Get-Date
    $windowStart  = $now.AddHours(-24).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $slaThreshold = $now.AddHours(-4).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

    # Server-side OData filter encoding all three evaluation rules — only failing incidents are returned.
    # Rule (a): unassigned and not a merged redirect.
    # Rule (b): high-severity, still active, strictly older than 4 h (lt = created before the SLA threshold, exclusive).
    # Rule (c): resolved but missing a meaningful classification or determination.
    $incidentFilter = "createdDateTime ge $windowStart and " +
                      "((assignedTo eq null and status ne 'redirected') or " +
                      "(severity eq 'high' and status eq 'active' and createdDateTime lt $slaThreshold) or " +
                      "(status eq 'resolved' and (classification eq 'unknown' or determination eq 'unknown')))"
    $incidentSelect = 'displayName,severity,status,assignedTo,classification,determination,createdDateTime,incidentWebUrl'

    Write-ZtProgress -Activity $activity -Status 'Querying failing Microsoft Defender XDR incidents from the last 24 hours'

    try {
        # Q1: Retrieve up to 10 incidents that breach at least one triage/remediation rule.
        # -DisablePaging prevents auto-following of nextLink so $top=10 is respected as a hard cap.
        # $count=true returns @odata.count with the true total so the report can show a truncation indicator.
        # Prefer: include-unknown-enum-members is required so that awaitingAction is returned as its real string.
        $response = Invoke-ZtGraphRequest -RelativeUri 'security/incidents' -ApiVersion beta -Filter $incidentFilter -Select $incidentSelect -Top 10 -QueryParameters @{ '$count' = 'true' } -Headers @{ Prefer = 'include-unknown-enum-members' } -ErrorAction Stop -DisablePaging
    }
    catch {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        if ($httpStatus -in @(401, 403)) {
            Write-PSFMessage "Failed to query Defender XDR incidents due to insufficient permissions (HTTP $httpStatus). Ensure the account has SecurityIncident.Read.All: $_" -Tag Test -Level Warning
            $params = @{
                TestId       = '41061'
                Title        = 'All active Microsoft Defender XDR incidents are triaged and remediated'
                Status       = $false
                Result       = '⚠️ Insufficient Graph permission; the assessment runtime cannot read Defender XDR incidents. Ensure the account has SecurityIncident.Read.All.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
            return
        }
        # Any other error (network, throttling, 5xx, etc.) is treated as a transient investigate condition.
        Write-PSFMessage "Failed to query Defender XDR incidents (HTTP $httpStatus): $_" -Tag Test -Level Warning
        $params = @{
            TestId       = '41061'
            Title        = 'All active Microsoft Defender XDR incidents are triaged and remediated'
            Status       = $false
            Result       = '⚠️ Transient Microsoft Graph error or unexpected response shape; re-run after 5–10 minutes.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    #endregion Data Collection

    #region Assessment Logic

    $failingIncidents = @($response.value | Where-Object { $_ })
    $totalFailingCount = if ($null -ne $response.'@odata.count') { $response.'@odata.count' } else { $failingIncidents.Count }

    # Empty response: no incidents breach any evaluation rule — tenant is compliant.
    $passed = ($failingIncidents.Count -eq 0)

    if ($passed) {
        $testResultMarkdown = '✅ All Microsoft Defender XDR incidents from the last 24 hours are triaged, assigned, and (when closed) classified.'
    }
    else {
        $testResultMarkdown = "❌ One or more incidents are unassigned, exceed SLA in ``active`` status, or were closed without classification.`n`n%TestResult%"
    }

    # Annotate each returned (failing) incident with per-rule flags for per-cell decoration in the report.
    $incidentResults = foreach ($incident in $failingIncidents) {
        $hoursOpenRaw = ($now - [datetime]$incident.createdDateTime).TotalHours
        $hoursOpen    = [math]::Round($hoursOpenRaw, 1)
        $isAssigned   = -not [string]::IsNullOrWhiteSpace($incident.assignedTo)

        # Condition (a): unassigned and not a merged redirect.
        $failUnassigned = (-not $isAssigned) -and ($incident.status -ne 'redirected')
        # Condition (b): high-severity active incident strictly past the 4-hour SLA; use unrounded value to avoid rounding a near-boundary incident to exactly 4.0.
        $failSla = $incident.severity -eq 'high' -and $incident.status -eq 'active' -and $hoursOpenRaw -gt 4
        # Condition (c): resolved without a meaningful classification or determination.
        $failClassification = $incident.status -eq 'resolved' -and ($incident.classification -eq 'unknown' -or $incident.determination -eq 'unknown')

        [PSCustomObject]@{
            DisplayName        = $incident.displayName
            Severity           = $incident.severity
            Status             = $incident.status
            AssignedTo         = if ($isAssigned) { $incident.assignedTo } else { '—' }
            Classification     = $incident.classification
            Determination      = $incident.determination
            Created            = $incident.createdDateTime
            HoursOpen          = $hoursOpen
            IncidentWebUrl     = $incident.incidentWebUrl
            FailUnassigned     = $failUnassigned
            FailSla            = $failSla
            FailClassification = $failClassification
        }
    }
    $incidentResults = @($incidentResults)

    #endregion Assessment Logic

    #region Report Generation

    if (-not $passed) {
        $incidentsPortalUrl = 'https://security.microsoft.com/incidents'
        $hasMoreItems       = $totalFailingCount -gt $incidentResults.Count

        $tableRows = ''
        foreach ($row in $incidentResults) {
            $nameMd           = if ($row.IncidentWebUrl) { "[$(Get-SafeMarkdown $row.DisplayName)]($($row.IncidentWebUrl))" } else { Get-SafeMarkdown $row.DisplayName }
            # Decorate the specific cell that triggered failure.
            $assignedMd       = if ($row.FailUnassigned)  { '❌ —' } elseif ($row.AssignedTo -eq '—') { '—' } else { Get-SafeMarkdown $row.AssignedTo }
            $hoursOpenMd      = if ($row.FailSla)          { "❌ $($row.HoursOpen)" } else { $row.HoursOpen }
            $classificationMd = if ($row.FailClassification -and $row.Classification -eq 'unknown') { '❌ unknown' } else { $row.Classification }
            $determinationMd  = if ($row.FailClassification -and $row.Determination  -eq 'unknown') { '❌ unknown' } else { $row.Determination }
            $createdMd        = Get-FormattedDate -DateString $row.Created

            $tableRows += "| $nameMd | $($row.Severity) | $($row.Status) | $assignedMd | $classificationMd | $determinationMd | $createdMd | $hoursOpenMd | ❌ Fail |`n"
        }

        if ($hasMoreItems) {
            $remaining  = $totalFailingCount - $incidentResults.Count
            $tableRows += "`n... and $remaining more. [Defender XDR > Incidents & alerts > Incidents]($incidentsPortalUrl)`n"
        }

        $formatTemplate = @'


## [Defender XDR > Incidents & alerts > Incidents]({0})

| Incident name | Severity | Status | Assigned to | Classification | Determination | Created | Hours open | Result |
| :------------ | :------- | :----- | :---------- | :------------- | :------------ | :------ | ---------: | :----- |
{1}
'@

        $mdInfo             = $formatTemplate -f $incidentsPortalUrl, $tableRows
        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }

    #endregion Report Generation

    $params = @{
        TestId = '41061'
        Title  = 'All active Microsoft Defender XDR incidents are triaged and remediated'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
