
<#
.SYNOPSIS

#>



function Test-Assessment-24550 {
    [ZtTest(
        Category = 'Devices',
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
    function Get-AllSettingInstances {
        # Recursively collects every setting instance in a policy's settings tree,
        # including those nested inside groupSettingCollectionValue.children and
        # groupSettingValue.children paths used by Settings Catalog policies.
        param([array]$SettingInstances)
        $result = [System.Collections.Generic.List[object]]::new()
        foreach ($si in $SettingInstances) {
            if ($null -eq $si) { continue }
            $result.Add($si)
            if ($si.groupSettingCollectionValue) {
                foreach ($gsv in $si.groupSettingCollectionValue) {
                    if ($gsv.children) {
                        $result.AddRange([object[]](Get-AllSettingInstances -SettingInstances @($gsv.children)))
                    }
                }
            }
            if ($si.groupSettingValue -and $si.groupSettingValue.children) {
                $result.AddRange([object[]](Get-AllSettingInstances -SettingInstances @($si.groupSettingValue.children)))
            }
            if ($si.choiceSettingValue -and $si.choiceSettingValue.children) {
                $result.AddRange([object[]](Get-AllSettingInstances -SettingInstances @($si.choiceSettingValue.children)))
            }
            if ($si.choiceSettingCollectionValue) {
                foreach ($csv in $si.choiceSettingCollectionValue) {
                    if ($csv.children) {
                        $result.AddRange([object[]](Get-AllSettingInstances -SettingInstances @($csv.children)))
                    }
                }
            }
        }
        return $result
    }

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
    # templateReference is a DuckDB STRUCT — wrap in to_json() so PowerShell can access its properties.
    # Personal Data Encryption policies are excluded in the WHERE clause.
    $sql = @"
    SELECT id, name, platforms,
           to_json(templateReference) as templateReference,
           to_json(settings) as settings,
           to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE platforms LIKE '%windows10%'
      AND (templateReference.templateDisplayName NOT LIKE '%Personal Data Encryption%'
           OR templateReference.templateDisplayName IS NULL)
"@
    $modernPoliciesRaw = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    # Parse JSON fields
    foreach ($policy in $modernPoliciesRaw) {
        if ($policy.templateReference -is [string]) {
            $policy.templateReference = $policy.templateReference | ConvertFrom-Json
        }
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

        # Recursively flatten all setting instances to catch settings nested inside
        # groupSettingCollectionValue.children (common in Settings Catalog BitLocker policies)
        $allInstances    = Get-AllSettingInstances -SettingInstances @($policy.settings.settingInstance)
        $allSettingIds   = @($allInstances | ForEach-Object { $_.settingDefinitionId } | Where-Object { $_ })

        $hasBitLockerSettings = ($allSettingIds | Where-Object { $_ -like 'device_vendor_msft_bitlocker*' }).Count -gt 0

        # Only proceed if this is a BitLocker-relevant policy
        if ($isEndpointSecurityDiskEncryption -or $hasBitLockerSettings) {
            # Check that Require Device Encryption is explicitly enabled anywhere in the setting tree
            $allChoiceValues = @($allInstances | ForEach-Object { $_.choiceSettingValue.value } | Where-Object { $_ })

            if ($allChoiceValues -contains 'device_vendor_msft_bitlocker_requiredeviceencryption_1') {
                $windowsBitLockerPolicies += $policy
            }
        }
    }

    Write-ZtProgress -Activity $activity -Status "Getting legacy BitLocker profiles"

    # Query 2: Retrieve legacy Windows device configuration profiles that enforce BitLocker / device encryption
    try {
        $deviceConfigsRaw = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/deviceConfigurations?`$expand=assignments" `
            -ApiVersion beta -ErrorAction Stop
    }
    catch {
        Write-PSFMessage "Failed to retrieve legacy device configuration profiles: $_" -Tag Test -Level Warning
        $deviceConfigsRaw = @()
    }

    $legacyWindowsBitLockerProfiles = @()
    $legacyWindowsTypes = @(
        '#microsoft.graph.windows10EndpointProtectionConfiguration',
        '#microsoft.graph.windows10GeneralConfiguration'
    )
    foreach ($deviceConfig in $deviceConfigsRaw) {
        if ($deviceConfig.'@odata.type' -notin $legacyWindowsTypes) { continue }

        $enforcesBitLocker = (
            $deviceConfig.storageRequireDeviceEncryption -eq $true -or
            $deviceConfig.bitLockerEncryptDevice -eq $true -or
            $null -ne $deviceConfig.bitLockerSystemDrivePolicy -or
            $null -ne $deviceConfig.bitLockerFixedDrivePolicy -or
            $null -ne $deviceConfig.bitLockerRemovableDrivePolicy
        )

        if ($enforcesBitLocker) {
            $legacyWindowsBitLockerProfiles += $deviceConfig
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
        foreach ($legacyProfile in $legacyWindowsBitLockerProfiles) {
            $profileName = Get-SafeMarkdown -Text $legacyProfile.displayName
            $odataType = $legacyProfile.'@odata.type' -replace '#microsoft.graph.', ''

            $encryptionFields = @()
            if ($legacyProfile.storageRequireDeviceEncryption -eq $true) { $encryptionFields += 'Device Encryption' }
            if ($legacyProfile.bitLockerEncryptDevice -eq $true) { $encryptionFields += 'BitLocker Encrypt Device' }
            if ($null -ne $legacyProfile.bitLockerSystemDrivePolicy) { $encryptionFields += 'System Drive Policy' }
            if ($null -ne $legacyProfile.bitLockerFixedDrivePolicy) { $encryptionFields += 'Fixed Drive Policy' }
            if ($null -ne $legacyProfile.bitLockerRemovableDrivePolicy) { $encryptionFields += 'Removable Drive Policy' }
            $encryptionSettings = $encryptionFields -join ', '

            $assignmentCount = $legacyProfile.assignments.Count
            if ($legacyProfile.assignments -and $legacyProfile.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $legacyProfile.assignments
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
        Title  = 'Data on Windows is protected by BitLocker encryption'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
