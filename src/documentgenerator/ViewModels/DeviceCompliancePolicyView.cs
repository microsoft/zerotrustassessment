using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;

namespace ZeroTrustAssessment.DocumentGenerator.ViewModels;
public class DeviceCompliancePolicyView
{
    public string Platform { get; set; } = string.Empty;
    public string ActiveFirewallRequired { get; set; } = string.Empty;
    public string AntiSpywareRequired { get; set; } = string.Empty;
    public string AntivirusRequired { get; set; } = string.Empty;
    public string BitLockerEnabled { get; set; } = string.Empty;
    public string CodeIntegrityEnabled { get; set; } = string.Empty;
    public string ConfigurationManagerComplianceRequired { get; set; } = string.Empty;
    public string DefenderEnabled { get; set; } = string.Empty;
    public string DefenderVersion { get; set; } = string.Empty;
    public string DeviceCompliancePolicyScript { get; set; } = string.Empty;
    public string DeviceThreatProtectionEnabled { get; set; } = string.Empty;
    public string DeviceThreatProtectionRequiredSecurityLevel { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public string EarlyLaunchAntiMalwareDriverEnabled { get; set; } = string.Empty;
    public string MobileOsMaximumVersion { get; set; } = string.Empty;
    public string MobileOsMinimumVersion { get; set; } = string.Empty;
    public string OsMaximumVersion { get; set; } = string.Empty;
    public string OsMinimumVersion { get; set; } = string.Empty;
    public string PasswordBlockSimple { get; set; } = string.Empty;
    public string PasswordExpirationDays { get; set; } = string.Empty;
    public string PasswordMinimumCharacterSetCount { get; set; } = string.Empty;
    public string PasswordMinimumLength { get; set; } = string.Empty;
    public string PasswordMinutesOfInactivityBeforeLock { get; set; } = string.Empty;
    public string PasswordPreviousPasswordBlockCount { get; set; } = string.Empty;
    public string PasswordRequired { get; set; } = string.Empty;
    public string PasswordRequiredToUnlockFromIdle { get; set; } = string.Empty;
    public string PasswordRequiredType { get; set; } = string.Empty;
    public string RequireHealthyDeviceReport { get; set; } = string.Empty;
    public string RoleScopeTagIds { get; set; } = string.Empty;
    public string RtpEnabled { get; set; } = string.Empty;
    public string SecureBootEnabled { get; set; } = string.Empty;
    public string SignatureOutOfDate { get; set; } = string.Empty;
    public string StorageRequireEncryption { get; set; } = string.Empty;
    public string TpmRequired { get; set; } = string.Empty;
    public string ValidOperatingSystemBuildRanges { get; set; } = string.Empty;

    public string Scopes { get; set; } = string.Empty;
    public string Assignments { get; set; } = string.Empty;

    private readonly GraphData _graphData;
    public DeviceCompliancePolicyView(GraphData graphData, DeviceCompliancePolicy policy)
    {
        _graphData = graphData;
        DisplayName = policy.DisplayName ?? string.Empty;
        if (policy is Windows10CompliancePolicy windows10CompliancePolicy)
        {
            Platform = Labels.PlatformWindows;
            InitDeviceCompliancePolicyView(windows10CompliancePolicy);
        }
        else if (policy is IosCompliancePolicy iosCompliancePolicy)
        {
            Platform = Labels.PlatformIos;
            InitDeviceCompliancePolicyView(iosCompliancePolicy);
        }
        else if (policy is MacOSCompliancePolicy macOSCompliancePolicy)
        {
            Platform = Labels.PlatformMacOs;
            InitDeviceCompliancePolicyView(macOSCompliancePolicy);
        }
        else if (policy is AndroidWorkProfileCompliancePolicy androidWorkProfileCompliancePolicy)
        {
            Platform = Labels.PlatformWindows;
            InitDeviceCompliancePolicyView(androidWorkProfileCompliancePolicy);
        }
        else if (policy is AndroidCompliancePolicy androidCompliancePolicy)
        {
            Platform = Labels.PlatformWindows;
            InitDeviceCompliancePolicyView(androidCompliancePolicy);
        }
        else if (policy is AospDeviceOwnerCompliancePolicy aospDeviceOwnerCompliancePolicy)
        {
            Platform = Labels.PlatformWindows;
            InitDeviceCompliancePolicyView(aospDeviceOwnerCompliancePolicy);
        }
        else if (policy is AndroidDeviceOwnerCompliancePolicy androidDeviceOwnerCompliancePolicy)
        {
            Platform = Labels.PlatformWindows;
            InitDeviceCompliancePolicyView(androidDeviceOwnerCompliancePolicy);
        }
        else if (policy is Windows81CompliancePolicy windows81CompliancePolicy)
        {
            Platform = Labels.PlatformWindows;
            InitDeviceCompliancePolicyView(windows81CompliancePolicy);
        }

        Scopes = _graphData.GetScopesString(policy.RoleScopeTagIds);
        Assignments = _graphData.GetGroupAssignmentTargetText(policy.Assignments);
    }

    public void InitDeviceCompliancePolicyView(AndroidDeviceOwnerCompliancePolicy policy) { }
    public void InitDeviceCompliancePolicyView(AospDeviceOwnerCompliancePolicy policy) { }
    public void InitDeviceCompliancePolicyView(AndroidCompliancePolicy policy) { }
    public void InitDeviceCompliancePolicyView(AndroidWorkProfileCompliancePolicy policy) { }
    public void InitDeviceCompliancePolicyView(MacOSCompliancePolicy policy) { }
    public void InitDeviceCompliancePolicyView(IosCompliancePolicy policy) { }
    public void InitDeviceCompliancePolicyView(Windows81CompliancePolicy policy) { }

    public void InitDeviceCompliancePolicyView(Windows10CompliancePolicy policy)
    {
        ActiveFirewallRequired = policy.ActiveFirewallRequired == true ? "Require" : string.Empty;
        AntiSpywareRequired = policy.AntiSpywareRequired == true ? "Require" : string.Empty;
        AntivirusRequired = policy.AntivirusRequired == true ? "Require" : string.Empty;
        BitLockerEnabled = policy.BitLockerEnabled == true ? "Require" : string.Empty;
        CodeIntegrityEnabled = policy.CodeIntegrityEnabled == true ? "Require" : string.Empty;
        ConfigurationManagerComplianceRequired = policy.ConfigurationManagerComplianceRequired == true ? "Require" : string.Empty;
        DefenderEnabled = policy.DefenderEnabled == true ? "Require" : string.Empty;
        DefenderVersion = policy.DefenderVersion ?? string.Empty;
        DeviceCompliancePolicyScript = policy.DeviceCompliancePolicyScript == null ? "Not configured" : "Configured";
        DeviceThreatProtectionEnabled = policy.DeviceThreatProtectionEnabled == true ? "Require" : string.Empty;
        DeviceThreatProtectionRequiredSecurityLevel = policy.DeviceThreatProtectionRequiredSecurityLevel?.ToString() ?? string.Empty;
        EarlyLaunchAntiMalwareDriverEnabled = policy.EarlyLaunchAntiMalwareDriverEnabled == true ? "Require" : string.Empty;
        MobileOsMaximumVersion = policy.MobileOsMaximumVersion?.ToString() ?? string.Empty;
        MobileOsMinimumVersion = policy.MobileOsMinimumVersion?.ToString() ?? string.Empty;
        OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
        OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
        PasswordBlockSimple = policy.PasswordBlockSimple == true ? "Blocked" : string.Empty;
        PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
        PasswordMinimumCharacterSetCount = policy.PasswordMinimumCharacterSetCount?.ToString() ?? string.Empty;
        PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
        PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
        PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
        PasswordRequired = policy.PasswordRequired == true ? "Require" : string.Empty;
        PasswordRequiredToUnlockFromIdle = policy.PasswordRequiredToUnlockFromIdle == true ? "Require" : string.Empty;
        PasswordRequiredType = policy.PasswordRequiredType?.ToString() ?? string.Empty;
        RequireHealthyDeviceReport = policy.RequireHealthyDeviceReport == true ? "Require" : string.Empty;
        RoleScopeTagIds = _graphData.GetScopesString(policy.RoleScopeTagIds);
        RtpEnabled = policy.RtpEnabled == true ? "Require" : string.Empty;
        SecureBootEnabled = policy.SecureBootEnabled == true ? "Require" : string.Empty;
        SignatureOutOfDate = policy.SignatureOutOfDate?.ToString() ?? string.Empty;
        StorageRequireEncryption = policy.StorageRequireEncryption == true ? "Require" : string.Empty;
        TpmRequired = policy.TpmRequired == true ? "Require" : string.Empty;

        if (policy.ValidOperatingSystemBuildRanges != null)
        {
            foreach (var range in policy.ValidOperatingSystemBuildRanges)
            {
                if (!string.IsNullOrEmpty(ValidOperatingSystemBuildRanges)) ValidOperatingSystemBuildRanges += ", ";
                ValidOperatingSystemBuildRanges += string.Format("({0} - {1})", range.LowestVersion?.ToString() ?? string.Empty, range.HighestVersion?.ToString() ?? string.Empty);
            }
        }
    }
}