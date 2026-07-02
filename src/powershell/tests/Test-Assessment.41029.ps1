<#
.SYNOPSIS
    Anti-malware policies are configured according to recommended settings
#>

function Test-Assessment-41029 {
    [ZtTest(
        Category = 'Email and collaboration security',
        ImplementationCost = 'Low',
        Service = ('ExchangeOnline'),
        CompatibleLicense = ('EXCHANGE_S_STANDARD'),
        Pillar = 'SecOps',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and isolate production systems',
        TenantType = ('Workforce'),
        TestId = 41029,
        Title = 'Anti-malware policies are configured according to recommended settings',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking anti-malware policy configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting anti-malware filter policies'

    $policies = @()
    $rules = @()
    $errorMsg = $null

    try {
        # Q1: Enumerate all anti-malware filter policies and their settings
        $policies = @(Get-MalwareFilterPolicy -ErrorAction Stop |
            Select-Object Identity, IsDefault, EnableFileFilter, FileTypes, ZapEnabled, QuarantineTag,
                          EnableInternalSenderAdminNotifications, EnableExternalSenderAdminNotifications,
                          ExternalSenderAdminAddress)

        # Q2: Enumerate all anti-malware filter rules (required to determine which custom policies are in-scope)
        Write-ZtProgress -Activity $activity -Status 'Getting anti-malware filter rules'
        $rules = @(Get-MalwareFilterRule -ErrorAction Stop |
            Select-Object Name, MalwareFilterPolicy, Priority, State)
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying anti-malware configuration: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($errorMsg) {
        Write-PSFMessage 'Not connected to Exchange Online.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedExchange
        return
    }

    $passed = $false
    $customStatus = $null
    $inScopePolicies = [System.Collections.Generic.List[object]]::new()
    $orphanedRules = @()

    # Step 2: Empty policy result indicates API failure — default policy always exists in Exchange Online
    if ($policies.Count -eq 0) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ **Investigate:** ``Get-MalwareFilterPolicy`` returned no results. The default policy is always present in Exchange Online; an empty result indicates an API or connectivity failure."
    }
    else {
        # Step 3: Build in-scope set = default policy + policies referenced by enabled rules
        $enabledRules = @($rules | Where-Object { $_.State -eq 'Enabled' })

        # Build case-insensitive lookup by Identity for rule-to-policy resolution.
        # The spec says match on "Identity or Name", but for Get-MalwareFilterPolicy the returned
        # Identity IS the policy name string (Exchange accepts name, GUID, or DN as input; the
        # cmdlet echoes back the name as Identity). MalwareFilterRule.MalwareFilterPolicy also
        # stores the policy name, so a single Identity-keyed lookup satisfies both identifiers.
        $policyByIdentity = @{}
        foreach ($policy in $policies) {
            $policyByIdentity[$policy.Identity] = $policy
        }

        # Track in-scope identities to avoid duplicates
        $inScopeIdentities = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

        # Default policy is always in-scope (catch-all for any recipient not matched by a custom rule)
        foreach ($policy in ($policies | Where-Object { $_.IsDefault -eq $true })) {
            if ($inScopeIdentities.Add($policy.Identity)) {
                [void]$inScopePolicies.Add($policy)
            }
        }

        # Step 4: Add policies referenced by enabled rules; flag orphaned rules (reference missing policy)
        foreach ($rule in $enabledRules) {
            $referencedName = $rule.MalwareFilterPolicy
            if ($policyByIdentity.ContainsKey($referencedName)) {
                $referencedPolicy = $policyByIdentity[$referencedName]
                if ($inScopeIdentities.Add($referencedPolicy.Identity)) {
                    [void]$inScopePolicies.Add($referencedPolicy)
                }
            }
            else {
                $orphanedRules += $rule
            }
        }

        if ($orphanedRules.Count -gt 0) {
            $customStatus = 'Investigate'
            $orphanNames = ($orphanedRules | ForEach-Object { Get-SafeMarkdown -Text $_.Name }) -join ', '
            $testResultMarkdown = "⚠️ **Investigate:** $($orphanedRules.Count) enabled rule(s) reference a policy that does not exist (orphan rule); manual review is required. Orphaned rules: $orphanNames."
        }
        else {
            # Steps 5–7: Evaluate compliance for each in-scope policy
            $nonCompliantPolicies = @()
            $investigatePolicies = @()

            foreach ($policy in $inScopePolicies) {
                if ($policy.QuarantineTag -ne 'AdminOnlyAccessPolicy') {
                    # Step 6: Customer-defined quarantine policy — release behavior cannot be confirmed
                    $policy | Add-Member -NotePropertyName RowResult -NotePropertyValue '⚠️ Investigate' -Force
                    $investigatePolicies += $policy
                }
                elseif ($policy.EnableFileFilter -ne $true -or $policy.ZapEnabled -ne $true) {
                    # Step 7 (fail): Common Attachment Filter or ZAP is not enabled
                    $policy | Add-Member -NotePropertyName RowResult -NotePropertyValue '❌ Fail' -Force
                    $nonCompliantPolicies += $policy
                }
                else {
                    $policy | Add-Member -NotePropertyName RowResult -NotePropertyValue '✅ Pass' -Force
                }
            }

            if ($investigatePolicies.Count -gt 0) {
                $customStatus = 'Investigate'
                $policyNames = ($investigatePolicies | ForEach-Object { Get-SafeMarkdown -Text $_.Identity }) -join ', '
                $testResultMarkdown = "⚠️ **Investigate:** One or more in-scope policies apply a customer-defined quarantine policy whose release behavior cannot be confirmed by this check — cross-check spec 41030. Affected: $policyNames."
            }
            elseif ($nonCompliantPolicies.Count -gt 0) {
                $passed = $false
                $testResultMarkdown = "❌ One or more in-scope anti-malware policies have the Common Attachment Filter disabled, ZAP disabled, or apply a quarantine policy that permits recipient self-release of malware."
            }
            else {
                $passed = $true
                $testResultMarkdown = "✅ All in-scope anti-malware policies have the Common Attachment Filter enabled, zero-hour auto purge enabled, and route detected malware to an admin-only quarantine."
            }
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($inScopePolicies.Count -gt 0) {
        $totalInScope = $inScopePolicies.Count
        $displayPolicies = $inScopePolicies | Select-Object -First 10
        $truncated = $totalInScope -gt 10

        $testResultMarkdown += "`n`n### [In-scope anti-malware policies](https://security.microsoft.com/antimalwarev2)`n`n"
        $testResultMarkdown += "| Identity | Is default | Common attachment filter | File types (count) | ZAP | Quarantine tag | Applied | Result |`n"
        $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $displayPolicies) {
            $identity       = Get-SafeMarkdown -Text $policy.Identity
            $isDefault      = if ($policy.IsDefault -eq $true) { 'Yes' } else { 'No' }
            $fileFilter     = if ($policy.EnableFileFilter -eq $true) { '✅ Yes' } else { '❌ No' }
            $fileTypesCount = if ($policy.FileTypes) { $policy.FileTypes.Count } else { 0 }
            $zap            = if ($policy.ZapEnabled -eq $true) { '✅ Yes' } else { '❌ No' }
            $quarantineTag  = Get-SafeMarkdown -Text $policy.QuarantineTag
            $applied        = if ($policy.IsDefault -eq $true) { 'Default catch-all' } else { 'Via enabled rule' }
            $rowResult      = $policy.RowResult

            $testResultMarkdown += "| $identity | $isDefault | $fileFilter | $fileTypesCount | $zap | $quarantineTag | $applied | $rowResult |`n"
        }

        if ($truncated) {
            $testResultMarkdown += "| ... | | | | | | | |`n"
            $testResultMarkdown += "`n_Showing first 10 of $totalInScope policies. [View all anti-malware policies](https://security.microsoft.com/antimalwarev2)._`n"
        }

        $internalNotifyCount = @($inScopePolicies | Where-Object { $_.EnableInternalSenderAdminNotifications -eq $true }).Count
        $externalNotifyCount = @($inScopePolicies | Where-Object { $_.EnableExternalSenderAdminNotifications -eq $true }).Count
        $testResultMarkdown += "`n_Of $totalInScope in-scope policies, $internalNotifyCount have internal sender admin notifications enabled and $externalNotifyCount have external sender admin notifications enabled. Microsoft's baseline recommends both off; these settings do not affect this check's Pass/Fail._`n"

    }
    #endregion Report Generation

    $params = @{
        TestId = '41029'
        Title  = 'Anti-malware policies are configured according to recommended settings'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
