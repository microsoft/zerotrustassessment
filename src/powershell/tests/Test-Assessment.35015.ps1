<#
.SYNOPSIS
    Globally published sensitivity labels don't exceed the recommended maximum

.DESCRIPTION
    Sensitivity label policies control which labels are available to users and can be scoped to specific users, groups, or the entire organization. Publishing too many labels globally creates confusion and decision paralysis for end users. Microsoft recommends publishing no more than 25 labels in globally-scoped policies to maintain usability and reduce misclassification.

.NOTES
    Test ID: 35015
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-35015 {
    [ZtTest(
        Category = 'sensitivity-labels',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35015,
        Title = 'Globally published sensitivity labels don''t exceed the recommended maximum',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Global Scope Label Count'

    # Q1: Get all enabled label policies
    Write-ZtProgress -Activity $activity -Status 'Getting label policies'

    $errorMsg = $null
    $maxRecommendedLabels = 25

    try {
        # Get all enabled label policies
        $labelPolicies = Get-LabelPolicy -ErrorAction Stop | Where-Object { $_.Enabled -eq $true }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying label policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $customStatus = $null
    if ($errorMsg) {
        $testResultMarkdown = "⚠️ Unable to determine global label count due to permissions issues or query failure.`n`n"
        $customStatus = 'Investigate'
    }
    else {
        # Identify globally-scoped policies by checking all location names
        $globalPolicies = $labelPolicies | ForEach-Object {
            $policy = $_
            $allLocationNames = @(
                $policy.ExchangeLocation.Name
                $policy.ModernGroupLocation.Name
                $policy.SharePointLocation.Name
                $policy.OneDriveLocation.Name
                $policy.SkypeLocation.Name
                $policy.PublicFolderLocation.Name
            ) | Where-Object { $_ }
            $isGlobal = $allLocationNames -contains 'All'
            $scope = if ($isGlobal) { 'Global' } else { 'User/Group-Scoped' }

            $policy | Add-Member -MemberType NoteProperty -Name 'Scope' -Value $scope -PassThru
        } | Where-Object { $_.Scope -eq 'Global' }
        $uniqueLabels = $globalPolicies.Labels | Where-Object { $_ } | Select-Object -Unique
        $totalUniqueLabels = @($uniqueLabels).Count
        $passed = $totalUniqueLabels -le $maxRecommendedLabels
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to determine global label count due to error: $errorMsg"
    }
    else {
        $status = if ($passed) { '✅' } else { '❌' }
        $statusText = if ($passed) { 'within' } else { 'exceeding' }
        $testResultMarkdown = "$status $totalUniqueLabels sensitivity labels are published in globally-scoped policies, $statusText the recommended limit of $maxRecommendedLabels.`n`n"

        if ($globalPolicies) {
            $testResultMarkdown += "### [Global Label Policies](https://purview.microsoft.com/informationprotection/labelpolicies)`n`n"
            $testResultMarkdown += "| Policy Name | Global Workloads | Labels Published | Sample Labels |`n"
            $testResultMarkdown += "| :--- | :--- | :---: | :--- |`n"

            $policyLink = "https://purview.microsoft.com/informationprotection/labelpolicies"

            foreach ($policy in $globalPolicies) {
                $policyName = Get-SafeMarkdown -Text $policy.Name
                $labelCount = @($policy.Labels).Count

                # Identify which workloads have "All" (Location Properties with "All")
                $globalWorkloads = @()
                if ($policy.ExchangeLocation.Name -contains 'All') { $globalWorkloads += 'Exchange' }
                if ($policy.SharePointLocation.Name -contains 'All') { $globalWorkloads += 'SharePoint' }
                if ($policy.OneDriveLocation.Name -contains 'All') { $globalWorkloads += 'OneDrive' }
                if ($policy.ModernGroupLocation.Name -contains 'All') { $globalWorkloads += 'ModernGroup' }
                if ($policy.SkypeLocation.Name -contains 'All') { $globalWorkloads += 'Skype' }

                $workloadsText = if ($globalWorkloads.Count -gt 0) {
                    $globalWorkloads -join ', '
                } else { 'None' }

                # Get sample labels (up to 5)
                $sampleLabels = if ($policy.Labels) {
                    $samples = @($policy.Labels | Select-Object -First 5)
                    $labelText = ($samples | ForEach-Object { Get-SafeMarkdown -Text $_ }) -join ', '
                    if (@($policy.Labels).Count -gt 5) { $labelText += ', ...' }
                    $labelText
                } else { 'None' }

                $testResultMarkdown += "| [$policyName]($policyLink) | $workloadsText | $labelCount | $sampleLabels |`n"
            }

            $statusText = if ($passed) { 'Pass' } else { 'Fail' }
            $testResultMarkdown += "`n### Summary`n`n"
            $testResultMarkdown += "* **Total Unique Labels Published Globally:** $totalUniqueLabels`n"
            $testResultMarkdown += "* **Recommended Maximum:** $maxRecommendedLabels`n"
            $testResultMarkdown += "* **Status:** $statusText`n"
            $testResultMarkdown += "`n*Note: Labels appearing in multiple global policies are counted once (deduplicated).*`n"
        } else {
            $testResultMarkdown += "No globally-scoped label policies found.`n"
        }
    }
    #endregion Report Generation

    $params = @{
        TestId = '35015'
        Title  = 'Global Scope Label Count'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
