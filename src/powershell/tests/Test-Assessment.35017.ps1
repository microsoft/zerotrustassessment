<#
.SYNOPSIS
    Validates that default labels are configured for sensitivity label policies.

.DESCRIPTION
    This test checks if sensitivity label policies have default labels configured
    for various workloads including documents/emails, Outlook, Power BI, and
    SharePoint sites/Microsoft 365 Groups.

.NOTES
    Test ID: 35017
    Category: Information Protection
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-35017 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35017,
        Title = 'Default label configured for sensitivity labels',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions
    function Get-DefaultLabelSettings {
        <#
        .SYNOPSIS
            Extracts default label settings from a label policy's Settings array.
        .PARAMETER Settings
            The Settings array from a label policy.
        .OUTPUTS
            PSCustomObject with default label settings for each workload.
        #>
        param(
            [Parameter(Mandatory = $true)]
            [AllowNull()]
            $Settings
        )

        $result = [PSCustomObject]@{
            DefaultLabelId           = $null
            OutlookDefaultLabel      = $null
            PowerBIDefaultLabelId    = $null
            SiteAndGroupDefaultLabel = $null
        }

        if (-not $Settings) {
            return $result
        }

        foreach ($setting in $Settings) {
            # Parse [key, value] format returned by Get-LabelPolicy
            $match = $setting -match '^\[(.*?),\s*(.+)\]$'
            if ($match) {
                $key = $matches[1].ToLower().Trim()
                $value = $matches[2].Trim()

                switch ($key) {
                    'defaultlabelid' { $result.DefaultLabelId = $value }
                    'outlookdefaultlabel' { $result.OutlookDefaultLabel = $value }
                    'powerbidefaultlabelid' { $result.PowerBIDefaultLabelId = $value }
                    'siteandgroupdefaultlabelid' { $result.SiteAndGroupDefaultLabel = $value }
                }
            }
        }

        return $result
    }

    function Test-ValidLabelId {
        <#
        .SYNOPSIS
            Checks if a label ID is a valid GUID and not empty.
        .PARAMETER LabelId
            The label ID to validate.
        .OUTPUTS
            Boolean indicating if the label ID is valid.
        #>
        param(
            [Parameter(Mandatory = $false)]
            [AllowNull()]
            [AllowEmptyString()]
            $LabelId
        )

        if ([string]::IsNullOrWhiteSpace($LabelId)) {
            return $false
        }

        # Check if it's a valid GUID format
        $guid = [System.Guid]::Empty
        return [System.Guid]::TryParse($LabelId, [ref]$guid)
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking default label configuration for sensitivity label policies'
    Write-ZtProgress -Activity $activity -Status 'Getting enabled label policies'

    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $policiesWithDefaults = @()
    $policiesWithoutDefaults = @()
    $totalEnabledPolicies = 0
    $errorMsg = $null
    $labelPolicies = @()

    # Query Q1: Get all enabled label policies
    try {
        $labelPolicies = Get-LabelPolicy -ErrorAction Stop | Where-Object { $_.Enabled -eq $true }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying label policies: $_" -Level Error
    }

    # Step 1: Check if any enabled policies exist
    if ($null -eq $errorMsg -and $labelPolicies -and $labelPolicies.Count -gt 0) {
        $totalEnabledPolicies = $labelPolicies.Count
        Write-ZtProgress -Activity $activity -Status "Analyzing $totalEnabledPolicies label policies"

        # Step 2: Analyze each policy for default label settings
        foreach ($policy in $labelPolicies) {
            $defaultSettings = Get-DefaultLabelSettings -Settings $policy.Settings

            $hasDocumentDefault = Test-ValidLabelId -LabelId $defaultSettings.DefaultLabelId
            $hasOutlookDefault = Test-ValidLabelId -LabelId $defaultSettings.OutlookDefaultLabel
            $hasPowerBIDefault = Test-ValidLabelId -LabelId $defaultSettings.PowerBIDefaultLabelId
            $hasSiteGroupDefault = Test-ValidLabelId -LabelId $defaultSettings.SiteAndGroupDefaultLabel

            $hasAnyDefault = $hasDocumentDefault -or $hasOutlookDefault -or $hasPowerBIDefault -or $hasSiteGroupDefault

            $policyInfo = [PSCustomObject]@{
                Name                     = $policy.Name
                Enabled                  = $policy.Enabled
                DefaultLabelId           = $defaultSettings.DefaultLabelId
                OutlookDefaultLabel      = $defaultSettings.OutlookDefaultLabel
                PowerBIDefaultLabelId    = $defaultSettings.PowerBIDefaultLabelId
                SiteAndGroupDefaultLabel = $defaultSettings.SiteAndGroupDefaultLabel
                HasDocumentDefault       = $hasDocumentDefault
                HasOutlookDefault        = $hasOutlookDefault
                HasPowerBIDefault        = $hasPowerBIDefault
                HasSiteGroupDefault      = $hasSiteGroupDefault
                HasAnyDefault            = $hasAnyDefault
                LabelsCount              = ($policy.Labels | Measure-Object).Count
            }

            if ($hasAnyDefault) {
                $policiesWithDefaults += $policyInfo
            }
            else {
                $policiesWithoutDefaults += $policyInfo
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $customStatus = $null

    if ($errorMsg) {
        $testResultMarkdown = "⚠️ Unable to determine if default labels are configured due to policy complexity, permissions issues, or unclear Settings structure.`n`n%TestResult%"
        $customStatus = 'Investigate'
    }
    elseif ($policiesWithDefaults.Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ Default labels are configured for at least one workload (Outlook, Teams/OneDrive, SharePoint/Microsoft 365 Groups, or Power BI) in at least one active sensitivity label policy.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ No sensitivity label policies have default labels configured for any workload.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''
    $allPolicies = $policiesWithDefaults + $policiesWithoutDefaults

    # Show table whenever we have policy settings
    if ($allPolicies.Count -gt 0) {
        # Build policy table
        $mdInfo += "`n`n### [Enabled label policies](https://purview.microsoft.com/informationprotection/labelpolicies)`n"
        $mdInfo += "| Policy name | Documents/Emails | Outlook | Power BI | SharePoint/Groups | Scope | Labels |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $allPolicies) {
            $policyName = Get-SafeMarkdown -Text $policy.Name
            $docIcon = if ($policy.HasDocumentDefault) { '✅' } else { '❌' }
            $outlookIcon = if ($policy.HasOutlookDefault) { '✅' } else { '❌' }
            $powerBIIcon = if ($policy.HasPowerBIDefault) { '✅' } else { '❌' }
            $siteGroupIcon = if ($policy.HasSiteGroupDefault) { '✅' } else { '❌' }
            $scope = if ($policy.Enabled) { 'Global' } else { 'Scoped' }
            $mdInfo += "| $policyName | $docIcon | $outlookIcon | $powerBIIcon | $siteGroupIcon | $scope | $($policy.LabelsCount) |`n"
        }

        # Build summary metrics
        $docDefaultCount = ($policiesWithDefaults | Where-Object { $_.HasDocumentDefault }).Count
        $outlookDefaultCount = ($policiesWithDefaults | Where-Object { $_.HasOutlookDefault }).Count
        $powerBIDefaultCount = ($policiesWithDefaults | Where-Object { $_.HasPowerBIDefault }).Count
        $siteGroupDefaultCount = ($policiesWithDefaults | Where-Object { $_.HasSiteGroupDefault }).Count

        $mdInfo += "`n`n### Summary`n"
        $mdInfo += "| Metric | Count |`n"
        $mdInfo += "| :--- | :--- |`n"
        $mdInfo += "| Total enabled label policies | $($allPolicies.Count) |`n"
        $mdInfo += "| Policies with default labels | $($policiesWithDefaults.Count) |`n"
        $mdInfo += "| Documents/Emails default | $docDefaultCount |`n"
        $mdInfo += "| Outlook default | $outlookDefaultCount |`n"
        $mdInfo += "| Power BI default | $powerBIDefaultCount |`n"
        $mdInfo += "| SharePoint/Groups default | $siteGroupDefaultCount |"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35017'
        Title  = 'Default label configured for sensitivity labels'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if status is 'Investigate'
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params

}
