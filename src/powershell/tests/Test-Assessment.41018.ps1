<#
.SYNOPSIS
    No open Microsoft Defender for Identity health issues are present in the tenant.

.NOTES
    Test ID: 41018
    Workshop Task: SECOPS-018
    Pillar: Identity
    Category: Identity threat protection
    Required permission: SecurityIdentitiesHealth.Read.All
#>

function Test-Assessment-41018 {
    [ZtTest(
        Category = 'Identity threat protection',
        CompatibleLicense = ('ATA'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41018,
        Title = 'No open Microsoft Defender for Identity health issues are present in the tenant',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity   = 'Checking Microsoft Defender for Identity health issues'
    $queryError = $null
    $healthIssues = $null

    Write-ZtProgress -Activity $activity -Status 'Querying MDI health issues'

    try {
        # Q1: List all open MDI health issues.
        $healthIssues = Invoke-ZtGraphRequest -RelativeUri 'security/identities/healthIssues' -Filter "status eq 'open'" -ApiVersion beta -ErrorAction Stop
    }
    catch {
        $queryError = $_
        Write-PSFMessage "Failed to retrieve MDI health issues: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($queryError) {
        $errText = $queryError.ToString()

        # 403 with "not onboarded" in the body means MDI is not licensed/provisioned — skip.
        # 403 with an empty message ("UnknownError") means the caller lacks SecurityIdentitiesHealth.Read.All — investigate.
        # The two cases both return HTTP 403 but carry different error codes in the response body.
        if ($errText -match 'not onboarded to Microsoft Defender for Identity' -or $errText -match '"code":"Forbidden"') {
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
            return
        }

        # All other errors (permission missing, transient failures, 5xx) → Investigate.
        $params = @{
            TestId       = '41018'
            Title        = 'No open Microsoft Defender for Identity health issues are present in the tenant'
            Status       = $false
            Result       = '⚠️ Microsoft Defender for Identity is deployed but the healthIssues collection returned an error.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $healthIssues = @($healthIssues)

    # unknownFutureValue in severity signals API schema drift → Investigate.
    $unknownItems = @($healthIssues | Where-Object { $_.severity -eq 'unknownFutureValue' })
    if ($unknownItems.Count -gt 0) {
        $params = @{
            TestId       = '41018'
            Title        = 'No open Microsoft Defender for Identity health issues are present in the tenant'
            Status       = $false
            Result       = '⚠️ Microsoft Defender for Identity is deployed but the healthIssues collection returned an error.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Low-severity issues are reported but do not fail the check; only medium/high do.
    $criticalIssues = @($healthIssues | Where-Object { $_.severity -in ('medium', 'high') })
    $passed = $criticalIssues.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ No medium- or high-severity Microsoft Defender for Identity health issues are open in the tenant.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more medium- or high-severity Microsoft Defender for Identity health issues are open and reduce detection coverage.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $healthPageUrl = 'https://security.microsoft.com/securitysettings/identities'
    $mdInfo        = ''

    if ($healthIssues.Count -gt 0) {
        $severityOrder = @{ high = 0; medium = 1; low = 2; unknownFutureValue = 3 }
        $sortedIssues  = @($healthIssues | Sort-Object { $severityOrder[$_.severity] }, displayName)
        $maxDisplay    = 10
        $totalCount    = $sortedIssues.Count
        $displayIssues = if ($totalCount -gt $maxDisplay) { $sortedIssues | Select-Object -First $maxDisplay } else { $sortedIssues }

        $tableRows = ''
        foreach ($issue in $displayIssues) {
            $displayName  = Get-SafeMarkdown $issue.displayName
            $severity     = $issue.severity
            $issueType    = $issue.healthIssueType
            $sensors      = if ($issue.sensorDNSNames -and $issue.sensorDNSNames.Count -gt 0) { $issue.sensorDNSNames -join ', ' } else { '—' }
            $domains      = if ($issue.domainNames -and $issue.domainNames.Count -gt 0) { $issue.domainNames -join ', ' } else { '—' }
            $lastModified = if ($issue.lastModifiedDateTime) { Get-FormattedDate -DateString $issue.lastModifiedDateTime } else { '—' }
            $rowStatus    = if ($issue.severity -in ('medium', 'high')) { '❌ Fail' } else { '✅ Pass' }
            $tableRows   += "| $displayName | $severity | $issueType | $sensors | $domains | $lastModified | $rowStatus |`n"
        }

        if ($totalCount -gt $maxDisplay) {
            $remaining  = $totalCount - $maxDisplay
            $tableRows += "| ... ($remaining more) | | | | | | |`n"
        }

        # Show count above the table when results are truncated.
        $preTableLines = ''
        if ($totalCount -gt $maxDisplay) {
            $preTableLines = "Total open issues: $totalCount.`n`n"
        }

        $formatTemplate = @'


### [Defender XDR — Identity health issues]({0})

{1}| Display name | Severity | Type | Affected sensors | Affected domains | Last modified | Status |
| :----------- | :------- | :--- | :--------------- | :--------------- | :------------ | :----- |
{2}
'@
        $mdInfo = $formatTemplate -f $healthPageUrl, $preTableLines, $tableRows
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41018'
        Title  = 'No open Microsoft Defender for Identity health issues are present in the tenant'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
