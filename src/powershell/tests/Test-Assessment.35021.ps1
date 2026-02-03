<#
.SYNOPSIS
    Auto-Labeling Policies Enabled for SharePoint and OneDrive

.DESCRIPTION
    SharePoint sites and OneDrive accounts are the primary repositories for unstructured file content in Microsoft 365. Without auto-labeling policies specifically targeting these locations, organizations cannot automatically classify files based on their content or sensitive information types, leaving sensitive data vulnerable. Auto-labeling policies deployed in enforcement mode (not simulation) for SharePoint and OneDrive locations actively scan new and modified files, automatically applying sensitivity labels when the policy conditions are met. Implementing at least one auto-labeling policy in enforcement mode for SharePoint and OneDrive ensures that file-based sensitive data is consistently classified.

.NOTES
    Test ID: 35021
    Pillar: Data
    Risk Level: High
#>

function Test-Assessment-35021 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35021,
        Title = 'Auto-Labeling Policies Enabled for SharePoint and OneDrive',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Auto-Labeling Policies for SharePoint and OneDrive'
    Write-ZtProgress -Activity $activity -Status 'Getting auto-labeling policies'

    $errorMsg = $null
    $allPolicies = @()

    try {
        # Get all auto-labeling policies
        $allPolicies = @(Get-AutoSensitivityLabelPolicy -ErrorAction Stop)
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying auto-labeling policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $customStatus = $null
    $spodPolicies = @()
    $enforcementPolicies = @()

    if ($errorMsg) {
        $passed = $false
        $customStatus = 'Investigate'
    }
    else {
        # Filter for policies targeting SharePoint or OneDrive
        foreach ($policy in $allPolicies) {
            if ($policy.Workload) {
                $workloadList = $policy.Workload -split ', ' | ForEach-Object { $_.Trim() }
                if ($workloadList -contains 'SharePoint' -or $workloadList -contains 'OneDriveForBusiness') {
                    $spodPolicies += $policy

                    # Check if enabled AND in enforcement mode
                    if ($policy.Enabled -eq $true -and $policy.Mode -eq 'Enable') {
                        $enforcementPolicies += $policy
                    }
                }
            }
        }

        # Pass if at least one policy is enabled and in enforcement mode
        $passed = $enforcementPolicies.Count -gt 0
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to determine SharePoint/OneDrive auto-labeling enforcement status due to error: $errorMsg"
    }
    else {
        $policyLink = "https://purview.microsoft.com/informationprotection/autolabeling"

        if ($passed) {
            $testResultMarkdown = "✅ $($enforcementPolicies.Count) auto-labeling $(if ($enforcementPolicies.Count -eq 1) { 'policy is' } else { 'policies are' }) enabled and in enforcement mode for SharePoint and/or OneDrive.`n`n"

            $testResultMarkdown += "### [Auto-Labeling Policies for SharePoint/OneDrive]($policyLink)`n`n"
            $testResultMarkdown += "| Policy Name | Description | Enabled | Mode | Workload | Created | Last Modified |`n"
            $testResultMarkdown += "| :--- | :--- | :---: | :--- | :--- | :--- | :--- |`n"

            foreach ($policy in $spodPolicies) {
                $policyName = Get-SafeMarkdown -Text $policy.Name
                $description = if ($policy.Comment) { Get-SafeMarkdown -Text $policy.Comment } else { '' }
                $enabled = if ($policy.Enabled) { '✅' } else { '❌' }
                $mode = if ($policy.Mode -eq 'Enable') { 'Enforcement' } elseif ($policy.Mode) { $policy.Mode } else { 'Unknown' }
                $workload = if ($policy.Workload) { $policy.Workload } else { 'Not specified' }
                $created = if ($policy.WhenCreatedUTC) { $policy.WhenCreatedUTC.ToString('yyyy-MM-dd') } else { 'Unknown' }
                $lastModified = if ($policy.WhenChangedUTC) { $policy.WhenChangedUTC.ToString('yyyy-MM-dd') } else { 'Unknown' }

                $testResultMarkdown += "| $policyName | $description | $enabled | $mode | $workload | $created | $lastModified |`n"
            }

            # Summary section
            $testResultMarkdown += "`n### Summary`n`n"
            $testResultMarkdown += "* **Total Policies Targeting SharePoint/OneDrive:** $($spodPolicies.Count)`n"

            # Count by status
            $disabledCount = ($spodPolicies | Where-Object { $_.Enabled -eq $false }).Count
            $simulationCount = ($spodPolicies | Where-Object { $_.Enabled -eq $true -and $_.Mode -ne 'Enable' }).Count
            $enforcementCount = $enforcementPolicies.Count

            $testResultMarkdown += "* **Policies in Enforcement Mode:** $enforcementCount`n"
            $testResultMarkdown += "* **Policies in Simulation Mode:** $simulationCount`n"
            $testResultMarkdown += "* **Policies Disabled:** $disabledCount`n"

            # Check workload coverage from enforcement policies
            $enforcementWorkloads = @()
            foreach ($policy in $enforcementPolicies) {
                if ($policy.Workload) {
                    $enforcementWorkloads += $policy.Workload -split ', ' | ForEach-Object { $_.Trim() }
                }
            }
            $enforcementWorkloads = $enforcementWorkloads | Select-Object -Unique

            $hasSharePoint = $enforcementWorkloads -contains 'SharePoint'
            $hasOneDrive = $enforcementWorkloads -contains 'OneDriveForBusiness'

            $testResultMarkdown += "* **SharePoint Coverage:** [$(if ($hasSharePoint) { 'Yes' } else { 'No' })]`n"
            $testResultMarkdown += "* **OneDrive Coverage:** [$(if ($hasOneDrive) { 'Yes' } else { 'No' })]`n"

            # Date range for enforcement activation
            $createdDates = $enforcementPolicies.WhenCreatedUTC | Where-Object { $_ } | Sort-Object
            if ($createdDates) {
                $oldest = $createdDates[0].ToString('yyyy-MM-dd')
                $newest = $createdDates[-1].ToString('yyyy-MM-dd')
                $testResultMarkdown += "* **Enforcement Activation Date Range:** $oldest to $newest`n"
            }
        }
        else {
            if ($spodPolicies.Count -eq 0) {
                $testResultMarkdown = "❌ No auto-labeling policies are configured for SharePoint or OneDrive.`n`n"
            }
            else {
                $testResultMarkdown = "❌ $($spodPolicies.Count) auto-labeling $(if ($spodPolicies.Count -eq 1) { 'policy targets' } else { 'policies target' }) SharePoint/OneDrive, but none are enabled and in enforcement mode.`n`n"

                $testResultMarkdown += "### [Auto-Labeling Policies for SharePoint/OneDrive]($policyLink)`n`n"
                $testResultMarkdown += "| Policy Name | Description | Enabled | Mode | Workload | Created | Last Modified |`n"
                $testResultMarkdown += "| :--- | :--- | :---: | :--- | :--- | :--- | :--- |`n"

                foreach ($policy in $spodPolicies) {
                    $policyName = Get-SafeMarkdown -Text $policy.Name
                    $description = if ($policy.Comment) { Get-SafeMarkdown -Text $policy.Comment } else { '' }
                    $enabled = if ($policy.Enabled) { '✅' } else { '❌' }
                    $mode = if ($policy.Mode -eq 'Enable') { 'Enforcement' } elseif ($policy.Mode) { $policy.Mode } else { 'Unknown' }
                    $workload = if ($policy.Workload) { $policy.Workload } else { 'Not specified' }
                    $created = if ($policy.WhenCreatedUTC) { $policy.WhenCreatedUTC.ToString('yyyy-MM-dd') } else { 'Unknown' }
                    $lastModified = if ($policy.WhenChangedUTC) { $policy.WhenChangedUTC.ToString('yyyy-MM-dd') } else { 'Unknown' }

                    $testResultMarkdown += "| $policyName | $description | $enabled | $mode | $workload | $created | $lastModified |`n"
                }

                # Summary section
                $testResultMarkdown += "`n### Summary`n`n"
                $testResultMarkdown += "* **Total Policies Targeting SharePoint/OneDrive:** $($spodPolicies.Count)`n"

                $disabledCount = ($spodPolicies | Where-Object { $_.Enabled -eq $false }).Count
                $simulationCount = ($spodPolicies | Where-Object { $_.Enabled -eq $true -and $_.Mode -ne 'Enable' }).Count

                $testResultMarkdown += "* **Policies in Enforcement Mode:** 0`n"
                $testResultMarkdown += "* **Policies in Simulation Mode:** $simulationCount`n"
                $testResultMarkdown += "* **Policies Disabled:** $disabledCount`n"
                $testResultMarkdown += "* **SharePoint Coverage:** [No]`n"
                $testResultMarkdown += "* **OneDrive Coverage:** [No]`n"
            }

            $testResultMarkdown += "`n### Recommendation`n`n"
            $testResultMarkdown += "Enable at least one auto-labeling policy in enforcement mode for SharePoint and/or OneDrive to automatically classify sensitive files. "
            $testResultMarkdown += "Visit the [Auto-labeling policies portal]($policyLink) to create or configure policies.`n"
        }
    }
    #endregion Report Generation

    $params = @{
        TestId = '35021'
        Title  = 'Auto-Labeling Policies Enabled for SharePoint and OneDrive'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
