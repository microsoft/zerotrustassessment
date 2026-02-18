<#
.SYNOPSIS
    Adaptive Protection is enabled in data loss prevention policies

.DESCRIPTION
    Adaptive Protection in DLP integrates Microsoft Purview Insider Risk Management with Data Loss Prevention policies.
    This feature uses machine learning to identify users exhibiting risky behaviors (classified as elevated, moderate, or minor risk levels)
    and automatically applies appropriate DLP controls. Rather than applying uniform DLP policies to all users, Adaptive Protection
    allows organizations to dynamically enforce stronger protections for high-risk users while maintaining flexibility for normal operations.
    Without Adaptive Protection, DLP policies apply the same rules uniformly regardless of user risk profile, missing opportunities
    to prevent insider threats based on behavioral indicators.

.NOTES
    Test ID: 35032
    Pillar: Data
    Risk Level: Medium
    Category: Data Loss Prevention (DLP)
    Required Module: ExchangeOnlineManagement
    Required Connection: Connect-IPPSSession
#>

function Test-Assessment-35032 {
    [ZtTest(
        Category = 'Data Loss Prevention (DLP)',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35032,
        Title = 'Adaptive Protection is enabled in data loss prevention policies',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    # Risk Level GUIDs for Adaptive Protection
    $ElevatedRiskGuid = 'FCB9FA93-6269-4ACF-A756-832E79B36A2A'
    $ModerateRiskGuid = '797C4446-5C73-484F-8E58-0CCA08D6DF6C'
    $MinorRiskGuid = '75A4318B-94A2-4323-BA42-2CA6DB29AAFE'

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Adaptive Protection in DLP Policies'
    Write-ZtProgress -Activity $activity -Status 'Querying DLP compliance rules'

    $dlpRules = $null
    $adaptiveRules = $null
    $errorMsg = $null

    try {
        # Q1/Q2: Get all DLP compliance rules
        $dlpRules = Get-DlpComplianceRule -ErrorAction Stop

        # Q3: Filter for rules with Adaptive Protection (SharedByIRMUserRisk condition)
        $adaptiveRules = $dlpRules | Where-Object { $_.AdvancedRule -match 'SharedByIRMUserRisk' }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying DLP compliance rules: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $customStatus = $false
    $passed = $false

    if ($errorMsg) {
        $customStatus = $true
    }
    else {
        # If at least 1 DLP rule contains SharedByIRMUserRisk condition, the test passes
        # Returns $true if $adaptiveRules contains any items
        # Returns $false if it's $null or empty
        $passed = [bool]$adaptiveRules
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ""

    if ($customStatus) {
        $testResultMarkdown = "⚠️ Unable to determine Adaptive Protection configuration due to permissions issues or service connection failure.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Adaptive Protection is configured in DLP policies, enabling risk-based, behavior-driven data protection through insider risk integration.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No DLP policies use Adaptive Protection; policies do not have insider risk-based rules configured.`n`n%TestResult%"
    }

    $mdInfo = ''

    if ($customStatus) {
        $mdInfo = "[View DLP Policies in Microsoft Purview Portal](https://purview.microsoft.com/datalossprevention/policies)`n"
    }
    elseif ($passed) {
        # Summary counts
        $totalRules = @($dlpRules).Count
        $adaptiveRulesCount = @($adaptiveRules).Count

        # Count rules by risk level
        $elevatedRiskCount = 0
        $moderateRiskCount = 0
        $minorRiskCount = 0

        foreach ($rule in $adaptiveRules) {
            if ($rule.AdvancedRule -match $ElevatedRiskGuid) { $elevatedRiskCount++ }
            if ($rule.AdvancedRule -match $ModerateRiskGuid) { $moderateRiskCount++ }
            if ($rule.AdvancedRule -match $MinorRiskGuid) { $minorRiskCount++ }
        }

        # Get unique parent policies with Adaptive Protection
        $adaptivePolicies = @($adaptiveRules | Select-Object -ExpandProperty ParentPolicyName -Unique)

        $formatTemplate = @'

### {0}

| Metric | Count |
| :----- | :---- |
{1}

### DLP Rules with Adaptive Protection

| Rule Name | Parent Policy | Enabled | Risk Levels |
| :-------- | :------------ | :------ | :---------- |
{2}

[View DLP Policies in Microsoft Purview Portal](https://purview.microsoft.com/datalossprevention/policies)

'@

        $summaryRows = "| Total DLP Rules | $totalRules |`n"
        $summaryRows += "| Rules with Adaptive Protection | $adaptiveRulesCount |`n"
        $summaryRows += "| Policies with Adaptive Protection | $($adaptivePolicies.Count) |`n"
        $summaryRows += "| Rules with Elevated Risk Level | $elevatedRiskCount |`n"
        $summaryRows += "| Rules with Moderate Risk Level | $moderateRiskCount |`n"
        $summaryRows += "| Rules with Minor Risk Level | $minorRiskCount |`n"

        $ruleRows = ''
        foreach ($rule in $adaptiveRules) {
            $ruleName = $rule.Name
            $parentPolicy = $rule.ParentPolicyName
            $enabledStatus = if ($rule.Disabled -eq $false) { "✅ Yes" } else { "❌ No" }

            # Determine which risk levels are in the rule
            $riskLevels = @()
            if ($rule.AdvancedRule -match $ElevatedRiskGuid) { $riskLevels += "Elevated" }
            if ($rule.AdvancedRule -match $ModerateRiskGuid) { $riskLevels += "Moderate" }
            if ($rule.AdvancedRule -match $MinorRiskGuid) { $riskLevels += "Minor" }
            $riskLevelStr = if ($riskLevels.Count -gt 0) { $riskLevels -join ", " } else { "Unknown" }

            $ruleRows += "| $ruleName | $parentPolicy | $enabledStatus | $riskLevelStr |`n"
        }

        $reportTitle = 'Adaptive Protection Summary'
        $mdInfo = $formatTemplate -f $reportTitle, $summaryRows, $ruleRows
    }
    else {
        $mdInfo = "[View DLP Policies in Microsoft Purview Portal](https://purview.microsoft.com/datalossprevention/policies)`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35032'
        Title  = 'Adaptive Protection in DLP Policies'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus -eq $true) {
        $params.CustomStatus = 'Investigate'
    }
    Add-ZtTestResultDetail @params
}
