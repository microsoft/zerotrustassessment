using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;

namespace ZeroTrustAssessment.DocumentGenerator.ViewModels;
public class AppProtectionPolicyViews
{
    private readonly GraphData _graphData;
    public AppProtectionPolicyViews(GraphData graphData)
    {
        _graphData = graphData;
    }
    public List<AppProtectionPolicyView> GetViews()
    {
        var views = new List<AppProtectionPolicyView>();

        if (_graphData.ManagedAppPoliciesAndroid != null)
        {
            foreach (var policy in _graphData.ManagedAppPoliciesAndroid)
            {
                views.Add(GetCompliancePolicyView(policy));
            }
        }
        if (_graphData.ManagedAppPoliciesIos != null)
        {
            foreach (var policy in _graphData.ManagedAppPoliciesIos)
            {
                views.Add(GetCompliancePolicyView(policy));
            }
        }
        if (_graphData.ManagedAppPoliciesWindows != null)
        {
            foreach (var policy in _graphData.ManagedAppPoliciesWindows)
            {
                views.Add(GetCompliancePolicyView(policy));
            }
        }
        return views;
    }
    private AppProtectionPolicyView GetCompliancePolicyView(IosManagedAppProtection policy)
    {
        string includedGroups, excludedGroups;
        _graphData.GetGroupAssignmentTargetText(policy.Assignments, out includedGroups, out excludedGroups);

        AppProtectionPolicyView view = new()
        {
            Id = policy.Id,
            DisplayName = policy.DisplayName,
            Platform = "iOS/iPadOS",
            PublicApps = GetAppGroupTypeString(policy.AppGroupType),
            PreventBackups = Labels.GetLabelAllowBlockBlank(policy.DataBackupBlocked),
            SendOrgDataToOtherApps = GetManagedAppDataTransferLevelLabel(policy.AllowedOutboundDataTransferDestinations,
                policy.DisableProtectionOfManagedOutboundOpenInData, policy.FilterOpenInToOnlyManagedApps),
            AppsToExempt = GetExemptedAppsString(policy.ExemptedAppProtocols),
            SaveCopiesOfOrgData = Labels.GetLabelAllowBlockBlank(policy.SaveAsBlocked),
            AllowUserToSaveCopiesToSelectedServices = GetAllowedDataStorageLocations(policy.AllowedDataStorageLocations),
            TransferTelecommunicationDataTo = GetDialerRestrictionLevel(policy.DialerRestrictionLevel),
            ReceiveDataFromOtherApps = GetAllowedInboundDataTransfer(policy.AllowedInboundDataTransferSources, policy.ProtectInboundDataFromUnknownSources),
            OpenDataIntoOrgDocuments = "",
            AllowUsersToOpenDataFromSelectedServices = "",
            RestrictCutCopyAndPasteBetweenOtherApps = "",
            CutAndCopyCharacterLimitForAnyApp = "",
            EncryptOrgData = "",
            SyncPolicyManagedAppDataWithNativeAppsOrAddIns = "",
            PrintingOrgData = "",
            RestrictWebContentTransferWithOtherApps = "",
            OrgDataNotifications = "",
            MaxPinAttemptsAction = "",
            OfflineGracePeriodBlockAccessMin = "",
            OfflineGracePeriodWipeDataDays = "",
            DisabedAccount = "",
            MinAppVersionAction = "",
            RootedJailbrokenDevices = GetDeviceComplianceAction(policy.AppActionIfDeviceComplianceRequired),
            PrimaryMTDService = "",
            MaxAllowedDeviceThreatLevel = "",
            MinOSVersion = "",
            MaxOSVersion = "",

            Scopes = _graphData.GetScopesString(policy.RoleScopeTagIds),
            IncludedGroups = includedGroups,
            ExcludedGroups = excludedGroups
        };
        SetPublicAndCustomApps(view, policy);
        return view;
    }

