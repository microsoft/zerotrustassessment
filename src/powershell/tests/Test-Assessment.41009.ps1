<#
.SYNOPSIS
    Dormant accounts have been removed from sensitive Active Directory groups.

.DESCRIPTION
    Validates the Microsoft Defender for Identity "Remove dormant accounts from sensitive
    groups" posture recommendation via Microsoft Secure Score.

    Accounts that have not authenticated for 180+ days while retaining membership in
    sensitive groups such as Domain Admins or Enterprise Admins are high-value targets:
    their owners are not monitoring sign-ins, passwords are rarely rotated, and any
    pre-existing credential exposure remains exploitable indefinitely.

    The check reads the Secure Score control profile for AATP_DormantAccounts and the
    latest per-control score snapshot, then returns:
      Pass        – MDI reports no dormant accounts in sensitive groups.
      Fail        – One or more dormant accounts remain in sensitive groups.
      Investigate – The MDI posture control is not present in this tenant's Secure Score
                    (MDI not onboarded, sensors not healthy, or not yet provisioned).

.NOTES
    Test ID: 41009
    Workshop Task: SECOPS-009
    Pillar: SecOps
    Category: Identity threat protection
    Risk Level: High
    Supported Clouds: Global, USGov, USGovDoD
    Required Permission: SecurityEvents.Read.All (Application or Delegated)
#>

