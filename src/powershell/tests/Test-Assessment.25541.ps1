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

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Query all Application Gateway WAF policies using Azure Resource Graph
    $argQuery = @"
    resources
    | where type =~ 'microsoft.network/ApplicationGatewayWebApplicationFirewallPolicies'
    | join kind=leftouter (resourcecontainers | where type =~ 'microsoft.resources/subscriptions' | project subscriptionName=name, subscriptionId) on subscriptionId
    | project PolicyName=name, SubscriptionName=subscriptionName, SubscriptionId=subscriptionId, EnabledState=tostring(properties.policySettings.state), Mode=tostring(properties.policySettings.mode), PolicyId=id
"@

    $policies = @()
    try {
        $policies = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($policies.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Skip test if no policies found
    if ($policies.Count -eq 0) {
        Write-PSFMessage 'No Application Gateway WAF policies found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Check if all policies are enabled and in Prevention mode
    $passed = ($policies | Where-Object { $_.EnabledState -ne 'Enabled' -or $_.Mode -ne 'Prevention' }).Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Application Gateway WAF policies are enabled in **Prevention** mode.`n`n%TestResult%"
    }
    else {
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
