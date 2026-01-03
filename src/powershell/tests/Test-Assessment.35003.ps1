<#
.SYNOPSIS
    Total Sensitivity Labels Configured

.DESCRIPTION
    This test checks if there is at least one sensitivity label configured in the tenant.
    Sensitivity labels are the foundation of Microsoft Information Protection.

.NOTES
    Test ID: 35003
    Pillar: Data
    Risk Level: High
#>

function Test-Assessment-35003 {
    [ZtTest(
        Category = 'sensitivity-labels',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35003,
        Title = 'Total Sensitivity Labels Configured',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Sensitivity Labels'
    Write-ZtProgress -Activity $activity -Status 'Getting Sensitivity Labels'

    $labels = @()
    $errorMsg = $null

    try {
        # Query: Get all sensitivity labels
        $labels = Get-Label -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying Sensitivity Labels: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($errorMsg) {
        $passed = $false
    }
    else {
        $passed = $labels.Count -gt 0
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to query sensitivity labels due to error: $errorMsg"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ At least one sensitivity label is configured in the tenant.`n`n"
        }
        else {
            $testResultMarkdown = "❌ No sensitivity labels are configured.`n`n"
        }

        $testResultMarkdown += "### Sensitivity Label Configuration Summary`n`n"
        $testResultMarkdown += "**Label Statistics:**`n"
        $testResultMarkdown += "* Total Label Count: $($labels.Count)`n"

        $topLevelCount = ($labels | Where-Object { [string]::IsNullOrEmpty($_.ParentId) }).Count
        $subLabelCount = ($labels | Where-Object { -not [string]::IsNullOrEmpty($_.ParentId) }).Count

        $testResultMarkdown += "* Top-Level Labels Count: $topLevelCount`n"
        $testResultMarkdown += "* Sub-Labels Count: $subLabelCount`n`n"

        if ($labels.Count -gt 0) {
            $testResultMarkdown += "**Sample Labels** (up to 5):`n"
            $testResultMarkdown += "| Label Name | Priority | Parent Label |`n"
            $testResultMarkdown += "|:---|:---|:---|`n"

            foreach ($label in ($labels | Select-Object -First 5)) {
                $parentName = if (-not [string]::IsNullOrEmpty($label.ParentLabelDisplayName)) { $label.ParentLabelDisplayName } else { "None" }
                $labelName = Get-SafeMarkdown -Text $label.DisplayName
                $parentName = Get-SafeMarkdown -Text $parentName
                $testResultMarkdown += "| $labelName | $($label.Priority) | $parentName |`n"
            }
        }

        $testResultMarkdown += "`n[Manage Sensitivity Labels in Microsoft Purview](https://purview.microsoft.com/informationprotection/informationprotectionlabels/sensitivitylabels)`n"
    }
    #endregion Report Generation

    $testResultDetail = @{
        TestId             = '35003'
        Title              = 'Total Sensitivity Labels Configured'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @testResultDetail
}
