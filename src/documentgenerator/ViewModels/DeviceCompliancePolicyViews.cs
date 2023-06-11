using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.ViewModels;
public class DeviceCompliancePolicyViews
{
    private readonly GraphData _graphData;
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
        view.Platform = "Android Enterprise";
        view.PolicyType = "Fully managed, dedicated, and corporate-owned work profile";
    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, AospDeviceOwnerCompliancePolicy policy)
    {
        view.Platform = "Android (AOSP)";
        view.PolicyType = "Android (AOSP) compliance policy";
    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, AndroidCompliancePolicy policy)
    {
        view.Platform = "Android device administrator";
        view.PolicyType = "Android compliance policy";
    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, AndroidWorkProfileCompliancePolicy policy)
    {
        view.Platform = "Android Enterprise";
        view.PolicyType = "Personally-owned work profile";

    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, MacOSCompliancePolicy policy)
    {
        view.Platform = "macOS";
        view.PolicyType = "Mac compliance policy";

    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, IosCompliancePolicy policy)
    {
        view.Platform = "iOS/iPadOS";
        view.PolicyType = "iOS compliance policy";

    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, Windows81CompliancePolicy policy)
    {
        view.Platform = "Windows 8.1 and later";
        view.PolicyType = "Windows 8 compliance policy";

    }
    private void SetCompliancePolicyView(DeviceCompliancePolicyView view, Windows10CompliancePolicy policy)
    {
        view.Platform = "Windows 10 and later";
        view.PolicyType = "Windows 10/11 compliance policy";
        view.ActiveFirewallRequired = policy.ActiveFirewallRequired == true ? "Require" : string.Empty;
        view.AntiSpywareRequired = policy.AntiSpywareRequired == true ? "Require" : string.Empty;
        view.AntivirusRequired = policy.AntivirusRequired == true ? "Require" : string.Empty;
        view.BitLockerEnabled = policy.BitLockerEnabled == true ? "Require" : string.Empty;
        view.CodeIntegrityEnabled = policy.CodeIntegrityEnabled == true ? "Require" : string.Empty;
        view.ConfigurationManagerComplianceRequired = policy.ConfigurationManagerComplianceRequired == true ? "Require" : string.Empty;
        view.DefenderEnabled = policy.DefenderEnabled == true ? "Require" : string.Empty;
        view.DefenderVersion = policy.DefenderVersion ?? string.Empty;
        view.DeviceCompliancePolicyScript = policy.DeviceCompliancePolicyScript == null ? "Not configured" : "Configured";
        view.DeviceThreatProtectionEnabled = policy.DeviceThreatProtectionEnabled == true ? "Require" : string.Empty;
        view.DeviceThreatProtectionRequiredSecurityLevel = policy.DeviceThreatProtectionRequiredSecurityLevel?.ToString() ?? string.Empty;
        view.EarlyLaunchAntiMalwareDriverEnabled = policy.EarlyLaunchAntiMalwareDriverEnabled == true ? "Require" : string.Empty;
        view.MobileOsMaximumVersion = policy.MobileOsMaximumVersion?.ToString() ?? string.Empty;
        view.MobileOsMinimumVersion = policy.MobileOsMinimumVersion?.ToString() ?? string.Empty;
        view.OsMaximumVersion = policy.OsMaximumVersion?.ToString() ?? string.Empty;
        view.OsMinimumVersion = policy.OsMinimumVersion?.ToString() ?? string.Empty;
        view.PasswordBlockSimple = policy.PasswordBlockSimple == true ? "Blocked" : string.Empty;
        view.PasswordExpirationDays = policy.PasswordExpirationDays?.ToString() ?? string.Empty;
        view.PasswordMinimumCharacterSetCount = policy.PasswordMinimumCharacterSetCount?.ToString() ?? string.Empty;
        view.PasswordMinimumLength = policy.PasswordMinimumLength?.ToString() ?? string.Empty;
        view.PasswordMinutesOfInactivityBeforeLock = policy.PasswordMinutesOfInactivityBeforeLock?.ToString() ?? string.Empty;
        view.PasswordPreviousPasswordBlockCount = policy.PasswordPreviousPasswordBlockCount?.ToString() ?? string.Empty;
        view.PasswordRequired = policy.PasswordRequired == true ? "Require" : string.Empty;
        view.PasswordRequiredToUnlockFromIdle = policy.PasswordRequiredToUnlockFromIdle == true ? "Require" : string.Empty;
        view.PasswordRequiredType = policy.PasswordRequiredType?.ToString() ?? string.Empty;
        view.RequireHealthyDeviceReport = policy.RequireHealthyDeviceReport == true ? "Require" : string.Empty;
        view.RoleScopeTagIds = _graphData.GetScopesString(policy.RoleScopeTagIds);
        view.RtpEnabled = policy.RtpEnabled == true ? "Require" : string.Empty;
        view.SecureBootEnabled = policy.SecureBootEnabled == true ? "Require" : string.Empty;
        view.SignatureOutOfDate = policy.SignatureOutOfDate?.ToString() ?? string.Empty;
        view.StorageRequireEncryption = policy.StorageRequireEncryption == true ? "Require" : string.Empty;
        view.TpmRequired = policy.TpmRequired == true ? "Require" : string.Empty;

        if (policy.ValidOperatingSystemBuildRanges != null)
        {
            foreach (var range in policy.ValidOperatingSystemBuildRanges)
            {
                if (!string.IsNullOrEmpty(view.ValidOperatingSystemBuildRanges)) view.ValidOperatingSystemBuildRanges += ", ";
                view.ValidOperatingSystemBuildRanges += string.Format("({0} - {1})", range.LowestVersion?.ToString() ?? string.Empty, range.HighestVersion?.ToString() ?? string.Empty);
            }
        }
    }
}