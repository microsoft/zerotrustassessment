
<#
.SYNOPSIS

#>



function Test-Assessment-24550 {
    [ZtTest(
        Category = 'Device',
        ImplementationCost = 'Low',
        CompatibleLicense = ('INTUNE_A'),
        Pillar = 'Devices',
        RiskLevel = 'High',
        SfiPillar = 'Protect engineering systems',
        TenantType = ('Workforce'),
        TestId = 24550,
        Title = 'Data on Windows is protected by BitLocker encryption',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Helper Functions
    function Test-PolicyAssignment {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $false)]
            [array]$Policies
        )

        # Return false if $Policies is null or empty
        if (-not $Policies) {
            return $false
        }

        # Check if at least one policy has assignments
        $assignedPolicies = $Policies | Where-Object {
            $_.PSObject.Properties.Match("assignments") -and $_.assignments -and $_.assignments.Count -gt 0
        }

        return $assignedPolicies.Count -gt 0
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Windows BitLocker policy is configured and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting modern BitLocker policies"

    # Query 1: Retrieve modern Windows 10 Settings Catalog / Endpoint Security configuration policies from DB
    $sql = @"
    SELECT id, name, platforms, templateReference, to_json(settings) as settings, to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE platforms LIKE '%windows10%'
"@
    $modernPoliciesRaw = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    # Parse JSON fields
    foreach ($policy in $modernPoliciesRaw) {
        if ($policy.settings -is [string]) {
            $policy.settings = $policy.settings | ConvertFrom-Json
        }
        if ($policy.assignments -is [string]) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }
    }

    # Filter to BitLocker-relevant modern policies:
    # Either in the Endpoint Security Disk Encryption template family (excluding Personal Data Encryption),
    # or containing at least one device_vendor_msft_bitlocker setting.
    # Must also have Require Device Encryption enabled (value = _1).
    $windowsBitLockerPolicies = @()
    foreach ($policy in $modernPoliciesRaw) {
        $isEndpointSecurityDiskEncryption = $policy.templateReference.templateFamily -eq 'endpointSecurityDiskEncryption'
        $isPersonalDataEncryption = $policy.templateReference.templateDisplayName -like '*Personal Data Encryption*'

        # Flatten all settingDefinitionIds across all nested setting instances
        $allSettingIds = $policy.settings.settingInstance.settingDefinitionId
        if ($allSettingIds -isnot [array]) { $allSettingIds = @($allSettingIds) }

        $hasBitLockerSettings = ($allSettingIds | Where-Object { $_ -like 'device_vendor_msft_bitlocker*' }).Count -gt 0

        # Only proceed if this is a BitLocker-relevant policy (not Personal Data Encryption)
        if (-not $isPersonalDataEncryption -and ($isEndpointSecurityDiskEncryption -or $hasBitLockerSettings)) {
            # Check that Require Device Encryption is explicitly enabled
            $allChoiceValues = $policy.settings.settingInstance.choiceSettingValue.value
            if ($allChoiceValues -isnot [array]) { $allChoiceValues = @($allChoiceValues) }

            if ($allChoiceValues -contains 'device_vendor_msft_bitlocker_requiredeviceencryption_1') {
                $windowsBitLockerPolicies += $policy
            }
        }
    }

    Write-ZtProgress -Activity $activity -Status "Getting legacy BitLocker profiles"

    # Query 2: Retrieve legacy Windows device configuration profiles that enforce BitLocker / device encryption
    $deviceConfigsRaw = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/deviceConfigurations?`$expand=assignments" -ApiVersion beta

    $legacyWindowsBitLockerProfiles = @()
    $legacyWindowsTypes = @(
        '#microsoft.graph.windows10EndpointProtectionConfiguration',
        '#microsoft.graph.windows10GeneralConfiguration'
    )
    foreach ($profile in $deviceConfigsRaw) {
        if ($profile.'@odata.type' -notin $legacyWindowsTypes) { continue }

        $enforcesBitLocker = (
            $profile.storageRequireDeviceEncryption -eq $true -or
            $profile.bitLockerEncryptDevice -eq $true -or
            $null -ne $profile.bitLockerSystemDrivePolicy -or
            $null -ne $profile.bitLockerFixedDrivePolicy -or
            $null -ne $profile.bitLockerRemovableDrivePolicy
        )

        if ($enforcesBitLocker) {
            $legacyWindowsBitLockerProfiles += $profile
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Pass if at least one modern policy OR at least one legacy profile is assigned
    $modernAssigned  = Test-PolicyAssignment -Policies $windowsBitLockerPolicies
    $legacyAssigned  = Test-PolicyAssignment -Policies $legacyWindowsBitLockerProfiles
    $passed = $modernAssigned -or $legacyAssigned

    if ($passed) {
        $testResultMarkdown = "At least one Windows BitLocker policy is configured and assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No Windows BitLocker policy is configured or assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration'
    $mdInfo = ""

    # Modern BitLocker policies section
    if ($windowsBitLockerPolicies.Count -gt 0) {
        $modernRows = ""
        foreach ($policy in $windowsBitLockerPolicies) {
            $policyName = Get-SafeMarkdown -Text $policy.name
            $templateFamily = $policy.templateReference.templateFamily
            $requireDeviceEncryption = '✅ Enabled'
            $assignmentCount = $policy.assignments.Count
            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }
            else {
                $assignmentTarget = 'None'
            }
            $modernRows += "| [$policyName]($portalLink) | $templateFamily | $requireDeviceEncryption | $assignmentCount | $assignmentTarget |`n"
        }

        $mdInfo += @"

## Modern Windows BitLocker Policies

| Policy Name | Template Family | Require Device Encryption | Assignments | Assignment Target |
| :---------- | :-------------- | :------------------------ | :---------- | :---------------- |
$modernRows

"@
    }

    # Legacy BitLocker profiles section
    if ($legacyWindowsBitLockerProfiles.Count -gt 0) {
        $legacyRows = ""
        foreach ($profile in $legacyWindowsBitLockerProfiles) {
            $profileName = Get-SafeMarkdown -Text $profile.displayName
            $odataType = $profile.'@odata.type' -replace '#microsoft.graph.', ''

            $encryptionFields = @()
            if ($profile.storageRequireDeviceEncryption -eq $true) { $encryptionFields += 'Device Encryption' }
            if ($profile.bitLockerEncryptDevice -eq $true) { $encryptionFields += 'BitLocker Encrypt Device' }
            if ($null -ne $profile.bitLockerSystemDrivePolicy) { $encryptionFields += 'System Drive Policy' }
            if ($null -ne $profile.bitLockerFixedDrivePolicy) { $encryptionFields += 'Fixed Drive Policy' }
            if ($null -ne $profile.bitLockerRemovableDrivePolicy) { $encryptionFields += 'Removable Drive Policy' }
            $encryptionSettings = $encryptionFields -join ', '

            $assignmentCount = $profile.assignments.Count
            if ($profile.assignments -and $profile.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $profile.assignments
            }
            else {
                $assignmentTarget = 'None'
            }
            $legacyRows += "| [$profileName]($portalLink) | $odataType | $encryptionSettings | $assignmentCount | $assignmentTarget |`n"
        }

        $mdInfo += @"

## Legacy Windows BitLocker Profiles

| Profile Name | Profile Type | Encryption Settings | Assignments | Assignment Target |
| :----------- | :----------- | :------------------ | :---------- | :---------------- |
$legacyRows

"@
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24550'
        Title  = 'Windows BitLocker policy is configured and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
