<#
.SYNOPSIS
    Tenant Allow/Block List entries are scoped, time-bounded, and free of broad allow rules.

.NOTES
    Test ID: 41040
    Workshop Task: SECOPS-040
    Pillar: SecOps
    Category: Email and collaboration security
    Required Module: ExchangeOnlineManagement
    Required Connection: Exchange Online (Security Reader or View-Only Configuration role)
#>

function Test-Assessment-41040 {
    [ZtTest(
        Category = 'Email and collaboration security',
        CompatibleLicense = ('EXCHANGE_S_STANDARD'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('ExchangeOnline'),
        SfiPillar = 'Protect tenants and isolate production systems',
        TenantType = ('Workforce'),
        TestId = 41040,
        Title = 'Tenant Allow/Block List entries are scoped, time-bounded, and free of broad allow rules',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity        = 'Checking Tenant Allow/Block List hygiene'
    $allEntries      = @()
    $failedListTypes = @()

    # Q1a: Enumerate Sender entries.
    Write-ZtProgress -Activity $activity -Status 'Querying Sender entries'
    try {
        $senderEntries = @(Get-TenantAllowBlockListItems -ListType Sender -ErrorAction Stop |
            Select-Object Value, Action, ExpirationDate, Notes, ListSubType, LastModifiedDateTime)
        foreach ($entry in $senderEntries) {
            $entry | Add-Member -NotePropertyName ListTypeName -NotePropertyValue 'Sender' -Force
            $allEntries += $entry
        }
        Write-PSFMessage "Q1a: retrieved $($senderEntries.Count) Sender entries" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Failed to query Sender TABL entries: $_" -Tag Test -Level Warning
        $failedListTypes += 'Sender'
    }

    # Q1b: Enumerate URL entries.
    # AdvancedDelivery is a documented ListSubType for phishing-simulation URLs
    # (see advanced-delivery-policy-configure). Those entries are intentionally excluded from the verdict.
    Write-ZtProgress -Activity $activity -Status 'Querying URL entries'
    try {
        $urlEntries = @(Get-TenantAllowBlockListItems -ListType Url -ErrorAction Stop |
            Select-Object Value, Action, ExpirationDate, Notes, ListSubType, LastModifiedDateTime)
        foreach ($entry in $urlEntries) {
            $entry | Add-Member -NotePropertyName ListTypeName -NotePropertyValue 'Url' -Force
            $allEntries += $entry
        }
        Write-PSFMessage "Q1b: retrieved $($urlEntries.Count) URL entries" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Failed to query URL TABL entries: $_" -Tag Test -Level Warning
        $failedListTypes += 'Url'
    }

    # Q1c: Enumerate file hash entries.
    Write-ZtProgress -Activity $activity -Status 'Querying FileHash entries'
    try {
        $fileHashEntries = @(Get-TenantAllowBlockListItems -ListType FileHash -ErrorAction Stop |
            Select-Object Value, Action, ExpirationDate, Notes, ListSubType, LastModifiedDateTime)
        foreach ($entry in $fileHashEntries) {
            $entry | Add-Member -NotePropertyName ListTypeName -NotePropertyValue 'FileHash' -Force
            $allEntries += $entry
        }
        Write-PSFMessage "Q1c: retrieved $($fileHashEntries.Count) FileHash entries" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Failed to query FileHash TABL entries: $_" -Tag Test -Level Warning
        $failedListTypes += 'FileHash'
    }

    # Q1d: Enumerate IP entries.
    Write-ZtProgress -Activity $activity -Status 'Querying IP entries'
    try {
        $ipEntries = @(Get-TenantAllowBlockListItems -ListType IP -ErrorAction Stop |
            Select-Object Value, Action, ExpirationDate, Notes, ListSubType, LastModifiedDateTime)
        foreach ($entry in $ipEntries) {
            $entry | Add-Member -NotePropertyName ListTypeName -NotePropertyValue 'IP' -Force
            $allEntries += $entry
        }
        Write-PSFMessage "Q1d: retrieved $($ipEntries.Count) IP entries" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Failed to query IP TABL entries: $_" -Tag Test -Level Warning
        $failedListTypes += 'IP'
    }
    #endregion Data Collection

    #region Assessment Logic

    if ($failedListTypes.Count -eq 4) {
        $params = @{
            TestId       = '41040'
            Title        = 'Tenant Allow/Block List entries are scoped, time-bounded, and free of broad allow rules'
            Status       = $false
            Result       = '⚠️ All four Tenant Allow/Block List queries failed (Sender, Url, FileHash, and IP). Verify the assessment account has Security Reader or View-Only Configuration access via Exchange Online RBAC and that the ExchangeOnline connection is active.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $now              = Get-Date
    $staleThreshold   = $now.AddDays(-90)
    $listTypePriority = @{ 'FileHash' = 1; 'Url' = 2; 'Sender' = 3; 'IP' = 4 }

    $allAllow = @($allEntries | Where-Object { $_.Action -eq 'Allow' })
    $allBlock = @($allEntries | Where-Object { $_.Action -eq 'Block' })

    $exemptEntries = @($allAllow | Where-Object {
        $_.ListSubType -in @('AdvancedDelivery', 'Submission')
    })
    $adminControlledAllow = @($allAllow | Where-Object {
        $_.ListSubType -eq 'Tenant'
    })

    $classifiedEntries = foreach ($entry in $adminControlledAllow) {
        $expirationDate  = $entry.ExpirationDate
        $lastModifiedDate = $entry.LastModifiedDateTime
        $isUnbounded     = $null -eq $expirationDate

        $hasNotes = -not [string]::IsNullOrWhiteSpace([string]$entry.Notes)
        $isActive = $isUnbounded -or ($null -ne $expirationDate -and $expirationDate -gt $now)
        $isStale = $isActive -and $null -ne $lastModifiedDate -and $lastModifiedDate -lt $staleThreshold
        $isFailEntry = $isUnbounded -and (-not $hasNotes)
        $isFlagged = $isFailEntry -or ($isUnbounded -and $hasNotes) -or $isStale

        $flags = @()
        if ($isUnbounded) { $flags += 'unbounded' }
        if (-not $hasNotes) { $flags += 'no-notes' }
        if ($isStale) { $flags += 'stale' }

        [PSCustomObject]@{
            ListTypeName         = $entry.ListTypeName
            Value                = $entry.Value
            Action               = $entry.Action
            ExpirationDate       = $expirationDate
            LastModifiedDateTime = $lastModifiedDate
            Notes                = $entry.Notes
            IsUnbounded          = $isUnbounded
            HasNotes             = $hasNotes
            IsStale              = $isStale
            IsFailEntry          = $isFailEntry
            IsFlagged            = $isFlagged
            Flags                = $flags -join ', '
            SortDate             = $lastModifiedDate
            ListTypePriority     = $listTypePriority[$entry.ListTypeName]
        }
    }
    $classifiedEntries = @($classifiedEntries)

    # Drift metrics (CISO scoreboard).
    $totalAdminControlledAllowsCount = $classifiedEntries.Count
    $unboundedAdminControlledCount   = @($classifiedEntries | Where-Object { $_.IsUnbounded }).Count
    $unboundedWithoutNotesCount      = @($classifiedEntries | Where-Object { $_.IsFailEntry }).Count
    $staleAdminControlledCount       = @($classifiedEntries | Where-Object { $_.IsStale }).Count
    $unboundedRatio                  = if ($totalAdminControlledAllowsCount -gt 0) {
        [math]::Round($unboundedAdminControlledCount / $totalAdminControlledAllowsCount * 100, 1)
    } else { $null }

    $totalAllowCount  = $allAllow.Count
    $totalBlockCount  = $allBlock.Count
    $totalExemptCount = $exemptEntries.Count

    $passed       = $false
    $customStatus = $null
    $partialDataCaveat = if ($failedListTypes.Count -gt 0) {
        " Results reflect partial data only (failed: $($failedListTypes -join ', ')). Verify permissions and re-run."
    } else { '' }

    if ($unboundedWithoutNotesCount -gt 0) {
        $testResultMarkdown = "❌ One or more admin-controlled allow entries are unbounded and have no documented business justification in the Notes field. Each is a permanent filter bypass with no recorded reason for its existence. A threat actor who reuses an allowed sender, registers a lookalike under an allowed domain, or replays an allowed file hash will bypass Microsoft's spam, bulk, and phishing verdicts for as long as the entry remains.$partialDataCaveat`n`n%TestResult%"
    }
    elseif ($staleAdminControlledCount -gt 0 -or $unboundedAdminControlledCount -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ Unbounded allow entries exist but all have populated Notes, or stale entries (not modified in more than 90 days) exist. The customer is using the Tenant Allow/Block List responsibly but should confirm that each unbounded entry's business justification is still current and prune any entries that no longer apply.$partialDataCaveat`n`n%TestResult%"
    }
    elseif ($failedListTypes.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ One or more Tenant Allow/Block List queries failed; results reflect partial data only (failed: $($failedListTypes -join ', ')). Verify permissions and re-run.`n`n%TestResult%"
    }
    else {
        $passed             = $true
        $testResultMarkdown = "✅ All admin-controlled allow entries in the Tenant Allow/Block List are either time-bounded or have a documented business justification, and no entry has been left untouched for more than 90 days.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tablPortalUrl = 'https://security.microsoft.com/tenantAllowBlockList'
    $maxDisplay    = 10

    $unboundedRatioDisplay = if ($null -eq $unboundedRatio) { '—' } else { "$unboundedRatio%" }
    $partialDataNote       = if ($failedListTypes.Count -gt 0) { " — ⚠️ partial data (failed: $($failedListTypes -join ', '))" } else { '' }

    $driftRows  = "| Unbounded admin-controlled allow entries | $unboundedAdminControlledCount | 0 |`n"
    $driftRows += "| Unbounded entries lacking documented justification | $unboundedWithoutNotesCount | 0 |`n"
    $driftRows += "| Stale allow entries (last modified >90 days) | $staleAdminControlledCount | 0 |`n"
    $driftRows += "| Unbounded ratio | $unboundedRatioDisplay | <5% (informational) |`n"
    $driftRows += "| Total allow entries (all categories) | $totalAllowCount | — |`n"
    $driftRows += "| Total block entries (not evaluated) | $totalBlockCount | — |`n"
    $driftRows += "| Excluded entries (AdvancedDelivery + Submission) | $totalExemptCount | — |`n"

    $driftSection = @"

## [Tenant Allow/Block Lists]($tablPortalUrl) — drift summary$partialDataNote

| Metric | Value | Target |
| :----- | ----: | :----- |
$driftRows

Excluded entries (AdvancedDelivery, Submission) are represented by the excluded count row above and never affect the verdict.
"@

    $actionSection = ''
    if (-not $passed -or $null -ne $customStatus) {
        $flaggedEntries = @($classifiedEntries | Where-Object { $_.IsFlagged })

        if ($flaggedEntries.Count -gt 0) {
            $sortedFlagged = @(
                $flaggedEntries | Sort-Object `
                    @{ Expression = { if ($_.IsFailEntry) { 0 } else { 1 } } },
                    @{ Expression = { $_.SortDate } },
                    @{ Expression = { $_.ListTypePriority } },
                    @{ Expression = { if ($_.IsStale) { 0 } else { 1 } } },
                    @{ Expression = { [string]$_.Value } }
            )
            $hasMoreRows  = $sortedFlagged.Count -gt $maxDisplay
            $displayRows  = if ($hasMoreRows) { @($sortedFlagged | Select-Object -First $maxDisplay) } else { $sortedFlagged }

            $tableRows = ''
            foreach ($row in $displayRows) {
                $valueRaw = ([string]$row.Value) -replace '[\r\n]+', ' '
                $valueDisplay = if ($valueRaw.Length -gt 50) { $valueRaw.Substring(0, 47) + '...' } else { $valueRaw }
                $valueDisplay = Get-SafeMarkdown -Text $valueDisplay

                $notesRaw = if ($null -ne $row.Notes) { (([string]$row.Notes).Trim() -replace '[\r\n]+', ' ') } else { '' }
                $notesDisplay = if ([string]::IsNullOrWhiteSpace($notesRaw)) { '—' } `
                    elseif ($notesRaw.Length -gt 80) { $notesRaw.Substring(0, 77) + '...' } `
                    else { $notesRaw }
                if ($notesDisplay -ne '—') {
                    $notesDisplay = Get-SafeMarkdown -Text $notesDisplay
                }

                $expirationDisplay = if ($row.IsUnbounded) {
                    'No expiration'
                } else {
                    Get-FormattedDate -DateString ($row.ExpirationDate.ToString('o'))
                }
                $lastModDisplay = if ($null -ne $row.LastModifiedDateTime) {
                    Get-FormattedDate -DateString ($row.LastModifiedDateTime.ToString('o'))
                } else { '—' }

                $tableRows += "| $($row.ListTypeName) | $valueDisplay | $($row.Action) | $expirationDisplay | $lastModDisplay | $notesDisplay | $($row.Flags) |`n"
            }

            if ($hasMoreRows) {
                $tableRows += "| ... | ... | ... | ... | ... | ... | ... |`n"
            }

            $inventoryLink = if ($hasMoreRows) {
                "`n[Microsoft Defender portal > Tenant Allow/Block Lists]($tablPortalUrl)`n"
            } else { '' }

            $actionSection = @"

## Action required

| List type | Value | Action | Expiration date | Last modified | Notes | Flags |
| :-------- | :---- | :----- | :-------------- | :------------ | :---- | :----- |
$tableRows
$inventoryLink
"@
        }
    }

    $formatTemplate = @'
{0}
{1}
'@
    $mdInfo             = $formatTemplate -f $driftSection, $actionSection
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41040'
        Title  = 'Tenant Allow/Block List entries are scoped, time-bounded, and free of broad allow rules'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
