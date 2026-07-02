<#
.SYNOPSIS
    Checks that compromised identities surfaced by Microsoft Defender for Identity alerts have been remediated.

.NOTES
    Test ID: 41019
    Workshop Task: SECOPS-019
    Pillar: SecOps
    Category: Identity threat protection
    Required permission: SecurityAlert.Read.All
#>

function Test-Assessment-41019 {

    [ZtTest(
        Category           = 'Identity threat protection',
        CompatibleLicense  = ('ATA'),
        ImplementationCost = 'Low',
        Pillar             = 'SecOps',
        RiskLevel          = 'High',
        Service            = ('Graph'),
        SfiPillar          = 'Accelerate response and remediation',
        TenantType         = ('Workforce'),
        TestId             = 41019,
        Title              = 'Compromised identities surfaced by Microsoft Defender for Identity have been remediated',
        UserImpact         = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Microsoft Defender for Identity compromised identity remediation'
    Write-ZtProgress -Activity $activity -Status 'Querying open MDI alerts'

    # Q1: List open MDI alerts; the evidence collection is returned inline per alert.
    # Compromised-user evidence and remediation state are evaluated client-side.
    # Prefer: include-unknown-enum-members is required so that the six gated remediationStatus
    # values (active, pendingApproval, declined, unremediated, running, partiallyRemediated)
    # are returned as their real strings rather than collapsing to unknownFutureValue.
    $openAlerts = $null
    try {
        $openAlerts = Invoke-ZtGraphRequest -RelativeUri 'security/alerts_v2' -Filter "serviceSource eq 'microsoftDefenderForIdentity' and status ne 'resolved'" -ApiVersion beta -Headers @{ Prefer = 'include-unknown-enum-members' } -ErrorAction Stop
    }
    catch {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        if ($httpStatus -in @(401, 403)) {
            $params = @{
                TestId       = '41019'
                Title        = 'Compromised identities surfaced by Microsoft Defender for Identity have been remediated'
                Status       = $false
                Result       = '⚠️ Insufficient Graph permission for SecurityAlert.Read.All; the assessment runtime cannot read MDI alerts.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
            return
        }
        $params = @{
            TestId       = '41019'
            Title        = 'Compromised identities surfaced by Microsoft Defender for Identity have been remediated'
            Status       = $false
            Result       = '⚠️ Transient Microsoft Graph error or unexpected response shape; re-run after 5-10 minutes.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q2: When Q1 returns nothing, probe whether MDI has any alerts at all to distinguish
    # "no open alerts" from "MDI is not deployed".
    $mdiPresenceAlerts = $null
    if ($null -eq $openAlerts -or @($openAlerts).Count -eq 0) {
        Write-ZtProgress -Activity $activity -Status 'Probing MDI telemetry presence'
        try {
            $mdiPresenceAlerts = Invoke-ZtGraphRequest -RelativeUri 'security/alerts_v2' -Filter "serviceSource eq 'microsoftDefenderForIdentity'" -Top 1 -ApiVersion beta -ErrorAction Stop
        }
        catch {
            $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($httpStatus -in @(401, 403)) {
                $params = @{
                    TestId       = '41019'
                    Title        = 'Compromised identities surfaced by Microsoft Defender for Identity have been remediated'
                    Status       = $false
                    Result       = '⚠️ Insufficient Graph permission for SecurityAlert.Read.All; the assessment runtime cannot read MDI alerts.'
                    CustomStatus = 'Investigate'
                }
                Add-ZtTestResultDetail @params
                return
            }
            $params = @{
                TestId       = '41019'
                Title        = 'Compromised identities surfaced by Microsoft Defender for Identity have been remediated'
                Status       = $false
                Result       = '⚠️ Transient Microsoft Graph error or unexpected response shape; re-run after 5-10 minutes.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
            return
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    # Unfiltered MDI probe also returned nothing: MDI is not deployed in this tenant.
    if (($null -eq $openAlerts -or @($openAlerts).Count -eq 0) -and
        ($null -eq $mdiPresenceAlerts -or @($mdiPresenceAlerts).Count -eq 0)) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Microsoft Defender for Identity alerts are open in this tenant.'
        return
    }

    $containedStatuses    = @('remediated', 'prevented', 'blocked')
    # unknownFutureValue is included here as a defensive fallback: if the Prefer header is
    # somehow dropped or a future API version adds new gated values, treat them as Investigate
    # rather than silently promoting them to Fail.
    $inProgressStatuses   = @('active', 'running', 'pendingApproval', 'partiallyRemediated', 'unknownFutureValue')

    # One row per compromised userEvidence — an alert can implicate multiple accounts.
    $compromisedRows = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($alert in @($openAlerts)) {
        $compromisedEvidenceList = @($alert.evidence | Where-Object {
            $_.'@odata.type' -eq '#microsoft.graph.security.userEvidence' -and
            $_.roles -contains 'compromised'
        })

        foreach ($userEvidence in $compromisedEvidenceList) {
            $rawRemediationStatus = $userEvidence.remediationStatus
            $isAbsent             = [string]::IsNullOrEmpty($rawRemediationStatus)

            # Absent means the product hasn't attached a remediation object yet (e.g. a freshly-raised
            # alert). "No data" is not a confirmed gap, so treat as Investigate rather than Fail.
            # Only positive not-remediated signals (none/notFound/declined/unremediated) → Fail.
            $rowVerdict = if ($isAbsent) {
                'Investigate'
            } elseif ($rawRemediationStatus -in $containedStatuses) {
                'Pass'
            } elseif ($rawRemediationStatus -in $inProgressStatuses) {
                'Investigate'
            } else {
                # none, notFound, declined, unremediated → confirmed not remediated
                'Fail'
            }

            $compromisedRows.Add([PSCustomObject]@{
                AlertTitle        = $alert.title
                AlertSeverity     = $alert.severity
                AlertStatus       = $alert.status
                AssignedTo        = $alert.assignedTo
                FirstActivity     = $alert.firstActivityDateTime
                IncidentId        = $alert.incidentId
                IncidentWebUrl    = $alert.incidentWebUrl
                UserAccount       = $userEvidence.userAccount
                RemediationStatus = if ($isAbsent) { 'absent' } else { $rawRemediationStatus }
                RowVerdict        = $rowVerdict
            })
        }
    }

    # No compromised-user evidence found across all open MDI alerts.
    if ($compromisedRows.Count -eq 0) {
        $params = @{
            TestId = '41019'
            Title  = 'Compromised identities surfaced by Microsoft Defender for Identity have been remediated'
            Status = $true
            Result = '✅ No compromised identities surfaced by Microsoft Defender for Identity are awaiting remediation.'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Aggregate verdict: Fail > Investigate > Pass.
    $allVerdicts  = @($compromisedRows | Select-Object -ExpandProperty RowVerdict)
    $passed       = $true
    $customStatus = $null

    if ($allVerdicts -contains 'Fail') {
        $passed = $false
        $testResultMarkdown = "❌ One or more identities flagged as compromised by Microsoft Defender for Identity have not been remediated.`n`n%TestResult%"
    } elseif ($allVerdicts -contains 'Investigate') {
        $passed       = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Remediation is in progress for the flagged compromised identities; confirm that it completes.`n`n%TestResult%"
    } else {
        $testResultMarkdown = "✅ No compromised identities surfaced by Microsoft Defender for Identity are awaiting remediation.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $alertsPortalUrl = 'https://security.microsoft.com/alerts'

    # Sort Fail rows first (F < I < P alphabetically), then by alert title within each verdict.
    $sortedRows  = @($compromisedRows | Sort-Object -Property RowVerdict, AlertTitle)
    $totalCount  = $sortedRows.Count
    $displayRows = @($sortedRows | Select-Object -First 10)
    $isTruncated = $totalCount -gt 10

    $anyNonPass     = @($compromisedRows | Where-Object { $_.RowVerdict -ne 'Pass' })
    $showPortalLink = $isTruncated -or $anyNonPass.Count -gt 0

    $preTableLines = ''
    if ($isTruncated) {
        $preTableLines += "Total compromised identities: $totalCount (showing first 10)`n`n"
    } else {
        $preTableLines += "Total compromised identities: $totalCount`n`n"
    }
    if ($showPortalLink) {
        $preTableLines += "[Defender XDR > Investigation & response > Alerts]($alertsPortalUrl)`n`n"
    }

    $tableRows = ''
    foreach ($row in $displayRows) {
        $alertTitle = $row.AlertTitle
        $userAccount = $row.UserAccount

        # Prefer UPN; fall back to domainName\accountName (down-level format matching MDI on-prem display).
        $userDisplay = if (-not [string]::IsNullOrEmpty($userAccount.userPrincipalName)) {
            Get-SafeMarkdown -Text $userAccount.userPrincipalName
        } else {
            "$($userAccount.domainName)\$($userAccount.accountName)"
        }

        $severity          = $row.AlertSeverity
        $alertStatus       = $row.AlertStatus
        $remediationStatus = switch ($row.RemediationStatus) {
            { $_ -in $containedStatuses }                        { "✅ $($row.RemediationStatus)" }
            { $_ -in $inProgressStatuses -or $_ -eq 'absent' }  { "⚠️ $($row.RemediationStatus)" }
            default                                              { "❌ $($row.RemediationStatus)" }
        }
        $assignedTo        = if ([string]::IsNullOrEmpty($row.AssignedTo)) { '—' } else { $row.AssignedTo }
        $firstActivity     = if ([string]::IsNullOrEmpty($row.FirstActivity)) { '—' } else { Get-FormattedDate -DateString $row.FirstActivity }

        $incidentCell = if (-not [string]::IsNullOrEmpty($row.IncidentWebUrl)) {
            "[Incident $($row.IncidentId)]($($row.IncidentWebUrl))"
        } elseif (-not [string]::IsNullOrEmpty($row.IncidentId)) {
            $row.IncidentId
        } else {
            '—'
        }

        $rowResult = switch ($row.RowVerdict) {
            'Pass'        { '✅ Pass' }
            'Investigate' { '⚠️ Investigate' }
            default       { '❌ Fail' }
        }

        $tableRows += "| $alertTitle | $userDisplay | $severity | $alertStatus | $remediationStatus | $assignedTo | $firstActivity | $incidentCell | $rowResult |`n"
    }

    if ($isTruncated) {
        $tableRows += "| ... | ... | ... | ... | ... | ... | ... | ... | ... |`n"
    }

    $mdInfo = @"
$preTableLines
| Alert title | Compromised user | Severity | Alert status | Remediation status | Assigned to | First activity | Incident | Result |
| :---------- | :--------------- | :------- | :----------- | :----------------- | :---------- | :------------- | :------- | :----- |
$tableRows
"@

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41019'
        Title  = 'Compromised identities surfaced by Microsoft Defender for Identity have been remediated'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
