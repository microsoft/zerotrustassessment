<#
.SYNOPSIS
    Published Label Policies

.DESCRIPTION
    Creating sensitivity labels is the first step in information protection deployment.
    Labels must be published through label policies before users can apply them to content.
    Label policies define which users or groups receive which labels, determine default labeling behavior,
    and enforce mandatory labeling requirements.

.NOTES
    Test ID: 35004
    Pillar: Data
    Risk Level: Low
#>

function Test-Assessment-35004 {
    [ZtTest(
        Category = 'Sensitivity Labels',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Low',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35004,
        Title = 'Published Label Policies',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Published Label Policies'
    Write-ZtProgress -Activity $activity -Status 'Getting Label Policies'

    $policies = @()
    $errorMsg = $null

    try {
        # Query: Get all label policies
        $policies = Get-LabelPolicy -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying Label Policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $enabledPolicies = @()
    $totalUsersGroupsDisplay = "0"

    if ($errorMsg) {
        $passed = $false
    }
    else {
        $enabledPolicies = $policies | Where-Object { $_.Enabled -eq $true }
        $passed = $enabledPolicies.Count -ge 1

        $allUsersTargeted = $false
        $uniqueTargets = New-Object System.Collections.Generic.HashSet[string]

        foreach ($policy in $enabledPolicies) {
            if ($policy.ExchangeLocation  -contains "All" -or
                $policy.ModernGroupLocation -contains "All" -or
                $policy.SharePointLocation  -contains "All" -or
                $policy.OneDriveLocation    -contains "All") {
                $allUsersTargeted = $true
                break
            }

            if ($policy.ExchangeLocation) {
                foreach ($target in $policy.ExchangeLocation) { $null = $uniqueTargets.Add($target) }
            }
            if ($policy.ModernGroupLocation) {
                foreach ($target in $policy.ModernGroupLocation) { $null = $uniqueTargets.Add($target) }
            }
        }

        $totalUsersGroupsDisplay = if ($allUsersTargeted) { "All Users" } else { $uniqueTargets.Count }
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to query label policies due to error: $errorMsg"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ At least one enabled label policy is published to users.`n`n"
        }
        else {
            $testResultMarkdown = "❌ No enabled label policies exist or all policies are disabled.`n`n"
        }

        $testResultMarkdown += "### Label Policy Summary`n`n"
        $testResultMarkdown += "* Total Policies Configured: $($policies.Count)`n"
        $testResultMarkdown += "* Enabled Policies: $($enabledPolicies.Count)`n"
        $testResultMarkdown += "* Disabled Policies: $($policies.Count - $enabledPolicies.Count)`n"
        $testResultMarkdown += "* Total Users/Groups with Label Access: $totalUsersGroupsDisplay`n"

        if ($policies.Count -gt 0) {
            $testResultMarkdown += "`n**Policies:**`n"
            $testResultMarkdown += "| Policy Name | Enabled | Labels Included | Published To |`n"
            $testResultMarkdown += "|:---|:---|:---|:---|`n"

            foreach ($policy in $policies) {
                $policyName = Get-SafeMarkdown -Text $policy.Name
                $enabled = if ($policy.Enabled) { "True" } else { "False" }

                # Labels property usually contains the list of label names or GUIDs
                $labelsIncluded = 0
                if ($policy.Labels) {
                    $labelsIncluded = ($policy.Labels).Count
                } elseif ($policy.ScopedLabels) {
                    $labelsIncluded = ($policy.ScopedLabels).Count
                }

                # Determine publication scope
                $publishedTo = "Specific Users/Groups"
                if ($policy.ExchangeLocation -contains "All" -or $policy.ModernGroupLocation -contains "All" -or $policy.SharePointLocation -contains "All" -or $policy.OneDriveLocation -contains "All") {
                    $publishedTo = "All Users/Groups"
                }

                $testResultMarkdown += "| $policyName | $enabled | $labelsIncluded | $publishedTo |`n"
            }
        }

        $testResultMarkdown += "`n[Manage Label Policies in Microsoft Purview](https://purview.microsoft.com/informationprotection/labelpolicies)`n"
    }
    #endregion Report Generation

    $testResultDetail = @{
        TestId             = '35004'
        Title              = 'Published Label Policies'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @testResultDetail
}
