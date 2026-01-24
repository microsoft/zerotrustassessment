<#
.SYNOPSIS
    Validates that all Application Gateway WAF policies are configured in Prevention mode.

.DESCRIPTION
    This test checks if all Azure Application Gateway Web Application Firewall (WAF) policies
    in the tenant are running in Prevention mode to actively block malicious traffic.
    WAF policies in Detection mode only log threats without blocking them, leaving applications
    vulnerable to exploitation.

.NOTES
    Test ID: 25541
    Category: Azure Network Security
    Required API: Azure Management API - ApplicationGatewayWebApplicationFirewallPolicies
#>

function Test-Assessment-25541 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure_WAF'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25541,
        Title = 'Application Gateway WAF is Enabled in Prevention mode',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Application Gateway WAF policies are in Prevention mode'
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    # Check Azure context and validate AzureCloud environment
    $azContext = $null
    try {
        $azContext = Get-AzContext -ErrorAction Stop
        if ($null -eq $azContext) {
            Write-PSFMessage "No Azure context found." -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
            return
        }

        # Verify environment is AzureCloud
        if ($azContext.Environment.Name -ne 'AzureCloud') {
            Write-PSFMessage "This test is only applicable to the Global environment." -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
            return
        }
    }
    catch {
        Write-PSFMessage "Error retrieving Azure context: $_" -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    $resourceManagerUrl = $azContext.Environment.ResourceManagerUrl

    # Initialize collections
    $allWafPolicies = @()
    $detectionModePolicies = @()
    $preventionModePolicies = @()

    # Query 1: Get all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Getting Azure subscriptions'
    try {
        $subscriptionsUri = "${resourceManagerUrl}subscriptions?api-version=2025-03-01"
        $response = Invoke-AzRestMethod -Method GET -Uri $subscriptionsUri -ErrorAction Stop

        if ($response.StatusCode -eq 200) {
            $subscriptions = ($response.Content | ConvertFrom-Json).value
        }
        else {
            Write-PSFMessage "Failed to retrieve subscriptions. Status: $($response.StatusCode)" -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }
    }
    catch {
        Write-PSFMessage "Error retrieving subscriptions: $_" -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    if (-not $subscriptions -or $subscriptions.Count -eq 0) {
        Write-PSFMessage "No Azure subscriptions found." -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Query 2: Get all WAF policies across all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Getting Application Gateway WAF policies'
    foreach ($subscription in $subscriptions) {
        $subscriptionId = $subscription.subscriptionId
        Write-PSFMessage "Checking subscription: $($subscription.displayName) ($subscriptionId)" -Level Verbose

        try {
            $wafPoliciesUri = "${resourceManagerUrl}subscriptions/${subscriptionId}/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies?api-version=2025-03-01"
            $response = Invoke-AzRestMethod -Method GET -Uri $wafPoliciesUri -ErrorAction Stop

            if ($response.StatusCode -eq 200) {
                $wafPolicies = ($response.Content | ConvertFrom-Json).value
                if ($wafPolicies) {
                    $allWafPolicies += $wafPolicies
                }
            }
            elseif ($response.StatusCode -eq 404) {
                # No WAF policies found in this subscription
                Write-PSFMessage "No WAF policies found in subscription $subscriptionId" -Level Verbose
            }
            else {
                Write-PSFMessage "Failed to retrieve WAF policies for subscription $subscriptionId. Status: $($response.StatusCode)" -Level Verbose
            }
        }
        catch {
            Write-PSFMessage "Error retrieving WAF policies for subscription $subscriptionId : $_" -Level Verbose
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    Write-ZtProgress -Activity $activity -Status 'Analyzing WAF policy modes'

    $testResultMarkdown = ''
    $passed = $false
    $allPoliciesWithStatus = @()

    if ($null -eq $allWafPolicies -or $allWafPolicies.Count -eq 0) {
        # No WAF policies found in any subscription - skip the test
        Write-PSFMessage "No Application Gateway WAF policies found in any subscription." -Level Verbose
        return
    }
    else {
        # Analyze each WAF policy
        foreach ($policy in $allWafPolicies) {
            $policyMode = $policy.properties.policySettings.mode
            $policyState = $policy.properties.policySettings.state
            $subscriptionId = ($policy.id -split '/')[2]

            # Get subscription name
            $subscriptionInfo = $subscriptions | Where-Object { $_.subscriptionId -eq $subscriptionId }
            $subscriptionName = $subscriptionInfo.displayName

            $policyInfo = [PSCustomObject]@{
                SubscriptionName    = $subscriptionName
                SubscriptionId      = $subscriptionId
                Name                = $policy.name
                Id                  = $policy.id
                Location            = $policy.location
                State               = $policyState
                Mode                = $policyMode
                ResourceGroup       = ($policy.id -split '/')[4]
                ApplicationGateways = @()
                IsPassing           = $policyMode -eq 'Prevention'
            }

            # Get associated Application Gateways
            if ($policy.properties.applicationGateways) {
                $policyInfo.ApplicationGateways = $policy.properties.applicationGateways | ForEach-Object {
                    ($_.id -split '/')[-1]
                }
            }

            $allPoliciesWithStatus += $policyInfo

            # Categorize based on mode
            if ($policyMode -eq 'Prevention') {
                $preventionModePolicies += $policyInfo
            }
            elseif ($policyMode -eq 'Detection') {
                $detectionModePolicies += $policyInfo
            }
        }

        # Determine pass/fail status
        if ($detectionModePolicies.Count -eq 0) {
            $passed = $true
            $testResultMarkdown = "✅ Application Gateway WAF policy is enabled in Prevention mode.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ Application Gateway WAF policy is enabled in Detection mode `n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($allPoliciesWithStatus.Count -gt 0) {
        $mdInfo += "`n## Application Gateway WAF Policy Status`n`n"
        $mdInfo += "| Subscription name | WAF policy name | Mode | Status |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"

        foreach ($policy in ($allPoliciesWithStatus | Sort-Object -Property SubscriptionName, Name)) {
            # Create portal link to WAF policy
            $wafPolicyLink = "https://portal.azure.com/#@microsoft.onmicrosoft.com/resource$($policy.Id)/overview"
            $safePolicyName = Get-SafeMarkdown $policy.Name
            $wafPolicyNameLink = "[$safePolicyName]($wafPolicyLink)"

            # Get safe subscription name
            $safeSubscriptionName = Get-SafeMarkdown $policy.SubscriptionName

            # Set status icon based on mode
            $statusIcon = if ($policy.IsPassing) { '✅ Prevention' } else { '❌ Detection' }

            # Build row
            $mdInfo += "| $safeSubscriptionName | $wafPolicyNameLink | $($policy.Mode) | $statusIcon |`n"
        }
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25541'
        Title  = 'Application Gateway WAF is Enabled in Prevention mode'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
