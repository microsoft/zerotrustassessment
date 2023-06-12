using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.ViewModels;
public class DeviceCompliancePolicyViews
{
    private readonly GraphData _graphData;
    private const string NotApplicableString = "N/A";
    private const string RequireString = "Yes";
    private const string NotRequiredString = "Not required";
    private const string ConfiguredString = "Configured";
    private const string NotConfiguredString = "Not configured";
    private const string BlockedString = "Blocked";
    public DeviceCompliancePolicyViews(GraphData graphData)
    {
        _graphData = graphData;
    }
    public List<DeviceCompliancePolicyView> GetViews()
    {
        //TODO Add linux
        var views = new List<DeviceCompliancePolicyView>();
        var compliancePolicies = _graphData.DeviceCompliancePolicies;
        if (compliancePolicies != null)
        {
            foreach (var policy in compliancePolicies)
            {
                var view = new DeviceCompliancePolicyView
                {
                    Id = policy.Id,
                    DisplayName = policy.DisplayName,
                    Scopes = _graphData.GetScopesString(policy.RoleScopeTagIds),
                    Assignments = _graphData.GetGroupAssignmentTargetText(policy.Assignments)
                };

                if (policy is Windows10CompliancePolicy windows10CompliancePolicy) { SetCompliancePolicyView(view, windows10CompliancePolicy); }
                else if (policy is IosCompliancePolicy iosCompliancePolicy) { SetCompliancePolicyView(view, iosCompliancePolicy); }
                else if (policy is MacOSCompliancePolicy macOSCompliancePolicy) { SetCompliancePolicyView(view, macOSCompliancePolicy); }
                else if (policy is AndroidWorkProfileCompliancePolicy androidWorkProfileCompliancePolicy) { SetCompliancePolicyView(view, androidWorkProfileCompliancePolicy); }
                else if (policy is AndroidCompliancePolicy androidCompliancePolicy) { SetCompliancePolicyView(view, androidCompliancePolicy); }
                else if (policy is AospDeviceOwnerCompliancePolicy aospDeviceOwnerCompliancePolicy) { SetCompliancePolicyView(view, aospDeviceOwnerCompliancePolicy); }
                else if (policy is AndroidDeviceOwnerCompliancePolicy androidDeviceOwnerCompliancePolicy) { SetCompliancePolicyView(view, androidDeviceOwnerCompliancePolicy); }
                else if (policy is Windows81CompliancePolicy windows81CompliancePolicy) { SetCompliancePolicyView(view, windows81CompliancePolicy); }
                views.Add(view);
            }
        }
        return views;
    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, AndroidDeviceOwnerCompliancePolicy policy)
    {
        view.Platform = "Android Enterprise (Corp)";
        view.PolicyType = "Fully managed, dedicated, and corporate-owned work profile";
        view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.AdvancedThreatProtectionRequiredSecurityLevel);
        view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
        view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
        view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
        view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
        view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
        view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordCountToBlock?.ToString() ?? string.Empty;
        view.PasswordRequired = policy.PasswordRequired == true ? RequireString : string.Empty;
        view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);

    }

    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, AospDeviceOwnerCompliancePolicy policy)
    {
        view.Platform = "Android (AOSP)";
        view.PolicyType = "Android (AOSP) compliance policy";
        view.DefenderForEndPoint = NotApplicableString;
        view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
        view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
        view.PasswordExpirationDays = NotApplicableString;
        view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
        view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
        view.PasswordPreviousPasswordBlockCount = NotApplicableString;
        view.PasswordRequired = policy.PasswordRequired == true ? RequireString : string.Empty;
        view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);

    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, AndroidCompliancePolicy policy)
    {
        view.Platform = "Android device administrator";
        view.PolicyType = "Android compliance policy";
        view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.AdvancedThreatProtectionRequiredSecurityLevel);
        view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
        view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
        view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
        view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
        view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
        view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
        view.PasswordRequired = policy.PasswordRequired == true ? RequireString : string.Empty;
        view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);

    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, AndroidWorkProfileCompliancePolicy policy)
    {
        view.Platform = "Android Enterprise (Personal)";
        view.PolicyType = "Personally-owned work profile";
        view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.AdvancedThreatProtectionRequiredSecurityLevel);
        view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
        view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
        view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
        view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
        view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
        view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
        view.PasswordRequired = policy.PasswordRequired == true ? RequireString : string.Empty;
        view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);

    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, IosCompliancePolicy policy)
    {
        view.Platform = "iOS/iPadOS";
        view.PolicyType = "iOS compliance policy";
        view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.AdvancedThreatProtectionRequiredSecurityLevel);
        view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
        view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
        view.PasswordExpirationDays = policy.PasscodeExpirationDays?.ToString() ?? string.Empty;
        view.PasswordMinutesOfInactivityBeforeLock = policy.PasscodeMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
        view.PasswordMinimumLength = policy.PasscodeMinimumLength?.ToString() ?? string.Empty;
        view.PasswordPreviousPasswordBlockCount = policy.PasscodePreviousPasscodeBlockCount?.ToString() ?? string.Empty;
        view.PasswordRequired = policy.PasscodeRequired == true ? RequireString : string.Empty;
        view.PasswordRequiredType = GetPasswordRequiredType(policy.PasscodeRequiredType);

    }

    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, MacOSCompliancePolicy policy)
    {
        view.Platform = "macOS";
        view.PolicyType = "Mac compliance policy";
        view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.AdvancedThreatProtectionRequiredSecurityLevel);
        view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
        view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
        view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
        view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
        view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
        view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
        view.PasswordRequired = policy.PasswordRequired == true ? RequireString : string.Empty;
        view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);

        view.ActiveFirewallRequired = policy.FirewallEnabled == true ? RequireString : string.Empty;

    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, Windows81CompliancePolicy policy)
    {
        view.Platform = "Windows 8.1 and later";
        view.PolicyType = "Windows 8 compliance policy";
        view.DefenderForEndPoint = NotApplicableString;
        view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
        view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
        view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
        view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
        view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
        view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
        view.PasswordRequired = policy.PasswordRequired == true ? RequireString : string.Empty;
        view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);

    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, Windows10CompliancePolicy policy)
    {
        view.Platform = "Windows 10 and later";
        view.PolicyType = "Windows 10/11 compliance policy";
        view.DefenderForEndPoint = GetDefenderEndPointLabel(policy.DeviceThreatProtectionRequiredSecurityLevel);
        view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
        view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
        view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
        view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
        view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
        view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
        view.PasswordRequired = policy.PasswordRequired == true ? RequireString : string.Empty;
        view.PasswordRequiredType = GetPasswordRequiredType(policy.PasswordRequiredType);

        view.ActiveFirewallRequired = policy.ActiveFirewallRequired == true ? RequireString : string.Empty;
        view.AntiSpywareRequired = policy.AntiSpywareRequired == true ? RequireString : string.Empty;
        view.AntivirusRequired = policy.AntivirusRequired == true ? RequireString : string.Empty;
        view.BitLockerEnabled = policy.BitLockerEnabled == true ? RequireString : string.Empty;
        view.CodeIntegrityEnabled = policy.CodeIntegrityEnabled == true ? RequireString : string.Empty;
        view.ConfigurationManagerComplianceRequired = policy.ConfigurationManagerComplianceRequired == true ? RequireString : string.Empty;

        view.DefenderVersion = policy.DefenderVersion ?? string.Empty;
        view.DeviceCompliancePolicyScript = policy.DeviceCompliancePolicyScript == null ? NotConfiguredString : ConfiguredString;
        view.DeviceThreatProtectionEnabled = policy.DeviceThreatProtectionEnabled == true ? RequireString : string.Empty;
        view.DeviceThreatProtectionRequiredSecurityLevel = policy.DeviceThreatProtectionRequiredSecurityLevel?.ToString() ?? string.Empty;
        view.EarlyLaunchAntiMalwareDriverEnabled = policy.EarlyLaunchAntiMalwareDriverEnabled == true ? RequireString : string.Empty;
        view.MobileOsMaximumVersion = policy.MobileOsMaximumVersion?.ToString() ?? string.Empty;
        view.MobileOsMinimumVersion = policy.MobileOsMinimumVersion?.ToString() ?? string.Empty;
        view.PasswordBlockSimple = policy.PasswordBlockSimple == true ? BlockedString : string.Empty;
        view.PasswordMinimumCharacterSetCount = policy.PasswordMinimumCharacterSetCount?.ToString() ?? string.Empty;
        view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
        view.PasswordRequired = policy.PasswordRequired == true ? RequireString : string.Empty;
        view.PasswordRequiredToUnlockFromIdle = policy.PasswordRequiredToUnlockFromIdle == true ? RequireString : string.Empty;
        view.RequireHealthyDeviceReport = policy.RequireHealthyDeviceReport == true ? RequireString : string.Empty;
        view.RoleScopeTagIds = _graphData.GetScopesString(policy.RoleScopeTagIds);
        view.RtpEnabled = policy.RtpEnabled == true ? RequireString : string.Empty;
        view.SecureBootEnabled = policy.SecureBootEnabled == true ? RequireString : string.Empty;
        view.SignatureOutOfDate = policy.SignatureOutOfDate?.ToString() ?? string.Empty;
        view.StorageRequireEncryption = policy.StorageRequireEncryption == true ? RequireString : string.Empty;
        view.TpmRequired = policy.TpmRequired == true ? RequireString : string.Empty;

        if (policy.ValidOperatingSystemBuildRanges != null)
        {
            foreach (var range in policy.ValidOperatingSystemBuildRanges)
            {
                if (!string.IsNullOrEmpty(view.ValidOperatingSystemBuildRanges)) view.ValidOperatingSystemBuildRanges += ", ";
                view.ValidOperatingSystemBuildRanges += string.Format("({0} - {1})", range.LowestVersion?.ToString() ?? string.Empty, range.HighestVersion?.ToString() ?? string.Empty);
            }
        }
    }

    private static string? GetPasswordRequiredType(RequiredPasswordType? passwordRequiredType)
    {
        return passwordRequiredType switch
        {
            RequiredPasswordType.DeviceDefault => "Device default",
            RequiredPasswordType.Numeric => "Numeric",
            RequiredPasswordType.Alphanumeric => "Alphanumeric",
            _ => NotConfiguredString,
        };
    }

    private static string? GetPasswordRequiredType(AndroidDeviceOwnerRequiredPasswordType? passwordRequiredType)
    {
        return passwordRequiredType switch
        {
            AndroidDeviceOwnerRequiredPasswordType.DeviceDefault => "Device default",
            AndroidDeviceOwnerRequiredPasswordType.Alphabetic => "Alphabetic",
            AndroidDeviceOwnerRequiredPasswordType.Alphanumeric => "Alphanumeric",
            AndroidDeviceOwnerRequiredPasswordType.AlphanumericWithSymbols => "Alphanumeric with symbols",
            AndroidDeviceOwnerRequiredPasswordType.Required => "Password required",
            AndroidDeviceOwnerRequiredPasswordType.LowSecurityBiometric => "Biometric (low security)",
            AndroidDeviceOwnerRequiredPasswordType.Numeric => "Numeric",
            AndroidDeviceOwnerRequiredPasswordType.NumericComplex => "Numeric complex",
            _ => NotConfiguredString,
        };
    }

    private static string? GetPasswordRequiredType(AndroidRequiredPasswordType? passwordRequiredType)
    {
        return passwordRequiredType switch
        {
            AndroidRequiredPasswordType.DeviceDefault => "Device default",
            AndroidRequiredPasswordType.Alphabetic => "Alphabetic",
            AndroidRequiredPasswordType.Alphanumeric => "Alphanumeric",
            AndroidRequiredPasswordType.AlphanumericWithSymbols => "Alphanumeric with symbols",
            AndroidRequiredPasswordType.Any => "Any",
            AndroidRequiredPasswordType.LowSecurityBiometric => "Biometric (low security)",
            AndroidRequiredPasswordType.Numeric => "Numeric",
            AndroidRequiredPasswordType.NumericComplex => "Numeric complex",
            _ => NotConfiguredString,
        };
    }

    private static string GetDefenderEndPointLabel(DeviceThreatProtectionLevel? advancedThreatProtectionRequiredSecurityLevel)
    {
        return advancedThreatProtectionRequiredSecurityLevel switch
        {
            DeviceThreatProtectionLevel.Unavailable or DeviceThreatProtectionLevel.NotSet => string.Empty,
            DeviceThreatProtectionLevel.Secured => "Clear",
            DeviceThreatProtectionLevel.Low => "Low",
            DeviceThreatProtectionLevel.Medium => "Medium",
            DeviceThreatProtectionLevel.High => "High",
            _ => NotConfiguredString,
        };
    }
}