    private AppProtectionPolicyView GetCompliancePolicyView(AndroidManagedAppProtection policy)
    {
        string includedGroups, excludedGroups;
        _graphData.GetGroupAssignmentTargetText(policy.Assignments, out includedGroups, out excludedGroups);

        AppProtectionPolicyView view = new()
        {
            Id = policy.Id,
            DisplayName = policy.DisplayName,
            Platform = "Android",
            PublicApps = GetAppGroupTypeString(policy.AppGroupType),
            PreventBackups = Labels.GetLabelAllowBlockBlank(policy.DataBackupBlocked),
            SendOrgDataToOtherApps = GetManagedAppDataTransferLevelLabel(policy.AllowedOutboundDataTransferDestinations, null, null),
            AppsToExempt = GetExemptedAppsString(policy.ExemptedAppPackages),
            SaveCopiesOfOrgData = Labels.GetLabelAllowBlockBlank(policy.SaveAsBlocked),
            AllowUserToSaveCopiesToSelectedServices = GetAllowedDataStorageLocations(policy.AllowedDataStorageLocations),
            TransferTelecommunicationDataTo = GetDialerRestrictionLevel(policy.DialerRestrictionLevel),
            ReceiveDataFromOtherApps = GetAllowedInboundDataTransfer(policy.AllowedInboundDataTransferSources, null),
            OpenDataIntoOrgDocuments = "",
            AllowUsersToOpenDataFromSelectedServices = "",
            RestrictCutCopyAndPasteBetweenOtherApps = "",
            CutAndCopyCharacterLimitForAnyApp = "",
            EncryptOrgData = "",
            SyncPolicyManagedAppDataWithNativeAppsOrAddIns = "",
            PrintingOrgData = "",
            RestrictWebContentTransferWithOtherApps = "",
            OrgDataNotifications = "",
            MaxPinAttemptsAction = "",
            OfflineGracePeriodBlockAccessMin = "",
            OfflineGracePeriodWipeDataDays = "",
            DisabedAccount = "",
            MinAppVersionAction = "",
            RootedJailbrokenDevices = GetDeviceComplianceAction(policy.AppActionIfDeviceComplianceRequired),
            PrimaryMTDService = "",
            MaxAllowedDeviceThreatLevel = "",
            MinOSVersion = "",
            MaxOSVersion = "",
            Scopes = _graphData.GetScopesString(policy.RoleScopeTagIds),
            IncludedGroups = includedGroups,
            ExcludedGroups = excludedGroups
        };
        SetPublicAndCustomApps(view, policy);
        return view;
    }

    private AppProtectionPolicyView GetCompliancePolicyView(MdmWindowsInformationProtectionPolicy policy)
    {
        string includedGroups, excludedGroups;
        _graphData.GetGroupAssignmentTargetText(policy.Assignments, out includedGroups, out excludedGroups);

        AppProtectionPolicyView view = new()
        {
            Id = policy.Id,
            DisplayName = policy.DisplayName,
            Platform = "Windows",
            PublicApps = Labels.NotApplicableString,
            CustomApps = GetCustomAppsString(policy.ProtectedApps, policy.ProtectedAppLockerFiles),
            PreventBackups = Labels.NotApplicableString,
            SendOrgDataToOtherApps = Labels.NotApplicableString,
            AppsToExempt = GetCustomAppsString(policy.ExemptApps, policy.ExemptAppLockerFiles),
            SaveCopiesOfOrgData = Labels.NotApplicableString,
            AllowUserToSaveCopiesToSelectedServices = Labels.NotApplicableString,
            TransferTelecommunicationDataTo = Labels.NotApplicableString,
            ReceiveDataFromOtherApps = Labels.NotApplicableString,
            OpenDataIntoOrgDocuments = Labels.NotApplicableString,
            AllowUsersToOpenDataFromSelectedServices = Labels.NotApplicableString,
            RestrictCutCopyAndPasteBetweenOtherApps = Labels.NotApplicableString,
            CutAndCopyCharacterLimitForAnyApp = Labels.NotApplicableString,
            EncryptOrgData = Labels.NotApplicableString,
            SyncPolicyManagedAppDataWithNativeAppsOrAddIns = Labels.NotApplicableString,
            PrintingOrgData = Labels.NotApplicableString,
            RestrictWebContentTransferWithOtherApps = Labels.NotApplicableString,
            OrgDataNotifications = Labels.NotApplicableString,
            MaxPinAttemptsAction = Labels.NotApplicableString,
            OfflineGracePeriodBlockAccessMin = Labels.NotApplicableString,
            OfflineGracePeriodWipeDataDays = Labels.NotApplicableString,
            DisabedAccount = Labels.NotApplicableString,
            MinAppVersionAction = Labels.NotApplicableString,
            RootedJailbrokenDevices = Labels.NotApplicableString,
            PrimaryMTDService = Labels.NotApplicableString,
            MaxAllowedDeviceThreatLevel = Labels.NotApplicableString,
            MinOSVersion = Labels.NotApplicableString,
            MaxOSVersion = Labels.NotApplicableString,
            Scopes = _graphData.GetScopesString(policy.RoleScopeTagIds),
            IncludedGroups = includedGroups,
            ExcludedGroups = excludedGroups
        };
        return view;
    }

