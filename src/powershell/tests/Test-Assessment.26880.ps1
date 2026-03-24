<#
.SYNOPSIS
    Validates that Request Body Inspection is enabled in Azure Front Door WAF.

.DESCRIPTION
    This test validates that Azure Front Door Web Application Firewall policies
    have request body inspection enabled to analyze HTTP POST, PUT, and PATCH request bodies
    for malicious patterns.

.NOTES
    Test ID: 26880
    Category: Azure Network Security
    Pillar: Network
    Required API: Azure Resource Graph - FrontDoorWebApplicationFirewallPolicies
#>

function Test-Assessment-26880 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Azure WAF'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 26880,
        Title = 'Request Body Inspection is enabled in Azure Front Door WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Azure Front Door WAF request body inspection configuration'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Query Azure Front Door WAF policies that are attached to Azure Front Door instances.
    # A policy is attached if frontendEndpointLinks (classic) or securityPolicyLinks (Standard/Premium) is non-empty.
    # Unattached policies (both arrays empty) are excluded from evaluation.
    # Note: isnotempty() properly handles null and empty arrays, unlike array_length() which returns null for null values.
    $argQuery = @"
resources
| where type =~ 'microsoft.network/frontdoorwebapplicationfirewallpolicies'
| where isnotempty(properties.frontendEndpointLinks) or isnotempty(properties.securityPolicyLinks)
| extend PolicyId = id
| extend PolicyName = name
| extend RequestBodyCheck = tostring(properties.policySettings.requestBodyCheck)
| extend EnabledState = tostring(properties.policySettings.enabledState)
| extend Mode = tostring(properties.policySettings.mode)
| project PolicyId, PolicyName, subscriptionId, RequestBodyCheck, EnabledState, Mode
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
        Write-PSFMessage 'No Azure Front Door WAF policies found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Azure Front Door WAF policies attached to Azure Front Door found across subscriptions.'
        return
    }

    # Compute compliance once per policy to avoid duplicating the predicate logic
    foreach ($policy in $policies) {
        $policy | Add-Member -NotePropertyName 'IsCompliant' -NotePropertyValue (
            $policy.RequestBodyCheck -eq 'Enabled' -and
            $policy.EnabledState -eq 'Enabled' -and
            $policy.Mode -eq 'Prevention'
        )
    }

    # Check if all policies are compliant
    $passed = ($policies | Where-Object { -not $_.IsCompliant }).Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Azure Front Door WAF policies attached to Azure Front Door are enabled, running in Prevention mode, and have request body inspection enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure Front Door WAF policies attached to Azure Front Door are disabled, running in Detection mode, or have request body inspection disabled, leaving applications vulnerable to body-based attacks that bypass WAF rule evaluation.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Table title
    $reportTitle = 'Azure Front Door WAF Policies'
    $portalLink = "https://portal.azure.com/#view/Microsoft_Azure_HybridNetworking/FirewallManagerMenuBlade/~/wafMenuItem"

    # Prepare table rows
    $tableRows = ''
    foreach ($item in $policies | Sort-Object SubscriptionName, PolicyName) {
        $policyLink = "https://portal.azure.com/#resource$($item.PolicyId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.subscriptionId)"
        $policyMd = "[$(Get-SafeMarkdown $item.PolicyName)]($policyLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"

        # Calculate status indicators
        $requestBodyCheckDisplay = if ($item.RequestBodyCheck -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $enabledStateDisplay = if ($item.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $modeDisplay = if ($item.Mode -eq 'Prevention') { '✅ Prevention' } else { "❌ $($item.Mode)" }
        $status = if ($item.IsCompliant) { '✅ Pass' } else { '❌ Fail' }

        $tableRows += "| $policyMd | $subMd | $enabledStateDisplay | $modeDisplay | $requestBodyCheckDisplay | $status |`n"
    }

    $formatTemplate = @'
## [{0}]({1})

| Policy name | Subscription name | Enabled state | WAF mode | Request body check | Status |
| :---------- | :---------------- | :-----------: | :------: | :----------------: | :----: |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '26880'
        Title  = 'Request Body Inspection is enabled in Azure Front Door WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
