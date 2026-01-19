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

    $subscriptions = Get-AzSubscription
    $results = @()
    foreach ($sub in $subscriptions) {
        Set-AzContext -SubscriptionId $sub.Id | Out-Null
        # Get all firewall policies in the subscription
        $policies = Get-AzResource -ResourceType 'Microsoft.Network/firewallPolicies' -ErrorAction Stop

        if (-not $policies) {
            continue
        }

        #endregion Data Collection
        #region Assessment Logic

        foreach ($policyResource in $policies) {
            $policy = Get-AzFirewallPolicy `
                -Name $policyResource.Name `
                -ResourceGroupName $policyResource.ResourceGroupName `
                -ErrorAction SilentlyContinue

            if (-not $policy) {
                continue
            }

            $subContext = Get-AzContext
            $status = if ($policy.ThreatIntelMode -eq 'Deny') {
                'Pass'
            }
            else {
                'Fail'
            }

            $results += [PSCustomObject]@{
                CheckName        = 'Threat intelligence is Enabled in Deny Mode on Azure Firewall'
                PolicyName       = $policy.Name
                ResourceGroup    = $policy.ResourceGroupName
                SubscriptionName = $subContext.Subscription.Name
                SubscriptionId   = $subContext.Subscription.Id
                ThreatIntelMode  = $policy.ThreatIntelMode
                Status           = $status
            }
        }
    }
    #endregion Assessment Logic

    #region Assessment Logic Evaluation
    if (-not $results) {
        Write-PSFMessage 'No Azure Firewall policies found. Skipping test.' -Tag Firewall -Level Verbose
        return
    }
    else {
        $allModes = $results.ThreatIntelMode
        $uniqueModes = $allModes | Select-Object -Unique

        if ($uniqueModes.Count -eq 1 -and $uniqueModes -eq 'Deny') {

            $passed = $true
            $testResultMarkdown = 'Threat Intel is enabled in **Alert and Deny** mode.'

        }
        else {

            $passed = $false

            if ($uniqueModes.Count -eq 1) {

                switch ($uniqueModes) {
                    'Alert' {
                        $testResultMarkdown = 'Threat Intel is enabled in **Alert** mode.'
                    }
                    'Off' {
                        $testResultMarkdown = 'Threat Intel is **disabled**.'
                    }
                    default {
                        $testResultMarkdown = 'Threat Intel is not enabled in **Alert and Deny** mode for all Firewall policies.'
                    }
                }
            }
            else {
                $testResultMarkdown = 'Threat Intel is not enabled in **Alert and Deny** mode for all Firewall policies.'
            }
        }

        # --- Markdown Table ---
        $mdInfo = "`n`n## Firewall Policies`n`n"
        $mdInfo += "| Policy name | Subscription name | Threat Intel Mode |`n"
        $mdInfo += "| :--- | :--- | :---: |`n"

        foreach ($item in $results | Sort-Object PolicyName) {
            $policyLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)/resourceGroups/$($item.ResourceGroup)/providers/Microsoft.Network/firewallPolicies/$($item.PolicyName)"
            $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
            $policyMd = "[$(Get-SafeMarkdown -Text $item.PolicyName)]($policyLink)"
            $subMd = "[$(Get-SafeMarkdown -Text $item.SubscriptionName)]($subLink)"
            $mdInfo += "| $policyMd | $subMd | $($item.ThreatIntelMode) |`n"
        }

        $testResultMarkdown += $mdInfo

        #endregion Assessment Logic Evaluation

        #region Report Generation
        Add-ZtTestResultDetail `
            -TestId '25537' `
            -Title 'Azure Firewall Threat Intelligence is enabled in Alert and Deny mode' `
            -Status $passed `
            -Result $testResultMarkdown
        #endregion Report Generation
    }
}
