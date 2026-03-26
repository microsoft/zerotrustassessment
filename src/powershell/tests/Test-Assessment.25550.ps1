<#
.SYNOPSIS
    Inspection of Outbound TLS Traffic is Enabled on Azure Firewall
.DESCRIPTION
    Verifies that Azure Firewall Premium has TLS inspection enabled by checking for global certificate authority configuration
    and at least one application rule with terminateTLS enabled.
#>

function Test-Assessment-25550 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Azure_Firewall_Premium'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 25550,
        Title = 'Inspection of Outbound TLS Traffic is Enabled on Azure Firewall',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start Azure Firewall TLS Inspection evaluation' -Tag Test -Level VeryVerbose

    $activity = 'Checking Azure Firewall TLS Inspection configuration'

    #region Data Collection

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Check the supported environment, 'AzureCloud' maps to 'Global'
    Write-ZtProgress -Activity $activity -Status 'Checking Azure environment'

    if ($azContext.Environment.Name -ne 'AzureCloud') {
        Write-PSFMessage 'This test is only applicable to the Global (AzureCloud) environment.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Q1-Q3: Query all firewall policies via Azure Resource Graph
    Write-ZtProgress -Activity $activity -Status 'Querying Azure Firewall policies via Resource Graph'

    $policyQuery = @"
resources
| where type =~ 'microsoft.network/firewallpolicies'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    PolicyName=name,
    PolicyId=id,
    SubscriptionName=subscriptionName,
    SkuTier=tostring(properties.sku.tier),
    FirewallCount=coalesce(array_length(properties.firewalls), 0),
    CertName=tostring(properties.transportSecurity.certificateAuthority.name),
    CertKeyVaultSecretId=tostring(properties.transportSecurity.certificateAuthority.keyVaultSecretId)
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

    # Filter for Premium SKU policies
    $premiumPolicies = @($allPolicies | Where-Object { $_.SkuTier -eq 'Premium' })

    # Q4-Q5: Find policies with at least one application rule that has terminateTLS enabled
    $tlsPolicyIds = @()
    if ($premiumPolicies.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Checking application rules for TLS inspection'

        $tlsRuleQuery = @"
resources
| where type =~ 'microsoft.network/firewallpolicies/rulecollectiongroups'
| mvexpand ruleCollection = properties.ruleCollections
| where ruleCollection.ruleCollectionType =~ 'FirewallPolicyFilterRuleCollection'
| mvexpand rule = ruleCollection.rules
| where rule.ruleType =~ 'ApplicationRule' and rule.terminateTLS == true
| extend lowerId = tolower(id)
| extend policyId = substring(lowerId, 0, indexof(lowerId, '/rulecollectiongroups/'))
| distinct policyId
"@

        try {
            $tlsPolicyIds = @(Invoke-ZtAzureResourceGraphRequest -Query $tlsRuleQuery | ForEach-Object { $_.policyId })
            Write-PSFMessage "ARG found $($tlsPolicyIds.Count) policy(ies) with TLS-enabled rules" -Tag Test -Level VeryVerbose
        }
        catch {
            Write-PSFMessage "TLS rule query failed: $($_.Exception.Message)" -Tag Test -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NotSupported
            return
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Build evaluation results for each Premium policy
    $evaluationResults = @()
    foreach ($policy in $premiumPolicies) {
        $policyIdLower = $policy.PolicyId.ToLower()
        $attachedToFirewall = $policy.FirewallCount -gt 0
        $tlsGloballyConfigured = [bool]$policy.CertName -and [bool]$policy.CertKeyVaultSecretId
        $hasTlsRules = $policyIdLower -in $tlsPolicyIds
        $portalUrl = "https://portal.azure.com/#@/resource$($policy.PolicyId)"

        $evaluationResults += [PSCustomObject]@{
            SubscriptionName      = $policy.SubscriptionName
            PolicyName            = $policy.PolicyName
            PortalUrl             = $portalUrl
            AttachedToFirewall    = $attachedToFirewall
            TLSGloballyConfigured = $tlsGloballyConfigured
            CertName              = if ($policy.CertName) { $policy.CertName } else { 'N/A' }
            HasTlsRules           = $hasTlsRules
            PassesCriteria        = $attachedToFirewall -and $tlsGloballyConfigured -and $hasTlsRules
        }
    }

    # Determine overall result
    $passed = $false
    $testResultMarkdown = ''

    # Separate attached (evaluable) policies from unattached (skipped) ones
    $attachedResults = @($evaluationResults | Where-Object { $_.AttachedToFirewall })

    if ($premiumPolicies.Count -eq 0) {
        # Policies exist but none are Premium → Fail
        $testResultMarkdown = "❌ TLS inspection is not properly configured on Azure Firewall. Either the global certificate authority is missing, or no application rules have TLS inspection enabled.`n`n"
    }
    elseif ($attachedResults.Count -eq 0) {
        # All Premium policies are not attached to any firewall → Skipped
        Write-PSFMessage 'All Premium firewall policies are not attached to any Azure Firewall.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }
    elseif ($attachedResults | Where-Object { $_.PassesCriteria }) {
        $passed = $true
        $testResultMarkdown = "✅ TLS inspection is enabled on Azure Firewall Premium. Global TLS certificate authority is configured and at least one application rule has TLS inspection enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ TLS inspection is not properly configured on Azure Firewall. Either the global certificate authority is missing, or no application rules have TLS inspection enabled.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation
    $formatTemplate = @'

## Azure Firewall policies TLS inspection status

| Subscription name | Azure Firewall policy name | Attached to Firewall | TLS inspection globally configured | Certificate authority name | Application rule with TLS inspection enabled |
| :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

    $tableRows = ''
    foreach ($result in $evaluationResults) {
        $policyName = Get-SafeMarkdown -Text $result.PolicyName
        $policyNameWithLink = "[$policyName]($($result.PortalUrl))"
        $subName = Get-SafeMarkdown -Text $result.SubscriptionName
        $attached = if ($result.AttachedToFirewall) { 'Yes' } else { 'No' }
        $tlsConfigured = if ($result.TLSGloballyConfigured) { 'Yes' } else { 'No' }
        $certName = Get-SafeMarkdown -Text $result.CertName
        $tlsRules = if ($result.HasTlsRules) { 'Yes' } else { 'No' }

        $tableRows += "| $subName | $policyNameWithLink | $attached | $tlsConfigured | $certName | $tlsRules |`n"
    }

    $mdInfo = $formatTemplate -f $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '25550'
        Title  = 'Inspection of Outbound TLS Traffic is Enabled on Azure Firewall'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