function Test-Assessment-41009 {
    [ZtTest(
        Category = 'Identity threat protection',
        ImplementationCost = 'Low',
        CompatibleLicense = ('ATA'),
        Service = ('Graph'),
        Pillar = 'SecOps',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 41009,
        Title = 'Dormant accounts have been removed from sensitive Active Directory groups',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity    = 'Checking dormant accounts in sensitive Active Directory groups via MDI Secure Score'
    Write-ZtProgress -Activity $activity -Status 'Retrieving MDI secure score control profile'
       
    # Q1 – Retrieve the MDI "Remove dormant accounts from sensitive groups" control profile.
    # This uses a $filter query; an empty result set indicates the profile is absent from this tenant.
    
    $controlProfile = $null
    $errorMsgQ1     = $null
    $httpStatusQ1   = $null

    try {

        $profileResults = Invoke-ZtGraphRequest -RelativeUri 'security/secureScoreControlProfiles' -Filter "service eq 'Azure ATP' and id eq 'AATP_DormantAccounts'" -ApiVersion beta -ErrorAction Stop
        $controlProfile = $profileResults | Select-Object -First 1
    }
    catch {
        $errorMsgQ1   = $_
        $httpStatusQ1 = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Failed to retrieve MDI control profile: $errorMsgQ1" -Level Warning
    }

    # Q2 – Retrieve the most recent Secure Score snapshot.
    $latestSecureScore = $null

    if ($null -ne $controlProfile) {
        Write-ZtProgress -Activity $activity -Status 'Retrieving latest Microsoft Secure Score'
        try {
            $scoreResponse     = Invoke-ZtGraphRequest -RelativeUri 'security/secureScores' -Top 1 -ApiVersion beta -DisablePaging -ErrorAction Stop
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

    # ── Investigate: Q1 returned no profile (MDI not onboarded or not yet provisioned) or 401/403 (insufficient permissions) ──
    if ($null -eq $controlProfile) {
        if ($httpStatusQ1 -in @(401, 403)) {
            $investigateReason = 'The **SecurityEvents.Read.All** permission is required to read Secure Score control profiles. Verify the permission is consented and re-run the assessment.'
        }
        elseif ($null -ne $errorMsgQ1) {
            $investigateReason = "Microsoft Graph returned an unexpected error retrieving the MDI Secure Score control profile. Re-run the assessment in 5–10 minutes and open a support ticket if the error persists."
        }
        else {
            $investigateReason = "The Microsoft Defender for Identity posture recommendation `"Remove dormant accounts from sensitive groups`" was not found in the tenant's Microsoft Secure Score; verify that MDI posture assessments are enabled."
        }

        $testResultMarkdown = "⚠️ $investigateReason"
        $customStatus       = 'Investigate'

        $params = @{
            TestId       = '41009'
            Title        = 'Dormant accounts have been removed from sensitive Active Directory groups'
            Status       = $passed
            Result       = $testResultMarkdown
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Resolve profile fields
    $controlId     = $controlProfile.id
    $profileTitle  = $controlProfile.title
    $maxScore      = $controlProfile.maxScore
    $actionUrl     = $controlProfile.actionUrl

    # ── Investigate: Q2 returned no data at all ──
    if ($null -eq $latestSecureScore) {
        $testResultMarkdown = "⚠️ The MDI dormant-accounts control profile exists but the current Microsoft Secure Score snapshot could not be retrieved."
        $customStatus       = 'Investigate'

        $params = @{
            TestId       = '41009'
            Title        = 'Dormant accounts have been removed from sensitive Active Directory groups'
            Status       = $passed
            Result       = $testResultMarkdown
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    # ── Locate the per-control entry inside controlScores[] ──
    $controlScoreEntry = $null
    if ($latestSecureScore.controlScores) {
        $controlScoreEntry = $latestSecureScore.controlScores |
            Where-Object { $_.controlName -eq $controlId } |
            Select-Object -First 1
    }

    # ── Investigate: profile exists but the snapshot has no entry for this control ──
    if ($null -eq $controlScoreEntry) {
        $testResultMarkdown = "⚠️ The MDI dormant-accounts control profile ($controlId) exists but the latest Secure Score snapshot has no scored entry for this control."
        $customStatus       = 'Investigate'

        $params = @{
            TestId       = '41009'
            Title        = 'Dormant accounts have been removed from sensitive Active Directory groups'
            Status       = $passed
            Result       = $testResultMarkdown
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    # ── Evaluate Pass / Fail ──
    $currentScore         = $controlScoreEntry.score
    $scoreInPercentage    = $controlScoreEntry.scoreInPercentage
    $implementationStatus = $controlScoreEntry.implementationStatus
    $lastSynced           = $controlScoreEntry.lastSynced

    if ($currentScore -eq $maxScore) {
        $passed             = $true
        $testResultMarkdown = "✅ No dormant accounts are members of sensitive Active Directory groups.`n`n%TestResult%"
    }
    else {
        $passed             = $false
        $testResultMarkdown = "❌ One or more dormant accounts are members of sensitive Active Directory groups.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $defenderLink = 'https://security.microsoft.com/securescore?viewid=actions'

    $scoreDisplay     = if ($null -ne $currentScore) { $currentScore } else { '-' }
    $maxDisplay       = if ($null -ne $maxScore) { $maxScore } else { '-' }
    $pctDisplay       = if ($null -ne $scoreInPercentage) { "$([math]::Round($scoreInPercentage, 1))%" } else { '-' }
    $impStatusDisplay = if (-not [string]::IsNullOrEmpty($implementationStatus)) { $implementationStatus } else { '-' }
    $syncDisplay      = if (-not [string]::IsNullOrEmpty($lastSynced)) { Get-FormattedDate -DateString $lastSynced } else { '-' }
    $statusLabel      = if ($passed) { '✅ Pass' } else { '❌ Fail' }

    $actionLinkMarkdown = ''
    if (-not [string]::IsNullOrWhiteSpace($actionUrl)) {
        $actionLinkMarkdown = "[$(Get-SafeMarkdown $profileTitle)]($actionUrl)"
    }
    elseif (-not [string]::IsNullOrWhiteSpace($profileTitle)) {
        $actionLinkMarkdown = Get-SafeMarkdown $profileTitle
    }
    else {
        $actionLinkMarkdown = 'Remove dormant accounts from sensitive groups'
    }
    
    $tableRows = "| $actionLinkMarkdown | $scoreDisplay | $maxDisplay | $pctDisplay | $impStatusDisplay | $syncDisplay | $statusLabel |`n"

    $mdFailLink = ''
    if (-not $passed) {
        $mdFailLink = "`n## [Defender XDR > Secure Score > Recommendations]($defenderLink)`n"
    }

    $mdTable = @"

$mdFailLink
| Recommendation title | Current score | Maximum score | Score % | Implementation status | Last synced | Status |
| :------------------- | :-----------: | :-----------: | :-----: | :-------------------- | :---------- | :----: |
$tableRows
"@

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdTable

    #endregion Report Generation

    $params = @{
        TestId = '41009'
        Title  = 'Dormant accounts have been removed from sensitive Active Directory groups'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
