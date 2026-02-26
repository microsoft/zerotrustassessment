<#
.SYNOPSIS
    Validates that the Default Ruleset is enabled and assigned in Azure Front Door WAF.

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
        Title = 'Default Ruleset is enabled and assigned in Azure Front Door WAF',
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
    # mv-expand flattens the managedRuleSets array to check for Microsoft_DefaultRuleSet
    # summarize collects back to one row per policy with HasDefaultRuleset flag
    $argQuery = @"
resources
| where type =~ 'microsoft.network/frontdoorwebapplicationfirewallpolicies'
| where array_length(properties.frontendEndpointLinks) > 0 or array_length(properties.securityPolicyLinks) > 0
| extend ManagedRuleSets = properties.managedRules.managedRuleSets
| extend EnabledState = tostring(properties.policySettings.enabledState)
| extend WafMode = tostring(properties.policySettings.mode)
| extend SkuName = tostring(sku.name)
| mv-expand ManagedRuleSet = ManagedRuleSets to typeof(dynamic)
| extend RuleSetType = tostring(ManagedRuleSet.ruleSetType)
| extend RuleSetVersion = tostring(ManagedRuleSet.ruleSetVersion)
| summarize
    HasDefaultRuleset = max(RuleSetType == 'Microsoft_DefaultRuleSet'),
    DefaultRulesetVersion = maxif(RuleSetVersion, RuleSetType == 'Microsoft_DefaultRuleSet'),
    EnabledState = any(EnabledState),
    WafMode = any(WafMode),
    SkuName = any(SkuName),
    PolicyId = any(id),
    PolicyName = any(name),
    subscriptionId = any(subscriptionId)
    by tolower(id)
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionId, SubscriptionName = name
) on subscriptionId
| project PolicyName, PolicyId, subscriptionId, SubscriptionName, SkuName, EnabledState, WafMode, HasDefaultRuleset, DefaultRulesetVersion
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
    # Skip test if no policies found
    if ($policies.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door WAF policies attached to Azure Front Door found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Azure Front Door WAF policies attached to Azure Front Door found across subscriptions.'
        return
    }

    # Check if all policies have default ruleset enabled
    $passedItems = @($policies | Where-Object { $_.HasDefaultRuleset -eq $true })
    $failedItems = @($policies | Where-Object { $_.HasDefaultRuleset -ne $true })

    $passed = ($failedItems.Count -eq 0) -and ($passedItems.Count -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ All Azure Front Door WAF policies attached to Azure Front Door have a default managed ruleset (Microsoft_DefaultRuleSet) enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure Front Door WAF policies attached to Azure Front Door do not have a default managed ruleset configured.`n`n%TestResult%"
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
        $modeDisplay = if ($item.WafMode -eq 'Prevention') { '✅ Prevention' } else { "⚠️ $($item.WafMode)" }
        $rulesetType = if ($item.HasDefaultRuleset -eq $true) { 'Microsoft_DefaultRuleSet' } else { 'None' }
        $rulesetVersion = if ($item.HasDefaultRuleset -eq $true -and $item.DefaultRulesetVersion) { $item.DefaultRulesetVersion } else { 'N/A' }
        $status = if ($item.HasDefaultRuleset -eq $true) { '✅ Pass' } else { '❌ Fail' }

        $tableRows += "| $policyMd | $subMd | $enabledStateDisplay | $modeDisplay | $rulesetType | $rulesetVersion | $status |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Policy name | Subscription name | Enabled state | WAF mode | Default ruleset type | Ruleset version | Status |
| :---------- | :---------------- | :-----------: | :------: | :------------------- | :-------------- | :----: |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    # Summary
    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total Azure Front Door WAF policies evaluated: $($policies.Count)`n"
    $mdInfo += "- Policies with default ruleset enabled: $($passedItems.Count)`n"
    $mdInfo += "- Policies without default ruleset: $($failedItems.Count)`n"

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '26883'
        Title  = 'Default Ruleset is enabled and assigned in Azure Front Door WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
