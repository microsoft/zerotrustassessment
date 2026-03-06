<#
.SYNOPSIS
    Validates that the default managed ruleset is enabled in Application Gateway WAF.

.DESCRIPTION
    This test checks if all Azure Application Gateway WAF policies attached to Application Gateways
    are enabled, running in Prevention mode, and have at least one rule enabled in a default managed
    ruleset (ruleSetType of Microsoft_DefaultRuleSet or OWASP). A policy fails if it is disabled,
    running in Detection mode, or has all Default Ruleset rules explicitly disabled via ruleGroupOverrides.
    Without an active default ruleset, the WAF cannot detect or block common web application attacks
    including SQL injection, cross-site scripting, and other OWASP Top 10 vulnerabilities.

.NOTES
    Test ID: 26881
    Category: Azure Network Security
    Required API: Azure Resource Graph - ApplicationGatewayWebApplicationFirewallPolicies
#>

function Test-Assessment-26881 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure WAF'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 26881,
        Title = 'Default Ruleset is enabled in Application Gateway WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Application Gateway WAF default ruleset configuration'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Query all Application Gateway WAF policies attached to Application Gateways using Azure Resource Graph
    $argQuery = @"
resources
| where type =~ 'microsoft.network/applicationgatewaywebapplicationfirewallpolicies'
| where coalesce(array_length(properties.applicationGateways), 0) >= 1
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId)
    on subscriptionId
| project
    PolicyName = name,
    PolicyId = id,
    SubscriptionName = subscriptionName,
    SubscriptionId = subscriptionId,
    EnabledState = tostring(properties.policySettings.state),
    Mode = tostring(properties.policySettings.mode),
    ManagedRuleSets = properties.managedRules.managedRuleSets
"@

    $policies = @()
    try {
        $policies = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($policies.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Enrich each policy with default ruleset state
    foreach ($policy in $policies) {
        $managedRuleSets = @($policy.ManagedRuleSets)
        $defaultRuleSet = $managedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_DefaultRuleSet' -or $_.ruleSetType -eq 'OWASP' }

        $ruleOverrides = @($defaultRuleSet.ruleGroupOverrides.rules | Where-Object { $null -ne $_ })
        $disabledRuleOverrides = @($ruleOverrides | Where-Object { $_.state -eq 'Disabled' })
        $hasOnlyDisabledRuleOverrides = $ruleOverrides.Count -gt 0 -and $disabledRuleOverrides.Count -eq $ruleOverrides.Count

        # RuleSetState is disabled if all rules are explicitly set to Disabled
        # If there are no rule overrides, or at least one rule override is not disabled, then the ruleset is considered enabled
        $defaultRuleSetState = if ($hasOnlyDisabledRuleOverrides) { 'Disabled' } else { 'Enabled' }

        $policy | Add-Member -NotePropertyName DefaultRuleSetState -NotePropertyValue $defaultRuleSetState
        $policy | Add-Member -NotePropertyName DefaultRuleSetVersion -NotePropertyValue $defaultRuleSet.ruleSetVersion
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Skip test if no policies found
    if ($policies.Count -eq 0) {
        Write-PSFMessage 'No Application Gateway WAF policies found attached to Application Gateways.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Application Gateway WAF policies found attached to Application Gateways.'
        return
    }

    # Fail if any policy is not enabled, not in Prevention mode, or has all Default Ruleset rules disabled
    # Default ruleset is always present for all Application Gateway WAF policies as it is mandatory during WAF policy creation
    $failingPolicies = $policies | Where-Object {
        $_.EnabledState -ne 'Enabled' -or
        $_.Mode -ne 'Prevention' -or
        $_.DefaultRuleSetState -ne 'Enabled'
    }

    $passed = $failingPolicies.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Application Gateway WAF policies attached to Application Gateways are enabled, running in Prevention mode, and have the Default Ruleset (Microsoft_DefaultRuleSet or OWASP) with at least one rule enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Application Gateway WAF policies attached to Application Gateways are disabled, running in Detection mode, or have all Default Ruleset rules disabled, leaving applications vulnerable to common web exploits and OWASP Top 10 attacks.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    $reportTitle = 'Application Gateway WAF policies'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FapplicationGatewayWebApplicationFirewallPolicies'

    $tableRows = ''
    foreach ($policy in $policies | Sort-Object SubscriptionName, PolicyName) {
        $policyLink = "https://portal.azure.com/#resource$($policy.PolicyId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($policy.SubscriptionId)"
        $policyMd = "[$(Get-SafeMarkdown $policy.PolicyName)]($policyLink)"
        $subMd = "[$(Get-SafeMarkdown $policy.SubscriptionName)]($subLink)"

        $defaultRuleSet = $policy.ManagedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_DefaultRuleSet' -or $_.ruleSetType -eq 'OWASP' }
        $enabledStateDisplay = if ($policy.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $modeDisplay = if ($policy.Mode -eq 'Prevention') { '✅ Prevention' } else { '❌ Detection' }
        $defaultRuleSetType = $defaultRuleSet.ruleSetType
        $defaultRuleSetStateDisplay = if ($policy.DefaultRuleSetState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }

        $versionDisplay = if ($policy.DefaultRuleSetVersion) { $policy.DefaultRuleSetVersion } else { 'N/A' }
        $statusDisplay = if ($policy.EnabledState -eq 'Enabled' -and $policy.Mode -eq 'Prevention' -and $policy.DefaultRuleSetState -eq 'Enabled') { '✅' } else { '❌' }

        $tableRows += "| $policyMd | $subMd | $enabledStateDisplay | $modeDisplay | $defaultRuleSetType | $versionDisplay | $defaultRuleSetStateDisplay | $statusDisplay |`n"
    }

    $formatTemplate = @'

## [{0}]({1})

| Policy name | Subscription name | Policy state | Mode | Default ruleset type | Ruleset version | Default ruleset state | Status |
| :---------- | :---------------- | :----------- | :--- | :------------------- | :-------------- | :-------------------- | :----- |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '26881'
        Title  = 'Default Ruleset is enabled in Application Gateway WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
