namespace ZeroTrustAssessment.DocumentGenerator.ViewModels
{
    public class DeviceCompliancePolicyView
    {
        // Common attributes
        public string? Id { get; set; }
        public string? Platform { get; set; }
        public string? PolicyType { get; set; }
        public string? DisplayName { get; set; }
        public string? DefenderForEndPoint { get; set; }
        public string? OsMaximumVersion { get; set; }
        public string? OsMinimumVersion { get; set; }
        public string? PasswordExpirationDays { get; set; }
        public string? PasswordMinimumLength { get; set; }
        public string? PasswordMinutesOfInactivityBeforeLock { get; set; }
        public string? PasswordPreviousPasswordBlockCount { get; set; }
        public string? PasswordRequired { get; set; }
        public string? PasswordRequiredType { get; set; }
        public string? NoncomplianceActionPushNotification { get; set; }
        public string? NoncomplianceActionNotification { get; set; }
        public string? NoncomplianceActionRemoteLock { get; set; }
        public string? NoncomplianceActionBlock { get; set; }
        public string? NoncomplianceActionRetire { get; set; }
        public string? RoleScopeTagIds { get; set; }
        public string? Scopes { get; set; }
        public string? IncludedGroups { get; set; }
        public string? ExcludedGroups { get; set; }


        //Android attributes
        public string? SecurityBlockJailbrokenDevices { get; set; }

        // iOS attributes

        // macOS attributes
        // Windows attributes
        public string? ActiveFirewallRequired { get; set; }
        public string? AntiSpywareRequired { get; set; }
        public string? AntivirusRequired { get; set; }
        public string? BitLockerEnabled { get; set; }
        public string? CodeIntegrityEnabled { get; set; }
        public string? ConfigurationManagerComplianceRequired { get; set; }
        public string? DefenderVersion { get; set; }
        public string? DeviceCompliancePolicyScript { get; set; }
        public string? DeviceThreatProtectionEnabled { get; set; }
        public string? DeviceThreatProtectionRequiredSecurityLevel { get; set; }
        public string? EarlyLaunchAntiMalwareDriverEnabled { get; set; }
        public string? MobileOsMaximumVersion { get; set; }
        public string? MobileOsMinimumVersion { get; set; }
        public string? PasswordBlockSimple { get; set; }
        public string? PasswordMinimumCharacterSetCount { get; set; }
        public string? PasswordRequiredToUnlockFromIdle { get; set; }
        public string? RequireHealthyDeviceReport { get; set; }
        public string? RtpEnabled { get; set; }
        public string? SecureBootEnabled { get; set; }
        public string? SignatureOutOfDate { get; set; }
        public string? StorageRequireEncryption { get; set; }
        public string? TpmRequired { get; set; }
        public string? ValidOperatingSystemBuildRanges { get; set; }
    }
}