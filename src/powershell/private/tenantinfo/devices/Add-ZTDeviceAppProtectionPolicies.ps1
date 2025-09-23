
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
            BackupOrgDataToICloudOrGoogle                          = ''
            SendOrgDataToOtherApps                                 = ''
            AppsToExempt                                           = ''
            SaveCopiesOfOrgData                                    = ''
            AllowUserToSaveCopiesToSelectedServices                = ''
            DataProtectionTransferTelecommunicationDataTo          = ''
            DataProtectionReceiveDataFromOtherApps                 = ''
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
            ConditionalLaunchDeviceRootedJailbrokenDevices         = ''
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
