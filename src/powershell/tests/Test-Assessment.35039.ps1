<#
.SYNOPSIS
    Communication compliance monitoring is configured for Microsoft Copilot

.DESCRIPTION
    This test verifies that Communication Compliance rules targeting Copilot interactions are properly
    configured and enabled. It checks that supervisory review policies with Copilot-targeting rules
    are active and have configured review mailboxes for processing alerts.

.NOTES
    Test ID: 35039
    Category: Data Security Posture Management
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Security & Compliance PowerShell
#>

function Test-Assessment-35039 {
    [ZtTest(
        Category = 'Data Security Posture Management',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35039,
        Title = 'Communication compliance monitoring is configured for Microsoft Copilot',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Communication Compliance Rules for Copilot Content'
    Write-ZtProgress -Activity $activity -Status 'Getting supervisory review rules'

    # Q1: Find Communication Compliance rules targeting Copilot content
    $copilotRules = @()
    $errorMsg = $null

    try {
        $allRules = Get-SupervisoryReviewRule -IncludeRuleXml -ErrorAction Stop
        $allReviewPolicy = Get-SupervisoryReviewPolicyV2

        foreach ($rule in $allRules) {
            if (-not [string]::IsNullOrWhiteSpace($rule.RuleXml)) {
                try {
                    # Wrap RuleXml in a root element to handle multiple rule elements
                    $wrappedXml = "<root>$($rule.RuleXml)</root>"
                    $ruleXml = [xml]$wrappedXml
                    $hasCopilotConfig = $false

                    # Check for Copilot in Workloads array within JSON value elements
                    if ($ruleXml.root) {
                        $valueElements = $ruleXml.root.GetElementsByTagName('value')
                        foreach ($valueElement in $valueElements) {
                            $rawValue = $valueElement.'#text'
                            if (-not [string]::IsNullOrWhiteSpace($rawValue)) {
                                try {
                                    $jsonText = $rawValue.Trim()

                                    # We only need object/array JSON payloads that can contain Workloads
                                    if ($jsonText -notmatch '^[\{\[]') {
                                        continue
                                    }

                                    $jsonData = $jsonText | ConvertFrom-Json -ErrorAction Stop
                                    if ($jsonData.Workloads -and $jsonData.Workloads -contains 'Copilot') {
                                        $hasCopilotConfig = $true
                                        break
                                    }
                                }
                                catch {
                                    # Skip if JSON parsing fails
                                }
                            }
                        }
                    }

                    if ($hasCopilotConfig) {
                        # Lookup policy name from $allReviewPolicy using Policy ID
                        $policyId = $rule.Policy
                        $policyName = ($allReviewPolicy | Where-Object { $_.Guid -eq $policyId }).Name

                        $copilotRules += [PSCustomObject]@{
                            RuleName   = $rule.Name
                            PolicyId   = $policyId
                            PolicyName = if ($policyName) { $policyName } else { 'Unknown' }
                        }
                    }
                }
                catch {
                    Write-PSFMessage "Error parsing RuleXml for rule '$($rule.Name)': $_" -Level Warning
                }
            }

        }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve supervisory review rules: $_" -Tag Test -Level Warning
    }

    # Q2: Resolve Copilot-targeting policies and verify enabled status
    $enabledCopilotPolicies = @()
    if ($copilotRules -and -not $errorMsg) {
        #Write-ZtProgress -Activity $activity -Status 'Verifying policy enabled status'

        try {
            $copilotPolicyIdentities = @($copilotRules | Select-Object -ExpandProperty PolicyId -Unique)
            $policies = foreach ($id in $copilotPolicyIdentities) {
                $allReviewPolicy | Where-Object { $_.Guid -eq $id }
            }
            $enabledCopilotPolicies = @($policies | Where-Object { $_ -and $_.Enabled -eq $true })
        }
        catch {
            Write-PSFMessage "Failed to retrieve supervisory review policies: $_" -Tag Test -Level Warning
        }
    }

    # Q3: Verify Copilot capture is active by checking audit logs (optional)
    $policyHits = $null
    if ($enabledCopilotPolicies) {
        Write-ZtProgress -Activity $activity -Status 'Checking audit logs'

        try {
            $startDate = (Get-Date).AddDays(-30)
            $endDate = Get-Date
            $hits = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -Operations SupervisionRuleMatch -ErrorAction Stop

            if ($hits) {
                $policyNamePattern = ($enabledCopilotPolicies.Name | ForEach-Object { [regex]::Escape($_) }) -join '|'
                $policyHits = @($hits | Where-Object { $_.AuditData -match $policyNamePattern -and ($_.AuditData -match 'Copilot') })
            }
        }
        catch {
            Write-PSFMessage "Failed to check audit logs: $_" -Tag Test -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Evaluation Logic:
    # 1. If Query 1 returns at least 1 rule with Copilot in RuleXml, proceed to Query 2
    if ($copilotRules.Count -gt 0) {
        # 2. If Query 2 returns at least 1 enabled policy with ReviewMailbox configured, then Pass
        $hasValidPolicies = @($enabledCopilotPolicies | Where-Object { $_.ReviewMailbox }).Count -gt 0
        $passed = $hasValidPolicies
    }
    # 3. If Query 1 returns no rules or Query 2 returns no enabled policies, then Fail
    else {
        $passed = $false
    }
    # Query 3 (audit logs) is optional and used only for evidence display
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($passed) {
        $statusIcon = '✅ Pass'
        $statusMessage = 'Communication Compliance rules targeting Copilot content are properly configured and enabled.'
    }
    else {
        $statusIcon = '❌ Fail'
        $statusMessage = 'Communication Compliance rules targeting Copilot content are not properly configured or enabled.'
    }

    # Copilot-Targeting Rules section
    if ($copilotRules -and $copilotRules.Count -gt 0) {
        $rulesTableRows = ''
        foreach ($rule in $copilotRules | Sort-Object RuleName) {
            $rulesTableRows += "| $($rule.RuleName) | $($rule.PolicyName) |`n"
        }

        $rulesTemplate = @'

### Copilot-Targeting Rules

| Rule Name | Associated Policy |
| :------ | :---- |
{0}
'@
        $mdInfo += $rulesTemplate -f $rulesTableRows
    }
    else {
        $mdInfo += "`n### Copilot-Targeting Rules`n`nNo Copilot-targeting rules found.`n"
    }

    # Enabled Policies section
    if ($enabledCopilotPolicies -and $enabledCopilotPolicies.Count -gt 0) {
        $policiesTableRows = ''
        foreach ($policy in $enabledCopilotPolicies | Sort-Object Name) {
            $reviewMailbox = if ($policy.ReviewMailbox) { $policy.ReviewMailbox } else { 'Not configured' }
            $enabledStatus = if ($policy.Enabled -eq $true) { 'True' } else { 'False' }
            $policiesTableRows += "| $($policy.Name) | $enabledStatus | $reviewMailbox |`n"
        }

        $policiesTemplate = @'

### Enabled Policies

| Policy Name | Enabled | Review Mailbox |
| :------ | :---- | :---- |
{0}
'@
        $mdInfo += $policiesTemplate -f $policiesTableRows
    }
    else {
        $mdInfo += "`n### Enabled Policies`n`nNo enabled policies with Copilot rules found.`n"
    }

    # Activity Evidence section
    $evidenceText = if ($policyHits -and $policyHits.Count -gt 0) {
        "Recent Copilot Matches (30 days): $($policyHits.Count)"
    }
    elseif ($enabledCopilotPolicies -and $enabledCopilotPolicies.Count -gt 0) {
        "Recent Copilot Matches (30 days): 0"
    }
    else {
        "Recent Copilot Matches (30 days): No policies configured for audit review."
    }

    $mdInfo += "`n### Activity Evidence`n`n$evidenceText`n"

    # Summary
    $summaryTemplate = @'

**Summary:**

 Status: {0}

 Total Copilot Rules Found: {1}

 Enabled Policies with Copilot Rules: {2}

**Portal Access:**

 [Microsoft Purview Communication Compliance > Policies](https://purview.microsoft.com/communicationcompliance/policies)

'@

    $mdInfo += $summaryTemplate -f $statusIcon, $copilotRules.Count, $enabledCopilotPolicies.Count

    $testResultMarkdown = "$statusMessage`n$mdInfo"

    #endregion Report Generation

    $params = @{
        TestId = '35039'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
