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

    #region Helper Functions
    function Get-AzureSubscriptions {
        <#
        .SYNOPSIS
            Gets all Azure subscriptions accessible to the current user.
        .OUTPUTS
            Array of subscription objects or $null if retrieval fails.
        #>
        param(
            [string]$ResourceManagerUrl,
            [string]$ApiVersion = '2022-12-01'
        )

        try {
            $subscriptionsUri = "${ResourceManagerUrl}subscriptions?api-version=${ApiVersion}"
            $response = Invoke-AzRestMethod -Method GET -Uri $subscriptionsUri -ErrorAction Stop

            if ($response.StatusCode -eq 200) {
                $content = $response.Content | ConvertFrom-Json
                return $content.value
            }
            else {
                Write-PSFMessage "Failed to retrieve subscriptions. Status: $($response.StatusCode)" -Level Warning
                return $null
            }
        }
        catch {
            Write-PSFMessage "Error retrieving subscriptions: $_" -Level Warning
            return $null
        }
    }

    function Get-WafPolicies {
        <#
        .SYNOPSIS
            Gets all Application Gateway WAF policies in a subscription.
        .OUTPUTS
            Array of WAF policy objects or empty array if none found.
        #>
        param(
            [string]$ResourceManagerUrl,
            [string]$SubscriptionId,
            [string]$ApiVersion = '2024-03-01'
        )

        try {
            $wafPoliciesUri = "${ResourceManagerUrl}subscriptions/${SubscriptionId}/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies?api-version=${ApiVersion}"
            $response = Invoke-AzRestMethod -Method GET -Uri $wafPoliciesUri -ErrorAction Stop

            if ($response.StatusCode -eq 200) {
                $content = $response.Content | ConvertFrom-Json
                return $content.value
            }
            elseif ($response.StatusCode -eq 404) {
                # No WAF policies found in this subscription
                return @()
            }
            else {
                Write-PSFMessage "Failed to retrieve WAF policies for subscription $SubscriptionId. Status: $($response.StatusCode)" -Level Warning
                return @()
            }
        }
        catch {
            Write-PSFMessage "Error retrieving WAF policies for subscription $SubscriptionId : $_" -Level Verbose
            return @()
        }
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Application Gateway WAF policies are in Prevention mode'
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    # Check Azure connection
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch [Management.Automation.CommandNotFoundException] {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (!$accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Get Azure context
    $resourceManagerUrl = (Get-AzContext).Environment.ResourceManagerUrl

    # Initialize variables
    $testResultMarkdown = ''
    $passed = $false
    $allWafPolicies = @()
    $detectionModePolicies = @()
    $preventionModePolicies = @()

    # Step 1: Get all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Getting Azure subscriptions'
    $subscriptions = Get-AzureSubscriptions -ResourceManagerUrl $resourceManagerUrl

    if (!$subscriptions -or $subscriptions.Count -eq 0) {
        Write-PSFMessage "No Azure subscriptions found or unable to retrieve subscriptions." -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Step 2: Get all WAF policies across all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Getting Application Gateway WAF policies'

    foreach ($subscription in $subscriptions) {
        $subscriptionId = $subscription.subscriptionId
        Write-PSFMessage "Checking subscription: $($subscription.displayName) ($subscriptionId)" -Level Verbose

        $wafPolicies = Get-WafPolicies -ResourceManagerUrl $resourceManagerUrl -SubscriptionId $subscriptionId

        if ($wafPolicies -and $wafPolicies.Count -gt 0) {
            $allWafPolicies += $wafPolicies
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    Write-ZtProgress -Activity $activity -Status 'Analyzing WAF policy modes'

    if ($allWafPolicies.Count -eq 0) {
        $testResultMarkdown = "ℹ️ No Application Gateway WAF policies found in any subscription.`n`n%TestResult%"
        $passed = $true  # No WAF policies means nothing to check - pass by default
    }
    else {
        # Step 3: Analyze each WAF policy
        foreach ($policy in $allWafPolicies) {
            $policyMode = $policy.properties.policySettings.mode
            $policyState = $policy.properties.policySettings.state

            $policyInfo = [PSCustomObject]@{
                Name                = $policy.name
                Id                  = $policy.id
                Location            = $policy.location
                State               = $policyState
                Mode                = $policyMode
                ResourceGroup       = ($policy.id -split '/')[4]
                SubscriptionId      = ($policy.id -split '/')[2]
                ApplicationGateways = @()
            }

            # Get associated Application Gateways
            if ($policy.properties.applicationGateways) {
                $policyInfo.ApplicationGateways = $policy.properties.applicationGateways | ForEach-Object {
                    ($_.id -split '/')[-1]
                }
            }

            # Categorize based on mode
            if ($policyMode -eq 'Prevention') {
                $preventionModePolicies += $policyInfo
            }
            elseif ($policyMode -eq 'Detection') {
                $detectionModePolicies += $policyInfo
            }
        }

        # Step 4: Determine pass/fail status
        if ($detectionModePolicies.Count -eq 0) {
            $passed = $true
            $testResultMarkdown = "✅ All Application Gateway WAF policies ($($allWafPolicies.Count)) are configured in Prevention mode.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ Found $($detectionModePolicies.Count) Application Gateway WAF $($detectionModePolicies.Count -eq 1 ? 'policy' : 'policies') in Detection mode. This leaves applications exposed to exploitation.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $mdInfo = ''

    if ($allWafPolicies.Count -gt 0) {
        $mdInfo += "`n## WAF Policy Mode Assessment`n`n"
        $mdInfo += "**Total WAF policies**: $($allWafPolicies.Count)`n"
        $mdInfo += "**Prevention mode**: $($preventionModePolicies.Count)`n"
        $mdInfo += "**Detection mode**: $($detectionModePolicies.Count)`n`n"

        # Show Detection mode policies first (if any) - these are the issues
        if ($detectionModePolicies.Count -gt 0) {
            $formatTemplate = @'
### ❌ WAF Policies in Detection Mode (Action Required)

**Risk**: These policies only log malicious traffic without blocking it, leaving applications vulnerable to attacks.

| Policy Name | Resource Group | Location | State | Associated App Gateways |
| :---------- | :------------- | :------- | :---- | :---------------------- |
{0}

'@
            $tableRows = ""
            foreach ($policy in ($detectionModePolicies | Sort-Object -Property Name)) {
                $appGateways = if ($policy.ApplicationGateways.Count -gt 0) {
                    ($policy.ApplicationGateways -join ', ')
                } else {
                    'None'
                }
                $tableRows += "| $(Get-SafeMarkdown $policy.Name) | $(Get-SafeMarkdown $policy.ResourceGroup) | $($policy.Location) | $($policy.State) | $(Get-SafeMarkdown $appGateways) |`n"
            }
            $mdInfo += $formatTemplate -f $tableRows
        }

        # Show Prevention mode policies
        if ($preventionModePolicies.Count -gt 0) {
            $formatTemplate = @'
### ✅ WAF Policies in Prevention Mode

| Policy Name | Resource Group | Location | State | Associated App Gateways |
| :---------- | :------------- | :------- | :---- | :---------------------- |
{0}

'@
            $tableRows = ""
            foreach ($policy in ($preventionModePolicies | Sort-Object -Property Name)) {
                $appGateways = if ($policy.ApplicationGateways.Count -gt 0) {
                    ($policy.ApplicationGateways -join ', ')
                } else {
                    'None'
                }
                $tableRows += "| $(Get-SafeMarkdown $policy.Name) | $(Get-SafeMarkdown $policy.ResourceGroup) | $($policy.Location) | $($policy.State) | $(Get-SafeMarkdown $appGateways) |`n"
            }
            $mdInfo += $formatTemplate -f $tableRows
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

    # Add test result details
    Add-ZtTestResultDetail @params
}
