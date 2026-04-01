<#
.SYNOPSIS
    High-risk web categories are blocked by Azure Firewall application rules.
.DESCRIPTION
    Verifies that Azure Firewall Policies have at least one application rule in a Deny
    rule collection that targets high-risk (Liability group) web categories.
    Web categories allow administrators to block access to inherently dangerous website
    categories such as malware, phishing, hacking, and other liability-group content.
    This check applies to both Standard and Premium SKU firewalls.
.NOTES
    Test ID: 00000 (placeholder — replace with assigned spec ID)
    Category: Azure Network Security
    Required API: Azure Resource Graph
#>

function Test-Assessment-00000 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Azure_Firewall_Standard', 'Azure_Firewall_Premium'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 00000,
        Title = 'High-risk web categories are blocked by Azure Firewall application rules',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start Azure Firewall Web Categories evaluation' -Tag Test -Level VeryVerbose

    $activity = 'Checking Azure Firewall web category filtering configuration'

    #region Data Collection

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Check the supported environment — 'AzureCloud' maps to 'Global'
    Write-ZtProgress -Activity $activity -Status 'Checking Azure environment'

    if ($azContext.Environment.Name -ne 'AzureCloud') {
        Write-PSFMessage 'This test is only applicable to the Global (AzureCloud) environment.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Q1: Query all firewall policies (Standard + Premium) via Azure Resource Graph
    Write-ZtProgress -Activity $activity -Status 'Querying Azure Firewall policies via Resource Graph'

    $policyQuery = @"
resources
| where type =~ 'microsoft.network/firewallpolicies'
| where tostring(properties.sku.tier) in ('Standard', 'Premium')
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    PolicyName=name,
    PolicyId=id,
    SubscriptionName=subscriptionName,
    SubscriptionId=subscriptionId,
    SkuTier=tostring(properties.sku.tier),
    FirewallCount=coalesce(array_length(properties.firewalls), 0)
"@

    $allPolicies = @()
    try {
        $allPolicies = @(Invoke-ZtAzureResourceGraphRequest -Query $policyQuery)
        Write-PSFMessage "ARG returned $($allPolicies.Count) firewall policy(ies)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # No firewall policies at all → Skipped
    if ($allPolicies.Count -eq 0) {
        Write-PSFMessage 'No Azure Firewall policies found in any subscription.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q2: Find policies with at least one Deny application rule targeting web categories
    Write-ZtProgress -Activity $activity -Status 'Checking application rules for web category deny rules'

    $webCatPolicyIds = @()

    $webCatQuery = @"
resources
| where type =~ 'microsoft.network/firewallpolicies/rulecollectiongroups'
| mvexpand ruleCollection = properties.ruleCollections
| where ruleCollection.ruleCollectionType =~ 'FirewallPolicyFilterRuleCollection'
    and ruleCollection.action.type =~ 'Deny'
| mvexpand rule = ruleCollection.rules
| where rule.ruleType =~ 'ApplicationRule'
    and array_length(rule.webCategories) > 0
| extend lowerId = tolower(id)
| extend policyId = substring(lowerId, 0, indexof(lowerId, '/rulecollectiongroups/'))
| distinct policyId
"@

    try {
        $webCatPolicyIds = @(Invoke-ZtAzureResourceGraphRequest -Query $webCatQuery | ForEach-Object { $_.policyId })
        Write-PSFMessage "ARG found $($webCatPolicyIds.Count) policy(ies) with web category deny rules" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Web category rule query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    #endregion Data Collection

    #region Assessment Logic

    # Build evaluation results for each policy
    $evaluationResults = @()
    foreach ($policy in $allPolicies) {
        $policyIdLower = $policy.PolicyId.ToLower()
        $attachedToFirewall = $policy.FirewallCount -gt 0
        $hasWebCatDenyRules = $policyIdLower -in $webCatPolicyIds
        $portalUrl = "https://portal.azure.com/#@/resource$($policy.PolicyId)"

        $evaluationResults += [PSCustomObject]@{
            SubscriptionName   = $policy.SubscriptionName
            SubscriptionId     = $policy.SubscriptionId
            PolicyName         = $policy.PolicyName
            SkuTier            = $policy.SkuTier
            PortalUrl          = $portalUrl
            AttachedToFirewall = $attachedToFirewall
            HasWebCatDenyRules = $hasWebCatDenyRules
            PassesCriteria     = $attachedToFirewall -and $hasWebCatDenyRules
        }
    }

    # Separate attached (evaluable) policies from unattached ones
    $attachedResults = @($evaluationResults | Where-Object { $_.AttachedToFirewall })

    $passed = $false
    $testResultMarkdown = ''

    if ($attachedResults.Count -eq 0) {
        # All policies are not attached to any firewall → Not applicable
        Write-PSFMessage 'All firewall policies are not attached to any Azure Firewall.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }
    elseif (($attachedResults | Where-Object { -not $_.PassesCriteria }).Count -eq 0) {
        $passed = $true
        $testResultMarkdown = @"
✅ All Azure Firewall policies have application rules that deny traffic to high-risk web categories. This provides defense-in-depth against threats delivered through inherently dangerous website categories.

%TestResult%
"@
    }
    else {
        $testResultMarkdown = @"
❌ One or more Azure Firewall policies do not have application rules that deny traffic to high-risk web categories. Without web category filtering, users can access malware distribution sites, phishing pages, and other liability-group content through the firewall.

%TestResult%
"@
    }

    #endregion Assessment Logic

    #region Report Generation

    $formatTemplate = @'

## Azure Firewall policies web category filtering status

| Subscription name | Firewall policy name | SKU | Attached to Firewall | Web category deny rules | Result |
| :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

    $tableRows = ''
    foreach ($result in ($evaluationResults | Sort-Object PolicyName)) {
        $policyName = Get-SafeMarkdown -Text $result.PolicyName
        $policyNameWithLink = "[$policyName]($($result.PortalUrl))"
        $subName = Get-SafeMarkdown -Text $result.SubscriptionName
        $attached = if ($result.AttachedToFirewall) { 'Yes' } else { 'No' }
        $webCatDeny = if ($result.HasWebCatDenyRules) { 'Yes' } else { 'No' }

        if (-not $result.AttachedToFirewall) {
            $icon = '⬜'
        }
        elseif ($result.PassesCriteria) {
            $icon = '✅'
        }
        else {
            $icon = '❌'
        }

        $tableRows += "| $subName | $policyNameWithLink | $($result.SkuTier) | $attached | $webCatDeny | $icon |`n"
    }

    $mdInfo = $formatTemplate -f $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '00000'
        Title  = 'High-risk web categories are blocked by Azure Firewall application rules'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
