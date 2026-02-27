<#
.SYNOPSIS
    Validates that JavaScript challenge is enabled in Azure Front Door WAF policies.

.DESCRIPTION
    This test evaluates Azure Front Door WAF policies across all subscriptions to verify
    that at least one custom rule with JavaScript challenge action (JSChallenge) is configured
    and enabled. Only policies attached to an Azure Front Door are evaluated.

.NOTES
    Test ID: 27019
    Category: Azure Network Security
    Required APIs: Azure Resource Graph (Front Door WAF policies)
#>

function Test-Assessment-27019 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = 'Azure_WAF',
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27019,
        Title = 'JavaScript Challenge is Enabled in Azure Front Door WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Azure Front Door WAF JavaScript challenge configuration'

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
| project id, name, subscriptionId, subscriptionName, properties
"@

    $allPolicies = @()
    try {
        $allPolicies = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
    }
    catch {
        Write-PSFMessage "Failed to query Azure Front Door WAF policies via Resource Graph: $_" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    if ($allPolicies.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door WAF policies attached to Azure Front Door found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Evaluate each policy for JavaScript challenge rules
    $evaluationResults = @()

    foreach ($policy in $allPolicies) {
        $enabledState = $policy.properties.policySettings.enabledState
        $wafMode = $policy.properties.policySettings.mode
        $cookieExpiration = $policy.properties.policySettings.javascriptChallengeExpirationInMinutes
        $customRules = $policy.properties.customRules.rules

        $jsChallengeRules = @()
        if ($customRules) {
            $jsChallengeRules = @($customRules | Where-Object {
                $_.action -eq 'JSChallenge' -and $_.enabledState -eq 'Enabled'
            })
        }

        $jsChallengeCount = $jsChallengeRules.Count
        $jsChallengeRuleState = if ($jsChallengeCount -gt 0) { 'Enabled' } else { 'Disabled' }
        $cookieExpirationDisplay = if ($cookieExpiration) { $cookieExpiration } else { 'N/A' }

        # Status requires all three: policy enabled, Prevention mode, and at least one JSChallenge rule
        $status = 'Fail'
        if ($enabledState -eq 'Enabled' -and $wafMode -eq 'Prevention' -and $jsChallengeCount -gt 0) {
            $status = 'Pass'
        }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId       = $policy.subscriptionId
            SubscriptionName     = $policy.subscriptionName
            PolicyName           = $policy.name
            PolicyId             = $policy.id
            EnabledState         = $enabledState
            WafMode              = $wafMode
            JSChallengeCount     = $jsChallengeCount
            JSChallengeRuleState = $jsChallengeRuleState
            CookieExpiration     = $cookieExpirationDisplay
            Status               = $status
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passedItems = $evaluationResults | Where-Object { $_.Status -eq 'Pass' }
    $failedItems = $evaluationResults | Where-Object { $_.Status -eq 'Fail' }

    $passed = ($failedItems.Count -eq 0) -and ($passedItems.Count -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ All Azure Front Door WAF policies attached to Azure Front Door are enabled in Prevention mode and have at least one JavaScript Challenge rule configured and enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure Front Door WAF policies attached to Azure Front Door do not have any JavaScript challenge rules configured, leaving applications without browser verification against automated bots at the global edge.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalWafBrowseLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FfrontdoorWebApplicationFirewallPolicies'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'
    $portalSubscriptionBaseLink = 'https://portal.azure.com/#resource/subscriptions'

    $mdInfo = "`n## [Azure Front Door WAF policies]($portalWafBrowseLink)`n`n"

    if ($evaluationResults.Count -gt 0) {
        $tableRows = ''
        $formatTemplate = @'
| Policy name | Subscription name | Enabled state | WAF mode | JS challenge rules count | Rule state | Cookie expiration (mins) | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

        foreach ($result in $evaluationResults) {
            $policyLink = "[$(Get-SafeMarkdown $result.PolicyName)]($portalResourceBaseLink$($result.PolicyId))"
            $subscriptionLink = "[$(Get-SafeMarkdown $result.SubscriptionName)]($portalSubscriptionBaseLink/$($result.SubscriptionId)/overview)"
            $statusText = if ($result.Status -eq 'Pass') { '✅ Pass' } else { '❌ Fail' }

            $tableRows += "| $policyLink | $subscriptionLink | $($result.EnabledState) | $($result.WafMode) | $($result.JSChallengeCount) | $($result.JSChallengeRuleState) | $($result.CookieExpiration) | $statusText |`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }

    # Summary
    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total attached WAF policies evaluated: $($evaluationResults.Count)`n"
    $mdInfo += "- Policies with JavaScript challenge enabled: $($passedItems.Count)`n"
    $mdInfo += "- Policies without JavaScript challenge: $($failedItems.Count)`n"

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '27019'
        Title  = 'JavaScript Challenge is Enabled in Azure Front Door WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
