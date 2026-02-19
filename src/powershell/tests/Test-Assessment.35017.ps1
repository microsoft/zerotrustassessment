<#
.SYNOPSIS
    A default sensitivity label is configured in label policies

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
        Title = 'A default sensitivity label is configured in label policies',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking default label configuration for sensitivity label policies'
    Write-ZtProgress -Activity $activity -Status 'Getting enabled label policies'

    $errorMsg = $null
    $enabledPolicies = @()

    try {
        # Q1: Retrieve all enabled sensitivity label policies to assess default label configuration
        $enabledPolicies = Get-LabelPolicy -ErrorAction Stop | Where-Object { $_.Enabled -eq $true }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying label policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $allPolicySettings = @()
    $policiesWithDefaults = @()
    $xmlParseErrors = @()
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        $testResultMarkdown = "⚠️ Unable to determine if default labels are configured due to error: $errorMsg`n`n%TestResult%"
        $customStatus = 'Investigate'
    }
    else {
        Write-PSFMessage "Found $($enabledPolicies.Count) enabled label policies" -Level Verbose

        try {
            # Examine label policy settings for default labels
            foreach ($policy in $enabledPolicies) {
                # Use common function to parse PolicySettingsBlob XML
                $parsedSettings = Get-LabelPolicySettings -PolicySettingsBlob $policy.PolicySettingsBlob -PolicyName $policy.Name

                # Track XML parsing errors
                if ($parsedSettings.ParseError) {
                    $xmlParseErrors += [PSCustomObject]@{
                        PolicyName = $policy.Name
                        Error      = $parsedSettings.ParseError
                    }
                }

                # Validate label IDs (TryParse handles $null and empty strings)
                $guid = [System.Guid]::Empty
                $hasDocumentDefault = [System.Guid]::TryParse($parsedSettings.DefaultLabelId, [ref]$guid)
                $hasOutlookDefault = [System.Guid]::TryParse($parsedSettings.OutlookDefaultLabel, [ref]$guid)
                $hasPowerBIDefault = [System.Guid]::TryParse($parsedSettings.PowerBIDefaultLabelId, [ref]$guid)
                $hasSiteGroupDefault = [System.Guid]::TryParse($parsedSettings.SiteAndGroupDefaultLabelId, [ref]$guid)

                $hasAnyDefault = $hasDocumentDefault -or $hasOutlookDefault -or $hasPowerBIDefault -or $hasSiteGroupDefault

                # Q2: Determine policy scope (Global vs User/Group-Scoped)
                # A policy is Global if ANY location property contains "All"
                $allLocationNames = @(
                    $policy.ExchangeLocation.Name
                    $policy.ModernGroupLocation.Name
                    $policy.SharePointLocation.Name
                    $policy.OneDriveLocation.Name
                    $policy.SkypeLocation.Name
                    $policy.PublicFolderLocation.Name
                ) | Where-Object { $_ }
                $isGlobal = $allLocationNames -contains 'All'

                $policyInfo = [PSCustomObject]@{
                    PolicyName           = $policy.Name
                    Guid                 = $policy.Guid
                    Enabled              = $policy.Enabled
                    DefaultLabelId       = $parsedSettings.DefaultLabelId
                    OutlookDefaultLabel  = $parsedSettings.OutlookDefaultLabel
                    PowerBIDefaultLabelId = $parsedSettings.PowerBIDefaultLabelId
                    SiteAndGroupDefaultLabel = $parsedSettings.SiteAndGroupDefaultLabelId
                    HasDocumentDefault   = $hasDocumentDefault
                    HasOutlookDefault    = $hasOutlookDefault
                    HasPowerBIDefault    = $hasPowerBIDefault
                    HasSiteGroupDefault  = $hasSiteGroupDefault
                    HasAnyDefault        = $hasAnyDefault
                    Scope                = if ($isGlobal) { 'Global' } else { 'User/Group-Scoped' }
                    LabelsCount          = $policy.Labels.Count
                }

                $allPolicySettings += $policyInfo

                if ($hasAnyDefault) {
                    $policiesWithDefaults += $policyInfo
                }
            }
        }
        catch {
            Write-PSFMessage "Error parsing label policy settings: $_" -Level Error
            $testResultMarkdown = "⚠️ Unable to determine default label status due to unexpected policy settings structure: $_`n`n%TestResult%"
            $customStatus = 'Investigate'
        }

        # Determine pass/fail status and message (only if no error occurred)
        if ($null -eq $customStatus) {
            if ($policiesWithDefaults.Count -gt 0) {
                $passed = $true
                $testResultMarkdown = "✅ Default labels are configured for at least one workload (Outlook, Teams/OneDrive, SharePoint/Microsoft 365 Groups, or Power BI) in at least one active sensitivity label policy.`n`n%TestResult%"
            }
            else {
                $passed = $false

                if ($enabledPolicies.Count -eq 0) {
                    $testResultMarkdown = "❌ No enabled sensitivity label policies were found in your tenant.`n`n%TestResult%"
                }
                else {
                    $testResultMarkdown = "❌ No sensitivity label policies have default labels configured for any workload.`n`n%TestResult%"
                }
            }
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Show table whenever we have policy settings
    if ($allPolicySettings.Count -gt 0) {
        # Build policy table
        $mdInfo += "`n`n### [Enabled label policies](https://purview.microsoft.com/informationprotection/labelpolicies)`n"
        $mdInfo += "| Policy name | Documents/Emails | Outlook | Power BI | SharePoint/Groups | Scope | Labels |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $allPolicySettings) {
            $policyName = Get-SafeMarkdown -Text $policy.PolicyName
            $docIcon = if ($policy.HasDocumentDefault) { '✅' } else { '❌' }
            $outlookIcon = if ($policy.HasOutlookDefault) { '✅' } else { '❌' }
            $powerBIIcon = if ($policy.HasPowerBIDefault) { '✅' } else { '❌' }
            $siteGroupIcon = if ($policy.HasSiteGroupDefault) { '✅' } else { '❌' }
            $mdInfo += "| $policyName | $docIcon | $outlookIcon | $powerBIIcon | $siteGroupIcon | $($policy.Scope) | $($policy.LabelsCount) |`n"
        }

        # Build summary metrics
        $docDefaultCount = ($policiesWithDefaults | Where-Object { $_.HasDocumentDefault }).Count
        $outlookDefaultCount = ($policiesWithDefaults | Where-Object { $_.HasOutlookDefault }).Count
        $powerBIDefaultCount = ($policiesWithDefaults | Where-Object { $_.HasPowerBIDefault }).Count
        $siteGroupDefaultCount = ($policiesWithDefaults | Where-Object { $_.HasSiteGroupDefault }).Count

        $mdInfo += "`n`n### Summary`n"
        $mdInfo += "| Metric | Count |`n"
        $mdInfo += "| :--- | :--- |`n"
        $mdInfo += "| Total enabled label policies | $($allPolicySettings.Count) |`n"
        $mdInfo += "| Policies with default labels | $($policiesWithDefaults.Count) |`n"
        $mdInfo += "| Documents/Emails default | $docDefaultCount |`n"
        $mdInfo += "| Outlook default | $outlookDefaultCount |`n"
        $mdInfo += "| Power BI default | $powerBIDefaultCount |`n"
        $mdInfo += "| SharePoint/Groups default | $siteGroupDefaultCount |"
    }

    # Report XML parsing errors if any occurred
    if ($xmlParseErrors.Count -gt 0) {
        $mdInfo += "`n`n### ⚠️ XML Parsing Errors`n"
        $mdInfo += "The following policies could not be parsed and were excluded from analysis:`n`n"
        $mdInfo += "| Policy Name | Error |`n"
        $mdInfo += "| :--- | :--- |`n"
        foreach ($parseError in $xmlParseErrors) {
            $errorMessage = Get-SafeMarkdown -Text $parseError.Error
            $policyName = Get-SafeMarkdown -Text $parseError.PolicyName
            $mdInfo += "| $policyName | $errorMessage |`n"
        }
        $mdInfo += "`n**Note**: These policies were treated as having no default labels configured.`n"
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
