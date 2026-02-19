<#
.SYNOPSIS
    Mandatory labeling is enabled in sensitivity label policies
#>

function Test-Assessment-35016 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce','External'),
        TestId = 35016,
        Title = 'Mandatory labeling is enabled in sensitivity label policies',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking mandatory labeling configuration'

    # Q1: Retrieve all enabled sensitivity label policies to assess mandatory labeling configuration
    Write-ZtProgress -Activity $activity -Status 'Getting sensitivity label policies'
    $errorMsg = $null
    $enabledPolicies = @()

    try {
        $enabledPolicies = Get-LabelPolicy -ErrorAction Stop | Where-Object { $_.Enabled -eq $true }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying label policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $allPolicySettings = @()
    $mandatoryPolicies = @()
    $xmlParseErrors = @()
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        $testResultMarkdown = "⚠️ Unable to determine auto-labeling enforcement mode status due to permissions issues or query failure.`n`n"
        $customStatus = 'Investigate'
    }
    else {
        Write-PSFMessage "Found $($enabledPolicies.Count) enabled label policies" -Level Verbose

        try {
            # Examine label policy settings for mandatory labeling
            foreach ($policy in $enabledPolicies) {
                # Determine policy scope:
                # - Global if any location is set to "All"
                # - Scoped if specific users/groups are defined
                $allLocationNames = @(
                    $policy.ExchangeLocation.Name
                    $policy.ModernGroupLocation.Name
                    $policy.SharePointLocation.Name
                    $policy.OneDriveLocation.Name
                    $policy.SkypeLocation.Name
                    $policy.PublicFolderLocation.Name
                ) | Where-Object { $_ }

                $isGlobal = $allLocationNames -contains 'All'

                $policySettings = @{
                    PolicyName = $policy.Name
                    Guid = $policy.Guid
                    Enabled = $policy.Enabled
                    EmailMandatory = $false
                    TeamworkMandatory = $false
                    SiteGroupMandatory = $false
                    PowerBIMandatory = $false
                    EmailOverride = $false
                    Scope = if ($isGlobal) { 'Global' } else { 'User/Group-scoped' }
                    LabelsCount = $policy.Labels.Count
                }

                # Parse PolicySettingsBlob XML for mandatory labeling flags
                if (-not [string]::IsNullOrWhiteSpace($policy.PolicySettingsBlob)) {
                    try {
                        $xmlSettings = [xml]$policy.PolicySettingsBlob

                        # Validate XML structure before accessing properties
                        if ($xmlSettings.settings -and $xmlSettings.settings.setting) {
                            # Access settings as XML elements for direct property lookup
                            foreach ($setting in $xmlSettings.settings.setting) {
                                # Add null safety for key and value attributes
                                if (-not $setting.key -or -not $setting.value) {
                                    Write-PSFMessage "Skipping setting with null key or value in policy '$($policy.Name)'" -Level Verbose
                                    continue
                                }

                                $key = $setting.key.ToLower()
                                $value = $setting.value.ToLower()

                                switch ($key) {
                                    'mandatory' {
                                        $policySettings.EmailMandatory = ($value -eq 'true')
                                    }
                                    'teamworkmandatory' {
                                        $policySettings.TeamworkMandatory = ($value -eq 'true')
                                    }
                                    'siteandgroupmandatory' {
                                        $policySettings.SiteGroupMandatory = ($value -eq 'true')
                                    }
                                    'powerbimandatory' {
                                        $policySettings.PowerBIMandatory = ($value -eq 'true')
                                    }
                                    'disablemandatoryinoutlook' {
                                        $policySettings.EmailOverride = ($value -eq 'true')
                                    }
                                    default {
                                        Write-PSFMessage "Unknown setting key '$key' in policy '$($policy.Name)'" -Level Verbose
                                    }
                                }
                            }
                        }
                        else {
                            Write-PSFMessage "Policy '$($policy.Name)' has PolicySettingsBlob but no settings elements found" -Level Verbose
                        }
                    }
                    catch {
                        # Track parsing errors for reporting
                        $xmlParseErrors += [PSCustomObject]@{
                            PolicyName = $policy.Name
                            Error = $_.Exception.Message
                        }
                        Write-PSFMessage "Error parsing PolicySettingsBlob XML for policy '$($policy.Name)': $_" -Level Warning
                    }
                }

                # Per Microsoft documentation, disablemandatoryinoutlook can be set to explicitly
                # disable mandatory labeling in Outlook even when the 'mandatory' setting is true.
                # This provides an exception path for organizations that need mandatory labeling
                # for files but not emails. Apply the override logic:
                if ($policySettings.EmailMandatory -and $policySettings.EmailOverride) {
                    $policySettings.EmailMandatory = $false
                }

                # Store all policy settings
                $allPolicySettings += [PSCustomObject]$policySettings

                # Determine if this policy has ANY mandatory setting enabled (after applying overrides)
                $hasMandatory = $policySettings.EmailMandatory -or
                                $policySettings.TeamworkMandatory -or
                                $policySettings.SiteGroupMandatory -or
                                $policySettings.PowerBIMandatory

                if ($hasMandatory) {
                    $mandatoryPolicies += [PSCustomObject]$policySettings
                }
            }
        }
        catch {
            Write-PSFMessage "Error parsing label policy settings: $_" -Level Error
            $testResultMarkdown = "⚠️ Unable to determine mandatory labeling status due to policy complexity or unclear Settings structure.`n`n"
            $customStatus = 'Investigate'
        }

        # Determine pass/fail status and message (only if no error occurred)
        if ($null -eq $customStatus) {
            if ($mandatoryPolicies.Count -gt 0) {
                $passed = $true
                $testResultMarkdown = "✅ Mandatory labeling is configured and enforced through at least one active sensitivity label policy across one or more workloads (Outlook, Teams/OneDrive, SharePoint/Microsoft 365 Groups, or Power BI).`n`n%TestResult%"
            }
            else {
                $passed = $false

                if ($enabledPolicies.Count -eq 0) {
                    $testResultMarkdown = "❌ No enabled sensitivity label policies were found in your tenant.`n`n%TestResult%"
                }
                else {
                    $testResultMarkdown = "❌ No sensitivity label policies require users to apply labels across any workload (emails, files, sites, groups, or Power BI content).`n`n%TestResult%"
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
        $mdInfo += "| Policy name | Email | Files/Collab | Sites/Groups | Power BI | Email override | Scope | Labels |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $allPolicySettings) {
            $policyName = Get-SafeMarkdown -Text $policy.PolicyName
            $emailIcon = if ($policy.EmailMandatory) { '✅' } else { '❌' }
            $teamworkIcon = if ($policy.TeamworkMandatory) { '✅' } else { '❌' }
            $siteGroupIcon = if ($policy.SiteGroupMandatory) { '✅' } else { '❌' }
            $powerBIIcon = if ($policy.PowerBIMandatory) { '✅' } else { '❌' }
            $overrideIcon = if ($policy.EmailOverride) { 'Yes' } else { 'No' }
            $mdInfo += "| $policyName | $emailIcon | $teamworkIcon | $siteGroupIcon | $powerBIIcon | $overrideIcon | $($policy.Scope) | $($policy.LabelsCount) |`n"
        }

        # Build summary metrics
        $emailCount = ($mandatoryPolicies | Where-Object { $_.EmailMandatory }).Count
        $teamworkCount = ($mandatoryPolicies | Where-Object { $_.TeamworkMandatory }).Count
        $siteGroupCount = ($mandatoryPolicies | Where-Object { $_.SiteGroupMandatory }).Count
        $powerBICount = ($mandatoryPolicies | Where-Object { $_.PowerBIMandatory }).Count

        $mdInfo += "`n`n### Summary`n"
        $mdInfo += "| Metric | Count |`n"
        $mdInfo += "| :--- | :--- |`n"
        $mdInfo += "| Total enabled label policies | $($allPolicySettings.Count) |`n"
        $mdInfo += "| Total enabled label policies with mandatory labeling | $($mandatoryPolicies.Count) |`n"
        $mdInfo += "| Email mandatory labeling | $emailCount |`n"
        $mdInfo += "| File/collaboration mandatory labeling | $teamworkCount |`n"
        $mdInfo += "| Site/group mandatory labeling | $siteGroupCount |`n"
        $mdInfo += "| Power BI mandatory labeling | $powerBICount |"
    }

    # Report XML parsing errors if any occurred
    if ($xmlParseErrors.Count -gt 0) {
        $mdInfo += "`n`n### ⚠️ XML parsing errors`n"
        $mdInfo += "The following policies could not be parsed and were excluded from analysis:`n`n"
        $mdInfo += "| Policy name | Error |`n"
        $mdInfo += "| :--- | :--- |`n"
        foreach ($error in $xmlParseErrors) {
            $errorMsg = Get-SafeMarkdown -Text $error.Error
            $policyName = Get-SafeMarkdown -Text $error.PolicyName
            $mdInfo += "| $policyName | $errorMsg |`n"
        }
        $mdInfo += "`n**Note**: These policies were treated as having no mandatory labeling configured.`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35016'
        Title  = 'Mandatory labeling enabled for sensitivity labels'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if status is 'Investigate'
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
