<#
.SYNOPSIS
    Validates Threat intelligence is Enabled in Deny Mode on Azure Firewall.
.DESCRIPTION
    This test validates that Azure Firewall Policies have Threat Intelligence enabled in Deny mode.
    Checks all firewall policies in the subscription and reports their threat intelligence status.
.NOTES
    Test ID: 25537
    Category: Internet Access Control
    Required API: Azure Firewall Policies
#>

function Test-Assessment-25537 {
    [ZtTest(
        Category = 'Internet Access Control',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure_Firewall_Standard','Azure_Firewall_Premium'),
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

    #region Authentication Check
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (!$accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }
    #endregion Authentication Check

    #region Data Collection
    Write-ZtProgress `
        -Activity 'Azure Firewall Threat Intelligence' `
        -Status 'Enumerating Firewall Policies'

    try {
        $policies = Get-AzResource -ResourceType "Microsoft.Network/firewallPolicies" -ErrorAction Stop
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""
    $results = @()

    if (-not $policies) {
        $testResultMarkdown = "No Azure Firewall Policies were found in this subscription."
        Add-ZtTestResultDetail `
            -TestId '25537' `
            -Title 'Threat intelligence is Enabled in Deny Mode on Azure Firewall' `
            -Status $false `
            -Result $testResultMarkdown
        return
    }

    $results = @()

    foreach ($policyResource in $policies) {
        $policy = Get-AzFirewallPolicy `
            -Name $policyResource.Name `
            -ResourceGroupName $policyResource.ResourceGroupName `
            -ErrorAction SilentlyContinue

        $mode = $policy.ThreatIntelMode

        $result = switch ($mode) {
            'Deny'  { '✅ Enabled (Alert and Deny)' }
            'Alert' { '❌ Alert only' }
            'Off'   { '❌ Disabled' }
            default { '❌ Not configured' }
        }

        $results += [PSCustomObject]@{
            PolicyName      = $policy.Name
            ResourceGroup   = $policy.ResourceGroupName
            ThreatIntelMode = $mode
            Result          = $result
        }
    }
    #endregion Data Collection

    #region Assessment Logic Evaluation
    $failedPolicies = $results | Where-Object { $_.ThreatIntelMode -ne 'Deny' }
    $passed = ($failedPolicies.Count -eq 0)

    if ($passed) {
        $testResultMarkdown = "Threat Intelligence is enabled in **Alert and Deny** mode for all Azure Firewall Policies.`n`n%TestResult%"
    } else {
        $testResultMarkdown = "One or more Azure Firewall Policies do **not** have Threat Intelligence enabled in **Alert and Deny** mode.`n`n%TestResult%"
    }
    #endregion Assessment Logic Evaluation

    #region Report Generation
    $mdInfo  = "## Azure Firewall Threat Intelligence Status`n`n"
    $mdInfo += "Policy Name | Resource Group | Threat Intel Mode | Result |`n"
    $mdInfo += "| :--- | :--- | :--- | :---: |`n"

    foreach ($item in $results | Sort-Object PolicyName) {
        $mdInfo += "| $($item.PolicyName) | $($item.ResourceGroup) | $($item.ThreatIntelMode) | $($item.Result) |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    # --- Final result (NO AppliesTo) ---
    Add-ZtTestResultDetail `
        -TestId '25537' `
        -Title 'Azure Firewall Threat Intelligence is enabled in Alert and Deny mode' `
        -Status $passed `
        -Result $testResultMarkdown
}
