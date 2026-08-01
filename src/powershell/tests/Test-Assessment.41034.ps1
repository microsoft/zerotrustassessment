<#
.SYNOPSIS
    Anti-spam (hosted content filter) policies are configured with recommended thresholds and actions.
#>

function Test-Assessment-41034 {
    [ZtTest(
        Category = 'Email and collaboration security',
        CompatibleLicense = ('EXCHANGE_S_STANDARD'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        Service = ('ExchangeOnline'),
        SfiPillar = 'Protect tenants and isolate production systems',
        TenantType = ('Workforce'),
        TestId = 41034,
        Title = 'Anti-spam (hosted content filter) policies are configured with recommended thresholds and actions',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking anti-spam (hosted content filter) policy configuration'
    Write-ZtProgress -Activity $activity -Status 'Retrieving hosted content filter policies'
    
    # Q1a: Retrieve all hosted content filter policies from Exchange Online.
    $allPolicies = $null
    try {
        $allPolicies = @(Get-HostedContentFilterPolicy -ErrorAction Stop |
            Select-Object Identity, IsBuiltInProtection, IsDefault,
                          BulkThreshold, MarkAsSpamBulkMail,
                          SpamAction, HighConfidenceSpamAction, PhishSpamAction,
                          HighConfidencePhishAction, BulkSpamAction,
                          AllowedSenders, AllowedSenderDomains,
                          HighConfidencePhishQuarantineTag,
                          PhishZapEnabled, SpamZapEnabled, InlineSafetyTipsEnabled)
    }
    catch {
        Write-PSFMessage "Failed to retrieve hosted content filter policies: $_" -Tag Test -Level Warning
        $params = @{
            TestId       = '41034'
            Title        = 'Anti-spam (hosted content filter) policies are configured with recommended thresholds and actions'
            Status       = $false
            Result       = '⚠️ Hosted content filter policies could not be retrieved; verify Exchange Online permissions and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Spec: The Default policy always exists in Exchange Online; zero rows indicates a cmdlet failure.
    if ($allPolicies.Count -eq 0) {
        $params = @{
            TestId       = '41034'
            Title        = 'Anti-spam (hosted content filter) policies are configured with recommended thresholds and actions'
            Status       = $false
            Result       = '⚠️ **Get-HostedContentFilterPolicy** returned no results. The Default policy is always present in Exchange Online; an empty result indicates an Exchange Online permission or connectivity issue rather than absence of protection — verify access and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q1b: Retrieve all hosted content filter rules to determine which policies are actively applied.
    Write-ZtProgress -Activity $activity -Status 'Retrieving hosted content filter rules'
    $allRules = $null
    try {
        $allRules = @(Get-HostedContentFilterRule -ErrorAction Stop |
            Select-Object Name, HostedContentFilterPolicy, Priority, State,
                          RecipientDomainIs, SentTo, SentToMemberOf)
    }
    catch {
        Write-PSFMessage "Failed to retrieve hosted content filter rules: $_" -Tag Test -Level Warning
        # Spec: if Get-HostedContentFilterRule fails while policies succeeded, return Investigate —
        # the rule set needed to determine which policies are actively applied cannot be read.
        $params = @{
            TestId       = '41034'
            Title        = 'Anti-spam (hosted content filter) policies are configured with recommended thresholds and actions'
            Status       = $false
            Result       = '⚠️ Hosted content filter policies were retrieved but the associated rules could not be read; the set of actively applied policies cannot be determined. Verify Exchange Online permissions and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    # Build case-insensitive identity lookup
    $policyByIdentity = @{}
    foreach ($policy in $allPolicies) {
        $policyByIdentity[$policy.Identity] = $policy
    }

    # Spec: zero rows from Get-HostedContentFilterRule is NOT an error — evaluate Default policy alone.
    $enabledRules = @($allRules | Where-Object { $_.State -eq 'Enabled' })

    # Map: policy identity → all rule names that reference it
    $rulesForPolicy = @{}
    foreach ($rule in $enabledRules) {
        if (-not $rulesForPolicy.ContainsKey($rule.HostedContentFilterPolicy)) {
            $rulesForPolicy[$rule.HostedContentFilterPolicy] = [System.Collections.Generic.List[string]]::new()
        }
        $rulesForPolicy[$rule.HostedContentFilterPolicy].Add($rule.Name)
    }

    # Default policy (IsDefault == True) — always in-scope as the catch-all
    $defaultPolicy = $allPolicies | Where-Object { $_.IsDefault -eq $true } | Select-Object -First 1

    # Spec: Default policy must be present; if policies were returned but none is marked IsDefault,
    # something is wrong with the data — return Investigate rather than a false Pass.
    if ($null -eq $defaultPolicy) {
        $params = @{
            TestId       = '41034'
            Title        = 'Anti-spam (hosted content filter) policies are configured with recommended thresholds and actions'
            Status       = $false
            Result       = '⚠️ Policies were returned by **Get-HostedContentFilterPolicy** but none has **IsDefault = $true**. The Default policy is always present in Exchange Online; this indicates unexpected data — verify Exchange Online access and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Collect in-scope policy identities: Default first, then all referenced by enabled rules (deduplicated).
    # Use OrdinalIgnoreCase HashSet — Exchange may return different casing between cmdlets.
    $inScopeIdentities = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $inScopeIdentities.Add($defaultPolicy.Identity) | Out-Null
    foreach ($policyName in $rulesForPolicy.Keys) {
        $inScopeIdentities.Add($policyName) | Out-Null
    }

    $passed         = $true
    $hasInvestigate = $false

    $policyRows = [System.Collections.Generic.List[PSCustomObject]]::new()

    # Process in-scope policies
    foreach ($identity in $inScopeIdentities) {
        $policy   = $policyByIdentity[$identity]
        $ruleName = if ($rulesForPolicy.ContainsKey($identity)) { $rulesForPolicy[$identity] -join ', ' } else { '' }

        if ($null -eq $policy) {
            # Orphan rule: enabled rule references a policy not found in Get-HostedContentFilterPolicy → Investigate
            $hasInvestigate = $true
            $policyRows.Add([PSCustomObject]@{
                Identity  = $identity
                IsDefault = $false
                IsOrphan  = $true
                RuleName  = $ruleName
                RowResult = 'Investigate'
            })
            continue
        }

        # Evaluate each baseline property and collect named fail reasons
        $allowedSendersCount       = ($policy.AllowedSenders | Measure-Object).Count
        $allowedSenderDomainsCount = ($policy.AllowedSenderDomains | Measure-Object).Count

        $failReasons = [System.Collections.Generic.List[string]]::new()
        # Spec-named reasons first (most impactful)
        if ($policy.HighConfidencePhishAction -ne 'Quarantine')               { $failReasons.Add('HC-phish delivered') }
        if ($policy.PhishSpamAction -ne 'Quarantine')                         { $failReasons.Add('phish delivered') }
        if ($policy.HighConfidenceSpamAction -ne 'Quarantine')                { $failReasons.Add('HC-spam delivered') }
        if ($policy.SpamAction -notin @('MoveToJmf', 'Quarantine'))           { $failReasons.Add("spam action $($policy.SpamAction)") }
        if ($policy.BulkSpamAction -notin @('MoveToJmf', 'Quarantine'))       { $failReasons.Add("bulk action $($policy.BulkSpamAction)") }
        if ($null -eq $policy.BulkThreshold)  { $failReasons.Add('bulk threshold null (unexpected — verify policy data)') }
        elseif ($policy.BulkThreshold -gt 6) { $failReasons.Add("bulk threshold $($policy.BulkThreshold)") }
        if ($policy.MarkAsSpamBulkMail -ne 'On')                              { $failReasons.Add('MarkAsSpamBulkMail off') }
        if ($allowedSendersCount -gt 0)                                       { $failReasons.Add('allowed senders non-empty') }
        if ($allowedSenderDomainsCount -gt 0)                                 { $failReasons.Add('allowed domains non-empty') }
        if ($policy.HighConfidencePhishQuarantineTag -ne 'AdminOnlyAccessPolicy') { $failReasons.Add('HC-phish tag allows self-release') }
        if ($policy.PhishZapEnabled -ne $true)                                { $failReasons.Add('PhishZAP disabled') }
        if ($policy.SpamZapEnabled -ne $true)                                 { $failReasons.Add('SpamZAP disabled') }
        if ($policy.InlineSafetyTipsEnabled -ne $true)                        { $failReasons.Add('SafetyTips disabled') }

        $rowFails = $failReasons.Count -gt 0
        if ($rowFails) {
            $passed = $false
        }

        $rowResult       = if ($rowFails) { 'Fail' } else { 'Pass' }
        # Default policy has no rule; rule name is blank for it.
        $displayRuleName = if ($policy.IsDefault) { '' } else { $ruleName }

        $policyRows.Add([PSCustomObject]@{
            Identity                         = $identity
            IsDefault                        = ($policy.IsDefault -eq $true)
            IsOrphan                         = $false
            RuleName                         = $displayRuleName
            FailReasons                      = $failReasons
            RowResult                        = $rowResult
            SpamAction                       = $policy.SpamAction
            HighConfidenceSpamAction         = $policy.HighConfidenceSpamAction
            PhishSpamAction                  = $policy.PhishSpamAction
            HighConfidencePhishAction        = $policy.HighConfidencePhishAction
            BulkSpamAction                   = $policy.BulkSpamAction
            BulkThreshold                    = $policy.BulkThreshold
            MarkAsSpamBulkMail               = $policy.MarkAsSpamBulkMail
            PhishZapEnabled                  = $policy.PhishZapEnabled
            SpamZapEnabled                   = $policy.SpamZapEnabled
            InlineSafetyTipsEnabled          = $policy.InlineSafetyTipsEnabled
            AllowedSendersCount              = $allowedSendersCount
            AllowedSenderDomainsCount        = $allowedSenderDomainsCount
            HighConfidencePhishQuarantineTag = $policy.HighConfidencePhishQuarantineTag
        })
    }

    # Aggregate verdict: Fail > Investigate > Pass
    $customStatus = $null
    if (-not $passed) {
        $testResultMarkdown = "❌ One or more anti-spam policies allow high-confidence phishing to be delivered (action is not Quarantine), set a permissive bulk threshold, or contain entries in the per-policy allowed-sender list that bypass spam, spoofing, and most phishing filtering for those senders. Operational exceptions for legitimate vendors belong in the **[Tenant Allow/Block List](https://security.microsoft.com/tenantAllowBlockList)**, where they can be reviewed and expired.`n`n%TestResult%"
    }
    elseif ($hasInvestigate) {
        $passed       = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ An enabled rule references a policy that does not exist in **Get-HostedContentFilterPolicy**; manual review is required.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "✅ Anti-spam policies route high-confidence phishing to admin-only quarantine, use a strict bulk threshold, and contain no per-policy allow-sender entries that bypass filtering.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl  = 'https://security.microsoft.com/antispam'
    $maxDisplay = 10
    $totalCount = $policyRows.Count

    # Sort: worst verdict first (Fail > Investigate > Pass), then alphabetically by identity
    $statusPriority = @{ Fail = 0; Investigate = 1; Pass = 2 }
    $sortedRows  = @($policyRows | Sort-Object { $statusPriority[$_.RowResult] }, Identity)
    $displayRows = @($sortedRows | Select-Object -First $maxDisplay)

    $tableRows = ''
    foreach ($row in $displayRows) {
        # Policy column: Identity with [default] suffix for the Default policy
        $policySuffix  = if ($row.IsDefault) { ' [default]' } else { '' }
        $policyDisplay = "$(Get-SafeMarkdown $row.Identity)$policySuffix"

        # Scope column: show all rule names if multiple rules reference this policy
        $scopeDisplay = if ($row.IsOrphan -or $row.RuleName) {
            $ruleLabel = if (($row.RuleName -split ', ').Count -gt 1) { 'rules' } else { 'rule' }
            "Applied via $ruleLabel $(Get-SafeMarkdown $row.RuleName)"
        } else {
            'Default (catch-all)'
        }

        # Compact columns — blank for orphan rows where policy data is unavailable
        if ($row.IsOrphan) {
            $filterActionsDisplay = '—'
            $bulkZapDisplay       = '—'
            $allowListsDisplay    = '—'
        }
        else {
            # Filter actions: Phish: <action>/HC:<action> • Spam: <action>/HC:<action> • Bulk: <action>
            $filterActionsDisplay = "Phish: $($row.PhishSpamAction)/HC:$($row.HighConfidencePhishAction) • Spam: $($row.SpamAction)/HC:$($row.HighConfidenceSpamAction) • Bulk: $($row.BulkSpamAction)"

            # Bulk & ZAP: Bulk: <n>/6 • MarkBulk: Y/N • ZAP: Y/N • SafetyTips: Y/N
            # ZAP is a single Y/N: Y only when both PhishZapEnabled AND SpamZapEnabled are true
            $zapDisplay        = if ($row.PhishZapEnabled -eq $true -and $row.SpamZapEnabled -eq $true) { 'Y' } else { 'N' }
            $markBulkDisplay   = if ($row.MarkAsSpamBulkMail -eq 'On') { 'Y' } else { 'N' }
            $safetyTipsDisplay = if ($row.InlineSafetyTipsEnabled -eq $true) { 'Y' } else { 'N' }
            $bulkZapDisplay    = "Bulk: $($row.BulkThreshold)/6 • MarkBulk: $markBulkDisplay • ZAP: $zapDisplay • SafetyTips: $safetyTipsDisplay"

            # Allow lists & quarantine tag: Senders: N • Domains: N • HC-Phish tag: <tag>
            $allowListsDisplay = "Senders: $($row.AllowedSendersCount) • Domains: $($row.AllowedSenderDomainsCount) • HC-Phish tag: $(Get-SafeMarkdown -Text $row.HighConfidencePhishQuarantineTag)"
        }

        # Result column with named reasons per spec
        $resultDisplay = switch ($row.RowResult) {
            'Pass'        { '✅ Pass' }
            'Investigate' { '⚠️ Investigate (orphan rule reference)' }
            'Fail'        { "❌ Fail ($($row.FailReasons -join '; '))" }
        }

        $tableRows += "| $policyDisplay | $scopeDisplay | $filterActionsDisplay | $bulkZapDisplay | $allowListsDisplay | $resultDisplay |`n"
    }

    if ($totalCount -gt $maxDisplay) {
        $tableRows += "| ... | ... | ... | ... | ... | ... |`n"
    }

    $preTableLines = ''
    if ($totalCount -gt $maxDisplay) {
        $preTableLines = "Showing $maxDisplay of $totalCount policies. [View all in Microsoft 365 Defender > Policies & rules > Threat policies > Anti-spam]($portalUrl)`n`n"
    }

    $formatTemplate = @'
{0}
## [Anti-spam policy settings]({2})

| Policy | Scope | Filter actions | Bulk & ZAP | Allow lists & quarantine tag | Result |
| :----- | :---- | :------------- | :--------- | :--------------------------- | :----- |
{1}
'@

    $mdInfo             = $formatTemplate -f $preTableLines, $tableRows, $portalUrl
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41034'
        Title  = 'Anti-spam (hosted content filter) policies are configured with recommended thresholds and actions'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
