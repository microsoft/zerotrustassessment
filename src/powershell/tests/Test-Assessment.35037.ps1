<#
.SYNOPSIS
    Purview Audit Logging Enabled
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
        Title = 'Purview audit logging enabled',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Purview audit logging configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting audit log configuration'

    # Query Q1: Check if unified audit logging is enabled
    $auditConfig = Get-AdminAuditLogConfig

    Write-PSFMessage "Retrieved audit log configuration " -Level Verbose
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Determine pass/fail status based on UnifiedAuditLogIngestionEnabled
    if ($auditConfig.UnifiedAuditLogIngestionEnabled -eq $true) {
        $passed = $true
        $testResultMarkdown = "✅ Purview audit logging is enabled and all activities across Microsoft 365 services are being captured and logged for investigation and compliance purposes.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ Purview audit logging is disabled, creating a critical visibility gap where unauthorized access, policy violations, and security incidents cannot be detected or investigated.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Show audit configuration
    $mdInfo += "`n`n### [Audit logging status](https://purview.microsoft.com/audit)`n"
    $mdInfo += "| Configuration property | Value |`n"
    $mdInfo += "| :--- | :--- |`n"

    $auditStatus = $auditConfig.UnifiedAuditLogIngestionEnabled
    $ageLimit = if ($auditConfig.AdminAuditLogAgeLimit) { $auditConfig.AdminAuditLogAgeLimit } else { 'Not configured' }
    $organization = if ($auditConfig.OrganizationalUnitRoot) { Get-SafeMarkdown -Text $auditConfig.OrganizationalUnitRoot } else { 'N/A' }

    $mdInfo += "| Unified audit log ingestion enabled | $auditStatus |`n"
    $mdInfo += "| Audit log age limit | $ageLimit |`n"
    $mdInfo += "| Organization | $organization |"

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
