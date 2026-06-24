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
        MinimumLicense = ('ATA'),
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
    # Using the stable direct-GET form rather than a $filter query so the 404 response
    # unambiguously signals that the profile is absent from this tenant.
    
    $controlProfile = $null
    $errorMsgQ1     = $null
    $httpStatusQ1   = $null

    try {
        $profileResults = Invoke-ZtGraphRequest -RelativeUri 'security/secureScoreControlProfiles' -Filter "service eq 'Azure ATP' and id eq 'AATP_DormantAccounts'" -ApiVersion beta -ErrorAction Stop
        $controlProfile = $profileResults | Select-Object -First 1
    }
    catch {
        $errorMsgQ1 = $_
        Write-PSFMessage "Failed to retrieve MDI control profile: $errorMsgQ1" -Level Warning

        if ($errorMsgQ1.Exception.Response.StatusCode) {
            $httpStatusQ1 = [int]$errorMsgQ1.Exception.Response.StatusCode.value__
        }
        elseif ($errorMsgQ1.Exception.Message -match '403|Forbidden') {
            $httpStatusQ1 = 403
        }
        elseif ($errorMsgQ1.Exception.Message -match '404|NotFound') {
            $httpStatusQ1 = 404
        }
    }

    # Q2 – Retrieve the most recent Secure Score snapshot.
    $latestSecureScore = $null

    if ($null -ne $controlProfile) {
        Write-ZtProgress -Activity $activity -Status 'Retrieving latest Microsoft Secure Score'
        try {
            $scoreResponse = Invoke-ZtGraphRequest -RelativeUri 'security/secureScores' -Top 1 -ApiVersion beta -ErrorAction Stop
            # Invoke-ZtGraphRequest may return the value array or the first object directly.
            if ($scoreResponse -is [System.Collections.IEnumerable] -and -not ($scoreResponse -is [string])) {
                $latestSecureScore = @($scoreResponse)[0]
            }
            else {
                $latestSecureScore = $scoreResponse
            }
        }
        catch {
            Write-PSFMessage "Failed to retrieve Secure Score: $_" -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passed       = $false
    $customStatus = $null

    # ── Investigate: Q1 returned 404 or 403 (profile not in tenant or insufficient perms) ──
    if ($null -eq $controlProfile) {
        if ($httpStatusQ1 -in @(401, 403)) {
            $investigateReason = "The `SecurityEvents.Read.All` permission is required to read Secure Score control profiles. Verify the permission is consented and re-run the assessment."
        }
        else {
            $investigateReason = "The Microsoft Defender for Identity posture recommendation `"Remove dormant accounts from sensitive groups`" (`$controlId`) was not found in this tenant's Microsoft Secure Score. Verify that MDI posture assessments are enabled: check that at least one MDI sensor is healthy at **Microsoft Defender XDR > Settings > Identities > Sensors** and that Identity recommendations are visible at **Microsoft Defender XDR > Secure Score > Recommendations**."
        }

        $testResultMarkdown = "⚠️ $investigateReason`n`n%TestResult%"
        $customStatus       = 'Investigate'

        Add-ZtTestResultDetail `
            -TestId '41009' `
            -Title  'Dormant accounts have been removed from sensitive Active Directory groups' `
            -Status $passed `
            -Result $testResultMarkdown `
            -CustomStatus $customStatus
        return
    }

    # Resolve profile fields
    $profileTitle  = $controlProfile.title
    $maxScore      = $controlProfile.maxScore
    $actionUrl     = $controlProfile.actionUrl

    # ── Investigate: Q2 returned no data at all ──
    if ($null -eq $latestSecureScore) {
        $testResultMarkdown = "⚠️ The MDI dormant-accounts control profile exists but the current Microsoft Secure Score snapshot could not be retrieved. Re-run the assessment to get an up-to-date score.`n`n%TestResult%"
        $customStatus       = 'Investigate'

        Add-ZtTestResultDetail `
            -TestId '41009' `
            -Title  'Dormant accounts have been removed from sensitive Active Directory groups' `
            -Status $passed `
            -Result $testResultMarkdown `
            -CustomStatus $customStatus
        return
    }

    # ── Locate the per-control entry inside controlScores[] ──
    $controlScoreEntry = $null
    if ($latestSecureScore.value.controlScores) {
        $controlScoreEntry = $latestSecureScore.value.controlScores |
            Where-Object { $_.controlName -eq $controlId } |
            Select-Object -First 1
    }

    # ── Investigate: profile exists but the snapshot has no entry for this control ──
    if ($null -eq $controlScoreEntry) {
        $testResultMarkdown = "⚠️ The MDI dormant-accounts control profile (`$controlId`) exists but the latest Secure Score snapshot has no scored entry for this control. MDI posture assessments may not yet have run against this tenant. Re-run the assessment after confirming MDI sensor health at **Microsoft Defender XDR > Settings > Identities > Sensors**.`n`n%TestResult%"
        $customStatus       = 'Investigate'

        Add-ZtTestResultDetail `
            -TestId '41009' `
            -Title  'Dormant accounts have been removed from sensitive Active Directory groups' `
            -Status $passed `
            -Result $testResultMarkdown `
            -CustomStatus $customStatus
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
        $testResultMarkdown = "❌ One or more dormant accounts are members of sensitive Active Directory groups.`n`nThe per-account list is available only in the Defender XDR portal. Use the link in the table below to enumerate exposed accounts.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $defenderLink = 'https://security.microsoft.com/securescore?viewid=actions'

    $scoreDisplay  = if ($null -ne $currentScore) { $currentScore } else { 'N/A' }
    $maxDisplay    = if ($null -ne $maxScore) { $maxScore } else { 'N/A' }
    $pctDisplay    = if ($null -ne $scoreInPercentage) { "$([math]::Round($scoreInPercentage, 1))%" } else { 'N/A' }
    $statusDisplay = if ($null -ne $implementationStatus) { $implementationStatus } else { 'N/A' }
    $syncDisplay   = if ($null -ne $lastSynced) { $lastSynced } else { 'N/A' }

    $actionLinkMarkdown = ''
    if (-not [string]::IsNullOrWhiteSpace($actionUrl)) {
        $actionLinkMarkdown = "[$profileTitle]($actionUrl)"
    }
    elseif (-not [string]::IsNullOrWhiteSpace($profileTitle)) {
        $actionLinkMarkdown = $profileTitle
    }
    else {
        $actionLinkMarkdown = 'Remove dormant accounts from sensitive groups'
    }

    $tableRows = "| $actionLinkMarkdown | $scoreDisplay | $maxDisplay | $pctDisplay | $statusDisplay | $syncDisplay |`n"

    $mdFailLink = ''
    if (-not $passed) {
        $mdFailLink = "`n[Defender XDR > Secure Score > Recommendations]($defenderLink)`n"
    }

    $mdTable = @"

$mdFailLink
| Recommendation title | Current score | Maximum score | Score % | Implementation status | Last synced |
| :------------------- | :-----------: | :-----------: | :-----: | :-------------------- | :---------- |
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
