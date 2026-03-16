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
    # NOTE: Complex regex patterns in ARG extract() fail through REST API due to escaping issues.
    # We retrieve the managedRuleSets as an array and process in PowerShell instead.
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

    # Process each policy to extract default ruleset information
    $policies = @()
    foreach ($policy in $rawPolicies) {
        # Find the Microsoft_DefaultRuleSet in managedRuleSets
        $hasDefaultRuleset = $false
        $defaultRulesetVersion = $null
        $allRulesDisabled = $false
        $needsInvestigation = $false

        if ($policy.ManagedRuleSets) {
            foreach ($ruleset in $policy.ManagedRuleSets) {
                if ($ruleset.ruleSetType -eq 'Microsoft_DefaultRuleSet') {
                    $hasDefaultRuleset = $true
                    $defaultRulesetVersion = $ruleset.ruleSetVersion

                    # Check if all rules are disabled via ruleGroupOverrides
                    # A ruleGroupOverride with no rules means the entire group is disabled
                    $allGroupsExplicitlyDisabled = $true
                    if ($null -eq $ruleset.ruleGroupOverrides -or $ruleset.ruleGroupOverrides.Count -eq 0) {
                        $allGroupsExplicitlyDisabled = $false  # No overrides = all defaults = enabled
                    } else {
                        foreach ($override in $ruleset.ruleGroupOverrides) {
                            if ($override.rules -and $override.rules.Count -gt 0) {
                                foreach ($rule in $override.rules) {
                                    if ($rule.enabledState -eq 'Enabled') {
                                        $allGroupsExplicitlyDisabled = $false
                                        break
                                    }
                                }
                            }
                            # else: no rules in override = entire group disabled, continue checking
                            if (-not $allGroupsExplicitlyDisabled) { break }
                        }
                    }
                    # Only flag if overrides exist AND every override disables its content
                    $allRulesDisabled = $allGroupsExplicitlyDisabled
                    # Flag for investigation when we have overrides with only disabled rules
                    # but can't confirm ALL rule groups are covered by overrides
                    $needsInvestigation = $allGroupsExplicitlyDisabled
                    break
                }
            }
        }

        $policies += [PSCustomObject]@{
            PolicyName            = $policy.PolicyName
            PolicyId              = $policy.PolicyId
            subscriptionId        = $policy.subscriptionId
            SubscriptionName      = $policy.SubscriptionName
            SkuName               = $policy.SkuName
            EnabledState          = $policy.EnabledState
            WafMode               = $policy.WafMode
            HasDefaultRuleset     = $hasDefaultRuleset
            DefaultRulesetVersion = $defaultRulesetVersion
            AllRulesDisabled      = $allRulesDisabled
            NeedsInvestigation    = $needsInvestigation
        }
    }

    # Evaluate each policy against all four pass criteria per spec:
    # 1. EnabledState is 'Enabled'
    # 2. WafMode is 'Prevention'
    # 3. HasDefaultRuleset is true
    # 4. At least one rule in DefaultRuleSet is enabled (AllRulesDisabled is false)
    $passedItems = @($policies | Where-Object {
        $_.EnabledState -eq 'Enabled' -and
        $_.WafMode -eq 'Prevention' -and
        $_.HasDefaultRuleset -eq $true -and
        $_.AllRulesDisabled -ne $true
    })
    $failedItems = @($policies | Where-Object {
        $_.EnabledState -ne 'Enabled' -or
        $_.WafMode -ne 'Prevention' -or
        $_.HasDefaultRuleset -ne $true -or
        $_.AllRulesDisabled -eq $true
    })

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
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.subscriptionId)"
        $policyMd = "[$(Get-SafeMarkdown $item.PolicyName)]($policyLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"

        # Calculate status indicators
        $enabledStateDisplay = if ($item.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $modeDisplay = if ($item.WafMode -eq 'Prevention') { '✅ Prevention' } else { "❌ $($item.WafMode)" }
        $rulesetType = if ($item.HasDefaultRuleset -eq $true) { 'Microsoft_DefaultRuleSet' } else { 'None' }
        $rulesetVersion = if ($item.HasDefaultRuleset -eq $true -and $item.DefaultRulesetVersion) { $item.DefaultRulesetVersion } else { 'N/A' }

        # Determine pass/fail/investigate status based on all four criteria
        $isPassed = $item.EnabledState -eq 'Enabled' -and
                    $item.WafMode -eq 'Prevention' -and
                    $item.HasDefaultRuleset -eq $true -and
                    $item.AllRulesDisabled -ne $true
        $isInvestigate = $item.NeedsInvestigation -eq $true
        $status = if ($isInvestigate) { '⚠️ Investigate' } elseif ($isPassed) { '✅ Pass' } else { '❌ Fail' }

        $tableRows += "| $policyMd | $subMd | Yes | $enabledStateDisplay | $modeDisplay | $rulesetType | $rulesetVersion | $status |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Policy name | Subscription name | Attached to AFD | Enabled state | WAF mode | Default ruleset type | Ruleset version | Status |
| :---------- | :---------------- | :-------------: | :-----------: | :------: | :------------------- | :-------------- | :----: |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    # Count items needing investigation
    $investigateItems = @($policies | Where-Object { $_.NeedsInvestigation -eq $true })

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

    # Set CustomStatus to 'Investigate' when policies have overrides with only disabled rules
    # since we can't definitively determine if ALL rules are disabled
    if ($investigateItems.Count -gt 0) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
