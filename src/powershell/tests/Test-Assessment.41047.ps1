<#
.SYNOPSIS
    Microsoft Defender Antivirus is set to active mode on all eligible endpoints.

.DESCRIPTION
    Verifies that Microsoft Defender Antivirus is configured in active mode on all eligible Windows
    endpoints by first inspecting Intune Settings Catalog configuration policies for an assigned
    active-mode antivirus policy (Q1). If Intune data is unavailable (HTTP 401/403), the check falls
    back to Microsoft Secure Score controls for the "Turn on Microsoft Defender Antivirus" signal
    (Q2 + Q3). Passive mode, disabled state, or unassigned policy intent all result in a Fail or
    Investigate outcome.

.NOTES
    Test ID: 41047
    Workshop Task: SECOPS-047
    Category: Endpoint threat protection
    Pillar: SecOps
    Required Module: Microsoft.Graph.Authentication
    Required Connection: Connect-ZtAssessment
#>

function Test-Assessment-41047 {
    [ZtTest(
        Category           = 'Endpoint threat protection',
        CompatibleLicense  = ('WINDEFATP','MDE_LITE'),
        ImplementationCost = 'Low',
        Pillar             = 'SecOps',
        RiskLevel          = 'High',
        Service            = ('Graph'),
        SfiPillar          = 'Monitor and detect cyberthreats',
        TenantType         = ('Workforce'),
        TestId             = 41047,
        Title              = 'Microsoft Defender Antivirus is set to active mode on all eligible endpoints',
        UserImpact         = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity  = 'Checking Microsoft Defender Antivirus active mode configuration'
    $testTitle = 'Microsoft Defender Antivirus is set to active mode on all eligible endpoints'

    # All three Defender real-time protection settings must be present and enabled
    # (choiceSettingValue ending in '_1') for a policy to enforce active mode.
    $requiredSettings = @(
        'device_vendor_msft_policy_config_defender_allowrealtimemonitoring',
        'device_vendor_msft_policy_config_defender_allowonaccessprotection',
        'device_vendor_msft_policy_config_defender_allowbehaviormonitoring'
    )

    # --- Q1: Intune Settings Catalog (preferred path) ---
    $q1Fallback   = $false   # true when Q1 returns 401/403 → fall through to Q2/Q3
    $q1QueryError = $null    # non-401/403 failure on the list call
    $avPolicies   = @()      # matching policies with active-mode AV settings + assignment

    Write-ZtProgress -Activity $activity -Status 'Reading assigned Intune configuration policies (Q1)'
    try {
        # Fetch only assigned policies with assignments embedded — skips unassigned policies
        # entirely and avoids a separate per-policy assignments call.
        $assignedPolicies = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies?`$expand=assignments" -Filter 'assignments/any()' -ApiVersion beta -ErrorAction Stop)

        foreach ($policy in $assignedPolicies) {
            # Fan out to get settings only for this already-assigned policy.
            $policySettings = $null
            try {
                $policySettings = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies/$($policy.id)/settings" -ApiVersion beta -ErrorAction Stop)
            }
            catch {
                Write-PSFMessage "Skipping settings for policy '$($policy.name)': $_" -Tag Test -Level Warning
                continue
            }

            # A policy enforces active mode only when all three required settings are present
            # and each has a choice value ending in '_1' (enabled).
            $enabledSettings = @()
            foreach ($setting in $policySettings) {
                $defId = $setting.settingInstance.settingDefinitionId
                if ([string]::IsNullOrWhiteSpace($defId)) { continue }
                $defIdLower = $defId.ToLower()
                if ($requiredSettings -contains $defIdLower) {
                    $choiceValue = $setting.settingInstance.choiceSettingValue.value
                    if ($choiceValue -and $choiceValue.EndsWith('_1')) {
                        $enabledSettings += $defIdLower
                    }
                }
            }
            # Skip policies that do not have all three required settings enabled.
            if ($enabledSettings.Count -lt $requiredSettings.Count) { continue }

            # Assignments are already embedded from the Q1 expand — no separate call needed.
            $assignments = @($policy.assignments)

            $avPolicies += [PSCustomObject]@{
                PolicyId       = $policy.id
                PolicyName     = $policy.name
                AvSettings     = $enabledSettings -join ', '
                HasAssignments = $true   # guaranteed by $filter=assignments/any()
                Assignments    = $assignments   # raw for group name resolution in report
            }
        }
    }
    catch {
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
        if ($statusCode -in @(401, 403)) {
            Write-PSFMessage "HTTP $statusCode on configurationPolicies — falling back to Secure Score (Q2/Q3)." -Tag Test -Level Warning
            $q1Fallback = $true
        }
        else {
            $q1QueryError = $_
            Write-PSFMessage "Unexpected error reading configurationPolicies (HTTP $statusCode): $_" -Tag Test -Level Warning
        }
    }

    # --- Q2: Secure Score control profiles (fallback / supplemental) ---
    # Only run Q2+Q3 when Q1 found no assigned AV policy or Q1 was unavailable.
    $pinnedControlIds = @('scid_2010', 'scid_5090', 'scid_6090')
    $controlProfiles  = @()
    $q2QueryError     = $null

    $runSecureScore = $q1Fallback -or ($null -eq $q1QueryError -and $avPolicies.Count -eq 0)

    if ($runSecureScore) {
        Write-ZtProgress -Activity $activity -Status 'Reading Secure Score control profiles (Q2)'
        try {
            # Spec references v1.0; using beta per project convention (riskAmbiguityLog #1).
            $controlProfiles = @(Invoke-ZtGraphRequest -RelativeUri 'security/secureScoreControlProfiles' -ApiVersion beta -Filter "service eq 'MDATP' and (id eq 'scid_2010' or id eq 'scid_5090' or id eq 'scid_6090')" -ErrorAction Stop)
        }
        catch {
            $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($statusCode -in @(401, 403)) {
                Write-PSFMessage "HTTP $statusCode on secureScoreControlProfiles — service not licensed." -Tag Test -Level Warning
                Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result '⚠️ Microsoft Defender for Endpoint or the Secure Score service is not available for this tenant. Ensure WINDEFATP or MDE_LITE is licensed.'
                return
            }
            $q2QueryError = $_
            Write-PSFMessage "Unexpected error reading secureScoreControlProfiles (HTTP $statusCode): $_" -Tag Test -Level Warning
        }
    }

    # --- Q3: Latest Secure Score snapshot ---
    $secureScore  = $null
    $q3QueryError = $null

    if ($runSecureScore -and $null -eq $q2QueryError) {
        Write-ZtProgress -Activity $activity -Status 'Reading latest Secure Score snapshot (Q3)'
        try {
            # -DisablePaging returns the raw Graph wrapper; access items via .value.
            # Spec references v1.0; using beta per project convention (riskAmbiguityLog #1).
            $response = Invoke-ZtGraphRequest -RelativeUri 'security/secureScores' -ApiVersion beta -Top '1' -DisablePaging -ErrorAction Stop
            $secureScore = if ($response.value) { $response.value | Select-Object -First 1 } else { $null }
        }
        catch {
            $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($statusCode -in @(401, 403)) {
                Write-PSFMessage "HTTP $statusCode on secureScores — service not licensed." -Tag Test -Level Warning
                Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result '⚠️ The Secure Score endpoint is not available for this tenant. Ensure WINDEFATP or MDE_LITE is licensed.'
                return
            }
            $q3QueryError = $_
            Write-PSFMessage "Unexpected error reading secureScores (HTTP $statusCode): $_" -Tag Test -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic

    # Unexpected Q1 error → Investigate.
    if ($q1QueryError) {
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $q1QueryError
        Write-PSFMessage "Test-Assessment-41047: INVESTIGATE — Q1 error (HTTP $statusCode)" -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -TestId '41047' -Title $testTitle -Status $false -CustomStatus 'Investigate' -Result "⚠️ Microsoft Graph returned an unexpected error (HTTP $statusCode) reading Intune configuration policies. Verify `DeviceManagementConfiguration.Read.All` is consented and re-run."
        return
    }

    # Q2 or Q3 unexpected error → Investigate.
    if ($q2QueryError -or $q3QueryError) {
        $errCode = if ($q2QueryError) { Get-ZtHttpStatusCode -ErrorRecord $q2QueryError } else { Get-ZtHttpStatusCode -ErrorRecord $q3QueryError }
        Write-PSFMessage "Test-Assessment-41047: INVESTIGATE — Secure Score query error (HTTP $errCode)" -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -TestId '41047' -Title $testTitle -Status $false -CustomStatus 'Investigate' -Result "⚠️ Microsoft Graph returned an unexpected error (HTTP $errCode) reading Secure Score data. Verify `SecurityEvents.Read.All` is consented and re-run."
        return
    }

    # Q1 path: all entries in $avPolicies are assigned (guaranteed by $filter=assignments/any()).
    $ctrlStatuses     = @{}    # id → 'Pass' | 'Fail' | 'Investigate' (Secure Score path only)
    $investigateFound = $false
    if ($avPolicies.Count -gt 0) {
        # Pass: at least one assigned active-mode AV policy confirmed.
        $passed = $true
    }
    else {
        # Secure Score path evaluation.
        if ($controlProfiles.Count -eq 0) {
            # No pinned control profiles found → Investigate (no evidence).
            Write-PSFMessage "Test-Assessment-41047: INVESTIGATE — no pinned Secure Score control profiles found" -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -TestId '41047' -Title $testTitle -Status $false -CustomStatus 'Investigate' -Result "⚠️ The Secure Score control could not be located; verify Defender for Endpoint Secure Score data is flowing."
            return
        }

        # Evaluate each pinned control and record per-control status.
        $passed = $true

        foreach ($ctrl in $controlProfiles) {
            $maxScore = $ctrl.maxScore

            # Resolve the score entry from the latest snapshot by controlName (== profile id).
            $scoreEntry = $null
            if ($secureScore) {
                $scoreEntry = @($secureScore.controlScores | Where-Object { $_.controlName -eq $ctrl.id }) |
                    Select-Object -First 1
            }

            # Determine ignored state from the most recent controlStateUpdates entry.
            # updatedDateTime on each state update entry is used for sorting only.
            $latestStateUpdate = @($ctrl.controlStateUpdates |
                Sort-Object { if ($_.updatedDateTime) { [datetime]$_.updatedDateTime } else { [datetime]::MinValue } } -Descending) |
                Select-Object -First 1
            $isIgnored = $latestStateUpdate -and $latestStateUpdate.state -eq 'ignored'

            if ($isIgnored) {
                $ctrlStatuses[$ctrl.id] = 'Investigate'
                $passed = $false
            }
            elseif ($null -eq $scoreEntry -or $scoreEntry.score -lt $maxScore) {
                $ctrlStatuses[$ctrl.id] = 'Fail'
                $passed = $false
            }
            else {
                $ctrlStatuses[$ctrl.id] = 'Pass'
            }
        }

        # Investigate overrides Fail: if any control is ignored, escalate overall outcome.
        $investigateFound = $ctrlStatuses.Values -contains 'Investigate'
        if ($investigateFound) {
            $ignoredNames = ($ctrlStatuses.GetEnumerator() | Where-Object { $_.Value -eq 'Investigate' }).Key -join ', '
            Write-PSFMessage "Test-Assessment-41047: INVESTIGATE — control(s) ignored: $ignoredNames" -Tag Test -Level VeryVerbose
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl       = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/antivirus'
    $secureScoreUrl  = 'https://security.microsoft.com/securescore?viewid=actions'
    $maxDisplay = 10

    if ($passed) {
        $testResultMarkdown = "✅ Microsoft Defender Antivirus is in active mode on all eligible Windows endpoints.`n`n%TestResult%"
    }
    elseif ($investigateFound) {
        $testResultMarkdown = "⚠️ One or more Microsoft Defender Antivirus Secure Score controls are marked as ignored. Review the ignore justification and confirm each control is intentionally excluded.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Microsoft Defender Antivirus is disabled or in passive mode on one or more eligible endpoints.`n`n%TestResult%"
    }

    # Build report table based on which evaluation path succeeded.
    if ($avPolicies.Count -gt 0) {
        # Q1 path table.

        $displayPolicies = @($avPolicies | Select-Object -First $maxDisplay)
        $isTruncated     = $avPolicies.Count -gt $maxDisplay

        $tableRows = ''
        foreach ($row in $displayPolicies) {
            $nameMd = Get-SafeMarkdown -Text $row.PolicyName
            $avMd      = Get-SafeMarkdown -Text $row.AvSettings
            $groupsMd  = Get-SafeMarkdown -Text (Get-ZtAssignmentText -assignments $row.Assignments)

            $tableRows += "| $nameMd | $avMd | ✅ Assigned | $groupsMd | ✅ Pass |`n"
        }
        if ($isTruncated) {
            $tableRows += "| ... | ... | ... | ... | ... |`n"
        }
        $truncNote = if ($isTruncated) { "Showing $maxDisplay of $($avPolicies.Count) matching policies. [View all in Intune]($portalUrl)`n`n" } else { '' }

        $mdInfo = @"


$truncNote### [Microsoft Intune Endpoint Security]($portalUrl)

| Policy name | AV settings found | Assignment status | Assigned groups | Status |
| :---------- | :---------------- | :---------------- | :-------------- | :----- |
$tableRows
"@
    }
    else {
        # Q2/Q3 Secure Score path table.
        $tableRows = ''
        foreach ($ctrl in $controlProfiles) {
            $scoreEntry = $null
            if ($secureScore) {
                $scoreEntry = @($secureScore.controlScores | Where-Object { $_.controlName -eq $ctrl.id }) |
                    Select-Object -First 1
            }

            $latestUpd = @($ctrl.controlStateUpdates |
                Sort-Object { if ($_.updatedDateTime) { [datetime]$_.updatedDateTime } else { [datetime]::MinValue } } -Descending) |
                Select-Object -First 1

            $score      = if ($scoreEntry) { $scoreEntry.score } else { '—' }
            $maxScore   = if ($null -ne $ctrl.maxScore) { $ctrl.maxScore } else { '—' }
            $implStatus = if ($scoreEntry -and $scoreEntry.implementationStatus) { $scoreEntry.implementationStatus } else { '—' }
            $lastMod    = if ($ctrl.lastModifiedDateTime) { Get-FormattedDate -DateString $ctrl.lastModifiedDateTime } else { '—' }
            $ignored    = if ($latestUpd -and $latestUpd.state -eq 'ignored') {
                $comment = if ($latestUpd.comment) { ' — ' + (Get-SafeMarkdown -Text $latestUpd.comment) } else { '' }
                "⚠️ Yes$comment"
            } else { '✅ No' }

            $rowResult  = switch ($ctrlStatuses[$ctrl.id]) {
                'Pass'        { '✅ Pass' }
                'Fail'        { '❌ Fail' }
                'Investigate' { '⚠️ Investigate' }
                default       { '❌ Fail' }
            }

            $titleMd    = Get-SafeMarkdown -Text $ctrl.title
            $tableRows += "| $titleMd | $($ctrl.id) | $score | $maxScore | $implStatus | $lastMod | $ignored | $rowResult |`n"
        }

        $mdInfo = @"


### [Microsoft Secure Score]($secureScoreUrl)

| Title | Control Id | Score | Max score | Implementation status | Last modified | Ignored | Status |
| :---- | :--------- | :---- | :-------- | :-------------------- | :------------ | :------ | :----- |
$tableRows
"@
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41047'
        Title  = $testTitle
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($investigateFound) { $params['CustomStatus'] = 'Investigate' }
    Add-ZtTestResultDetail @params
}
