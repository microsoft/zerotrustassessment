<#
.SYNOPSIS
    Checks that at least one Microsoft Defender for Cloud Apps anomaly detection policy is generating alerts.

.NOTES
    Test ID: 41081
    Workshop Task: SECOPS-081
    Pillar: SecOps
    Category: SaaS threat detection
    Required permission: SecurityAlert.Read.All
#>

function Test-Assessment-41081 {

    [ZtTest(
        Category = 'SaaS threat detection',
        CompatibleLicense = ('ADALLOM_S_STANDALONE','ADALLOM_S_O365'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41081,
        Title = 'At least one Microsoft Defender for Cloud Apps anomaly detection policy is generating alerts',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Microsoft Defender for Cloud Apps anomaly detection policy alerts'
    Write-ZtProgress -Activity $activity -Status 'Querying security alerts'

    $cutoff = (Get-Date).ToUniversalTime().AddDays(-90).ToString('yyyy-MM-ddTHH:mm:ssZ')
    $filter  = "serviceSource eq 'microsoftDefenderForCloudApps' and createdDateTime ge $cutoff"

    $allAlerts = $null
    try {
        $allAlerts = Invoke-ZtGraphRequest -RelativeUri 'security/alerts_v2' -Filter $filter -ApiVersion beta -ErrorAction Stop
    }
    catch {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        if ($httpStatus -in @(401, 403)) {
            $params = @{
                TestId       = '41081'
                Title        = 'At least one Microsoft Defender for Cloud Apps anomaly detection policy is generating alerts'
                Status       = $false
                Result       = '⚠️ **SecurityAlert.Read.All** permission is required to read security alerts. Verify the permission is consented and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
            return
        }
        $params = @{
            TestId       = '41081'
            Title        = 'At least one Microsoft Defender for Cloud Apps anomaly detection policy is generating alerts'
            Status       = $false
            Result       = '⚠️ Transient Microsoft Graph error or unexpected response while querying security alerts; re-run after 5–10 minutes, file a support ticket if persistent.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $unfilteredAlerts = @($allAlerts)

    # Client-side filter: anomaly detection alerts only.
    $anomalyAlerts = @($unfilteredAlerts | Where-Object {
        $_.detectionSource -eq 'cloudAppSecurity' -and $null -ne $_.alertPolicyId -and $_.alertPolicyId -ne ''
    })

    $passed       = $false
    $customStatus = $null

    if ($anomalyAlerts.Count -ge 1) {
        $passed = $true
        $testResultMarkdown = "✅ Microsoft Defender for Cloud Apps anomaly detection policies are active and producing alerts.`n`n%TestResult%"
    } elseif ($unfilteredAlerts.Count -gt 0) {
        # MDA produced alerts (session policy, file policy, or App Governance) but none were
        # anomaly-detection-attributed; administrator review is required.
        $passed       = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Microsoft Defender for Cloud Apps returned alerts in the last 90 days but none have **detectionSource = cloudAppSecurity** with a non-null **alertPolicyId**. Review built-in anomaly detection policy state in the Microsoft Defender portal.`n`n%TestResult%"
    } else {
        $passed = $false
        $testResultMarkdown = "❌ No Microsoft Defender for Cloud Apps anomaly detection policy alerts were observed in the last 90 days.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl = 'https://security.microsoft.com/cloudapps/policies'

    $preTableLines = "## [Defender XDR > Cloud apps > Policies > Anomaly detection]($portalUrl)`n`n"

    # Only render the alert table when anomaly alerts were found (Pass case).
    if ($passed) {
        $totalCount  = $anomalyAlerts.Count
        $displayRows = @($anomalyAlerts | Select-Object -First 10)
        $isTruncated = $totalCount -gt 10

        $countLine = ''
        if ($isTruncated) {
            $countLine = "Total alerts: $totalCount (showing first 10)`n`n"
        }

        $tableRows = ''
        foreach ($alert in $displayRows) {
            $title           = Get-SafeMarkdown -Text $alert.title
            $severity        = if ($alert.severity)        { $alert.severity }        else { '—' }
            $detectionSource = if ($alert.detectionSource) { $alert.detectionSource } else { '—' }
            $created         = if ($alert.createdDateTime) { Get-FormattedDate -DateString $alert.createdDateTime } else { '—' }
            $alertStatus     = if ($alert.status)          { $alert.status }          else { '—' }
            $alertUrl        = if ($alert.alertWebUrl)     { "[$($alert.alertWebUrl)]($($alert.alertWebUrl))" } else { '—' }

            $tableRows += "| $title | $severity | $detectionSource | $created | $alertStatus | $alertUrl |`n"
        }

        if ($isTruncated) {
            $tableRows += "| ... | ... | ... | ... | ... | ... |`n"
        }

        $mdInfo = @"
`n$preTableLines
$countLine| Alert title | Severity | Detection source | Created | Status | Alert URL |
| :---------- | :------- | :--------------- | :------ | :----- | :-------- |
$tableRows
"@
    } else {
        # Investigate or Fail: just render the portal link, no table.
        $mdInfo = $preTableLines
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41081'
        Title  = 'At least one Microsoft Defender for Cloud Apps anomaly detection policy is generating alerts'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
