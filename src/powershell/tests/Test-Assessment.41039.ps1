<#
.SYNOPSIS
    Zero-hour auto purge (ZAP) is enabled for malware, phishing, and spam in email
#>

function Test-Assessment-41039 {
    [ZtTest(
        Category = 'Email and collaboration security',
        CompatibleLicense = ('EXCHANGE_S_STANDARD'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('ExchangeOnline'),
        SfiPillar = 'Accelerate response and remediation',
        TenantType = ('Workforce'),
        TestId = 41039,
        Title = 'Zero-hour auto purge (ZAP) is enabled for malware, phishing, and spam in email',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking zero-hour auto purge configuration'

    $malwarePolicies = @()
    $malwareRules = @()
    $malwarePolicyQueryFailed = $false
    $malwareRuleQueryFailed = $false
    $spamPolicies = @()
    $spamRules = @()
    $spamPolicyQueryFailed = $false
    $spamRuleQueryFailed = $false

    # Q1: Read ZAP-related properties from anti-malware policies and their rules.
    Write-ZtProgress -Activity $activity -Status 'Getting anti-malware filter policies'
    try {
        $malwarePolicies = @(Get-MalwareFilterPolicy -ErrorAction Stop |
            Select-Object Identity, IsDefault, ZapEnabled)
    }
    catch {
        $malwarePolicyQueryFailed = $true
        Write-PSFMessage "Failed to retrieve anti-malware policies: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Getting anti-malware filter rules'
    try {
        $malwareRules = @(Get-MalwareFilterRule -ErrorAction Stop |
            Select-Object Name, MalwareFilterPolicy, Priority, State)
    }
    catch {
        $malwareRuleQueryFailed = $true
        Write-PSFMessage "Failed to retrieve anti-malware rules: $_" -Tag Test -Level Warning
    }

    # Q2: Read ZAP-related properties from anti-spam policies and their rules.
    Write-ZtProgress -Activity $activity -Status 'Getting hosted content filter policies'
    try {
        $spamPolicies = @(Get-HostedContentFilterPolicy -ErrorAction Stop |
            Select-Object Identity, IsDefault, SpamZapEnabled, PhishZapEnabled)
    }
    catch {
        $spamPolicyQueryFailed = $true
        Write-PSFMessage "Failed to retrieve anti-spam policies: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Getting hosted content filter rules'
    try {
        $spamRules = @(Get-HostedContentFilterRule -ErrorAction Stop |
            Select-Object Name, HostedContentFilterPolicy, Priority, State)
    }
    catch {
        $spamRuleQueryFailed = $true
        Write-PSFMessage "Failed to retrieve anti-spam rules: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $malwarePolicyRows = @()
    $spamPolicyRows = @()
    $hasFailure = $false
    $hasInvestigate = $false
    $malwarePolicyUnavailable = $malwarePolicyQueryFailed -or $malwarePolicies.Count -eq 0
    $spamPolicyUnavailable = $spamPolicyQueryFailed -or $spamPolicies.Count -eq 0

    if ($malwarePolicyUnavailable) {
        $hasInvestigate = $true
    }
    else {
        $malwarePolicyByIdentity = @{}
        foreach ($policy in $malwarePolicies) {
            $malwarePolicyByIdentity[$policy.Identity] = $policy
        }

        $defaultMalwarePolicies = @($malwarePolicies | Where-Object { $_.IsDefault -eq $true })
        if ($defaultMalwarePolicies.Count -eq 0) {
            $hasInvestigate = $true
            $malwarePolicyRows += [PSCustomObject]@{
                PolicyIdentity = '—'
                IsDefault      = $false
                RuleName       = $null
                ZapEnabled     = $null
                Result         = 'Investigate'
                StatusDetail   = 'default policy not found'
            }
        }

        foreach ($policy in $defaultMalwarePolicies) {
            $propertyKnown = $policy.ZapEnabled -is [bool]
            $propertyEnabled = $propertyKnown -and $policy.ZapEnabled
            $result = if (-not $propertyKnown) {
                $hasInvestigate = $true
                'Investigate'
            }
            elseif ($propertyEnabled) {
                'Pass'
            }
            else {
                $hasFailure = $true
                'Fail'
            }
            $malwarePolicyRows += [PSCustomObject]@{
                PolicyIdentity = $policy.Identity
                IsDefault      = $true
                RuleName       = $null
                ZapEnabled     = if ($propertyKnown) { $propertyEnabled } else { $null }
                Result         = $result
                StatusDetail   = if ($propertyKnown) { $null } else { 'ZapEnabled value is unavailable' }
            }
        }

        if ($malwareRuleQueryFailed) {
            $hasInvestigate = $true
            $malwarePolicyRows += [PSCustomObject]@{
                PolicyIdentity = '—'
                IsDefault      = $false
                RuleName       = $null
                ZapEnabled     = $null
                Result         = 'Investigate'
                StatusDetail   = 'could not retrieve anti-malware rules'
            }
        }
        else {
            foreach ($rule in ($malwareRules | Where-Object { $_.State -eq 'Enabled' })) {
                $policy = $malwarePolicyByIdentity[[string]$rule.MalwareFilterPolicy]
                if ($null -eq $policy) {
                    $hasInvestigate = $true
                    $malwarePolicyRows += [PSCustomObject]@{
                        PolicyIdentity = [string]$rule.MalwareFilterPolicy
                        IsDefault      = $false
                        RuleName       = [string]$rule.Name
                        ZapEnabled     = $null
                        Result         = 'Investigate'
                        StatusDetail   = 'referenced policy not found'
                    }
                    continue
                }

                $propertyKnown = $policy.ZapEnabled -is [bool]
                $propertyEnabled = $propertyKnown -and $policy.ZapEnabled
                $result = if (-not $propertyKnown) {
                    $hasInvestigate = $true
                    'Investigate'
                }
                elseif ($propertyEnabled) {
                    'Pass'
                }
                else {
                    $hasFailure = $true
                    'Fail'
                }
                $malwarePolicyRows += [PSCustomObject]@{
                    PolicyIdentity = $policy.Identity
                    IsDefault      = $false
                    RuleName       = [string]$rule.Name
                    ZapEnabled     = if ($propertyKnown) { $propertyEnabled } else { $null }
                    Result         = $result
                    StatusDetail   = if ($propertyKnown) { $null } else { 'ZapEnabled value is unavailable' }
                }
            }
        }
    }

    if ($spamPolicyUnavailable) {
        $hasInvestigate = $true
    }
    else {
        $spamPolicyByIdentity = @{}
        foreach ($policy in $spamPolicies) {
            $spamPolicyByIdentity[$policy.Identity] = $policy
        }

        $defaultSpamPolicies = @($spamPolicies | Where-Object { $_.IsDefault -eq $true })
        if ($defaultSpamPolicies.Count -eq 0) {
            $hasInvestigate = $true
            $spamPolicyRows += [PSCustomObject]@{
                PolicyIdentity  = '—'
                IsDefault       = $false
                RuleName        = $null
                PhishZapEnabled = $null
                SpamZapEnabled  = $null
                Result          = 'Investigate'
                StatusDetail    = 'default policy not found'
            }
        }

        foreach ($policy in $defaultSpamPolicies) {
            $phishZapKnown = $policy.PhishZapEnabled -is [bool]
            $spamZapKnown = $policy.SpamZapEnabled -is [bool]
            $phishZapEnabled = $phishZapKnown -and $policy.PhishZapEnabled
            $spamZapEnabled = $spamZapKnown -and $policy.SpamZapEnabled
            $result = if (($phishZapKnown -and -not $phishZapEnabled) -or ($spamZapKnown -and -not $spamZapEnabled)) {
                $hasFailure = $true
                'Fail'
            }
            elseif ($phishZapEnabled -and $spamZapEnabled) {
                'Pass'
            }
            else {
                $hasInvestigate = $true
                'Investigate'
            }
            $spamPolicyRows += [PSCustomObject]@{
                PolicyIdentity  = $policy.Identity
                IsDefault       = $true
                RuleName        = $null
                PhishZapEnabled = if ($phishZapKnown) { $phishZapEnabled } else { $null }
                SpamZapEnabled  = if ($spamZapKnown) { $spamZapEnabled } else { $null }
                Result          = $result
                StatusDetail    = if ($phishZapKnown -and $spamZapKnown) { $null } else { 'one or more ZAP values are unavailable' }
            }
        }

        if ($spamRuleQueryFailed) {
            $hasInvestigate = $true
            $spamPolicyRows += [PSCustomObject]@{
                PolicyIdentity  = '—'
                IsDefault       = $false
                RuleName        = $null
                PhishZapEnabled = $null
                SpamZapEnabled  = $null
                Result          = 'Investigate'
                StatusDetail    = 'could not retrieve anti-spam rules'
            }
        }
        else {
            foreach ($rule in ($spamRules | Where-Object { $_.State -eq 'Enabled' })) {
                $policy = $spamPolicyByIdentity[[string]$rule.HostedContentFilterPolicy]
                if ($null -eq $policy) {
                    $hasInvestigate = $true
                    $spamPolicyRows += [PSCustomObject]@{
                        PolicyIdentity  = [string]$rule.HostedContentFilterPolicy
                        IsDefault       = $false
                        RuleName        = [string]$rule.Name
                        PhishZapEnabled = $null
                        SpamZapEnabled  = $null
                        Result          = 'Investigate'
                        StatusDetail    = 'referenced policy not found'
                    }
                    continue
                }

                $phishZapKnown = $policy.PhishZapEnabled -is [bool]
                $spamZapKnown = $policy.SpamZapEnabled -is [bool]
                $phishZapEnabled = $phishZapKnown -and $policy.PhishZapEnabled
                $spamZapEnabled = $spamZapKnown -and $policy.SpamZapEnabled
                $result = if (($phishZapKnown -and -not $phishZapEnabled) -or ($spamZapKnown -and -not $spamZapEnabled)) {
                    $hasFailure = $true
                    'Fail'
                }
                elseif ($phishZapEnabled -and $spamZapEnabled) {
                    'Pass'
                }
                else {
                    $hasInvestigate = $true
                    'Investigate'
                }
                $spamPolicyRows += [PSCustomObject]@{
                    PolicyIdentity  = $policy.Identity
                    IsDefault       = $false
                    RuleName        = [string]$rule.Name
                    PhishZapEnabled = if ($phishZapKnown) { $phishZapEnabled } else { $null }
                    SpamZapEnabled  = if ($spamZapKnown) { $spamZapEnabled } else { $null }
                    Result          = $result
                    StatusDetail    = if ($phishZapKnown -and $spamZapKnown) { $null } else { 'one or more ZAP values are unavailable' }
                }
            }
        }
    }

    $passed = $false
    $customStatus = $null
    if ($hasFailure) {
        $testResultMarkdown = "❌ One or more in-scope policies disable ZAP for malware, spam, or phish; reclassified messages will remain in user mailboxes.`n`n%TestResult%"
    }
    elseif ($hasInvestigate) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ An email ZAP policy surface could not be evaluated completely because policy or rule data is unavailable, or an enabled rule references a policy that does not exist; manual review is required.`n`n%TestResult%"
    }
    else {
        $passed = $true
        $testResultMarkdown = "✅ Zero-hour auto purge is enabled for malware, spam, and phish across all in-scope EOP anti-malware and anti-spam policies.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $maxDisplay = 10
    $statusPriority = @{ Fail = 0; Investigate = 1; Pass = 2 }
    $sortedMalwareRows = @($malwarePolicyRows | Sort-Object { $statusPriority[$_.Result] }, PolicyIdentity)
    $displayMalwareRows = @($sortedMalwareRows | Select-Object -First $maxDisplay)
    $malwareTableRows = ''

    foreach ($row in $displayMalwareRows) {
        $defaultSuffix = if ($row.IsDefault) { ' [default]' } else { '' }
        $policyIdentity = "$(Get-SafeMarkdown -Text $row.PolicyIdentity)$defaultSuffix"
        $appliedViaRule = if ($row.IsDefault) {
            '— (catch-all)'
        }
        elseif ($row.RuleName) {
            Get-SafeMarkdown -Text $row.RuleName
        }
        else {
            '—'
        }
        $zapDisplay = if ($null -eq $row.ZapEnabled) { '⚠️ Unknown' } elseif ($row.ZapEnabled) { '✅ Yes' } else { '❌ No' }
        $resultDisplay = switch ($row.Result) {
            'Pass' { '✅ Pass' }
            'Fail' { '❌ Fail' }
            'Investigate' {
                if ($row.StatusDetail) { "⚠️ Investigate — $($row.StatusDetail)" } else { '⚠️ Investigate' }
            }
        }
        $malwareTableRows += "| $policyIdentity | $appliedViaRule | $zapDisplay | $resultDisplay |`n"
    }

    if ($sortedMalwareRows.Count -gt $maxDisplay) {
        $malwareTableRows += "| ... | ... | ... | ... |`n"
    }

    $malwarePolicyDetails = if ($malwarePolicyUnavailable) {
        'Unable to query anti-malware policies.'
    }
    elseif ($sortedMalwareRows.Count -gt 0) {
        @"
| Policy identity | Applied via Rule | ZAP for malware | Status |
| :-------------- | :--------------- | :-------------- | :----- |
$malwareTableRows
"@
    }
    else {
        @'
No in-scope anti-malware policy rows could be resolved; verify the default policy and enabled rule references.
'@
    }

    $sortedSpamRows = @($spamPolicyRows | Sort-Object { $statusPriority[$_.Result] }, PolicyIdentity)
    $displaySpamRows = @($sortedSpamRows | Select-Object -First $maxDisplay)
    $spamTableRows = ''

    foreach ($row in $displaySpamRows) {
        $defaultSuffix = if ($row.IsDefault) { ' [default]' } else { '' }
        $policyIdentity = "$(Get-SafeMarkdown -Text $row.PolicyIdentity)$defaultSuffix"
        $appliedViaRule = if ($row.IsDefault) {
            '— (catch-all)'
        }
        elseif ($row.RuleName) {
            Get-SafeMarkdown -Text $row.RuleName
        }
        else {
            '—'
        }
        $phishZapDisplay = if ($null -eq $row.PhishZapEnabled) { '⚠️ Unknown' } elseif ($row.PhishZapEnabled) { '✅ Yes' } else { '❌ No' }
        $spamZapDisplay = if ($null -eq $row.SpamZapEnabled) { '⚠️ Unknown' } elseif ($row.SpamZapEnabled) { '✅ Yes' } else { '❌ No' }
        $resultDisplay = switch ($row.Result) {
            'Pass' { '✅ Pass' }
            'Fail' { '❌ Fail' }
            'Investigate' {
                if ($row.StatusDetail) { "⚠️ Investigate — $($row.StatusDetail)" } else { '⚠️ Investigate' }
            }
        }
        $spamTableRows += "| $policyIdentity | $appliedViaRule | $phishZapDisplay | $spamZapDisplay | $resultDisplay |`n"
    }

    if ($sortedSpamRows.Count -gt $maxDisplay) {
        $spamTableRows += "| ... | ... | ... | ... | ... |`n"
    }

    $spamPolicyDetails = if ($spamPolicyUnavailable) {
        'Unable to query anti-spam policies.'
    }
    elseif ($sortedSpamRows.Count -gt 0) {
        @"
| Policy identity | Applied via Rule | ZAP for phishing | ZAP for spam | Status |
| :-------------- | :--------------- | :--------------- | :----------- | :----- |
$spamTableRows
"@
    }
    else {
        @'
No in-scope anti-spam policy rows could be resolved; verify the default policy and enabled rule references.
'@
    }

    $threatPolicyLink = ''
    if ($sortedMalwareRows.Count -gt $maxDisplay -or $sortedSpamRows.Count -gt $maxDisplay) {
        $threatPolicyLink = @'
[Microsoft 365 Defender > Policies & rules > Threat policies](https://security.microsoft.com/threatpolicy)
'@
    }

    $formatTemplate = @'
## Anti-malware policy settings

{0}

## Anti-spam policy settings

{1}

{2}
'@

    $mdInfo = if ($malwarePolicyUnavailable -and $spamPolicyUnavailable) {
        ''
    }
    else {
        $formatTemplate -f $malwarePolicyDetails, $spamPolicyDetails, $threatPolicyLink
    }
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41039'
        Title  = 'Zero-hour auto purge (ZAP) is enabled for malware, phishing, and spam in email'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
