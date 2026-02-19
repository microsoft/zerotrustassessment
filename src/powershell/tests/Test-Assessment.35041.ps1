<#
.SYNOPSIS
    Browser DLP Policies Configured

.DESCRIPTION
    Data Loss Prevention (DLP) policies with Browser enforcement protect sensitive information in web
    browsers by monitoring and controlling data interactions in supported browsers like Microsoft Edge.
    When Browser DLP is enabled, organizations can prevent sensitive data from being copied, pasted,
    printed, or uploaded to unauthorized locations through browser-based applications.

.NOTES
    Test ID: 35041
    Category: Data Loss Prevention (DLP)
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Security & Compliance PowerShell
#>

function Test-Assessment-35041 {
    [ZtTest(
        Category = 'Data Loss Prevention (DLP)',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35041,
        Title = 'Browser DLP Policies Configured',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Browser DLP Policies'
    Write-ZtProgress -Activity $activity -Status 'Getting DLP policies with Browser enforcement'

    $browserDlpPolicies = @()
    $browserDlpRules = @()
    $errorMsg = $null

    try {
        # Q1: Find DLP policies with Browser enforcement plane (indicates Browser DLP configured)
        $browserDlpPolicies = @(Get-DlpCompliancePolicy -ErrorAction Stop | Where-Object { $_.EnforcementPlanes -contains 'Browser' })

        # Q2: Get DLP compliance rules for those Browser policies
        if ($browserDlpPolicies.Count -gt 0) {
            Write-ZtProgress -Activity $activity -Status 'Getting DLP rules for Browser policies'
            $browserDlpRules = @($browserDlpPolicies | ForEach-Object {
                Get-DlpComplianceRule -Policy $_.Identity -ErrorAction SilentlyContinue
            })
        }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve DLP policies: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $investigateFlag = $false
    $passed = $false
    $failureReason = $null
    $enabledBrowserPolicies = @()

    if ($errorMsg) {
        $investigateFlag = $true
    }
    else {
        # Step 1: Discover Browser DLP Policies
        # If no Browser enforcement plane policies found → FAIL (Browser DLP not configured)
        if ($browserDlpPolicies.Count -eq 0) {
            $passed = $false
            $failureReason = 'NoPolicies'
        }
        # Step 2: Verify Rules Exist
        # If no Browser DLP rules found → FAIL (policies exist but lack enforcement rules)
        elseif ($browserDlpRules.Count -eq 0) {
            $passed = $false
            $failureReason = 'NoRules'
        }
        # Step 3: Check Enablement
        # If count ≥ 1 enabled browser DLP policy → PASS
        # If count = 0 or all policies disabled → FAIL
        else {
            $enabledBrowserPolicies = @($browserDlpPolicies | Where-Object { $_.Enabled -eq $true })
            if ($enabledBrowserPolicies.Count -ge 1) {
                $passed = $true
            }
            else {
                $passed = $false
                $failureReason = 'AllDisabled'
            }
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''

    if ($investigateFlag) {
        $testResultMarkdown = "⚠️ Unable to determine Browser DLP policy status due to permissions issues or service connection failure.`n`n"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ Browser DLP policies are configured and enabled, providing protection against sensitive data disclosure through web browsers.`n`n"
        }
        else {
            # Provide specific failure message based on the failure reason
            switch ($failureReason) {
                'NoPolicies' {
                    $testResultMarkdown = "❌ No Browser DLP policies found. Browser DLP is not configured; this implies PAYG is either inactive or not used for browser protection.`n`n"
                }
                'NoRules' {
                    $testResultMarkdown = "❌ Browser DLP policies exist but lack enforcement rules. Policies without rules cannot protect against data exfiltration.`n`n"
                }
                'AllDisabled' {
                    $testResultMarkdown = "❌ Browser DLP policies exist but are all disabled. Enable at least one policy to protect against unmanaged AI app data exfiltration.`n`n"
                }
                default {
                    $testResultMarkdown = "❌ No Browser DLP policies are enabled or configured in the organization.`n`n"
                }
            }
        }

        $testResultMarkdown += "## Browser DLP Policy Summary`n`n"
        $testResultMarkdown += "**Total Browser DLP Policies:** $($browserDlpPolicies.Count)`n`n"
        $testResultMarkdown += "**Enabled Policies:** $($enabledBrowserPolicies.Count)`n`n"
        $testResultMarkdown += "**Total Rules:** $($browserDlpRules.Count)`n`n"

        # Browser DLP Policies section
        if ($browserDlpPolicies.Count -gt 0) {
            $testResultMarkdown += "### Browser DLP Policies`n`n"
            $testResultMarkdown += "| Policy Name | Enabled | Mode | Enforcement Planes | Policy Category | Created |`n"
            $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"

            foreach ($policy in $browserDlpPolicies | Sort-Object Name) {
                $enabledStatus = if ($policy.Enabled) { '✅ Yes' } else { '❌ No' }
                $mode = if ($policy.Mode) { $policy.Mode } else { 'N/A' }
                $enforcementPlanes = if ($policy.EnforcementPlanes) { ($policy.EnforcementPlanes -join ', ') } else { 'N/A' }
                $policyCategory = if ($policy.PolicyCategory) { $policy.PolicyCategory } else { 'N/A' }
                $createdDate = if ($policy.CreationTimeUtc) { $policy.CreationTimeUtc.ToString('yyyy-MM-dd') } else { 'N/A' }
                $testResultMarkdown += "| $($policy.Name) | $enabledStatus | $mode | $enforcementPlanes | $policyCategory | $createdDate |`n"
            }
            $testResultMarkdown += "`n"
        }
        else {
            $testResultMarkdown += "### Browser DLP Policies`n`nNo Browser DLP policies found.`n`n"
        }

        # Browser DLP Rules section
        if ($browserDlpRules.Count -gt 0) {
            $testResultMarkdown += "### Browser DLP Rules`n`n"
            $testResultMarkdown += "| Rule Name | Policy | Disabled | Actions |`n"
            $testResultMarkdown += "| :--- | :--- | :--- | :--- |`n"

            foreach ($rule in $browserDlpRules | Sort-Object Name) {
                $disabledStatus = if ($rule.Disabled) { '❌ Yes' } else { '✅ No' }
                $policyName = if ($rule.Policy) { $rule.Policy } else { 'N/A' }
                $actions = if ($rule.Actions) { ($rule.Actions -join ', ') } else { 'N/A' }
                $testResultMarkdown += "| $($rule.Name) | $policyName | $disabledStatus | $actions |`n"
            }
            $testResultMarkdown += "`n"
        }
        else {
            $testResultMarkdown += "### Browser DLP Rules`n`nNo Browser DLP rules found.`n`n"
        }
    }

    $testResultMarkdown += "[View DLP Policies in Microsoft Purview Portal](https://purview.microsoft.com/datalossprevention/policies)`n"
    #endregion Report Generation

    $params = @{
        TestId = '35041'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($investigateFlag -eq $true) {
        $params.CustomStatus = 'Investigate'
    }
    Add-ZtTestResultDetail @params
}
