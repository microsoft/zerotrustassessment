<#
.SYNOPSIS
    Attack surface reduction (ASR) rules are enabled in block mode.

.DESCRIPTION
    Attack surface reduction rules block high-risk behaviors commonly reused by malware and
    human-operated attacks. This check evaluates the pinned ASR Secure Score control set
    (scid_2500 through scid_2518) by joining control profiles to the latest Microsoft Secure Score
    snapshot and comparing each available score with its maximum score.

.NOTES
    Test ID: 41050
    Workshop Task ID: SECOPS-050
    Category: Endpoint threat protection
    Pillar: SecOps
    Required Module: Microsoft.Graph.Authentication
    Required Connection: Microsoft Graph
#>

function Test-Assessment-41050 {
    [ZtTest(
        Category = 'Endpoint threat protection',
        CompatibleLicense = ('WINDEFATP'),
        ImplementationCost = 'Medium',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41050,
        Title = 'Attack surface reduction (ASR) rules are enabled in block mode',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking ASR block-mode controls in Microsoft Secure Score'

    $asrControlIds = @(
        'scid_2500', 'scid_2501', 'scid_2502', 'scid_2503', 'scid_2504',
        'scid_2505', 'scid_2506', 'scid_2507', 'scid_2508', 'scid_2509',
        'scid_2510', 'scid_2511', 'scid_2512', 'scid_2513', 'scid_2514',
        'scid_2515', 'scid_2516', 'scid_2517', 'scid_2518'
    )

    $controlProfileError = $null
    $secureScoreError = $null

    # Q1: Read all MDATP Secure Score control profiles, then intersect client-side with pinned IDs.
    Write-ZtProgress -Activity $activity -Status 'Getting MDATP Secure Score control profiles'

    $mdatpControlProfiles = @()
    try {
        $mdatpControlProfiles = @(Invoke-ZtGraphRequest -RelativeUri 'security/secureScoreControlProfiles' -Filter "service eq 'MDATP'" -ApiVersion beta -ErrorAction Stop)
    }
    catch {
        $controlProfileError = $_
        Write-PSFMessage "Failed to retrieve MDATP Secure Score control profiles: $_" -Tag Test -Level Warning
    }

    # Q2: Read the latest Secure Score snapshot; -DisablePaging returns the wrapper object.
    Write-ZtProgress -Activity $activity -Status 'Getting latest Secure Score snapshot'

    $latestSecureScore = $null
    try {
        $secureScoresResponse = Invoke-ZtGraphRequest -RelativeUri 'security/secureScores' -Top 1 -ApiVersion beta -DisablePaging -ErrorAction Stop
        $secureScores = @($secureScoresResponse.value)
        if ($secureScores.Count -gt 0) {
            $latestSecureScore = $secureScores[0]
        }
    }
    catch {
        $secureScoreError = $_
        Write-PSFMessage "Failed to retrieve latest Secure Score snapshot: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    foreach ($queryError in @($controlProfileError, $secureScoreError) | Where-Object { $null -ne $_ }) {
        if ((Get-ZtHttpStatusCode -ErrorRecord $queryError) -in (401, 403)) {
            $params = @{
                TestId       = '41050'
                Title        = 'Attack surface reduction (ASR) rules are enabled in block mode'
                Status       = $false
                Result       = '⚠️ Microsoft Graph returned HTTP 401 or 403. Verify SecurityEvents.Read.All is granted, Secure Score data is flowing, and at least one MDE device is onboarded.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
            return
        }
    }

    $controlProfileById = @{}
    foreach ($controlProfile in @($mdatpControlProfiles | Where-Object { $asrControlIds -contains $_.id })) {
        if ($null -ne $controlProfile.id -and -not $controlProfileById.ContainsKey($controlProfile.id)) {
            $controlProfileById[$controlProfile.id] = $controlProfile
        }
    }

    if ($controlProfileError -or $secureScoreError -or $null -eq $latestSecureScore) {
        $params = @{
            TestId       = '41050'
            Title        = 'Attack surface reduction (ASR) rules are enabled in block mode'
            Status       = $false
            Result       = '⚠️ ASR Secure Score data was not found; verify SecurityEvents.Read.All is granted, Secure Score data is flowing, and at least one MDE device is onboarded.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $controlScoreByName = @{}
    foreach ($controlScore in @($latestSecureScore.controlScores)) {
        if ($null -ne $controlScore.controlName -and -not $controlScoreByName.ContainsKey($controlScore.controlName)) {
            $controlScoreByName[$controlScore.controlName] = $controlScore
        }
    }

    $evaluationResults = @()
    foreach ($controlId in $asrControlIds) {
        $controlProfile = if ($controlProfileById.ContainsKey($controlId)) { $controlProfileById[$controlId] } else { $null }
        $matchingScore = if ($null -ne $controlProfile -and $controlScoreByName.ContainsKey($controlId)) { $controlScoreByName[$controlId] } else { $null }

        $score = if ($null -ne $matchingScore -and $null -ne $matchingScore.score) { $matchingScore.score } else { $null }
        $maxScore = if ($null -ne $controlProfile -and $null -ne $controlProfile.maxScore) { $controlProfile.maxScore } else { $null }

        $latestStateUpdate = @()
        if ($null -ne $controlProfile) {
            $latestStateUpdate = @($controlProfile.controlStateUpdates | Sort-Object { if ($_.updatedDateTime) { [datetime]$_.updatedDateTime } else { [datetime]::MinValue } } -Descending | Select-Object -First 1)
        }
        $isIgnored = $latestStateUpdate.Count -gt 0 -and $latestStateUpdate[0].state -eq 'ignored'

        $scoreValue = $null
        $scoreIsNumeric = $false
        if ($null -ne $score) {
            try {
                $scoreValue = [double]$score
                $scoreIsNumeric = $true
            }
            catch { }
        }

        $maxScoreValue = $null
        $maxScoreIsNumeric = $false
        if ($null -ne $maxScore) {
            try {
                $maxScoreValue = [double]$maxScore
                $maxScoreIsNumeric = $true
            }
            catch { }
        }

        $notApplicableReason = $null
        $status = if ($null -eq $controlProfile) {
            $notApplicableReason = 'profile not found'
            'N/A'
        }
        elseif ($null -eq $matchingScore) {
            $notApplicableReason = 'no applicable devices'
            'N/A'
        }
        elseif ($isIgnored) {
            'Skipped'
        }
        elseif (-not $scoreIsNumeric -or -not $maxScoreIsNumeric) {
            'Investigate'
        }
        elseif ($scoreValue -ge $maxScoreValue) {
            'Pass'
        }
        else {
            'Fail'
        }

        $ruleName = if ($null -ne $controlProfile -and -not [string]::IsNullOrWhiteSpace($controlProfile.title)) {
            $controlProfile.title
        }
        else {
            $controlId
        }

        $evaluationResults += [PSCustomObject]@{
            AsrRuleId             = $controlId
            AsrRuleName           = $ruleName
            ActionUrl             = if ($null -ne $controlProfile) { $controlProfile.actionUrl } else { $null }
            Score                 = if ($null -ne $score) { $score } else { 'N/A' }
            MaxScore              = if ($null -ne $maxScore) { $maxScore } else { 'N/A' }
            ImplementationStatus  = if ($null -ne $matchingScore -and -not [string]::IsNullOrWhiteSpace($matchingScore.implementationStatus)) { $matchingScore.implementationStatus } else { 'N/A' }
            LastModifiedDateTime  = if ($null -ne $controlProfile) { $controlProfile.lastModifiedDateTime } else { $null }
            Status                = $status
            NotApplicableReason   = $notApplicableReason
        }
    }

    $failedItems = @($evaluationResults | Where-Object Status -eq 'Fail')
    $passedItems = @($evaluationResults | Where-Object Status -eq 'Pass')

    if ($failedItems.Count -gt 0) {
        $testResultMarkdown = "❌ One or more attack surface reduction rules are in audit / disabled mode (below their target score).`n`n%TestResult%"
    }
    elseif ($passedItems.Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ All applicable attack surface reduction rules are deployed in block mode.`n`n%TestResult%"
    }
    else {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ ASR Secure Score data was not found; verify SecurityEvents.Read.All is granted, Secure Score data is flowing, and at least one MDE device is onboarded.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $totalCount = $evaluationResults.Count
    $countLine = "Total ASR controls evaluated: $totalCount"
    $asrPoliciesLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/asr'
    $asrDefenderLink = 'https://security.microsoft.com/asr'

    $portalLinks = "[Microsoft Intune ASR Policies]($asrPoliciesLink) | [Defender XDR > Endpoints > Attack surface reduction]($asrDefenderLink)"

    $tableRows = ''
    foreach ($result in $evaluationResults) {
        $statusDisplay = switch ($result.Status) {
            'Pass' { '✅ Pass' }
            'Fail' { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
            'N/A' { "N/A ($($result.NotApplicableReason))" }
            default { 'Skipped' }
        }
        $lastModified = if ($result.LastModifiedDateTime) { Get-FormattedDate -DateString $result.LastModifiedDateTime } else { 'N/A' }
        $safeRuleName = Get-SafeMarkdown -Text $result.AsrRuleName
        $ruleDisplay = if (-not [string]::IsNullOrWhiteSpace($result.ActionUrl)) {
            "[$safeRuleName]($($result.ActionUrl)) ($($result.AsrRuleId))"
        }
        elseif ($result.AsrRuleName -ne $result.AsrRuleId) {
            "$safeRuleName ($($result.AsrRuleId))"
        }
        else {
            $safeRuleName
        }
        $tableRows += "| $ruleDisplay | $($result.Score) | $($result.MaxScore) | $($result.ImplementationStatus) | $lastModified | $statusDisplay |`n"
    }

    $mdInfo = @"
$countLine

$portalLinks

| ASR rule (id) | Score | Max score | Implementation status | Last modified | Status |
| :------------ | ----: | --------: | :-------------------- | :------------ | :----- |
$tableRows
"@

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41050'
        Title  = 'Attack surface reduction (ASR) rules are enabled in block mode'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
