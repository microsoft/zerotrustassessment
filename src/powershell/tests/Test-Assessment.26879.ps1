<#
.SYNOPSIS
    Validates that Request Body Inspection is enabled in Application Gateway WAF.

.DESCRIPTION
    This test validates that Azure Application Gateway Web Application Firewall policies
    have request body inspection enabled to analyze HTTP POST, PUT, and PATCH request bodies
    for malicious patterns.

.NOTES
    Test ID: 26879
    Category: Azure Network Security
    Pillar: Network
    Required API: Azure Resource Graph - ApplicationGatewayWebApplicationFirewallPolicies
#>

function Test-Assessment-26879 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure WAF'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 26879,
        Title = 'Request Body Inspection is enabled in Application Gateway WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Application Gateway WAF request body inspection configuration'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Inner join with Application Gateways filters out orphaned WAF policies (not attached to any gateway).
    # summarize collapses to one row per policy, collecting gateway names into a list.
    # leftouter join adds subscription name on the already-reduced result set.
    $argQuery = @"
resources
| where type =~ 'microsoft.network/ApplicationGatewayWebApplicationFirewallPolicies'
| extend wafPolicyId = tolower(id)
| join kind=inner (
    resources
    | where type =~ 'microsoft.network/applicationgateways'
    | where isnotempty(properties.firewallPolicy.id)
    | extend wafPolicyId = tolower(tostring(properties.firewallPolicy.id))
    | project wafPolicyId, GatewayName=name
) on wafPolicyId
| summarize ApplicationGateways=make_list(GatewayName), PolicyName=any(name), subscriptionId=any(subscriptionId), PolicyId=any(id), RequestBodyCheck=any(tobool(properties.policySettings.requestBodyCheck)), EnabledState=any(tostring(properties.policySettings.state)), Mode=any(tostring(properties.policySettings.mode)) by wafPolicyId
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionId, SubscriptionName=name
) on subscriptionId
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
    # Skip test if no policies found
    if ($policies.Count -eq 0) {
        Write-PSFMessage 'No Application Gateway WAF policies found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Application Gateway WAF policies attached to Application Gateways found across subscriptions.'
        return
    }

    # Check if all policies have request body inspection enabled
    $passed = ($policies | Where-Object { $_.RequestBodyCheck -ne $true }).Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Application Gateway WAF policies attached to Application Gateways have request body inspection enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Application Gateway WAF policies attached to Application Gateways have request body inspection disabled.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Table title
    $reportTitle = 'Application Gateway WAF Policies'
    $portalLink = "https://portal.azure.com/#view/Microsoft_Azure_HybridNetworking/FirewallManagerMenuBlade/~/wafMenuItem"

    # Prepare table rows
    $tableRows = ''
    foreach ($item in $policies | Sort-Object SubscriptionName, PolicyName) {
        $policyLink = "https://portal.azure.com/#resource$($item.PolicyId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $policyMd = "[$(Get-SafeMarkdown $item.PolicyName)]($policyLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"

        # Extract Application Gateway names from the ARG make_list array and sanitize for Markdown
        $appGwMd = @($item.ApplicationGateways | ForEach-Object { Get-SafeMarkdown $_ }) -join ', '

        # Calculate status indicators
        $requestBodyCheckDisplay = if ($item.RequestBodyCheck -eq $true) { '✅ Enabled' } else { '❌ Disabled' }
        $enabledStateDisplay = if ($item.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $modeDisplay = if ($item.Mode -eq 'Prevention') { '✅ Prevention' } else { "⚠️ $($item.Mode)" }
        $status = if ($item.RequestBodyCheck -eq $true) { '✅ Pass' } else { '❌ Fail' }

        $tableRows += "| $policyMd | $subMd | $appGwMd | $enabledStateDisplay | $modeDisplay | $requestBodyCheckDisplay | $status |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Policy name | Subscription name | Attached Application Gateways | Enabled state | WAF mode | Request body check | Status |
| :---------- | :---------------- | :---------------------------- | :-----------: | :------: | :----------------: | :----: |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '26879'
        Title  = 'Request Body Inspection is enabled in Application Gateway WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
