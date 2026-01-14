<#
.SYNOPSIS
    Insider Risk Management Policies Enabled for Risky AI Usage

.DESCRIPTION
    Insider Risk Management (IRM) policies with Adaptive Protection enable organizations to detect and prevent risky behavior involving sensitive data, including unauthorized sharing with external parties, mass downloads, unusual data access patterns, and data exfiltration attempts. Without IRM policies configured and enabled with Adaptive Protection integration (`OptInDrpForDlp`), organizations cannot identify insider threats or malicious actors who abuse legitimate access to exfiltrate data. IRM policies that integrate with Data Loss Prevention (DLP) create a comprehensive detection system that combines behavioral indicators (unusual access patterns) with policy-based content detection (sensitive data types), enabling rapid response to insider threats before data is compromised. Organizations must enable at least one IRM policy with Adaptive Protection enabled to detect and mitigate insider risk, including risky AI usage scenarios where users attempt to expose sensitive data to large language models or unauthorized cloud AI services. Without IRM policies, organizations cannot meet insider threat management requirements or demonstrate proactive threat detection capabilities to regulators.

.NOTES
    Test ID: 35038
    Pillar: Data
    Risk Level: High
    Category: Data Security Posture Management
#>

function Test-Assessment-35038 {
    [ZtTest(
        Category = 'Data Security Posture Management',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35038,
        Title = 'Insider Risk Management Policies Enabled for Risky AI Usage',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Getting all Insider Risk Management policies'
    Write-ZtProgress -Activity $activity -Status 'Getting Insider Risk Management Policies'

    $irmPolicies = $null
    $adaptiveProtectionEnabledPolicies = $null

    try {
        $irmPolicies = Get-InsiderRiskPolicy -ErrorAction Stop | Select-Object -Property Name, Enabled, OptInDrpForDlp, WhenCreatedUTC

        $adaptiveProtectionEnabledPolicies = $irmPolicies | Where-Object { $_.Enabled -eq $true -and $_.OptInDrpForDlp -eq $true } | Select-Object -Property Name, Enabled, OptInDrpForDlp
    }
    catch {
        Write-PSFMessage "Error querying Insider Risk Management Policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    if($adaptiveProtectionEnabledPolicies -and $adaptiveProtectionEnabledPolicies.Count -gt 0){
        $passed = $true
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($passed) {
        $testResultMarkdown = "✅ Insider Risk Management Policies are ENABLED with Adaptive Protection integrated, enabling detection of risky behavior and insider threats including unauthorized data exposure to AI services.`n"
    }
    else{
        $testResultMarkdown = "❌ No Insider Risk Management Policies are enabled with Adaptive Protection, creating a critical gap in insider threat detection and risky AI usage prevention.`n"
    }

    $testResultMarkdown += "## Summary`n`n"
    $testResultMarkdown += "- **Total IRM Policies:** $($irmPolicies.Count)`n"
    $testResultMarkdown += "- **Enabled Policies with Adaptive Protection:** $($adaptiveProtectionEnabledPolicies.Count)`n"

    if($irmPolicies.Count -gt 0){
        $testResultMarkdown += "## [IRM Policies](https://purview.microsoft.com/insiderriskmgmt/policiespage)`n`n"
        $testResultMarkdown += "| Policy Name | Enabled | Adaptive Protection (OptInDrpForDlp) | Created Date |`n"
        $testResultMarkdown += "|:---|:---|:---|:---|`n"

        foreach ($policy in $irmPolicies) {
            $policyName = $policy.Name
            $enabled = if ($policy.Enabled) { "✅ Enabled" } else { "❌ Disabled" }
            $adaptiveProtection = if ($policy.OptInDrpForDlp) { "✅ Enabled" } else { "❌ Disabled" }
            $createdDate = if ($policy.WhenCreatedUTC) { $policy.WhenCreatedUTC.ToString("yyyy-MM-dd") } else { "N/A" }

            $testResultMarkdown += "| $policyName | $enabled | $adaptiveProtection | $createdDate |`n"
        }
    }
    else{
        $testResultMarkdown += "`n[Microsoft Purview Insider Risk Management > Policies](https://purview.microsoft.com/insiderriskmgmt/policiespage)`n"
    }
    #endregion Report Generation

    $params = @{
        TestId = '35038'
        Title  = 'Insider Risk Management Policies Enabled for Risky AI Usage'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
