<#
.SYNOPSIS
    Validates that all Azure Storage Accounts enforce minimum TLS 1.2 and HTTPS-only traffic.

.DESCRIPTION
    This test checks all Storage Accounts across the tenant to verify they enforce
    TLS 1.2 as the minimum transport protocol and require HTTPS for all traffic.
    Using older TLS versions or allowing HTTP exposes data in transit to interception
    and downgrade attacks.

.NOTES
    Test ID: 35043
    Category: Azure Data Security
    Required API: Azure Management API - Storage Accounts
#>

function Test-Assessment-35043 {
    [ZtTest(
        Category = 'Azure Data Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure Storage'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 35043,
        Title = "Storage Accounts enforce minimum TLS 1.2 and HTTPS-only traffic",
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Storage Account TLS and HTTPS settings'

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
| where type =~ 'microsoft.storage/storageaccounts'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    AccountName = name,
    AccountId = id,
    SubscriptionName = subscriptionName,
    SubscriptionId = subscriptionId,
    MinTlsVersion = tostring(properties.minimumTlsVersion),
    HttpsOnly = tobool(properties.supportsHttpsTrafficOnly)
"@

    $accounts = @()
    try {
        $accounts = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($accounts.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($accounts.Count -eq 0) {
        Write-PSFMessage 'No Storage Accounts found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $nonCompliant = @($accounts | Where-Object {
        $_.MinTlsVersion -ne 'TLS1_2' -or $_.HttpsOnly -ne $true
    })

    $passed = $nonCompliant.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Storage Accounts enforce **TLS 1.2** and **HTTPS-only** traffic.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Storage Accounts do not enforce **TLS 1.2** or **HTTPS-only** traffic.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($item in $accounts | Sort-Object SubscriptionName, AccountName) {
        $accountLink = "https://portal.azure.com/#resource$($item.AccountId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $accountMd = "[$(Get-SafeMarkdown $item.AccountName)]($accountLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"

        $tlsDisplay = if ($item.MinTlsVersion -eq 'TLS1_2') { '✅ TLS 1.2' } else { "❌ $($item.MinTlsVersion)" }
        $httpsDisplay = if ($item.HttpsOnly -eq $true) { '✅ Enabled' } else { '❌ Disabled' }
        $overallStatus = if ($item.MinTlsVersion -eq 'TLS1_2' -and $item.HttpsOnly -eq $true) { '✅' } else { '❌' }

        $tableRows += "| $accountMd | $subMd | $tlsDisplay | $httpsDisplay | $overallStatus |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Storage account | Subscription | Min TLS version | HTTPS only | Status |
| :-------------- | :----------- | :-------------: | :--------: | :----: |
{2}

'@
    $reportTitle = 'Storage Account encryption in transit'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.Storage%2FStorageAccounts'
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35043'
        Title  = 'Storage Accounts enforce minimum TLS 1.2 and HTTPS-only traffic'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
