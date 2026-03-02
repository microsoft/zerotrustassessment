<#
.SYNOPSIS
    Validates that all Azure Key Vaults have soft-delete and purge protection enabled.

.DESCRIPTION
    This test checks if all Azure Key Vaults in the tenant have soft-delete enabled
    and purge protection configured. Without these safeguards, accidental or malicious
    deletion of Key Vaults can result in permanent loss of cryptographic keys,
    certificates, and secrets, potentially causing widespread service outages.

.NOTES
    Test ID: 35041
    Category: Azure Network Security
    Required API: Azure Management API - Key Vaults
#>

function Test-Assessment-35041 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure Key Vault'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 35041,
        Title = 'Key Vaults have soft-delete and purge protection enabled',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Key Vault soft-delete and purge protection'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Query all Key Vaults with their soft-delete and purge protection settings
    $argQuery = @"
resources
| where type =~ 'microsoft.keyvault/vaults'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    VaultName = name,
    VaultId = id,
    SubscriptionName = subscriptionName,
    SubscriptionId = subscriptionId,
    Location = location,
    SoftDeleteEnabled = tobool(properties.enableSoftDelete),
    PurgeProtectionEnabled = tobool(properties.enablePurgeProtection),
    SoftDeleteRetentionDays = toint(properties.softDeleteRetentionInDays)
"@

    $vaults = @()
    try {
        $vaults = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($vaults.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Skip test if no Key Vaults found
    if ($vaults.Count -eq 0) {
        Write-PSFMessage 'No Key Vaults found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Check if all vaults have both soft-delete and purge protection enabled
    $nonCompliantVaults = @($vaults | Where-Object {
        $_.SoftDeleteEnabled -ne $true -or $_.PurgeProtectionEnabled -ne $true
    })

    $passed = $nonCompliantVaults.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Key Vaults have **soft-delete** and **purge protection** enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Key Vaults do not have **soft-delete** or **purge protection** enabled.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Table title
    $reportTitle = 'Key Vault recovery protection'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.KeyVault%2Fvaults'

    # Prepare table rows
    $tableRows = ''
    foreach ($item in $vaults | Sort-Object SubscriptionName, VaultName) {
        $vaultLink = "https://portal.azure.com/#resource$($item.VaultId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $vaultMd = "[$(Get-SafeMarkdown $item.VaultName)]($vaultLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"

        # Calculate status indicators
        $softDeleteDisplay = if ($item.SoftDeleteEnabled -eq $true) { '✅ Enabled' } else { '❌ Disabled' }
        $purgeProtectionDisplay = if ($item.PurgeProtectionEnabled -eq $true) { '✅ Enabled' } else { '❌ Disabled' }
        $retentionDisplay = if ($item.SoftDeleteRetentionDays) { "$($item.SoftDeleteRetentionDays) days" } else { 'N/A' }
        $overallStatus = if ($item.SoftDeleteEnabled -eq $true -and $item.PurgeProtectionEnabled -eq $true) { '✅' } else { '❌' }

        $tableRows += "| $vaultMd | $subMd | $softDeleteDisplay | $purgeProtectionDisplay | $retentionDisplay | $overallStatus |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Vault name | Subscription | Soft-delete | Purge protection | Retention | Status |
| :--------- | :----------- | :---------: | :--------------: | :-------: | :----: |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35041'
        Title  = 'Key Vaults have soft-delete and purge protection enabled'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
