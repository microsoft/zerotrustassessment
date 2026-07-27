<#
.SYNOPSIS
    Validates that the HTTP DDoS protection rule set is enabled in Azure Front Door WAF.
#>

function Test-Assessment-27024 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Consumption-based: Azure WAF on Azure Front Door Premium'),
        Service = ('Azure'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27024,
        Title = 'HTTP DDoS protection rule set is enabled in Azure Front Door WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Evaluating Azure Front Door WAF HTTP DDoS protection configuration'
    Write-ZtProgress -Activity $activity -Status 'Querying Azure Front Door WAF policies'

    # Q1: Query attached Premium Azure Front Door WAF policies and their managed rule sets.
    $argQuery = @"
resources
| where type =~ 'microsoft.network/frontdoorwebapplicationfirewallpolicies'
| where tostring(sku.name) =~ 'Premium_AzureFrontDoor'
| where array_length(properties.frontendEndpointLinks) > 0 or array_length(properties.securityPolicyLinks) > 0
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionId, SubscriptionName = name
) on subscriptionId
| project
    PolicyName = name,
    PolicyId = id,
    SubscriptionName,
    SubscriptionId = subscriptionId,
    SkuName = tostring(sku.name),
    EnabledState = tostring(properties.policySettings.enabledState),
    WafMode = tostring(properties.policySettings.mode),
    ManagedRuleSets = properties.managedRules.managedRuleSets
"@

    $rawPolicies = @()
    try {
        $rawPolicies = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery | Where-Object { $null -ne $_ })
        Write-PSFMessage "ARG query returned $($rawPolicies.Count) Azure Front Door Premium WAF policy(ies)." -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($rawPolicies.Count -eq 0) {
        Write-PSFMessage 'No attached Azure Front Door Premium WAF policies found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No attached Azure Front Door Premium WAF policies found.'
        return
    }

    $policies = foreach ($policy in $rawPolicies) {
        $httpDdosRuleSet = @($policy.ManagedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_HTTPDDoSRuleSet' } | Select-Object -First 1)
        $hasHttpDdosRuleSet = $httpDdosRuleSet.Count -gt 0
        $ruleOverrides = @()

        if ($hasHttpDdosRuleSet) {
            # Unlisted rules retain their default enabled state, so both documented rules must be explicitly disabled.
            foreach ($ruleGroupOverride in @($httpDdosRuleSet[0].ruleGroupOverrides)) {
                $ruleOverrides += @($ruleGroupOverride.rules | Where-Object { $null -ne $_ })
            }
        }

        $disabledRuleIds = @($ruleOverrides | Where-Object {
            $_.ruleId -in @('500100', '500110') -and $_.enabledState -eq 'Disabled'
        } | Select-Object -ExpandProperty ruleId -Unique)
        $bothHttpDdosRulesDisabled = $disabledRuleIds.Count -eq 2

        $httpDdosRulesetState = if (-not $hasHttpDdosRuleSet) {
            'Not Configured'
        }
        elseif ($bothHttpDdosRulesDisabled) {
            'Disabled'
        }
        else {
            'Enabled'
        }

        $isCompliant = $policy.EnabledState -eq 'Enabled' -and
            $policy.WafMode -eq 'Prevention' -and
            $httpDdosRulesetState -eq 'Enabled'

        [PSCustomObject]@{
            PolicyName               = $policy.PolicyName
            PolicyId                 = $policy.PolicyId
            SubscriptionName         = $policy.SubscriptionName
            SubscriptionId           = $policy.SubscriptionId
            SkuName                  = $policy.SkuName
            EnabledState             = $policy.EnabledState
            WafMode                  = $policy.WafMode
            HttpDdosRulesetState     = $httpDdosRulesetState
            HttpDdosRulesetVersion   = if ($hasHttpDdosRuleSet) { $httpDdosRuleSet[0].ruleSetVersion } else { $null }
            IsCompliant              = $isCompliant
        }
    }

    $failedItems = @($policies | Where-Object { -not $_.IsCompliant })
    $passed = $failedItems.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Azure Front Door Premium WAF policies attached to Azure Front Door are enabled, running in Prevention mode, and have the HTTP DDoS ruleset (Microsoft_HTTPDDoSRuleSet) with at least one rule enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure Front Door Premium WAF policies attached to Azure Front Door are disabled, running in Detection mode, do not have the HTTP DDoS ruleset configured, or have all HTTP DDoS ruleset rules disabled, leaving applications vulnerable to volumetric HTTP-based attacks at the edge.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalWafBrowseLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FfrontdoorWebApplicationFirewallPolicies'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'
    $portalSubscriptionBaseLink = 'https://portal.azure.com/#resource/subscriptions'
    $reportTitle = 'Azure Front Door WAF policies'

    $tableRows = ''
    foreach ($policy in ($policies | Sort-Object SubscriptionName, PolicyName)) {
        $policyLink = "[$(Get-SafeMarkdown $policy.PolicyName)]($portalResourceBaseLink$($policy.PolicyId))"
        $subscriptionLink = "[$(Get-SafeMarkdown $policy.SubscriptionName)]($portalSubscriptionBaseLink/$($policy.SubscriptionId)/overview)"
        $enabledStateDisplay = if ($policy.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $wafModeDisplay = if ($policy.WafMode -eq 'Prevention') { '✅ Prevention' } else { "❌ $($policy.WafMode)" }
        $httpDdosRulesetDisplay = if ($policy.HttpDdosRulesetState -eq 'Enabled') { '✅ Enabled' } elseif ($policy.HttpDdosRulesetState -eq 'Disabled') { '❌ Disabled' } else { '❌ Not Configured' }
        $rulesetVersionDisplay = if ($policy.HttpDdosRulesetVersion) { $policy.HttpDdosRulesetVersion } else { 'N/A' }
        $statusDisplay = if ($policy.IsCompliant) { '✅ Pass' } else { '❌ Fail' }

        $tableRows += "| $policyLink | $subscriptionLink | $enabledStateDisplay | $wafModeDisplay | $httpDdosRulesetDisplay | $rulesetVersionDisplay | $statusDisplay |`n"
    }

    $formatTemplate = @'
## [{0}]({1})

| Policy name | Subscription name | Enabled state | WAF mode | HTTP DDoS ruleset | Ruleset version | Status |
| :---------- | :---------------- | :------------ | :------- | :---------------- | :-------------- | :----- |
{2}
'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalWafBrowseLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '27024'
        Title  = 'HTTP DDoS protection rule set is enabled in Azure Front Door WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
