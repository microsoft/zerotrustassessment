<#
.SYNOPSIS
    Validates that bot protection ruleset is enabled and assigned in Azure Front Door WAF.

.DESCRIPTION
    This test evaluates Azure Front Door Premium profiles to ensure the Bot Manager rule set
    is enabled in the associated WAF policy and properly assigned via security policies.

.NOTES
    Test ID: 26884
    Category: Azure Network Security
    Required APIs: Azure Management REST API (subscriptions, Front Door profiles, WAF policies, security policies)
#>

function Test-Assessment-26884 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Azure_Front_Door_Premium'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 26884,
        Title = 'Bot protection rule set is enabled and assigned in Azure Front Door WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating Azure Front Door WAF bot protection configuration'

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

    # Q1 & Q2: Query Azure Front Door Premium profiles using Azure Resource Graph
    Write-ZtProgress -Activity $activity -Status 'Querying Azure Front Door profiles via Resource Graph'

    $argQuery = @"
resources
| where type =~ 'microsoft.cdn/profiles'
| where properties.provisioningState =~ 'Succeeded'
| where sku.name in~ ('Premium_AzureFrontDoor', 'Standard_AzureFrontDoor')
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    ProfileName=name,
    ProfileId=id,
    Location=location,
    SkuName=tostring(sku.name),
    ResourceGroup=resourceGroup,
    SubscriptionId=subscriptionId,
    SubscriptionName=subscriptionName
