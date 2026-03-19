<#
.SYNOPSIS
    Validates that Bot Manager ruleset is enabled in Application Gateway WAF policies.

.DESCRIPTION
    This test checks if all Azure Application Gateway WAF policies attached to Application Gateways
    have the Microsoft Bot Manager ruleset configured in their managed rules and have at least one
    rule enabled. Uses Azure Resource Graph to query policies and checks both the presence of the
    Microsoft_BotManagerRuleSet and that not all rules within it are explicitly disabled via
    ruleGroupOverrides. Unattached policies are excluded from evaluation.

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

    # Query all Application Gateway WAF policies using Azure Resource Graph.
    # All policies are returned; unattached ones are flagged via AttachedGatewayCount for exclusion in reporting.
    $argQuery = @"
resources
| where type =~ 'microsoft.network/applicationgatewaywebapplicationfirewallpolicies'
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
    ManagedRuleSets = properties.managedRules.managedRuleSets,
    AttachedGatewayCount = coalesce(array_length(properties.applicationGateways), 0)
"@

    $allPolicies = @()
    try {
        $allPolicies = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($allPolicies.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Helper Functions
    # Determine if Bot Manager ruleset is present and has at least one enabled rule.
    # If ruleGroupOverrides is absent or empty, all rules are enabled by default.
    # If ruleGroupOverrides is present, at least one rule group must NOT have state=Disabled.
    function Test-BotManagerEnabled {
        param($ManagedRuleSets)

        if (-not $ManagedRuleSets) { return $false }

        $botRuleSet = $ManagedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_BotManagerRuleSet' } | Select-Object -First 1
        if (-not $botRuleSet) { return $false }

        $overrides = @($botRuleSet.ruleGroupOverrides)
        if ($overrides.Count -eq 0) {
            # No overrides means all rules are enabled by default
            return $true
        }

        # Fail only if all rule groups are explicitly disabled
        $allDisabled = ($overrides | Where-Object { $_.state -ne 'Disabled' }).Count -eq 0
        return -not $allDisabled
    }
    #endregion Helper Functions

    #region Assessment Logic
    $passed = $false

    if ($allPolicies.Count -eq 0) {
        Write-PSFMessage 'No Application Gateway WAF policies found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Application Gateway WAF policies found.'
        return
    }

    $attachedPolicies = @($allPolicies | Where-Object { $_.AttachedGatewayCount -ge 1 })

    if ($attachedPolicies.Count -eq 0) {
        Write-PSFMessage 'No Application Gateway WAF policies found attached to Application Gateways.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Application Gateway WAF policies found attached to Application Gateways.'
        return
    }

    $failingPolicies = $attachedPolicies | Where-Object {
        $_.EnabledState -ne 'Enabled' -or
        $_.Mode -ne 'Prevention' -or
        -not (Test-BotManagerEnabled -ManagedRuleSets $_.ManagedRuleSets)
    }

    $passed = $failingPolicies.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Application Gateway WAF policies attached to Application Gateways are enabled, running in Prevention mode, and have the Bot Manager ruleset (Microsoft_BotManagerRuleSet) with at least one rule enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Application Gateway WAF policies attached to Application Gateways are disabled, running in Detection mode, do not have the Bot Manager ruleset configured, or have all Bot Manager rules disabled, leaving applications vulnerable to automated attacks and malicious bots.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''
    $reportTitle = 'Application Gateway WAF policies'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FapplicationGatewayWebApplicationFirewallPolicies'

    $tableRows = ''
    foreach ($policy in $allPolicies | Sort-Object SubscriptionName, PolicyName) {
        $policyLink = "https://portal.azure.com/#resource$($policy.PolicyId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($policy.SubscriptionId)"
        $policyMd = "[$(Get-SafeMarkdown $policy.PolicyName)]($policyLink)"
        $subMd = "[$(Get-SafeMarkdown $policy.SubscriptionName)]($subLink)"

        $isAttached = $policy.AttachedGatewayCount -ge 1
        $attachedDisplay = if ($isAttached) { '✅ Yes' } else { '❌ No' }
        $enabledStateDisplay = if ($policy.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $modeDisplay = if ($policy.Mode -eq 'Prevention') { '✅ Prevention' } else { '❌ Detection' }

        $botRuleSet = $null
        if ($policy.ManagedRuleSets) {
            $botRuleSet = $policy.ManagedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_BotManagerRuleSet' } | Select-Object -First 1
        }
        $botManagerEnabled = Test-BotManagerEnabled -ManagedRuleSets $policy.ManagedRuleSets
        $botManagerDisplay = if ($botRuleSet -and $botManagerEnabled) { '✅ Enabled' } elseif ($botRuleSet) { '❌ All Rules Disabled' } else { '❌ Not Configured' }
        $rulesetVersionDisplay = if ($botRuleSet) { $botRuleSet.ruleSetVersion } else { 'N/A' }

        if (-not $isAttached) {
            $statusDisplay = '⚪ Excluded'
        }
        elseif ($policy.EnabledState -eq 'Enabled' -and $policy.Mode -eq 'Prevention' -and $botManagerEnabled) {
            $statusDisplay = '✅ Pass'
        }
        else {
            $statusDisplay = '❌ Fail'
        }

        $tableRows += "| $policyMd | $subMd | $attachedDisplay | $enabledStateDisplay | $modeDisplay | $botManagerDisplay | $rulesetVersionDisplay | $statusDisplay |`n"
    }

    $formatTemplate = @'

## [{0}]({1})

| Policy name | Subscription name | Attached to AppGW | Policy state | WAF Mode | Bot Manager ruleset | Ruleset version | Status |
| :---------- | :---------------- | :---------------- | :----------- | :------- | :------------------ | :-------------- | :----- |
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
