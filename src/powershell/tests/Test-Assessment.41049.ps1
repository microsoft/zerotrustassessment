<#
.SYNOPSIS
    The Microsoft Defender Antivirus user interface is hidden from end users.

.DESCRIPTION
    Checks whether the DisableVirusUI setting is configured and assigned in Intune policies
    (Settings Catalog or legacy endpoint protection) to hide the Virus and threat protection UI
    from standard users.

.NOTES
    Test ID: 41049
    Workshop Task ID: SECOPS-049
    Category: Endpoint threat protection
    Pillar: SecOps
    Required Module: Microsoft.Graph.Authentication
    Required Connection: Microsoft Graph
    Required Permission: DeviceManagementConfiguration.Read.All
#>

function Test-Assessment-41049 {
    [ZtTest(
        Category = 'Endpoint threat protection',
        CompatibleLicense = ('INTUNE_A&WINDEFATP'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41049,
        Title = 'The Microsoft Defender Antivirus user interface is hidden from end users',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Defender UI suppression configuration'
    $evaluationResults = @()
    $settingsCatalogError = $null
    $legacyEppError = $null
    $investigateParams = @{
        TestId       = '41049'
        Title        = 'The Microsoft Defender Antivirus user interface is hidden from end users'
        Status       = $false
        Result       = '⚠️ Unable to determine DisableVirusUI status due to an API or access error. Re-run the assessment after verifying Intune licensing, DeviceManagementConfiguration.Read.All consent, and Microsoft Graph access.'
        CustomStatus = 'Investigate'
    }

    # Q1: List Settings Catalog configuration policies from Intune and check for Defender UI suppression settings.
    try {
        Write-ZtProgress -Activity $activity -Status 'Getting Settings Catalog policies'
        $settingsCatalogPolicies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/configurationPolicies' -ApiVersion beta -ErrorAction Stop)
        Write-PSFMessage "Found $($settingsCatalogPolicies.Count) Settings Catalog policies" -Level Verbose
    }
    catch {
        $settingsCatalogError = $_
        Write-PSFMessage "Failed to query Settings Catalog policies: $_" -Tag Test -Level Warning
    }

    # Process each Settings Catalog policy
    foreach ($policy in $settingsCatalogPolicies) {
        try {
            Write-ZtProgress -Activity $activity -Status "Reading Settings Catalog policy $($policy.name)"

            $settings = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies/$($policy.id)/settings" -ApiVersion beta -ErrorAction Stop)
            $assignments = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies/$($policy.id)/assignments" -ApiVersion beta -ErrorAction Stop)

            # Flatten nested children: top-level items are {id, settingInstance} wrappers;
            # children inside choiceSettingValue/groupSettingCollectionValue are bare settingInstance
            # objects and must be re-wrapped so $findSetting can resolve settingDefinitionId uniformly.
            $flattenedSettings = [System.Collections.Generic.List[object]]::new()
            $visitSettingInstances = {
                param($instances)
                foreach ($instance in @($instances)) {
                    if ($null -eq $instance) { continue }
                    [void]$flattenedSettings.Add($instance)
                    $bareChildren = @($instance.settingInstance.choiceSettingValue.children) +
                                    @($instance.settingInstance.groupSettingCollectionValue)
                    $wrapped = @($bareChildren | Where-Object { $null -ne $_ } | ForEach-Object {
                        [PSCustomObject]@{ settingInstance = $_ }
                    })
                    if ($wrapped.Count -gt 0) { & $visitSettingInstances $wrapped }
                }
            }
            & $visitSettingInstances $settings
            $settings = @($flattenedSettings)

            # Helper to find setting by ID pattern
            $findSetting = {
                param([string]$Pattern)
                @($settings | Where-Object {
                    $_.settingInstance.settingDefinitionId -match $Pattern
                })
            }

            $assignmentCount = $assignments.Count

            # Extract all UI suppression controls for context
            $uiSuppressionControls = @(
                @{ Name = 'Virus/AV UI'; Pattern = '(?i)_disablevirusui(?:_|$)'; IsPrimary = $true },
                @{ Name = 'Account UI'; Pattern = '(?i)_disableaccountprotectionui(?:_|$)'; IsPrimary = $false },
                @{ Name = 'App/browser UI'; Pattern = '(?i)_disableappbrowserui(?:_|$)'; IsPrimary = $false },
                @{ Name = 'Device security UI'; Pattern = '(?i)_disabledevicesecurityui(?:_|$)'; IsPrimary = $false },
                @{ Name = 'Family UI'; Pattern = '(?i)_disablefamilyui(?:_|$)'; IsPrimary = $false },
                @{ Name = 'Health UI'; Pattern = '(?i)_disablehealthui(?:_|$)'; IsPrimary = $false },
                @{ Name = 'Network UI'; Pattern = '(?i)_disablenetworkui(?:_|$)'; IsPrimary = $false },
                @{ Name = 'Clear TPM button'; Pattern = '(?i)_disablecleartpmbutton(?:_|$)'; IsPrimary = $false },
                @{ Name = 'TPM firmware warning'; Pattern = '(?i)_disabletpmfirmwareupdatewarning(?:_|$)'; IsPrimary = $false },
                @{ Name = 'Ransomware recovery UI'; Pattern = '(?i)_hideransomwaredatarecovery(?:_|$)'; IsPrimary = $false },
                @{ Name = 'Secure Boot UI'; Pattern = '(?i)_hidesecureboot(?:_|$)'; IsPrimary = $false },
                @{ Name = 'TPM troubleshooting UI'; Pattern = '(?i)_hidetpmtroubleshooting(?:_|$)'; IsPrimary = $false },
                @{ Name = 'Notification-area icon'; Pattern = '(?i)_hidewindowssecuritynotificationareacontrol(?:_|$)'; IsPrimary = $false },
                @{ Name = 'Noncritical notifications'; Pattern = '(?i)_disableenhancednotifications(?:_|$)'; IsPrimary = $false },
                @{ Name = 'All notifications'; Pattern = '(?i)_disablenotifications(?:_|$)'; IsPrimary = $false }
            )

            foreach ($control in $uiSuppressionControls) {
                $matchingSetting = & $findSetting $control.Pattern
                if ($matchingSetting.Count -eq 0) {
                    continue
                }

                foreach ($setting in $matchingSetting) {
                    $settingId = $setting.settingInstance.settingDefinitionId
                    # Extract the normalized value: _1 = enabled/hidden, _0 = disabled/visible
                    $choiceValue = [string]$setting.settingInstance.choiceSettingValue.value
                    $normalizedState = 'N/A'
                    if ($choiceValue -match '(?i)_1$') {
                        $normalizedState = 'Hidden'
                    }
                    elseif ($choiceValue -match '(?i)_0$') {
                        $normalizedState = 'Visible'
                    }

                    # Only DisableVirusUI (IsPrimary) determines overall outcome; other controls are contextual.
                    $controlStatus = 'N/A'
                    if ($normalizedState -eq 'N/A') {
                        $controlStatus = 'Investigate'
                    }
                    elseif ($normalizedState -eq 'Hidden' -and $assignmentCount -gt 0) {
                        $controlStatus = 'Pass'
                    }
                    else {
                        $controlStatus = 'Fail'
                    }

                    $evaluationResults += [PSCustomObject]@{
                        PolicyName           = $policy.name
                        Source               = 'Settings Catalog'
                        AssignmentCount      = $assignmentCount
                        CanonicalControl     = $control.Name
                        RawSettingProperty   = $settingId
                        NormalizedState      = $normalizedState
                        Status               = $controlStatus
                        IsPrimary            = $control.IsPrimary
                    }
                }
            }
        }
        catch {
            Add-ZtTestResultDetail @investigateParams
            return
        }
    }

    # Q2: Legacy windows10EndpointProtectionConfiguration (fallback if no Settings Catalog results)
    if ($evaluationResults.Count -eq 0) {
        Write-ZtProgress -Activity $activity -Status 'Getting legacy endpoint protection configuration policies'

        try {
            $legacyEppUri = "deviceManagement/deviceConfigurations?`$filter=isof('microsoft.graph.windows10EndpointProtectionConfiguration')"
            $legacyEppPolicies = @(Invoke-ZtGraphRequest -RelativeUri $legacyEppUri -ApiVersion beta -ErrorAction Stop)
            Write-PSFMessage "Found $($legacyEppPolicies.Count) legacy endpoint protection policies" -Level Verbose
        }
        catch {
            $legacyEppError = $_
            Write-PSFMessage "Failed to query legacy EPP policies: $_" -Tag Test -Level Warning
        }

        # Process each legacy EPP policy
        foreach ($policy in $legacyEppPolicies) {
            try {
                Write-ZtProgress -Activity $activity -Status "Reading EPP policy $($policy.displayName)"

                $policy = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceConfigurations' -UniqueId $policy.id -ApiVersion beta -ErrorAction Stop
                $assignments = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/deviceConfigurations/$($policy.id)/assignments" -ApiVersion beta -ErrorAction Stop)
                $assignmentCount = $assignments.Count

                # Map legacy boolean properties to UI suppression controls
                $legacyControls = @(
                    @{ Name = 'Virus/AV UI'; Property = 'defenderSecurityCenterDisableVirusUI'; IsPrimary = $true },
                    @{ Name = 'Account UI'; Property = 'defenderSecurityCenterDisableAccountUI'; IsPrimary = $false },
                    @{ Name = 'App/browser UI'; Property = 'defenderSecurityCenterDisableAppBrowserUI'; IsPrimary = $false },
                    @{ Name = 'Device security UI'; Property = 'defenderSecurityCenterDisableHardwareUI'; IsPrimary = $false },
                    @{ Name = 'Family UI'; Property = 'defenderSecurityCenterDisableFamilyUI'; IsPrimary = $false },
                    @{ Name = 'Health UI'; Property = 'defenderSecurityCenterDisableHealthUI'; IsPrimary = $false },
                    @{ Name = 'Network UI'; Property = 'defenderSecurityCenterDisableNetworkUI'; IsPrimary = $false },
                    @{ Name = 'Clear TPM button'; Property = 'defenderSecurityCenterDisableClearTpmUI'; IsPrimary = $false },
                    @{ Name = 'TPM firmware warning'; Property = 'defenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI'; IsPrimary = $false },
                    @{ Name = 'Ransomware recovery UI'; Property = 'defenderSecurityCenterDisableRansomwareUI'; IsPrimary = $false },
                    @{ Name = 'Secure Boot UI'; Property = 'defenderSecurityCenterDisableSecureBootUI'; IsPrimary = $false },
                    @{ Name = 'TPM troubleshooting UI'; Property = 'defenderSecurityCenterDisableTroubleshootingUI'; IsPrimary = $false },
                    @{ Name = 'Notification-area icon'; Property = 'defenderSecurityCenterDisableNotificationAreaUI'; IsPrimary = $false },
                    @{ Name = 'Noncritical notifications'; Property = 'defenderSecurityCenterNotificationsFromApp'; ExpectedValue = 'blockNoncriticalNotifications'; IsPrimary = $false },
                    @{ Name = 'All notifications'; Property = 'defenderSecurityCenterNotificationsFromApp'; ExpectedValue = 'blockAllNotifications'; IsPrimary = $false }
                )

                foreach ($control in $legacyControls) {
                    $propertyValue = $policy.($control.Property)
                    if ($null -eq $propertyValue) {
                        continue
                    }

                    $normalizedState = 'N/A'
                    if ($propertyValue -eq $true) {
                        $normalizedState = 'Hidden'
                    }
                    elseif ($propertyValue -eq $false) {
                        $normalizedState = 'Visible'
                    }
                    elseif ($control.ExpectedValue) {
                        # blockAllNotifications suppresses all notifications including noncritical (superset).
                        if ($propertyValue -eq $control.ExpectedValue -or $propertyValue -eq 'blockAllNotifications') {
                            $normalizedState = 'Hidden'
                        }
                        elseif ($propertyValue -in @('blockNoncriticalNotifications', 'blockAllNotifications')) {
                            $normalizedState = 'Visible'
                        }
                    }

                    # Only DisableVirusUI (IsPrimary) determines overall outcome; other controls are contextual.
                    $controlStatus = 'N/A'
                    if ($normalizedState -eq 'N/A') {
                        $controlStatus = 'Investigate'
                    }
                    elseif ($normalizedState -eq 'Hidden' -and $assignmentCount -gt 0) {
                        $controlStatus = 'Pass'
                    }
                    else {
                        $controlStatus = 'Fail'
                    }

                    $evaluationResults += [PSCustomObject]@{
                        PolicyName           = $policy.displayName
                        Source               = 'Legacy EPP'
                        AssignmentCount      = $assignmentCount
                        CanonicalControl     = $control.Name
                        RawSettingProperty   = $control.Property
                        NormalizedState      = $normalizedState
                        Status               = $controlStatus
                        IsPrimary            = $control.IsPrimary
                    }
                }
            }
            catch {
                Add-ZtTestResultDetail @investigateParams
                return
            }
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Handle query errors - return early if any query failed
    $hasQueryError = ($null -ne $settingsCatalogError) -or ($null -ne $legacyEppError)

    if ($hasQueryError) {
        Add-ZtTestResultDetail @investigateParams
        return
    }

    # Determine overall outcome based on DisableVirusUI primary control
    $primaryResults = @($evaluationResults | Where-Object { $_.IsPrimary -eq $true })
    $passed = $false
    $customStatus = $null

    if ($primaryResults.Count -eq 0) {
        # No DisableVirusUI control found on either surface
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ The `DisableVirusUI` state could not be determined on either the Settings Catalog or legacy endpoint protection surface; verify configuration in the Intune portal."
    }
    else {
        # Evaluate with precedence: Fail > Investigate > Pass
        $failResults = @($primaryResults | Where-Object { $_.Status -eq 'Fail' })
        $investigateResults = @($primaryResults | Where-Object { $_.Status -eq 'Investigate' })

        if ($failResults.Count -gt 0) {
            $testResultMarkdown = "❌ The Defender Antivirus UI is not hidden — `DisableVirusUI` is disabled, or enabled only in an unassigned policy.`n`n%TestResult%"
        }
        elseif ($investigateResults.Count -gt 0) {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ Could not determine `DisableVirusUI` state: no matching control on either surface, empty result set, uninterpretable value, or Graph 401/403/404.`n`n%TestResult%"
        }
        else {
            $passResults = @($primaryResults | Where-Object { $_.Status -eq 'Pass' })
            if ($passResults.Count -gt 0) {
                $passed = $true
                $testResultMarkdown = "✅ The Microsoft Defender Antivirus (Virus & threat protection) UI is hidden from end users — an assigned policy enables `DisableVirusUI`.`n`n%TestResult%"
            }
        }
    }

    #endregion Assessment Logic

    #region Report Generation

    if ($evaluationResults.Count -gt 0) {
        # Sort results: DisableVirusUI first (primary), then others by policy and control name, limit to 10
        $sortedResults = @($evaluationResults | Sort-Object -Property { $_.IsPrimary -eq $false }, PolicyName, CanonicalControl | Select-Object -First 10)

        $portalUrl = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration'

        # Map status to emoji format
        $statusEmoji = @{
            'Pass'        = '✅ Pass'
            'Fail'        = '❌ Fail'
            'Investigate' = '⚠️ Investigate'
            'N/A'         = 'N/A'
        }

        $tableRows = @($sortedResults | ForEach-Object {
            $policyName = (Get-SafeMarkdown -Text $_.PolicyName) -replace '\|', '\\|'
            $policyLink = "$portalUrl"
            $displayStatus = $statusEmoji[$_.Status]
            if (-not $displayStatus) { $displayStatus = $_.Status }
            "| [$policyName]($policyLink) | $($_.Source) | $($_.AssignmentCount) | $($_.CanonicalControl) | $($_.RawSettingProperty) | $($_.NormalizedState) | $displayStatus |"
        })

        if ($evaluationResults.Count -gt 10) {
            $tableRows += "| ... | | | | | | $($evaluationResults.Count) total configurations |"
        }

        $mdInfo = @"

## [Intune configuration policies](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration)

| Policy/Profile | Source | Assignment Count | Canonical control | Raw setting/property | Normalized state | Status |
| :--- | :--- | ---: | :--- | :--- | :--- | :--- |
$($tableRows -join "`n")
"@

        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }

    $params = @{
        TestId = '41049'
        Title  = 'The Microsoft Defender Antivirus user interface is hidden from end users'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params

    #endregion Report Generation
}
