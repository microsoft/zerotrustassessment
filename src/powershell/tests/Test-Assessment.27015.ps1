<#
.SYNOPSIS
    Validates that HTTP DDoS Protection Ruleset is enabled in Application Gateway WAF.

.DESCRIPTION
    This test checks if all Azure Application Gateway WAF policies attached to Application Gateways
    have the Microsoft HTTP DDoS ruleset configured and WAF mode set to Prevention.
    HTTP DDoS protection helps mitigate volumetric HTTP-based attacks at the application layer.

.NOTES
    Test ID: 27015
    Category: Azure Network Security
    Required API: Azure Resource Graph - ApplicationGatewayWebApplicationFirewallPolicies
#>

function Test-Assessment-27015 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure WAF'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27015,
        Title = 'HTTP DDoS Protection Ruleset is Enabled in Application Gateway WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Application Gateway WAF HTTP DDoS protection configuration'

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
    # Enrich each policy with HTTP DDoS ruleset state
    foreach ($policy in $policies) {
        $managedRuleSets = @($policy.ManagedRuleSets)
        $httpDdosRuleSet = $managedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_HTTPDDoSRuleSet' }
        $hasHttpDdosRuleSet = $null -ne $httpDdosRuleSet

        $hasOnlyDisabledRuleOverrides = $false
        if ($hasHttpDdosRuleSet) {
            $ruleOverrides = @($httpDdosRuleSet.ruleGroupOverrides.rules | Where-Object { $null -ne $_ })
            $disabledRuleOverrides = @($ruleOverrides | Where-Object { $_.state -eq 'Disabled' })
            $hasOnlyDisabledRuleOverrides = $ruleOverrides.Count -gt 0 -and $disabledRuleOverrides.Count -eq $ruleOverrides.Count
        }

        $httpDdosState = $null
        if (-not $hasHttpDdosRuleSet) {
            $httpDdosState = 'Not Configured'
        }
        # If ruleset is present but all rules are set to Disabled
        elseif ($hasOnlyDisabledRuleOverrides) {
            $httpDdosState = 'Disabled'
        }
        # If ruleset is present and has at least one rule set to Enabled (OR) ruleset is present and has no rule overrides (which means all rules are in default state, which is Enabled)
        else {
            $httpDdosState = 'Enabled'
        }

        $policy | Add-Member -NotePropertyName HttpDdosState -NotePropertyValue $httpDdosState
        $policy | Add-Member -NotePropertyName HttpDdosRuleSetVersion -NotePropertyValue $(if ($hasHttpDdosRuleSet) { $httpDdosRuleSet.ruleSetVersion } else { $null })
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

    # Fail if any policy is disabled, not in Prevention mode, or has HTTP DDoS ruleset not enabled
    $failingPolicies = $policies | Where-Object {
        $_.EnabledState -ne 'Enabled' -or
        $_.Mode -ne 'Prevention' -or
        $_.HttpDdosState -ne 'Enabled'
    }

    $passed = $failingPolicies.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Application Gateway WAF policies attached to Application Gateways are enabled in Prevention mode and have the HTTP DDoS Protection ruleset (Microsoft_HTTPDDoSRuleSet) with at least one rule enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Application Gateway WAF policies attached to Application Gateways are disabled, running in Detection mode, do not have the HTTP DDoS Protection ruleset configured, or have all HTTP DDoS Protection rules disabled, leaving applications vulnerable to volumetric HTTP-based attacks.`n`n%TestResult%"
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

        $enabledStateDisplay = if ($policy.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $modeDisplay = if ($policy.Mode -eq 'Prevention') { '✅ Prevention' } else { '❌ Detection' }
        $httpDdosRulesetDisplay = if ($policy.HttpDdosState -eq 'Enabled') { '✅ Enabled' } elseif ($policy.HttpDdosState -eq 'Disabled') { '❌ Disabled' } else { '❌ Not Configured' }
        $versionDisplay = if ($policy.HttpDdosRuleSetVersion) { $policy.HttpDdosRuleSetVersion } else { 'N/A' }
        $statusDisplay = if ($policy.EnabledState -eq 'Enabled' -and $policy.Mode -eq 'Prevention' -and $policy.HttpDdosState -eq 'Enabled') { '✅' } else { '❌' }

        $tableRows += "| $policyMd | $subMd | $enabledStateDisplay | $modeDisplay | $httpDdosRulesetDisplay | $versionDisplay | $statusDisplay |`n"
    }

    $formatTemplate = @'

## [{0}]({1})

| Policy name | Subscription name | Policy state | Mode | HTTP DDoS ruleset | Ruleset version | Status |
| :---------- | :---------------- | :----------- | :--- | :---------------- | :-------------- | :----- |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '27015'
        Title  = 'HTTP DDoS Protection Ruleset is Enabled in Application Gateway WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
