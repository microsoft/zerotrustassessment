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
        Service            = ('ExchangeOnline'),
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
            EnableFirstContactSafetyTips, EnableSimilarUsersSafetyTips,
            EnableSimilarDomainsSafetyTips, EnableUnusualCharactersSafetyTips,
            TargetedUserQuarantineTag, TargetedDomainQuarantineTag,
            MailboxIntelligenceQuarantineTag, SpoofQuarantineTag)
    }
    catch {
        Write-PSFMessage "Failed to retrieve anti-phishing policies: $_" -Tag Test -Level Warning
        $params = @{
            TestId       = '41033'
            Title        = 'Anti-phishing policies in Microsoft Defender for Office 365 are configured with impersonation and spoof protection'
            Status       = $false
            Result       = "⚠️ Anti-phishing policies could not be retrieved. Verify that the account has the required permissions and that the Exchange Online session is active. Error: $_"
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying anti-phishing rules'
    try {
        $rules = @(Get-AntiPhishRule -ErrorAction Stop | Select-Object `
            Name, AntiPhishPolicy, Priority, State, RecipientDomainIs, SentTo, SentToMemberOf)
    }
    catch {
        Write-PSFMessage "Failed to retrieve anti-phishing rules: $_" -Tag Test -Level Warning
        $params = @{
            TestId       = '41033'
            Title        = 'Anti-phishing policies in Microsoft Defender for Office 365 are configured with impersonation and spoof protection'
            Status       = $false
            Result       = "⚠️ Anti-phishing rules could not be retrieved. Verify that the account has the required permissions and that the Exchange Online session is active. Error: $_"
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying quarantine policies'
    # $quarantineTagMap: tag name → $true when PermissionToRelease (bit 32) is set (recipients can self-release)
    # Falls back to $null on error; assessment then uses built-in tag name list as a fallback
    $quarantineTagMap = $null
    try {
        $quarantineTagMap = @{}
        Get-QuarantinePolicy -ErrorAction Stop | ForEach-Object {
            $quarantineTagMap[$_.Name] = (([int]$_.EndUserQuarantinePermissionsValue -band 32) -ne 0)
        }
    }
    catch {
        Write-PSFMessage "Get-QuarantinePolicy failed; self-release check will fall back to built-in tag names. Error: $_" -Tag Test -Level Warning
        $quarantineTagMap = $null
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

    # Known built-in tags that grant PermissionToRelease; used as fallback when quarantine policy data is unavailable
    $builtInSelfReleaseTags = @('DefaultFullAccessPolicy', 'DefaultFullAccessWithNotificationPolicy')

    $enabledRules   = @($rules | Where-Object { $_.State -eq 'Enabled' })
    $allPolicyNames = @($policies | Select-Object -ExpandProperty Identity)
    $orphanedRules  = @($enabledRules | Where-Object { $_.AntiPhishPolicy -notin $allPolicyNames })

    # Build policy-name → enabled rule names map
    $policyRuleMap = @{}
    foreach ($rule in $enabledRules) {
        if (-not $policyRuleMap.ContainsKey($rule.AntiPhishPolicy)) {
            $policyRuleMap[$rule.AntiPhishPolicy] = [System.Collections.Generic.List[string]]::new()
        }
        [void]$policyRuleMap[$rule.AntiPhishPolicy].Add($rule.Name)
    }

    # Evaluate each policy, producing canonical reason strings per spec §"Canonical Result reason strings"
    $policyResults = foreach ($policy in $policies) {
        $isBuiltIn = $policy.IsBuiltInProtection -eq $true
        $isDefault = $policy.IsDefault -eq $true
        $reasons   = [System.Collections.Generic.List[string]]::new()

        if (-not $isBuiltIn) {
            $userCount   = if ($policy.TargetedUsersToProtect)   { @($policy.TargetedUsersToProtect).Count }   else { 0 }
            $domainCount = if ($policy.TargetedDomainsToProtect) { @($policy.TargetedDomainsToProtect).Count } else { 0 }

            # Impersonation checks — custom policies only; default policy is evaluated against the minimum subset only
            if (-not $isDefault) {
                if ($policy.EnableTargetedUserProtection -ne $true -or $userCount -eq 0) {
                    [void]$reasons.Add('Fail (targeted users empty)')
                }
                if ($policy.EnableTargetedDomainsProtection -ne $true -or $domainCount -eq 0) {
                    [void]$reasons.Add('Fail (targeted domains empty)')
                }
                if ($policy.EnableOrganizationDomainsProtection -ne $true) {
                    [void]$reasons.Add('Fail (org domains not protected)')
                }
                if ($policy.EnableTargetedUserProtection -eq $true -and $policy.EnableSimilarUsersSafetyTips -ne $true) {
                    [void]$reasons.Add('Fail (similar users safety tips off)')
                }
                if ($policy.EnableTargetedDomainsProtection -eq $true -and $policy.EnableSimilarDomainsSafetyTips -ne $true) {
                    [void]$reasons.Add('Fail (similar domains safety tips off)')
                }
                if ($policy.EnableUnusualCharactersSafetyTips -ne $true) {
                    [void]$reasons.Add('Fail (unusual characters safety tips off)')
                }
            }

            # Core checks (default and custom)
            if ($policy.EnableMailboxIntelligence -ne $true -or $policy.EnableMailboxIntelligenceProtection -ne $true) {
                [void]$reasons.Add('Fail (mailbox intelligence off)')
            }
            if ($policy.EnableSpoofIntelligence -ne $true) {
                [void]$reasons.Add('Fail (spoof off)')
            }
            if ($policy.HonorDmarcPolicy -ne $true) {
                [void]$reasons.Add('Fail (dmarc not honored)')
            }
            if (-not $isDefault -and $policy.AuthenticationFailAction -ne 'Quarantine') {
                [void]$reasons.Add('Fail (auth-fail delivered)')
            }
            if ($policy.EnableUnauthenticatedSender -ne $true) {
                [void]$reasons.Add('Fail (unauthenticated sender indicator off)')
            }
            if ($policy.EnableViaTag -ne $true) {
                [void]$reasons.Add('Fail (via tag off)')
            }
            if ($policy.EnableFirstContactSafetyTips -ne $true) {
                [void]$reasons.Add('Fail (first contact safety tips off)')
            }
            if ($policy.HonorDmarcPolicy -eq $true -and $policy.DmarcQuarantineAction -ne 'Quarantine') {
                [void]$reasons.Add('Fail (DMARC quarantine action not quarantine)')
            }
            if ($policy.HonorDmarcPolicy -eq $true -and $policy.DmarcRejectAction -ne 'Quarantine') {
                [void]$reasons.Add('Fail (DMARC reject action not quarantine)')
            }

            # Per-verdict action checks — only when the feature is enabled; name the offending property
            foreach ($check in @(
                @{ Enabled = $policy.EnableTargetedUserProtection;        Prop = 'TargetedUserProtectionAction' }
                @{ Enabled = $policy.EnableTargetedDomainsProtection;     Prop = 'TargetedDomainProtectionAction' }
                @{ Enabled = $policy.EnableMailboxIntelligenceProtection; Prop = 'MailboxIntelligenceProtectionAction' }
            )) {
                if ($check.Enabled -eq $true -and $policy.($check.Prop) -ne 'Quarantine') {
                    [void]$reasons.Add("Fail (impersonation action not enforced: $($check.Prop))")
                }
            }

            # Quarantine tag self-release — check PermissionToRelease bit (decimal 32) from collected policy data;
            # fall back to built-in tag names when Get-QuarantinePolicy data is unavailable
            foreach ($tp in @('TargetedUserQuarantineTag', 'TargetedDomainQuarantineTag', 'MailboxIntelligenceQuarantineTag', 'SpoofQuarantineTag')) {
                $val = $policy.$tp
                if (-not [string]::IsNullOrEmpty($val)) {
                    $allowsSelfRelease = if ($null -ne $quarantineTagMap -and $quarantineTagMap.ContainsKey($val)) {
                        $quarantineTagMap[$val]
                    } else {
                        $val -in $builtInSelfReleaseTags
                    }
                    if ($allowsSelfRelease) {
                        [void]$reasons.Add("Fail (self-release quarantine tag: $tp)")
                    }
                }
            }

            # Investigate: threshold below Microsoft-recommended minimum of 3, only when there are no Fail reasons
            if (($reasons | Where-Object { $_ -like 'Fail *' }).Count -eq 0 -and $policy.PhishThresholdLevel -lt 3) {
                [void]$reasons.Add("Investigate (phish threshold=$($policy.PhishThresholdLevel), below recommended minimum of 3)")
            }
        }

        # Derive row status; multiple Fail reasons merge into a single Fail (reason1; reason2) per spec
        $hasFail        = ($reasons | Where-Object { $_ -like 'Fail *' }).Count -gt 0
        $hasInvestigate = ($reasons | Where-Object { $_ -like 'Investigate *' }).Count -gt 0
        $rowStatus      = if ($hasFail) { 'Fail' } elseif ($hasInvestigate) { 'Investigate' } else { 'Pass' }
        $rowResult      = if ($hasFail) {
            "Fail ($(@($reasons | ForEach-Object { $_ -replace '^Fail \((.+)\)$', '$1' }) -join '; '))"
        } elseif ($hasInvestigate) {
            "Investigate ($(@($reasons | ForEach-Object { $_ -replace '^Investigate \((.+)\)$', '$1' }) -join '; '))"
        } else { 'Pass' }

        # Identity with [default] / [built-in] / [disabled] suffixes
        $suffixes = @()
        if ($isDefault) { $suffixes += '[default]' }
        if ($isBuiltIn) { $suffixes += '[built-in]' }
        if ($policy.Enabled -eq $false) { $suffixes += '[disabled]' }
        $identityDisplay = $policy.Identity + $(if ($suffixes) { " $($suffixes -join ' ')" } else { '' })

        # Scope column: "Applied via rule <Name>" or "Not applied"
        $scopeDisplay = if ($policyRuleMap.ContainsKey($policy.Identity)) {
            'Applied via rule ' + ($policyRuleMap[$policy.Identity] -join ', ')
        } else { 'Not applied' }

        # Impersonation column: Users: N • Domains: N • Org: Y/N • MailboxIntel: Y/N
        $uCount  = if ($policy.TargetedUsersToProtect)   { @($policy.TargetedUsersToProtect).Count }   else { 0 }
        $dCount  = if ($policy.TargetedDomainsToProtect) { @($policy.TargetedDomainsToProtect).Count } else { 0 }
        $orgY    = if ($policy.EnableOrganizationDomainsProtection -eq $true) { 'Y' } else { 'N' }
        $mbxY    = if ($policy.EnableMailboxIntelligence -eq $true -and $policy.EnableMailboxIntelligenceProtection -eq $true) { 'Y' } else { 'N' }
        $impersonDisplay = if ($isBuiltIn) { '—' } else {
            "Users: $uCount • Domains: $dCount • Org: $orgY • MailboxIntel: $mbxY"
        }

        # Authentication column: Spoof: Y/N • DMARC: Y/N • AuthFail: <action>
        $spoofY      = if ($policy.EnableSpoofIntelligence -eq $true) { 'Y' } else { 'N' }
        $dmarcY      = if ($policy.HonorDmarcPolicy -eq $true) { 'Y' } else { 'N' }
        $authDisplay = "Spoof: $spoofY • DMARC: $dmarcY • AuthFail: $($policy.AuthenticationFailAction)"

        # Phish threshold with label
        $threshDisplay = switch ([int]$policy.PhishThresholdLevel) {
            1 { '1 Standard' }
            2 { '2 Aggressive' }
            3 { '3 More aggressive' }
            4 { '4 Most aggressive' }
            default { "$($policy.PhishThresholdLevel)" }
        }

        [PSCustomObject]@{
            IdentityDisplay = $identityDisplay
            IsDefault       = $isDefault
            IsBuiltIn       = $isBuiltIn
            Scope           = $scopeDisplay
            Impersonation   = $impersonDisplay
            Authentication  = $authDisplay
            PhishThreshold  = $threshDisplay
            Result          = $rowResult
            RowStatus       = $rowStatus
        }
    }
    $policyResults = @($policyResults)

    # Identify in-scope policy groups
    $defaultResult   = $policyResults | Where-Object { $_.IsDefault } | Select-Object -First 1
    $ruleRefPolicies = @($policyResults | Where-Object { -not $_.IsBuiltIn -and -not $_.IsDefault -and $_.Scope -ne 'Not applied' })
    $allApplicable   = @($policyResults | Where-Object { -not $_.IsBuiltIn -and ($_.IsDefault -or $_.Scope -ne 'Not applied') })

    $defaultMeetsSubset  = (-not $defaultResult) -or ($defaultResult.RowStatus -ne 'Fail')
    $anyCustomPass       = ($ruleRefPolicies | Where-Object { $_.RowStatus -eq 'Pass' }).Count -gt 0
    $anyCustomFail       = ($ruleRefPolicies | Where-Object { $_.RowStatus -eq 'Fail' }).Count -gt 0
    $anyApplicableInvest = ($allApplicable | Where-Object { $_.RowStatus -eq 'Investigate' }).Count -gt 0
    $failCount           = ($allApplicable | Where-Object { $_.RowStatus -eq 'Fail' }).Count

    # Overall verdict: Fail > Investigate > Pass
    $isFail   = (-not $defaultMeetsSubset) -or $anyCustomFail
    $isInvest = -not $isFail -and (-not $anyCustomPass -or $anyApplicableInvest -or $orphanedRules.Count -gt 0)

    $passed       = $false
    $customStatus = $null
    $aggregation  = ''

    if ($isFail) {
        # Orphaned rules appended to Fail aggregation per spec
        $aggParts = @("$failCount $(if ($failCount -eq 1) {'policy'} else {'policies'}) non-compliant")
        if ($orphanedRules.Count -gt 0) {
            $aggParts += "$($orphanedRules.Count) orphaned $(if ($orphanedRules.Count -eq 1) {'rule'} else {'rules'})"
        }
        $aggregation        = $aggParts -join ', '
        $testResultMarkdown = "❌ One or more anti-phishing policies disable a key control (spoof, DMARC, mailbox intelligence, or impersonation protection), have empty impersonation lists, or apply non-quarantine actions to phishing.`n`n%TestResult%"
    }
    elseif ($isInvest) {
        $customStatus = 'Investigate'
        if ($orphanedRules.Count -gt 0) {
            $aggregation        = ($orphanedRules | ForEach-Object { "orphaned rule $($_.Name) references phantom policy" }) -join '; '
            $testResultMarkdown = "⚠️ An enabled anti-phishing rule references a policy that does not exist. Manual review is required to confirm the customer's intent.`n`n%TestResult%"
        }
        else {
            if ($anyApplicableInvest) {
                $triggerText        = if ($defaultResult -and $defaultResult.RowStatus -eq 'Investigate') {
                    'phish threshold below 3 in default policy'
                } else { 'phish threshold below 3 in one or more policies' }
                $aggregation        = $triggerText
                $testResultMarkdown = "⚠️ One or more anti-phishing policies have \`PhishThresholdLevel\` below 3 (Microsoft recommends 3 — More aggressive — for Standard, and 4 — Most aggressive — for Strict); manual review is required to confirm the customer's intent.`n`n%TestResult%"
            }
            else {
                $aggregation        = 'no custom anti-phishing policy with full impersonation controls is applied to any recipient'
                $testResultMarkdown = "⚠️ Only the default anti-phishing policy is in effect. The default policy is evaluated against the minimum spoof and DMARC subset only; it does not enforce targeted-user, domain, or org-domain impersonation protection. Configure a custom policy with impersonation controls and assign it via an enabled rule.`n`n%TestResult%"
            }
        }
    }
    else {
        $passed             = $true
        $aggregation        = 'at least one compliant policy applies, default policy meets required subset, no orphaned rules'
        $testResultMarkdown = "✅ Anti-phishing policies are configured with spoof intelligence, DMARC honoring, mailbox intelligence, and impersonation protection for users and domains; high-confidence phishing is quarantined to admin-only release.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalLink = 'https://security.microsoft.com/antiphishing'
    $maxDisplay = 10
    $totalCount = $policyResults.Count

    $overallVerdict = if ($passed) { 'Pass' } elseif ($customStatus) { 'Investigate' } else { 'Fail' }
    $overallLine    = "**Overall: $overallVerdict** — $aggregation"

    $statusOrder = @{ Fail = 0; Investigate = 1; Pass = 2 }
    $displayRows = @($policyResults | Sort-Object { $statusOrder[$_.RowStatus] }, IdentityDisplay) | Select-Object -First $maxDisplay
    $isTruncated = $totalCount -gt $maxDisplay

    $tableRows = ''
    foreach ($row in $displayRows) {
        $identityMd = Get-SafeMarkdown -Text $row.IdentityDisplay
        $scopeMd    = Get-SafeMarkdown -Text $row.Scope
        $resultMd   = Get-SafeMarkdown -Text $row.Result
        $tableRows += "| $identityMd | $scopeMd | $($row.Impersonation) | $($row.Authentication) | $($row.PhishThreshold) | $resultMd |`n"
    }

    if ($isTruncated) {
        $tableRows += "| ... | ... | ... | ... | ... | ... |`n"
    }

    $preTableLines = if ($isTruncated) {
        "Showing $maxDisplay of $totalCount policies. [View all in Microsoft 365 Defender]($portalLink)`n`n"
    } else { '' }

    $formatTemplate = @'


{0}

### [Microsoft 365 Defender > Policies & rules > Anti-phishing]({1})

{2}| Policy | Scope | Impersonation | Authentication | Phish threshold | Result |
| :----- | :---- | :------------ | :------------- | --------------: | :----- |
{3}
'@

    $mdInfo             = $formatTemplate -f $overallLine, $portalLink, $preTableLines, $tableRows
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
