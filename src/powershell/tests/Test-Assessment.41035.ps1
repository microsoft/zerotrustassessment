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
    if ($null -eq $policyList -or $policyList.Count -eq 0 -or $null -eq $policyList[0]) {
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

    #endregion Data Collection

    #region Assessment Logic
    $portalUrl = 'https://security.microsoft.com/userSubmissionsReportMessage'

    # Routing destinations per spec
    # microsoftRoute: EnableReportToMicrosoft = True; requires no rule.
    $microsoftRoute = ($policy.EnableReportToMicrosoft -eq $true)

    # Custom mailbox route flags (set to True by the Defender portal when a reporting mailbox is configured).
    $junkFlagSet    = ($policy.ReportJunkToCustomizedAddress    -eq $true)
    $notJunkFlagSet = ($policy.ReportNotJunkToCustomizedAddress -eq $true)
    $phishFlagSet   = ($policy.ReportPhishToCustomizedAddress   -eq $true)

    $junkCount    = ($policy.ReportJunkAddresses    | Measure-Object).Count
    $notJunkCount = ($policy.ReportNotJunkAddresses | Measure-Object).Count
    $phishCount   = ($policy.ReportPhishAddresses   | Measure-Object).Count

    # customMailboxComplete: all three routing flags True AND all three address lists non-empty.
    $customMailboxComplete = $junkFlagSet -and $notJunkFlagSet -and $phishFlagSet -and
                             ($junkCount -gt 0) -and ($notJunkCount -gt 0) -and ($phishCount -gt 0)
    $customMailboxPartial  = ($junkFlagSet -or $notJunkFlagSet -or $phishFlagSet -or
                              ($junkCount -gt 0) -or ($notJunkCount -gt 0) -or ($phishCount -gt 0)) -and
                             (-not $customMailboxComplete)

    # ruleActionable: a rule exists with State=Enabled and SentTo populated.
    # Shared requirement for both the custom-mailbox and non-Microsoft-tool routes.
    $ruleActionable = ($null -ne $rule) -and ($rule.State -eq 'Enabled') -and (-not [string]::IsNullOrWhiteSpace($rule.SentTo))

    # customMailboxRoute: complete flags+addresses AND rule actionable.
    $customMailboxRoute = $customMailboxComplete -and $ruleActionable

    # Spec Investigate: flags+addresses complete but rule absent/disabled/no SentTo.
    $customMailboxRuleProblem = $customMailboxComplete -and (-not $ruleActionable)

    $thirdPartyCount       = ($policy.ThirdPartyReportAddresses | Measure-Object).Count
    $thirdPartyConfigured  = ($policy.EnableThirdPartyAddress -eq $true) -and ($thirdPartyCount -gt 0)
    # thirdPartyPartial: exactly one of EnableThirdPartyAddress / ThirdPartyReportAddresses is set — an attempted but incomplete route.
    $thirdPartyPartial     = (($policy.EnableThirdPartyAddress -eq $true) -or ($thirdPartyCount -gt 0)) -and (-not $thirdPartyConfigured)
    # thirdPartyRoute also requires a report submission rule — without it, TP reports are not delivered
    # to the reporting mailbox or surfaced on the Submissions page (verified against a live tenant).
    $thirdPartyRoute       = $thirdPartyConfigured -and $ruleActionable
    $thirdPartyRuleProblem = $thirdPartyConfigured -and (-not $ruleActionable)

    # Spec evaluation order: Pass → Investigate → Fail
    $anyRoute = $microsoftRoute -or $customMailboxRoute -or $thirdPartyRoute

    $passed       = $false
    $customStatus = $null

    if ($anyRoute) {
        $passed = $true
        $testResultMarkdown = "✅ User reporting in Outlook is enabled and user-reported messages reach Microsoft, a monitored SOC mailbox, or a configured non-Microsoft reporter.`n`n%TestResult%"
    }
    elseif ($customMailboxPartial -or $customMailboxRuleProblem -or $thirdPartyRuleProblem -or $thirdPartyPartial) {
        $passed       = $false
        $customStatus = 'Investigate'
        $investigateDetails = [System.Collections.Generic.List[string]]::new()
        if ($customMailboxPartial) {
            $investigateDetails.Add('custom reporting mailbox is partially configured — only some of **ReportJunkToCustomizedAddress**/**ReportNotJunkToCustomizedAddress**/**ReportPhishToCustomizedAddress** routing flags or **ReportJunkAddresses**/**ReportNotJunkAddresses**/**ReportPhishAddresses** address lists are set; all six must be configured')
        }
        if ($customMailboxRuleProblem) {
            if ($null -eq $rule) {
                $investigateDetails.Add('all three custom-mailbox flags and address lists are configured but no report submission rule exists — nothing delivers messages to the SOC mailbox')
            }
            elseif ($rule.State -eq 'Disabled') {
                $investigateDetails.Add("report submission rule '**$($rule.Name)**' is **Disabled** — routing is broken even when policy flags and address lists appear correct")
            }
            else {
                $investigateDetails.Add("report submission rule '**$($rule.Name)**' has no **SentTo** address — nothing delivers messages to the SOC mailbox")
            }
        }
        if ($thirdPartyRuleProblem) {
            if ($null -eq $rule) {
                $investigateDetails.Add('**EnableThirdPartyAddress** and **ThirdPartyReportAddresses** are configured but no report submission rule exists — nothing delivers non-Microsoft reporter messages to the reporting mailbox')
            }
            elseif ($rule.State -eq 'Disabled') {
                $investigateDetails.Add("report submission rule '**$($rule.Name)**' is **Disabled** — the non-Microsoft reporter route is broken even though **EnableThirdPartyAddress** and **ThirdPartyReportAddresses** are set")
            }
            else {
                $investigateDetails.Add("report submission rule '**$($rule.Name)**' has no **SentTo** address — nothing delivers non-Microsoft reporter messages to the reporting mailbox")
            }
        }
        if ($thirdPartyPartial) {
            $investigateDetails.Add('non-Microsoft reporter route is partially configured — only one of **EnableThirdPartyAddress** / **ThirdPartyReportAddresses** is set; both must be configured')
        }
        $reasonText = ($investigateDetails | ForEach-Object { "- $_" }) -join "`n"
        $testResultMarkdown = "⚠️ The customized mailbox is partially configured, the report submission rule is absent or disabled, or the non-Microsoft reporter route is incomplete; verify the configuration in the Defender portal.`n`n$reasonText`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ Reports are sent nowhere actionable; the SOC has no visibility into what end users are reporting and Microsoft re-evaluation is not in the loop.`n`n> **Note:** If your organization uses a non-Microsoft reporting button (such as KnowBe4 PAB or Cofense Reporter) that does not integrate with Exchange Online's report submission policy, this result may be a false positive — verify whether a third-party reporter is in use before remediating.`n`n%TestResult%"
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

    # Custom mailbox: N/A only when overall Pass and custom mailbox completely unconfigured (not attempted).
    $customMailboxNA = $anyRoute -and (-not $customMailboxComplete) -and (-not $customMailboxPartial)

    # Flag rows — route-aware: Pass only when the complete custom route passes, Investigate when
    # the route was attempted but incomplete, N/A when the route was not attempted, Fail otherwise.
    $junkFlagResult    = if ($customMailboxRoute) { '✅ Pass' } elseif ($customMailboxPartial -or $customMailboxRuleProblem) { '⚠️ Investigate' } elseif ($customMailboxNA) { 'N/A' } else { '❌ Fail' }
    $notJunkFlagResult = if ($customMailboxRoute) { '✅ Pass' } elseif ($customMailboxPartial -or $customMailboxRuleProblem) { '⚠️ Investigate' } elseif ($customMailboxNA) { 'N/A' } else { '❌ Fail' }
    $phishFlagResult   = if ($customMailboxRoute) { '✅ Pass' } elseif ($customMailboxPartial -or $customMailboxRuleProblem) { '⚠️ Investigate' } elseif ($customMailboxNA) { 'N/A' } else { '❌ Fail' }

    # Custom mailbox address lists — same route-aware logic as the flag rows: an attempted but
    # incomplete route reports Investigate; any populated address on an incomplete route is caught by $customMailboxPartial.
    $junkResult    = if ($customMailboxRoute) { '✅ Pass' } elseif ($customMailboxPartial -or $customMailboxRuleProblem) { '⚠️ Investigate' } elseif ($customMailboxNA) { 'N/A' } else { '❌ Fail' }
    $notJunkResult = if ($customMailboxRoute) { '✅ Pass' } elseif ($customMailboxPartial -or $customMailboxRuleProblem) { '⚠️ Investigate' } elseif ($customMailboxNA) { 'N/A' } else { '❌ Fail' }
    $phishResult   = if ($customMailboxRoute) { '✅ Pass' } elseif ($customMailboxPartial -or $customMailboxRuleProblem) { '⚠️ Investigate' } elseif ($customMailboxNA) { 'N/A' } else { '❌ Fail' }

    # Third-party reporter — N/A only when not attempted at all (neither flag nor addresses set) and another route passes.
    $tpEnabled           = $policy.EnableThirdPartyAddress
    $tpEnabledDisp       = & $formatBool $tpEnabled
    $thirdPartyAttempted = ($tpEnabled -eq $true) -or ($thirdPartyCount -gt 0)
    $thirdPartyNA        = $anyRoute -and (-not $thirdPartyAttempted)
    # Route-aware: an attempted but incomplete non-Microsoft route (rule problem or flag/address mismatch)
    # reports Investigate before any address count is considered; both third-party rows share the same state.
    $tpResult     = if ($thirdPartyRoute) { '✅ Pass' } elseif ($thirdPartyRuleProblem -or $thirdPartyPartial) { '⚠️ Investigate' } elseif ($thirdPartyNA) { 'N/A' } else { '❌ Fail' }
    $tpAddrResult = if ($thirdPartyRoute) { '✅ Pass' } elseif ($thirdPartyRuleProblem -or $thirdPartyPartial) { '⚠️ Investigate' } elseif ($thirdPartyNA) { 'N/A' } else { '❌ Fail' }

    # Chat and post-submit — informational only; do not participate in the Pass/Fail/Investigate verdict.
    $chatResult = 'ℹ️ Informational'
    $postResult = 'ℹ️ Informational'

    # Rule state and SentTo — applicable when custom mailbox is fully configured OR non-Microsoft reporter
    # is configured; without the rule, neither route delivers to the reporting mailbox.
    $ruleIsRelevant   = $customMailboxComplete -or $thirdPartyConfigured
    $ruleStateName    = if (-not $ruleIsRelevant -or $null -eq $rule) { '—' } else { "``$($rule.State)``" }
    $ruleStateResult  = if (-not $ruleIsRelevant) { 'N/A' } elseif (-not $ruleActionable) { '⚠️ Investigate' } else { '✅ Pass' }
    $ruleSentTo       = if (-not $ruleIsRelevant -or $null -eq $rule -or [string]::IsNullOrWhiteSpace($rule.SentTo)) { '—' } else { Get-SafeMarkdown -Text $rule.SentTo }
    $ruleSentToResult = if (-not $ruleIsRelevant) { 'N/A' } elseif ($ruleActionable) { '✅ Pass' } else { '⚠️ Investigate' }

    $tableRows  = ''
    $tableRows += "| EnableReportToMicrosoft | $(& $formatBool $policy.EnableReportToMicrosoft) | True (re-evaluation + model training) | $msResult |`n"
    $tableRows += "| ReportJunkToCustomizedAddress | $(& $formatBool $policy.ReportJunkToCustomizedAddress) | True (custom SOC mailbox route) | $junkFlagResult |`n"
    $tableRows += "| ReportNotJunkToCustomizedAddress | $(& $formatBool $policy.ReportNotJunkToCustomizedAddress) | True (custom SOC mailbox route) | $notJunkFlagResult |`n"
    $tableRows += "| ReportPhishToCustomizedAddress | $(& $formatBool $policy.ReportPhishToCustomizedAddress) | True (custom SOC mailbox route) | $phishFlagResult |`n"
    $tableRows += "| ReportJunkAddresses | $(& $formatAddresses $policy.ReportJunkAddresses) | non-empty (custom SOC mailbox) | $junkResult |`n"
    $tableRows += "| ReportNotJunkAddresses | $(& $formatAddresses $policy.ReportNotJunkAddresses) | non-empty (custom SOC mailbox) | $notJunkResult |`n"
    $tableRows += "| ReportPhishAddresses | $(& $formatAddresses $policy.ReportPhishAddresses) | non-empty (custom SOC mailbox) | $phishResult |`n"
    $tableRows += "| EnableThirdPartyAddress | $tpEnabledDisp | True (if using non-Microsoft reporter) | $tpResult |`n"
    $tableRows += "| ThirdPartyReportAddresses | $(& $formatAddresses $policy.ThirdPartyReportAddresses) | non-empty (if using non-Microsoft reporter) | $tpAddrResult |`n"
    $tableRows += "| ReportChatMessageEnabled | $(& $formatBool $policy.ReportChatMessageEnabled) | True (MDO P2 + Teams policy required) | $chatResult |`n"
    $tableRows += "| PostSubmitMessageEnabled | $(& $formatBool $policy.PostSubmitMessageEnabled) | True (user feedback after submission) | $postResult |`n"
    $tableRows += "| Report submission rule State | $ruleStateName | Enabled | $ruleStateResult |`n"
    $tableRows += "| Report submission rule SentTo | $ruleSentTo | (SOC mailbox address) | $ruleSentToResult |`n"

    $formatTemplate = @'
## [User reported settings]({0})

| Setting | Value | Recommended | Result |
| :------ | :---- | :---------- | :----- |
{1}
'@

    $mdInfo             = $formatTemplate -f $portalUrl, $tableRows
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
