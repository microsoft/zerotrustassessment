<#
.SYNOPSIS
    Endpoint Data Loss Prevention (DLP) Policies

.DESCRIPTION
    Endpoint Data Loss Prevention (Endpoint DLP) extends data protection from cloud workloads (Exchange, SharePoint, OneDrive, Teams) to user devices (Windows, macOS, Linux), creating comprehensive coverage for sensitive data across the entire organization. Endpoint DLP monitors and controls sensitive data activities on employee devices, preventing unauthorized data transfer to cloud storage, USB drives, printers, external applications, and removable media. Without Endpoint DLP policies configured, organizations have visibility and control only over cloud-based activities, leaving sensitive data vulnerable when accessed from user devices or transferred to unmanaged applications. Endpoint DLP policies integrate with Defender for Endpoint to provide rich telemetry about data handling activities, enabling organizations to detect and respond to data exfiltration attempts in real time. For organizations handling highly sensitive data (trade secrets, financial records, PII, healthcare information), Endpoint DLP is critical to preventing data loss through user devices and uncontrolled applications. Configuring at least one Endpoint DLP policy targeting critical sensitive information types (financial data, trade secrets, customer PII) ensures defense-in-depth protection that extends beyond cloud workloads.

.NOTES
    Test ID: 35031
    Pillar: Data
    Risk Level: High
#>

function Test-Assessment-35031 {
    [ZtTest(
        Category = 'Data Loss Prevention (DLP)',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35031,
        Title = 'DLP Policies Endpoint Workloads',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Endpoint Data Loss Prevention Policies'
    Write-ZtProgress -Activity $activity -Status 'Querying endpoint DLP policies from compliance center'

    $dlpPolicies = $null
    $dlpPoliciesDetailed = $null
    $endpointDlpPolicies = $null
    $enabledEndpointPoliciesCount = 0
    $errorMsg = $null

    try {
        # Q1: Get all DLP compliance policies
        $dlpPolicies = Get-DlpCompliancePolicy -ErrorAction Stop

        # Q2: Filter for endpoint DLP policies
        $endpointDlpPolicies = $dlpPolicies | Where-Object { $_.EndpointDlpLocation -ne $null }

        # Q3: Count enabled endpoint DLP policies
        $enabledEndpointPoliciesCount = @($endpointDlpPolicies | Where-Object { $_.Enabled -eq $true }).Count

        # Get details on endpoint DLP policy status and rules
        $dlpPoliciesDetailed = $endpointDlpPolicies | Select-Object -Property Name, Enabled, WhenCreatedUTC, WhenChangedUTC, EndpointDlpLocation, EndpointDlpRules
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
        # If enabled endpoint DLP policy count >= 1, the test passes
        if ($enabledEndpointPoliciesCount -ge 1) {
            $passed = $true
        }
        else {
            # No endpoint policies exist or all endpoint policies are disabled
            $passed = $false
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ""

    if ($investigateFlag) {
        $testResultMarkdown = "⚠️ Unable to determine Endpoint DLP policy configuration due to permissions issues or service connection failure.`n`n"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ Endpoint DLP policies are configured and enabled, protecting sensitive data on user devices.`n`n"
        }
        else {
            $testResultMarkdown = "❌ No Endpoint DLP policies are configured, or all endpoint policies are disabled.`n`n"
        }

        $testResultMarkdown += "## Endpoint DLP Policy Summary`n`n"
        $testResultMarkdown += "**Total DLP Policies:** $($dlpPolicies.Count)`n`n"
        $testResultMarkdown += "**Endpoint DLP Policies:** $($endpointDlpPolicies.Count)`n`n"
        $testResultMarkdown += "**Enabled Endpoint Policies:** $enabledEndpointPoliciesCount`n`n"

        if ($endpointDlpPolicies.Count -gt 0) {
            $testResultMarkdown += "### Endpoint DLP Policies Configuration`n`n"

            foreach ($policy in $dlpPoliciesDetailed) {
                $enabledStatus = if ($policy.Enabled) { "✅ Enabled" } else { "❌ Disabled" }
                $endpointLocations = if ($policy.EndpointDlpLocation) { ($policy.EndpointDlpLocation -join ', ') } else { "None" }
                $rulesCount = if ($policy.EndpointDlpRules) { @($policy.EndpointDlpRules).Count } else { 0 }
                $createdDate = if ($policy.WhenCreatedUTC) { $policy.WhenCreatedUTC.ToString('yyyy-MM-dd') } else { "N/A" }

                $testResultMarkdown += "#### $($policy.Name)`n`n"
                $testResultMarkdown += "* **Enabled Status:** $enabledStatus`n"
                $testResultMarkdown += "* **Endpoint Locations:** $endpointLocations`n"
                $testResultMarkdown += "* **Associated Rules Count:** $rulesCount`n"
                $testResultMarkdown += "* **Created Date:** $createdDate`n`n"
            }
        }
        else {
            $testResultMarkdown += "### Endpoint DLP Policies Configuration`n`n"
            $testResultMarkdown += "No endpoint DLP policies are currently configured in the organization. Organizations should configure at least one endpoint DLP policy protecting critical sensitive data types (financial records, trade secrets, PII).`n`n"
        }
    }

    $testResultMarkdown += "[View DLP Policies in Microsoft Purview Portal](https://purview.microsoft.com/datalossprevention/policies)`n"
    #endregion Report Generation

    $params = @{
        TestId = '35031'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($investigateFlag -eq $true) {
        $params.CustomStatus = 'Investigate'
    }
    Add-ZtTestResultDetail @params
}
