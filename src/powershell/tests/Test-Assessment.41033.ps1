<#
.SYNOPSIS
    Anti-phishing policies in Microsoft Defender for Office 365 are configured with impersonation and spoof protection.

.NOTES
    Test ID: 41033
    Workshop Task: SECOPS-033
    Pillar: SecOps
    Category: Email and collaboration security
    Required Module: ExchangeOnlineManagement
    Required permissions: Get-AntiPhishPolicy, Get-AntiPhishRule
#>

function Test-Assessment-41033 {
    [ZtTest(
        Category           = 'Email and collaboration security',
        CompatibleLicense  = ('ATP_ENTERPRISE'),
        ImplementationCost = 'Low',
        Pillar             = 'SecOps',
        RiskLevel          = 'High',
        Service            = ('SecurityCompliance'),
        SfiPillar          = 'Protect tenants and isolate production systems',
        TenantType         = ('Workforce'),
        TestId             = 41033,
        Title              = 'Anti-phishing policies in Microsoft Defender for Office 365 are configured with impersonation and spoof protection',
        UserImpact         = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking anti-phishing policy configuration'

    Write-ZtProgress -Activity $activity -Status 'Querying anti-phishing policies'
    try {
        $policies = @(Get-AntiPhishPolicy -ErrorAction Stop | Select-Object `
            Identity, IsBuiltInProtection, IsDefault, Enabled,
            EnableSpoofIntelligence, AuthenticationFailAction,
            EnableUnauthenticatedSender, EnableViaTag,
            EnableMailboxIntelligence, EnableMailboxIntelligenceProtection,
            MailboxIntelligenceProtectionAction,
            EnableTargetedUserProtection, TargetedUsersToProtect, TargetedUserProtectionAction,
            EnableTargetedDomainsProtection, TargetedDomainsToProtect, TargetedDomainProtectionAction,
            EnableOrganizationDomainsProtection, PhishThresholdLevel,
            HonorDmarcPolicy, DmarcQuarantineAction, DmarcRejectAction,
            TargetedUserQuarantineTag, TargetedDomainQuarantineTag,
            MailboxIntelligenceQuarantineTag, SpoofQuarantineTag)
    }
    catch {
        Write-PSFMessage "Failed to retrieve anti-phishing policies: $_" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedExchange
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying anti-phishing rules'
    try {
        $rules = @(Get-AntiPhishRule -ErrorAction Stop | Select-Object `
            Name, AntiPhishPolicy, Priority, State)
    }
    catch {
        Write-PSFMessage "Failed to retrieve anti-phishing rules: $_" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedExchange
        return
    }
    #endregion Data Collection

    #region Assessment Logic

    # The default policy always exists; zero rows signals a connectivity issue
    if ($policies.Count -eq 0) {
        $params = @{
            TestId       = '41033'
            Title        = 'Anti-phishing policies in Microsoft Defender for Office 365 are configured with impersonation and spoof protection'
            Status       = $false
            Result       = '⚠️ `Get-AntiPhishPolicy` returned zero rows. The default policy always exists; verify Exchange Online connectivity and re-run.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Quarantine tag names that permit recipients to self-release quarantined messages
    $selfReleaseTags = @('DefaultFullAccessPolicy', 'DefaultFullAccessWithNotificationPolicy')

    # Identify enabled rules and map them to their policy names
    $enabledRules   = @($rules | Where-Object { $_.State -eq 'Enabled' })
    $allPolicyNames = @($policies | Select-Object -ExpandProperty Identity)

    # Rules whose referenced policy is absent from Get-AntiPhishPolicy output
    $orphanedRules  = @($enabledRules | Where-Object { $_.AntiPhishPolicy -notin $allPolicyNames })

    # Build policy-name → enabled rule names map
    $policyRuleMap = @{}
    foreach ($rule in $enabledRules) {
        if (-not $policyRuleMap.ContainsKey($rule.AntiPhishPolicy)) {
            $policyRuleMap[$rule.AntiPhishPolicy] = [System.Collections.Generic.List[string]]::new()
        }
        [void]$policyRuleMap[$rule.AntiPhishPolicy].Add($rule.Name)
    }

    # Evaluate each policy
    $policyResults = foreach ($policy in $policies) {
        $userCount   = if ($policy.TargetedUsersToProtect) { @($policy.TargetedUsersToProtect).Count } else { 0 }
        $domainCount = if ($policy.TargetedDomainsToProtect) { @($policy.TargetedDomainsToProtect).Count } else { 0 }
        $appliedRule = if ($policyRuleMap.ContainsKey($policy.Identity)) {
            ($policyRuleMap[$policy.Identity] -join ', ')
        }
        else { '' }

        # Core compliance flags
        $spoofOk        = $policy.EnableSpoofIntelligence -eq $true
        $dmarcOk        = $policy.HonorDmarcPolicy -eq $true
        $mbxIntelOk     = $policy.EnableMailboxIntelligence -eq $true -and $policy.EnableMailboxIntelligenceProtection -eq $true
        $mbxActionOk    = $policy.MailboxIntelligenceProtectionAction -eq 'Quarantine'
        $authFailOk     = $policy.AuthenticationFailAction -eq 'Quarantine'
        $meetsMinSubset = $spoofOk -and $dmarcOk -and $mbxIntelOk

        # Impersonation coverage
        $hasUserImpers  = $policy.EnableTargetedUserProtection -eq $true -and $userCount -gt 0
        $hasOrgDomains  = $policy.EnableOrganizationDomainsProtection -eq $true
        $hasDomainImpers = ($policy.EnableTargetedDomainsProtection -eq $true -and $domainCount -gt 0) -or $hasOrgDomains
        $userActionOk   = ($policy.EnableTargetedUserProtection -ne $true) -or $policy.TargetedUserProtectionAction -eq 'Quarantine'
        $domActionOk    = ($policy.EnableTargetedDomainsProtection -ne $true) -or $policy.TargetedDomainProtectionAction -eq 'Quarantine'

        # Quarantine tag compliance — collect only non-empty tag values
        $qtags          = @(
            $policy.TargetedUserQuarantineTag,
            $policy.TargetedDomainQuarantineTag,
            $policy.MailboxIntelligenceQuarantineTag,
            $policy.SpoofQuarantineTag
        ) | Where-Object { -not [string]::IsNullOrEmpty($_) }
        $hasSelfRelease = ($qtags | Where-Object { $_ -in $selfReleaseTags }).Count -gt 0

        # Compliant modulo threshold: all requirements met except PhishThresholdLevel >= 2
        $isCompliantModuloThreshold = $meetsMinSubset -and $hasUserImpers -and $hasDomainImpers -and
                                      $mbxActionOk -and $authFailOk -and $userActionOk -and $domActionOk -and
                                      (-not $hasSelfRelease)

        # Full compliance: adds threshold requirement
        $isFullyCompliant = $isCompliantModuloThreshold -and $policy.PhishThresholdLevel -ge 2

        # Per-row verdict
        $rowStatus = if ($policy.IsBuiltInProtection -eq $true) {
            # Built-in protection has Microsoft-managed fixed settings
            if ($meetsMinSubset) { 'Pass' } else { 'Investigate' }
        }
        elseif ($policy.IsDefault -eq $true) {
            # Default policy: minimum subset + self-release + threshold check
            if ($hasSelfRelease -or -not $meetsMinSubset) { 'Fail' }
            elseif ($policy.PhishThresholdLevel -eq 1) { 'Investigate' }
            else { 'Pass' }
        }
        else {
            # Custom policy: full compliance required
            if (-not $spoofOk -or -not $dmarcOk -or $hasSelfRelease -or
                ($policy.EnableTargetedUserProtection -eq $true -and $userCount -eq 0)) {
                'Fail'
            }
            elseif ($isFullyCompliant) {
                'Pass'
            }
            elseif ($isCompliantModuloThreshold -and $policy.PhishThresholdLevel -eq 1) {
                'Investigate'
            }
            else {
                'Fail'
            }
        }

        # Display-only computed fields
        $userImpersonDisplay = if ($policy.IsBuiltInProtection -or $policy.IsDefault) {
            '—'
        }
        elseif ($hasUserImpers) {
            "✅ ($userCount)"
        }
        else {
            "❌ ($userCount)"
        }

        $domImpersonDisplay = if ($policy.IsBuiltInProtection -or $policy.IsDefault) {
            '—'
        }
        elseif ($hasDomainImpers) {
            if ($hasOrgDomains) { '✅ (org)' } else { "✅ ($domainCount)" }
        }
        else {
            '❌'
        }

        $allAdminOnly  = $qtags.Count -gt 0 -and ($qtags | Where-Object { $_ -ne 'AdminOnlyAccessPolicy' }).Count -eq 0
        $qTagDisplay   = if ($hasSelfRelease) { '❌ Self-release' }
                         elseif ($allAdminOnly) { '✅ Admin-only' }
                         elseif ($qtags.Count -eq 0) { '—' }
                         else { '⚠️ Custom' }

        [PSCustomObject]@{
            Identity                    = $policy.Identity
            PolicyType                  = if ($policy.IsBuiltInProtection -eq $true) { 'Built-in' }
                                          elseif ($policy.IsDefault -eq $true) { 'Default' }
                                          else { 'Custom' }
            SpoofIntel                  = if ($spoofOk) { '✅' } else { '❌' }
            DMARC                       = if ($dmarcOk) { '✅' } else { '❌' }
            MailboxIntel                = if ($mbxIntelOk) { '✅' } else { '❌' }
            UserImpersonation           = $userImpersonDisplay
            DomainImpersonation         = $domImpersonDisplay
            PhishThreshold              = $policy.PhishThresholdLevel
            QuarantineTags              = $qTagDisplay
            AppliedViaRule              = $appliedRule
            RowStatus                   = $rowStatus
            IsDefault                   = $policy.IsDefault -eq $true
            IsBuiltIn                   = $policy.IsBuiltInProtection -eq $true
            IsFullyCompliant            = $isFullyCompliant
            IsCompliantModuloThreshold  = $isCompliantModuloThreshold
            HasImpersonation            = $hasUserImpers -or $hasDomainImpers
        }
    }
    $policyResults = @($policyResults)

    # Applicable policies (non-built-in; default + custom with enabled rules)
    $applicablePolicies      = @($policyResults | Where-Object { -not $_.IsBuiltIn -and ($_.IsDefault -or $_.AppliedViaRule -ne '') })
    $defaultResult           = $policyResults | Where-Object { $_.IsDefault }
    $policiesWithEnabledRule = @($policyResults | Where-Object { -not $_.IsDefault -and -not $_.IsBuiltIn -and $_.AppliedViaRule -ne '' })

    $anyFullyCompliant              = ($applicablePolicies | Where-Object { $_.IsFullyCompliant }).Count -gt 0
    $anyCompliantModuloThreshold    = ($applicablePolicies | Where-Object { $_.IsCompliantModuloThreshold }).Count -gt 0
    $anyApplicableInvestigate       = ($applicablePolicies | Where-Object { $_.RowStatus -eq 'Investigate' }).Count -gt 0

    $passed       = $false
    $customStatus = $null

    if ($orphanedRules.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ An enabled anti-phishing rule references a policy that does not exist. Manual review is required to confirm the customer's intent.`n`n%TestResult%"
    }
    elseif ($defaultResult -and $defaultResult.RowStatus -eq 'Fail') {
        $testResultMarkdown = "❌ The default anti-phishing policy disables a critical control (spoof intelligence, DMARC honoring, or mailbox intelligence) or allows recipient self-release from quarantine.`n`n%TestResult%"
    }
    elseif (-not $anyCompliantModuloThreshold) {
        $allImpersonEmpty = ($applicablePolicies | Where-Object { $_.HasImpersonation }).Count -eq 0
        if ($allImpersonEmpty) {
            $testResultMarkdown = "❌ Impersonation protection lists are empty across all anti-phishing policies. No targeted user or domain impersonation protection is configured.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ One or more anti-phishing policies disable a key control (spoof intelligence, DMARC, mailbox intelligence, or impersonation protection), have empty impersonation lists, or apply non-quarantine actions to phishing.`n`n%TestResult%"
        }
    }
    elseif (($policiesWithEnabledRule | Where-Object { $_.RowStatus -eq 'Fail' }).Count -gt 0) {
        $testResultMarkdown = "❌ One or more anti-phishing policies referenced by enabled rules disable a key control or apply non-quarantine actions to phishing.`n`n%TestResult%"
    }
    elseif (-not $anyFullyCompliant -or $anyApplicableInvestigate) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ One or more anti-phishing policies have `PhishThresholdLevel` set to 1 (Standard, the lowest setting); manual review is required to confirm the customer's intent.`n`n%TestResult%"
    }
    else {
        $passed             = $true
        $testResultMarkdown = "✅ Anti-phishing policies are configured with spoof intelligence, DMARC honoring, mailbox intelligence, and impersonation protection for users and domains; high-confidence phishing is quarantined to admin-only release.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalLink = 'https://security.microsoft.com/antiphishing'
    $maxDisplay = 10
    $totalCount = $policyResults.Count

    $statusOrder   = @{ Fail = 0; Investigate = 1; Pass = 2 }
    $sortedResults = @($policyResults | Sort-Object { $statusOrder[$_.RowStatus] }, PolicyType, Identity)
    $displayRows   = $sortedResults | Select-Object -First $maxDisplay
    $isTruncated   = $totalCount -gt $maxDisplay

    $tableRows = ''
    foreach ($row in $displayRows) {
        $identityMd = Get-SafeMarkdown -Text $row.Identity
        $ruleMd     = if ($row.AppliedViaRule) { Get-SafeMarkdown -Text $row.AppliedViaRule } else { '—' }
        $statusMd   = switch ($row.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $identityMd | $($row.PolicyType) | $($row.SpoofIntel) | $($row.DMARC) | $($row.MailboxIntel) | $($row.UserImpersonation) | $($row.DomainImpersonation) | $($row.PhishThreshold) | $($row.QuarantineTags) | $ruleMd | $statusMd |`n"
    }

    if ($isTruncated) {
        $tableRows += "| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |`n"
    }

    $preTableLines = ''
    if ($isTruncated) {
        $preTableLines = "Showing $maxDisplay of $totalCount policies. [View all in Microsoft 365 Defender]($portalLink)`n`n"
    }

    $formatTemplate = @'


### [Microsoft 365 Defender > Policies & rules > Anti-phishing]({0})

{1}| Policy | Type | Spoof intel | DMARC | Mailbox intel | User impersonation | Domain impersonation | Phish threshold | Quarantine tags | Applied via rule | Status |
| :----- | :--- | :---------: | :---: | :-----------: | :----------------- | :------------------- | --------------: | :-------------- | :--------------- | :----- |
{2}
'@

    $mdInfo             = $formatTemplate -f $portalLink, $preTableLines, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41033'
        Title  = 'Anti-phishing policies in Microsoft Defender for Office 365 are configured with impersonation and spoof protection'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
