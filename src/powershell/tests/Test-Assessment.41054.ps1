<#
.SYNOPSIS
    Controlled folder access is enabled in block mode.

.DESCRIPTION
    Evaluates the pinned controlled folder access Secure Score control by joining its control
    profile to the latest Microsoft Secure Score snapshot and comparing the achieved score with
    its maximum score. A missing profile, no applicable devices, or an ignored control produces
    an Investigate result.

.NOTES
    Test ID: 41054
    Workshop Task ID: SECOPS-054
    Category: Endpoint threat protection
    Pillar: SecOps
    Required Module: Microsoft.Graph.Authentication
    Required Connection: Microsoft Graph
#>

function Test-Assessment-41054 {
    [ZtTest(
        Category = 'Endpoint threat protection',
        CompatibleLicense = ('WINDEFATP', 'MDE_LITE'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41054,
        Title = 'Controlled folder access is enabled in block mode',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking controlled folder access in Microsoft Secure Score'
    $controlId = 'scid_2021'
    $controlProfileError = $null
    $secureScoreError = $null

    # Q1: Read the pinned MDATP Secure Score control profile.
    Write-ZtProgress -Activity $activity -Status 'Getting the controlled folder access Secure Score control profile'

    $controlProfiles = @()
    try {
        $controlProfileFilter = "service eq 'MDATP' and id eq '$controlId'"
        $controlProfiles = @(Invoke-ZtGraphRequest -RelativeUri 'security/secureScoreControlProfiles' -Filter $controlProfileFilter -ApiVersion beta -ErrorAction Stop)
    }
    catch {
        $controlProfileError = $_
        Write-PSFMessage "Failed to retrieve the controlled folder access Secure Score control profile: $_" -Tag Test -Level Warning
    }

    # Q2: Read the latest Secure Score snapshot; -DisablePaging returns the wrapper object.
    Write-ZtProgress -Activity $activity -Status 'Getting the latest Secure Score snapshot'

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
        Write-PSFMessage "Failed to retrieve the latest Secure Score snapshot: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null
    $queryErrors = @($controlProfileError, $secureScoreError | Where-Object { $null -ne $_ })

    if ($queryErrors.Count -gt 0) {
        $queryError = $queryErrors[0]
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $queryError
        $errorMessage = switch ($httpStatus) {
            { $_ -in (401, 403) } { 'Microsoft Graph permission issue. Grant SecurityEvents.Read.All; for delegated runs assign Security Reader or Security Administrator.'; break }
            404 { 'The Microsoft Graph endpoint or required resource is unavailable or was not found.'; break }
            429 { 'Microsoft Graph throttled the request. Retry after the Retry-After interval.'; break }
            { $_ -ge 500 -and $_ -le 599 } { "Microsoft Graph returned a transient service error (HTTP $_). Please try again."; break }
            default { 'Microsoft Graph returned an error and the controlled folder access Secure Score control could not be evaluated.' }
        }

        $params = @{
            TestId       = '41054'
            Title        = 'Controlled folder access is enabled in block mode'
            Status       = $false
            Result       = "⚠️ $errorMessage"
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($null -eq $latestSecureScore) {
        $params = @{
            TestId       = '41054'
            Title        = 'Controlled folder access is enabled in block mode'
            Status       = $false
            Result       = '⚠️ The controlled folder access Secure Score control could not be evaluated because no latest Secure Score snapshot was returned; verify SecurityEvents.Read.All is granted, Secure Score data is flowing, and at least one MDE device is onboarded.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $controlProfile = $controlProfiles | Select-Object -First 1
    $matchingScore = @($latestSecureScore.controlScores | Where-Object controlName -eq $controlId | Select-Object -First 1)
    $matchingScore = if ($matchingScore.Count -gt 0) { $matchingScore[0] } else { $null }

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

    $evaluationResult = [PSCustomObject]@{
        ControlId            = $controlId
        ControlTitle         = $controlTitle
        ActionUrl            = if ($null -ne $controlProfile) { $controlProfile.actionUrl } else { $null }
        Score                = if ($null -ne $score) { $score } else { 'N/A' }
        MaxScore             = if ($null -ne $maxScore) { $maxScore } else { 'N/A' }
        ImplementationStatus = if ($null -ne $matchingScore -and -not [string]::IsNullOrWhiteSpace($matchingScore.implementationStatus)) { $matchingScore.implementationStatus } else { 'N/A' }
        State                = $controlState
        LastModifiedDateTime = if ($null -ne $controlProfile) { $controlProfile.lastModifiedDateTime } else { $null }
        Status               = $status
        StatusReason         = $statusReason
    }

    if ($status -eq 'Fail') {
        $testResultMarkdown = "❌ Controlled folder access is below its Secure Score target on one or more applicable devices (for example, disabled or in audit-only mode).`n`n%TestResult%"
    }
    elseif ($status -eq 'Pass') {
        $passed = $true
        $testResultMarkdown = "✅ Controlled folder access is enabled in block mode.`n`n%TestResult%"
    }
    else {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ The controlled folder access Secure Score control could not be evaluated (no pinned profile, no applicable devices, an ignored control, no latest snapshot, or a Microsoft Graph error); verify SecurityEvents.Read.All is granted, Secure Score data is flowing, and at least one MDE device is onboarded.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $statusDisplay = switch ($evaluationResult.Status) {
        'Pass' { '✅ Pass' }
        'Fail' { '❌ Fail' }
        'Investigate' { '⚠️ Investigate' }
        'N/A' { "N/A ($($evaluationResult.StatusReason))" }
        default { 'Skipped' }
    }
    $lastModified = if ($evaluationResult.LastModifiedDateTime) { Get-FormattedDate -DateString $evaluationResult.LastModifiedDateTime } else { 'N/A' }
    $safeControlTitle = Get-SafeMarkdown -Text $evaluationResult.ControlTitle
    $controlDisplay = if (-not [string]::IsNullOrWhiteSpace($evaluationResult.ActionUrl)) {
        "[$safeControlTitle]($($evaluationResult.ActionUrl)) ($($evaluationResult.ControlId))"
    }
    elseif ($evaluationResult.ControlTitle -ne $evaluationResult.ControlId) {
        "$safeControlTitle ($($evaluationResult.ControlId))"
    }
    else {
        $safeControlTitle
    }

    $countLine = 'Total pinned controlled folder access controls: 1'
    $secureScoreLink = '[Microsoft Secure Score](https://security.microsoft.com/securescore)'
    $controlTable = @"
| Control title (id) | Score | Max score | Implementation status | State | Last modified | Status |
| :----------------- | ----: | --------: | :-------------------- | :---- | :------------ | :----- |
| $controlDisplay | $($evaluationResult.Score) | $($evaluationResult.MaxScore) | $($evaluationResult.ImplementationStatus) | $($evaluationResult.State) | $lastModified | $statusDisplay |
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
        TestId = '41054'
        Title  = 'Controlled folder access is enabled in block mode'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
