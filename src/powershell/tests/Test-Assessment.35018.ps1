<#
.SYNOPSIS
    Downgrade Justification Required for Sensitivity Labels

.DESCRIPTION
    Sensitivity label policies should require users to provide justification when removing or downgrading labels. When downgrade justification is not required, users can silently reduce the classification level of sensitive content without creating an audit trail, creating compliance and audit risks.

.NOTES
    Test ID: 35018
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-35018 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35018,
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
        $testResultMarkdown += "## Downgrade Justification Configuration`n`n"

        $testResultMarkdown += "### Policy Summary`n`n"
        $testResultMarkdown += "| Policy Name | Enabled | Downgrade Justification | Scope | Labels Count | Workloads |`n"
        $testResultMarkdown += "|---|---|---|---|---|---|`n"

        foreach ($detail in $policyDetails) {
            $downgradeStatus = if ($detail.RequireDowngradeJustification) { '✅ Yes' } else { '❌ No' }
            $testResultMarkdown += "| $($detail.PolicyName) | $($detail.Enabled) | $downgradeStatus | $($detail.PolicyScope) | $($detail.LabelsPublishedCount) | $($detail.WorkloadsAffected) |`n"
        }

        $testResultMarkdown += "`n## Summary Statistics`n`n"
        $testResultMarkdown += "| Metric | Count |`n"
        $testResultMarkdown += "|---|---|`n"
        $testResultMarkdown += "| Total Enabled Label Policies | $($policyDetails.Count) |`n"
        $testResultMarkdown += "| Policies Requiring Downgrade Justification | $($policiesWithDowngradeJustification.Count) |`n"
        $testResultMarkdown += "| Policies NOT Requiring Downgrade Justification | $($policyDetails.Count - $policiesWithDowngradeJustification.Count) |`n"

        if ($policyDetails.Count -gt 0) {
            $percentage = [Math]::Round(($policiesWithDowngradeJustification.Count / $policyDetails.Count) * 100, 2)
            $testResultMarkdown += "| Percentage with Downgrade Justification | $percentage% |`n"
        }

        if ($policiesWithDowngradeJustification.Count -gt 0) {
            $testResultMarkdown += "`n## Policies with Downgrade Justification Enabled`n`n"
            $testResultMarkdown += "| Policy Name | Scope | Labels |`n"
            $testResultMarkdown += "|---|---|---|`n"

            foreach ($policy in $policiesWithDowngradeJustification) {
                $detail = $policyDetails | Where-Object { $_.PolicyName -eq $policy.Name }
                $testResultMarkdown += "| $($policy.Name) | $($detail.PolicyScope) | $($detail.LabelsPublishedCount) |`n"
            }
        }
    }

    #endregion Report Generation

    $passed = $testStatus -eq 'Pass'
    $params = @{
        TestId  = '35018'
        Title   = 'Downgrade Justification Required for Sensitivity Labels'
        Status  = $passed
        Result  = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
