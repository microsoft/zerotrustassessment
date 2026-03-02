<#
.SYNOPSIS
    Validates that Azure Storage Accounts have public blob access disabled and network default action set to Deny.

.DESCRIPTION
    This test checks all Storage Accounts across the tenant to verify that anonymous
    public blob access is disabled and the network ACL default action is set to Deny.
    These are core Zero Trust controls ensuring storage is not accessible to the
    public internet by default.

.NOTES
    Test ID: 35044
    Category: Azure Data Security
    Required API: Azure Management API - Storage Accounts
#>

function Test-Assessment-35044 {
    [ZtTest(
        Category = 'Azure Data Security',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Azure Storage'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 35044,
        Title = "Storage Accounts have public access disabled and network rules configured",
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Storage Account public access and network rules'

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
    AllowBlobPublicAccess = tobool(properties.allowBlobPublicAccess),
    NetworkDefaultAction = tostring(properties.networkAcls.defaultAction),
    PublicNetworkAccess = tostring(properties.publicNetworkAccess)
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
        $_.AllowBlobPublicAccess -eq $true -or $_.NetworkDefaultAction -ne 'Deny'
    })

    $passed = $nonCompliant.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Storage Accounts have **public blob access disabled** and **network default action set to Deny**.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Storage Accounts allow **public blob access** or have **permissive network rules**.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($item in $accounts | Sort-Object SubscriptionName, AccountName) {
        $accountLink = "https://portal.azure.com/#resource$($item.AccountId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $accountMd = "[$(Get-SafeMarkdown $item.AccountName)]($accountLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"

        $publicAccessDisplay = if ($item.AllowBlobPublicAccess -ne $true) { '✅ Disabled' } else { '❌ Enabled' }
        $networkDisplay = if ($item.NetworkDefaultAction -eq 'Deny') { '✅ Deny' } else { '❌ Allow' }
        $publicNetworkDisplay = if ($item.PublicNetworkAccess -eq 'Disabled') { '✅ Disabled' } else { $item.PublicNetworkAccess }
        $overallStatus = if ($item.AllowBlobPublicAccess -ne $true -and $item.NetworkDefaultAction -eq 'Deny') { '✅' } else { '❌' }

        $tableRows += "| $accountMd | $subMd | $publicAccessDisplay | $networkDisplay | $publicNetworkDisplay | $overallStatus |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Storage account | Subscription | Public blob access | Network default | Public network | Status |
| :-------------- | :----------- | :----------------: | :-------------: | :------------: | :----: |
{2}

'@
    $reportTitle = 'Storage Account network restrictions'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.Storage%2FStorageAccounts'
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35044'
        Title  = 'Storage Accounts have public access disabled and network rules configured'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
