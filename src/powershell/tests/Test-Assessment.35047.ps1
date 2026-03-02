<#
.SYNOPSIS
    Validates that Recovery Services Vaults have immutability and soft-delete enabled.

.DESCRIPTION
    This test checks all Recovery Services Vaults across the tenant to verify that
    immutability settings and soft-delete are enabled. These are critical ransomware
    resilience controls that prevent attackers from deleting or modifying backup data
    even with compromised admin credentials.

.NOTES
    Test ID: 35047
    Category: Azure Data Security
    Required API: Azure Management API - Recovery Services Vaults
#>

function Test-Assessment-35047 {
    [ZtTest(
        Category = 'Azure Data Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure Backup'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 35047,
        Title = "Recovery Services Vaults have immutability and soft-delete enabled",
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Recovery Services Vault immutability and soft-delete'

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
| where type =~ 'microsoft.recoveryservices/vaults'
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
    ImmutabilityState = tostring(properties.securitySettings.immutabilitySettings.state),
    SoftDeleteState = tostring(properties.securitySettings.softDeleteSettings.softDeleteState),
    SoftDeleteRetentionDays = toint(properties.securitySettings.softDeleteSettings.softDeleteRetentionPeriodInDays)
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
    if ($vaults.Count -eq 0) {
        Write-PSFMessage 'No Recovery Services Vaults found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # A vault is compliant if immutability is enabled (Enabled or Locked) and soft-delete is enabled
    $nonCompliant = @($vaults | Where-Object {
        ($_.ImmutabilityState -ne 'Enabled' -and $_.ImmutabilityState -ne 'Locked') -or
        ($_.SoftDeleteState -ne 'Enabled' -and $_.SoftDeleteState -ne 'AlwaysOn')
    })

    $passed = $nonCompliant.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Recovery Services Vaults have **immutability** and **soft-delete** enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Recovery Services Vaults do not have **immutability** or **soft-delete** enabled.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($item in $vaults | Sort-Object SubscriptionName, VaultName) {
        $vaultLink = "https://portal.azure.com/#resource$($item.VaultId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $vaultMd = "[$(Get-SafeMarkdown $item.VaultName)]($vaultLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"

        $immutabilityDisplay = if ($item.ImmutabilityState -in @('Enabled', 'Locked')) { "✅ $($item.ImmutabilityState)" } else { "❌ $($item.ImmutabilityState)" }
        $softDeleteDisplay = if ($item.SoftDeleteState -in @('Enabled', 'AlwaysOn')) { "✅ $($item.SoftDeleteState)" } else { "❌ $($item.SoftDeleteState)" }
        $retentionDisplay = if ($item.SoftDeleteRetentionDays) { "$($item.SoftDeleteRetentionDays) days" } else { 'N/A' }
        $isCompliant = ($item.ImmutabilityState -in @('Enabled', 'Locked')) -and ($item.SoftDeleteState -in @('Enabled', 'AlwaysOn'))
        $overallStatus = if ($isCompliant) { '✅' } else { '❌' }

        $tableRows += "| $vaultMd | $subMd | $immutabilityDisplay | $softDeleteDisplay | $retentionDisplay | $overallStatus |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| Vault name | Subscription | Immutability | Soft-delete | Retention | Status |
| :--------- | :----------- | :----------: | :---------: | :-------: | :----: |
{2}

'@
    $reportTitle = 'Recovery Services Vault protection'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.RecoveryServices%2Fvaults'
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35047'
        Title  = 'Recovery Services Vaults have immutability and soft-delete enabled'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
