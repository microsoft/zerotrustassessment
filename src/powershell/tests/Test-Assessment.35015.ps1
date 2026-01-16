<#
.SYNOPSIS
    Global Scope Label Count

.DESCRIPTION
    Sensitivity label policies control which labels are available to users and can be scoped to specific users, groups, or the entire organization. Publishing too many labels globally creates confusion and decision paralysis for end users. Microsoft recommends publishing no more than 25 labels in globally-scoped policies to maintain usability and reduce misclassification.

.NOTES
    Test ID: 35015
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-35015 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35015,
        Title = 'Global Scope Label Count',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Global Scope Label Count'
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
        $passed = $false
        $customStatus = 'Investigate'
    }
    else {
        # Identify globally-scoped policies (no specific user/group scope or applies to 'All')
        $globalPolicies = $labelPolicies | Where-Object {
            ($_.ExchangeLocation    -contains 'All') -or
            ($_.ModernGroupLocation -contains 'All') -or
            ($_.SharePointLocation  -contains 'All') -or
            ($_.OneDriveLocation    -contains 'All') -or
            (
                (-not $_.ModernGroupLocation  -or $_.ModernGroupLocation.Count  -eq 0) -and
                (-not $_.ExchangeLocation     -or $_.ExchangeLocation.Count     -eq 0) -and
                (-not $_.SharePointLocation   -or $_.SharePointLocation.Count   -eq 0) -and
                (-not $_.OneDriveLocation     -or $_.OneDriveLocation.Count     -eq 0)
            )
        }
        $uniqueLabels = $globalPolicies.Labels | Where-Object { $_ } | Select-Object -Unique
        $totalUniqueLabels = $uniqueLabels.Count
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
            $testResultMarkdown += "### Global Label Policies`n`n"
            $testResultMarkdown += "| Policy Name | Status | Labels Published | Sample Labels |`n"
            $testResultMarkdown += "| :--- | :--- | :---: | :--- |`n"

            $policyLink = "https://purview.microsoft.com/informationprotection/labelpolicies"

            foreach ($policy in $globalPolicies) {
                $policyName = Get-SafeMarkdown -Text $policy.Name
                $labelCount = @($policy.Labels).Count

                # Get sample labels (up to 5)
                $sampleLabels = if ($policy.Labels) {
                    $samples = @($policy.Labels | Select-Object -First 5)
                    $labelText = ($samples | ForEach-Object { Get-SafeMarkdown -Text $_ }) -join ', '
                    if (@($policy.Labels).Count -gt 5) { $labelText += ', ...' }
                    $labelText
                } else { 'None' }

                $testResultMarkdown += "| [$policyName]($policyLink) | Enabled | $labelCount | $sampleLabels |`n"
            }

            $statusText = if ($passed) { 'Pass' } else { 'Fail' }
            $testResultMarkdown += "`n### Summary`n`n"
            $testResultMarkdown += "* **Total Unique Labels Published Globally:** $totalUniqueLabels`n"
            $testResultMarkdown += "* **Recommended Maximum:** $maxRecommendedLabels`n"
            $testResultMarkdown += "* **Status:** $statusText`n"
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
