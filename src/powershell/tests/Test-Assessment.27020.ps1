<#
.SYNOPSIS
    Validates that CAPTCHA challenge is enabled in Azure Front Door WAF.

.DESCRIPTION
    This test evaluates Azure Front Door WAF policies to ensure at least one custom rule
    with CAPTCHA challenge action is configured and enabled. CAPTCHA challenge provides
    interactive human verification against sophisticated automated bots at the global edge.

.NOTES
    Test ID: 27020
    Category: Azure Network Security
    Required APIs: Azure Resource Graph (microsoft.network/frontdoorwebapplicationfirewallpolicies)
#>

function Test-Assessment-27020 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure WAF'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27020,
        Title = 'CAPTCHA challenge is enabled in Azure Front Door WAF',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating Azure Front Door WAF CAPTCHA challenge configuration'

    # Check Azure connection
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Check supported environment (Global cloud only)
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
    CaptchaExpirationInMins = toint(properties.policySettings.captchaExpirationInMinutes),
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

    if ($policies.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door WAF policies attached to Azure Front Door found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Azure Front Door WAF policies attached to Azure Front Door found.'
        return
    }

    # Fail if any policy is disabled, not in Prevention mode, or has no enabled CAPTCHA custom rule
    $failingPolicies = $policies | Where-Object {
        $_.EnabledState -ne 'Enabled' -or
        $_.WafMode -ne 'Prevention' -or
        @($_.CustomRules | Where-Object { $_.action -eq 'Captcha' -and $_.enabledState -eq 'Enabled' }).Count -eq 0
    }

    $passed = $failingPolicies.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Azure Front Door WAF policies attached to Azure Front Door are enabled in Prevention mode and have at least one CAPTCHA challenge rule configured and enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure Front Door WAF policies attached to Azure Front Door are disabled, not running in Prevention mode, or do not have any CAPTCHA challenge rules configured and enabled, leaving applications without interactive human verification against sophisticated automated bots at the global edge.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalWafBrowseLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FfrontdoorWebApplicationFirewallPolicies'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'
    $portalSubscriptionBaseLink = 'https://portal.azure.com/#resource/subscriptions'

    $mdInfo = "`n## [Azure Front Door WAF policies]($portalWafBrowseLink)`n`n"

    $tableRows = ''
    $formatTemplate = @'
| Policy name | Subscription name | Enabled state | WAF mode | CAPTCHA challenge rules count | Rule state | CAPTCHA expiration (mins) | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

    foreach ($policy in ($policies | Sort-Object SubscriptionName, PolicyName)) {
        $policyLink = "[$(Get-SafeMarkdown $policy.PolicyName)]($portalResourceBaseLink$($policy.PolicyId))"
        $subscriptionLink = "[$(Get-SafeMarkdown $policy.SubscriptionName)]($portalSubscriptionBaseLink/$($policy.SubscriptionId)/overview)"

        $allCaptchaRules = @($policy.CustomRules | Where-Object { $_.action -eq 'Captcha' })
        $enabledCaptchaRules = @($allCaptchaRules | Where-Object { $_.enabledState -eq 'Enabled' })

        $captchaRuleCountDisplay = if ($enabledCaptchaRules.Count -gt 0) {
            "✅ $($enabledCaptchaRules.Count)"
        }
        elseif ($allCaptchaRules.Count -gt 0) {
            "⚠️ $($allCaptchaRules.Count) (disabled)"
        }
        else {
            '❌ 0'
        }
        $ruleStateDisplay = if ($allCaptchaRules.Count -eq 0) {
            'N/A'
        }
        elseif ($enabledCaptchaRules.Count -ge 1) {
            '✅ Enabled'
        }
        else {
            '❌ Disabled'
        }

        $captchaExpiration = if ($policy.CaptchaExpirationInMins) { $policy.CaptchaExpirationInMins } else { 'N/A' }
        $enabledStateDisplay = if ($policy.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $wafModeDisplay = if ($policy.WafMode -eq 'Prevention') { '✅ Prevention' } else { '❌ Detection' }
        $statusText = if ($policy.EnabledState -eq 'Enabled' -and $policy.WafMode -eq 'Prevention' -and $enabledCaptchaRules.Count -ge 1) { '✅ Pass' } else { '❌ Fail' }

        $tableRows += "| $policyLink | $subscriptionLink | $enabledStateDisplay | $wafModeDisplay | $captchaRuleCountDisplay | $ruleStateDisplay | $captchaExpiration | $statusText |`n"
    }

    $mdInfo += $formatTemplate -f $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '27020'
        Title  = 'CAPTCHA challenge is enabled in Azure Front Door WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
