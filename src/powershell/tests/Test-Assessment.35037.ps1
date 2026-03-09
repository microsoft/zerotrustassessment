<#
.SYNOPSIS
    Purview audit logging is enabled
#>

function Test-Assessment-35037 {
    [ZtTest(
        Category = 'Data Security Posture Management',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce','External'),
        TestId = 35037,
        Title = 'Purview audit logging is enabled',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Purview audit logging configuration'

    # Query Q1: Get unified audit logging configuration
    Write-ZtProgress -Activity $activity -Status 'Getting audit log configuration'

    $errorMsg = $null
    $auditConfig = $null

    try {
        $auditConfig = Get-AdminAuditLogConfig -ErrorAction Stop
        Write-PSFMessage "Retrieved audit log configuration" -Level Verbose
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying audit log configuration: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($errorMsg -or -not $auditConfig) {
        Write-PSFMessage 'Not connected to Exchange Online.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedExchange
        return
    }

    $passed = $false

    if ($auditConfig.UnifiedAuditLogIngestionEnabled -eq $true) {
        $passed = $true
        $testResultMarkdown = "✅ Purview Audit Logging is ENABLED and all activities across Microsoft 365 services are being captured and logged for investigation and compliance purposes.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ Purview Audit Logging is DISABLED, creating a critical visibility gap where unauthorized access, policy violations, and security incidents cannot be detected or investigated.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Show audit configuration only if we have data
    if ($null -ne $auditConfig) {
        $mdInfo += "`n`n### [Audit logging status](https://purview.microsoft.com/audit)`n"
        $mdInfo += "| Configuration property | Value |`n"
        $mdInfo += "| :--- | :--- |`n"

        $auditStatus = $auditConfig.UnifiedAuditLogIngestionEnabled
        $ageLimit = if ($auditConfig.AdminAuditLogAgeLimit) { $auditConfig.AdminAuditLogAgeLimit } else { 'Not configured' }
        $organizationId = if ($auditConfig.OrganizationId) { Get-SafeMarkdown -Text $auditConfig.OrganizationId } else { 'N/A' }

        $mdInfo += "| Unified audit log ingestion enabled | $auditStatus |`n"
        $mdInfo += "| Audit log age limit | $ageLimit |`n"
        $mdInfo += "| Organization ID | $organizationId |"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35037'
        Title  = 'Purview audit logging enabled'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