"@

    $allFrontDoorProfiles = @()
    try {
        $allFrontDoorProfiles = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($allFrontDoorProfiles.Count) Azure Front Door profile(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Check if any Azure Front Door profiles exist
    if ($allFrontDoorProfiles.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door profiles found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Filter Premium profiles for evaluation (Standard profiles will be marked as skipped)
    $premiumProfiles = $allFrontDoorProfiles | Where-Object { $_.SkuName -eq 'Premium_AzureFrontDoor' }
    $standardProfiles = $allFrontDoorProfiles | Where-Object { $_.SkuName -eq 'Standard_AzureFrontDoor' }

    # If no Premium profiles exist, skip the test
    if ($premiumProfiles.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door Premium profiles found. Bot protection is only available in Premium SKU.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q3: Query all WAF policies in all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Querying WAF policies'

    $wafPoliciesArgQuery = @"
resources
| where type =~ 'microsoft.network/frontdoorwebapplicationfirewallpolicies'
| project
    PolicyId=id,
    PolicyName=name,
    SkuName=tostring(sku.name),
    EnabledState=tostring(properties.policySettings.enabledState),
    Mode=tostring(properties.policySettings.mode),
    ManagedRuleSets=properties.managedRules.managedRuleSets,
    SecurityPolicyLinks=properties.securityPolicyLinks,
    SubscriptionId=subscriptionId
"@

    $allWafPolicies = @()
    try {
        $allWafPolicies = @(Invoke-ZtAzureResourceGraphRequest -Query $wafPoliciesArgQuery)
        Write-PSFMessage "ARG Query returned $($allWafPolicies.Count) WAF policy(ies)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "WAF policies query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Build a hashtable for quick WAF policy lookup by ID
    $wafPolicyLookup = @{}
    foreach ($wafPolicy in $allWafPolicies) {
        $wafPolicyLookup[$wafPolicy.PolicyId.ToLower()] = $wafPolicy
    }

    # Evaluate each Premium Front Door profile
    Write-ZtProgress -Activity $activity -Status 'Evaluating bot protection configuration'

    $evaluationResults = @()

    foreach ($fdProfile in $premiumProfiles) {
        $profileId = $fdProfile.ProfileId
        $profileName = $fdProfile.ProfileName

        # Q4: Query security policies for this Front Door profile
        $securityPoliciesPath = "$profileId/securityPolicies?api-version=2024-02-01"

        $securityPolicies = @()
        try {
            $securityPolicies = @(Invoke-ZtAzureRequest -Path $securityPoliciesPath)
        }
        catch {
            Write-PSFMessage "Error querying security policies for $profileName : $_" -Level Warning
        }

        # Evaluate security policies and associated WAF policies
        $hasValidBotProtection = $false
        $associatedWafPolicyName = 'None'
        $associatedWafPolicyId = $null
        $botManagerEnabled = 'No'
        $ruleSetVersion = 'N/A'
        $ruleSetAction = 'N/A'
        $domainsProtected = 0
        $securityPolicyConfigured = 'No'
        $wafEnabled = 'N/A'
        $wafMode = 'N/A'
        $wafIsPremium = $false
        $hasEnabledRule = $false

        if ($securityPolicies.Count -gt 0) {
            $securityPolicyConfigured = 'Yes'

            foreach ($secPolicy in $securityPolicies) {
                # Reset domain count for each security policy to avoid accumulation
                $currentPolicyDomainCount = 0

                # Reset Bot Manager-related fields for each security policy to avoid stale values
                $botManagerEnabled = 'No'
                $ruleSetVersion = 'N/A'
                $ruleSetAction = 'N/A'
                $hasEnabledRule = $false

                $wafPolicyRef = $secPolicy.properties.parameters.wafPolicy.id

                if ($wafPolicyRef) {
                    $associatedWafPolicyId = $wafPolicyRef.ToLower()

                    # Count domains protected by this security policy
                    $associations = $secPolicy.properties.parameters.associations
                    if ($associations) {
                        foreach ($assoc in $associations) {
                            if ($assoc.domains) {
                                $currentPolicyDomainCount += $assoc.domains.Count
                            }
                        }
                    }

                    # Look up the WAF policy
                    if ($wafPolicyLookup.ContainsKey($associatedWafPolicyId)) {
                        $wafPolicy = $wafPolicyLookup[$associatedWafPolicyId]
                        $associatedWafPolicyName = $wafPolicy.PolicyName
                        $wafEnabled = $wafPolicy.EnabledState
                        $wafMode = $wafPolicy.Mode
                        $wafIsPremium = $wafPolicy.SkuName -eq 'Premium_AzureFrontDoor'

                        # Check for Bot Manager rule set
                        $managedRuleSets = $wafPolicy.ManagedRuleSets
                        if ($managedRuleSets) {
                            foreach ($ruleSet in $managedRuleSets) {
                                if ($ruleSet.ruleSetType -eq 'Microsoft_BotManagerRuleSet') {
                                    $botManagerEnabled = 'Yes'
                                    $ruleSetVersion = $ruleSet.ruleSetVersion
                                    if ($ruleSet.ruleSetAction) {
                                        $ruleSetAction = $ruleSet.ruleSetAction
                                    }
                                    else {
                                        $ruleSetAction = 'Per-rule defaults'
                                    }

                                    # Check if at least one rule is enabled in the Bot Manager rule set
                                    # Rules are enabled by default unless explicitly disabled. Azure WAF managed rule
                                    # overrides typically list only changed rules; non-overridden rules remain enabled
                                    # by default. To avoid false negatives, we assume there is at least one enabled
                                    # rule unless we have conclusive evidence that the entire ruleset is disabled.
                                    $hasEnabledRule = $true
                                    if ($ruleSet.ruleGroupOverrides) {
                                        # We intentionally do not flip $hasEnabledRule to $false when all *overridden*
                                        # rules are disabled, because there may still be non-overridden (and thus
                                        # enabled) rules in the Bot Manager ruleset. Missing or empty overrides are
                                        # treated as default-enabled.
                                        foreach ($override in $ruleSet.ruleGroupOverrides) {
                                            if ($override.rules) {
                                                foreach ($rule in $override.rules) {
                                                    if ($rule.enabledState -ne 'Disabled') {
                                                        # At least one explicitly enabled/non-disabled rule found.
                                                        # Keep $hasEnabledRule = $true and break out early.
                                                        break
                                                    }
                                                }
                                            }
                                            else {
                                                # No explicit rule overrides for this group: cannot conclude all rules
                                                # are disabled; non-overridden rules remain enabled by default.
                                                break
                                            }
                                        }
                                    }

                                    # Check if WAF policy is enabled, in Prevention mode, and Bot Manager is present with at least one rule enabled
                                    if ($wafIsPremium -and $wafEnabled -eq 'Enabled' -and $wafMode -eq 'Prevention' -and $hasEnabledRule) {
                                        $hasValidBotProtection = $true
                                        # Only count domains from security policy with valid bot protection
                                        $domainsProtected = $currentPolicyDomainCount
                                    }
                                    break
                                }
                            }
                        }
                    }
                }

                # Stop iterating if valid bot protection is found to preserve the correct WAF policy details
                if ($hasValidBotProtection) {
                    break
                }
            }
        }

        $status = if ($hasValidBotProtection) { 'Pass' } else { 'Fail' }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId           = $fdProfile.SubscriptionId
            SubscriptionName         = $fdProfile.SubscriptionName
            ProfileName              = $profileName
            ProfileId                = $profileId
            SkuName                  = $fdProfile.SkuName
            WAFPolicyName            = $associatedWafPolicyName
            WAFPolicyId              = $associatedWafPolicyId
            WAFEnabled               = $wafEnabled
            WAFMode                  = $wafMode
            SecurityPolicyConfigured = $securityPolicyConfigured
            BotManagerEnabled        = $botManagerEnabled
            HasEnabledRule           = $hasEnabledRule
            RuleSetVersion           = $ruleSetVersion
            RuleSetAction            = $ruleSetAction
            DomainsProtected         = $domainsProtected
            Status                   = $status
        }
    }

    # Add Standard SKU profiles as skipped
    $skippedResults = @()
    foreach ($fdProfile in $standardProfiles) {
        $skippedResults += [PSCustomObject]@{
            SubscriptionId           = $fdProfile.SubscriptionId
            SubscriptionName         = $fdProfile.SubscriptionName
            ProfileName              = $fdProfile.ProfileName
            ProfileId                = $fdProfile.ProfileId
            SkuName                  = $fdProfile.SkuName
            WAFPolicyName            = 'N/A'
            WAFEnabled               = 'N/A'
            SecurityPolicyConfigured = 'N/A'
            BotManagerEnabled        = 'N/A'
            RuleSetVersion           = 'N/A'
            RuleSetAction            = 'N/A'
            DomainsProtected         = 0
            Status                   = 'Skipped'
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passedItems = $evaluationResults | Where-Object { $_.Status -eq 'Pass' }
    $failedItems = $evaluationResults | Where-Object { $_.Status -eq 'Fail' }

    $passed = ($failedItems.Count -eq 0) -and ($passedItems.Count -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ All Azure Front Door WAF policies attached to Azure Front Door are enabled, running in Prevention mode, and have the Bot Manager rule set (Microsoft_BotManagerRuleSet) with at least one rule enabled, providing protection against malicious bot traffic.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure Front Door WAF policies attached to Azure Front Door are disabled, running in Detection mode, do not have the Bot Manager rule set configured, or have all Bot Manager rules disabled, leaving web applications vulnerable to automated attacks and malicious bots.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    # Portal link variables
    $portalFrontDoorBrowseLink = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/Microsoft.Cdn%2Fprofiles'
    $portalSubscriptionBaseLink = 'https://portal.azure.com/#resource/subscriptions'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'

    $mdInfo = "`n## [Azure Front Door WAF bot protection status]($portalFrontDoorBrowseLink)`n`n"

    # Premium profiles table
    if ($evaluationResults.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
| Subscription | Profile name | SKU | WAF policy | WAF mode | Bot protection enabled | Enabled state | Rule set version | Rule set action | Domains protected | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

        foreach ($result in $evaluationResults) {
            $subscriptionLink = "[$(Get-SafeMarkdown $result.SubscriptionName)]($portalSubscriptionBaseLink/$($result.SubscriptionId)/overview)"
            $profileLink = "[$(Get-SafeMarkdown $result.ProfileName)]($portalResourceBaseLink$($result.ProfileId)/securityPolicies)"
            $statusText = if ($result.Status -eq 'Pass') { '✅ Pass' } else { '❌ Fail' }
            $wafModeDisplay = if ($result.WAFMode -eq 'Prevention') { '✅ Prevention' } else { "⚠️ $($result.WAFMode)" }
            $enabledStateDisplay = if ($result.WAFEnabled -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }

            # Create WAF policy link if policy exists
            $wafPolicyDisplay = if ($result.WAFPolicyId) {
                "[$(Get-SafeMarkdown $result.WAFPolicyName)]($portalResourceBaseLink$($result.WAFPolicyId)/overview)"
            } else {
                $(Get-SafeMarkdown $result.WAFPolicyName)
            }

            $tableRows += "| $subscriptionLink | $profileLink | $($result.SkuName) | $wafPolicyDisplay | $wafModeDisplay | $($result.BotManagerEnabled) | $enabledStateDisplay | $($result.RuleSetVersion) | $($result.RuleSetAction) | $($result.DomainsProtected) | $statusText |`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }

    # Standard SKU profiles table (if any)
    if ($skippedResults.Count -gt 0) {
        $mdInfo += "`n### Standard SKU profiles (Skipped - bot protection not available)`n`n"

        $skippedTableRows = ""
        $skippedFormatTemplate = @'
| Subscription | Profile name | SKU | Status |
| :--- | :--- | :--- | :--- |
{0}

'@

        foreach ($result in $skippedResults) {
            $subscriptionLink = "[$(Get-SafeMarkdown $result.SubscriptionName)]($portalSubscriptionBaseLink/$($result.SubscriptionId)/overview)"
            $profileLink = "[$(Get-SafeMarkdown $result.ProfileName)]($portalResourceBaseLink$($result.ProfileId)/overview)"

            $skippedTableRows += "| $subscriptionLink | $profileLink | $($result.SkuName) | Skipped - Standard SKU |`n"
        }

        $mdInfo += $skippedFormatTemplate -f $skippedTableRows
    }

    # Summary
    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total Azure Front Door Premium profiles evaluated: $($evaluationResults.Count)`n"
    $mdInfo += "- Profiles with bot protection enabled: $($passedItems.Count)`n"
    $mdInfo += "- Profiles without bot protection: $($failedItems.Count)`n"
    $mdInfo += "- Standard SKU profiles (skipped): $($skippedResults.Count)`n"

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '26884'
        Title  = 'Bot protection rule set is enabled and assigned in Azure Front Door WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
