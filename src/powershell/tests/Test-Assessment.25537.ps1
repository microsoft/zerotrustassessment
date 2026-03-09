
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
    $activity = 'Azure Firewall Threat Intelligence'
    Write-ZtProgress  -Activity $activity -Status 'Enumerating Firewall Policies'

    $context = Get-AzContext
    if (($context).Environment.name -ne 'AzureCloud') {
        Write-PSFMessage "This test is only applicable to the Global environment." -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (-not $accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause 'NotConnectedAzure'
        return
    }

    $argQuery = @"
Resources
| where type =~ 'microsoft.network/firewallpolicies'
| where tostring(properties.sku.tier) in ('Standard', 'Premium')
| join kind=leftouter (ResourceContainers | where type =~ 'microsoft.resources/subscriptions' | project subscriptionName=name, subscriptionId) on subscriptionId
| project PolicyName=name, SubscriptionName=subscriptionName, SubscriptionId=subscriptionId, ThreatIntelMode=tostring(properties.threatIntelMode), PolicyID=id
"@

    $results = @()
    try {
        Write-ZtProgress -Activity $activity -Status "Querying Azure Resource Graph"
        $results = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)

        Write-PSFMessage "ARG Query returned $($results.Count) records" -Tag Test -Level VeryVerbose

        # Normalize null/empty ThreatIntelMode to "Unknown"
        foreach ($row in $results) {
            if ([string]::IsNullOrWhiteSpace($row.ThreatIntelMode)) { $row.ThreatIntelMode = 'Unknown' }
        }
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    if ($results.Count -eq 0) {
        Write-PSFMessage "No firewall policies found." -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic

    $passed = ($results | Where-Object { $_.ThreatIntelMode -ne 'Deny' }).Count -eq 0
    $allAlert = ($results | Where-Object { $_.ThreatIntelMode -ne 'Alert' }).Count -eq 0

    if ($passed) {
        $testResultMarkdown = "Threat Intel is enabled in **Alert and Deny** mode.`n`n%TestResult%"
    }
    elseif ($allAlert) {
        $testResultMarkdown = "Threat Intel is enabled in **Alert** mode.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Threat Intel is not enabled in **Alert and Deny** mode for all Firewall policies.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $reportTitle = "Firewall policies"
    $tableRows = ""

    $formatTemplate = @'

## {0}

| Policy name | Subscription name | Threat Intel mode | Result |
| :---------- | :---------------- | :---------------- | :----- |
{1}

'@

    foreach ($item in $results | Sort-Object PolicyName) {

        $policyLink = "https://portal.azure.com/#resource$($item.PolicyID)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"

        $policyName = Get-SafeMarkdown -Text $item.PolicyName
        $subName = Get-SafeMarkdown -Text $item.SubscriptionName

        if ($item.ThreatIntelMode -eq 'Deny') {
            $icon = '✅'
        }
        else {
            $icon = '❌'
        }

        $tableRows += "| [$policyName]($policyLink) | [$subName]($subLink) | $($item.ThreatIntelMode) | $icon |`n"
    }

    $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25537'
        Title  = 'Threat intelligence is Enabled in Deny Mode on Azure Firewall'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
