<#
.SYNOPSIS
    Validates that Microsoft Defender for Cloud is enabled for data services (Storage, SQL, Cosmos DB).

.DESCRIPTION
    This test checks whether Defender for Cloud threat protection plans are enabled
    (Standard tier) for data-related Azure services including Storage Accounts,
    SQL Servers, Cosmos DB, and SQL Server on Virtual Machines. These plans provide
    advanced threat detection, vulnerability assessment, and anomaly detection for
    data workloads.

.NOTES
    Test ID: 35046
    Category: Azure Data Security
    Required API: Azure Management API - Security Pricings
#>

function Test-Assessment-35046 {
    [ZtTest(
        Category = 'Azure Data Security',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft Defender for Cloud'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Detect and respond to threats',
        TenantType = ('Workforce', 'External'),
        TestId = 35046,
        Title = "Defender for Cloud is enabled for data services",
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Defender for Cloud data service plans'

    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Query Defender for Cloud pricing tiers for data-related services
    $argQuery = @"
securityresources
| where type =~ 'microsoft.security/pricings'
| where name in~ ('StorageAccounts', 'SqlServers', 'CosmosDbs', 'SqlServerVirtualMachines', 'OpenSourceRelationalDatabases')
| project
    PlanName = name,
    PlanId = id,
    SubscriptionId = subscriptionId,
    PricingTier = tostring(properties.pricingTier),
    SubPlan = tostring(properties.subPlan),
    FreeTrialRemaining = tostring(properties.freeTrialRemainingTime)
"@

    $plans = @()
    try {
        $plans = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($plans.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($plans.Count -eq 0) {
        Write-PSFMessage 'No Defender for Cloud pricing data found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $nonCompliant = @($plans | Where-Object {
        $_.PricingTier -ne 'Standard'
    })

    $passed = $nonCompliant.Count -eq 0

    # Friendly display names for plan names
    $planDisplayNames = @{
        'StorageAccounts'               = 'Defender for Storage'
        'SqlServers'                    = 'Defender for Azure SQL'
        'CosmosDbs'                     = 'Defender for Cosmos DB'
        'SqlServerVirtualMachines'      = 'Defender for SQL on VMs'
        'OpenSourceRelationalDatabases' = 'Defender for Open-Source DBs'
    }

    if ($passed) {
        $testResultMarkdown = "✅ **Defender for Cloud** is enabled (Standard tier) for all data services.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more **Defender for Cloud** data service plans are not enabled.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($item in $plans | Sort-Object SubscriptionId, PlanName) {
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionId)]($subLink)"
        $displayName = if ($planDisplayNames.ContainsKey($item.PlanName)) { $planDisplayNames[$item.PlanName] } else { $item.PlanName }

        $tierDisplay = if ($item.PricingTier -eq 'Standard') { '✅ Standard' } else { '❌ Free' }
        $subPlanDisplay = if ($item.SubPlan) { $item.SubPlan } else { 'N/A' }
        $overallStatus = if ($item.PricingTier -eq 'Standard') { '✅' } else { '❌' }

        $tableRows += "| $displayName | $subMd | $tierDisplay | $subPlanDisplay | $overallStatus |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Defender plan | Subscription | Pricing tier | Sub-plan | Status |
| :------------ | :----------- | :----------: | :------- | :----: |
{2}

'@
    $reportTitle = 'Defender for Cloud data service plans'
    $portalLink = 'https://portal.azure.com/#blade/Microsoft_Azure_Security/SecurityMenuBlade/pricingTier'
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35046'
        Title  = 'Defender for Cloud is enabled for data services'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
