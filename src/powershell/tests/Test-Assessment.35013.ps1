<#
.SYNOPSIS
    Validates that at least one encryption-enabled sensitivity label is configured.

.DESCRIPTION
    This test checks if at least one sensitivity label has encryption enabled. Encryption-enabled labels
    apply Azure Rights Management protection to documents and emails, enforcing access controls that
    persist with the content regardless of where it is stored or shared.

.NOTES
    Test ID: 35013
    Category: Data
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Exchange Online (Security & Compliance Center)
#>

function Test-Assessment-35013 {
    [ZtTest(
        Category = 'Data',
        ImplementationCost = 'Medium',
        MinimumLicense = 'Microsoft_365_E3',
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce', 'External'),
        TestId = 35013,
        Title = 'Encryption-enabled sensitivity labels are configured',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage 'Start Encryption-Enabled Labels evaluation' -Tag Test -Level VeryVerbose

    $activity = 'Checking Encryption-Enabled Labels'
    Write-ZtProgress -Activity $activity -Status 'Getting sensitivity labels'

    # Q1: Retrieve all sensitivity labels
    try {
        $labels = Get-Label -ErrorAction Stop
    }
    catch {
        Write-PSFMessage "Failed to retrieve sensitivity labels: $_" -Tag Test -Level Warning
        
        $params = @{
            TestId = '35013'
            Title  = 'Encryption-enabled sensitivity labels are configured'
            Status = $false
            Result = "❌ Unable to retrieve sensitivity labels. Ensure you are connected to Exchange Online Security & Compliance Center.`n`nError: $_"
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q2: Filter for encryption-enabled labels
    $encryptionEnabledLabels = $labels | Where-Object { $_.EncryptionEnabled -eq $true }
    
    # Q3: Check if any labels have null/undefined EncryptionEnabled property
    $undeterminedLabels = $labels | Where-Object { $null -eq $_.EncryptionEnabled }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    # Investigate: Cannot determine encryption configuration
    if ($undeterminedLabels.Count -gt 0 -and $encryptionEnabledLabels.Count -eq 0) {
        $passed = $true
        $customStatus = 'Investigate'
    }
    # Pass: At least one encryption-enabled label exists
    elseif ($encryptionEnabledLabels.Count -ge 1) {
        $passed = $true
    }
    # Fail: No encryption-enabled labels exist
    else {
        $passed = $false
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''

    if ($customStatus -eq 'Investigate') {
        $testResultMarkdown = "⚠️ Labels exist but encryption configuration cannot be determined`n`n"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ At least one encryption-enabled sensitivity label is configured`n`n"
    }
    else {
        $testResultMarkdown = "❌ No encryption-enabled labels exist; all labels provide classification only`n`n"
    }

    # Build detailed information
    $mdInfo = "## Summary`n`n"
    $mdInfo += "- **Total Sensitivity Labels**: $($labels.Count)`n"
    $mdInfo += "- **Encryption-Enabled Labels**: $($encryptionEnabledLabels.Count)`n"
    
    if ($undeterminedLabels.Count -gt 0) {
        $mdInfo += "- **Labels with Undetermined Encryption**: $($undeterminedLabels.Count)`n"
    }
    
    $mdInfo += "`n"

    if ($encryptionEnabledLabels.Count -gt 0) {
        $mdInfo += "## Encryption-Enabled Labels`n`n"
        $mdInfo += "| Label name | Enabled | Content type |`n"
        $mdInfo += "| :--------- | :------ | :----------- |`n"

        foreach ($label in ($encryptionEnabledLabels | Sort-Object DisplayName)) {
            $enabledStatus = if ($label.Disabled -eq $false) { '✅ Yes' } else { '❌ No' }
            $contentType = if ($label.ContentType) { $label.ContentType -join ', ' } else { 'All' }
            
            $mdInfo += "| $(Get-SafeMarkdown $label.DisplayName) | $enabledStatus | $contentType |`n"
        }
        $mdInfo += "`n"
    }

    if ($undeterminedLabels.Count -gt 0) {
        $mdInfo += "## Labels with Undetermined Encryption Configuration`n`n"
        $mdInfo += "| Label name | Enabled | Content type |`n"
        $mdInfo += "| :--------- | :------ | :----------- |`n"

        foreach ($label in ($undeterminedLabels | Sort-Object DisplayName)) {
            $enabledStatus = if ($label.Disabled -eq $false) { '✅ Yes' } else { '❌ No' }
            $contentType = if ($label.ContentType) { $label.ContentType -join ', ' } else { 'All' }
            
            $mdInfo += "| $(Get-SafeMarkdown $label.DisplayName) | $enabledStatus | $contentType |`n"
        }
        $mdInfo += "`n⚠️ These labels have null or undefined EncryptionEnabled property. Verify encryption configuration manually.`n`n"
    }

    if ($encryptionEnabledLabels.Count -eq 0 -and $undeterminedLabels.Count -eq 0) {
        $mdInfo += "⚠️ **Recommendation**: Create at least one sensitivity label with encryption enabled to protect high-value data.`n`n"
        $mdInfo += "Encryption ensures that only authorized users and applications can decrypt content, preventing data exfiltration even if files are leaked, stolen, or improperly shared.`n"
    }

    $testResultMarkdown += $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35013'
        Title  = 'Encryption-enabled sensitivity labels are configured'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
