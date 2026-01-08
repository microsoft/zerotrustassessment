<#
.SYNOPSIS
    Downgrade Justification Required for Sensitivity Labels

.DESCRIPTION
    Sensitivity label policies should require users to provide justification when removing or downgrading labels. When downgrade justification is not required, users can silently reduce the classification level of sensitive content without creating an audit trail, creating compliance and audit risks.

.NOTES
    Test ID: 350181
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-350181 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 350181,
        Title = 'Downgrade Justification Required for Sensitivity Labels',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Sensitivity Label Policy Downgrade Justification Requirements'
    Write-ZtProgress -Activity $activity -Status 'Query 1: Getting all enabled label policies'

    # Query 1: Get all enabled label policies
    $labelPolicies = $null
    $errorMsg = $null
    $investigateReason = $null

    try {
        $labelPolicies = @(Get-LabelPolicy -ErrorAction Stop | Where-Object { $_.Enabled -eq $true })
    }
    catch {
        $errorMsg = $_
        $investigateReason = "Unable to query Label Policies: $($_)"
        Write-PSFMessage "Error querying Label Policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $testStatus = $null
    $policiesWithDowngradeJustification = @()
    $policyDetails = @()
    $downgradeJustifications = @()

    if ($errorMsg) {
        $testStatus = 'Investigate'
    }
    else {
        Write-ZtProgress -Activity $activity -Status 'Query 2 & 3: Examining label policy downgrade justification settings'

        # For each enabled policy, examine settings for downgrade justification
        foreach ($policy in $labelPolicies) {
            try {
                # Query 3: Get detail on specific policy settings
                $policySettings = Get-LabelPolicy -Identity $policy.Identity -ErrorAction Stop |
                    Select-Object -ExpandProperty Settings

                # Convert Settings array to hashtable for easier querying
                $settingsHash = @{}
                if ($policySettings) {
                    foreach ($setting in $policySettings) {
                        # Parse [key, value] format
                        $match = $setting -match '^\[(.*?),\s*(.+)\]$'
                        if ($match) {
                            $key = $matches[1].ToLower().Trim()
                            $value = $matches[2].ToLower().Trim()
                            $settingsHash[$key] = $value
                        }
                    }
                }

                # Query 2: Check for requiredowngradejustification setting
                $hasDowngradeJustification = $settingsHash.ContainsKey('requiredowngradejustification') -and
                    $settingsHash['requiredowngradejustification'] -eq 'true'

                if ($hasDowngradeJustification) {
                    $policiesWithDowngradeJustification += $policy
                }

                # Collect policy details for reporting
                $policyDetail = [PSCustomObject]@{
                    PolicyName                      = $policy.Name
                    Enabled                         = $policy.Enabled
                    RequireDowngradeJustification   = $hasDowngradeJustification
                    PolicyScope                     = if ($policy.ExchangeLocation -and $policy.ExchangeLocation.Type.value -ne 'Tenant') { 'Scoped' } else { 'Global' }
                    LabelsPublishedCount            = if ($policy.labels) { @($policy.labels).Count } else { 0 }
                    WorkloadsAffected               = @($policy.Workload) -join ', '
                }
                $policyDetails += $policyDetail
            }
            catch {
                $investigateReason = "Unable to determine Settings structure or permissions prevent access for policy: $($policy.Name)"
                Write-PSFMessage "Error examining policy '$($policy.Name)': $_" -Level Warning
            }
        }

        # Query audit logs for downgrade justification entries
        Write-ZtProgress -Activity $activity -Status 'Querying audit logs for downgrade justifications'
        try {
            $endDate = (Get-Date).ToUniversalTime()
            $startDate = $endDate.AddDays(-90)
            $auditLogs = Search-UnifiedAuditLog -RecordType SensitivityLabelAction -Operations LabelDowngradeJustification -StartDate $startDate -EndDate $endDate -ResultSize 5000 -ErrorAction Stop
            if ($auditLogs) {
                $downgradeJustifications = @($auditLogs | ForEach-Object {
                    [PSCustomObject]@{
                        UserEmail   = $_.UserIds
                        Timestamp   = $_.CreationDate
                        Justification = ($_.AuditData | ConvertFrom-Json).DowngradeJustification
                        Item        = ($_.AuditData | ConvertFrom-Json).ObjectId
                    }
                })
            }
        }
        catch {
            Write-PSFMessage "Warning: Unable to query audit logs for downgrade justifications: $_" -Level Warning
        }

        # Determine test status
        if ($investigateReason) {
            $testStatus = 'Investigate'
        }
        elseif ($policiesWithDowngradeJustification.Count -gt 0) {
            $testStatus = 'Pass'
        }
        else {
            $testStatus = 'Fail'
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ""

    if ($testStatus -eq 'Investigate') {
        $testResultMarkdown += "### Investigate`n`n"
        $testResultMarkdown += $investigateReason
    }
    elseif ($testStatus -eq 'Pass') {
        $testResultMarkdown += "### ✅ Pass`n`n"
        $testResultMarkdown += "Downgrade justification is required for at least one active sensitivity label policy, ensuring users must explain when removing or reducing label classification.`n`n"
    }
    else {
        $testResultMarkdown += "### ❌ Fail`n`n"
        $testResultMarkdown += "No sensitivity label policies require users to provide downgrade justification when removing or changing labels.`n`n"
    }

    # Add detailed configuration data if we have policy information
    if ($policyDetails.Count -gt 0) {
        $testResultMarkdown += "## Expected Details`n`n"

        # Get policy names with downgrade justification enabled
        $policyNames = @($policiesWithDowngradeJustification | ForEach-Object { $_.Name }) -join ', '
        if ($policyNames -eq '') {
            $policyNames = 'None'
        }

        # Determine policy scope
        $scopeList = @()
        foreach ($policy in $policiesWithDowngradeJustification) {
            $scope = if ($policy.ExchangeLocation -and $policy.ExchangeLocation.Type.value -ne 'Tenant') { 'Scoped to specific users or groups' } else { 'Global' }
            if ($scopeList -notcontains $scope) {
                $scopeList += $scope
            }
        }
        $policyScope = if ($scopeList.Count -gt 0) { $scopeList -join ', ' } else { 'N/A' }

        $testResultMarkdown += "- **Number of enabled policies requiring downgrade justification:** $($policiesWithDowngradeJustification.Count)`n"
        $testResultMarkdown += "- **Policy names with downgrade justification:** $policyNames`n"
        $testResultMarkdown += "- **Policy scope:** $policyScope`n"
        
        # Display actual audit log justifications
        $testResultMarkdown += "- **Audit logging - Downgrade Justifications Captured:**`n"
        if ($downgradeJustifications.Count -gt 0) {
            $testResultMarkdown += "`n  | User | Timestamp | Justification | Item |`n"
            $testResultMarkdown += "  |---|---|---|---|`n"
            foreach ($entry in $downgradeJustifications) {
                $justificationText = if ($entry.Justification) { $entry.Justification } else { 'N/A' }
                $testResultMarkdown += "  | $($entry.UserEmail) | $($entry.Timestamp) | $justificationText | $($entry.Item) |`n"
            }
            $testResultMarkdown += "`n  **Total downgrade justifications recorded:** $($downgradeJustifications.Count)`n"
        }
        else {
            $testResultMarkdown += " No downgrade justifications recorded in audit logs`n"
        }
        $testResultMarkdown += "`n`n"

        $testResultMarkdown += "## Summary Statistics`n`n"
        $testResultMarkdown += "| Metric | Count |`n"
        $testResultMarkdown += "|---|---|`n"
        $testResultMarkdown += "| Total Enabled Label Policies | $($policyDetails.Count) |`n"
        $testResultMarkdown += "| Policies Requiring Downgrade Justification | $($policiesWithDowngradeJustification.Count) |`n"
        $testResultMarkdown += "| Policies NOT Requiring Downgrade Justification | $($policyDetails.Count - $policiesWithDowngradeJustification.Count) |`n"

        if ($policyDetails.Count -gt 0) {
            $percentage = [Math]::Round(($policiesWithDowngradeJustification.Count / $policyDetails.Count) * 100, 2)
            $testResultMarkdown += "| Percentage with Downgrade Justification | $percentage% |`n"
        }

        $testResultMarkdown += "| Downgrade Justifications in Audit Logs | $($downgradeJustifications.Count) |`n"

        if ($policiesWithDowngradeJustification.Count -gt 0) {
            $testResultMarkdown += "`n## Policies with Downgrade Justification Enabled`n`n"
            $testResultMarkdown += "| Policy Name | Scope | Labels |`n"
            $testResultMarkdown += "|---|---|---|`n"

            foreach ($policy in $policiesWithDowngradeJustification) {
                $detail = $policyDetails | Where-Object { $_.PolicyName -eq $policy.Name }
                $scope = if ($policy.ExchangeLocation -and $policy.ExchangeLocation.Type.value -ne 'Tenant') { 'Scoped' } else { 'Global' }
                $testResultMarkdown += "| $($policy.Name) | $scope | $($detail.LabelsPublishedCount) |`n"
            }
        }
    }

    $testResultMarkdown += "`n## Remediation Steps`n`n"
    $testResultMarkdown += "1. Navigate to [Sensitivity label policies](https://purview.microsoft.com/informationprotection/labelpolicies) in Microsoft Purview`n"
    $testResultMarkdown += "2. Create or update a policy to enable downgrade justification requirement`n"
    $testResultMarkdown += "3. Enable: 'Require users to provide justification to change a label'`n"
    $testResultMarkdown += "4. Define predefined justification reasons`n"
    $testResultMarkdown += "5. Set policy scope (global or specific groups)`n"
    $testResultMarkdown += "6. Verify audit logging is enabled`n"
    $testResultMarkdown += "7. Test with pilot users`n`n"

    $testResultMarkdown += "[Learn More: Require users to provide justification to change a label](https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps#require-users-to-provide-justification-to-change-a-label)`n`n"
    $testResultMarkdown += "[Manage Sensitivity Label Policies in Microsoft Purview](https://purview.microsoft.com/informationprotection/labelpolicies)`n"

    #endregion Report Generation

    $passed = $testStatus -eq 'Pass'
    $params = @{
        TestId  = '350181'
        Title   = 'Downgrade Justification Required for Sensitivity Labels'
        Status  = $passed
        Result  = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
