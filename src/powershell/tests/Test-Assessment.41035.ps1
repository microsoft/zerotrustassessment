<#
.SYNOPSIS
    User reporting for phishing and spam is enabled and routed to a reviewed mailbox.

.NOTES
    Test ID: 41035
    Workshop Task: SECOPS-035
    Pillar: SecOps
    Category: Email and collaboration security
    Required Module: ExchangeOnlineManagement
    Required permissions: Get-ReportSubmissionPolicy, Get-ReportSubmissionRule
#>

function Test-Assessment-41035 {
    [ZtTest(
        Category           = 'Email and collaboration security',
        CompatibleLicense  = ('EXCHANGE_S_STANDARD'),
        ImplementationCost = 'Low',
        Pillar             = 'SecOps',
        RiskLevel          = 'Medium',
        Service            = ('ExchangeOnline'),
        SfiPillar          = 'Monitor and detect cyberthreats',
        TenantType         = ('Workforce'),
        TestId             = 41035,
        Title              = 'User reporting for phishing and spam is enabled and routed to a reviewed mailbox',
        UserImpact         = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking user report submission policy configuration'
    Write-ZtProgress -Activity $activity -Status 'Retrieving report submission policy'

    # Q1a: Retrieve the singleton report submission policy from Exchange Online.
    # Note: EnableThirdPartyAddress and ThirdPartyReportAddresses are included here despite being absent
    # from the spec's Select-Object list — they are required by the evaluation logic and output table.
    $policyList = $null
    try {
        $policyList = @(Get-ReportSubmissionPolicy -ErrorAction Stop |
            Select-Object Identity,
                          EnableReportToMicrosoft,
                          ReportJunkToCustomizedAddress,
                          ReportNotJunkToCustomizedAddress,
                          ReportPhishToCustomizedAddress,
                          ReportJunkAddresses,
                          ReportNotJunkAddresses,
                          ReportPhishAddresses,
                          EnableReportTypeReportFromBuiltInButton,
                          EnableThirdPartyAddress,
                          ThirdPartyReportAddresses,
                          ReportChatMessageEnabled,
                          ReportChatMessageToCustomizedAddressEnabled,
                          PostSubmitMessageEnabled)
    }
    catch {
        Write-PSFMessage "Failed to retrieve report submission policy: $_" -Tag Test -Level Warning
        $params = @{
            TestId       = '41035'
            Title        = 'User reporting for phishing and spam is enabled and routed to a reviewed mailbox'
            Status       = $false
            Result       = "⚠️ The report submission policy could not be retrieved. Verify that the account has Exchange Online permissions and re-run. Error: $_"
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Spec: Get-ReportSubmissionPolicy is tenant-singleton and should always exist.
    if ($policyList.Count -eq 0) {
        $params = @{
            TestId       = '41035'
            Title        = 'User reporting for phishing and spam is enabled and routed to a reviewed mailbox'
            Status       = $false
            Result       = '⚠️ **Get-ReportSubmissionPolicy** returned no results. The policy is tenant-singleton and should always exist; an empty result indicates a permission or connectivity issue — verify access and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $policy = $policyList[0]

    # Q1b: Retrieve the report submission rule. The rule may not exist in all tenants (e.g., MS-only route).
    Write-ZtProgress -Activity $activity -Status 'Retrieving report submission rule'
    $rule = $null
    try {
        $ruleList = @(Get-ReportSubmissionRule -ErrorAction Stop |
            Select-Object Name, ReportSubmissionPolicy, SentTo, State)
        if ($ruleList.Count -gt 0) {
            $rule = $ruleList[0]
        }
    }
    catch {
        Write-PSFMessage "Failed to retrieve report submission rule (non-fatal — treating as no rule): $_" -Tag Test -Level Warning
        $rule = $null
    }

    # Q2: Reachability probe for the Microsoft Graph email threat submission API.
    # Per spec, this is informational only; the check must not depend on Q2 succeeding.
    Write-ZtProgress -Activity $activity -Status 'Probing email threat submission API (informational)'
    $graphApiReachable = $false
    try {
        $null = Invoke-ZtGraphRequest -RelativeUri 'security/threatSubmission/emailThreats' `
            -ApiVersion beta `
            -Top 1 `
            -DisablePaging `
            -ErrorAction Stop
        $graphApiReachable = $true
    }
    catch {
        Write-PSFMessage "Email threat submission API probe failed (non-blocking): $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $portalUrl = 'https://security.microsoft.com/securitysettings/userSubmission'

    # Built-in Report button state.
    # Spec/Challenges: null is observed in some tenants. Treat null as "default on" (don't Fail),
    # but flag as Investigate so operators can confirm in the Defender portal.
    $builtInButtonValue = $policy.EnableReportTypeReportFromBuiltInButton
    $builtInButtonNull  = $null -eq $builtInButtonValue
    $builtInButtonOff   = (-not $builtInButtonNull) -and ($builtInButtonValue -eq $false)

    # Routing destinations
    $microsoftRoute = ($policy.EnableReportToMicrosoft -eq $true)

    $junkCount    = ($policy.ReportJunkAddresses    | Measure-Object).Count
    $notJunkCount = ($policy.ReportNotJunkAddresses | Measure-Object).Count
    $phishCount   = ($policy.ReportPhishAddresses   | Measure-Object).Count

    $customMailboxFull    = ($junkCount -gt 0) -and ($notJunkCount -gt 0) -and ($phishCount -gt 0)
    $customMailboxPartial = (($junkCount + $notJunkCount + $phishCount) -gt 0) -and (-not $customMailboxFull)

    $thirdPartyCount = ($policy.ThirdPartyReportAddresses | Measure-Object).Count
    $thirdPartyRoute = ($policy.EnableThirdPartyAddress -eq $true) -and ($thirdPartyCount -gt 0)

    $anyActionableRoute = $microsoftRoute -or $customMailboxFull -or $thirdPartyRoute

    # Rule state: a Disabled rule blocks the custom-mailbox route even when policy parameters look correct.
    $ruleDisabled = ($null -ne $rule) -and ($rule.State -eq 'Disabled')

    # Collect fail and investigate reasons independently; verdict = Fail > Investigate > Pass.
    $failReasons        = [System.Collections.Generic.List[string]]::new()
    $investigateReasons = [System.Collections.Generic.List[string]]::new()

    if ($builtInButtonOff) {
        $failReasons.Add('built-in report button is disabled (EnableReportTypeReportFromBuiltInButton = False)')
    }
    if ($builtInButtonNull) {
        $investigateReasons.Add('EnableReportTypeReportFromBuiltInButton is null — verify built-in button state in the Defender portal')
    }
    if ($customMailboxPartial) {
        $investigateReasons.Add('custom reporting mailbox is partially configured (only some of ReportJunkAddresses / ReportNotJunkAddresses / ReportPhishAddresses are populated)')
    }
    if ($ruleDisabled) {
        $investigateReasons.Add("report submission rule '$($rule.Name)' is Disabled — routing is broken even when policy parameters appear correct")
    }
    # No actionable route AND no partial attempt → definitive Fail (not Investigate).
    # Partial mailbox is handled above as Investigate; only zero-address-lists AND MS off AND no third-party → Fail.
    if (-not $anyActionableRoute -and -not $customMailboxPartial -and -not $builtInButtonOff) {
        $failReasons.Add('no actionable reporting destination is configured (EnableReportToMicrosoft is False, no custom mailbox, no third-party reporter)')
    }

    # Aggregate verdict
    $passed       = $false
    $customStatus = $null

    if ($failReasons.Count -gt 0) {
        $passed = $false
        $reasonText = $failReasons -join '; '
        if ($builtInButtonOff) {
            $testResultMarkdown = "❌ The built-in Outlook Report button is disabled (**EnableReportTypeReportFromBuiltInButton = False**). End users have no built-in mechanism to report phishing or spam — the SOC has no visibility into what reaches inboxes after every automated filter has passed the message. Enable the Report button in [Microsoft 365 Defender > User reported settings]($portalUrl).`n`n> **Note:** If your organization uses a third-party reporting add-in (such as KnowBe4 PAB or Cofense Reporter), end users may still have a reporting mechanism even though this check fails. Verify whether a non-Microsoft reporter is deployed before treating this as a gap.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ The Report button is on but reports are sent nowhere actionable — **EnableReportToMicrosoft** is not True, no fully-configured custom SOC mailbox exists, and no third-party reporter is set. The SOC has no visibility into user-reported messages and Microsoft re-evaluation is not in the loop.`n`n> **Note:** If your organization uses a third-party reporting add-in (such as KnowBe4 PAB or Cofense Reporter), this check may incorrectly fail. Verify whether a non-Microsoft reporter is deployed before treating this as a gap.`n`n%TestResult%"
        }
    }
    elseif ($investigateReasons.Count -gt 0) {
        $passed       = $false
        $customStatus = 'Investigate'
        $reasonText   = ($investigateReasons | ForEach-Object { "- $_" }) -join "`n"
        $testResultMarkdown = "⚠️ Manual review is required in [Microsoft 365 Defender > User reported settings]($portalUrl):`n`n$reasonText`n`n%TestResult%"
    }
    else {
        $passed = $true
        $testResultMarkdown = "✅ The Outlook Report button is on and user-reported messages reach at least one actionable destination — Microsoft (re-evaluation and global anti-phishing model training), a monitored SOC mailbox, or a configured non-Microsoft reporter.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation

    # Helper: format an address list for display (show up to 3 addresses, then count)
    $formatAddresses = {
        param([object]$Addresses)
        $list = @($Addresses | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        if ($list.Count -eq 0) { return '*(none)*' }
        $display = ($list | Select-Object -First 3 | ForEach-Object { Get-SafeMarkdown -Text $_ }) -join ', '
        if ($list.Count -gt 3) { $display += " *(+$($list.Count - 3) more)*" }
        return $display
    }

    # Helper: Boolean/null display
    $formatBool = {
        param([object]$Value)
        if ($null -eq $Value) { return '`null`' }
        return "``$($Value.ToString().ToLower())``"
    }

    # Determine per-row result icons
    # Button
    $btnResult = if ($builtInButtonNull) { '⚠️ Investigate' } elseif ($builtInButtonOff) { '❌ Fail' } else { '✅ Pass' }

    # Microsoft route
    $msResult = if ($microsoftRoute) { '✅ Pass' } else { '❌ Fail' }

    # Custom mailbox address lists
    $junkResult    = if ($junkCount    -gt 0) { '✅ Pass' } elseif ($customMailboxPartial) { '⚠️ Investigate' } else { '—' }
    $notJunkResult = if ($notJunkCount -gt 0) { '✅ Pass' } elseif ($customMailboxPartial) { '⚠️ Investigate' } else { '—' }
    $phishResult   = if ($phishCount   -gt 0) { '✅ Pass' } elseif ($customMailboxPartial) { '⚠️ Investigate' } else { '—' }

    # Third-party reporter
    $tpEnabled      = $policy.EnableThirdPartyAddress
    $tpEnabledDisp  = & $formatBool $tpEnabled
    $tpResult       = if ($thirdPartyRoute) { '✅ Pass' } elseif ($tpEnabled -eq $true -and $thirdPartyCount -eq 0) { '⚠️ Investigate' } else { '—' }
    $tpAddrResult   = if ($thirdPartyCount -gt 0) { '✅ Pass' } elseif ($tpEnabled -eq $true) { '⚠️ Investigate' } else { '—' }

    # Chat and post-submit
    $chatResult     = if ($policy.ReportChatMessageEnabled -eq $true) { '✅ Pass' } else { '—' }
    $postResult     = if ($policy.PostSubmitMessageEnabled -eq $true) { '✅ Pass' } else { '⚠️ Investigate' }

    # Rule state and SentTo
    $ruleStateName   = if ($null -eq $rule) { '*(no rule)*' } else { "``$($rule.State)``" }
    $ruleStateResult = if ($ruleDisabled) { '⚠️ Investigate' } elseif ($null -eq $rule) { '—' } else { '✅ Pass' }
    $ruleSentTo      = if ($null -eq $rule -or [string]::IsNullOrWhiteSpace($rule.SentTo)) { '*(none)*' } else { Get-SafeMarkdown -Text $rule.SentTo }
    $ruleSentToResult = if ($null -ne $rule -and -not [string]::IsNullOrWhiteSpace($rule.SentTo)) { '✅ Pass' } else { '—' }

    $tableRows  = ''
    $tableRows += "| ``EnableReportTypeReportFromBuiltInButton`` | $(& $formatBool $builtInButtonValue) | ``true`` (built-in Outlook Report button) | $btnResult |`n"
    $tableRows += "| ``EnableReportToMicrosoft`` | $(& $formatBool $policy.EnableReportToMicrosoft) | ``true`` (re-evaluation + model training) | $msResult |`n"
    $tableRows += "| ``ReportJunkAddresses`` | $(& $formatAddresses $policy.ReportJunkAddresses) | non-empty (custom SOC mailbox) | $junkResult |`n"
    $tableRows += "| ``ReportNotJunkAddresses`` | $(& $formatAddresses $policy.ReportNotJunkAddresses) | non-empty (custom SOC mailbox) | $notJunkResult |`n"
    $tableRows += "| ``ReportPhishAddresses`` | $(& $formatAddresses $policy.ReportPhishAddresses) | non-empty (custom SOC mailbox) | $phishResult |`n"
    $tableRows += "| ``EnableThirdPartyAddress`` | $tpEnabledDisp | ``true`` (if using non-Microsoft reporter) | $tpResult |`n"
    $tableRows += "| ``ThirdPartyReportAddresses`` | $(& $formatAddresses $policy.ThirdPartyReportAddresses) | non-empty (if using non-Microsoft reporter) | $tpAddrResult |`n"
    $tableRows += "| ``ReportChatMessageEnabled`` | $(& $formatBool $policy.ReportChatMessageEnabled) | ``true`` (MDO P2 + Teams policy required) | $chatResult |`n"
    $tableRows += "| ``PostSubmitMessageEnabled`` | $(& $formatBool $policy.PostSubmitMessageEnabled) | ``true`` (user feedback after submission) | $postResult |`n"
    $tableRows += "| Report submission rule ``State`` | $ruleStateName | ``Enabled`` | $ruleStateResult |`n"
    $tableRows += "| Report submission rule ``SentTo`` | $ruleSentTo | *(SOC mailbox address)* | $ruleSentToResult |`n"

    # Q2 Graph API reachability note (informational — does not affect verdict)
    $graphNote = if ($graphApiReachable) {
        '> ✅ The Microsoft Graph email threat submission API (`/beta/security/threatSubmission/emailThreats`) is reachable — SOC tooling can enumerate user-submitted messages programmatically using the `ThreatSubmission.Read.All` permission.'
    }
    else {
        '> ⚠️ The Microsoft Graph email threat submission API (`/beta/security/threatSubmission/emailThreats`) could not be reached. This does not affect the check verdict, but SOC tooling that ingests the submission queue via Graph will need the `ThreatSubmission.Read.All` permission granted.'
    }

    $formatTemplate = @'
## [User reported settings]({0})

| Setting | Value | Recommended | Result |
| :------ | :---- | :---------- | :----- |
{1}
{2}
'@

    $mdInfo             = $formatTemplate -f $portalUrl, $tableRows, $graphNote
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41035'
        Title  = 'User reporting for phishing and spam is enabled and routed to a reviewed mailbox'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
