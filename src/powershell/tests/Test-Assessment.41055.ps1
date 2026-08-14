<#
.SYNOPSIS
    Real-time, behavioral, and heuristic protection are enabled on Microsoft Defender Antivirus.

.DESCRIPTION
    Evaluates the pinned Microsoft Defender Antivirus Secure Score controls by joining control
    profiles to the latest Microsoft Secure Score snapshot and comparing each achieved score with
    its maximum score. Controls with missing profiles, controls without applicable devices, and
    ignored controls are excluded from the roll-up.

.NOTES
    Test ID: 41055
    Workshop Task ID: SECOPS-055
    Category: Endpoint threat protection
    Pillar: SecOps
    Required Module: Microsoft.Graph.Authentication
    Required Connection: Microsoft Graph
#>

function Test-Assessment-41055 {
    [ZtTest(
        Category = 'Endpoint threat protection',
        CompatibleLicense = ('WINDEFATP', 'MDE_LITE'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41055,
        Title = 'Real-time, behavioral, and heuristic protection are enabled on Microsoft Defender Antivirus',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Microsoft Defender Antivirus protection controls in Microsoft Secure Score'
    $defenderAntivirusControlIds = @(
        'scid_2012', 'scid_91', 'scid_92', 'scid_89', 'scid_90', 'scid_5093', 'scid_6093'
    )
    $controlProfileError = $null
    $secureScoreError = $null

    # Q1: Read MDATP Secure Score control profiles, then intersect client-side with pinned IDs.
    Write-ZtProgress -Activity $activity -Status 'Getting MDATP Secure Score control profiles'

    $mdatpControlProfiles = @()
    try {
        $controlProfileFilter = "service eq 'MDATP' and (id eq 'scid_2012' or id eq 'scid_91' or id eq 'scid_92' or id eq 'scid_89' or id eq 'scid_90' or id eq 'scid_5093' or id eq 'scid_6093')"
        $mdatpControlProfiles = @(Invoke-ZtGraphRequest -RelativeUri 'security/secureScoreControlProfiles' -Filter $controlProfileFilter -ApiVersion beta -ErrorAction Stop)
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
                TestId       = '41055'
                Title        = 'Real-time, behavioral, and heuristic protection are enabled on Microsoft Defender Antivirus'
                Status       = $false
                Result       = '⚠️ Microsoft Graph returned HTTP 401 or 403. Verify SecurityEvents.Read.All is granted, Secure Score data is flowing, and at least one MDE device is onboarded.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
            return
        }
    }

    $controlProfileById = @{}
    foreach ($controlProfile in @($mdatpControlProfiles | Where-Object { $defenderAntivirusControlIds -contains $_.id })) {
        if ($null -ne $controlProfile.id -and -not $controlProfileById.ContainsKey($controlProfile.id)) {
            $controlProfileById[$controlProfile.id] = $controlProfile
        }
    }

    if ($controlProfileError -or $secureScoreError -or $null -eq $latestSecureScore -or $controlProfileById.Count -eq 0) {
        $params = @{
            TestId       = '41055'
            Title        = 'Real-time, behavioral, and heuristic protection are enabled on Microsoft Defender Antivirus'
            Status       = $false
            Result       = '⚠️ No Microsoft Defender Antivirus Secure Score control could be evaluated; verify SecurityEvents.Read.All is granted, Secure Score data is flowing, and at least one MDE device is onboarded.'
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
    foreach ($controlId in $defenderAntivirusControlIds) {
        $controlProfile = if ($controlProfileById.ContainsKey($controlId)) { $controlProfileById[$controlId] } else { $null }
        $matchingScore = if ($controlScoreByName.ContainsKey($controlId)) { $controlScoreByName[$controlId] } else { $null }

        $latestStateUpdate = @()
        if ($null -ne $controlProfile) {
            $latestStateUpdate = @($controlProfile.controlStateUpdates | Sort-Object { if ($_.updatedDateTime) { [datetime]$_.updatedDateTime } else { [datetime]::MinValue } } -Descending | Select-Object -First 1)
        }
        $controlState = if ($latestStateUpdate.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($latestStateUpdate[0].state)) { $latestStateUpdate[0].state } else { 'N/A' }
        $isIgnored = $latestStateUpdate.Count -gt 0 -and $latestStateUpdate[0].state -eq 'ignored'

        $score = if ($null -ne $matchingScore -and $null -ne $matchingScore.score) { $matchingScore.score } else { $null }
        $maxScore = if ($null -ne $controlProfile -and $null -ne $controlProfile.maxScore) { $controlProfile.maxScore } else { $null }
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

        $statusReason = $null
        $status = if ($null -eq $controlProfile) {
            $statusReason = 'profile not found'
            'N/A'
        }
        elseif ($null -eq $matchingScore) {
            $statusReason = 'no applicable devices'
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

        $controlTitle = if ($null -ne $controlProfile -and -not [string]::IsNullOrWhiteSpace($controlProfile.title)) {
            $controlProfile.title
        }
        else {
            $controlId
        }

        $evaluationResults += [PSCustomObject]@{
            ControlId             = $controlId
            ControlTitle          = $controlTitle
            ActionUrl             = if ($null -ne $controlProfile) { $controlProfile.actionUrl } else { $null }
            Score                 = if ($null -ne $score) { $score } else { 'N/A' }
            MaxScore              = if ($null -ne $maxScore) { $maxScore } else { 'N/A' }
            ImplementationStatus  = if ($null -ne $matchingScore -and -not [string]::IsNullOrWhiteSpace($matchingScore.implementationStatus)) { $matchingScore.implementationStatus } else { 'N/A' }
            State                 = $controlState
            LastModifiedDateTime  = if ($null -ne $controlProfile) { $controlProfile.lastModifiedDateTime } else { $null }
            Status                = $status
            StatusReason          = $statusReason
        }
    }

    $failedItems = @($evaluationResults | Where-Object Status -eq 'Fail')
    $passedItems = @($evaluationResults | Where-Object Status -eq 'Pass')

    if ($failedItems.Count -gt 0) {
        $testResultMarkdown = "❌ One or more of real-time, behavioral, or heuristic scanning is disabled.`n`n%TestResult%"
    }
    elseif ($passedItems.Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ Real-time, behavioral, and heuristic protection on Microsoft Defender Antivirus are enabled.`n`n%TestResult%"
    }
    else {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ No Microsoft Defender Antivirus Secure Score control could be evaluated; verify SecurityEvents.Read.All is granted, Secure Score data is flowing, and at least one MDE device is onboarded.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $totalCount = $evaluationResults.Count
    $countLine = "Total Microsoft Defender Antivirus controls evaluated: $totalCount"
    $secureScoreLink = '[Microsoft Secure Score](https://security.microsoft.com/securescore)'

    $tableRows = ''
    foreach ($result in $evaluationResults) {
        $statusDisplay = switch ($result.Status) {
            'Pass' { '✅ Pass' }
            'Fail' { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
            'N/A' { "N/A ($($result.StatusReason))" }
            default { 'Skipped' }
        }
        $lastModified = if ($result.LastModifiedDateTime) { Get-FormattedDate -DateString $result.LastModifiedDateTime } else { 'N/A' }
        $safeControlTitle = Get-SafeMarkdown -Text $result.ControlTitle
        $controlDisplay = if (-not [string]::IsNullOrWhiteSpace($result.ActionUrl)) {
            "[$safeControlTitle]($($result.ActionUrl)) ($($result.ControlId))"
        }
        elseif ($result.ControlTitle -ne $result.ControlId) {
            "$safeControlTitle ($($result.ControlId))"
        }
        else {
            $safeControlTitle
        }
        $tableRows += "| $controlDisplay | $($result.Score) | $($result.MaxScore) | $($result.ImplementationStatus) | $($result.State) | $lastModified | $statusDisplay |`n"
    }

    $controlTable = @"
| Control title (id) | Score | Max score | Implementation status | State | Last modified | Status |
| :----------------- | ----: | --------: | :-------------------- | :---- | :------------ | :----- |
$tableRows
"@
    $formatTemplate = @'
{0}

{1}

{2}
'@
    $mdInfo = $formatTemplate -f $countLine, $secureScoreLink, $controlTable
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41055'
        Title  = 'Real-time, behavioral, and heuristic protection are enabled on Microsoft Defender Antivirus'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