    private string GetExemptedAppsString(List<Microsoft.Graph.Beta.Models.KeyValuePair>? exemptedAppPackages)
    {
        string exemptedApps = string.Empty;
        if (exemptedAppPackages?.Count > 0)
        {
            foreach (var app in exemptedAppPackages)
            {
                exemptedApps += Helper.AppendWithComma(exemptedApps, $"{app.Name}:{app.Value}");
            }
        }
        return exemptedApps;
    }

    private void SetPublicAndCustomApps(AppProtectionPolicyView view, AndroidManagedAppProtection policy)
    {
        string publicApps = string.Empty;
        string customApps = string.Empty;

        if (policy.Apps?.Count > 0)
        {
            var appStatuses = _graphData.ManagedAppStatusAndroid;
            foreach (var app in policy.Apps)
            {
                bool appFound = false;
                if (app.MobileAppIdentifier is AndroidMobileAppIdentifier appIdentifier)
                {
                    if (appIdentifier.PackageId != null)
                    {
                        if (appStatuses.TryGetValue(appIdentifier.PackageId, out var appInfo))
                        {
                            if (appInfo.IsFirstParty)
                            {
                                publicApps += Helper.AppendWithComma(publicApps, appInfo.DisplayName);
                                appFound = true;
                            }
                            else
                            {
                                customApps += Helper.AppendWithComma(customApps, appInfo.DisplayName);
                                appFound = true;
                            }
                        }
                    }
                }
                if (!appFound)
                {
                    customApps += Helper.AppendWithComma(customApps, app.Id); //Add the raw ID if we don't find it
                }
            }
        }
        if (policy.AppGroupType == TargetedManagedAppGroupType.SelectedPublicApps) //Only show app names if they are selected apps
        {
            view.PublicApps += publicApps;
        }

        view.CustomApps += customApps;

    }

    private void SetPublicAndCustomApps(AppProtectionPolicyView view, IosManagedAppProtection policy)
    {
        string publicApps = string.Empty;
        string customApps = string.Empty;

        if (policy.Apps?.Count > 0)
        {
            var appStatuses = _graphData.ManagedAppStatusIos;
            foreach (var app in policy.Apps)
            {
                bool appFound = false;
                if (app.MobileAppIdentifier is IosMobileAppIdentifier appIdentifier)
                {
                    if (appIdentifier.BundleId != null)
                    {
                        if (appStatuses.TryGetValue(appIdentifier.BundleId, out var appInfo))
                        {
                            if (appInfo.IsFirstParty)
                            {
                                publicApps += Helper.AppendWithComma(publicApps, appInfo.DisplayName);
                                appFound = true;
                            }
                            else
                            {
                                customApps += Helper.AppendWithComma(customApps, appInfo.DisplayName);
                                appFound = true;
                            }
                        }
                    }
                }
                if (!appFound)
                {
                    customApps += Helper.AppendWithComma(customApps, app.Id); //Add the raw ID if we don't find it
                }
            }
        }
        if (policy.AppGroupType == TargetedManagedAppGroupType.SelectedPublicApps) //Only show app names if they are selected apps
        {
            view.PublicApps += publicApps;
        }
        view.CustomApps += customApps;
    }

