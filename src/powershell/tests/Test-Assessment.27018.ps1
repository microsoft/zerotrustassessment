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

    # Q1: List all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Querying subscriptions'

    $subscriptionsPath = '/subscriptions?api-version=2022-12-01'

    try {
        $result = Invoke-ZtAzureRequest -Path $subscriptionsPath -FullResponse

        if ($result.StatusCode -eq 403) {
            Write-PSFMessage 'The signed in user does not have access to list subscriptions.' -Tag Test -Level Verbose
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }

        if ($result.StatusCode -ge 400) {
            throw "Subscriptions request failed with status code $($result.StatusCode)"
        }

        $subscriptionsJson = $result.Content | ConvertFrom-Json
        $subscriptions = @($subscriptionsJson.value | Where-Object { $_.state -eq 'Enabled' })
    }
    catch {
        Write-PSFMessage "Failed to enumerate Azure subscriptions: $_" -Tag Test -Level Error
        throw
    }

    if ($subscriptions.Count -eq 0) {
        Write-PSFMessage 'No enabled subscriptions found.' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Q2: List WAF policies across all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Querying Azure Front Door WAF policies'

    $allPolicies = @()
    $wafQuerySuccess = $false

    foreach ($subscription in $subscriptions) {
        $subscriptionId = $subscription.subscriptionId
        $subscriptionName = $subscription.displayName

        $wafPath = "/subscriptions/$subscriptionId/providers/Microsoft.Network/FrontDoorWebApplicationFirewallPolicies?api-version=2025-03-01"

        try {
            $wafPoliciesInSub = @(Invoke-ZtAzureRequest -Path $wafPath)
            $wafQuerySuccess = $true

            foreach ($policy in $wafPoliciesInSub) {
                $allPolicies += [PSCustomObject]@{
                    SubscriptionId   = $subscriptionId
                    SubscriptionName = $subscriptionName
                    Policy           = $policy
                }
            }
        }
        catch {
            Write-PSFMessage "Error querying WAF policies in subscription $subscriptionId : $_" -Tag Test -Level Warning
        }
    }

    if (-not $wafQuerySuccess) {
        Write-PSFMessage 'Unable to query WAF policies in any subscription due to access restrictions.' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Q3: Filter to only policies attached to Azure Front Door and evaluate
    $evaluationResults = @()

    foreach ($item in $allPolicies) {
        $policy = $item.Policy
        $frontendLinks = $policy.properties.frontendEndpointLinks
        $securityPolicyLinks = $policy.properties.securityPolicyLinks


        $isAttached = (@($frontendLinks).Count -gt 0) -or (@($securityPolicyLinks).Count -gt 0)

        if (-not $isAttached) {
            continue
        }

        # Evaluate rate limiting rules
        $enabledState = $policy.properties.policySettings.enabledState
        $wafMode = $policy.properties.policySettings.mode
        $customRules = $policy.properties.customRules.rules

        $rateLimitRules = @()
        if ($customRules) {
            $rateLimitRules = @($customRules | Where-Object {
                $_.ruleType -eq 'RateLimitRule' -and $_.enabledState -eq 'Enabled'
            })
        }

        $rateLimitCount = $rateLimitRules.Count
        $rateLimitRuleState = if ($rateLimitCount -gt 0) { 'Enabled' } else { 'Disabled' }

        # Status requires all three: policy enabled, Prevention mode, and at least one RateLimitRule
        $status = 'Fail'
        if ($enabledState -eq 'Enabled' -and $wafMode -eq 'Prevention' -and $rateLimitCount -gt 0) {
            $status = 'Pass'
        }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId   = $item.SubscriptionId
            SubscriptionName = $item.SubscriptionName
            PolicyName       = $policy.name
            PolicyId         = $policy.id
            EnabledState     = $enabledState
            WafMode          = $wafMode
            RateLimitCount   = $rateLimitCount
            RateLimitRuleState = $rateLimitRuleState
            Status           = $status
        }
    }

    # Skip if no attached WAF policies found
    if ($evaluationResults.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door WAF policies attached to Azure Front Door found across subscriptions.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    #endregion Data Collection

    #region Assessment Logic

    $passedItems = $evaluationResults | Where-Object { $_.Status -eq 'Pass' }
    $failedItems = $evaluationResults | Where-Object { $_.Status -eq 'Fail' }

    $passed = ($failedItems.Count -eq 0) -and ($passedItems.Count -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ All Azure Front Door WAF policies attached to Azure Front Door have at least one rate limiting rule configured and enabled.`n`n%TestResult%"
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

    if ($evaluationResults.Count -gt 0) {
        $tableRows = ''
        $formatTemplate = @'
| Policy name | Subscription | Rule state | Enabled state | WAF mode | Rate limit rules count | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

        foreach ($result in $evaluationResults) {
            $policyLink = "[$(Get-SafeMarkdown $result.PolicyName)]($portalResourceBaseLink$($result.PolicyId))"
            $subscriptionLink = "[$(Get-SafeMarkdown $result.SubscriptionName)]($portalSubscriptionBaseLink/$($result.SubscriptionId)/overview)"
            $statusText = if ($result.Status -eq 'Pass') { '✅ Pass' } else { '❌ Fail' }

            $tableRows += "| $policyLink | $subscriptionLink | $($result.RateLimitRuleState) | $($result.EnabledState) | $($result.WafMode) | $($result.RateLimitCount) | $statusText |`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }

    # Summary
    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total attached WAF policies evaluated: $($evaluationResults.Count)`n"
    $mdInfo += "- Policies with rate limiting enabled: $($passedItems.Count)`n"
    $mdInfo += "- Policies without rate limiting: $($failedItems.Count)`n"

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
