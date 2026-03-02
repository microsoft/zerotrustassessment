<#
.SYNOPSIS
    Validates that workloads are enrolled in Azure Backup with protected items.

.DESCRIPTION
    This test checks whether Azure Backup has protected items enrolled across
    Recovery Services Vaults in the tenant. Having vault configuration without
    enrolled backup items means critical workloads are not actually being backed up,
    leaving the organization vulnerable to data loss from ransomware, accidental
    deletion, or infrastructure failures.

.NOTES
    Test ID: 35051
    Category: Azure Data Security
    Required API: Azure Management API - Recovery Services Backup Protected Items
#>

function Test-Assessment-35051 {
    [ZtTest(
        Category = 'Azure Data Security',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Azure Backup'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 35051,
        Title = "Workloads are enrolled in Azure Backup with active protected items",
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Azure Backup protected items enrollment'

    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Check if any Recovery Services Vaults exist
    $vaultCountQuery = @"
resources
| where type =~ 'microsoft.recoveryservices/vaults'
| summarize Count=count()
"@

    $vaultCount = 0
    try {
        $vaultResult = @(Invoke-ZtAzureResourceGraphRequest -Query $vaultCountQuery)
        if ($vaultResult.Count -gt 0) {
            $vaultCount = $vaultResult[0].Count
        }
    }
    catch {
        Write-PSFMessage "Vault count query failed: $($_.Exception.Message)" -Tag Test -Level Warning
    }

    if ($vaultCount -eq 0) {
        Write-PSFMessage 'No Recovery Services Vaults found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Query protected backup items per subscription
    $argQuery = @"
recoveryservicesresources
| where type =~ 'microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| extend protectionStatus = tostring(properties.protectionStatus)
| extend protectedItemType = tostring(properties.protectedItemType)
| extend lastBackupStatus = tostring(properties.lastBackupStatus)
| extend lastBackupTime = todatetime(properties.lastBackupTime)
| extend sourceResourceId = tostring(properties.sourceResourceId)
| extend sourceResourceName = tostring(split(sourceResourceId, '/')[8])
| extend vaultId = tostring(split(id, '/backupFabrics')[0])
| extend vaultName = tostring(split(vaultId, '/')[8])
| project
    ItemName = name,
    ItemId = id,
    SubscriptionName = subscriptionName,
    SubscriptionId = subscriptionId,
    VaultName = vaultName,
    VaultId = vaultId,
    ProtectionStatus = protectionStatus,
    ItemType = protectedItemType,
    LastBackupStatus = lastBackupStatus,
    LastBackupTime = lastBackupTime,
    SourceResource = sourceResourceName
"@

    $protectedItems = @()
    try {
        $protectedItems = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($protectedItems.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $protectedItems.Count -gt 0

    if ($passed) {
        $healthyCount = @($protectedItems | Where-Object { $_.ProtectionStatus -eq 'Healthy' }).Count
        $testResultMarkdown = "✅ **$($protectedItems.Count)** backup protected item(s) found across **$vaultCount** vault(s). **$healthyCount** item(s) are healthy.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No backup protected items found despite **$vaultCount** Recovery Services Vault(s) existing. Workloads are not enrolled in backup.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($item in $protectedItems | Sort-Object SubscriptionName, VaultName, ItemName) {
        $vaultLink = "https://portal.azure.com/#resource$($item.VaultId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $vaultMd = "[$(Get-SafeMarkdown $item.VaultName)]($vaultLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"
        $statusDisplay = if ($item.ProtectionStatus -eq 'Healthy') { '✅ Healthy' } else { "❌ $($item.ProtectionStatus)" }
        $sourceDisplay = if ($item.SourceResource) { Get-SafeMarkdown $item.SourceResource } else { 'N/A' }
        $typeDisplay = if ($item.ItemType) { Get-SafeMarkdown $item.ItemType } else { 'N/A' }
        $lastBackupDisplay = if ($item.LastBackupStatus -eq 'Completed') { '✅ Completed' } else { "⚠️ $($item.LastBackupStatus)" }

        $tableRows += "| $vaultMd | $subMd | $sourceDisplay | $typeDisplay | $statusDisplay | $lastBackupDisplay |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Vault name | Subscription | Source resource | Item type | Protection status | Last backup |
| :--------- | :----------- | :-------------- | :-------- | :---------------: | :---------: |
{2}

'@
    $reportTitle = 'Backup protected items'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.RecoveryServices%2Fvaults'
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35051'
        Title  = 'Workloads are enrolled in Azure Backup with active protected items'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
