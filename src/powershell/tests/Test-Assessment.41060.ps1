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
        CompatibleLicense = ('ATA'),
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

    # Q1a: Read the pinned MDATP Secure Score control profiles (scid_2016, scid_5094, scid_6094).
    # The OData $filter contains single quotes and parentheses, so it is URL-encoded before use.
    Write-ZtProgress -Activity $activity -Status 'Getting MDATP Secure Score control profiles for cloud delivered protection'

    $investigateParams = @{
        TestId       = '41060'
        Title        = 'Cloud-delivered protection is enabled in Microsoft Defender Antivirus'
        Status       = $false
        CustomStatus = 'Investigate'
        Result       = "⚠️ The pinned cloud protection Secure Score controls or latest Secure Score snapshot could not be read due to a permission or connectivity error. Verify the caller has the ``SecurityEvents.Read.All`` Graph permission (Entra role: Security Reader) and re-run."
    }

    $controlProfiles = @()
    try {
        $filter = "service eq 'MDATP' and (id eq 'scid_2016' or id eq 'scid_5094' or id eq 'scid_6094')"
        $controlProfiles = @(Invoke-ZtGraphRequest `
                -RelativeUri "security/secureScoreControlProfiles" `
                -Filter $filter `
                -ApiVersion beta `
                -ErrorAction Stop)
        Write-PSFMessage "Q1a returned $($controlProfiles.Count) MDATP control profile(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
        if ($statusCode -eq 404) {
            Write-PSFMessage "MDATP Secure Score control profiles returned HTTP $statusCode — Microsoft Defender for Endpoint is likely not onboarded for this tenant." -Tag Test -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
            return
        }
        elseif ($statusCode -in (401, 403)) {
            Write-PSFMessage "Failed to get MDATP Secure Score control profiles due to authorization issues (HTTP $statusCode). Make sure the required permissions are granted and roles are activated: $_" -Tag Test -Level Warning
            $investigateParams.Result = "⚠️ Unable to retrieve MDATP cloud protection Secure Score control profiles. Make sure the required permissions are granted and roles are activated: `SecurityEvents.Read.All` Graph permission (Entra role: Security Reader)."
            Add-ZtTestResultDetail @investigateParams
            return
        }

        # any other error (network, 5xx, etc.) is treated as an investigate condition.
        Write-PSFMessage "Failed to get MDATP Secure Score control profiles (HTTP $statusCode): $_" -Tag Test -Level Warning
        Add-ZtTestResultDetail @investigateParams
        return
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
                -ApiVersion beta `
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
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
        if ($statusCode -eq 404) {
            Write-PSFMessage "Secure Score API returned HTTP $statusCode — the Microsoft Secure Score service is likely not available or not licensed for this tenant." -Tag Test -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
            return
        }
        elseif ($statusCode -in (401, 403)) {
            Write-PSFMessage "Failed to get latest Secure Score snapshot due to authorization issues (HTTP $statusCode). Make sure the required permissions are granted and roles are activated: $_" -Tag Test -Level Warning
            $investigateParams.Result = "⚠️ Unable to retrieve the latest Secure Score snapshot. Make sure the required permissions are granted and roles are activated: `SecurityEvents.Read.All` Graph permission (Entra role: Security Reader)."
            Add-ZtTestResultDetail @investigateParams
            return
        }

        # any other error (network, 5xx, etc.) is treated as an investigate condition.
        Write-PSFMessage "Failed to get latest Secure Score snapshot (HTTP $statusCode): $_" -Tag Test -Level Warning
        Add-ZtTestResultDetail @investigateParams
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Investigate: no pinned control profiles returned, or no Secure Score snapshot available.
    if ($controlProfiles.Count -eq 0) {
        $investigateParams.Result = "⚠️ No pinned MDATP cloud protection Secure Score control profiles were returned. The control IDs may not be present for this tenant's Microsoft Defender for Endpoint plan."
        Add-ZtTestResultDetail @investigateParams
        return
    }

    if ($null -eq $latestSecureScore) {
        $investigateParams.Result = '⚠️ No Microsoft Secure Score snapshot was returned, so the pinned cloud protection controls cannot be scored.'
        Add-ZtTestResultDetail @investigateParams
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
        $score = if ($null -ne $matchingScore -and $null -ne $matchingScore.score) { $matchingScore.score } else { $null }
        $maxScore = if ($null -ne $controlProfile.maxScore) { $controlProfile.maxScore } else { $null }

        # The most recent controlStateUpdates entry carries the resolved state ('Ignored',
        # 'Default', ...) and its updatedDateTime. Fall back to the profile-level
        # lastModifiedDateTime (both may be null for never-modified controls).
        $latestStateUpdate = @($controlProfile.controlStateUpdates | Sort-Object updatedDateTime -Descending | Select-Object -First 1)[0]
        $isIgnored = ($null -ne $latestStateUpdate -and $latestStateUpdate.state -eq 'Ignored')
        # Intentional spec deviation: spec maps Last Modified → lastModifiedDateTime, but
        # controlStateUpdates.updatedDateTime is preferred when present because it reflects when
        # the admin last changed the control state (Ignored/Default/etc.), which is more
        # actionable than when the profile object itself was last touched.
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