    private string? GetCustomAppsString(List<WindowsInformationProtectionApp>? apps, List<WindowsInformationProtectionAppLockerFile>? appLockerFiles)
    {
        var appString = string.Empty;
        if (apps?.Count > 0)
        {
            appString = string.Join(",", apps.Select(x => x.DisplayName));

        }
        if (appLockerFiles?.Count > 0)
        {
            var appList = string.Join(",", appLockerFiles.Select(x => x.DisplayName));
            appString += Helper.AppendWithComma(appString, appList);
        }

        return appString;
    }

    private string? GetAppGroupTypeString(TargetedManagedAppGroupType? appGroupType)
    {
        return appGroupType switch
        {
            TargetedManagedAppGroupType.AllApps => "All apps",
            TargetedManagedAppGroupType.AllCoreMicrosoftApps => "Core Microsoft apps",
            TargetedManagedAppGroupType.AllMicrosoftApps => "All Microsoft apps",
            TargetedManagedAppGroupType.SelectedPublicApps => "Selected apps: ",
            _ => string.Empty,
        };
    }


    private static string GetManagedAppDataTransferLevelLabel(ManagedAppDataTransferLevel? allowedOutboundDataTransferDestinations,
        bool? disableProtectionOfManagedOutboundOpenInData, bool? filterOpenInToOnlyManagedApps)
    {
        switch (allowedOutboundDataTransferDestinations)
        {
            case ManagedAppDataTransferLevel.AllApps:
                return "All apps";
            case ManagedAppDataTransferLevel.None:
                return "None";
            case ManagedAppDataTransferLevel.ManagedApps:
                var result = "Policy managed apps";
                if (disableProtectionOfManagedOutboundOpenInData == true)
                {
                    result += " with OS sharing";
                }
                else if (filterOpenInToOnlyManagedApps == true)
                {
                    result += " with Open-In/Share filtering";
                }
                return result;
            default:
                return string.Empty;
        }
    }

    private string GetAllowedDataStorageLocations(List<ManagedAppDataStorageLocation?>? allowedDataStorageLocations)
    {
        string result = string.Empty;
        if (allowedDataStorageLocations?.Count > 0)
        {
            foreach (var location in allowedDataStorageLocations)
            {
                string value = location?.ToString() ?? "";
                string name = value switch
                {
                    "oneDriveForBusiness" => "OneDrive for Business",
                    "sharePoint" => "SharePoint",
                    "photoLibrary" => "Photo library ",
                    "box" => "Box",
                    "localStorage" => "Local storage",
                    _ => value
                };
                result += Helper.AppendWithComma(result, value);
            }
        }
        return result;
    }

    private string GetDialerRestrictionLevel(ManagedAppPhoneNumberRedirectLevel? dialerRestrictionLevel)
    {
        return dialerRestrictionLevel switch
        {
            ManagedAppPhoneNumberRedirectLevel.AllApps => "Any dialer app",
            ManagedAppPhoneNumberRedirectLevel.CustomApp => "A specific dialer app",
            ManagedAppPhoneNumberRedirectLevel.Blocked => "None, do not transfer this data between apps",
            ManagedAppPhoneNumberRedirectLevel.ManagedApps => "Any policy-managed dialer app",
            _ => nameof(dialerRestrictionLevel),
        };
    }

    private string GetAllowedInboundDataTransfer(ManagedAppDataTransferLevel? allowedInboundDataTransferSources, bool? protectInboundDataFromUnknownSources)
    {
        switch (allowedInboundDataTransferSources)
        {
            case ManagedAppDataTransferLevel.None:
                return "None";
            case ManagedAppDataTransferLevel.AllApps:
                var result = "All apps";
                if (protectInboundDataFromUnknownSources == true)
                {
                    result += " with incoming org data";
                }
                return result;
            case ManagedAppDataTransferLevel.ManagedApps:
                return "Policy managed apps";
            default:
                return nameof(allowedInboundDataTransferSources);
        }
    }

    private string GetDeviceComplianceAction(ManagedAppRemediationAction? appActionIfDeviceComplianceRequired)
    {
        return appActionIfDeviceComplianceRequired switch
        {
            ManagedAppRemediationAction.Warn => "Warn",
            ManagedAppRemediationAction.Block => "Block access",
            ManagedAppRemediationAction.Wipe => "Wipe data",
            _ => nameof(ManagedAppRemediationAction),
        };
    }
}