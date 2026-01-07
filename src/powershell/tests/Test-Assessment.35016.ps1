<#
.SYNOPSIS
    Mandatory Labeling Enabled for Sensitivity Labels
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
        Title = 'Mandatory labeling enabled for sensitivity labels',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking mandatory labeling configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting sensitivity label policies'

    $errorMsg = $null
    $enabledPolicies = @()

    try {
        # Q1: Get all enabled label policies
        $enabledPolicies = Get-LabelPolicy -ErrorAction Stop | Where-Object { $_.Enabled -eq $true }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying label policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $mandatoryPolicies = @()
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        $testResultMarkdown = "⚠️ Unable to determine mandatory labeling status due to error: $errorMsg`n`n"
        $customStatus = 'Investigate'
    }
    else {
        Write-PSFMessage "Found $($enabledPolicies.Count) enabled label policies" -Level Verbose

        try {
            # Examine label policy settings for mandatory labeling
            foreach ($policy in $enabledPolicies) {
                $policySettings = @{
                    PolicyName = $policy.Name
                    Guid = $policy.Guid
                    Enabled = $policy.Enabled
                    EmailMandatory = $false
                    TeamworkMandatory = $false
                    SiteGroupMandatory = $false
                    PowerBIMandatory = $false
                    EmailOverride = $false
                    Scope = if ($policy.IsGlobalPolicy) { 'Global' } else { 'Scoped' }
                    LabelsCount = $policy.Labels.Count
                }

                # Parse Settings array for mandatory labeling flags
                if ($policy.Settings -and $policy.Settings.Count -gt 0) {
                    foreach ($setting in $policy.Settings) {
                        # Settings are stored as key=value pairs
                        $key = $setting.Key
                        $value = $setting.Value

                        switch ($key) {
                            'mandatory' {
                                $policySettings.EmailMandatory = ($value -eq $true)
                            }
                            'teamworkmandatory' {
                                $policySettings.TeamworkMandatory = ($value -eq $true)
                            }
                            'siteandgroupmandatory' {
                                $policySettings.SiteGroupMandatory = ($value -eq $true)
                            }
                            'powerbimandatory' {
                                $policySettings.PowerBIMandatory = ($value -eq $true)
                            }
                            'disablemandatoryinoutlook' {
                                $policySettings.EmailOverride = ($value -eq $true)
                            }
                        }
                    }
                }

                # Email mandatory should not be overridden
                if ($policySettings.EmailMandatory -and $policySettings.EmailOverride) {
                    $policySettings.EmailMandatory = $false
                }

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
            $testResultMarkdown = "⚠️ Unable to determine mandatory labeling status due to unexpected policy settings structure: $_`n`n"
            $customStatus = 'Investigate'
        }

        # Determine pass/fail status and message (only if no error occurred)
        if ($null -eq $customStatus) {
            if ($mandatoryPolicies.Count -gt 0) {
                $passed = $true
                $testResultMarkdown = "✅ Mandatory labeling is configured and enforced through at least one active sensitivity label policy across one or more workloads (Outlook, Teams/OneDrive, SharePoint/Microsoft 365 Groups, or Power BI).`n`n"
            }
            else {
                $passed = $false

                if ($enabledPolicies.Count -eq 0) {
                    $testResultMarkdown = "❌ No enabled sensitivity label policies were found in your tenant.`n`n"
                }
                else {
                    $testResultMarkdown = "❌ No sensitivity label policies require users to apply labels across any workload (emails, files, sites, groups, or Power BI content).`n`n"
                    $testResultMarkdown += "**Total enabled label policies:** $($enabledPolicies.Count)`n`n"
                }
            }
        }
    }

    #endregion Assessment Logic

    #region Report Generation
    # Add detailed statistics for passing tests
    if ($passed) {
        # Build Mandatory Labeling Policies table
        $testResultMarkdown += "**[Mandatory Labeling Policies](https://purview.microsoft.com/informationprotection/labelpolicies):**`n`n"
        $testResultMarkdown += "| Policy name | Email | Files/Collab | Sites/Groups | Power BI | Email override | Scope | Labels |`n"
        $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $mandatoryPolicies) {
            $policyName = Get-SafeMarkdown -Text $policy.PolicyName

            $emailIcon = if ($policy.EmailMandatory) { "✅" } else { "❌" }
            $teamworkIcon = if ($policy.TeamworkMandatory) { "✅" } else { "❌" }
            $siteGroupIcon = if ($policy.SiteGroupMandatory) { "✅" } else { "❌" }
            $powerBIIcon = if ($policy.PowerBIMandatory) { "✅" } else { "❌" }
            $overrideIcon = if ($policy.EmailOverride) { "⚠️ Yes" } else { "No" }

            $testResultMarkdown += "| $policyName | $emailIcon | $teamworkIcon | $siteGroupIcon | $powerBIIcon | $overrideIcon | $($policy.Scope) | $($policy.LabelsCount) |`n"
        }

        # Summary statistics
        $emailCount = ($mandatoryPolicies | Where-Object { $_.EmailMandatory }).Count
        $teamworkCount = ($mandatoryPolicies | Where-Object { $_.TeamworkMandatory }).Count
        $siteGroupCount = ($mandatoryPolicies | Where-Object { $_.SiteGroupMandatory }).Count
        $powerBICount = ($mandatoryPolicies | Where-Object { $_.PowerBIMandatory }).Count

        $testResultMarkdown += "`n**Summary:**`n"
        $testResultMarkdown += "- Total enabled label policies: $($enabledPolicies.Count)`n"
        $testResultMarkdown += "- Policies with email mandatory labeling: $emailCount`n"
        $testResultMarkdown += "- Policies with file/collaboration mandatory labeling: $teamworkCount`n"
        $testResultMarkdown += "- Policies with site/group mandatory labeling: $siteGroupCount`n"
        $testResultMarkdown += "- Policies with Power BI mandatory labeling: $powerBICount`n"
    }
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
