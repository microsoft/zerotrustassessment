<#
.SYNOPSIS
    Checks for Mail Flow Rules with Rights Protection.

.DESCRIPTION
    This test validates that mail flow rules (transport rules) are configured to apply rights protection
    to sensitive emails. It checks for rules that apply Office 365 Message Encryption (OME),
    Rights Management Service (RMS) templates, or data classifications.

.NOTES
    Test ID: 35029
    Pillar: Data
#>
function Test-Assessment-35029 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = 'Microsoft 365 E3',
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = 'Workforce',
        TestId = '35029',
        Title = 'Mail Flow Rules with Rights Protection',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Mail Flow Rules with Rights Protection'
    Write-ZtProgress -Activity $activity -Status 'Querying Transport Rules'

    $rules = $null
    $errorMsg = $null

    try {
        if (Get-Command Get-TransportRule -ErrorAction SilentlyContinue) {
            $rules = Get-TransportRule -ResultSize Unlimited | Where-Object {
                $_.ApplyOME -eq $true -or
                $null -ne $_.ApplyRightsProtectionTemplate -or
                $null -ne $_.ApplyClassification
            }
        }
        else {
            $errorMsg = "The Get-TransportRule cmdlet is not available. Please ensure you are connected to Exchange Online."
        }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to query transport rules: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null
    $totalRules = 0
    $enabledCount = 0
    $disabledCount = 0
    $omeCount = 0
    $rmsCount = 0
    $dlpCount = 0
    $hasExternal = $false
    $hasSensitive = $false
    $hasDepartment = $false

    if ($errorMsg) {
        $passed = $false
        $customStatus = 'Investigate'
    }
    else {
        $totalRules = $rules.Count
        $enabledRules = $rules | Where-Object { $_.State -eq 'Enabled' }
        $enabledCount = $enabledRules.Count
        $disabledCount = $totalRules - $enabledCount

        $omeCount = ($rules | Where-Object { $_.ApplyOME -eq $true }).Count
        $rmsCount = ($rules | Where-Object { $null -ne $_.ApplyRightsProtectionTemplate }).Count
        $dlpCount = ($rules | Where-Object { $null -ne $_.ApplyClassification }).Count

        foreach ($rule in $rules) {
            if ($rule.SentToScope -eq 'NotInOrganization' -or ($null -ne $rule.RecipientDomainIs -and $rule.RecipientDomainIs.Count -gt 0)) {
                $hasExternal = $true
            }
            if ($null -ne $rule.MessageContainsDataClassifications -and $rule.MessageContainsDataClassifications.Count -gt 0) {
                $hasSensitive = $true
            }
            if (($null -ne $rule.FromMemberOf -and $rule.FromMemberOf.Count -gt 0) -or $null -ne $rule.SenderAttribute1) {
                $hasDepartment = $true
            }
        }

        $passed = $enabledCount -ge 1
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ""

    if ($customStatus -eq 'Investigate') {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to query transport rules: $errorMsg"
    }
    else {
        if ($passed) {
            $testResultMarkdown += "✅ Mail flow rules with rights protection are configured to automatically protect sensitive emails.`n`n"
        }
        else {
            $testResultMarkdown += "❌ No mail flow rules with rights protection are configured; sensitive emails are not automatically protected.`n`n"
        }

        $testResultMarkdown += "### Summary`n`n"
        $testResultMarkdown += "* Total Rights Protection Rules: **$totalRules**`n"
        $testResultMarkdown += "* Enabled Rules: **$enabledCount**`n"
        $testResultMarkdown += "* Disabled Rules: **$disabledCount**`n`n"

        $testResultMarkdown += "#### Rules by Action Type`n`n"
        $testResultMarkdown += "| Action Type | Count |`n"
        $testResultMarkdown += "| :--- | :--- |`n"
        $testResultMarkdown += "| OME Encryption Rules | $omeCount |`n"
        $testResultMarkdown += "| RMS Template Application | $rmsCount |`n"
        $testResultMarkdown += "| DLP/Classification Rules | $dlpCount |`n`n"

        $testResultMarkdown += "#### Common Protection Scenarios Covered`n`n"
        $testResultMarkdown += "| Scenario | Covered |`n"
        $testResultMarkdown += "| :--- | :--- |`n"
        $testResultMarkdown += "| External Email Protection | $(if ($hasExternal) { 'Yes' } else { 'No' }) |`n"
        $testResultMarkdown += "| Sensitive Content Detection | $(if ($hasSensitive) { 'Yes' } else { 'No' }) |`n"
        $testResultMarkdown += "| Department-Specific Rules | $(if ($hasDepartment) { 'Yes' } else { 'No' }) |`n"
        $testResultMarkdown += "`n[Microsoft Purview portal > Data Loss Prevention > Rules](https://purview.microsoft.com/datalossprevention/rules)`n`n"

        if ($totalRules -gt 0) {
            $testResultMarkdown += "### Mail Flow Rules with Rights Protection`n`n"
            $testResultMarkdown += "| Rule Name | Enabled Status | Trigger Conditions | Protection Actions | Rule Priority | Last Modified Date |`n"
            $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"

            foreach ($rule in $rules) {
                $name = if ($rule.Name) { $rule.Name -replace '\|', '&#124;' } else { "-" }
                $status = if ($rule.State) { $rule.State } else { "-" }

                $triggers = @()
                if ($rule.From) { $triggers += "Sender" }
                if ($rule.SentTo) { $triggers += "Recipient" }
                if ($rule.SentToScope) { $triggers += "Scope: $($rule.SentToScope)" }
                if ($rule.RecipientDomainIs) { $triggers += "Recipient Domain" }
                if ($rule.SubjectOrBodyContainsWords) { $triggers += "Content Keywords" }
                if ($rule.MessageContainsDataClassifications) { $triggers += "Sensitive Info Types" }
                if ($rule.FromMemberOf) { $triggers += "Sender Group" }
                if ($triggers.Count -eq 0) { $triggers += "Other/Custom" }
                $triggerStr = $triggers -join ", "

                $actions = @()
                if ($rule.ApplyOME) { $actions += "OME Encryption" }
                if ($rule.ApplyRightsProtectionTemplate) { $actions += "RMS Template: $($rule.ApplyRightsProtectionTemplate)" }
                if ($rule.ApplyClassification) { $actions += "Classification: $($rule.ApplyClassification)" }
                $actionStr = $actions -join ", "

                $priority = $rule.Priority
                $modified = if ($rule.WhenChanged) { $rule.WhenChanged.ToString("yyyy-MM-dd") } else { "-" }

                $testResultMarkdown += "| $name | $status | $triggerStr | $actionStr | $priority | $modified |`n"
            }
        }
    }
    #endregion Report Generation

    $params = @{
        TestId = '35029'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
