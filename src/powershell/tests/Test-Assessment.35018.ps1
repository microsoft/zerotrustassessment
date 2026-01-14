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
    $passed = $false
    $customStatus = $null
    $policiesWithDowngradeJustification = @()
    $policyDetails = @()

    if ($errorMsg) {
        # Use CustomStatus to indicate investigation — do not overwrite TestStatus to preserve core pass/fail logic.
        $customStatus = 'Investigate'
    }
    else {

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
            # Prefer using CustomStatus to indicate investigation; avoid setting TestStatus here.
            $customStatus = 'Investigate'
        }
        elseif ($policiesWithDowngradeJustification.Count -gt 0) {
            $testStatus = 'Pass'
            $passed = $true
        }
        else {
            $testStatus = 'Fail'
            $passed = $false
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ""

    # Prefer CustomStatus 'Investigate' for reporting when present.
    if ($customStatus -eq 'Investigate') {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to determine if downgrade justification is required due to policy complexity, permissions issues, or unclear Settings structure.`n`n"
    }
    elseif ($testStatus -eq 'Pass') {
        $testResultMarkdown = "### ✅ Pass`n`n"
        $testResultMarkdown += "Downgrade justification is required for at least one active sensitivity label policy, ensuring users must explain when removing or reducing label classification.`n`n"
    }
    else {
        $testResultMarkdown = "### ❌ Fail`n`n"
        $testResultMarkdown += "No sensitivity label policies require users to provide downgrade justification when removing or changing labels.`n`n"
    }

    # Add detailed configuration data if we have policy information
    if ($policyDetails.Count -gt 0) {
        $testResultMarkdown += "## Downgrade Justification Configuration`n`n"

        $testResultMarkdown += "### Policy Summary`n`n"
        $testResultMarkdown += "| Policy name | Enabled | Downgrade justification | Scope | Labels count | Workloads |`n"
        $testResultMarkdown += "|---|---|---|---|---|---|`n"

        foreach ($detail in $policyDetails) {
            $downgradeStatus = if ($detail.RequireDowngradeJustification) { '✅ Yes' } else { '❌ No' }
            $testResultMarkdown += "| $($detail.PolicyName) | $($detail.Enabled) | $downgradeStatus | $($detail.PolicyScope) | $($detail.LabelsPublishedCount) | $($detail.WorkloadsAffected) |`n"
        }

        $testResultMarkdown += "`n## Summary Statistics`n`n"
        $testResultMarkdown += "| Metric | Count |`n"
        $testResultMarkdown += "|---|---|`n"
        $testResultMarkdown += "| Total enabled label policies | $($policyDetails.Count) |`n"
        $testResultMarkdown += "| Policies requiring downgrade justification | $($policiesWithDowngradeJustification.Count) |`n"
        $testResultMarkdown += "| Policies not requiring downgrade justification | $($policyDetails.Count - $policiesWithDowngradeJustification.Count) |`n"

        if ($policyDetails.Count -gt 0) {
            $percentage = [Math]::Round(($policiesWithDowngradeJustification.Count / $policyDetails.Count) * 100, 2)
            $testResultMarkdown += "| Percentage with Downgrade Justification | $percentage% |`n"
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

    # Add CustomStatus if status is 'Investigate'
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
