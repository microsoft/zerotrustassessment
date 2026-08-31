<#
.SYNOPSIS
    Local administrator passwords on identity assets are protected and managed with Microsoft LAPS.

.DESCRIPTION
    Validates the Microsoft Defender for Identity "Local administrator passwords on identity assets
    are protected and managed with Microsoft LAPS" posture recommendation via Microsoft Secure Score.

    The check reads the Secure Score control profile for AATP_PwdLAPS and the latest per-control
    score snapshot, then returns:
      Pass        – Every monitored identity asset has a LAPS-managed local Administrator password.
      Fail        – One or more monitored identity assets do not have a LAPS-managed local
                     Administrator password.
      Investigate – The MDI posture control is not present in the tenant's Secure Score.

.NOTES
    Test ID: 41008
    Workshop Task: SECOPS-008
    Pillar: SecOps
    Category: Identity threat protection
    Risk Level: High
    Supported Clouds: Global, USGov, USGovDoD
    Required Permission: SecurityEvents.Read.All (Application or Delegated)
#>

function Test-Assessment-41008 {
    [ZtTest(
        Category = 'Identity threat protection',
        CompatibleLicense = ('ATA'),
        ImplementationCost = 'Medium',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 41008,
        Title = 'Local administrator passwords on identity assets are protected and managed with Microsoft LAPS',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking LAPS posture for identity assets via MDI Secure Score'
    Write-ZtProgress -Activity $activity -Status 'Retrieving MDI secure score control profile'

    # Q1 – Retrieve the MDI LAPS control profile by its stable ID.
    $controlProfile = $null
    $errorMsgQ1 = $null
    $httpStatusQ1 = $null

    try {
        $controlProfile = Invoke-ZtGraphRequest -RelativeUri 'security/secureScoreControlProfiles' -UniqueId 'AATP_PwdLAPS' -ApiVersion beta -ErrorAction Stop
    }
    catch {
        $errorMsgQ1 = $_
        $httpStatusQ1 = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Failed to retrieve MDI LAPS control profile: $errorMsgQ1" -Level Warning
    }

    # Q2 – Retrieve the latest Secure Score snapshot; -DisablePaging avoids following @odata.nextLink to prior-day snapshots.
    $latestSecureScore = $null

    if ($null -ne $controlProfile) {
        Write-ZtProgress -Activity $activity -Status 'Retrieving latest Microsoft Secure Score'
        try {
            $scoreResponse = Invoke-ZtGraphRequest -RelativeUri 'security/secureScores' -Top 1 -ApiVersion beta -DisablePaging -ErrorAction Stop
            $latestSecureScore = $scoreResponse.value | Select-Object -First 1
        }
        catch {
            Write-PSFMessage "Failed to retrieve Secure Score: $_" -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passed       = $false
    $customStatus = $null

    # ── Investigate: Q1 returned no profile (404 / not provisioned) or an error (permission/transient) ──
    if ($null -eq $controlProfile) {
        if ($httpStatusQ1 -in @(401, 403)) {
            $investigateReason = 'The **SecurityEvents.Read.All** permission is required to read Secure Score control profiles. Verify the permission is consented and re-run the assessment.'
        }
        elseif ($null -ne $errorMsgQ1 -and $httpStatusQ1 -ne 404) {
            $investigateReason = 'Microsoft Graph returned an unexpected error retrieving the MDI LAPS Secure Score control profile. Re-run the assessment in 5–10 minutes and open a support ticket if the error persists.'
        }
        else {
            # HTTP 404 (or no error at all) means the control is simply absent from this tenant's Secure Score.
            $investigateReason = 'The Microsoft Defender for Identity posture recommendation for Microsoft LAPS was not found in the tenant''s Microsoft Secure Score; verify that MDI posture assessments are enabled.'
        }

        $customStatus = 'Investigate'
        $params = @{
            TestId       = '41008'
            Title        = 'Local administrator passwords on identity assets are protected and managed with Microsoft LAPS'
            Status       = $passed
            Result       = "⚠️ $investigateReason"
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Resolve profile fields
    $controlId = $controlProfile.id
    $profileTitle = $controlProfile.title
    $maxScore = $controlProfile.maxScore
    $actionUrl = $controlProfile.actionUrl

    # ── Investigate: Q2 returned no data at all ──
    if ($null -eq $latestSecureScore) {
        $customStatus = 'Investigate'
        $params = @{
            TestId       = '41008'
            Title        = 'Local administrator passwords on identity assets are protected and managed with Microsoft LAPS'
            Status       = $passed
            Result       = '⚠️ The MDI LAPS control profile exists but the current Microsoft Secure Score snapshot could not be retrieved.'
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    # ── Locate the per-control entry inside controlScores[] (matches on controlName) ──
    $controlScoreEntry = $null
    if ($latestSecureScore.controlScores) {
        $controlScoreEntry = $latestSecureScore.controlScores |
            Where-Object { $_.controlName -eq $controlId } |
            Select-Object -First 1
    }

    # ── Investigate: profile exists but the snapshot has no scored entry for this control ──
    if ($null -eq $controlScoreEntry) {
        $customStatus = 'Investigate'
        $params = @{
            TestId       = '41008'
            Title        = 'Local administrator passwords on identity assets are protected and managed with Microsoft LAPS'
            Status       = $passed
            Result       = '⚠️ The Microsoft Defender for Identity posture recommendation for Microsoft LAPS was not found in the tenant''s Microsoft Secure Score; verify that MDI posture assessments are enabled.'
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    $currentScore = $controlScoreEntry.score

    # ── Evaluate Pass / Fail ──
    if ($currentScore -eq $maxScore) {
        $passed = $true
        $testResultMarkdown = "✅ Every monitored device has a Microsoft LAPS-managed local Administrator password.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more monitored devices do not have a Microsoft LAPS-managed local Administrator password.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $defenderLink = 'https://security.microsoft.com/securescore?viewid=actions'
    $statusLabel = if ($passed) { '✅ Pass' } else { '❌ Fail' }
    $titleMarkdown = Get-SafeMarkdown -Text $profileTitle
    $defenderLinkMarkdown = if (-not [string]::IsNullOrWhiteSpace($actionUrl)) { "[Defender XDR]($actionUrl)" } else { '—' }

    $mdFailLink = ''
    if (-not $passed) {
        $mdFailLink = "`n## [Defender XDR > Secure Score > Recommendations]($defenderLink)`n"
    }

    $tableRows = "| $titleMarkdown | $currentScore | $maxScore | $defenderLinkMarkdown | $statusLabel |`n"

    $mdTable = @"

$mdFailLink
| Recommendation title | Current score | Maximum score | Defender XDR Recommendation Link | Status |
| :-------------------- | :-----------: | :-----------: | :-------------------------------- | :----: |
$tableRows
"@

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdTable

    #endregion Report Generation

    $params = @{
        TestId = '41008'
        Title  = 'Local administrator passwords on identity assets are protected and managed with Microsoft LAPS'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
