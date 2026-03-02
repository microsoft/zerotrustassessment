<#
.SYNOPSIS
    Validates that Private Endpoints are deployed for PaaS network isolation.

.DESCRIPTION
    This test checks whether Azure Private Endpoints are deployed across the tenant
    to securely connect to PaaS services over a private network link. Private Endpoints
    eliminate exposure of services to the public internet and are a foundational
    Zero Trust network isolation control.

.NOTES
    Test ID: 35048
    Category: Azure Network Security
    Required API: Azure Management API - Private Endpoints
#>

function Test-Assessment-35048 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Azure Virtual Network'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 35048,
        Title = "Private Endpoints are deployed for PaaS service network isolation",
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Private Endpoint deployment for PaaS services'

    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    $argQuery = @"
resources
| where type =~ 'microsoft.network/privateendpoints'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| extend connectionStatus = tostring(properties.privateLinkServiceConnections[0].properties.privateLinkServiceConnectionState.status)
| extend targetResource = tostring(properties.privateLinkServiceConnections[0].properties.privateLinkServiceId)
| extend targetResourceType = tostring(split(targetResource, '/')[6])
| extend targetResourceName = tostring(split(targetResource, '/')[8])
| project
    EndpointName = name,
    EndpointId = id,
    SubscriptionName = subscriptionName,
    SubscriptionId = subscriptionId,
    ResourceGroup = resourceGroup,
    ConnectionStatus = connectionStatus,
    TargetResourceType = targetResourceType,
    TargetResourceName = targetResourceName
"@

    $endpoints = @()
    try {
        $endpoints = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($endpoints.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $endpoints.Count -gt 0

    if ($passed) {
        $approvedCount = @($endpoints | Where-Object { $_.ConnectionStatus -eq 'Approved' }).Count
        $testResultMarkdown = "✅ **$($endpoints.Count)** Private Endpoint(s) found (**$approvedCount** approved). PaaS services are using private network connectivity.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No Private Endpoints found. PaaS services may be exposed to the public internet without network isolation.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($item in $endpoints | Sort-Object SubscriptionName, EndpointName) {
        $epLink = "https://portal.azure.com/#resource$($item.EndpointId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $epMd = "[$(Get-SafeMarkdown $item.EndpointName)]($epLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"
        $statusDisplay = if ($item.ConnectionStatus -eq 'Approved') { "✅ Approved" } else { "❌ $($item.ConnectionStatus)" }
        $targetDisplay = if ($item.TargetResourceName) { Get-SafeMarkdown $item.TargetResourceName } else { 'N/A' }
        $typeDisplay = if ($item.TargetResourceType) { Get-SafeMarkdown $item.TargetResourceType } else { 'N/A' }

        $tableRows += "| $epMd | $subMd | $typeDisplay | $targetDisplay | $statusDisplay |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Endpoint name | Subscription | Target type | Target resource | Connection status |
| :------------ | :----------- | :---------- | :-------------- | :---------------: |
{2}

'@
    $reportTitle = 'Private Endpoint deployment'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FprivateEndpoints'
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35048'
        Title  = 'Private Endpoints are deployed for PaaS service network isolation'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
