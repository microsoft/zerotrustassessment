<#
.SYNOPSIS
    Validates that Storage Accounts have encryption at rest enabled for blob services.

.DESCRIPTION
    This test checks all Storage Accounts across the tenant to verify that blob
    encryption at rest is enabled. While Azure enables encryption by default for
    new accounts, older accounts or accounts with modified configurations may have
    encryption disabled, leaving stored data vulnerable to unauthorized access.

.NOTES
    Test ID: 35050
    Category: Azure Data Security
    Required API: Azure Management API - Storage Accounts
#>

function Test-Assessment-35050 {
    [ZtTest(
        Category = 'Azure Data Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure Storage'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 35050,
        Title = "Storage Accounts have encryption at rest enabled for blob services",
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Storage Account encryption at rest'

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
| extend blobEncrypted = tobool(properties.encryption.services.blob.enabled)
| extend fileEncrypted = tobool(properties.encryption.services.file.enabled)
| extend keySource = tostring(properties.encryption.keySource)
| project
    AccountName = name,
    AccountId = id,
    SubscriptionName = subscriptionName,
    SubscriptionId = subscriptionId,
    BlobEncrypted = blobEncrypted,
    FileEncrypted = fileEncrypted,
    KeySource = keySource
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

    $nonCompliant = @($accounts | Where-Object { $_.BlobEncrypted -ne $true })
    $passed = $nonCompliant.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All **$($accounts.Count)** Storage Account(s) have blob encryption at rest enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ **$($nonCompliant.Count)** of **$($accounts.Count)** Storage Account(s) do not have blob encryption at rest enabled.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($item in $accounts | Sort-Object SubscriptionName, AccountName) {
        $acctLink = "https://portal.azure.com/#resource$($item.AccountId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $acctMd = "[$(Get-SafeMarkdown $item.AccountName)]($acctLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"
        $blobDisplay = if ($item.BlobEncrypted) { '✅ Enabled' } else { '❌ Disabled' }
        $fileDisplay = if ($item.FileEncrypted) { '✅ Enabled' } else { '❌ Disabled' }
        $keyDisplay = if ($item.KeySource -eq 'Microsoft.Keyvault') { '🔑 Customer-managed' } else { '🔐 Microsoft-managed' }

        $tableRows += "| $acctMd | $subMd | $blobDisplay | $fileDisplay | $keyDisplay |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Storage account | Subscription | Blob encryption | File encryption | Key source |
| :-------------- | :----------- | :-------------: | :-------------: | :--------- |
{2}

'@
    $reportTitle = 'Storage Account encryption at rest'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.Storage%2FStorageAccounts'
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35050'
        Title  = 'Storage Accounts have encryption at rest enabled for blob services'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
