<#
.SYNOPSIS
    Validates that Communication Compliance rules are configured to detect and monitor Copilot content.

.DESCRIPTION
    This test verifies that Communication Compliance rules targeting Copilot interactions are properly
    configured and enabled. It checks that supervisory review policies with Copilot-targeting rules
    are active and have configured review mailboxes for processing alerts.

.NOTES
    Test ID: 35039
    Category: Communication Compliance
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Security & Compliance PowerShell
#>

function Test-Assessment-35039 {
    [ZtTest(
        Category = 'Communication Compliance',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5 Compliance'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35039,
        Title = 'Communication Compliance Rules Targeting Copilot Content',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Communication Compliance Rules for Copilot Content'
    Write-ZtProgress -Activity $activity -Status 'Getting supervisory review rules'

    # Q1: Find Communication Compliance rules targeting Copilot content
    $copilotRules = $null
    $errorMsg = $null

    try {
        $allRules = @(Get-SupervisoryReviewRule -IncludeRuleXml -ErrorAction Stop)

        $copilotRules = @(foreach ($rule in $allRules) {
            if (-not [string]::IsNullOrWhiteSpace($rule.RuleXml)) {
                try {
                    # Wrap RuleXml in a root element to handle multiple rule elements
                    $wrappedXml = "<root>$($rule.RuleXml)</root>"
                    $ruleXml = [xml]$wrappedXml
                    $hasCopilotConfig = $false

                    # Check for Copilot in multiple possible locations in the XML structure
                    if ($ruleXml.root) {
                            $valueElements = $ruleXml.root.GetElementsByTagName('value')
                            foreach ($valueElement in $valueElements) {
                                if ($valueElement.'#text' -match 'IPM\.SkypeTeams\.Message\.Copilot') {
                                    $hasCopilotConfig = $true
                                    break
                                }
                            }
                    }

                    if ($hasCopilotConfig) {
                        $rule
                    }
                }
                catch {
                    Write-PSFMessage "Error parsing RuleXml for rule '$($rule.Name)': $_" -Level Warning
                }
            }
        })
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
            $copilotPolicyIdentities = @($copilotRules | Select-Object -ExpandProperty Policy -Unique)
            $policies = foreach ($id in $copilotPolicyIdentities.Guid) {
                Get-SupervisoryReviewPolicyV2 -Identity $id -ErrorAction SilentlyContinue
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
            $hits = @(Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -Operations SupervisionRuleMatch -ErrorAction Stop)

            if ($hits) {
                $policyNamePattern = ($enabledCopilotPolicies.Name | ForEach-Object { [regex]::Escape($_) }) -join '|'
                $policyHits = @($hits | Where-Object { $_.AuditData -match $policyNamePattern -and ($_.AuditData -match $copilotItemClassRegex -or $_.AuditData -match 'Copilot') })
            }
        }
        catch {
            Write-PSFMessage "Failed to check audit logs: $_" -Tag Test -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        # Investigate: Cannot query supervisory review rules (Query 1 failed)
        $passed = $false
        $customStatus = 'Investigate'
    }
    elseif ($copilotRules.Count -eq 0) {
        # Fail: Query 1 returns no rules matching the Copilot item class regex
        $passed = $false
    }
    elseif ($enabledCopilotPolicies.Count -eq 0) {
        # Fail: Query 2 returns no enabled policies
        $passed = $false
    }
    else {
        # Verify all enabled policies have ReviewMailbox configured (Query 2 requirement)
        $hasValidPolicies = @($enabledCopilotPolicies | Where-Object { $_.ReviewMailbox }).Count -gt 0

        if ($hasValidPolicies) {
            # Pass: Query 1 returns at least 1 rule AND Query 2 returns at least 1 enabled policy with ReviewMailbox
            $passed = $true
        }
        else {
            # Fail: Enabled policies exist but none have ReviewMailbox configured
            $passed = $false
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''

    if ($customStatus -eq 'Investigate') {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to determine Communication Compliance configuration status due to permissions issues or service connection failure."
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ **Status: Pass**`n`n"
        $testResultMarkdown += "Communication Compliance rules targeting Copilot content are properly configured and enabled.`n`n"
    }
    else {
        $testResultMarkdown = "❌ **Status: Fail**`n`n"
        $testResultMarkdown += "Communication Compliance rules targeting Copilot content are not properly configured or enabled.`n`n"
    }

    # Copilot-Targeting Rules section
    if ($copilotRules -and $copilotRules.Count -gt 0) {
        $testResultMarkdown += "## Copilot-Targeting Rules`n`n"
        $testResultMarkdown += "| Rule Name | Associated Policy |`n"
        $testResultMarkdown += "| :--- | :--- |`n"

        foreach ($rule in $copilotRules | Sort-Object Name) {
            $safeRuleName = Get-SafeMarkdown $rule.Name
            $safePolicyName = Get-SafeMarkdown $rule.Policy

            $testResultMarkdown += "| $safeRuleName | $safePolicyName |`n"
        }
        $testResultMarkdown += "`n"
    }
    else {
        $testResultMarkdown += "## Copilot-Targeting Rules`n`n"
        $testResultMarkdown += "No Copilot-targeting rules found.`n`n"
    }

    # Enabled Policies section
    if ($enabledCopilotPolicies -and $enabledCopilotPolicies.Count -gt 0) {
        $testResultMarkdown += "## Enabled Policies`n`n"
        $testResultMarkdown += "| Policy Name | Enabled | Review Mailbox |`n"
        $testResultMarkdown += "| :--- | :--- | :--- |`n"

        foreach ($policy in $enabledCopilotPolicies | Sort-Object Name) {
            $safePolicyName = Get-SafeMarkdown $policy.Name
            $reviewMailbox = if ($policy.ReviewMailbox) { Get-SafeMarkdown $policy.ReviewMailbox } else { 'Not configured' }
            $enabledStatus = if ($policy.Enabled -eq $true) { 'True' } else { 'False' }

            $testResultMarkdown += "| $safePolicyName | $enabledStatus | $reviewMailbox |`n"
        }
        $testResultMarkdown += "`n"
    }
    else {
        $testResultMarkdown += "## Enabled Policies`n`n"
        $testResultMarkdown += "No enabled policies with Copilot rules found.`n`n"
    }

    # Activity Evidence section (Optional)
    $testResultMarkdown += "## Activity Evidence (Optional)`n`n"
    if ($policyHits -and $policyHits.Count -gt 0) {
        $testResultMarkdown += "**Recent Copilot Matches (30 days):** $($policyHits.Count)`n`n"
    }
    elseif ($enabledCopilotPolicies -and $enabledCopilotPolicies.Count -gt 0) {
        $testResultMarkdown += "**Recent Copilot Matches (30 days):** 0`n`n"
    }
    else {
        $testResultMarkdown += "**Recent Copilot Matches (30 days):** No policies configured for audit review.`n`n"
    }

    # Summary section
    # Summary section
    $testResultMarkdown += "## Summary`n`n"
    $testResultMarkdown += "* **Total Copilot Rules Found:** $($copilotRules.Count)`n"
    $testResultMarkdown += "* **Enabled Policies with Copilot Rules:** $($enabledCopilotPolicies.Count)`n"

    if ($customStatus -eq 'Investigate') {
        $testResultMarkdown += "* **Status:** Investigate`n"
    }
    elseif ($passed) {
        $testResultMarkdown += "* **Status:** Pass`n"
    }
    else {
        $testResultMarkdown += "* **Status:** Fail`n"
    }

    #endregion Report Generation

    $params = @{
        TestId = '35039'
        Title  = 'Communication Compliance Rules Targeting Copilot Content'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
