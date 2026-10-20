<#
.SYNOPSIS
    Privileged accounts in Active Directory have the "Account is sensitive and cannot be delegated" flag set.

.DESCRIPTION
    Validates the Microsoft Defender for Identity "Ensure privileged accounts are not delegated"
    posture recommendation via Microsoft Secure Score.

    The check reads the Secure Score control profile for
    AATP_PrivilegedAccountsWithDelegationAllowed and the latest per-control score snapshot, then returns:
      Pass        – All monitored privileged accounts are marked sensitive and cannot be delegated.
      Fail        – One or more monitored privileged accounts can be delegated.
      Investigate – The MDI posture control or score data is absent, incomplete, inconsistent, or has been set to Ignored.

.NOTES
    Test ID: 41004
    Workshop Task: SECOPS-004
    Pillar: SecOps
    Category: Identity threat protection
    Risk Level: High
    Supported Clouds: Global, USGov, USGovDoD
    Required Permission: SecurityEvents.Read.All (Application or Delegated)
#>
function Test-Assessment-41004 {
    [ZtTest(
        Category = 'Identity threat protection',
        CompatibleLicense = ('ATA'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 41004,
        Title = 'Privileged accounts in Active Directory have the "Account is sensitive and cannot be delegated" flag set',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking whether privileged Active Directory accounts can be delegated'
    Write-ZtProgress -Activity $activity -Status 'Retrieving MDI secure score control profile'

    # Q1: Retrieve the MDI control profile by its stable ID.
    $controlProfile = $null
    $errorMsgQ1 = $null
    $httpStatusQ1 = $null

    try {
        $controlProfile = Invoke-ZtGraphRequest -RelativeUri 'security/secureScoreControlProfiles' -UniqueId 'AATP_PrivilegedAccountsWithDelegationAllowed' -ApiVersion beta -ErrorAction Stop
    }
    catch {
        $errorMsgQ1 = $_
        $httpStatusQ1 = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Failed to retrieve the MDI privileged-account delegation control profile: $errorMsgQ1" -Level Warning
    }

    # Q2: Retrieve only the latest Secure Score snapshot.
    $latestSecureScore = $null
    $errorMsgQ2 = $null
    $httpStatusQ2 = $null

    if ($null -ne $controlProfile) {
        Write-ZtProgress -Activity $activity -Status 'Retrieving latest Microsoft Secure Score'
        try {
            $scoreResponse = Invoke-ZtGraphRequest -RelativeUri 'security/secureScores' -Top 1 -ApiVersion beta -DisablePaging -ErrorAction Stop
            $latestSecureScore = $scoreResponse.value | Select-Object -First 1
        }
        catch {
            $errorMsgQ2 = $_
            $httpStatusQ2 = Get-ZtHttpStatusCode -ErrorRecord $_
            Write-PSFMessage "Failed to retrieve the latest Microsoft Secure Score: $errorMsgQ2" -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passed             = $false
    $customStatus       = $null
    $investigateMessage = 'The Microsoft Defender for Identity posture recommendation "Ensure privileged accounts are not delegated" was not found in the tenant''s Microsoft Secure Score, or the control has been set to `Ignored` (the recommendation was dismissed, so delegation exposure cannot be confirmed from Secure Score); verify that MDI posture assessments are enabled and review any ignored state.'

    # ── Investigate: Q1 returned no profile (404 / not provisioned) or an error (permission/transient) ──
    if ($null -eq $controlProfile) {
        if ($httpStatusQ1 -in @(401, 403)) {
            $investigateReason = 'The **SecurityEvents.Read.All** permission is required to read Secure Score control profiles. Verify the permission is consented and re-run the assessment.'
        }
        elseif ($null -ne $errorMsgQ1 -and $httpStatusQ1 -ne 404) {
            $investigateReason = 'Microsoft Graph returned an unexpected error retrieving the MDI privileged-account delegation Secure Score control profile. Re-run the assessment and investigate if the error persists.'
        }
        else {
            # HTTP 404 (or no error) means the control is absent from this tenant's Secure Score.
            $investigateReason = $investigateMessage
        }

        $customStatus = 'Investigate'
        $params = @{
            TestId       = '41004'
            Title        = 'Privileged accounts in Active Directory have the "Account is sensitive and cannot be delegated" flag set'
            Status       = $passed
            Result       = "⚠️ $investigateReason"
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Resolve profile fields.
    $controlId    = $controlProfile.id
    $profileTitle = $controlProfile.title
    $maxScore     = $controlProfile.maxScore
    $actionUrl    = $controlProfile.actionUrl

    # ── Check whether the control has been dismissed in Secure Score ──
    $latestStateUpdate = @($controlProfile.controlStateUpdates | Sort-Object { if ($_.updatedDateTime) { [datetime]$_.updatedDateTime } else { [datetime]::MinValue } } -Descending) | Select-Object -First 1
    $isIgnored    = $latestStateUpdate -and $latestStateUpdate.state -eq 'Ignored'
    $controlState = if ($latestStateUpdate -and -not [string]::IsNullOrEmpty($latestStateUpdate.state)) { $latestStateUpdate.state } else { '—' }

    if ($isIgnored) {
        $customStatus = 'Investigate'
        $params = @{
            TestId       = '41004'
            Title        = 'Privileged accounts in Active Directory have the "Account is sensitive and cannot be delegated" flag set'
            Status       = $passed
            Result       = "⚠️ $investigateMessage"
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    # ── Investigate: Q2 returned no data ──
    if ($null -eq $latestSecureScore) {
        if ($httpStatusQ2 -in @(401, 403)) {
            $investigateReason = 'The **SecurityEvents.Read.All** permission is required to read the latest Secure Score snapshot. Verify the permission is consented and re-run the assessment.'
        }
        elseif ($null -ne $errorMsgQ2) {
            $investigateReason = 'Microsoft Graph returned an unexpected error retrieving the latest Secure Score snapshot. Re-run the assessment and investigate if the error persists.'
        }
        else {
            $investigateReason = 'The MDI privileged-account delegation control profile exists, but the current Microsoft Secure Score snapshot could not be retrieved.'
        }

        $customStatus = 'Investigate'
        $params = @{
            TestId       = '41004'
            Title        = 'Privileged accounts in Active Directory have the "Account is sensitive and cannot be delegated" flag set'
            Status       = $passed
            Result       = "⚠️ $investigateReason"
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    # ── Locate the per-control entry inside controlScores[] by its stable controlName ──
    $controlScoreEntry = $null
    if ($latestSecureScore.controlScores) {
        $controlScoreEntry = $latestSecureScore.controlScores |
            Where-Object { $_.controlName -eq $controlId } |
            Select-Object -First 1
    }

    # ── Investigate: profile exists but the latest snapshot has no matching score entry ──
    if ($null -eq $controlScoreEntry) {
        $customStatus = 'Investigate'
        $params = @{
            TestId       = '41004'
            Title        = 'Privileged accounts in Active Directory have the "Account is sensitive and cannot be delegated" flag set'
            Status       = $passed
            Result       = "⚠️ $investigateMessage"
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    $currentScore = $controlScoreEntry.score

    # ── Investigate: incomplete score data could otherwise produce an incorrect verdict ──
    if ($null -eq $currentScore -or $null -eq $maxScore) {
        $customStatus = 'Investigate'
        $params = @{
            TestId       = '41004'
            Title        = 'Privileged accounts in Active Directory have the "Account is sensitive and cannot be delegated" flag set'
            Status       = $passed
            Result       = '⚠️ The MDI privileged-account delegation Secure Score control returned incomplete score data; re-run the assessment and investigate if the issue persists.'
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    # ── Evaluate Pass / Fail / Investigate ──
    if ($currentScore -eq $maxScore) {
        $passed = $true
        $testResultMarkdown = '✅ All privileged accounts in monitored Active Directory domains have the "Account is sensitive and cannot be delegated" flag set.'
    }
    elseif ($currentScore -lt $maxScore) {
        $testResultMarkdown = '❌ One or more privileged accounts in monitored Active Directory domains can be delegated and are exposed to Kerberos delegation abuse.'
    }
    else {
        $customStatus = 'Investigate'
        $testResultMarkdown = '⚠️ Microsoft Secure Score returned inconsistent data for this recommendation, so the result could not be evaluated reliably. Verify the Secure Score data and re-run the assessment.'
    }
    $testResultMarkdown += "`n`n%TestResult%"

    #endregion Assessment Logic

    #region Report Generation

    $statusLabel = if ($customStatus -eq 'Investigate') { '⚠️ Investigate' } elseif ($passed) { '✅ Pass' } else { '❌ Fail' }
    $titleMarkdown = Get-SafeMarkdown -Text $profileTitle
    $recommendationLink = if ([string]::IsNullOrWhiteSpace($actionUrl)) { '—' } else { "[Defender XDR]($actionUrl)" }
    $failUrl = if ([string]::IsNullOrWhiteSpace($actionUrl)) { 'https://security.microsoft.com/securescore?viewid=actions' } else { $actionUrl }

    $mdFailLink = ''
    if (-not $passed -and $customStatus -ne 'Investigate') {
        $mdFailLink = "`n## [Defender XDR > Secure Score > Recommendations]($failUrl)`n"
    }

    $tableRows = "| $titleMarkdown | $currentScore | $maxScore | $controlState | $recommendationLink | $statusLabel |`n"

    $formatTemplate = @"

{0}
| Recommendation title | Current score | Maximum score | Control state | Defender XDR Recommendation Link | Status |
| :-------------------- | :-----------: | :-----------: | :------------ | :-------------------------------- | :----: |
{1}
"@

    $mdTable = $formatTemplate -f $mdFailLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdTable

    #endregion Report Generation

    $params = @{
        TestId = '41004'
        Title  = 'Privileged accounts in Active Directory have the "Account is sensitive and cannot be delegated" flag set'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
