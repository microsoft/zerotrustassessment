<#
.SYNOPSIS
    Cloud-delivered protection is enabled in Microsoft Defender Antivirus

.DESCRIPTION
    Cloud-delivered protection connects Microsoft Defender Antivirus to Microsoft cloud protection
    services to provide accurate, real-time, and intelligent protection, identifying new threats
    sometimes before any endpoint is infected. Some Defender for Endpoint capabilities, including
    block at first sight and certain attack surface reduction protections, depend on it. This check
    reads the pinned MDATP Secure Score control IDs (scid_2016, scid_5094, scid_6094) and requires
    every returned control to be fully scored and not ignored.

.NOTES
    Test ID: 41060
    Workshop Task Id: SECOPS-060
    Category: Endpoint threat protection
    Pillar: SecOps
    Required Module: Microsoft.Graph.Authentication
    Required Connection: Microsoft Graph
#>

function Test-Assessment-41060 {
    [ZtTest(
        Category = 'Endpoint threat protection',
        ImplementationCost = 'Low',
        Service = ('Graph'),
        CompatibleLicense = ('WIN_DEF_ATP', 'MDE_LITE'),
        Pillar = 'SecOps',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41060,
        Title = 'Cloud-delivered protection is enabled in Microsoft Defender Antivirus',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking cloud-delivered protection in Microsoft Defender Antivirus'

    $profileQueryFailed = $false
    $scoreQueryFailed = $false

    # Q1a: Read the pinned MDATP Secure Score control profiles (scid_2016, scid_5094, scid_6094).
    # The OData $filter contains single quotes and parentheses, so it is URL-encoded before use.
    Write-ZtProgress -Activity $activity -Status 'Getting MDATP Secure Score control profiles'

    $controlProfiles = @()
    try {
        $filter = "service eq 'MDATP' and (id eq 'scid_2016' or id eq 'scid_5094' or id eq 'scid_6094')"
        $controlProfiles = @(Invoke-ZtGraphRequest `
                -RelativeUri "security/secureScoreControlProfiles" `
                -Filter $filter `
                -ApiVersion v1.0 `
                -ErrorAction Stop)
        Write-PSFMessage "Q1a returned $($controlProfiles.Count) MDATP control profile(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        $profileQueryFailed = $true
        Write-PSFMessage "Failed to get MDATP Secure Score control profiles: $_" -Tag Test -Level Warning
    }

    # Q1b: Read the most recent Secure Score snapshot.
    Write-ZtProgress -Activity $activity -Status 'Getting latest Secure Score snapshot'

    $latestSecureScore = $null
    try {
        # -DisablePaging returns the raw Graph response wrapper (avoids paging the full score
        # history that $top=1 would otherwise trigger via the nextLink). Unwrap .value to get the
        # actual secureScore snapshot(s).
        $secureScoresResponse = Invoke-ZtGraphRequest `
                -RelativeUri 'security/secureScores' `
                -ApiVersion v1.0 `
                -Top 1 `
                -ErrorAction Stop `
                -DisablePaging
        $secureScores = @($secureScoresResponse.value)
        if ($secureScores.Count -gt 0) {
            $latestSecureScore = $secureScores[0]
        }
        Write-PSFMessage "Q1b returned $($secureScores.Count) Secure Score snapshot(s)" -Tag Test -Level Debug
    }
    catch {
        $scoreQueryFailed = $true
        Write-PSFMessage "Failed to get latest Secure Score snapshot: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    # Investigate: either query failed (permission/HTTP error) — cannot determine posture.
    if ($profileQueryFailed -or $scoreQueryFailed) {
        Add-ZtTestResultDetail -TestId '41060' `
            -Title 'Cloud-delivered protection is enabled in Microsoft Defender Antivirus' `
            -Status $false -CustomStatus 'Investigate' `
            -Result "⚠️ The pinned cloud protection Secure Score controls or latest Secure Score snapshot could not be read. This may indicate a permission or connectivity issue. The least-privileged Graph permission is ``SecurityEvents.Read.All`` (Entra role: Security Reader)."
        return
    }

    # Investigate: no pinned control profiles returned, or no Secure Score snapshot available.
    if ($controlProfiles.Count -eq 0) {
        Add-ZtTestResultDetail -TestId '41060' `
            -Title 'Cloud-delivered protection is enabled in Microsoft Defender Antivirus' `
            -Status $false -CustomStatus 'Investigate' `
            -Result "⚠️ No pinned MDATP cloud protection Secure Score control profiles were returned. The control IDs may not be present for this tenant's Microsoft Defender for Endpoint plan."
        return
    }

    if ($null -eq $latestSecureScore) {
        Add-ZtTestResultDetail -TestId '41060' `
            -Title 'Cloud-delivered protection is enabled in Microsoft Defender Antivirus' `
            -Status $false -CustomStatus 'Investigate' `
            -Result '⚠️ No Microsoft Secure Score snapshot was returned, so the pinned cloud protection controls cannot be scored.'
        return
    }

    # Build a lookup of per-control scores from the latest snapshot, keyed by controlName.
    $controlScoreByName = @{}
    foreach ($controlScore in @($latestSecureScore.controlScores)) {
        if ($null -ne $controlScore.controlName -and -not $controlScoreByName.ContainsKey($controlScore.controlName)) {
            $controlScoreByName[$controlScore.controlName] = $controlScore
        }
    }

    # Evaluate each returned pinned profile: compare its snapshot score against maxScore and
    # confirm it is not Ignored. The secureScoreControlProfile resource has no top-level
    # controlState; the resolved state is carried by the controlStateUpdates collection.
    $evaluationResults = @()
    foreach ($controlProfile in $controlProfiles) {
        $matchingScore = if ($controlScoreByName.ContainsKey($controlProfile.id)) { $controlScoreByName[$controlProfile.id] } else { $null }
        $score = if ($null -ne $matchingScore -and $null -ne $matchingScore.score) { [double]$matchingScore.score } else { $null }
        $maxScore = if ($null -ne $controlProfile.maxScore) { [double]$controlProfile.maxScore } else { $null }

        # The most recent controlStateUpdates entry carries the resolved state ('Ignored',
        # 'Default', ...) and its updatedDateTime. Fall back to the profile-level
        # lastModifiedDateTime (both may be null for never-modified controls).
        $latestStateUpdate = @($controlProfile.controlStateUpdates | Sort-Object updatedDateTime -Descending | Select-Object -First 1)[0]
        $isIgnored = ($null -ne $latestStateUpdate -and $latestStateUpdate.state -eq 'Ignored')
        $lastModified = if ($null -ne $latestStateUpdate -and $null -ne $latestStateUpdate.updatedDateTime) { $latestStateUpdate.updatedDateTime } else { $controlProfile.lastModifiedDateTime }

        $isFullyScored = ($null -ne $score -and $null -ne $maxScore -and $score -ge $maxScore)
        $rowPassed = ($isFullyScored -and -not $isIgnored)

        $evaluationResults += [PSCustomObject]@{
            Title        = $controlProfile.title
            ControlId    = $controlProfile.id
            Score        = if ($null -ne $score) { $score } else { 'N/A' }
            MaxScore     = if ($null -ne $maxScore) { $maxScore } else { 'N/A' }
            Ignored      = if ($isIgnored) { 'Yes' } else { 'No' }
            LastModified = $lastModified
            RowPassed    = $rowPassed
        }
    }

    $failedItems = @($evaluationResults | Where-Object { -not $_.RowPassed })

    # Pass requires every returned pinned profile to be fully scored and not ignored.
    $passed = ($failedItems.Count -eq 0)

    if ($passed) {
        $testResultMarkdown = "✅ Cloud-delivered protection is enabled in Microsoft Defender Antivirus.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Cloud-delivered protection is disabled. One or more pinned Microsoft Defender Antivirus cloud protection controls are not fully scored or are ignored in Microsoft Secure Score.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalLink = 'https://security.microsoft.com/securescore'
    $tableTitle = 'Microsoft Secure Score — Cloud Protection Controls'

    $formatTemplate = @'

## [{0}]({1})

| Control Title | Control Id | Score | Max Score | Ignored | Last Modified | Status |
| :------------ | :--------- | ----: | --------: | :------ | :------------ | :----- |
{2}
'@

    # Surface non-passing controls first so failures are listed at the top.
    $displayResults = @($evaluationResults | Sort-Object RowPassed, Title)

    $tableRows = ''
    foreach ($result in $displayResults) {
        $statusDisplay = if ($result.RowPassed) { '✅ Pass' } else { '❌ Fail' }
        $lastModifiedDisplay = Get-FormattedDate -DateString $result.LastModified
        $tableRows += "| $(Get-SafeMarkdown $result.Title) | $($result.ControlId) | $($result.Score) | $($result.MaxScore) | $($result.Ignored) | $lastModifiedDisplay | $statusDisplay |`n"
    }

    $mdInfo = $formatTemplate -f $tableTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $passedCount = @($evaluationResults | Where-Object RowPassed).Count
    Write-PSFMessage "Emitted $($evaluationResults.Count) control results: $passedCount passed, $($failedItems.Count) failed" -Tag Test -Level VeryVerbose

    Add-ZtTestResultDetail -TestId '41060' `
        -Title 'Cloud-delivered protection is enabled in Microsoft Defender Antivirus' `
        -Status $passed -Result $testResultMarkdown
}
