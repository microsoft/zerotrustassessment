<#
.SYNOPSIS
    Windows App Control for Business (WDAC) is configured and assigned via Intune

.DESCRIPTION
    Checks whether at least one Intune App Control for Business policy is configured with a build option
    (Microsoft built-in controls, configure XML, or upload XML) and assigned to managed Windows devices.
    Without App Control for Business, every executable a user can drop onto disk can run with the user's
    full token before any EDR signal fires. App Control disrupts this kill chain at the kernel level by
    establishing a Windows code-integrity policy that only permits executables signed by trusted publishers,
    on a trusted file path, or specifically allow-listed by the organization to run.

.NOTES
    Test ID: 51018
    Category: Devices
    Pillar: Devices
    Required APIs:
      Q1: GET beta/deviceManagement/managedDevices?$filter=operatingSystem eq 'Windows'&$top=1
      Q2: Export DB — ConfigurationPolicy (templateReference.templateFamily = 'endpointSecurityApplicationControl')
    Required Permissions: DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All
#>

function Test-Assessment-51018 {
    [ZtTest(
        Category = 'Devices',
        CompatibleLicense = ('INTUNE_A'),
        ImplementationCost = 'Medium',
        Pillar = 'Devices',
        RiskLevel = 'High',
        SfiPillar = 'Protect engineering systems',
        TenantType = ('Workforce'),
        TestId = 51018,
        Title = 'Windows App Control for Business (WDAC) is configured and assigned via Intune',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking that Windows App Control for Business policies are configured and assigned'
    $investigateMsg = 'The Intune App Control for Business policies API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions — Global Reader at tenant scope.'

    # Q1: Count enrolled Windows devices to determine if the check is in scope.
    # If zero Windows devices are enrolled, the check is reported as Skipped.
    Write-ZtProgress -Activity $activity -Status 'Checking enrolled Windows devices'
    $windowsDeviceCount = 0
    $q1Error = $false

    try {
        $windowsResult = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDevices' -Filter "operatingSystem eq 'Windows'" -Select 'id' -Top 1 -QueryParameters @{'$count' = 'true'} -ApiVersion beta -DisablePaging -ErrorAction Stop
        $windowsDeviceCount = $windowsResult.'@odata.count'
    }
    catch {
        $q1Error = $true
        Write-PSFMessage "Windows enrolled-device query (Q1) failed: $_" -Tag Test -Level Warning
    }

    # If Q1 failed, scope cannot be determined — stop early.
    if ($q1Error) {
        $params = @{
            TestId       = '51018'
            Title        = 'Windows App Control for Business (WDAC) is configured and assigned via Intune'
            Status       = $false
            Result       = '⚠️ Unable to retrieve enrolled Windows device count due to API access error. Coverage could not be determined. Verify DeviceManagementManagedDevices.Read.All permission is granted and retry.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Guard: Skip if no Windows devices are enrolled.
    if ($windowsDeviceCount -eq 0) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Windows devices are enrolled in this tenant.'
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Getting App Control for Business policies'

    # Q2: Retrieve all Intune Settings Catalog configuration policies in the App Control for Business template family.
    $q2Error = $false
    try {
        $sql = @"
    SELECT id, name, platforms, technologies, templateReference, to_json(settings) as settings, to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE templateReference.templateFamily = 'endpointSecurityApplicationControl'
"@
        $appControlPolicies = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject -ErrorAction Stop
    }
    catch {
        $q2Error = $true
        Write-PSFMessage "App Control policy query (Q2) failed: $_" -Tag Test -Level Warning
    }

    # If Q2 failed, policy evaluation cannot proceed — stop early.
    if ($q2Error) {
        $params = @{
            TestId       = '51018'
            Title        = 'Windows App Control for Business (WDAC) is configured and assigned via Intune'
            Status       = $false
            Result       = "⚠️ $investigateMsg"
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Deserialize JSON fields and enrich each policy with evaluation metadata.
    foreach ($policy in $appControlPolicies) {
        if ($policy.settings -is [string]) {
            $policy.settings = $policy.settings | ConvertFrom-Json
        }
        if ($policy.assignments -is [string]) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }

        # Determine if the policy targets Windows (platforms must contain 'windows10').
        $isWindowsPolicy = $policy.platforms -and ($policy.platforms -match 'windows10')
        $policy | Add-Member -NotePropertyName IsWindowsPolicy -NotePropertyValue $isWindowsPolicy -Force

        # Detect the build-option setting in settings[*].settingInstance.settingDefinitionId.
        # Build-option values end with: _built_in_controls_selected, _configure_xml_selected, _upload_xml_selected.
        $buildOption = 'Not configured'
        if ($policy.settings -and $policy.settings.Count -gt 0) {
            foreach ($setting in $policy.settings) {
                $settingId = $setting.settingInstance.settingDefinitionId
                $choiceValue = $setting.settingInstance.choiceSettingValue.value

                if ($settingId -match 'device_vendor_msft_policy_config_applicationcontrol' -and $choiceValue) {
                    if ($choiceValue -match '_built_in_controls_selected$') {
                        $buildOption = 'Built-in controls'
                        break
                    }
                    elseif ($choiceValue -match '_configure_xml_selected$') {
                        $buildOption = 'Configure XML'
                        break
                    }
                    elseif ($choiceValue -match '_upload_xml_selected$') {
                        $buildOption = 'Upload XML'
                        break
                    }
                }
            }
        }
        $policy | Add-Member -NotePropertyName BuildOption -NotePropertyValue $buildOption -Force

        # Check assignment state using assignments.Count > 0 (do NOT rely on isAssigned).
        $isAssigned = $policy.assignments -and $policy.assignments.Count -gt 0
        $policy | Add-Member -NotePropertyName IsAssigned -NotePropertyValue $isAssigned -Force
    }
    #endregion Data Collection

    #region Assessment Logic
    # Filter to policies that target Windows.
    $windowsPolicies = @($appControlPolicies | Where-Object { $_.IsWindowsPolicy })

    # Pass: at least one Windows policy has a configured build option AND is assigned.
    $qualifyingPolicies = @($windowsPolicies | Where-Object { $_.BuildOption -ne 'Not configured' -and $_.IsAssigned })
    $passed = $qualifyingPolicies.Count -gt 0

    if ($passed) {
        $testResultMarkdown = "✅ Windows App Control for Business is configured (either via Microsoft built-in controls or a custom WDAC XML policy) and assigned to managed Windows devices via at least one Intune Settings Catalog policy.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Windows devices are enrolled but no Intune App Control for Business policy is configured AND assigned — managed Windows devices have no kernel-level allow-listing of executables, allowing unsigned and unknown binaries to run with the user's token before any detective control fires.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/appControl'

    # Build the summary status line.
    $verdictMd = if ($passed) { 'Pass' } else { 'Fail' }
    $statusLine = "**Status: $verdictMd** — $($qualifyingPolicies.Count) of $($windowsPolicies.Count) App Control policies are assigned with a configured build option."

    $mdInfo = ''
    $tableRows = ''

    if ($windowsPolicies.Count -gt 0) {
        $displayedPolicies = if ($windowsPolicies.Count -gt 10) { $windowsPolicies[0..9] } else { $windowsPolicies }

        foreach ($policy in $displayedPolicies) {
            $policyName = Get-SafeMarkdown $policy.name
            $buildOption = $policy.BuildOption
            $assignedText = if ($policy.IsAssigned) { '✅ Yes' } else { '❌ No' }
            $policyQualifies = ($policy.BuildOption -ne 'Not configured' -and $policy.IsAssigned)
            $policyStatus = if ($policyQualifies) { '✅ Pass' } else { '❌ Fail' }

            $encodedTechnologies = ([string]$policy.technologies) -replace ',', '%2C'
            $policyLink = "https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/PolicySummaryBlade/policyId/$($policy.id)/technology/$encodedTechnologies/templateId/$($policy.templateReference.templateId)/platformName/$($policy.platforms)"

            $tableRows += "| [$policyName]($policyLink) | $buildOption | $assignedText | $policyStatus |`n"
        }

        if ($windowsPolicies.Count -gt 10) {
            $tableRows += "| ... ($($windowsPolicies.Count) total) | | | |`n"
        }

        $formatTemplate = @'

## [{0}]({1})

{2}

| Policy name | Build option | Assigned | Status |
| :---------- | :----------- | :------- | :----- |
{3}
'@
        $mdInfo = $formatTemplate -f 'Windows App Control for Business — Settings Catalog policy posture', $portalUrl, $statusLine, $tableRows
    }
    else {
        # Edge case: Q2 returned policies but none target Windows.
        $formatTemplate = @'

## [{0}]({1})

**Status: Fail** — No App Control policies target the Windows platform.
'@
        $mdInfo = $formatTemplate -f 'Windows App Control for Business — Settings Catalog policy posture', $portalUrl
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '51018'
        Title  = 'Windows App Control for Business (WDAC) is configured and assigned via Intune'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
