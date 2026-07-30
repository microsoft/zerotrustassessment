<#
.SYNOPSIS
    Application control is enforced via Intune.

.NOTES
    Test ID: 41052
    Required permission: DeviceManagementConfiguration.Read.All
#>

function Test-Assessment-41052 {
    [ZtTest(
        Category = 'Endpoint threat protection',
        CompatibleLicense = ('INTUNE_A'),
        ImplementationCost = 'High',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41052,
        Title = 'Application control (WDAC / App Control for Business) is enforced via Intune',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking App Control for Business policies'
    $queryError = $null
    $policies = @()

    Write-ZtProgress -Activity $activity -Status 'Getting Intune application control policies'
    try {
        $policies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/configurationPolicies' -ApiVersion beta -ErrorAction Stop |
            Where-Object { $_.templateReference.templateFamily -eq 'endpointSecurityApplicationControl' })
    }
    catch {
        $queryError = $_
        Write-PSFMessage "Failed to retrieve App Control for Business policies: $_" -Tag Test -Level Warning
    }

    if ($queryError) {
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $queryError
        if ($statusCode -in 401, 403, 404) {
            Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'Microsoft Graph returned HTTP 401, 403, or 404. Verify Intune licensing, user RBAC, and DeviceManagementConfiguration.Read.All consent.'
            return
        }

        $params = @{
            TestId       = '41052'
            Title        = 'Application control (WDAC / App Control for Business) is enforced via Intune'
            Status       = $false
            Result       = '⚠️ Intune App Control for Business policies could not be retrieved. Retry after resolving the Microsoft Graph error.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $policyResults = @()
    foreach ($policy in $policies) {
        try {
            Write-ZtProgress -Activity $activity -Status "Reading policy $($policy.name)"
            $assignments = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies('$($policy.id)')/assignments" -ApiVersion beta -ErrorAction Stop)
        }
        catch {
            $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($statusCode -in 401, 403, 404) {
                Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'Microsoft Graph returned HTTP 401, 403, or 404. Verify Intune licensing, user RBAC, and DeviceManagementConfiguration.Read.All consent.'
                return
            }

            Write-PSFMessage "Failed to retrieve assignments for App Control policy '$($policy.name)': $_" -Tag Test -Level Warning
            $policyResults += [pscustomobject]@{
                Name = $policy.name; TemplateFamily = $policy.templateReference.templateFamily; Mode = 'Unknown'
                PolicyId = $policy.id; Technologies = $policy.technologies; TemplateId = $policy.templateReference.templateId; Platforms = $policy.platforms
                AssignmentState = 'Unknown'; AssignmentCount = $null; LastModified = $policy.lastModifiedDateTime; Status = 'Investigate'
            }
            continue
        }

        try {
            $settings = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies('$($policy.id)')/settings" -ApiVersion beta -ErrorAction Stop)
        }
        catch {
            $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($statusCode -in 401, 403, 404) {
                Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'Microsoft Graph returned HTTP 401, 403, or 404. Verify Intune licensing, user RBAC, and DeviceManagementConfiguration.Read.All consent.'
                return
            }

            Write-PSFMessage "Failed to retrieve settings for App Control policy '$($policy.name)': $_" -Tag Test -Level Warning
            $assignmentCount = $assignments.Count
            $policyResults += [pscustomobject]@{
                Name = $policy.name; TemplateFamily = $policy.templateReference.templateFamily; Mode = 'Unknown'
                PolicyId = $policy.id; Technologies = $policy.technologies; TemplateId = $policy.templateReference.templateId; Platforms = $policy.platforms
                AssignmentState = if ($assignmentCount -gt 0) { 'Assigned' } else { 'Unassigned' }; AssignmentCount = $assignmentCount; LastModified = $policy.lastModifiedDateTime
                Status = if ($assignmentCount -gt 0) { 'Investigate' } else { 'Fail' }
            }
            continue
        }

        $getPolicyMode = {
            param($PolicySettings)

            $buildOptions = @($PolicySettings | Where-Object {
                $_.settingInstance.settingDefinitionId -match '(?i)device_vendor_msft_policy_config_applicationcontrol' -and
                $_.settingInstance.choiceSettingValue.value -match '(?i)_(built_in_controls|configure_xml|upload_xml)_selected$'
            })
            if ($buildOptions.Count -ne 1) {
                return 'Unknown'
            }

            $buildOption = $buildOptions[0].settingInstance
            $buildOptionValue = [string]$buildOption.choiceSettingValue.value
            $instances = [System.Collections.Queue]::new()
            foreach ($child in @($buildOption.choiceSettingValue.children)) {
                if ($null -ne $child) {
                    $instances.Enqueue($child)
                }
            }

            if ($buildOptionValue -match '(?i)_built_in_controls_selected$') {
                $observedModes = @()
                while ($instances.Count -gt 0) {
                    $instance = $instances.Dequeue()
                    $settingId = [string]$instance.settingDefinitionId
                    $choiceValue = [string]$instance.choiceSettingValue.value
                    if ($settingId -eq 'device_vendor_msft_policy_config_applicationcontrol_enable_app_control') {
                        if ($choiceValue -eq 'device_vendor_msft_policy_config_applicationcontrol_enable_app_control_audit_only') {
                            $observedModes += 'Audit'
                        }
                        elseif ($choiceValue -eq 'device_vendor_msft_policy_config_applicationcontrol_enable_app_control_enabled') {
                            $observedModes += 'Enforce'
                        }
                    }

                    foreach ($child in @($instance.choiceSettingValue.children)) {
                        if ($null -ne $child) {
                            $instances.Enqueue($child)
                        }
                    }
                }

                $observedModes = @($observedModes | Select-Object -Unique)
                if ($observedModes.Count -eq 1) {
                    return $observedModes[0]
                }
                return 'Unknown'
            }

            $xmlModes = @()
            while ($instances.Count -gt 0) {
                $instance = $instances.Dequeue()
                $settingId = [string]$instance.settingDefinitionId
                $xmlValue = if ($settingId -match '(?i)applicationcontrol') {
                    [string]$instance.simpleSettingValue.value
                }

                if (-not [string]::IsNullOrWhiteSpace($xmlValue)) {
                    $xmlCandidates = @($xmlValue)
                    try {
                        $bytes = [Convert]::FromBase64String($xmlValue)
                        $xmlCandidates += [Text.Encoding]::UTF8.GetString($bytes)
                        $xmlCandidates += [Text.Encoding]::Unicode.GetString($bytes)
                        $xmlCandidates += [Text.Encoding]::BigEndianUnicode.GetString($bytes)
                    }
                    catch {
                        Write-PSFMessage "App Control policy XML value could not be decoded as Base64: $_" -Tag Test -Level VeryVerbose
                    }

                    foreach ($xmlCandidate in $xmlCandidates) {
                        try {
                            [xml]$policyXml = $xmlCandidate
                            if ($policyXml.DocumentElement.LocalName -ne 'SiPolicy') {
                                continue
                            }

                            $policyTypeNode = $policyXml.SelectSingleNode("//*[local-name()='PolicyType']")
                            if ($null -eq $policyTypeNode -or $policyTypeNode.InnerText.Trim() -ne 'Base Policy') {
                                continue
                            }

                            $auditOption = @($policyXml.SelectNodes("//*[local-name()='Option']") | Where-Object {
                                $_.InnerText.Trim() -eq 'Enabled:Audit Mode'
                            }).Count -gt 0
                            $xmlModes += if ($auditOption) { 'Audit' } else { 'Enforce' }
                            break
                        }
                        catch {
                            Write-PSFMessage "App Control policy XML value could not be parsed: $_" -Tag Test -Level VeryVerbose
                        }
                    }
                }

                foreach ($child in @($instance.choiceSettingValue.children)) {
                    if ($null -ne $child) {
                        $instances.Enqueue($child)
                    }
                }
            }

            $xmlModes = @($xmlModes | Select-Object -Unique)
            if ($xmlModes.Count -eq 1) {
                return $xmlModes[0]
            }
            return 'Unknown'
        }

        $mode = & $getPolicyMode $settings
        $assignmentCount = $assignments.Count
        $status = if ($assignmentCount -eq 0) { 'Fail' } elseif ($mode -eq 'Enforce') { 'Pass' } elseif ($mode -eq 'Unknown') { 'Investigate' } else { 'Fail' }

        $policyResults += [pscustomobject]@{
            Name = $policy.name; TemplateFamily = $policy.templateReference.templateFamily; Mode = $mode
            PolicyId = $policy.id; Technologies = $policy.technologies; TemplateId = $policy.templateReference.templateId; Platforms = $policy.platforms
            AssignmentState = if ($assignmentCount -gt 0) { 'Assigned' } else { 'Unassigned' }; AssignmentCount = $assignmentCount; LastModified = $policy.lastModifiedDateTime; Status = $status
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $enforcedPolicies = @($policyResults | Where-Object { $_.Status -eq 'Pass' })
    $unknownPolicies = @($policyResults | Where-Object { $_.Status -eq 'Investigate' })
    $passed = $enforcedPolicies.Count -gt 0
    $customStatus = $null

    if ($passed) {
        $testResultMarkdown = "✅ An App Control for Business policy is configured, enforced, and assigned in Microsoft Intune.`n`n%TestResult%"
    }
    elseif ($unknownPolicies.Count -gt 0) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ An App Control for Business policy was returned, but its assignment or enforcement mode could not be determined from the returned data.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No App Control for Business policies were returned, no policies are assigned, or all assigned policies are audit-only.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalUrl = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/appControl'
    $tableRows = @($policyResults | Select-Object -First 10 | ForEach-Object {
        $lastModified = if ($_.LastModified) { Get-FormattedDate -DateString $_.LastModified } else { '—' }
        $policyName = (Get-SafeMarkdown $_.Name) -replace '\|', '\\|'
        $encodedTechnologies = ([string]$_.Technologies) -replace ',', '%2C'
        $policyLink = "https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/PolicySummaryBlade/policyId/$($_.PolicyId)/technology/$encodedTechnologies/templateId/$($_.TemplateId)/platformName/$($_.Platforms)"
        "| [$policyName]($policyLink) | $($_.TemplateFamily) | $($_.Mode) | $($_.AssignmentState) | $($_.AssignmentCount) | $lastModified | $($_.Status) |"
    })
    if ($policyResults.Count -gt 10) {
        $tableRows += "| ... | | | | | | $($policyResults.Count) total policies |"
    }
    if ($tableRows.Count -eq 0) {
        $tableRows = '| No App Control for Business policies found | endpointSecurityApplicationControl | — | — | 0 | — | Fail |'
    }

    $mdInfo = @"

## [Intune App Control for Business]($portalUrl)

| Policy Name | Template Family | Mode | Assignment State | Assignment Count | Last Modified | Status |
| :---------- | :-------------- | :--- | :--------------- | ---------------: | :------------ | :----- |
$($tableRows -join "`n")
"@
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    $params = @{
        TestId = '41052'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params

    #endregion Report Generation
}
