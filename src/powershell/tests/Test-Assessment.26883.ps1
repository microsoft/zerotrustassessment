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
    Required APIs: Azure Management REST API (subscriptions, frontDoorWebApplicationFirewallPolicies)
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

    # Check the supported environment
    Write-ZtProgress -Activity $activity -Status 'Checking Azure environment'

    if ($azContext.Environment.Name -ne 'AzureCloud') {
        Write-PSFMessage 'This test is only applicable to the AzureCloud environment.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Check Azure access token
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (-not $accessToken) {
        Write-PSFMessage 'Azure authentication token not found.' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Step 1: Get all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Querying subscriptions'

    $subscriptionsPath = '/subscriptions?api-version=2025-03-01'
    $subscriptions = @()
    try {
        $subscriptions = @(Invoke-ZtAzureRequest -Path $subscriptionsPath)
        Write-PSFMessage "Found $($subscriptions.Count) subscription(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Failed to query subscriptions: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    if ($subscriptions.Count -eq 0) {
        Write-PSFMessage 'No subscriptions found or user does not have access.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Step 2: Get all Azure Front Door WAF policies from all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Querying Azure Front Door WAF policies'

    $allWafPolicies = @()
    foreach ($subscription in $subscriptions) {
        $subscriptionId = $subscription.subscriptionId
        $subscriptionName = $subscription.displayName

        $wafPath = "/subscriptions/$subscriptionId/providers/Microsoft.Network/frontDoorWebApplicationFirewallPolicies?api-version=2025-03-01"

        try {
            $wafPolicies = @(Invoke-ZtAzureRequest -Path $wafPath)
            foreach ($policy in $wafPolicies) {
                $policy | Add-Member -NotePropertyName 'SubscriptionId' -NotePropertyValue $subscriptionId -Force
                $policy | Add-Member -NotePropertyName 'SubscriptionName' -NotePropertyValue $subscriptionName -Force
            }
            $allWafPolicies += $wafPolicies
            Write-PSFMessage "Found $($wafPolicies.Count) WAF policy(ies) in subscription $subscriptionName" -Tag Test -Level VeryVerbose
        }
        catch {
            Write-PSFMessage "Error querying WAF policies in subscription $subscriptionName : $_" -Level Warning
        }
    }

    # Step 3: Filter to only policies attached to Azure Front Door
    $attachedWafPolicies = @()
    foreach ($policy in $allWafPolicies) {
        $frontendEndpointLinks = $policy.properties.frontendEndpointLinks
        $securityPolicyLinks = $policy.properties.securityPolicyLinks

        $hasAttachment = ($frontendEndpointLinks -and $frontendEndpointLinks.Count -gt 0) -or
                         ($securityPolicyLinks -and $securityPolicyLinks.Count -gt 0)

        if ($hasAttachment) {
            $attachedWafPolicies += $policy
        }
    }

    Write-PSFMessage "Found $($attachedWafPolicies.Count) WAF policy(ies) attached to Azure Front Door" -Tag Test -Level VeryVerbose

    if ($attachedWafPolicies.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door WAF policies attached to Azure Front Door found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Step 4: Evaluate each attached WAF policy for default ruleset
    Write-ZtProgress -Activity $activity -Status 'Evaluating WAF policy configurations'

    $evaluationResults = @()

    foreach ($policy in $attachedWafPolicies) {
        $policyName = $policy.name
        $policyId = $policy.id
        $subscriptionId = $policy.SubscriptionId
        $subscriptionName = $policy.SubscriptionName
        $enabledState = $policy.properties.policySettings.enabledState
        $wafMode = $policy.properties.policySettings.mode
        $skuName = $policy.sku.name

        # Check for Microsoft_DefaultRuleSet in managedRuleSets
        $managedRuleSets = $policy.properties.managedRules.managedRuleSets
        $defaultRuleset = $null
        $hasDefaultRuleset = $false

        if ($managedRuleSets -and $managedRuleSets.Count -gt 0) {
            $defaultRuleset = $managedRuleSets | Where-Object { $_.ruleSetType -eq 'Microsoft_DefaultRuleSet' } | Select-Object -First 1
            if ($defaultRuleset) {
                $hasDefaultRuleset = $true
            }
        }

        $rulesetType = if ($hasDefaultRuleset) { $defaultRuleset.ruleSetType } else { 'None' }
        $rulesetVersion = if ($hasDefaultRuleset) { $defaultRuleset.ruleSetVersion } else { 'N/A' }
        $status = if ($hasDefaultRuleset) { 'Pass' } else { 'Fail' }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId   = $subscriptionId
            SubscriptionName = $subscriptionName
            PolicyName       = $policyName
            PolicyId         = $policyId
            SkuName          = $skuName
            EnabledState     = $enabledState
            WafMode          = $wafMode
            RulesetType      = $rulesetType
            RulesetVersion   = $rulesetVersion
            Status           = $status
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passedItems = $evaluationResults | Where-Object { $_.Status -eq 'Pass' }
    $failedItems = $evaluationResults | Where-Object { $_.Status -eq 'Fail' }

    $passed = ($failedItems.Count -eq 0) -and ($passedItems.Count -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ All Azure Front Door WAF policies attached to Azure Front Door have a default managed ruleset (Microsoft_DefaultRuleSet) enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure Front Door WAF policies attached to Azure Front Door do not have a default managed ruleset configured.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    # Portal link variables
    $portalWafBrowseLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FfrontdoorWebApplicationFirewallPolicies'
    $portalSubscriptionBaseLink = 'https://portal.azure.com/#resource/subscriptions'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'

    $mdInfo = "`n## [Azure Front Door WAF policies]($portalWafBrowseLink)`n`n"

    # WAF Policies Status table
    if ($evaluationResults.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
| Policy name | Subscription name | Attached to AFD | Enabled state | WAF mode | Default ruleset type | Ruleset version | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

        # Limit display to first 5 items if there are many policies
        $maxItemsToDisplay = 5
        $displayResults = $evaluationResults
        $hasMoreItems = $false
        if ($evaluationResults.Count -gt $maxItemsToDisplay) {
            $displayResults = $evaluationResults | Select-Object -First $maxItemsToDisplay
            $hasMoreItems = $true
        }

        foreach ($result in $displayResults) {
            $subscriptionLink = "[$(Get-SafeMarkdown $result.SubscriptionName)]($portalSubscriptionBaseLink/$($result.SubscriptionId)/overview)"
            $policyLink = "[$(Get-SafeMarkdown $result.PolicyName)]($portalResourceBaseLink$($result.PolicyId))"
            $statusText = if ($result.Status -eq 'Pass') { '✅ Pass' } else { '❌ Fail' }

            $tableRows += "| $policyLink | $subscriptionLink | Yes | $($result.EnabledState) | $($result.WafMode) | $($result.RulesetType) | $($result.RulesetVersion) | $statusText |`n"
        }

        # Add note if more items exist
        if ($hasMoreItems) {
            $remainingCount = $evaluationResults.Count - $maxItemsToDisplay
            $tableRows += "`n... and $remainingCount more. [View all WAF Policies in the portal]($portalWafBrowseLink)`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }

    # Summary
    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total Azure Front Door WAF policies evaluated: $($evaluationResults.Count)`n"
    $mdInfo += "- Policies with default ruleset enabled: $($passedItems.Count)`n"
    $mdInfo += "- Policies without default ruleset: $($failedItems.Count)`n"

    # Replace the placeholder with detailed information
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
