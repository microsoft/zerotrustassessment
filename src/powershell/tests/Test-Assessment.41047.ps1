<#
.SYNOPSIS
    Microsoft Defender Antivirus is set to active mode on all eligible endpoints.

.DESCRIPTION
    Verifies that Microsoft Defender Antivirus is configured in active mode on all eligible Windows
    endpoints using a three-tier evaluation strategy. The primary signal (Q1) is a Microsoft Defender
    advanced hunting query (DeviceTvmSecureConfigurationAssessment, antivirus operational-mode
    configurations) that reports per-device runtime compliance. When the runtime signal is unavailable,
    the check falls back to Intune Settings Catalog configuration policies (Q2) for policy-intent
    validation, then to Microsoft Secure Score controls (Q3 + Q4) as a supplemental tenant-level
    signal. Passive mode or disabled antivirus on any eligible device results in a Fail.

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

    # --- Q1: Advanced hunting — primary runtime signal ---
    # Queries DeviceTvmSecureConfigurationAssessment filtered to the antivirus operational-mode
    # configurations only: 'Turn on Microsoft Defender Antivirus' and 'Turn on real-time protection'.
    # Hardening assessments in the Antivirus subcategory (PUA, email scanning, cloud protection, etc.)
    # are intentionally excluded — an active-mode device can legitimately report them non-compliant.
    # Note: legacy api.securitycenter.microsoft.com deviceavinfo API is intentionally not used;
    # all queries stay on the Microsoft Graph surface (one token audience), mirroring spec 41045.
    $q1Fallback   = $false   # true when Q1 returns 401/403 or 0 rows (no MDE signal) → fall to Q2
    $q1QueryError = $null    # non-401/403 failure
    $q1HasData    = $false   # true when Q1 returned at least one device row
    $q1FailRows   = @()      # device rows where IsCompliant == false

    Write-ZtProgress -Activity $activity -Status 'Running advanced hunting query for AV compliance (Q1)'
    try {
        $kqlQuery    = "DeviceTvmSecureConfigurationAssessment | where ConfigurationSubcategory == 'Antivirus' and IsApplicable == 1 | join kind=leftouter (DeviceTvmSecureConfigurationAssessmentKB | project ConfigurationId, ConfigurationName) on ConfigurationId | where ConfigurationName in ('Turn on Microsoft Defender Antivirus', 'Turn on real-time protection') | project DeviceId, DeviceName, ConfigurationId, ConfigurationName, IsCompliant"
        $requestBody = @{ query = $kqlQuery } | ConvertTo-Json -Compress
        $rawResult   = Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -ApiVersion v1.0 -Method POST -Body $requestBody -ErrorAction Stop
        $allRows     = @()
        if ($null -ne $rawResult -and $null -ne $rawResult.results) { $allRows = @($rawResult.results) }
        if ($allRows.Count -eq 0) {
            # No devices with applicable antivirus configurations in MDE data (last 30 days) → fall to Q2.
            Write-PSFMessage 'Q1 advanced hunting returned no rows — falling back to Q2 (Intune).' -Tag Test -Level Warning
            $q1Fallback = $true
        }
        else {
            $q1HasData  = $true
            $q1FailRows = @($allRows | Where-Object { -not $_.IsCompliant })
        }
    }
    catch {
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
        if ($statusCode -in @(401, 403)) {
            Write-PSFMessage "HTTP $statusCode on runHuntingQuery — falling back to Q2 (Intune)." -Tag Test -Level Warning
            $q1Fallback = $true
        }
        else {
            $q1QueryError = $_
            Write-PSFMessage "Unexpected error running advanced hunting query (HTTP $statusCode): $_" -Tag Test -Level Warning
        }
    }

    # --- Q2: Intune Settings Catalog — config-intent proxy (runs only when Q1 unavailable) ---
    # All three Defender real-time protection settings must be present and enabled
    # (choiceSettingValue ending in '_1') for a policy to enforce active mode.
    $requiredSettings = @(
        'device_vendor_msft_policy_config_defender_allowrealtimemonitoring',
        'device_vendor_msft_policy_config_defender_allowonaccessprotection',
        'device_vendor_msft_policy_config_defender_allowbehaviormonitoring'
    )
    $q2Fallback   = $false   # true when Q2 returns 401/403 → fall to Q3/Q4
    $q2QueryError = $null    # non-401/403 failure
    $avPolicies   = @()      # matching policies with all three active-mode settings enabled

    if ($q1Fallback) {
        Write-ZtProgress -Activity $activity -Status 'Reading assigned Intune configuration policies (Q2)'
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

                # Assignments are already embedded from the Q2 expand — no separate call needed.
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
                Write-PSFMessage "HTTP $statusCode on configurationPolicies — falling back to Secure Score (Q3/Q4)." -Tag Test -Level Warning
                $q2Fallback = $true
            }
            else {
                $q2QueryError = $_
                Write-PSFMessage "Unexpected error reading configurationPolicies (HTTP $statusCode): $_" -Tag Test -Level Warning
            }
        }
    }

    # --- Q3: Secure Score control profiles — supplemental fallback ---
    # Runs only when Q1 is unavailable AND Q2 found no assigned active-mode policy.
    # scid_* ids are provider-generated and must not be hardcoded — select by service + title at runtime.
    $controlProfiles = @()
    $q3QueryError    = $null

    $runSecureScore = $q1Fallback -and ($q2Fallback -or ($null -eq $q2QueryError -and $avPolicies.Count -eq 0))

    if ($runSecureScore) {
        Write-ZtProgress -Activity $activity -Status 'Reading Secure Score control profiles (Q3)'
        try {
            $allMdatpProfiles = @(Invoke-ZtGraphRequest -RelativeUri 'security/secureScoreControlProfiles' -ApiVersion beta -Filter "service eq 'MDATP'" -ErrorAction Stop)
            # Client-side: keep only active-mode controls, excluding PUA and deprecated profiles.
            $controlProfiles = @($allMdatpProfiles | Where-Object {
                $_.title -match 'Turn on Microsoft Defender Antivirus' -and
                $_.title -notmatch 'PUA' -and
                -not $_.deprecated
            })
        }
        catch {
            $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($statusCode -in @(401, 403)) {
                Write-PSFMessage "HTTP $statusCode on secureScoreControlProfiles — service not licensed." -Tag Test -Level Warning
                Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result '⚠️ Microsoft Defender for Endpoint or the Secure Score service is not available for this tenant. Ensure WINDEFATP or MDE_LITE is licensed.'
                return
            }
            $q3QueryError = $_
            Write-PSFMessage "Unexpected error reading secureScoreControlProfiles (HTTP $statusCode): $_" -Tag Test -Level Warning
        }
    }

    # --- Q4: Latest Secure Score snapshot ---
    $secureScore  = $null
    $q4QueryError = $null

    if ($runSecureScore -and $null -eq $q3QueryError) {
        Write-ZtProgress -Activity $activity -Status 'Reading latest Secure Score snapshot (Q4)'
        try {
            # -DisablePaging returns the raw Graph wrapper; access items via .value.
            $response    = Invoke-ZtGraphRequest -RelativeUri 'security/secureScores' -ApiVersion beta -Top '1' -DisablePaging -ErrorAction Stop
            $secureScore = if ($response.value) { $response.value | Select-Object -First 1 } else { $null }
        }
        catch {
            $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($statusCode -in @(401, 403)) {
                Write-PSFMessage "HTTP $statusCode on secureScores — service not licensed." -Tag Test -Level Warning
                Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result '⚠️ The Secure Score endpoint is not available for this tenant. Ensure WINDEFATP or MDE_LITE is licensed.'
                return
            }
            $q4QueryError = $_
            Write-PSFMessage "Unexpected error reading secureScores (HTTP $statusCode): $_" -Tag Test -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic

    # Unexpected Q1 error → Investigate.
    if ($q1QueryError) {
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $q1QueryError
        Write-PSFMessage "Test-Assessment-41047: INVESTIGATE — Q1 error (HTTP $statusCode)" -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -TestId '41047' -Title $testTitle -Status $false -CustomStatus 'Investigate' -Result "⚠️ Microsoft Graph returned an unexpected error (HTTP $statusCode) running the advanced hunting query. Verify `ThreatHunting.Read.All` is consented and re-run."
        return
    }

    # Unexpected Q2 error → Investigate.
    if ($q2QueryError) {
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $q2QueryError
        Write-PSFMessage "Test-Assessment-41047: INVESTIGATE — Q2 error (HTTP $statusCode)" -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -TestId '41047' -Title $testTitle -Status $false -CustomStatus 'Investigate' -Result "⚠️ Microsoft Graph returned an unexpected error (HTTP $statusCode) reading Intune configuration policies. Verify `DeviceManagementConfiguration.Read.All` is consented and re-run."
        return
    }

    # Unexpected Q3 or Q4 error → Investigate.
    if ($q3QueryError -or $q4QueryError) {
        $errCode = if ($q3QueryError) { Get-ZtHttpStatusCode -ErrorRecord $q3QueryError } else { Get-ZtHttpStatusCode -ErrorRecord $q4QueryError }
        Write-PSFMessage "Test-Assessment-41047: INVESTIGATE — Secure Score query error (HTTP $errCode)" -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -TestId '41047' -Title $testTitle -Status $false -CustomStatus 'Investigate' -Result "⚠️ Microsoft Graph returned an unexpected error (HTTP $errCode) reading Secure Score data. Verify `SecurityEvents.Read.All` is consented and re-run."
        return
    }

    $ctrlStatuses     = @{}    # id → 'Pass' | 'Fail' | 'Investigate' (Secure Score path only)
    $investigateFound = $false

    if ($q1HasData) {
        # Q1 path: runtime signal — pass when no non-compliant device rows returned.
        $passed = ($q1FailRows.Count -eq 0)
    }
    elseif ($avPolicies.Count -gt 0) {
        # Q2 path: at least one assigned active-mode AV policy confirmed → Pass.
        $passed = $true
    }
    else {
        # Q3/Q4 Secure Score path evaluation.
        if ($controlProfiles.Count -eq 0) {
            # No conclusive signal from any query → Investigate.
            Write-PSFMessage "Test-Assessment-41047: INVESTIGATE — no Secure Score control profiles found" -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -TestId '41047' -Title $testTitle -Status $false -CustomStatus 'Investigate' -Result "⚠️ Antivirus mode could not be determined from device runtime data, an assigned Intune policy, or Secure Score; verify Defender for Endpoint enrollment and that antivirus evidence is flowing."
            return
        }

        # Evaluate each active-mode control and record per-control status.
        $passed = $true

        foreach ($ctrl in $controlProfiles) {
            $maxScore = $ctrl.maxScore

            # Join controlScores by controlName == profile id (NOT by title — controlScores carry no title).
            $scoreEntry = $null
            if ($secureScore) {
                $scoreEntry = @($secureScore.controlScores | Where-Object { $_.controlName -eq $ctrl.id }) |
                    Select-Object -First 1
            }

            # Determine ignored state from the most recent controlStateUpdates entry.
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
    $portalUrl      = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/antivirus'
    $defenderUrl    = 'https://security.microsoft.com/machines'
    $secureScoreUrl = 'https://security.microsoft.com/securescore?viewid=actions'
    $maxDisplay     = 10

    if ($passed) {
        $testResultMarkdown = "✅ Microsoft Defender Antivirus is in active mode on all eligible Windows endpoints.`n`n%TestResult%"
    }
    elseif ($investigateFound) {
        $testResultMarkdown = "⚠️ One or more Microsoft Defender Antivirus Secure Score controls are marked as ignored. Review the ignore justification and confirm each control is intentionally excluded.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Microsoft Defender Antivirus is in passive or disabled mode on one or more eligible endpoints.`n`n%TestResult%"
    }

    # Build report table based on which evaluation path was used.
    if ($q1HasData) {
        # Q1 path: per-device table of non-compliant devices (empty on Pass).
        if ($q1FailRows.Count -eq 0) {
            $mdInfo = @"


### [Microsoft Defender XDR]($defenderUrl)

All devices returned by advanced hunting reported Microsoft Defender Antivirus operational-mode configurations as compliant.
"@
        }
        else {
            $displayRows = @($q1FailRows | Select-Object -First $maxDisplay)
            $isTruncated = $q1FailRows.Count -gt $maxDisplay
            $tableRows   = ''
            foreach ($device in $displayRows) {
                $deviceMd  = Get-SafeMarkdown -Text $device.DeviceName
                $configMd  = Get-SafeMarkdown -Text $device.ConfigurationName
                $tableRows += "| $deviceMd | $($device.DeviceId) | $configMd | ❌ No | ❌ Fail |`n"
            }
            if ($isTruncated) { $tableRows += "| ... | ... | ... | ... | ... |`n" }
            $truncNote = if ($isTruncated) { "Showing $maxDisplay of $($q1FailRows.Count) non-compliant devices. [View all in Microsoft Defender XDR]($defenderUrl)`n`n" } else { '' }

            $mdInfo = @"


$truncNote### [Microsoft Defender XDR]($defenderUrl)

| Device | Device ID | Configuration | Compliant | Status |
| :----- | :-------- | :------------ | :-------- | :----- |
$tableRows
"@
        }
    }
    elseif ($avPolicies.Count -gt 0) {
        # Q2 path: Intune policy-intent table.
        $displayPolicies = @($avPolicies | Select-Object -First $maxDisplay)
        $isTruncated     = $avPolicies.Count -gt $maxDisplay

        $tableRows = ''
        foreach ($row in $displayPolicies) {
            $nameMd   = Get-SafeMarkdown -Text $row.PolicyName
            $avMd     = Get-SafeMarkdown -Text $row.AvSettings
            $groupsMd = Get-SafeMarkdown -Text (Get-ZtAssignmentText -assignments $row.Assignments)
            $tableRows += "| $nameMd | $avMd | ✅ Assigned | $groupsMd | ✅ Pass |`n"
        }
        if ($isTruncated) { $tableRows += "| ... | ... | ... | ... | ... |`n" }
        $truncNote = if ($isTruncated) { "Showing $maxDisplay of $($avPolicies.Count) matching policies. [View all in Intune]($portalUrl)`n`n" } else { '' }

        $mdInfo = @"


$truncNote### [Microsoft Intune Endpoint Security]($portalUrl)

| Policy name | AV settings found | Assignment status | Assigned groups | Status |
| :---------- | :---------------- | :---------------- | :-------------- | :----- |
$tableRows
"@
    }
    else {
        # Q3/Q4 Secure Score path table.
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
            }
            else { '✅ No' }

            $rowResult = switch ($ctrlStatuses[$ctrl.id]) {
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
