<#
.SYNOPSIS
    Validates that all Azure SQL Servers have Microsoft Entra ID-only authentication enabled.

.DESCRIPTION
    This test checks all Azure SQL Servers to verify that Entra ID-only authentication
    is enabled, eliminating SQL authentication with shared passwords. This enforces
    identity-based access with MFA, conditional access, and centralized lifecycle
    management — core Zero Trust principles.

.NOTES
    Test ID: 35045
    Category: Azure Data Security
    Required API: Azure Management API - SQL Servers
#>

function Test-Assessment-35045 {
    [ZtTest(
        Category = 'Azure Data Security',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Azure SQL Database'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce', 'External'),
        TestId = 35045,
        Title = "Azure SQL Servers have Entra ID-only authentication enabled",
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Azure SQL Server Entra ID-only authentication'

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
| where type =~ 'microsoft.sql/servers'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    ServerName = name,
    ServerId = id,
    SubscriptionName = subscriptionName,
    SubscriptionId = subscriptionId,
    EntraOnlyAuth = tobool(properties.administrators.azureADOnlyAuthentication),
    EntraAdminLogin = tostring(properties.administrators.login),
    EntraAdminType = tostring(properties.administrators.administratorType)
"@

    $servers = @()
    try {
        $servers = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($servers.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($servers.Count -eq 0) {
        Write-PSFMessage 'No Azure SQL Servers found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $nonCompliant = @($servers | Where-Object {
        $_.EntraOnlyAuth -ne $true
    })

    $passed = $nonCompliant.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Azure SQL Servers have **Entra ID-only authentication** enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure SQL Servers allow **SQL authentication** in addition to Entra ID.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($item in $servers | Sort-Object SubscriptionName, ServerName) {
        $serverLink = "https://portal.azure.com/#resource$($item.ServerId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $serverMd = "[$(Get-SafeMarkdown $item.ServerName)]($serverLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"

        $authDisplay = if ($item.EntraOnlyAuth -eq $true) { '✅ Entra ID only' } else { '❌ SQL auth allowed' }
        $adminDisplay = if ($item.EntraAdminLogin) { Get-SafeMarkdown $item.EntraAdminLogin } else { '⚠️ Not configured' }
        $overallStatus = if ($item.EntraOnlyAuth -eq $true) { '✅' } else { '❌' }

        $tableRows += "| $serverMd | $subMd | $authDisplay | $adminDisplay | $overallStatus |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| SQL Server | Subscription | Authentication | Entra admin | Status |
| :--------- | :----------- | :------------: | :---------- | :----: |
{2}

'@
    $reportTitle = 'Azure SQL Server authentication'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.Sql%2Fservers'
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35045'
        Title  = 'Azure SQL Servers have Entra ID-only authentication enabled'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
