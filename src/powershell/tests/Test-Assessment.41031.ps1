<#
.SYNOPSIS
    Checks that Safe Attachments policies in Microsoft Defender for Office 365 are configured to detonate and block.
#>

function Test-Assessment-41031 {
    [ZtTest(
        Category = 'Email and collaboration security',
        CompatibleLicense = ('ATP_ENTERPRISE'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('ExchangeOnline'),
        SfiPillar = 'Protect tenants and isolate production systems',
        TenantType = ('Workforce'),
        TestId = 41031,
        Title = 'Safe Attachments policies in Microsoft Defender for Office 365 are configured to detonate and block',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Safe Attachments policies in Microsoft Defender for Office 365'
    Write-ZtProgress -Activity $activity -Status 'Retrieving Safe Attachments policies'

    # Q1: Retrieve all Safe Attachments policies and associated rules from Exchange Online.
    $allPolicies = $null
    try {
        $allPolicies = @(Get-SafeAttachmentPolicy -ErrorAction Stop | Select-Object Identity, Enable, Action, QuarantineTag, Redirect, RedirectAddress, IsBuiltInProtection, IsDefault)
    }
    catch {
        Write-PSFMessage "Failed to retrieve Safe Attachments policies: $_" -Tag Test -Level Warning
        # Spec: ATP_ENTERPRISE gates this test, so a cmdlet failure points to an Exchange Online
        # permission or connectivity issue rather than an unlicensed tenant.
        $params = @{
            TestId       = '41031'
            Title        = 'Safe Attachments policies in Microsoft Defender for Office 365 are configured to detonate and block'
            Status       = $false
            Result       = '⚠️ Safe Attachments policies could not be retrieved (no policies were returned, the cmdlet is unavailable, or the Exchange Online rule set cannot be read), or an enabled rule references a policy that does not exist; because MDO licensing gates this test, an empty or failed result points to an Exchange Online permission or connectivity issue rather than absence of protection — verify Exchange Online access and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allPolicies.Count -eq 0) {
        # Spec: Built-in Protection is always present in every MDO-licensed tenant, so zero rows
        # indicates an Exchange Online permission or connectivity anomaly, not an unlicensed tenant.
        $params = @{
            TestId       = '41031'
            Title        = 'Safe Attachments policies in Microsoft Defender for Office 365 are configured to detonate and block'
            Status       = $false
            Result       = '⚠️ Safe Attachments policies could not be retrieved (no policies were returned, the cmdlet is unavailable, or the Exchange Online rule set cannot be read), or an enabled rule references a policy that does not exist; because MDO licensing gates this test, an empty or failed result points to an Exchange Online permission or connectivity issue rather than absence of protection — verify Exchange Online access and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Retrieving Safe Attachments rules'

    $allRules = $null
    try {
        $allRules = @(Get-SafeAttachmentRule -ErrorAction Stop | Select-Object Name, SafeAttachmentPolicy, State)
    }
    catch {
        Write-PSFMessage "Failed to retrieve Safe Attachments rules: $_" -Tag Test -Level Warning
        # Spec: if Get-SafeAttachmentRule fails while policies succeeded, return Investigate —
        # the rule set needed to determine which policies are actively applied cannot be read.
        $params = @{
            TestId       = '41031'
            Title        = 'Safe Attachments policies in Microsoft Defender for Office 365 are configured to detonate and block'
            Status       = $false
            Result       = '⚠️ Safe Attachments policies were retrieved but the associated rules could not be read; the set of actively applied policies cannot be determined. Verify Exchange Online permissions and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    # Build lookup: policy Identity → policy object
    $policyByIdentity = @{}
    foreach ($policy in $allPolicies) {
        $policyByIdentity[$policy.Identity] = $policy
    }

    # Spec: zero rows = no custom rules; evaluate Built-in Protection policy alone.
    $enabledRules = @($allRules | Where-Object { $_.State -eq 'Enabled' })

    # Map: policy identity → rule name (join key: rule.SafeAttachmentPolicy == policy.Identity; 1-1 enforced by Exchange Online)
    $rulesForPolicy = @{}
    foreach ($rule in $enabledRules) {
        $rulesForPolicy[$rule.SafeAttachmentPolicy] = $rule.Name
    }

    # Built-in protection policy (IsBuiltInProtection == True)
    $builtInPolicy = $allPolicies | Where-Object { $_.IsBuiltInProtection -eq $true } | Select-Object -First 1

    # Collect in-scope policy identities: built-in first, then all referenced by enabled rules (deduplicated)
    $inScopeIdentities = [System.Collections.Generic.List[string]]::new()
    if ($builtInPolicy) {
        $inScopeIdentities.Add($builtInPolicy.Identity)
    }
    foreach ($policyName in $rulesForPolicy.Keys) {
        if (-not $inScopeIdentities.Contains($policyName)) {
            $inScopeIdentities.Add($policyName)
        }
    }

    $passed         = $true
    $hasInvestigate = $false

    # Missing built-in protection policy is an immediate fail
    if ($null -eq $builtInPolicy) {
        $passed = $false
    }

    $policyRows = [System.Collections.Generic.List[PSCustomObject]]::new()

    # Process in-scope policies: built-in + rule-referenced
    foreach ($identity in $inScopeIdentities) {
        $policy   = $policyByIdentity[$identity]
        $ruleName = if ($rulesForPolicy.ContainsKey($identity)) { $rulesForPolicy[$identity] } else { '' }

        if ($null -eq $policy) {
            # Orphan rule: enabled rule references a policy deleted from Get-SafeAttachmentPolicy → Investigate
            $hasInvestigate = $true
            $policyRows.Add([PSCustomObject]@{
                Identity        = "$identity (not found)"
                PolicyType      = '—'
                Enable          = $null
                Action          = '—'
                QuarantineTag   = '—'
                Redirect        = $null
                RedirectAddress = '—'
                AppliedViaRule  = $ruleName
                RowResult       = 'Investigate'
            })
            continue
        }

        # Type column: precedence Built-in > Default > Custom
        $policyType = if ($policy.IsBuiltInProtection) { 'Built-in' } elseif ($policy.IsDefault) { 'Default' } else { 'Custom' }

        if ($policy.Enable -eq $true -and $policy.Action -eq 'Block' -and $policy.QuarantineTag -eq 'AdminOnlyAccessPolicy') {
            $rowResult = 'Pass'
        }
        else {
            $rowResult = 'Fail'
            $passed    = $false
        }

        # Built-in Protection applies as a preset with no explicit rule; Applied via Rule is blank for it.
        $displayRuleName = if ($policy.IsBuiltInProtection) { '' } else { $ruleName }

        $policyRows.Add([PSCustomObject]@{
            Identity        = $identity
            PolicyType      = $policyType
            Enable          = $policy.Enable
            Action          = $policy.Action
            QuarantineTag   = $policy.QuarantineTag
            Redirect        = $policy.Redirect
            RedirectAddress = if ($policy.RedirectAddress) { $policy.RedirectAddress } else { '—' }
            AppliedViaRule  = $displayRuleName
            RowResult       = $rowResult
        })
    }

    # Unapplied policies: custom policies with no enabled rule — informational only, do not affect verdict
    foreach ($policy in $allPolicies) {
        if ($inScopeIdentities.Contains($policy.Identity)) { continue }
        $policyType = if ($policy.IsBuiltInProtection) { 'Built-in' } elseif ($policy.IsDefault) { 'Default' } else { 'Custom' }
        $policyRows.Add([PSCustomObject]@{
            Identity        = $policy.Identity
            PolicyType      = $policyType
            Enable          = $policy.Enable
            Action          = $policy.Action
            QuarantineTag   = $policy.QuarantineTag
            Redirect        = $policy.Redirect
            RedirectAddress = if ($policy.RedirectAddress) { $policy.RedirectAddress } else { '—' }
            AppliedViaRule  = ''
            RowResult       = 'Not applied'
        })
    }

    # Aggregate verdict: Fail > Investigate > Pass (matching SecOps peer tests)
    $customStatus = $null
    if (-not $passed) {
        $testResultMarkdown = "❌ The Built-in Protection policy is missing or non-compliant, or one or more policies referenced by enabled rules is disabled, set to Allow/DynamicDelivery, or applies a quarantine policy that lets recipients self-release; detonated malware can still reach end users.`n`n%TestResult%"
    }
    elseif ($hasInvestigate) {
        $passed       = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ An enabled Safe Attachments rule references a policy that does not exist; manual review is required.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "✅ Safe Attachments is enabled across the Built-in Protection preset and any policies referenced by enabled rules, set to Block detonated malware, and routes detections to admin-only quarantine.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl  = 'https://security.microsoft.com/safeattachmentv2'
    $maxDisplay = 10
    $totalCount = $policyRows.Count

    # Sort: worst verdict first, then alphabetically by identity; Not applied rows last
    $statusPriority = @{ Fail = 0; Investigate = 1; Pass = 2; 'Not applied' = 3 }
    $sortedRows  = @($policyRows | Sort-Object { $statusPriority[$_.RowResult] }, Identity)
    $displayRows = @($sortedRows | Select-Object -First $maxDisplay)

    $tableRows = ''
    foreach ($row in $displayRows) {
        $identityMd      = Get-SafeMarkdown $row.Identity
        $ruleNameMd      = if ($row.AppliedViaRule) { Get-SafeMarkdown $row.AppliedViaRule } else { '' }
        $enableDisplay    = if ($null -eq $row.Enable) { '—' } elseif ($row.Enable) { '✅ Yes' } else { '❌ No' }
        $actionDisplay    = if ($row.Action -eq '—') { '—' } elseif ($row.Action -eq 'Block') { '✅ Block' } else { "❌ $($row.Action)" }
        $quarantineDisplay = if ($row.QuarantineTag -eq '—') { '—' } elseif ($row.QuarantineTag -eq 'AdminOnlyAccessPolicy') { '✅ AdminOnlyAccessPolicy' } else { "❌ $($row.QuarantineTag)" }
        $redirectDisplay  = if ($null -eq $row.Redirect) { '—' } elseif ($row.Redirect) { 'Yes' } else { 'No' }
        $resultDisplay    = switch ($row.RowResult) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
            'Not applied' { 'Not applied' }
        }
        $tableRows += "| $identityMd | $($row.PolicyType) | $enableDisplay | $actionDisplay | $quarantineDisplay | $redirectDisplay | $($row.RedirectAddress) | $ruleNameMd | $resultDisplay |`n"
    }

    if ($totalCount -gt $maxDisplay) {
        $tableRows += "| ... | ... | ... | ... | ... | ... | ... | ... | ... |`n"
    }

    $preTableLines = ''
    if ($totalCount -gt $maxDisplay) {
        $preTableLines = "Showing $maxDisplay of $totalCount policies. [View all in Microsoft 365 Defender > Policies & rules > Threat policies > Safe Attachments]($portalUrl)`n`n"
    }

    $formatTemplate = @'
{0}
| Identity | Type | Enable | Action | Quarantine policy | Redirect | Redirect address | Applied via rule | Result |
| :------- | :--- | :----- | :----- | :---------------- | :------- | :--------------- | :--------------- | :----- |
{1}
'@

    $mdInfo             = $formatTemplate -f $preTableLines, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41031'
        Title  = 'Safe Attachments policies in Microsoft Defender for Office 365 are configured to detonate and block'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
