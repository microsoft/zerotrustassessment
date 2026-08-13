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
                          EnableThirdPartyAddress,
                          ThirdPartyReportAddresses,
                          ReportChatMessageEnabled,
                          ReportChatMessageToCustomizedAddressEnabled,
                          PhishingReviewResultMessage,
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

    # Spec: In an unconfigured tenant the policy object does not exist at all — it is created only when
    # user-reported settings are explicitly configured. An empty result means the effective defaults
    # cannot be confirmed from PowerShell.
    if ($policyList.Count -eq 0) {
        $params = @{
            TestId       = '41035'
            Title        = 'User reporting for phishing and spam is enabled and routed to a reviewed mailbox'
            Status       = $false
            Result       = '⚠️ **Get-ReportSubmissionPolicy** returned no results. In an unconfigured tenant the policy object is not created until user-reported settings are explicitly saved — the effective defaults cannot be confirmed from PowerShell. Verify the configuration in the [Defender portal > User reported settings](https://security.microsoft.com/securitysettings/userSubmission) and re-run after saving the settings.'
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
        $null = Invoke-ZtGraphRequest -RelativeUri 'security/threatSubmission/emailThreats' -ApiVersion beta -Top 1 -DisablePaging -ErrorAction Stop
        $graphApiReachable = $true
    }
    catch {
        Write-PSFMessage "Email threat submission API probe failed (non-blocking): $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $settingsUrl = 'https://security.microsoft.com/securitysettings/userSubmission'
    $portalUrl   = 'https://security.microsoft.com/userSubmissionsReportMessage'

    # Routing destinations per spec
    # microsoftRoute: EnableReportToMicrosoft = True; requires no rule.
    $microsoftRoute = ($policy.EnableReportToMicrosoft -eq $true)

    $junkCount    = ($policy.ReportJunkAddresses    | Measure-Object).Count
    $notJunkCount = ($policy.ReportNotJunkAddresses | Measure-Object).Count
    $phishCount   = ($policy.ReportPhishAddresses   | Measure-Object).Count

    # customMailboxComplete: all three address lists non-empty.
    $customMailboxComplete = ($junkCount -gt 0) -and ($notJunkCount -gt 0) -and ($phishCount -gt 0)
    $customMailboxPartial  = (($junkCount + $notJunkCount + $phishCount) -gt 0) -and (-not $customMailboxComplete)

    # customMailboxRoute: complete addresses AND rule exists AND State=Enabled AND SentTo populated.
    $ruleDelivers       = ($null -ne $rule) -and ($rule.State -eq 'Enabled') -and (-not [string]::IsNullOrWhiteSpace($rule.SentTo))
    $customMailboxRoute = $customMailboxComplete -and $ruleDelivers

    # Spec Investigate: addresses complete but rule absent/disabled/no SentTo.
    $customMailboxRuleProblem = $customMailboxComplete -and (-not $ruleDelivers)

    $thirdPartyCount = ($policy.ThirdPartyReportAddresses | Measure-Object).Count
    $thirdPartyRoute = ($policy.EnableThirdPartyAddress -eq $true) -and ($thirdPartyCount -gt 0)

    # Spec evaluation order: Pass → Investigate → Fail
    $anyRoute = $microsoftRoute -or $customMailboxRoute -or $thirdPartyRoute

    $passed       = $false
    $customStatus = $null

    if ($anyRoute) {
        $passed = $true
        $testResultMarkdown = "✅ User reporting in Outlook is enabled and user-reported messages reach Microsoft, a monitored SOC mailbox, or a configured non-Microsoft reporter.`n`n%TestResult%"
    }
    elseif ($customMailboxPartial -or $customMailboxRuleProblem) {
        $passed       = $false
        $customStatus = 'Investigate'
        $investigateDetails = [System.Collections.Generic.List[string]]::new()
        if ($customMailboxPartial) {
            $investigateDetails.Add('custom reporting mailbox is partially configured — only some of `ReportJunkAddresses`, `ReportNotJunkAddresses`, `ReportPhishAddresses` are populated; all three must be set')
        }
        if ($customMailboxRuleProblem) {
            if ($null -eq $rule) {
                $investigateDetails.Add('all three custom-mailbox address lists are populated but no report submission rule exists — nothing delivers messages to the SOC mailbox')
            }
            elseif ($rule.State -eq 'Disabled') {
                $investigateDetails.Add("report submission rule '**$($rule.Name)**' is **Disabled** — routing is broken even when policy address lists appear correct")
            }
            else {
                $investigateDetails.Add("report submission rule '**$($rule.Name)**' has no `SentTo` address — nothing delivers messages to the SOC mailbox")
            }
        }
        $reasonText = ($investigateDetails | ForEach-Object { "- $_" }) -join "`n"
        $testResultMarkdown = "⚠️ The customized mailbox is partially configured, or the report submission rule is absent or disabled; verify the configuration in the Defender portal.`n`n$reasonText`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ Reports are sent nowhere actionable; the SOC has no visibility into what end users are reporting and Microsoft re-evaluation is not in the loop.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation

    #format an address list for display (show up to 3 addresses, then count)
    $formatAddresses = {
        param([object]$Addresses)
        $list = @($Addresses | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        if ($list.Count -eq 0) { return '—' }
        $display = ($list | Select-Object -First 3 | ForEach-Object { Get-SafeMarkdown -Text $_ }) -join ', '
        if ($list.Count -gt 3) { $display += " *(+$($list.Count - 3) more)*" }
        return $display
    }

    #Boolean/null display
    $formatBool = {
        param([object]$Value)
        if ($null -eq $Value) { return '—' }
        return $Value.ToString()
    }

    # Determine per-row result icons

    # Microsoft route
    $msResult = if ($microsoftRoute) { '✅ Pass' } else { '❌ Fail' }

    # Custom mailbox address lists
    $junkResult    = if ($junkCount    -gt 0) { '✅ Pass' } elseif ($customMailboxPartial) { '⚠️ Investigate' } else { '❌ Fail' }
    $notJunkResult = if ($notJunkCount -gt 0) { '✅ Pass' } elseif ($customMailboxPartial) { '⚠️ Investigate' } else { '❌ Fail' }
    $phishResult   = if ($phishCount   -gt 0) { '✅ Pass' } elseif ($customMailboxPartial) { '⚠️ Investigate' } else { '❌ Fail' }

    # Third-party reporter
    $tpEnabled     = $policy.EnableThirdPartyAddress
    $tpEnabledDisp = & $formatBool $tpEnabled
    $tpResult      = if ($thirdPartyRoute) { '✅ Pass' } elseif ($tpEnabled -eq $true -and $thirdPartyCount -eq 0) { '⚠️ Investigate' } else { '❌ Fail' }
    $tpAddrResult  = if ($thirdPartyCount -gt 0) { '✅ Pass' } elseif ($tpEnabled -eq $true) { '⚠️ Investigate' } else { '❌ Fail' }

    # Chat and post-submit
    $chatResult = if ($policy.ReportChatMessageEnabled -eq $true) { '✅ Pass' } else { '❌ Fail' }
    $postResult = if ($policy.PostSubmitMessageEnabled -eq $true) { '✅ Pass' } else { '⚠️ Investigate' }

    # Rule state and SentTo — Investigate when customMailboxComplete but rule does not deliver
    $ruleStateName    = if ($null -eq $rule) { '—' } else { "``$($rule.State)``" }
    $ruleStateResult  = if ($customMailboxRuleProblem) { '⚠️ Investigate' } elseif ($null -eq $rule) { '❌ Fail' } elseif ($rule.State -eq 'Enabled') { '✅ Pass' } else { '⚠️ Investigate' }
    $ruleSentTo       = if ($null -eq $rule -or [string]::IsNullOrWhiteSpace($rule.SentTo)) { '—' } else { Get-SafeMarkdown -Text $rule.SentTo }
    $ruleSentToResult = if ($ruleDelivers) { '✅ Pass' } elseif ($customMailboxRuleProblem) { '⚠️ Investigate' } else { '❌ Fail' }

    $tableRows  = ''
    $tableRows += "| EnableReportToMicrosoft | $(& $formatBool $policy.EnableReportToMicrosoft) | True (re-evaluation + model training) | $msResult |`n"
    $tableRows += "| ReportJunkAddresses | $(& $formatAddresses $policy.ReportJunkAddresses) | non-empty (custom SOC mailbox) | $junkResult |`n"
    $tableRows += "| ReportNotJunkAddresses | $(& $formatAddresses $policy.ReportNotJunkAddresses) | non-empty (custom SOC mailbox) | $notJunkResult |`n"
    $tableRows += "| ReportPhishAddresses | $(& $formatAddresses $policy.ReportPhishAddresses) | non-empty (custom SOC mailbox) | $phishResult |`n"
    $tableRows += "| EnableThirdPartyAddress | $tpEnabledDisp | True (if using non-Microsoft reporter) | $tpResult |`n"
    $tableRows += "| ThirdPartyReportAddresses | $(& $formatAddresses $policy.ThirdPartyReportAddresses) | non-empty (if using non-Microsoft reporter) | $tpAddrResult |`n"
    $tableRows += "| ReportChatMessageEnabled | $(& $formatBool $policy.ReportChatMessageEnabled) | True (MDO P2 + Teams policy required) | $chatResult |`n"
    $tableRows += "| PostSubmitMessageEnabled | $(& $formatBool $policy.PostSubmitMessageEnabled) | True (user feedback after submission) | $postResult |`n"
    $tableRows += "| Report submission rule State | $ruleStateName | Enabled | $ruleStateResult |`n"
    $tableRows += "| Report submission rule SentTo | $ruleSentTo | (SOC mailbox address) | $ruleSentToResult |`n"

    # Q2 Graph API reachability note (informational — does not affect verdict)
    $graphNote = if ($graphApiReachable) {
        '> ✅ The Microsoft Graph email threat submission API (/beta/security/threatSubmission/emailThreats) is reachable — SOC tooling can enumerate user-submitted messages programmatically using the ThreatSubmission.Read.All permission.'
    }
    else {
    '> ⚠️ The Microsoft Graph email threat submission API (/beta/security/threatSubmission/emailThreats) could not be reached. This does not affect the check verdict, but SOC tooling that ingests the submission queue via Graph will need the ThreatSubmission.Read.All permission granted.'
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
