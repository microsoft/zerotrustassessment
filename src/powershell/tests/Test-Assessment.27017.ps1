<#
.SYNOPSIS
    Validates that JavaScript Challenge is enabled in Application Gateway WAF custom rules.

.DESCRIPTION
    This test checks if all Azure Application Gateway WAF policies attached to Application Gateways
    have at least one custom rule configured with the JSChallenge action and state set to Enabled.
    JavaScript challenge verifies that clients can execute JavaScript, blocking automated bots and
    headless browsers that cannot complete the challenge.

.NOTES
    Test ID: 27017
    Category: Azure Network Security
    Required API: Azure Resource Graph - ApplicationGatewayWebApplicationFirewallPolicies
#>

function Test-Assessment-27017 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure WAF'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27017,
        Title = 'JavaScript Challenge is Enabled in Application Gateway WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Application Gateway WAF policies configuration'

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
    JsChallengeCookieExpirationInMins = toint(properties.policySettings.jsChallengeCookieExpirationInMins),
    CustomRules = properties.customRules
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

    # Fail if any policy is disabled, not in Prevention mode, or has no enabled JSChallenge custom rule
    $failingPolicies = $policies | Where-Object {
        $_.EnabledState -ne 'Enabled' -or
        $_.Mode -ne 'Prevention' -or
        @($_.CustomRules | Where-Object { $_.action -eq 'JSChallenge' -and $_.state -eq 'Enabled' }).Count -eq 0
    }

    $passed = $failingPolicies.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Application Gateway WAF policies attached to Application Gateways are enabled in Prevention mode and have at least one JavaScript challenge rule configured and enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Application Gateway WAF policies attached to Application Gateways are disabled, running in Detection mode, have no JavaScript challenge rules configured, or have JavaScript challenge rules configured but all set to Disabled state, leaving applications without browser verification against automated bots.`n`n%TestResult%"
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

        $allJsRules = @($policy.CustomRules | Where-Object { $_.action -eq 'JSChallenge' })
        $enabledJsRules = @($allJsRules | Where-Object { $_.state -eq 'Enabled' })
        $jsRuleCountDisplay = if ($allJsRules.Count -gt 0) { "✅ $($allJsRules.Count)" } else { '❌ 0' }
        $ruleStateDisplay = if ($allJsRules.Count -eq 0) {
            'N/A'
        }
        elseif ($enabledJsRules.Count -ge 1) {
            '✅ Enabled'
        }
        else {
            '❌ Disabled'
        }
        $cookieExpiry = if ($policy.JsChallengeCookieExpirationInMins) { $policy.JsChallengeCookieExpirationInMins } else { 'N/A' }
        $enabledStateDisplay = if ($policy.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $modeDisplay = if ($policy.Mode -eq 'Prevention') { '✅ Prevention' } else { '❌ Detection' }
        $statusDisplay = if ($policy.EnabledState -eq 'Enabled' -and $policy.Mode -eq 'Prevention' -and $enabledJsRules.Count -ge 1) { '✅' } else { '❌' }

        $tableRows += "| $policyMd | $subMd | $enabledStateDisplay | $modeDisplay | $jsRuleCountDisplay | $ruleStateDisplay | $cookieExpiry | $statusDisplay |`n"
    }

    $formatTemplate = @'

## [{0}]({1})

| Policy name | Subscription name | Policy state | Mode | JS Challenge rules count | Rule state | JavaScript Challenge expiration (mins) | Status |
| :---------- | :---------------- | :----------- | :--- | :----------------------- | :--------- | :------------------------------------- | :----- |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '27017'
        Title  = 'JavaScript Challenge is Enabled in Application Gateway WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
