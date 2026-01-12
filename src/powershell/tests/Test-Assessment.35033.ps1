<#
.SYNOPSIS
    Validates that custom Sensitive Information Types (SITs) are configured in the organization.

.DESCRIPTION
    This test checks if custom Sensitive Information Types are configured, enabling detection of
    organization-specific sensitive data patterns beyond the built-in SIT library. Custom SITs are
    critical for protecting proprietary data formats and industry-specific information.

.NOTES
    Test ID: 35033
    Category: Advanced Classification
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Security & Compliance PowerShell
#>

function Test-Assessment-35033 {
    [ZtTest(
        Category = 'Advanced Classification',
        ImplementationCost = 'High',
        MinimumLicense = ('Microsoft 365 E5 Compliance'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35033,
        Title = 'Custom Sensitive Information Types (SITs) Configured',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Custom Sensitive Information Types Configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting custom SIT configuration'

    # Get all custom Sensitive Information Types
    $customSITs = $null
    $errorMsg = $null

    try {
        $allSITs = Get-DlpSensitiveInformationType -ErrorAction Stop
        # Filter for custom SITs (Publisher is not "Microsoft Corporation")
        $customSITs = @($allSITs | Where-Object { $_.Publisher -ne 'Microsoft Corporation' })
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve custom SIT configuration: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        # Investigate: Cannot query custom SITs
        $passed = $false
        $customStatus = 'Investigate'
    }
    elseif ($null -eq $customSITs) {
        # Investigate: Cannot determine custom SIT status
        $passed = $false
        $customStatus = 'Investigate'
    }
    elseif ($customSITs.Count -ge 1) {
        # Pass: Custom SITs are configured
        $passed = $true
    }
    else {
        # Fail: No custom SITs configured
        $passed = $false
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''

    if ($customStatus -eq 'Investigate') {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to determine custom SIT status due to permissions issues or service connection failure."
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Custom Sensitive Information Types are configured, enabling detection of organization-specific sensitive data patterns.`n`n"
    }
    else {
        $testResultMarkdown = "❌ No custom Sensitive Information Types are configured; relying solely on built-in SIT patterns.`n`n"
    }

    # Build detailed information if we have data
    if ($customSITs -and $customSITs.Count -gt 0) {
        $testResultMarkdown += "## [Custom Sensitive Information Types](https://purview.microsoft.com/informationprotection/dataclassification/sensinfoTypes)`n`n"
        $testResultMarkdown += "| Name | Description | Publisher |`n"
        $testResultMarkdown += "| :--- | :--- | :--- |`n"

        foreach ($sit in $customSITs | Sort-Object Name) {
            $safeSITName = Get-SafeMarkdown $sit.Name
            $safeDescription = if ($sit.Description) { Get-SafeMarkdown $sit.Description } else { 'Not specified' }
            $safePublisher = if ($sit.Publisher) { Get-SafeMarkdown $sit.Publisher } else { 'Not specified' }

            $testResultMarkdown += "| $safeSITName | $safeDescription | $safePublisher |`n"
        }

        $testResultMarkdown += "`n**Summary:**`n"
        $testResultMarkdown += "* Total Custom SITs: $($customSITs.Count)`n"
    }
    #endregion Report Generation

    $params = @{
        TestId = '35033'
        Title  = 'Custom Sensitive Information Types (SITs) Configured'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
