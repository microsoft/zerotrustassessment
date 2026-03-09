<#
.SYNOPSIS
    Mail flow rules apply rights protection to sensitive messages

.DESCRIPTION
    Mail flow rules (transport rules) in Exchange Online allow organizations to automatically apply information protection policies to email messages based on conditions such as sender, recipient, content patterns, or organizational attributes. When mail flow rules with rights protection are not configured, organizations must rely solely on users to manually apply sensitivity labels or encrypt messages—an approach that is inconsistent, error-prone, and does not scale. Without automated rights protection rules, sensitive emails are frequently sent unencrypted, allowing unauthorized access, forwarding, and printing of confidential information. Rights protection rules automatically apply encryption, restriction labels, and permissions to messages matching specific criteria (e.g., emails to external domains, messages containing credit card numbers, emails from finance departments). Configuring at least one mail flow rule with rights protection for high-risk email scenarios ensures sensitive information is automatically protected at the message transport layer, reducing the risk of data exfiltration, unauthorized access, and compliance violations.

.NOTES
    Test ID: 35029
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-35029 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35029,
        Title = 'Mail flow rules apply rights protection to sensitive messages',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Mail flow rules with rights protection'
    Write-ZtProgress -Activity $activity -Status 'Querying transport rules from Exchange Online'

    $protectionRules = @()
    $allProtectionRulesDetailed = @()
    $enabledRulesCount = 0
    $errorMsg = $null

    try {
        # Q1: Get all mail flow rules with encryption or rights management actions
        $allRules = Get-TransportRule -ErrorAction Stop
        $protectionRules = $allRules | Where-Object {
            $_.ApplyOME -eq $true -or
            $_.ApplyRightsProtectionTemplate -or
            $_.ApplyClassification
        }

        # Q2: Get detailed configuration of each protection rule
        foreach ($rule in $protectionRules) {
            $ruleDetails = [PSCustomObject]@{
                Name                          = $rule.Name
                State                         = $rule.State
                Priority                      = $rule.Priority
                ApplyOME                      = $rule.ApplyOME
                ApplyRightsProtectionTemplate = $rule.ApplyRightsProtectionTemplate
                ApplyClassification           = $rule.ApplyClassification
                SentToScope                   = $rule.SentToScope
                WhenChanged                   = $rule.WhenChanged
            }
            $allProtectionRulesDetailed += $ruleDetails
        }

        # Q3: Count enabled vs disabled rules
        $enabledRulesCount = @($protectionRules | Where-Object { $_.State -eq 'Enabled' }).Count
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying transport rules: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($errorMsg) {
        Write-PSFMessage 'Not connected to Exchange Online.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedExchange
        return
    }

    $passed = $false

    # Pass if at least one enabled rule with protection actions exists
    if ($enabledRulesCount -ge 1) {
        $passed = $true
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''

    if ($passed) {
        $testResultMarkdown = "✅ Mail flow rules with rights protection are configured, automatically protecting sensitive emails through encryption and restriction policies.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No mail flow rules with rights protection are configured; sensitive emails are not automatically protected in transit.`n`n%TestResult%"
    }

    # Build detailed content
    $mdInfo = ''

    # Build summary section
    $totalRulesCount = $protectionRules.Count
    $disabledRulesCount = $totalRulesCount - $enabledRulesCount

    # Count by protection type
    $omeRulesCount = @($protectionRules | Where-Object { $_.ApplyOME -eq $true }).Count
    $rmsRulesCount = @($protectionRules | Where-Object { $_.ApplyRightsProtectionTemplate }).Count
    $classificationRulesCount = @($protectionRules | Where-Object { $_.ApplyClassification }).Count

    # Check common protection scenarios
    $hasExternalProtection = @($protectionRules | Where-Object { $_.SentToScope -eq 'NotInOrganization' }).Count -gt 0

    if ($allProtectionRulesDetailed.Count -gt 0) {
        $mdInfo += "### [Protection rules configuration](https://admin.exchange.microsoft.com/#/transportrules)`n`n"
        $mdInfo += "| Rule name | State | Priority | OME | RMS template | Classification | Last modified |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($rule in $allProtectionRulesDetailed | Sort-Object -Property Priority) {
            $ruleName = Get-SafeMarkdown -Text $rule.Name
            $ruleLink = "[$ruleName](https://admin.exchange.microsoft.com/#/transportrules)"
            $stateIcon = if ($rule.State -eq 'Enabled') { '✅' } else { '❌' }
            $omeStatus = if ($rule.ApplyOME) { 'Yes' } else { 'No' }
            $rmsTemplate = if ($rule.ApplyRightsProtectionTemplate) { Get-SafeMarkdown -Text $rule.ApplyRightsProtectionTemplate } else { 'N/A' }
            $classificationStatus = if ($rule.ApplyClassification) { Get-SafeMarkdown -Text $rule.ApplyClassification } else { 'N/A' }
            $modifiedDate = if ($rule.WhenChanged) { $rule.WhenChanged.ToString('yyyy-MM-dd') } else { 'N/A' }

            $mdInfo += "| $ruleLink | $stateIcon $($rule.State) | $($rule.Priority) | $omeStatus | $rmsTemplate | $classificationStatus | $modifiedDate |`n"
        }
        $mdInfo += "`n"
    }

    $mdInfo += "### Rules by action type`n`n"
    $mdInfo += "| Action type | Count |`n"
    $mdInfo += "| :--- | :--- |`n"
    $mdInfo += "| OME encryption rules | $omeRulesCount |`n"
    $mdInfo += "| RMS template application | $rmsRulesCount |`n"
    $mdInfo += "| Classification rules | $classificationRulesCount |`n"

    $externalProtectionStatus = if ($hasExternalProtection) { '✅ Yes' } else { '❌ No' }

    $mdInfo += "`n### Summary`n`n"
    $mdInfo += "| Metric | Count |`n"
    $mdInfo += "| :--- | :--- |`n"
    $mdInfo += "| Total protection rules | $totalRulesCount |`n"
    $mdInfo += "| Enabled rules | $enabledRulesCount |`n"
    $mdInfo += "| Disabled rules | $disabledRulesCount |`n"
    $mdInfo += "| External email protection | $externalProtectionStatus |"

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35029'
        Title  = 'Mail flow rules with rights protection'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
