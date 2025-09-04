
<#
.SYNOPSIS
    Add App protection policies.
#>

function Add-ZTDeviceAppProtectionPolicies {

    $activity = "Getting Device App protection policies"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $appProtectionPoliciesAndroid = Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/androidManagedAppProtections' -QueryParameters @{ '$expand' = 'assignments,apps,deploymentSummary' } -ApiVersion 'beta'
    $appProtectionPoliciesIos = Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/iosManagedAppProtections' -QueryParameters @{ '$expand' = 'assignments,apps,deploymentSummary' } -ApiVersion 'beta'
    $appProtectionPoliciesWindows = Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/mdmWindowsInformationProtectionPolicies' -QueryParameters @{ '$expand' = 'assignments,protectedAppLockerFiles,exemptAppLockerFiles' } -ApiVersion 'beta'

    $appProtectionPolicies = @($appProtectionPoliciesAndroid, $appProtectionPoliciesIos, $appProtectionPoliciesWindows)
    # Create the table data structure
    $tableData = @()
    foreach ($policy in $appProtectionPolicies) {

        $tableData += [PSCustomObject]@{
            Platform = ''
            Name = $policy.Name
            AppsPublic = ''
            AppsCustom = ''
            BackupOrgDataToICloudOrGoogle = ''
            SendOrgDataToOtherApps = ''
            AppsToExempt = ''
            SaveCopiesOfOrgData = ''
            AllowUserToSaveCopiesToSelectedServices = ''
            DataProtectionTransferTelecommunicationDataTo = ''
            DataProtectionReceiveDataFromOtherApps = ''
            DataProtectionOpenDataIntoOrgDocuments = ''
            DataProtectionAllowUsersToOpenDataFromSelectedServices = ''
            DataProtectionRestrictCutCopyBetweenOtherApps = ''
            DataProtectionCutCopyCharacterLimitForAnyApp = ''
            DataProtectionEncryptOrgData = ''
            DataProtectionSyncPolicyManagedAppDataWithNativeApps = ''
            DataProtectionPrintingOrgData = ''
            DataProtectionRestrictWebContentTransferWithOtherApps = ''
            DataProtectionOrgDataNotifications = ''
            ConditionalLaunchAppMaxPinAttempts = ''
            ConditionalLaunchAppOfflineGracePeriodBlockAccess = ''
            ConditionalLaunchAppOfflineGracePeriodWipeData = ''
            ConditionalLaunchAppDisabedAccount = ''
            ConditionalLaunchAppMinAppVersion = ''
            ConditionalLaunchDeviceRootedJailbrokenDevices = ''
            ConditionalLaunchDevicePrimaryMtdService = ''
            ConditionalLaunchDeviceMaxAllowedDeviceThreatLevel = ''
            ConditionalLaunchDeviceMinOsVersion = ''
            ConditionalLaunchDeviceMaxOsVersion = ''
            Scope = ''
            IncludedGroups = ''
            ExcludedGroups = ''

        }
    }


    Add-ZtTenantInfo -Name "ConfigDeviceAppProtectionPolicies" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
