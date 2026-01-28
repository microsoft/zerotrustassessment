<#
.SYNOPSIS
    Data Loss Prevention (DLP) Policies

.DESCRIPTION
    Data Loss Prevention (DLP) policies protect sensitive information by monitoring, detecting, and preventing the sharing of confidential data across Microsoft 365 workloads including Exchange Online, SharePoint Online, OneDrive, and Microsoft Teams.
    When DLP policies are not enabled or configured, organizations lack automated controls to prevent accidental or intentional disclosure of sensitive information such as credit card numbers, social security numbers, financial data, or proprietary information. Without active DLP policies, employees can freely share sensitive content through email, file uploads, or team communications without organizational oversight, increasing the risk of data breaches, regulatory violations (GDPR, HIPAA, PCI-DSS), and reputational damage. Enabling and configuring at least one DLP policy ensures organizations have automated detection and response capabilities for sensitive data, reducing the risk of unauthorized data exfiltration and demonstrating compliance readiness to regulators and auditors.

.NOTES
    Test ID: 35030
    Pillar: Data
    Risk Level: High
#>

function Test-Assessment-35030 {
    [ZtTest(
        Category = 'Data Loss Prevention (DLP)',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35030,
        Title = 'DLP Policies Enabled',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Data Loss Prevention Policies'
    Write-ZtProgress -Activity $activity -Status 'Querying DLP policies from compliance center'

    $dlpPolicies = $null
    $dlpPoliciesDetailed = $null
    $enabledPoliciesCount = 0
    $errorMsg = $null

    try {
        # Q1: Get all DLP policies in the organization
        $dlpPolicies = Get-DlpCompliancePolicy -ErrorAction Stop

        # Q2: Get details on DLP policy status and rule count
        $dlpPoliciesDetailed = $dlpPolicies | Select-Object -Property Name, Enabled, WhenCreatedUTC, WhenChangedUTC

        # Q3: Count enabled vs disabled DLP policies
        $enabledPoliciesCount = @($dlpPolicies | Where-Object Enabled).Count
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying DLP policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $investigateFlag = $false
    $passed = $false

    if ($errorMsg) {
        $investigateFlag = $true
    }
    else {
        # If enabled policy count >= 1, the test passes
        if ($enabledPoliciesCount -ge 1) {
            $passed = $true
        }
        else {
            # No policies exist or all policies are disabled
            $passed = $false
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ""

    if ($investigateFlag) {
        $testResultMarkdown = "⚠️ Unable to determine DLP policy status due to permissions issues or service connection failure.`n`n"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ One or more DLP policies are enabled and configured, providing automated protection against sensitive data disclosure.`n`n"
        }
        else {
            $testResultMarkdown = "❌ No DLP policies are enabled or no DLP policies exist in the organization.`n`n"
        }

        $testResultMarkdown += "## Data Loss Prevention Policy Summary`n`n"
        $testResultMarkdown += "**Total DLP Policies:** $($dlpPolicies.Count)`n`n"
        $testResultMarkdown += "**Enabled Policies:** $enabledPoliciesCount`n`n"

        if ($dlpPoliciesDetailed.Count -gt 0) {
            $testResultMarkdown += "### DLP Policies Configuration`n`n"
            $testResultMarkdown += "| Policy Name | Enabled Status | Created Date | Last Modified Date |`n"
            $testResultMarkdown += "| :--- | :--- | :--- | :--- |`n"

            foreach ($policy in $dlpPoliciesDetailed) {
                $enabledStatus = if ($policy.Enabled) { "✅ Yes" } else { "❌ No" }
                $createdDate = if ($policy.WhenCreatedUTC) { $policy.WhenCreatedUTC.ToString('yyyy-MM-dd') } else { "N/A" }
                $modifiedDate = if ($policy.WhenChangedUTC) { $policy.WhenChangedUTC.ToString('yyyy-MM-dd') } else { "N/A" }
                $testResultMarkdown += "| $($policy.Name) | $enabledStatus | $createdDate | $modifiedDate |`n"
            }
            $testResultMarkdown += "`n"
        }
    }

    $testResultMarkdown += "[View DLP Policies in Microsoft Purview Portal](https://purview.microsoft.com/datalossprevention/policies)`n"
    #endregion Report Generation

    $params = @{
        TestId = '35030'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($investigateFlag -eq $true) {
        $params.CustomStatus = 'Investigate'
    }
    Add-ZtTestResultDetail @params
}
