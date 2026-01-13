<#
.SYNOPSIS
    Auto-Labeling Policies Configured (All Workloads)

.DESCRIPTION
    When auto-labeling policies are not configured, organizations cannot automatically classify content based on sensitive information types, patterns, or conditions. This creates a significant compliance and security gap because sensitive data relies entirely on manual user action for classification. Auto-labeling policies intelligently classify content across all workloads (Outlook emails, Exchange mailboxes, SharePoint sites, OneDrive accounts, Teams channels, and Power BI) based on content inspection. Configuring at least one auto-labeling policy for the organization's most sensitive data types is the foundation for consistent automated classification.

.NOTES
    Test ID: 35019
    Pillar: Data
    Risk Level: High
#>

function Test-Assessment-35019 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35019,
        Title = 'Auto-Labeling Policies Configured (All Workloads)',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Auto-Labeling Policies'
    Write-ZtProgress -Activity $activity -Status 'Getting auto-labeling policies'

    $errorMsg = $null
    $policies = @()

    try {
        # Get all auto-labeling policies
        $policies = @(Get-AutoSensitivityLabelPolicy -ErrorAction Stop)
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying auto-labeling policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $customStatus = $null
    if ($errorMsg) {
        $passed = $false
        $customStatus = 'Investigate'
    }
    else {
        $passed = $policies.Count -gt 0
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to determine auto-labeling policy status due to error: $errorMsg"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ $($policies.Count) auto-labeling $(if ($policies.Count -eq 1) { 'policy exists' } else { 'policies exist' }) in the organization, enabling automatic content classification.`n`n"

            $policyLink = "https://purview.microsoft.com/informationprotection/autolabeling"

            $testResultMarkdown += "### [Auto-Labeling Policies]($policyLink)`n`n"
            $testResultMarkdown += "| Policy Name | Description | Enabled | Mode | Workload | Created | Last Modified |`n"
            $testResultMarkdown += "| :--- | :--- | :---: | :--- | :--- | :--- | :--- |`n"

            foreach ($policy in $policies) {
                $policyName = Get-SafeMarkdown -Text $policy.Name
                $description = if ($policy.Comment) { Get-SafeMarkdown -Text $policy.Comment } else { '' }
                $enabled = if ($policy.Enabled) { '✅' } else { '❌' }
                $mode = if ($policy.Mode) { $policy.Mode } else { 'Unknown' }
                $workload = if ($policy.Workload) { $policy.Workload } else { 'Not specified' }
                $created = if ($policy.WhenCreatedUTC) { $policy.WhenCreatedUTC.ToString('yyyy-MM-dd') } else { 'Unknown' }
                $lastModified = if ($policy.WhenChangedUTC) { $policy.WhenChangedUTC.ToString('yyyy-MM-dd') } else { 'Unknown' }

                $testResultMarkdown += "| $policyName | $description | $enabled | $mode | $workload | $created | $lastModified |`n"
            }

            # Summary section
            $testResultMarkdown += "`n### Summary`n`n"
            $testResultMarkdown += "* **Total Auto-Labeling Policies:** $($policies.Count)`n"

            # Check which workloads are covered
            $workloads = $policies.Workload | Where-Object { $_ } | Select-Object -Unique
            $workloads = $workloads -split ', ' | ForEach-Object { $_.Trim() } | Select-Object -Unique
            $testResultMarkdown += "`n**Workloads with Auto-Labeling Policies:**`n"
            $hasExchange = $workloads -contains 'Exchange'
            $hasSharePoint = $workloads -contains 'SharePoint'
            $hasOneDrive = $workloads -contains 'OneDriveForBusiness'
            $hasTeams = $workloads -contains 'Teams'
            $hasPowerBI = $workloads -contains 'PowerBI'

            $testResultMarkdown += "* Exchange/Outlook: [$(if ($hasExchange) { 'Yes' } else { 'No' })]`n"
            $testResultMarkdown += "* SharePoint: [$(if ($hasSharePoint) { 'Yes' } else { 'No' })]`n"
            $testResultMarkdown += "* OneDrive: [$(if ($hasOneDrive) { 'Yes' } else { 'No' })]`n"
            $testResultMarkdown += "* Teams: [$(if ($hasTeams) { 'Yes' } else { 'No' })]`n"
            $testResultMarkdown += "* Power BI: [$(if ($hasPowerBI) { 'Yes' } else { 'No' })]`n"

            # Date range
            $createdDates = $policies.WhenCreatedUTC | Where-Object { $_ } | Sort-Object
            if ($createdDates) {
                $oldest = $createdDates[0].ToString('yyyy-MM-dd')
                $newest = $createdDates[-1].ToString('yyyy-MM-dd')
                $testResultMarkdown += "`n* **Policy Creation Date Range:** $oldest to $newest`n"
            }

            $testResultMarkdown += "`n💡 **Note:** This test validates policy existence only. Test 35020 validates that at least one policy is in enforcement mode.`n"
        }
        else {
            $testResultMarkdown = "❌ No auto-labeling policies are configured in the organization.`n`n"
            $testResultMarkdown += "### Recommendation`n`n"
            $testResultMarkdown += "Configure auto-labeling policies to automatically classify content based on sensitive information types. "
            $testResultMarkdown += "Visit the [Auto-labeling policies portal](https://purview.microsoft.com/informationprotection/autolabeling) to create policies.`n"
        }
    }
    #endregion Report Generation

    $params = @{
        TestId = '35019'
        Title  = 'Auto-Labeling Policies Configured (All Workloads)'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
