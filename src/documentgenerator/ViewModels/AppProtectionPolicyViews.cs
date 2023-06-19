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
            AppsToExempt = GetExemptedAppsString(policy.ExemptedAppProtocols),
            PreventBackups = Labels.GetLabelYesNoBlank(policy.DataBackupBlocked),
            SendOrgDataToOtherApps = GetManagedAppDataTransferLevelLabel(policy.AllowedOutboundDataTransferDestinations, 
                policy.DisableProtectionOfManagedOutboundOpenInData, policy.FilterOpenInToOnlyManagedApps),

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
            AppsToExempt = GetExemptedAppsString(policy.ExemptedAppPackages),
            PreventBackups = Labels.GetLabelYesNoBlank(policy.DataBackupBlocked),
            SendOrgDataToOtherApps = GetManagedAppDataTransferLevelLabel(policy.AllowedOutboundDataTransferDestinations, null, null),

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
            AppsToExempt = GetCustomAppsString(policy.ExemptApps, policy.ExemptAppLockerFiles),
            PreventBackups = Labels.NotApplicableString,
            SendOrgDataToOtherApps = Labels.NotApplicableString,

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

    // private void SetCompliancePolicyView(AppProtectionPolicyView view, AospDeviceOwnerCompliancePolicy policy)
    // {
    //     view.Platform = "Android (AOSP)";
    //     view.PolicyType = "Android (AOSP) compliance policy";
    //     view.DefenderForEndPoint = Labels.NotApplicableString;
    //     view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
    //     view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
    //     view.PasswordExpirationDays = Labels.NotApplicableString;
    //     view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
    //     view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
    //     view.PasswordPreviousPasswordBlockCount = Labels.NotApplicableString;
    //     view.PasswordRequired = policy.PasswordRequired == true ? Labels.RequireString : string.Empty;
    //     view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);
    //     view.StorageRequireEncryption = policy.StorageRequireEncryption == true ? Labels.RequireString : string.Empty;
    //     view.SecurityBlockJailbrokenDevices = policy.SecurityBlockJailbrokenDevices == true ? Labels.BlockedString : string.Empty;
    //     view.DeviceThreatProtectionRequiredSecurityLevel = Labels.NotApplicableString;
    //     view.ActiveFirewallRequired = Labels.NotApplicableString;

    //     AppProtectionPolicyViews.SetActionForNoncompliance(view, policy.ScheduledActionsForRule);
    // }
    // private void SetCompliancePolicyView(AppProtectionPolicyView view, AndroidCompliancePolicy policy)
    // {
    //     view.Platform = "Android device administrator";
    //     view.PolicyType = "Android compliance policy";
    //     view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.AdvancedThreatProtectionRequiredSecurityLevel);
    //     view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
    //     view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
    //     view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
    //     view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
    //     view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
    //     view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
    //     view.PasswordRequired = policy.PasswordRequired == true ? Labels.RequireString : string.Empty;
    //     view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);
    //     view.StorageRequireEncryption = policy.StorageRequireEncryption == true ? Labels.RequireString : string.Empty;
    //     view.SecurityBlockJailbrokenDevices = policy.SecurityBlockJailbrokenDevices == true ? Labels.BlockedString : string.Empty;
    //     view.DeviceThreatProtectionRequiredSecurityLevel = GetDeviceThreatLevelString(policy.DeviceThreatProtectionRequiredSecurityLevel);
    //     view.ActiveFirewallRequired = Labels.NotApplicableString;

    //     AppProtectionPolicyViews.SetActionForNoncompliance(view, policy.ScheduledActionsForRule);
    // }
    // private void SetCompliancePolicyView(AppProtectionPolicyView view, AndroidWorkProfileCompliancePolicy policy)
    // {
    //     view.Platform = "Android Enterprise (Personal)";
    //     view.PolicyType = "Personally-owned work profile";
    //     view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.AdvancedThreatProtectionRequiredSecurityLevel);
    //     view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
    //     view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
    //     view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
    //     view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
    //     view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
    //     view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
    //     view.PasswordRequired = policy.PasswordRequired == true ? Labels.RequireString : string.Empty;
    //     view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);
    //     view.StorageRequireEncryption = policy.StorageRequireEncryption == true ? Labels.RequireString : string.Empty;
    //     view.SecurityBlockJailbrokenDevices = policy.SecurityBlockJailbrokenDevices == true ? Labels.BlockedString : string.Empty;
    //     view.DeviceThreatProtectionRequiredSecurityLevel = GetDeviceThreatLevelString(policy.DeviceThreatProtectionRequiredSecurityLevel);
    //     view.ActiveFirewallRequired = Labels.NotApplicableString;

    //     AppProtectionPolicyViews.SetActionForNoncompliance(view, policy.ScheduledActionsForRule);
    // }
    // private void SetCompliancePolicyView(AppProtectionPolicyView view, IosCompliancePolicy policy)
    // {
    //     view.Platform = "iOS/iPadOS";
    //     view.PolicyType = "iOS compliance policy";
    //     view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.AdvancedThreatProtectionRequiredSecurityLevel);
    //     view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
    //     view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
    //     view.PasswordExpirationDays = policy.PasscodeExpirationDays?.ToString() ?? string.Empty;
    //     view.PasswordMinutesOfInactivityBeforeLock = policy.PasscodeMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
    //     view.PasswordMinimumLength = policy.PasscodeMinimumLength?.ToString() ?? string.Empty;
    //     view.PasswordPreviousPasswordBlockCount = policy.PasscodePreviousPasscodeBlockCount?.ToString() ?? string.Empty;
    //     view.PasswordRequired = policy.PasscodeRequired == true ? Labels.RequireString : string.Empty;
    //     view.PasswordRequiredType = GetPasswordRequiredType(policy.PasscodeRequiredType);
    //     view.StorageRequireEncryption = Labels.NotApplicableString;
    //     view.SecurityBlockJailbrokenDevices = policy.SecurityBlockJailbrokenDevices == true ? Labels.BlockedString : string.Empty;
    //     view.DeviceThreatProtectionRequiredSecurityLevel = GetDeviceThreatLevelString(policy.DeviceThreatProtectionRequiredSecurityLevel);
    //     view.ActiveFirewallRequired = Labels.NotApplicableString;

    //     AppProtectionPolicyViews.SetActionForNoncompliance(view, policy.ScheduledActionsForRule);
    // }

    // private void SetCompliancePolicyView(AppProtectionPolicyView view, MacOSCompliancePolicy policy)
    // {
    //     view.Platform = "macOS";
    //     view.PolicyType = "Mac compliance policy";
    //     view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.AdvancedThreatProtectionRequiredSecurityLevel);
    //     view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
    //     view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
    //     view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
    //     view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
    //     view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
    //     view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
    //     view.PasswordRequired = policy.PasswordRequired == true ? Labels.RequireString : string.Empty;
    //     view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);
    //     view.StorageRequireEncryption = policy.StorageRequireEncryption == true ? Labels.RequireString : string.Empty;
    //     view.SecurityBlockJailbrokenDevices = Labels.NotApplicableString;
    //     view.DeviceThreatProtectionRequiredSecurityLevel = GetDeviceThreatLevelString(policy.DeviceThreatProtectionRequiredSecurityLevel);
    //     view.ActiveFirewallRequired = policy.FirewallEnabled == true ? Labels.RequireString : string.Empty;

    //     AppProtectionPolicyViews.SetActionForNoncompliance(view, policy.ScheduledActionsForRule);

    // }
    // private void SetCompliancePolicyView(AppProtectionPolicyView view, Windows81CompliancePolicy policy)
    // {
    //     view.Platform = "Windows 8.1 and later";
    //     view.PolicyType = "Windows 8 compliance policy";
    //     view.DefenderForEndPoint = Labels.NotApplicableString;
    //     view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
    //     view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
    //     view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
    //     view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
    //     view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
    //     view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
    //     view.PasswordRequired = policy.PasswordRequired == true ? Labels.RequireString : string.Empty;
    //     view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);
    //     view.StorageRequireEncryption = policy.StorageRequireEncryption == true ? Labels.RequireString : string.Empty;
    //     view.DeviceThreatProtectionRequiredSecurityLevel = Labels.NotApplicableString;
    //     view.SecurityBlockJailbrokenDevices = Labels.NotApplicableString;
    //     view.ActiveFirewallRequired = Labels.NotApplicableString;

    //     AppProtectionPolicyViews.SetActionForNoncompliance(view, policy.ScheduledActionsForRule);
    // }
    // private void SetCompliancePolicyView(AppProtectionPolicyView view, Windows10CompliancePolicy policy)
    // {
    //     view.Platform = "Windows 10 and later";
    //     view.PolicyType = "Windows 10/11 compliance policy";
    //     view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.DeviceThreatProtectionRequiredSecurityLevel);
    //     view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
    //     view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
    //     view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
    //     view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
    //     view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
    //     view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
    //     view.PasswordRequired = policy.PasswordRequired == true ? Labels.RequireString : string.Empty;
    //     view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);
    //     view.StorageRequireEncryption = policy.StorageRequireEncryption == true ? Labels.RequireString : string.Empty;
    //     view.SecurityBlockJailbrokenDevices = Labels.NotApplicableString;
    //     view.DeviceThreatProtectionRequiredSecurityLevel = Labels.NotApplicableString;
    //     view.ActiveFirewallRequired = policy.ActiveFirewallRequired == true ? Labels.RequireString : string.Empty;

    //     AppProtectionPolicyViews.SetActionForNoncompliance(view, policy.ScheduledActionsForRule);

    //     view.AntiSpywareRequired = policy.AntiSpywareRequired == true ? Labels.RequireString : string.Empty;
    //     view.AntivirusRequired = policy.AntivirusRequired == true ? Labels.RequireString : string.Empty;
    //     view.BitLockerEnabled = policy.BitLockerEnabled == true ? Labels.RequireString : string.Empty;
    //     view.CodeIntegrityEnabled = policy.CodeIntegrityEnabled == true ? Labels.RequireString : string.Empty;
    //     view.ConfigurationManagerComplianceRequired = policy.ConfigurationManagerComplianceRequired == true ? Labels.RequireString : string.Empty;

    //     view.DefenderVersion = policy.DefenderVersion ?? string.Empty;
    //     view.DeviceCompliancePolicyScript = policy.DeviceCompliancePolicyScript == null ? Labels.NotConfiguredString : Labels.ConfiguredString;


    //     view.EarlyLaunchAntiMalwareDriverEnabled = policy.EarlyLaunchAntiMalwareDriverEnabled == true ? Labels.RequireString : string.Empty;
    //     view.MobileOsMaximumVersion = policy.MobileOsMaximumVersion?.ToString() ?? string.Empty;
    //     view.MobileOsMinimumVersion = policy.MobileOsMinimumVersion?.ToString() ?? string.Empty;
    //     view.PasswordBlockSimple = policy.PasswordBlockSimple == true ? Labels.BlockedString : string.Empty;
    //     view.PasswordMinimumCharacterSetCount = policy.PasswordMinimumCharacterSetCount?.ToString() ?? string.Empty;
    //     view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
    //     view.PasswordRequired = policy.PasswordRequired == true ? Labels.RequireString : string.Empty;
    //     view.PasswordRequiredToUnlockFromIdle = policy.PasswordRequiredToUnlockFromIdle == true ? Labels.RequireString : string.Empty;
    //     view.RequireHealthyDeviceReport = policy.RequireHealthyDeviceReport == true ? Labels.RequireString : string.Empty;
    //     view.RoleScopeTagIds = _graphData.GetScopesString(policy.RoleScopeTagIds);
    //     view.RtpEnabled = policy.RtpEnabled == true ? Labels.RequireString : string.Empty;
    //     view.SecureBootEnabled = policy.SecureBootEnabled == true ? Labels.RequireString : string.Empty;
    //     view.SignatureOutOfDate = policy.SignatureOutOfDate?.ToString() ?? string.Empty;

    //     view.TpmRequired = policy.TpmRequired == true ? Labels.RequireString : string.Empty;

    //     if (policy.ValidOperatingSystemBuildRanges != null)
    //     {
    //         foreach (var range in policy.ValidOperatingSystemBuildRanges)
    //         {
    //             if (!string.IsNullOrEmpty(view.ValidOperatingSystemBuildRanges)) view.ValidOperatingSystemBuildRanges += ", ";
    //             view.ValidOperatingSystemBuildRanges += string.Format("({0} - {1})", range.LowestVersion?.ToString() ?? string.Empty, range.HighestVersion?.ToString() ?? string.Empty);
    //         }
    //     }
    // }

    // private static void SetActionForNoncompliance(AppProtectionPolicyView view, List<DeviceComplianceScheduledActionForRule>? scheduledActionsForRule)
    // {
    //     var config = scheduledActionsForRule?.FirstOrDefault()?.ScheduledActionConfigurations;
    //     if (config != null)
    //     {
    //         foreach (var action in config)
    //         {
    //             if (action.GracePeriodHours.HasValue)
    //             {
    //                 var gracePeriod = Helper.ConvertHoursToTotalDays(action.GracePeriodHours.Value);
    //                 var gracePeriodDays = gracePeriod == 0 ? "Immediately" : gracePeriod.ToString();
    //                 switch (action.ActionType)
    //                 {
    //                     case DeviceComplianceActionType.Block:
    //                         view.NoncomplianceActionBlock = gracePeriodDays;
    //                         break;
    //                     case DeviceComplianceActionType.PushNotification:
    //                         view.NoncomplianceActionPushNotification = gracePeriodDays;
    //                         break;
    //                     case DeviceComplianceActionType.Notification:
    //                         view.NoncomplianceActionNotification = gracePeriodDays;
    //                         break;
    //                     case DeviceComplianceActionType.RemoteLock:
    //                         view.NoncomplianceActionRemoteLock = gracePeriodDays;
    //                         break;
    //                     case DeviceComplianceActionType.Retire:
    //                         view.NoncomplianceActionRetire = gracePeriodDays;
    //                         break;
    //                 }
    //             }
    //         }
    //     }
    // }

    // private static string? GetPasswordRequiredType(RequiredPasswordType? passwordRequiredType)
    // {
    //     return passwordRequiredType switch
    //     {
    //         RequiredPasswordType.DeviceDefault => "Device default",
    //         RequiredPasswordType.Numeric => "Numeric",
    //         RequiredPasswordType.Alphanumeric => "Alphanumeric",
    //         _ => Labels.NotConfiguredString,
    //     };
    // }

    // private static string? GetPasswordRequiredType(AndroidDeviceOwnerRequiredPasswordType? passwordRequiredType)
    // {
    //     return passwordRequiredType switch
    //     {
    //         AndroidDeviceOwnerRequiredPasswordType.DeviceDefault => "Device default",
    //         AndroidDeviceOwnerRequiredPasswordType.Alphabetic => "Alphabetic",
    //         AndroidDeviceOwnerRequiredPasswordType.Alphanumeric => "Alphanumeric",
    //         AndroidDeviceOwnerRequiredPasswordType.AlphanumericWithSymbols => "Alphanumeric with symbols",
    //         AndroidDeviceOwnerRequiredPasswordType.Required => "Password required",
    //         AndroidDeviceOwnerRequiredPasswordType.LowSecurityBiometric => "Biometric (low security)",
    //         AndroidDeviceOwnerRequiredPasswordType.Numeric => "Numeric",
    //         AndroidDeviceOwnerRequiredPasswordType.NumericComplex => "Numeric complex",
    //         _ => Labels.NotConfiguredString,
    //     };
    // }

    // private static string? GetPasswordRequiredType(AndroidRequiredPasswordType? passwordRequiredType)
    // {
    //     return passwordRequiredType switch
    //     {
    //         AndroidRequiredPasswordType.DeviceDefault => "Device default",
    //         AndroidRequiredPasswordType.Alphabetic => "Alphabetic",
    //         AndroidRequiredPasswordType.Alphanumeric => "Alphanumeric",
    //         AndroidRequiredPasswordType.AlphanumericWithSymbols => "Alphanumeric with symbols",
    //         AndroidRequiredPasswordType.Any => "Any",
    //         AndroidRequiredPasswordType.LowSecurityBiometric => "Biometric (low security)",
    //         AndroidRequiredPasswordType.Numeric => "Numeric",
    //         AndroidRequiredPasswordType.NumericComplex => "Numeric complex",
    //         _ => Labels.NotConfiguredString,
    //     };
    // }

    // private static string GetDefenderEndPointLabel(DeviceThreatProtectionLevel? advancedThreatProtectionRequiredSecurityLevel)
    // {
    //     return advancedThreatProtectionRequiredSecurityLevel switch
    //     {
    //         DeviceThreatProtectionLevel.Unavailable or DeviceThreatProtectionLevel.NotSet => string.Empty,
    //         DeviceThreatProtectionLevel.Secured => "Clear", // <-- This label is the only difference between device threat level and ATP
    //         DeviceThreatProtectionLevel.Low => "Low",
    //         DeviceThreatProtectionLevel.Medium => "Medium",
    //         DeviceThreatProtectionLevel.High => "High",
    //         _ => Labels.NotConfiguredString,
    //     };
    // }
    // private static string? GetDeviceThreatLevelString(DeviceThreatProtectionLevel? deviceThreatProtectionRequiredSecurityLevel)
    // {
    //     return deviceThreatProtectionRequiredSecurityLevel switch
    //     {
    //         DeviceThreatProtectionLevel.Unavailable or DeviceThreatProtectionLevel.NotSet => string.Empty,
    //         DeviceThreatProtectionLevel.Secured => "Secured", // <-- This label is the only difference between device threat level and ATP
    //         DeviceThreatProtectionLevel.Low => "Low",
    //         DeviceThreatProtectionLevel.Medium => "Medium",
    //         DeviceThreatProtectionLevel.High => "High",
    //         _ => Labels.NotConfiguredString,
    //     };
    // }
}