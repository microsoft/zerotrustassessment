<#
.SYNOPSIS
    Validates that Bot Manager ruleset is enabled in Application Gateway WAF policies.

.DESCRIPTION
    This test checks if all Azure Application Gateway WAF policies attached to Application Gateways
    have the Microsoft Bot Manager ruleset configured in their managed rules. Bot protection
    identifies and categorizes automated traffic based on behavioral patterns, signatures, and IP
    reputation to defend against credential stuffing, content scraping, inventory hoarding, and
    denial of service attacks.

.NOTES
    Test ID: 26882
    Category: Azure Network Security
    Required API: Azure Resource Graph - ApplicationGatewayWebApplicationFirewallPolicies
#>

function Test-Assessment-26882 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure WAF'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 26882,
        Title = 'Bot protection ruleset is enabled and assigned in Application Gateway WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Application Gateway WAF bot protection configuration'

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
    #endregion Data Collection


    #region Assessment Logic
    $passed = $false

    # Skip test if no policies found
    if ($policies.Count -eq 0) {
        Write-PSFMessage 'No Application Gateway WAF policies found attached to Application Gateways.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Application Gateway WAF policies found attached to Application Gateways.'
        return
    }

    # Fail if any attached policy is not enabled, not in Prevention mode, or missing the Microsoft_BotManagerRuleSet
    $failingPolicies = $policies | Where-Object {
        $_.EnabledState -ne 'Enabled' -or
        $_.Mode -ne 'Prevention' -or
        ($_.ManagedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_BotManagerRuleSet' }).Count -eq 0
    }

    $passed = $failingPolicies.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Application Gateway WAF policies attached to Application Gateways are enabled, running in Prevention mode, and have the Bot Manager ruleset (Microsoft_BotManagerRuleSet) assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Application Gateway WAF policies attached to Application Gateways are disabled, running in Detection mode, or do not have the Bot Manager ruleset configured, leaving applications vulnerable to automated attacks and malicious bots.`n`n%TestResult%"
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

        $botRuleSet = $policy.ManagedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_BotManagerRuleSet' }
        $rulesetVersionDisplay = if ($botRuleSet) { $botRuleSet.ruleSetVersion } else { 'N/A' }

        $statusDisplay = if ($policy.EnabledState -eq 'Enabled' -and $policy.Mode -eq 'Prevention' -and ($policy.ManagedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_BotManagerRuleSet' }).Count -gt 0) { '✅' } else { '❌' }

        $tableRows += "| $policyMd | $subMd | $enabledStateDisplay | $modeDisplay | $rulesetVersionDisplay | $statusDisplay |`n"
    }

    $formatTemplate = @'

## [{0}]({1})

| Policy name | Subscription name | Policy state | WAF mode | Bot Manager ruleset version | Status |
| :---------- | :---------------- | :----------- | :------- | :-------------------------- | :----- |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '26882'
        Title  = 'Bot protection ruleset is enabled and assigned in Application Gateway WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
