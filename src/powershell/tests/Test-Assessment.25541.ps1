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
        MinimumLicense = ('Azure WAF', 'Azure Application Gateway Standard SKU'),
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

    $activity = 'Checking Application Gateway WAF policies configuration'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Enumerating subscriptions'

    # Initialize variables
    $subscriptions = @()
    $policies = @()
    $anySuccessfulAccess = 0
    $apiVersion = '2025-03-01'

    try {
        $subscriptions = Get-AzSubscription -ErrorAction Stop
    }
    catch {
        Write-PSFMessage "Unable to retrieve Azure subscriptions: $_" -Level Warning
    }

    if ($subscriptions.Count -eq 0) {
        Write-PSFMessage 'No Azure subscriptions found.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Collect WAF policies from all subscriptions
    foreach ($sub in $subscriptions) {
        Write-ZtProgress -Activity $activity -Status "Checking subscription: $($sub.Name)"

        $path = "/subscriptions/$($sub.Id)/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies?api-version=$apiVersion"
        $response = Invoke-AzRestMethod -Path $path -ErrorAction SilentlyContinue

        # Skip if request failed completely
        if (-not $response -or $null -eq $response.StatusCode) {
            Write-PSFMessage "Failed to query subscription '$($sub.Name)'. Skipping." -Level Warning
            continue
        }

        # Handle access denied for this subscription - skip and continue to next
        if ($response.StatusCode -eq 403) {
            Write-PSFMessage "Access denied to subscription '$($sub.Name)': HTTP $($response.StatusCode). Skipping." -Level Verbose
            continue
        }

        # Handle other HTTP errors - skip this subscription
        if ($response.StatusCode -ge 400) {
            Write-PSFMessage "Error querying subscription '$($sub.Name)': HTTP $($response.StatusCode). Skipping." -Level Warning
            continue
        }

        # Count successful accesses
        $anySuccessfulAccess++

        # No content or no policies in this subscription
        if (-not $response.Content) {
            continue
        }

        # Azure REST list APIs are paginated.
        # Handling nextLink is required to avoid missing WAF policies in subscriptions with many policies.
        $allPoliciesInSub = @()
        $policiesJson = $response.Content | ConvertFrom-Json

        if ($policiesJson.value) {
            $allPoliciesInSub += $policiesJson.value
        }

        $nextLink = $policiesJson.nextLink
        while ($nextLink) {
            $response = Invoke-AzRestMethod -Uri $nextLink -Method GET
            $policiesJson = $response.Content | ConvertFrom-Json
            if ($policiesJson.value) {
                $allPoliciesInSub += $policiesJson.value
            }
            $nextLink = $policiesJson.nextLink
        }

        if ($allPoliciesInSub.Count -eq 0) {
            continue
        }

        # Collect policies from this subscription
        foreach ($policyResource in $allPoliciesInSub) {
            $policies += [PSCustomObject]@{
                SubscriptionId   = $sub.Id
                SubscriptionName = $sub.Name
                PolicyName       = $policyResource.name
                PolicyId         = $policyResource.id
                EnabledState     = $policyResource.properties.policySettings.state
                Mode             = $policyResource.properties.policySettings.mode
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Skip test if no policies found
    if ($policies.Count -eq 0) {
        if ($anySuccessfulAccess -eq 0) {
            # All subscriptions were inaccessible
            Write-PSFMessage 'No accessible Azure subscriptions found.' -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        } else {
            # Subscriptions accessible but no WAF policies deployed
            Write-PSFMessage 'No Application Gateway WAF policies found across subscriptions.' -Tag Test -Level Verbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Check if all policies are enabled and in Prevention mode
    $allCompliant = $true
    foreach ($policy in $policies) {
        if ($policy.EnabledState -ne 'Enabled' -or $policy.Mode -ne 'Prevention') {
            $allCompliant = $false
            break
        }
    }

    if ($allCompliant) {
        $passed = $true
        $testResultMarkdown = "✅ All Application Gateway WAF policies are enabled in **Prevention** mode.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ One or more Application Gateway WAF policies are either in **Disabled** state or in **Detection** mode.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Table title
    $reportTitle = 'Application Gateway WAF policies'
    $portalLink = 'https://portal.azure.com/#view/Microsoft_Azure_HybridNetworking/FirewallManagerMenuBlade/~/wafMenuItem'

    # Prepare table rows
    $tableRows = ''
    foreach ($item in $policies | Sort-Object SubscriptionName, PolicyName) {
        $policyLink = "https://portal.azure.com/#resource$($item.PolicyId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $policyMd = "[$(Get-SafeMarkdown $item.PolicyName)]($policyLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"

        # Calculate status indicators
        $policyStatus = if ($item.EnabledState -eq 'Enabled' -and $item.Mode -eq 'Prevention') { '✅' } else { '❌' }
        $modeDisplay = if ($item.Mode -eq 'Prevention') { '✅ Prevention' } else { '❌ Detection' }
        $enabledStateDisplay = if ($item.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }

        $tableRows += "| $policyMd | $subMd | $enabledStateDisplay | $modeDisplay | $policyStatus |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Policy name | Subscription name | Policy state | Mode | Status |
| :---------- | :---------------- | :----------: | :--: | :----: |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

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
