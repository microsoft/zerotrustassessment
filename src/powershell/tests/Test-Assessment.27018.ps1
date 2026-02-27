<#
.SYNOPSIS
    Validates that rate limiting is enabled in Azure Front Door WAF policies.

.DESCRIPTION
    This test evaluates Azure Front Door WAF policies across all subscriptions to verify
    that at least one rate limiting custom rule (RateLimitRule) is configured and enabled.
    Only policies attached to an Azure Front Door are evaluated.

.NOTES
    Test ID: 27018
    Category: Azure Network Security
    Required APIs: Azure Management REST API (subscriptions, Front Door WAF policies)
#>

function Test-Assessment-27018 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Medium',
        MinimumLicense = 'Azure_WAF',
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27018,
        Title = 'Rate Limiting is Enabled in Azure Front Door WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Azure Front Door WAF rate limiting configuration'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Check the supported environment
    Write-ZtProgress -Activity $activity -Status 'Checking Azure environment'

    if ($azContext.Environment.Name -ne 'AzureCloud') {
        Write-PSFMessage 'This test is only applicable to the AzureCloud environment.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Query all Front Door WAF policies attached to an Azure Front Door via Azure Resource Graph
    Write-ZtProgress -Activity $activity -Status 'Querying Azure Front Door WAF policies'

    $argQuery = @"
resources
| where type =~ 'microsoft.network/frontdoorwebapplicationfirewallpolicies'
| where array_length(properties.frontendEndpointLinks) > 0 or array_length(properties.securityPolicyLinks) > 0
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionId, subscriptionName=name
) on subscriptionId
| project
    PolicyName = name,
    PolicyId = id,
    SubscriptionName = subscriptionName,
    SubscriptionId = subscriptionId,
    EnabledState = tostring(properties.policySettings.enabledState),
    WafMode = tostring(properties.policySettings.mode),
    CustomRules = properties.customRules.rules
"@

    $policies = @()
    try {
        $policies = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($policies.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Failed to query Azure Front Door WAF policies via Resource Graph: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    #endregion Data Collection

    #region Assessment Logic

    # Skip test if no policies found
    if ($policies.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door WAF policies attached to Azure Front Door found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Azure Front Door WAF policies attached to Azure Front Door found.'
        return
    }

    # Fail if any policy is disabled, not in Prevention mode, or has no enabled rate limiting custom rule
    $failingPolicies = $policies | Where-Object {
        $_.EnabledState -ne 'Enabled' -or
        $_.WafMode -ne 'Prevention' -or
        @($_.CustomRules | Where-Object { $_.ruleType -eq 'RateLimitRule' -and $_.enabledState -eq 'Enabled' }).Count -eq 0
    }

    $passed = $failingPolicies.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Azure Front Door WAF policies attached to Azure Front Door are enabled in Prevention mode and have at least one rate limiting rule configured and enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure Front Door WAF policies attached to Azure Front Door do not have any rate limiting rules configured, leaving applications vulnerable to brute force and volumetric attacks at the global edge.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalWafBrowseLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FfrontdoorWebApplicationFirewallPolicies'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'
    $portalSubscriptionBaseLink = 'https://portal.azure.com/#resource/subscriptions'

    $mdInfo = "`n## [Azure Front Door WAF policies]($portalWafBrowseLink)`n`n"

    $tableRows = ''
    $formatTemplate = @'
| Policy name | Subscription name | Rule state | Enabled state | WAF mode | Rate limit rules count | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

    foreach ($policy in ($policies | Sort-Object SubscriptionName, PolicyName)) {
        $policyLink = "[$(Get-SafeMarkdown $policy.PolicyName)]($portalResourceBaseLink$($policy.PolicyId))"
        $subscriptionLink = "[$(Get-SafeMarkdown $policy.SubscriptionName)]($portalSubscriptionBaseLink/$($policy.SubscriptionId)/overview)"

        $allRateRules = @($policy.CustomRules | Where-Object { $_.ruleType -eq 'RateLimitRule' })
        $enabledRateRules = @($allRateRules | Where-Object { $_.enabledState -eq 'Enabled' })

        $rateRuleCountDisplay = if ($allRateRules.Count -gt 0) { "✅ $($allRateRules.Count)" } else { '❌ 0' }
        $ruleStateDisplay = if ($allRateRules.Count -eq 0) {
            'N/A'
        }
        elseif ($enabledRateRules.Count -ge 1) {
            '✅ Enabled'
        }
        else {
            '❌ Disabled'
        }

        $enabledStateDisplay = if ($policy.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $wafModeDisplay = if ($policy.WafMode -eq 'Prevention') { '✅ Prevention' } else { '❌ Detection' }
        $statusText = if ($policy.EnabledState -eq 'Enabled' -and $policy.WafMode -eq 'Prevention' -and $enabledRateRules.Count -ge 1) { '✅ Pass' } else { '❌ Fail' }

        $tableRows += "| $policyLink | $subscriptionLink | $ruleStateDisplay | $enabledStateDisplay | $wafModeDisplay | $rateRuleCountDisplay | $statusText |`n"
    }

    $mdInfo += $formatTemplate -f $tableRows


    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '27018'
        Title  = 'Rate Limiting is Enabled in Azure Front Door WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
