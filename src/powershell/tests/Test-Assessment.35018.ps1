<#
.SYNOPSIS
    Users must provide justification to downgrade sensitivity labels

.DESCRIPTION
    Sensitivity label policies should require users to provide justification when removing or downgrading labels. When downgrade justification is not required, users can silently reduce the classification level of sensitive content without creating an audit trail, creating compliance and audit risks.

.NOTES
    Test ID: 35018
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-35018 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35018,
        Title = 'Users must provide justification to downgrade sensitivity labels',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking downgrade justification required for sensitivity labels'
    Write-ZtProgress -Activity $activity -Status 'Checking downgrade justification'

    $enabledPolicies = @()
    $errorMsg = $null

    try {
        $enabledPolicies = Get-LabelPolicy -ErrorAction Stop | Where-Object { $_.Enabled -eq $true }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying label policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $policyResults = @()
    $policiesWithDowngradeJustification = @()
    $xmlParseErrors = @()
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine downgrade justification status due to error: $errorMsg`n`n"
    }
    else {
        foreach ($policy in $enabledPolicies) {

            $requireDowngradeJustification = $false

            if (-not [string]::IsNullOrWhiteSpace($policy.PolicySettingsBlob)) {
                try {
                    $xmlSettings = [xml]$policy.PolicySettingsBlob

                    if ($xmlSettings.settings -and $xmlSettings.settings.setting) {
                        foreach ($setting in $xmlSettings.settings.setting) {

                            if (-not $setting.key -or -not $setting.value) { continue }

                            if ($setting.key.ToLower() -eq 'requiredowngradejustification') {
                                $requireDowngradeJustification = ($setting.value.ToLower() -eq 'true')
                            }
                        }
                    }
                }
                catch {
                    $xmlParseErrors += [PSCustomObject]@{
                        PolicyName = $policy.Name
                        Error      = $_.Exception.Message
                    }
                }
            }

            # Determine scope
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

            # Determine workloads
            $workloads = @()
            if ($policy.ExchangeLocation)       { $workloads += 'Exchange' }
            if ($policy.SharePointLocation)     { $workloads += 'SharePoint' }
            if ($policy.OneDriveLocation)       { $workloads += 'OneDrive' }
            if ($policy.ModernGroupLocation)    { $workloads += 'M365 Groups' }
            if ($policy.PowerBILocation)        { $workloads += 'Power BI' }

            $policyResult = [PSCustomObject]@{
                PolicyName                    = $policy.Name
                PolicyGuid                    = $policy.Guid
                Enabled                       = $policy.Enabled
                RequireDowngradeJustification = $requireDowngradeJustification
                Scope                         =  if ($isGlobal) { 'Global' } else { 'Scoped' }
                LabelsCount                   = $policy.Labels.Count
                Workloads                     = ($workloads -join ', ')
            }

            $policyResults += $policyResult

            if ($requireDowngradeJustification) {
                $policiesWithDowngradeJustification += $policyResult
            }
        }

        if ($policiesWithDowngradeJustification.Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "✅ Downgrade justification is enforced in at least one enabled sensitivity label policy.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ No enabled sensitivity label policies require downgrade justification.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = "`n`n### Downgrade Justification Configuration`n"

    if ($policyResults.Count -gt 0) {
        $mdInfo += "| Policy name | Downgrade justification | Scope | Labels | Workloads |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $policyResults) {
            $policyName = Get-SafeMarkdown -Text $policy.PolicyName
            $policyUrl  = "https://purview.microsoft.com/informationprotection/labelpolicies"
            $icon = if ($policy.RequireDowngradeJustification) { '✅' } else { '❌' }

            $mdInfo += "| [$policyName]($policyUrl) | $icon | $($policy.Scope) | $($policy.LabelsCount) | $($policy.Workloads) |`n"
        }

        $percentage = if ($policyResults.Count -gt 0) {
            [Math]::Round(($policiesWithDowngradeJustification.Count / $policyResults.Count) * 100, 2)
        }
        else { 0 }

        $mdInfo += "`n### Summary`n"
        $mdInfo += "| Metric | Count |`n"
        $mdInfo += "| :--- | :--- |`n"
        $mdInfo += "| Total enabled label policies | $($policyResults.Count) |`n"
        $mdInfo += "| Policies requiring downgrade justification | $($policiesWithDowngradeJustification.Count) |`n"
        $mdInfo += "| Policies NOT requiring downgrade justification | $($policyResults.Count - $policiesWithDowngradeJustification.Count) |`n"
        $mdInfo += "| Percentage with downgrade justification | $percentage% |"
    }

    if ($xmlParseErrors.Count -gt 0) {
        $mdInfo += "`n`n### ⚠️ XML Parsing Errors`n"
        $mdInfo += "| Policy name | Error |`n"
        $mdInfo += "| :--- | :--- |`n"
        foreach ($err in $xmlParseErrors) {
            $mdInfo += "| $(Get-SafeMarkdown $err.PolicyName) | $(Get-SafeMarkdown $err.Error) |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35018'
        Title  = 'Downgrade Justification Required for Sensitivity Labels'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
