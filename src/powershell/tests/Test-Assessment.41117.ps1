<#
.SYNOPSIS
    Admin and user false positives and false negatives are submitted to Microsoft on a regular cadence.

.NOTES
    Test ID: 41117
    Workshop Task: SECOPS-117
    Pillar: SecOps
    Category: Email and collaboration security
    Required permission: ThreatSubmission.Read.All
#>

function Test-Assessment-41117 {
    [ZtTest(
        Category = 'Email and collaboration security',
        CompatibleLicense = ('EXCHANGE_S_STANDARD'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41117,
        Title = 'Admin and user false positives and false negatives are submitted to Microsoft on a regular cadence',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $title = 'Admin and user false positives and false negatives are submitted to Microsoft on a regular cadence'
    $environment = (Get-MgContext).Environment
    if ($environment -and $environment -ne 'Global') {
        Add-ZtTestResultDetail -TestId '41117' -Title $title -Status $false `
            -SkippedBecause NotApplicable `
            -Result 'The Microsoft Graph beta email threat submissions API is available only in the Global cloud.'
        return
    }

    $lookbackDays = 30
    $cutoff = (Get-Date).ToUniversalTime().AddDays(-$lookbackDays).ToString('yyyy-MM-ddTHH:mm:ssZ')
    $submissions = @()
    $queryError = $null
    $httpStatus = $null

    Write-ZtProgress -Activity 'Checking email threat submissions to Microsoft' -Status "Getting submissions from the last $lookbackDays days"
    try {
        $submissions = @(Invoke-ZtGraphRequest `
                -RelativeUri 'security/threatSubmission/emailThreats' `
                -Filter "createdDateTime ge $cutoff" `
                -ApiVersion beta `
                -ErrorAction Stop)
    }
    catch {
        $queryError = $_
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $queryError
        Write-PSFMessage "Failed to retrieve email threat submissions (HTTP $httpStatus): $queryError" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($queryError) {
        $message = if ($httpStatus -in (401, 403)) {
            "⚠️ **ThreatSubmission.Read.All** permission is required to read email threat submissions (HTTP $httpStatus). Verify the permission is consented and the assessment identity has the Security Reader role, then re-run the assessment."
        }
        elseif ($httpStatus -eq 404) {
            '⚠️ The Microsoft Graph beta email threat submissions endpoint returned HTTP 404. This API is available only in the Global cloud; verify tenant and API availability, then re-run the assessment.'
        }
        else {
            "⚠️ Microsoft Graph returned an unexpected error while retrieving email threat submissions. Re-run after 5–10 minutes; file a support ticket if this persists. Error: $(Get-SafeMarkdown -Text $queryError.Exception.Message)"
        }

        $params = @{
            TestId       = '41117'
            Title        = $title
            Status       = $false
            Result       = $message
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $administratorSubmissions = @($submissions | Where-Object { $_.source -eq 'administrator' })
    $userSubmissions = @($submissions | Where-Object { $_.source -eq 'user' })
    $allNotJunk = $submissions.Count -gt 0 -and @($submissions | Where-Object { $_.category -ne 'notJunk' }).Count -eq 0

    $passed = $false
    $customStatus = $null
    if ($submissions.Count -eq 0) {
        $testResultMarkdown = "❌ No email threat submissions to Microsoft were found in the last $lookbackDays days; the SOC submission process may be inactive."
    }
    elseif ($administratorSubmissions.Count -eq 0) {
        $testResultMarkdown = "❌ No administrator email threat submissions to Microsoft were found in the last $lookbackDays days; SOC engagement is not visible.`n`n%TestResult%"
    }
    elseif ($allNotJunk) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Email threat submissions were found, but all were false-positive (notJunk) submissions; review whether phishing and malware false negatives are being submitted.`n`n%TestResult%"
    }
    elseif ($userSubmissions.Count -eq 0) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Administrator submissions were found, but no user submissions were found in the last $lookbackDays days; review the user-reporting pipeline.`n`n%TestResult%"
    }
    else {
        $passed = $true
        $testResultMarkdown = "✅ Email threat submissions to Microsoft are flowing from both administrators and users in the last $lookbackDays days.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($submissions.Count -gt 0) {
        $maxDisplay = 10
        $countGroups = @($submissions | Group-Object source, category | Sort-Object Name)
        $countRows = ''
        foreach ($group in $countGroups) {
            $source = Get-SafeMarkdown -Text $group.Group[0].source
            $category = Get-SafeMarkdown -Text $group.Group[0].category
            $countRows += "| $source | $category | $($group.Count) |`n"
        }

        $recentRows = ''
        $recentSubmissions = @($submissions | Sort-Object { [datetime]$_.createdDateTime } -Descending | Select-Object -First $maxDisplay)
        foreach ($submission in $recentSubmissions) {
            $created = if ($submission.createdDateTime) { Get-FormattedDate -DateString $submission.createdDateTime } else { 'N/A' }
            $recentRows += '| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} |{8}' -f `
                $created,
                (Get-SafeMarkdown -Text $submission.source),
                (Get-SafeMarkdown -Text $submission.category),
                (Get-SafeMarkdown -Text $submission.status),
                (Get-SafeMarkdown -Text $submission.result),
                (Get-SafeMarkdown -Text $submission.sender),
                (Get-SafeMarkdown -Text $submission.recipientEmailAddress),
                (Get-SafeMarkdown -Text $submission.subject),
                "`n"
        }
            if ($submissions.Count -gt $maxDisplay) {
                $recentRows += "| ... | ... | ... | ... | ... | ... | ... | ... |`n"
            }
            $recentSummary = if ($submissions.Count -gt $maxDisplay) {
                "Showing $($recentSubmissions.Count) of $($submissions.Count) submissions.`n"
            } else { '' }

        $formatTemplate = @'
### [Submission counts by source and category](https://security.microsoft.com/reportsubmission)

| Source | Category | Count |
| :----- | :------- | ----: |
        {0}
### Recent submissions

        {1}
| Created | Source | Category | Status | Result | Sender | Recipient | Subject |
| :------ | :----- | :------- | :----- | :----- | :----- | :-------- | :------ |
        {2}
'@
            $mdInfo = $formatTemplate -f $countRows, $recentSummary, $recentRows
        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }
    #endregion Report Generation

    $params = @{
        TestId = '41117'
        Title  = $title
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}