<#
.SYNOPSIS
    Auto-labeling policies are in enforcement mode
#>

function Test-Assessment-35020 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce','External'),
        TestId = 35020,
        Title = 'Auto-labeling policies are in enforcement mode',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking auto-labeling enforcement mode configuration'

    # Q1: Get all auto-labeling policies
    Write-ZtProgress -Activity $activity -Status 'Getting auto-labeling policies'

    $errorMsg = $null
    $allPolicies = @()

    try {
        $allPolicies = Get-AutoSensitivityLabelPolicy -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying auto-labeling policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $enforcementPolicies = @()
    $simulationPolicies = @()
    $disabledPolicies = @()
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        $testResultMarkdown = "⚠️ Unable to determine auto-labeling enforcement mode status due to permissions issues or query failure.`n`n"
        $customStatus = 'Investigate'
    }
    else {
        Write-PSFMessage "Found $($allPolicies.Count) auto-labeling policies" -Level Verbose

        # Categorize policies by status and mode
        foreach ($policy in $allPolicies) {
            # Categorize policies by Mode property
            # Possible Mode values per documentation: Enable, TestWithNotifications, TestWithoutNotifications, Disable
            # Reference: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/set-autosensitivitylabelpolicy?view=exchange-ps#-mode

            if ($policy.Enabled -eq $true -and $policy.Mode -eq 'Enable') {
                $enforcementPolicies += $policy
            }
            elseif ($policy.Enabled -eq $true -and ($policy.Mode -eq 'TestWithoutNotifications' -or $policy.Mode -eq 'TestWithNotifications')) {
                $simulationPolicies += $policy
            }
            elseif ($policy.Enabled -eq $false) {
                $disabledPolicies += $policy
            }
        }

        # Determine pass/fail status
        if ($enforcementPolicies.Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "✅ At least one auto-labeling policy is enabled and actively labeling content in enforcement mode.`n`n%TestResult%"
        }
        else {
            $passed = $false

            if ($allPolicies.Count -eq 0) {
                $testResultMarkdown = "❌ No auto-labeling policies were found in your tenant.`n`n%TestResult%"
            }
            else {
                $testResultMarkdown = "❌ No auto-labeling policies are in enforcement mode. All policies are either disabled or in simulation mode.`n`n%TestResult%"
            }
        }
    }

    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Show enforcement policies table if any exist
    if ($enforcementPolicies.Count -gt 0) {
        $mdInfo += "`n`n### [Auto-labeling policies in enforcement mode](https://purview.microsoft.com/informationprotection/autolabeling)`n"
        $mdInfo += "| Policy name | Enabled status | Mode | Workload(s) targeted | Policy description | Date activated | Last modified |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $enforcementPolicies) {
            $policyName = Get-SafeMarkdown -Text $policy.Name
            $enabledStatus = $policy.Enabled
            $workload = if ($policy.Workload) { $policy.Workload } else { 'N/A' }
            $description = if ($policy.Comment) { Get-SafeMarkdown -Text $policy.Comment } else { 'N/A' }
            $created = if ($policy.WhenCreatedUTC) { $policy.WhenCreatedUTC.ToString('yyyy-MM-dd') } else { 'N/A' }
            $modified = if ($policy.WhenChangedUTC) { $policy.WhenChangedUTC.ToString('yyyy-MM-dd') } else { 'N/A' }
            $mdInfo += "| $policyName | $enabledStatus | $($policy.Mode) | $workload | $description | $created | $modified |`n"
        }
    }

    # Build summary metrics
    if ($allPolicies.Count -gt 0) {
        # Calculate aggregated workload coverage across all enforcement policies
        $allWorkloads = ($enforcementPolicies | ForEach-Object { $_.Workload }) -join ' '
        $exchangeCovered = if ($allWorkloads -match 'Exchange') { 'Yes' } else { 'No' }
        $sharepointCovered = if ($allWorkloads -match 'SharePoint') { 'Yes' } else { 'No' }
        $onedriveCovered = if ($allWorkloads -match 'OneDrive') { 'Yes' } else { 'No' }
        $teamsCovered = if ($allWorkloads -match 'Teams') { 'Yes' } else { 'No' }
        $powerbiCovered = if ($allWorkloads -match 'PowerBI') { 'Yes' } else { 'No' }

        $mdInfo += "`n`n### Summary:`n`n"
        $mdInfo += "- **Total Policies in Enforcement Mode:** $($enforcementPolicies.Count)`n"
        $mdInfo += "- **Total Policies in Simulation Mode:** $($simulationPolicies.Count)`n"
        $mdInfo += "- **Total Policies Disabled:** $($disabledPolicies.Count)`n"
        $mdInfo += "- **Workloads Covered by Enforcement Policies:**`n"
        $mdInfo += "  - **Exchange/Outlook:** $exchangeCovered`n"
        $mdInfo += "  - **SharePoint:** $sharepointCovered`n"
        $mdInfo += "  - **OneDrive:** $onedriveCovered`n"
        $mdInfo += "  - **Teams:** $teamsCovered`n"
        $mdInfo += "  - **Power BI:** $powerbiCovered`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35020'
        Title  = 'Auto-labeling enforcement mode enabled'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if status is 'Investigate'
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
