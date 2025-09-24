
<#
.SYNOPSIS
    Add App protection policies.
#>

function Add-ZTDeviceAppProtectionPolicies {

    function Get-AppGroupTypeString($appGroupType) {
        switch ($appGroupType) {
            "allApps" {
                return "All apps"
            }
            "allCoreMicrosoftApps" {
                return "Core Microsoft apps"
            }
            "allMicrosoftApps" {
                return "All Microsoft apps"
            }
            "selectedPublicApps" {
                return "Selected apps: "
            }
            default {
                return ""
            }
        }
    }

    function Get-ManagedAppList {
        $managedAppList = Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/managedAppStatuses/managedAppList' -ApiVersion 'beta'
        return $managedAppList.content.appList
    }

    function SetPublicAndCustomApps {
        param (
            $Policy,
            $View
        )

        $appList = Get-ManagedAppList
        $publicApps = ""
        $customApps = ""

        if ($Policy.Apps) {
            foreach ($app in $Policy.Apps) {
                if ($app.mobileAppIdentifier) {
                    $appIdentifier = $app.mobileAppIdentifier
                    if ($appIdentifier.packageId) {
                        $packageBundleId = $appIdentifier.packageId
                    }
                    elseif ($appIdentifier.bundleId) {
                        $packageBundleId = $appIdentifier.bundleId
                    }
                    if ($packageBundleId) {
                        $appInfo = $appList | Where-Object { $_.appIdentifier.packageId -eq $packageBundleId -or $_.appIdentifier.bundleId -eq $packageBundleId } | Select-Object -First 1
                        if ($appInfo) {
                            if ($appInfo.isFirstParty) {
                                $publicApps += if ($publicApps) {
                                    ", "
                                }
                                else {
                                    ""
                                }
                                $publicApps += $appInfo.displayName
                            }
                            else {
                                $customApps += if ($customApps) {
                                    ", "
                                }
                                else {
                                    ""
                                }
                                $customApps += $appInfo.displayName
                            }
                        }
                        else {
                            # If we don't find it in the managed app list, just use the raw ID
                            $customApps += if ($customApps) {
                                ", "
                            }
                            else {
                                ""
                            }
                            $customApps += $app.id
                        }
                    }
                }
                else {
                    # If no mobileAppIdentifier, just use the raw ID
                    $customApps += if ($customApps) {
                        ", "
                    }
                    else {
                        ""
                    }
                    $customApps += $app.id
                }
            }

            if ($Policy.appGroupType -eq "selectedPublicApps") {
                $View.AppsPublic = $publicApps
            }
            $View.AppsCustom = $customApps
        }
    }

    function Get-LabelAllowBlockBlank {
        param (
            $isBlocked
        )
        switch ($isBlocked) {
            'true' {
                return "Block"
            }
            'false' {
                return "Allow"
            }
            default {
                return ""
            }
        }
    }

    function Get-ManagedAppDataTransferLevelLabel {
        param (
            $allowedOutboundDataTransferDestinations,
            $disableProtectionOfManagedOutboundOpenInData,
            $filterOpenInToOnlyManagedApps
        )
        switch ($allowedOutboundDataTransferDestinations) {
            'allApps' {
                return "All apps"
            }
            'none' {
                return "None"
            }
            'managedApps' {
                $result = "Policy managed apps"
                if ($disableProtectionOfManagedOutboundOpenInData -eq $true) {
                    $result += " with OS sharing"
                }
                elseif ($filterOpenInToOnlyManagedApps -eq $true) {
                    $result += " with Open-In/Share filtering"
                }
                return $result
            }
            default {
                return ''
            }
        }
    }

    function Get-ExemptedAppsString {
        param (
            $exemptedAppPackages
        )
        $exemptedApps = ""
        if ($exemptedAppPackages -and $exemptedAppPackages.Count -gt 0) {
            foreach ($app in $exemptedAppPackages) {
                $exemptedApps += if ($exemptedApps) {
                    ", "
                }
                else {
                    ""
                }
                $exemptedApps += "$($app.Name):$($app.Value)"
            }
        }
        return $exemptedApps
    }

    function Get-DialerRestrictionLevel {
        param (
            $dialerRestrictionLevel
        )
        switch ($dialerRestrictionLevel) {
            'allApps' {
                return 'Any dialer app'
            }
            'customApp' {
                return 'A specific dialer app'
            }
            'blocked' {
                return 'None, do not transfer this data between apps'
            }
            'managedApps' {
                return 'Any policy-managed dialer app'
            }
            default {
                return $dialerRestrictionLevel
            }
        }
    }

    function Get-AllowedDataStorageLocations {
        param (
            $allowedDataStorageLocations
        )
        $result = ""
        if ($allowedDataStorageLocations -and $allowedDataStorageLocations.Count -gt 0) {
            foreach ($location in $allowedDataStorageLocations) {
                switch ($location) {
                    'oneDriveForBusiness' {
                        $name = 'OneDrive for Business'
                    }
                    'sharePoint' {
                        $name = 'SharePoint'
                    }
                    'photoLibrary' {
                        $name = 'Photo library'
                    }
                    'box' {
                        $name = 'Box'
                    }
                    'localStorage' {
                        $name = 'Local storage'
                    }
                    default {
                        $name = $location
                    }
                }
                $result += if ($result) {
                    ', '
                }
                else {
                    ''
                }
                $result += $name
            }
        }
        return $result
    }

    function Get-AllowedInboundDataTransfer {
        param (
            $allowedInboundDataTransferSources,
            $protectInboundDataFromUnknownSources
        )
        switch ($allowedInboundDataTransferSources) {
            'none' {
                return 'None'
            }
            'allApps' {
                $result = 'All apps'
                if ($protectInboundDataFromUnknownSources -eq $true) {
                    $result += ' with incoming org data'
                }
                return $result
            }
            'managedApps' {
                return 'Policy managed apps'
            }
            default {
                return $allowedInboundDataTransferSources
            }
        }
    }

    #     private string GetDeviceComplianceAction(ManagedAppRemediationAction? appActionIfDeviceComplianceRequired)
    # {
    #     return appActionIfDeviceComplianceRequired switch
    #     {
    #         ManagedAppRemediationAction.Warn => "Warn",
    #         ManagedAppRemediationAction.Block => "Block access",
    #         ManagedAppRemediationAction.Wipe => "Wipe data",
    #         _ => nameof(ManagedAppRemediationAction),
    #     };
    # }

    function Get-DeviceComplianceAction {
        param (
            $appActionIfDeviceComplianceRequired
        )
        switch ($appActionIfDeviceComplianceRequired) {
            'warn' {
                return 'Warn'
            }
            'block' {
                return 'Block access'
            }
            'wipe' {
                return 'Wipe data'
            }
            default {
                return $appActionIfDeviceComplianceRequired
            }
        }
    }

    $activity = "Getting Device App protection policies"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $appProtectionPoliciesAndroid = Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/androidManagedAppProtections' -QueryParameters @{ '$expand' = 'assignments,apps,deploymentSummary' } -ApiVersion 'beta'
    $appProtectionPoliciesIos = Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/iosManagedAppProtections' -QueryParameters @{ '$expand' = 'assignments,apps,deploymentSummary' } -ApiVersion 'beta'
    $appProtectionPoliciesWindows = Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/mdmWindowsInformationProtectionPolicies' -QueryParameters @{ '$expand' = 'assignments,protectedAppLockerFiles,exemptAppLockerFiles' } -ApiVersion 'beta'

    # Add a policy type property to each policy for identification
    $appProtectionPoliciesAndroid | ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name Platform -Value 'Android' -Force }
    $appProtectionPoliciesIos | ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name Platform -Value 'iOS' -Force }
    $appProtectionPoliciesWindows | ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name Platform -Value 'Windows' -Force }

    $appProtectionPolicies = @($appProtectionPoliciesAndroid, $appProtectionPoliciesIos, $appProtectionPoliciesWindows)

    # Create the table data structure
    $tableData = @()
    foreach ($policy in $appProtectionPolicies) {

        switch ($policy.Platform) {
            'Android' {
                $platform = 'Android'
            }
            'iOS' {
                $platform = 'iOS/iPadOS'
            }
            'Windows' {
                $platform = 'Windows'
            }
        }
        $view = [PSCustomObject]@{
            Platform                                               = $platform
            Name                                                   = $policy.displayName
            AppsPublic                                             = Get-AppGroupTypeString $policy.appGroupType
            AppsCustom                                             = ''
            BackupOrgDataToICloudOrGoogle                          = Get-LabelAllowBlockBlank $policy.dataBackupBlocked
            SendOrgDataToOtherApps                                 = Get-ManagedAppDataTransferLevelLabel -allowedOutboundDataTransferDestinations $policy.allowedOutboundDataTransferDestinations -disableProtectionOfManagedOutboundOpenInData $policy.disableProtectionOfManagedOutboundOpenInData -filterOpenInToOnlyManagedApps $policy.filterOpenInToOnlyManagedApps
            AppsToExempt                                           = Get-ExemptedAppsString $policy.exemptedAppPackages
            SaveCopiesOfOrgData                                    = Get-LabelAllowBlockBlank $policy.saveAsBlocked
            AllowUserToSaveCopiesToSelectedServices                = Get-AllowedDataStorageLocations $policy.allowedDataStorageLocations
            DataProtectionTransferTelecommunicationDataTo          = Get-DialerRestrictionLevel $policy.dialerRestrictionLevel
            DataProtectionReceiveDataFromOtherApps                 = Get-AllowedInboundDataTransfer -allowedInboundDataTransferSources $policy.allowedInboundDataTransferSources -protectInboundDataFromUnknownSources $policy.protectInboundDataFromUnknownSources
            DataProtectionOpenDataIntoOrgDocuments                 = ''
            DataProtectionAllowUsersToOpenDataFromSelectedServices = ''
            DataProtectionRestrictCutCopyBetweenOtherApps          = ''
            DataProtectionCutCopyCharacterLimitForAnyApp           = ''
            DataProtectionEncryptOrgData                           = ''
            DataProtectionSyncPolicyManagedAppDataWithNativeApps   = ''
            DataProtectionPrintingOrgData                          = ''
            DataProtectionRestrictWebContentTransferWithOtherApps  = ''
            DataProtectionOrgDataNotifications                     = ''
            ConditionalLaunchAppMaxPinAttempts                     = ''
            ConditionalLaunchAppOfflineGracePeriodBlockAccess      = ''
            ConditionalLaunchAppOfflineGracePeriodWipeData         = ''
            ConditionalLaunchAppDisabedAccount                     = ''
            ConditionalLaunchAppMinAppVersion                      = ''
            ConditionalLaunchDeviceRootedJailbrokenDevices         = Get-DeviceComplianceAction $policy.appActionIfDeviceComplianceRequired
            ConditionalLaunchDevicePrimaryMtdService               = ''
            ConditionalLaunchDeviceMaxAllowedDeviceThreatLevel     = ''
            ConditionalLaunchDeviceMinOsVersion                    = ''
            ConditionalLaunchDeviceMaxOsVersion                    = ''
            Scope                                                  = Get-ZtRoleScopeTag $policy.roleScopeTagIds
            IncludedGroups                                         = ''
            ExcludedGroups                                         = ''
        }
        SetPublicAndCustomApps -Policy $policy -View $view
        $tableData += $view
    }

    Add-ZtTenantInfo -Name "ConfigDeviceAppProtectionPolicies" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
