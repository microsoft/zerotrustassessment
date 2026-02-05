<#
.SYNOPSIS
    Validates that Azure Front Door WAF is enabled in Prevention Mode.

.DESCRIPTION
    This test validates that Azure Front Door Web Application Firewall policies are configured
    in Prevention mode to actively block malicious requests. Checks all Front Door WAF policies
    across all subscriptions and reports their prevention/detection mode status.

.NOTES
    Test ID: 25543
    Category: Azure Network Security
    Required API: Azure Front Door WAF Policies
#>

function Test-Assessment-25543 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure WAF on Azure Front Door Premium SKU', 'Azure Standard SKU'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25543,
        Title = 'Azure Front Door WAF is Enabled in Prevention Mode',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Azure Front Door WAF policies configuration'

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
    $apiVersion = "2025-03-01"

    try {
        $subscriptions = Get-AzSubscription -ErrorAction Stop
    }
    catch {
        Write-PSFMessage "Unable to retrieve Azure subscriptions: $_" -Level Warning
    }

    if ($subscriptions.Count -eq 0) {
        Write-PSFMessage "No Azure subscriptions found." -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Collect WAF policies from all subscriptions
    foreach ($sub in $subscriptions) {
        Write-ZtProgress -Activity $activity -Status "Checking subscription: $($sub.Name)"

        $path = "/subscriptions/$($sub.Id)/providers/Microsoft.Network/FrontDoorWebApplicationFirewallPolicies?api-version=$apiVersion"
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

        $policiesJson = $response.Content | ConvertFrom-Json

        if (-not $policiesJson.value -or $policiesJson.value.Count -eq 0) {
            continue
        }

        # Collect policies from this subscription
        foreach ($policyResource in $policiesJson.value) {
            $policies += [PSCustomObject]@{
                SubscriptionId   = $sub.Id
                SubscriptionName = $sub.Name
                PolicyName       = $policyResource.name
                PolicyId         = $policyResource.id
                EnabledState     = $policyResource.properties.policySettings.enabledState
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
            Write-PSFMessage "No accessible Azure subscriptions found." -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        } else {
            # Subscriptions accessible but no WAF policies deployed
            Write-PSFMessage "No Azure Front Door WAF policies found across subscriptions." -Tag Test -Level Verbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Assess policies if found
    if ($policies.Count -gt 0) {
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
            $testResultMarkdown = "✅ All Azure Front Door WAF policies are enabled in **Prevention** mode.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ One or more Azure Front Door WAF policies are either in **Disabled** state or in **Detection** mode.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($policies.Count -gt 0) {
        # Table title
        $reportTitle = 'Azure Front Door WAF policies'
        $portalLink = "https://portal.azure.com/#view/Microsoft_Azure_HybridNetworking/FirewallManagerMenuBlade/~/wafMenuItem"

        # Prepare table rows
        $tableRows = ''
        foreach ($item in $policies) {
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

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows.TrimEnd("`n")
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25543'
        Title  = 'Azure Front Door WAF is Enabled in Prevention Mode'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
