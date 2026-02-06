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

    # Check the supported environment, 'AzureCloud' in (Get-AzContext).Environment.Name maps to 'Global' in (Get-MgContext).Environment
    Write-ZtProgress -Activity $activity -Status 'Checking Azure environment'

    if ($azContext.Environment.Name -ne 'AzureCloud') {
        Write-PSFMessage "This test is only applicable to the Global (AzureCloud) environment." -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure subscriptions'
    $subscriptions = Get-AzSubscription
    $resourceManagementUrl = $azContext.Environment.ResourceManagerUrl

    $firewallPoliciesWithTLS = @()

    #endregion Data Collection

    #region Assessment Logic
    foreach ($subscription in $subscriptions) {
        Write-ZtProgress -Activity $activity -Status "Checking subscription: $($subscription.Name)"

        # List all firewall policies in subscription (handle possible pagination via nextLink)
        $fwPoliciesUri = "$resourceManagementUrl/subscriptions/$($subscription.Id)/providers/Microsoft.Network/firewallPolicies?api-version=2025-03-01"
        $fwPolicies = @()

        try {
            do {
                $fwPoliciesResp = Invoke-AzRestMethod -Method GET -Uri $fwPoliciesUri

                if ($fwPoliciesResp.StatusCode -eq 403) {
                    Write-PSFMessage 'The signed in user does not have access to query firewall policies.' -Level Verbose
                    Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
                    return
                }

                if ($fwPoliciesResp.StatusCode -ge 400) {
                    throw "Firewall policies request failed with status code $($fwPoliciesResp.StatusCode)"
                }

                $fwPoliciesJson = $fwPoliciesResp.Content | ConvertFrom-Json
                if ($fwPoliciesJson.value) {
                    $fwPolicies += $fwPoliciesJson.value
                }
                $fwPoliciesUri = $fwPoliciesJson.nextLink
            } while ($fwPoliciesUri)
        }
        catch {
            Write-PSFMessage "Unable to list firewall policies in subscription $($subscription.Name): $_" -Tag Test -Level Warning
            continue
        }

        # Filter for Premium SKU policies only
        $premiumPolicies = $fwPolicies | Where-Object { $_.properties.sku.tier -eq 'Premium' }

        foreach ($policy in $premiumPolicies) {
            Write-ZtProgress -Activity $activity -Status "Evaluating policy: $($policy.name)"

            # Get detailed policy configuration
            try {
                $policyDetailResp = Invoke-AzRestMethod -Method GET -Uri "$resourceManagementUrl$($policy.id)?api-version=2025-03-01"
                $policyDetail = $policyDetailResp.Content | ConvertFrom-Json
            }
            catch {
                Write-PSFMessage "Unable to get details for policy $($policy.name): $_" -Tag Test -Level Warning
                continue
            }

            # Check if global TLS certificate is configured
            $tlsGloballyConfigured = $false
            $certName = 'N/A'
            $certKeyVaultSecretId = 'N/A'
            $certKeyVaultSecretIdDisplay = 'N/A'

            $certAuth = $policyDetail.properties.transportSecurity.certificateAuthority
            if ($certAuth.name -and $certAuth.keyVaultSecretId) {
                $tlsGloballyConfigured = $true
                $certName = $certAuth.name
                $certKeyVaultSecretId = $certAuth.keyVaultSecretId
                $certKeyVaultSecretIdDisplay = 'XXXX'
            }

            # Check for application rules with terminateTLS enabled
            $tlsEnabledRulesFound = $false
            $ruleCollectionGroups = $policyDetail.properties.ruleCollectionGroups

            foreach ($rcgRef in $ruleCollectionGroups) {
                if ($tlsEnabledRulesFound) { break }

                try {
                    $rcgDetailResp = Invoke-AzRestMethod -Method GET -Uri "$resourceManagementUrl$($rcgRef.id)?api-version=2025-03-01"
                    $rcgDetail = $rcgDetailResp.Content | ConvertFrom-Json
                }
                catch {
                    Write-PSFMessage "Unable to get details for rule collection group $($rcgRef.id): $_" -Tag Test -Level Warning
                    continue
                }

                foreach ($ruleCollection in $rcgDetail.properties.ruleCollections) {
                    if ($tlsEnabledRulesFound) { break }
                    if ($ruleCollection.ruleCollectionType -ne 'FirewallPolicyFilterRuleCollection') { continue }

                    foreach ($rule in $ruleCollection.rules) {
                        if ($rule.ruleType -eq 'ApplicationRule' -and $rule.terminateTLS -eq $true) {
                            $tlsEnabledRulesFound = $true
                            break
                        }
                    }
                }
            }

            # Store results
            $firewallPoliciesWithTLS += [PSCustomObject]@{
                SubscriptionId                    = $subscription.Id
                SubscriptionName                  = $subscription.Name
                PolicyName                        = $policy.name
                PolicyId                          = $policy.id
                TLSGloballyConfigured             = if ($tlsGloballyConfigured) { 'Yes' } else { 'No' }
                CertificateAuthorityName          = $certName
                CertificateKeyVaultSecretId       = $certKeyVaultSecretId
                CertificateKeyVaultSecretIdDisplay = $certKeyVaultSecretIdDisplay
                ApplicationRuleWithTLS            = if ($tlsEnabledRulesFound) { 'Yes' } else { 'No' }
                PassesCriteria                    = $tlsGloballyConfigured -and $tlsEnabledRulesFound
            }
        }
    }

    # Determine pass/fail
    $passed = $false
    $testResultMarkdown = ''

    if ($firewallPoliciesWithTLS.Count -eq 0) {
        $testResultMarkdown = "❌ No Azure Firewall Premium policies found in any subscription.`n`n"
    }
    elseif (($firewallPoliciesWithTLS | Where-Object { $_.PassesCriteria }).Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ TLS inspection is globally configured in the Azure Firewall policy and at least one application rule explicitly enables TLS inspection with `"terminateTLS: true`".`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ TLS inspection is not enabled. Either the transportSecurity.certificateAuthority is missing in the firewall policy, or TLS inspection is globally configured but no application rule enables TLS inspection (application rules have `"terminateTLS: false`").`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation
    $formatTemplate = @'

## Azure Firewall policies TLS inspection status

| Subscription ID | Azure Firewall policy name | Azure Firewall policy ID | TLS inspection globally configured | Certificate authority name | Certificate authority Key Vault secret ID | Application rule with TLS inspection enabled |
| :------------- | :------------------------- | :----------------------- | :--------------------------------- | :------------------------- | :------------------------------------- | :------------------------------------------- |
{0}

'@

    $tableRows = ''
    foreach ($policyInfo in $firewallPoliciesWithTLS) {
        $policyName = Get-SafeMarkdown -Text $policyInfo.PolicyName
        $policyId = Get-SafeMarkdown -Text $policyInfo.PolicyId
        $subId = Get-SafeMarkdown -Text $policyInfo.SubscriptionId
        $certName = Get-SafeMarkdown -Text $policyInfo.CertificateAuthorityName
        $certKeyVault = Get-SafeMarkdown -Text $policyInfo.CertificateKeyVaultSecretIdDisplay

        $tableRows += "| $subId | $policyName | $policyId | $($policyInfo.TLSGloballyConfigured) | $certName | $certKeyVault | $($policyInfo.ApplicationRuleWithTLS) |`n"
    }

    $mdInfo = $formatTemplate -f $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '25550'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
