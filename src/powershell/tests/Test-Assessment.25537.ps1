<#
.SYNOPSIS
    Validates Threat intelligence is Enabled in Deny Mode on Azure Firewall.
.DESCRIPTION
    This test validates that Azure Firewall Policies have Threat Intelligence enabled in Deny mode.
    Checks all firewall policies in the subscription and reports their threat intelligence status.
.NOTES
    Test ID: 25537
    Category: Azure Network Security
    Required API: Azure Firewall Policies
#>

function Test-Assessment-25537 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure_Firewall_Standard', 'Azure_Firewall_Premium'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25537,
        Title = 'Threat intelligence is Enabled in Deny Mode on Azure Firewall',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    Write-ZtProgress `
        -Activity 'Azure Firewall Threat Intelligence' `
        -Status 'Enumerating Firewall Policies'

    # Query 1: List all subscriptions
    $subscriptions = Get-AzSubscription
    $results = @()

    foreach ($sub in $subscriptions) {
        Set-AzContext -SubscriptionId $sub.Id | Out-Null

        # Query 1: List Azure Firewall Policies
        try {
            $policies = Get-AzResource -ResourceType 'Microsoft.Network/firewallPolicies' -ErrorAction Stop
        }
        catch {
            Write-PSFMessage "Unable to enumerate firewall policies in subscription $($sub.Name): $($_.Exception.Message)" -Tag Firewall -Level Warning
            continue
        }

        if (-not $policies) { continue }

        # Query 2: Get details for each firewall policy and check threatIntelMode
        foreach ($policyResource in $policies) {
            $policy = Get-AzFirewallPolicy `
                -Name $policyResource.Name `
                -ResourceGroupName $policyResource.ResourceGroupName `
                -ErrorAction SilentlyContinue

            if (-not $policy) { continue }

            $subContext = Get-AzContext
            $isCompliant = $policy.ThreatIntelMode -eq 'Deny'

            $results += [PSCustomObject]@{
                PolicyName       = $policy.Name
                ResourceGroup    = $policy.ResourceGroupName
                SubscriptionName = $subContext.Subscription.Name
                SubscriptionId   = $subContext.Subscription.Id
                ThreatIntelMode  = $policy.ThreatIntelMode
                IsCompliant      = $isCompliant
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    if (-not $results) {
        Add-ZtTestResultDetail -SkippedBecause NoResults
        return
    }

    $passed = ($results | Where-Object { -not $_.IsCompliant }).Count -eq 0

    $testResultMarkdown = if ($passed) {
        "Threat intelligence mode is set to Deny for all Azure Firewall policies.`n`n%TestResult%"
    } else {
        "Threat intelligence mode is not set to Deny for all Azure Firewall policies.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = "## Firewall policies`n`n"
    $mdInfo += "| Policy name | Subscription name | Threat Intel mode | Result |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- |`n"

    foreach ($item in $results | Sort-Object PolicyName) {
        $policyLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)/resourceGroups/$($item.ResourceGroup)/providers/Microsoft.Network/firewallPolicies/$($item.PolicyName)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $policyMd = "[$(Get-SafeMarkdown -Text $item.PolicyName)]($policyLink)"
        $subMd = "[$(Get-SafeMarkdown -Text $item.SubscriptionName)]($subLink)"
        $icon = if ($item.IsCompliant) { '✅' } else { '❌' }

        $mdInfo += "| $policyMd | $subMd | $($item.ThreatIntelMode) | $icon |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    Add-ZtTestResultDetail -TestId '25537' -Status $passed -Result $testResultMarkdown
}
