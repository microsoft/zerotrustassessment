<#
.SYNOPSIS
    Validates Intrusion Detection is Enabled in Deny Mode on Azure Firewall.
.DESCRIPTION
    This test validates that Azure Firewall Policies have Intrusion Detection enabled in Deny mode.
    Checks all firewall policies in the subscription and reports their intrusion detection status.
.NOTES
    Test ID: 25539
    Category: Azure Network Security
    Required API: Azure Firewall Policies
#>

function Test-Assessment-25539 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure_Firewall_Premium'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25539,
        Title = 'IDPS Inspection is Enabled in Deny Mode on Azure Firewall',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    Write-ZtProgress `
        -Activity 'Azure Firewall Intrusion Detection' `
        -Status 'Enumerating Firewall Policies'

    $subscriptions = Get-AzSubscription
    $results = @()
    foreach ($sub in $subscriptions) {
        $contextSet = Set-AzContext -SubscriptionId $sub.Id -ErrorAction SilentlyContinue

        if (-not $contextSet) {
            Write-PSFMessage "Unable to set context for subscription $($sub.Id). Skipping." -Tag Firewall -Level Verbose
            continue
        }

        # Get all firewall policies in the current subscription
        $policies = $null
        $policies = Get-AzResource -ResourceType 'Microsoft.Network/firewallPolicies' -ErrorAction SilentlyContinue

        if (-not $policies) {
            continue
        }

        foreach ($policyResource in $policies) {
            $policy = Get-AzFirewallPolicy `
                -Name $policyResource.Name `
                -ResourceGroupName $policyResource.ResourceGroupName `
                -ErrorAction SilentlyContinue

            if (-not $policy) {
                continue
            }

            # Skip if SKU tier is not Premium
            if ($policy.Sku.Tier -ne 'Premium') {
                Write-PSFMessage "Firewall policy '$($policy.Name)' does not have Premium SKU. Skipping." -Tag Firewall -Level Verbose
                continue
            }

            $subContext = Get-AzContext

            # Get the intrusion detection mode (handle both nested object and string property)
            $idMode = $null
            if ($null -ne $policy.IntrusionDetection) {
                if ($policy.IntrusionDetection -is [string]) {
                    $idMode = $policy.IntrusionDetection
                }
                elseif ($policy.IntrusionDetection.Mode) {
                    $idMode = $policy.IntrusionDetection.Mode
                }
            }

            # Default to 'Off' if mode cannot be determined
            if ([string]::IsNullOrEmpty($idMode)) {
                $idMode = 'Off'
            }

            $status = if ($idMode -eq 'Deny') {
                'Pass'
            }
            else {
                'Fail'
            }

            # Map intrusion detection mode to user-friendly display values
            $detectionModeDisplay = switch ($idMode) {
                'Deny' { 'Alert and Deny' }
                'Alert' { 'Alert Only' }
                'Off' { 'Disabled' }
                default { $idMode }
            }

            $results += [PSCustomObject]@{
                PolicyName             = $policy.Name
                ResourceGroup          = $policy.ResourceGroupName
                SubscriptionName       = $subContext.Subscription.Name
                SubscriptionId         = $subContext.Subscription.Id
                IntrusionDetectionMode = $detectionModeDisplay
                Status                 = $status
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic Evaluation
    if (-not $results) {
        Write-PSFMessage 'No Azure Firewall policies found. Skipping test.' -Tag Firewall -Level Verbose
        return
    }
    else {
        # Check if all policies have Pass status (Intrusion Detection in Deny mode)
        $passedPolicies = $results | Where-Object { $_.Status -eq 'Pass' }
        $passed = ($passedPolicies.Count -eq $results.Count)

        # --- Markdown Table ---
        $mdInfo = "## Firewall Policies`n`n"
        $mdInfo += "| Check Name | Policy Name | Subscription Name | Subscription id | Status |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :---: |`n"

        $checkName = 'IDPS Inspection is Enabled in Deny Mode on Azure Firewall'
        $uniqueResults = $results | Group-Object -Property PolicyName, SubscriptionId | ForEach-Object { $_.Group[0] }
        foreach ($item in $uniqueResults | Sort-Object SubscriptionId, PolicyName) {
            $mdInfo += "| $checkName | $($item.PolicyName) | $($item.SubscriptionName) | $($item.SubscriptionId) | $($item.Status) |`n"
        }

        #endregion Assessment Logic Evaluation

        #region Report Generation
        Add-ZtTestResultDetail `
            -TestId '25539' `
            -Title 'IDPS Inspection is Enabled in Deny Mode on Azure Firewall' `
            -Status $passed `
            -Result $mdInfo
        #endregion Report Generation
    }
}
