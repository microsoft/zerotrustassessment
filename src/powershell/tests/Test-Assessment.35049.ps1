<#
.SYNOPSIS
    Validates that NSG Flow Logs are enabled for network traffic analysis.

.DESCRIPTION
    This test checks whether Network Watcher Flow Logs are deployed and enabled
    across the tenant. NSG Flow Logs record information about IP traffic flowing
    through Network Security Groups and are essential for network forensics,
    security investigation, and compliance auditing.

.NOTES
    Test ID: 35049
    Category: Azure Network Security
    Required API: Azure Management API - Network Watcher Flow Logs
#>

function Test-Assessment-35049 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure Virtual Network'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 35049,
        Title = "NSG Flow Logs are enabled for network traffic analysis",
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking NSG Flow Log deployment'

    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Query all flow log resources
    $argQuery = @"
resources
| where type =~ 'microsoft.network/networkwatchers/flowlogs'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| extend flowLogEnabled = tobool(properties.enabled)
| extend targetResourceId = tostring(properties.targetResourceId)
| extend targetResourceName = tostring(split(targetResourceId, '/')[8])
| extend retentionEnabled = tobool(properties.retentionPolicy.enabled)
| extend retentionDays = toint(properties.retentionPolicy.days)
| extend flowAnalyticsEnabled = tobool(properties.flowAnalyticsConfiguration.networkWatcherFlowAnalyticsConfiguration.enabled)
| project
    FlowLogName = name,
    FlowLogId = id,
    SubscriptionName = subscriptionName,
    SubscriptionId = subscriptionId,
    Enabled = flowLogEnabled,
    TargetResourceName = targetResourceName,
    RetentionEnabled = retentionEnabled,
    RetentionDays = retentionDays,
    TrafficAnalytics = flowAnalyticsEnabled
"@

    $flowLogs = @()
    try {
        $flowLogs = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($flowLogs.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Check NSG existence
    $nsgCountQuery = @"
resources
| where type =~ 'microsoft.network/networksecuritygroups'
| summarize Count=count()
"@

    $nsgCount = 0
    try {
        $nsgResult = @(Invoke-ZtAzureResourceGraphRequest -Query $nsgCountQuery)
        if ($nsgResult.Count -gt 0) {
            $nsgCount = $nsgResult[0].Count
        }
    }
    catch {
        Write-PSFMessage "NSG count query failed: $($_.Exception.Message)" -Tag Test -Level Warning
    }

    if ($nsgCount -eq 0) {
        Write-PSFMessage 'No Network Security Groups found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }
    #endregion Check NSG existence

    #region Assessment Logic
    $enabledCount = @($flowLogs | Where-Object { $_.Enabled -eq $true }).Count
    $disabledCount = @($flowLogs | Where-Object { $_.Enabled -ne $true }).Count
    $passed = $flowLogs.Count -gt 0 -and $disabledCount -eq 0

    if ($flowLogs.Count -eq 0) {
        $testResultMarkdown = "❌ No NSG Flow Logs are configured. **$nsgCount** NSG(s) found without flow logging.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ All **$enabledCount** NSG Flow Log(s) are enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ **$disabledCount** of **$($flowLogs.Count)** NSG Flow Log(s) are disabled.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($item in $flowLogs | Sort-Object SubscriptionName, FlowLogName) {
        $flLink = "https://portal.azure.com/#resource$($item.FlowLogId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $flMd = "[$(Get-SafeMarkdown $item.FlowLogName)]($flLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"
        $enabledDisplay = if ($item.Enabled) { '✅ Enabled' } else { '❌ Disabled' }
        $targetDisplay = if ($item.TargetResourceName) { Get-SafeMarkdown $item.TargetResourceName } else { 'N/A' }
        $retentionDisplay = if ($item.RetentionEnabled) { "$($item.RetentionDays) days" } else { '❌ Off' }
        $analyticsDisplay = if ($item.TrafficAnalytics) { '✅ Yes' } else { '❌ No' }

        $tableRows += "| $flMd | $subMd | $targetDisplay | $enabledDisplay | $retentionDisplay | $analyticsDisplay |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Flow log name | Subscription | Target NSG | Status | Retention | Traffic Analytics |
| :------------ | :----------- | :--------- | :----: | :-------: | :---------------: |
{2}

'@
    $reportTitle = 'NSG Flow Log configuration'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FnetworkWatchers%2FflowLogs'
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35049'
        Title  = 'NSG Flow Logs are enabled for network traffic analysis'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
