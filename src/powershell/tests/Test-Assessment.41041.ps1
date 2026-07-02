<#
.SYNOPSIS
    Checks that AIR-recommended remediation actions are reviewed and actioned for MDO incidents.

.NOTES
    Test ID: 41041
    Workshop Task: SECOPS-041
    Pillar: SecOps
    Category: Email and collaboration security
    Required permission: SecurityIncident.Read.All
#>

function Test-Assessment-41041 {
    [ZtTest(
        Category = 'Email and collaboration security',
        CompatibleLicense = ('THREAT_INTELLIGENCE'),
        ImplementationCost = 'Medium',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Accelerate response and remediation',
        TenantType = ('Workforce'),
        TestId = 41041,
        Title = 'Automated Investigation and Response (AIR) recommendations are reviewed and actioned',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking MDO Automated Investigation and Response incident staleness'

    $windowStart    = (Get-Date).AddDays(-30).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $incidentFilter = "(status eq 'active' or status eq 'inProgress') and createdDateTime ge $windowStart"
    $incidentSelect = 'id,displayName,severity,status,assignedTo,createdDateTime,lastUpdateDateTime,incidentWebUrl'
    $alertsExpand   = "alerts(`$select=id,status,serviceSource;`$filter=serviceSource eq 'microsoftDefenderForOffice365')"

    $allIncidents = $null
    $queryError   = $null

    Write-ZtProgress -Activity $activity -Status 'Querying active Microsoft 365 Defender incidents'

    try {
        # Q1: Enumerate active and in-progress MDO incidents in the last 30 days; server-side alert filter reduces payload.
        $allIncidents = Invoke-ZtGraphRequest -RelativeUri 'security/incidents' -ApiVersion beta -Filter $incidentFilter -Select $incidentSelect -QueryParameters @{ '$expand' = $alertsExpand } -ErrorAction Stop
    }
    catch {
        $queryError = $_
        Write-PSFMessage "Failed to retrieve security incidents: $_" -Tag Test -Level Warning
    }

    #endregion Data Collection

    #region Assessment Logic

    if ($queryError) {
        $params = @{
            TestId       = '41041'
            Title        = 'Automated Investigation and Response (AIR) recommendations are reviewed and actioned'
            Status       = $false
            Result       = '⚠️ Microsoft Graph returned an error while querying security incidents. Ensure the assessment account has SecurityIncident.Read.All permission and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $allIncidents = @($allIncidents)

    # Q1 returned zero incidents — API is reachable but tenant has no active incidents in the window.
    if ($allIncidents.Count -eq 0) {
        Write-PSFMessage 'No active incidents in the last 30 days — skipping AIR staleness check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q2: Retain incidents that have at least one MDO alert (alerts already server-side filtered by expand).
    $mdoIncidents = @($allIncidents | Where-Object { @($_.alerts).Count -gt 0 })

    if ($mdoIncidents.Count -eq 0) {
        Write-PSFMessage 'No MDO-origin incidents in the last 30 days — skipping AIR staleness check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $now                = Get-Date
    $staleThresholdHours = 24

    # Q3: Classify each MDO incident. Stale = not updated in 24 hours (status already filtered to active/inProgress by Q1).
    $incidentResults = foreach ($incident in $mdoIncidents) {
        $lastUpdated     = [datetime]$incident.lastUpdateDateTime
        $hoursSinceUpdate = [math]::Round(($now - $lastUpdated).TotalHours, 1)
        $isStale         = $hoursSinceUpdate -gt $staleThresholdHours
        $isAssigned      = -not [string]::IsNullOrWhiteSpace($incident.assignedTo)

        $rowStatus = if ($isStale -and -not $isAssigned) {
            'Fail'
        }
        elseif ($isStale -and $isAssigned) {
            'Investigate'
        }
        else {
            'Pass'
        }

        [PSCustomObject]@{
            DisplayName      = $incident.displayName
            Severity         = $incident.severity
            Status           = $incident.status
            AssignedTo       = if ($isAssigned) { $incident.assignedTo } else { '—' }
            Created          = $incident.createdDateTime
            LastUpdated      = $incident.lastUpdateDateTime
            HoursSinceUpdate = $hoursSinceUpdate
            IncidentWebUrl   = $incident.incidentWebUrl
            RowStatus        = $rowStatus
        }
    }
    $incidentResults  = @($incidentResults)

    $failItems        = @($incidentResults | Where-Object { $_.RowStatus -eq 'Fail' })
    $investigateItems = @($incidentResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    $passed       = $failItems.Count -eq 0 -and $investigateItems.Count -eq 0
    $customStatus = $null

    if ($failItems.Count -gt 0) {
        # Fail takes priority over Investigate when both exist.
        $testResultMarkdown = "❌ One or more MDO-origin incidents are unassigned and have not been updated in 24 hours; AIR-recommended remediation actions are likely unapproved and the original threats remain in user mailboxes.`n`n%TestResult%"
    }
    elseif ($investigateItems.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ Stale incidents exist but are assigned to an operator; manual review is required to determine why they have not progressed.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "✅ Microsoft Defender for Office 365 incidents are being triaged within SLA; no MDO-origin incidents are unassigned and stale.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $incidentsPortalUrl = 'https://security.microsoft.com/incidents'
    $maxDisplay         = 10

    # Sort by hours stale descending to surface the most neglected incidents first.
    $displayResults = @($incidentResults | Sort-Object -Property HoursSinceUpdate -Descending)
    $hasMoreItems   = $incidentResults.Count -gt $maxDisplay
    if ($hasMoreItems) {
        $displayResults = @($displayResults | Select-Object -First $maxDisplay)
    }

    $tableRows = ''
    foreach ($row in $displayResults) {
        $nameMd      = if ($row.IncidentWebUrl) { "[$(Get-SafeMarkdown $row.DisplayName)]($($row.IncidentWebUrl))" } else { Get-SafeMarkdown $row.DisplayName }
        $assignedMd  = if ($row.AssignedTo -eq '—') { '—' } else { Get-SafeMarkdown $row.AssignedTo }
        $createdMd   = Get-FormattedDate -DateString $row.Created
        $updatedMd   = Get-FormattedDate -DateString $row.LastUpdated
        $rowStatusMd = switch ($row.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $nameMd | $($row.Severity) | $($row.Status) | $assignedMd | $createdMd | $updatedMd | $($row.HoursSinceUpdate) | $rowStatusMd |`n"
    }

    if ($hasMoreItems) {
        $remaining  = $incidentResults.Count - $maxDisplay
        $tableRows += "`n... and $remaining more. [Microsoft 365 Defender > Incidents & alerts > Incidents]($incidentsPortalUrl)`n"
    }

    $formatTemplate = @'


## [Microsoft 365 Defender > Incidents & alerts > Incidents]({0})

| Display name | Severity | Status | Assigned to | Created | Last updated | Hours since update | Result |
| :----------- | :------- | :----- | :---------- | :------ | :----------- | -----------------: | :----- |
{1}
'@

    $mdInfo             = $formatTemplate -f $incidentsPortalUrl, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41041'
        Title  = 'Automated Investigation and Response (AIR) recommendations are reviewed and actioned'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
