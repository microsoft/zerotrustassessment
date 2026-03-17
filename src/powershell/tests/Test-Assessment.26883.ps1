<#
.SYNOPSIS
    Validates that the Default rule set is assigned in Azure Front Door WAF.

.DESCRIPTION
    This test evaluates Azure Front Door WAF policies attached to Azure Front Door
    to ensure they have a Microsoft_DefaultRuleSet enabled for comprehensive web
    application protection against OWASP Top 10 vulnerabilities.

.NOTES
    Test ID: 26883
    Category: Azure Network Security
    Pillar: Network
    Required API: Azure Resource Graph - FrontDoorWebApplicationFirewallPolicies
#>

function Test-Assessment-26883 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure WAF'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 26883,
        Title = 'Default rule set is assigned in Azure Front Door WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Evaluating Azure Front Door WAF default ruleset configuration'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Query Front Door WAF policies attached to Front Door (Classic or Standard/Premium)
    # - frontendEndpointLinks: Classic Front Door attachments
    # - securityPolicyLinks: Standard/Premium Front Door attachments
    # ManagedRuleSets are evaluated in PowerShell to keep the compliance logic readable.
    $argQuery = @"
resources
| where type =~ 'microsoft.network/frontdoorwebapplicationfirewallpolicies'
| where array_length(properties.frontendEndpointLinks) > 0 or array_length(properties.securityPolicyLinks) > 0
| extend EnabledState = tostring(properties.policySettings.enabledState)
| extend WafMode = tostring(properties.policySettings.mode)
| extend SkuName = tostring(sku.name)
| extend ManagedRuleSets = properties.managedRules.managedRuleSets
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionId, SubscriptionName = name
) on subscriptionId
| project PolicyName=name, PolicyId=id, subscriptionId, SubscriptionName, SkuName, EnabledState, WafMode, ManagedRuleSets
"@

    $rawPolicies = @()
    try {
        $rawPolicies = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($rawPolicies.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    # Skip test if no policies found
    if ($rawPolicies.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door WAF policies attached to Azure Front Door found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Azure Front Door WAF policies attached to Azure Front Door found across subscriptions.'
        return
    }

    $policies = foreach ($policy in $rawPolicies) {
        $defaultRuleset = @($policy.ManagedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_DefaultRuleSet' } | Select-Object -First 1)
        $hasDefaultRuleset = $defaultRuleset.Count -gt 0
        $defaultRulesetVersion = if ($hasDefaultRuleset) { $defaultRuleset[0].ruleSetVersion } else { $null }

        $allRulesDisabled = $false
        $needsInvestigation = $false

        if ($hasDefaultRuleset) {
            $allGroupsExplicitlyDisabled = $true
            $ruleGroupOverrides = @($defaultRuleset[0].ruleGroupOverrides)

            if ($ruleGroupOverrides.Count -eq 0) {
                $allGroupsExplicitlyDisabled = $false
            }
            else {
                foreach ($override in $ruleGroupOverrides) {
                    $overrideRules = @($override.rules | Where-Object { $null -ne $_ })
                    if ($overrideRules.Count -gt 0) {
                        $hasEnabledRuleOverride = @($overrideRules | Where-Object { $_.enabledState -eq 'Enabled' }).Count -gt 0
                        if ($hasEnabledRuleOverride) {
                            $allGroupsExplicitlyDisabled = $false
                            break
                        }
                    }
                }
            }

            $allRulesDisabled = $allGroupsExplicitlyDisabled
            $needsInvestigation = $allGroupsExplicitlyDisabled
        }

        $isEnabled = $policy.EnabledState -eq 'Enabled'
        $isPreventionMode = $policy.WafMode -eq 'Prevention'
        $isCompliant = $isEnabled -and $isPreventionMode -and $hasDefaultRuleset -and (-not $allRulesDisabled)
        $status = if ($needsInvestigation) { '⚠️ Investigate' } elseif ($isCompliant) { '✅ Pass' } else { '❌ Fail' }

        [PSCustomObject]@{
            PolicyName             = $policy.PolicyName
            PolicyId               = $policy.PolicyId
            SubscriptionId         = $policy.subscriptionId
            SubscriptionName       = $policy.SubscriptionName
            SkuName                = $policy.SkuName
            EnabledState           = $policy.EnabledState
            WafMode                = $policy.WafMode
            HasDefaultRuleset      = $hasDefaultRuleset
            DefaultRulesetVersion  = $defaultRulesetVersion
            AllRulesDisabled       = $allRulesDisabled
            NeedsInvestigation     = $needsInvestigation
            IsEnabled              = $isEnabled
            IsPreventionMode       = $isPreventionMode
            IsCompliant            = $isCompliant
            EnabledStateDisplay    = if ($isEnabled) { '✅ Enabled' } else { '❌ Disabled' }
            WafModeDisplay         = if ($isPreventionMode) { '✅ Prevention' } else { "❌ $($policy.WafMode)" }
            DefaultRulesetType     = if ($hasDefaultRuleset) { 'Microsoft_DefaultRuleSet' } else { 'None' }
            DefaultRulesetDisplay  = if ($hasDefaultRuleset -and $defaultRulesetVersion) { $defaultRulesetVersion } else { 'N/A' }
            StatusDisplay          = $status
        }
    }

    $passedItems = @($policies | Where-Object { $_.IsCompliant })
    $failedItems = @($policies | Where-Object { -not $_.IsCompliant })
    $investigateItems = @($policies | Where-Object { $_.NeedsInvestigation })

    if ($failedItems.Count -eq 0) {
        $passed = $true
        $testResultMarkdown = "✅ All Azure Front Door WAF policies attached to Azure Front Door are enabled, running in Prevention mode, and have the Default Ruleset (Microsoft_DefaultRuleSet) with at least one rule enabled.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ One or more Azure Front Door WAF policies attached to Azure Front Door are disabled, running in Detection mode, do not have a default managed ruleset configured, or have all Default Ruleset rules disabled, leaving applications vulnerable to common web exploits and OWASP Top 10 attacks.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Table title
    $reportTitle = 'Azure Front Door WAF Policies'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FfrontdoorWebApplicationFirewallPolicies'

    # Prepare table rows
    $tableRows = ''
    foreach ($item in $policies | Sort-Object SubscriptionName, PolicyName) {
        $policyLink = "https://portal.azure.com/#resource$($item.PolicyId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $policyMd = "[$(Get-SafeMarkdown $item.PolicyName)]($policyLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"

        $tableRows += "| $policyMd | $subMd | Yes | $($item.EnabledStateDisplay) | $($item.WafModeDisplay) | $($item.DefaultRulesetType) | $($item.DefaultRulesetDisplay) | $($item.StatusDisplay) |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Policy name | Subscription name | Attached to AFD | Enabled state | WAF mode | Default ruleset type | Ruleset version | Status |
| :---------- | :---------------- | :-------------: | :-----------: | :------: | :------------------- | :-------------- | :----: |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    # Summary
    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total Azure Front Door WAF policies evaluated: $($policies.Count)`n"
    $mdInfo += "- Policies passing all criteria: $($passedItems.Count)`n"
    $mdInfo += "- Policies failing one or more criteria: $($failedItems.Count)`n"
    if ($investigateItems.Count -gt 0) {
        $mdInfo += "- Policies requiring investigation (overrides with disabled rules, unable to confirm all rules are off): $($investigateItems.Count)`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '26883'
        Title  = 'Default rule set is assigned in Azure Front Door WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($investigateItems.Count -gt 0) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
