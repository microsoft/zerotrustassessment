<#
.SYNOPSIS
    Microsoft Entra Connect synchronization account does not hold unnecessary replication permissions

.NOTES
    Test ID: 41012
    Workshop Task: SECOPS-012
    Pillar: SecOps
    Category: Identity threat protection
    Required permission: SecurityEvents.Read.All
#>

function Test-Assessment-41012 {
    [ZtTest(
        Category           = 'Identity threat protection',
        CompatibleLicense  = ('ATA'),
        ImplementationCost = 'Medium',
        Pillar             = 'SecOps',
        RiskLevel          = 'High',
        Service            = ('Graph'),
        SfiPillar          = 'Protect identities and secrets',
        TenantType         = ('Workforce'),
        TestId             = 41012,
        Title              = 'Microsoft Entra Connect synchronization account does not hold unnecessary replication permissions',
        UserImpact         = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity       = 'Checking Microsoft Entra Connect synchronization account replication permissions'
    $title          = 'Microsoft Entra Connect synchronization account does not hold unnecessary replication permissions'
    $controlId      = 'AATP_EntraConnectAccountUnnecessaryReplicationPermission'
    $controlService = 'Azure ATP'
    $defenderLink   = 'https://security.microsoft.com/securescore?viewid=actions'

    $investigateParams = @{
        TestId       = '41012'
        Title        = $title
        Status       = $false
        CustomStatus = 'Investigate'
        Result       = '⚠️ The Secure Score control profile or latest Secure Score snapshot could not be read due to a permission or connectivity error. Verify the caller has SecurityEvents.Read.All (Entra role: Security Reader) and re-run.'
    }

    # Q1: filtered MDI Secure Score control profile.
    Write-ZtProgress -Activity $activity -Status 'Retrieving the MDI Secure Score control profile'
    $profileResults = @()
    try {
        $q1Filter = "service eq '$controlService' and id eq '$controlId'"
        $profileResults = @(Invoke-ZtGraphRequest -RelativeUri 'security/secureScoreControlProfiles' -Filter $q1Filter -ApiVersion beta -ErrorAction Stop)
    }
    catch {
        $q1Status = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Q1 failed. HTTP status: $q1Status. $_" -Tag Test -Level Warning
        if ($q1Status -in (401, 403)) {
            $investigateParams.Result = '⚠️ The Secure Score control profile could not be read because the request was not authorized. Verify the caller has SecurityEvents.Read.All (Entra role: Security Reader) and re-run.'
        }
        Add-ZtTestResultDetail @investigateParams
        return
    }

    if ($profileResults.Count -ne 1) {
        $investigateParams.Result = "⚠️ The MDI Secure Score control profile lookup returned $($profileResults.Count) matching profile(s); exactly one is required."
        Add-ZtTestResultDetail @investigateParams
        return
    }

    $controlProfile = $profileResults[0]
    if ($controlProfile.id -ne $controlId -or $controlProfile.service -ne $controlService) {
        $investigateParams.Result = '⚠️ The MDI Secure Score control profile lookup returned a profile that does not match the required identifier and service.'
        Add-ZtTestResultDetail @investigateParams
        return
    }

    if ($controlProfile.deprecated -eq $true) {
        $investigateParams.Result = '⚠️ The Secure Score recommendation is deprecated and cannot be evaluated automatically.'
        Add-ZtTestResultDetail @investigateParams
        return
    }

    # Q2: latest Secure Score snapshot only; -DisablePaging keeps `$top=1` honest.
    Write-ZtProgress -Activity $activity -Status 'Retrieving the latest Microsoft Secure Score snapshot'
    $secureScoresResponse = $null
    try {
        $secureScoresResponse = Invoke-ZtGraphRequest -RelativeUri 'security/secureScores' -Top 1 -ApiVersion beta -DisablePaging -ErrorAction Stop
    }
    catch {
        $q2Status = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Q2 failed. HTTP status: $q2Status. $_" -Tag Test -Level Warning
        Add-ZtTestResultDetail @investigateParams
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed              = $false
    $customStatus        = $null
    $reason              = $null
    $controlScoreEntry   = $null
    $currentScore        = $null
    $scorePercentage     = $null
    $snapshotTime        = $null
    $controlState        = $null
    $numericGuardsPassed = $false

    $maxScore = $controlProfile.maxScore

    # Invoke-ZtGraphRequest -OutputType PSObject deserializes Graph date-time strings into [datetime]
    # (Kind=Utc). Stringifying with the current culture and reparsing loses the ISO 8601 shape, so accept
    # native [datetime]/[datetimeoffset] directly and parse strings with invariant culture + RoundtripKind.
    $parseTimestamp = {
        param($value)
        if ($null -eq $value) { return $null }
        if ($value -is [datetimeoffset]) { return $value.ToUniversalTime() }
        if ($value -is [datetime]) {
            $dt = if ($value.Kind -eq [System.DateTimeKind]::Unspecified) { [datetime]::SpecifyKind($value, [System.DateTimeKind]::Utc) } else { $value }
            return ([datetimeoffset]$dt).ToUniversalTime()
        }
        $text = [string]$value
        if ([string]::IsNullOrWhiteSpace($text)) { return $null }
        $parsed = [datetimeoffset]::MinValue
        if ([datetimeoffset]::TryParse($text, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind, [ref]$parsed)) {
            return $parsed.ToUniversalTime()
        }
        return $null
    }

    # Resolve the latest administrative state per spec: undated Default is baseline; a dated non-Default
    # entry overrides; ties on the latest timestamp and undated non-Default entries are Investigate.
    if ($controlProfile.PSObject.Properties.Name -notcontains 'controlStateUpdates') {
        $reason = 'The control profile is missing controlStateUpdates.'
    }
    elseif ($null -eq $controlProfile.controlStateUpdates) {
        $controlState = 'Default'
    }
    elseif ($controlProfile.controlStateUpdates -is [string] -or $controlProfile.controlStateUpdates -isnot [System.Collections.IEnumerable]) {
        $reason = 'The controlStateUpdates value is malformed.'
    }
    else {
        $stateUpdates      = @($controlProfile.controlStateUpdates)
        $datedStateUpdates = @()
        foreach ($stateUpdate in $stateUpdates) {
            if ($reason) { break }
            $state = if ($null -ne $stateUpdate) { [string]$stateUpdate.state } else { $null }
            if ([string]::IsNullOrWhiteSpace($state) -or $state -notin @('Default', 'Ignored', 'ThirdParty', 'Reviewed')) {
                $reason = 'The control profile contains a missing or unrecognized administrative state.'
                break
            }
            $rawUpdatedAt = $stateUpdate.updatedDateTime
            $isUpdatedAtMissing = ($null -eq $rawUpdatedAt) -or (($rawUpdatedAt -is [string]) -and [string]::IsNullOrWhiteSpace($rawUpdatedAt))
            if ($isUpdatedAtMissing) {
                if ($state -ine 'Default') {
                    $reason = 'The control profile contains an undated non-Default administrative state.'
                }
                continue
            }
            $parsedStateTime = & $parseTimestamp $rawUpdatedAt
            if ($null -eq $parsedStateTime -or $parsedStateTime -gt [datetimeoffset]::UtcNow) {
                $reason = 'The control profile contains an invalid or future administrative-state timestamp.'
                break
            }
            $datedStateUpdates += [PSCustomObject]@{
                State = $state
                Time  = $parsedStateTime
            }
        }
        if (-not $reason) {
            if ($datedStateUpdates.Count -gt 0) {
                $latestTime   = ($datedStateUpdates | Sort-Object Time -Descending | Select-Object -First 1).Time
                $latestStates = @($datedStateUpdates | Where-Object Time -eq $latestTime | Select-Object -ExpandProperty State -Unique)
                if ($latestStates.Count -ne 1) {
                    $reason = 'The latest administrative-state updates conflict.'
                }
                else {
                    $controlState = $latestStates[0]
                }
            }
            elseif (-not $controlState) {
                $controlState = 'Default'
            }
        }
    }

    if (-not $reason -and $controlState -ine 'Default') {
        $reason = "The recommendation has the administrative state $controlState; verify the underlying permissions in Defender XDR."
    }

    # Validate Q2 shape and locate the matching per-control score entry.
    if (-not $reason) {
        if ($null -eq $secureScoresResponse -or $secureScoresResponse.PSObject.Properties.Name -notcontains 'value') {
            $reason = 'The latest Secure Score response is missing the snapshot collection.'
        }
        elseif ($secureScoresResponse.value -is [string] -or $secureScoresResponse.value -isnot [System.Collections.IEnumerable]) {
            $reason = 'The latest Secure Score response contains a malformed snapshot collection.'
        }
        else {
            $secureScores = @($secureScoresResponse.value)
            if ($secureScores.Count -ne 1) {
                $reason = "The latest Secure Score response returned $($secureScores.Count) snapshots; exactly one is required."
            }
            else {
                $latestSecureScore  = $secureScores[0]
                $parsedSnapshotTime = & $parseTimestamp $latestSecureScore.createdDateTime
                if ($null -eq $parsedSnapshotTime -or $parsedSnapshotTime -gt [datetimeoffset]::UtcNow) {
                    $reason = 'The latest Secure Score snapshot has a missing, invalid, or future timestamp.'
                }
                else {
                    $snapshotTime = $parsedSnapshotTime
                    if ($latestSecureScore.PSObject.Properties.Name -notcontains 'controlScores' -or $null -eq $latestSecureScore.controlScores -or $latestSecureScore.controlScores -is [string] -or $latestSecureScore.controlScores -isnot [System.Collections.IEnumerable]) {
                        $reason = 'The latest Secure Score snapshot has a missing or malformed controlScores collection.'
                    }
                    else {
                        $matchingScores = @($latestSecureScore.controlScores | Where-Object controlName -eq $controlId)
                        if ($matchingScores.Count -ne 1) {
                            $reason = "The latest Secure Score snapshot contains $($matchingScores.Count) matching control scores; exactly one is required."
                        }
                        else {
                            $controlScoreEntry = $matchingScores[0]
                            $currentScore      = $controlScoreEntry.score
                        }
                    }
                }
            }
        }
    }

    # Numeric guards: profile maxScore and score must both be finite JSON numbers with score in [0, maxScore].
    if (-not $reason) {
        $numericTypes   = @('Byte','SByte','Int16','UInt16','Int32','UInt32','Int64','UInt64','Single','Double','Decimal')
        $maxIsNumeric   = $null -ne $maxScore     -and $maxScore.GetType().Name     -in $numericTypes
        $scoreIsNumeric = $null -ne $currentScore -and $currentScore.GetType().Name -in $numericTypes
        if (-not $maxIsNumeric -or -not $scoreIsNumeric) {
            $reason = 'The current score or maximum score is missing or is not a JSON number.'
        }
        else {
            $maxD = [double]$maxScore
            $curD = [double]$currentScore
            if ([double]::IsNaN($maxD) -or [double]::IsInfinity($maxD) -or [double]::IsNaN($curD) -or [double]::IsInfinity($curD) -or $maxD -le 0 -or $curD -lt 0 -or $curD -gt $maxD) {
                $reason = 'The current score or maximum score is outside the valid range.'
            }
            else {
                $numericGuardsPassed = $true
                $scorePercentage     = 100 * ($curD / $maxD)
            }
        }
    }

    if ($numericGuardsPassed -and $currentScore -eq $maxScore) {
        $passed             = $true
        $reason             = 'The current score equals the recommendation maximum.'
        $testResultMarkdown = "✅ The latest Microsoft Defender for Identity Secure Score assessment reports no unnecessary replication permissions for monitored Microsoft Entra Connect synchronization accounts.`n`n%TestResult%"
    }
    elseif ($numericGuardsPassed) {
        $reason             = 'The current score is below the recommendation maximum.'
        $testResultMarkdown = "❌ The latest Microsoft Defender for Identity Secure Score assessment reports unnecessary replication permissions for one or more monitored Microsoft Entra Connect synchronization accounts; review the exposed accounts in Defender XDR before removing permissions.`n`n%TestResult%"
    }
    else {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ The assessment could not be evaluated reliably because evidence is unavailable, incomplete, invalid, or administratively overridden. Review the reported reason and verify MDI sensor coverage and the recommendation in Defender XDR.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $recommendationTitle   = if (-not [string]::IsNullOrWhiteSpace([string]$controlProfile.title)) { [string]$controlProfile.title } else { $title }
    $scoreDisplay          = if ($numericGuardsPassed) { "$currentScore / $maxScore" } else { '—' }
    $percentageDisplay     = if ($null -ne $scorePercentage) { '{0:N2}%' -f $scorePercentage } else { '—' }
    $implementationDisplay = if ($null -ne $controlScoreEntry -and -not [string]::IsNullOrWhiteSpace([string]$controlScoreEntry.implementationStatus)) { [string]$controlScoreEntry.implementationStatus } else { '—' }

    $lastSyncedRaw     = if ($null -ne $controlScoreEntry) { $controlScoreEntry.lastSynced } else { $null }
    $lastSyncedTime    = & $parseTimestamp $lastSyncedRaw
    $lastSyncedDisplay = if ($null -ne $lastSyncedTime) {
        Get-FormattedDate -DateString $lastSyncedTime.ToString('o')
    } else { '—' }

    $snapshotDisplay     = if ($null -ne $snapshotTime) { Get-FormattedDate -DateString $snapshotTime.ToString('o') } else { '—' }
    $controlStateDisplay = if ($controlState) { $controlState } else { '—' }
    $statusDisplay       = if ($passed) { '✅ Pass' } elseif ($customStatus -eq 'Investigate') { '⚠️ Investigate' } else { '❌ Fail' }

    # Prefer Q1 actionUrl when it's a valid HTTPS URL; otherwise link to the Defender XDR recommendations list.
    $parsedActionUrl   = $null
    $recommendationUrl = if ([uri]::TryCreate([string]$controlProfile.actionUrl, [System.UriKind]::Absolute, [ref]$parsedActionUrl) -and $parsedActionUrl.Scheme -eq 'https') {
        $parsedActionUrl.AbsoluteUri
    } else {
        $defenderLink
    }

    $safeRecommendationTitle = Get-SafeMarkdown -Text $recommendationTitle

    $recommendationDisplay = if (-not $passed) { "[$safeRecommendationTitle]($recommendationUrl)" } else { $safeRecommendationTitle }
    $portalInstruction     = if (-not $passed -and $recommendationUrl -eq $defenderLink) { "Review [Defender XDR > Secure Score > Recommendations]($defenderLink) and find the named recommendation.`n`n" } else { '' }

    $formatTemplate = @'


{0}| Recommendation title | Current score / Maximum score | Score percentage | Implementation status | Last synced | Snapshot time (UTC) | Control state | Status | Reason |
| :------------------- | :---------------------------- | :--------------- | :-------------------- | :---------- | :------------------ | :------------ | :----- | :----- |
| {1} | {2} | {3} | {4} | {5} | {6} | {7} | {8} | {9} |
'@
    $mdInfo             = $formatTemplate -f $portalInstruction, $recommendationDisplay, $scoreDisplay, $percentageDisplay, $implementationDisplay, $lastSyncedDisplay, $snapshotDisplay, $controlStateDisplay, $statusDisplay, $reason
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41012'
        Title  = $title
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}