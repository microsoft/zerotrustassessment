using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets;

public class SheetAssessmentDevice : SheetBase
{
    public SheetAssessmentDevice(IWorksheet sheet, GraphData graphData) : base(sheet, graphData)
    {
    }

    public void Generate()
    {
        MdmWindowsEnrollment();
        DeviceEnrollmentConfiguration();
        DeviceComplianceConfiguration();
        AppProtectionConfiguration();
        WindowsHelloForBusiness();
        WindowsUpdate();
    }

    private void MdmWindowsEnrollment()
    {
        var isMdmEnrolled = _graphData.MobilityManagementPolicies?.Any(x => x.IsValid == true && x?.AppliesTo != PolicyScope.None);
        var result = isMdmEnrolled.HasValue && isMdmEnrolled.Value ? AssessmentValue.Completed : AssessmentValue.NotStarted;
        SetValue("CH00001_WindowsEnrollment", result);
    }

    private void DeviceEnrollmentConfiguration()
    {
        var enrollmentConfigs = _graphData.DeviceEnrollmentConfigurations?.Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.SinglePlatformRestriction);
        var android = AssessmentValue.NotStarted;
        var windows = AssessmentValue.NotStarted;
        var ios = AssessmentValue.NotStarted;
        var macos = AssessmentValue.NotStarted;

        //Check if any of the platforms are disabled in the default policy
        var defaultPlatformRestrictions = _graphData.DeviceEnrollmentConfigurations?
            .Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.PlatformRestrictions).FirstOrDefault();
        if (defaultPlatformRestrictions != null && defaultPlatformRestrictions is DeviceEnrollmentPlatformRestrictionsConfiguration defaultRestriction)
        {
            if (defaultRestriction?.AndroidRestriction?.PlatformBlocked == false ||
                defaultRestriction?.AndroidForWorkRestriction?.PlatformBlocked == false) { android = AssessmentValue.Completed; }
            if (defaultRestriction?.IosRestriction?.PlatformBlocked == false) { ios = AssessmentValue.Completed; }
            if (defaultRestriction?.MacRestriction?.PlatformBlocked == false) { macos = AssessmentValue.Completed; }
            if (defaultRestriction?.WindowsRestriction?.PlatformBlocked == false) { windows = AssessmentValue.Completed; }
        }

        if (enrollmentConfigs != null) //Check if a custom policy has been created and mark as completed if one is found.
        {
            foreach (var config in enrollmentConfigs)
            {
                if (config is DeviceEnrollmentPlatformRestrictionConfiguration restriction)
                {
                    switch (restriction.PlatformType)
                    {
                        case EnrollmentRestrictionPlatformType.Android:
                        case EnrollmentRestrictionPlatformType.AndroidForWork:
                            android = AssessmentValue.Completed;
                            break;
                        case EnrollmentRestrictionPlatformType.Windows:
                            windows = AssessmentValue.Completed;
                            break;
                        case EnrollmentRestrictionPlatformType.Ios:
                            ios = AssessmentValue.Completed;
                            break;
                        case EnrollmentRestrictionPlatformType.Mac:
                            macos = AssessmentValue.Completed;
                            break;
                    }
                }
            }
        }

        //TODO: Future enhancement: Check transitive group count and if less than 10 (or maybe 10% of users) then set to In Progress.
        SetValue("CH00002_DeviceEnrollment_Android", android);
        SetValue("CH00003_DeviceEnrollment_Windows", windows);
        SetValue("CH00004_DeviceEnrollment_iOS", ios);
        SetValue("CH00005_DeviceEnrollment_macOS", macos);
    }

    private void DeviceComplianceConfiguration()
    {
        var compliancePolicies = _graphData.DeviceCompliancePolicies ?? new List<DeviceCompliancePolicy>();

        var aospDeviceOwnerCompliancePolicies = new List<AospDeviceOwnerCompliancePolicy>();
        var androidCompliancePolicies = new List<AndroidCompliancePolicy>(); //Device admin
        var androidDeviceOwnerCompliancePolicies = new List<AndroidDeviceOwnerCompliancePolicy>();
        var androidWorkProfileCompliancePolicies = new List<AndroidWorkProfileCompliancePolicy>();
        var iosCompliancePolicies = new List<IosCompliancePolicy>();
        var macOSCompliancePolicies = new List<MacOSCompliancePolicy>();
        var windows81CompliancePolicies = new List<Windows81CompliancePolicy>();
        var windows10CompliancePolicies = new List<Windows10CompliancePolicy>();

        foreach (var policy in compliancePolicies)
        {
            if (policy is Windows10CompliancePolicy windows10CompliancePolicy) { windows10CompliancePolicies.Add(windows10CompliancePolicy); }
            else if (policy is IosCompliancePolicy iosCompliancePolicy) { iosCompliancePolicies.Add(iosCompliancePolicy); }
            else if (policy is MacOSCompliancePolicy macOSCompliancePolicy) { macOSCompliancePolicies.Add(macOSCompliancePolicy); }
            else if (policy is AndroidWorkProfileCompliancePolicy androidWorkProfileCompliancePolicy) { androidWorkProfileCompliancePolicies.Add(androidWorkProfileCompliancePolicy); }
            else if (policy is AndroidCompliancePolicy androidCompliancePolicy) { androidCompliancePolicies.Add(androidCompliancePolicy); }
            else if (policy is AospDeviceOwnerCompliancePolicy aospDeviceOwnerCompliancePolicy) { aospDeviceOwnerCompliancePolicies.Add(aospDeviceOwnerCompliancePolicy); }
            else if (policy is AndroidDeviceOwnerCompliancePolicy androidDeviceOwnerCompliancePolicy) { androidDeviceOwnerCompliancePolicies.Add(androidDeviceOwnerCompliancePolicy); }
            else if (policy is Windows81CompliancePolicy windows81CompliancePolicy) { windows81CompliancePolicies.Add(windows81CompliancePolicy); }
        }

        var aospDeviceOwnerComplianceState = aospDeviceOwnerCompliancePolicies.Count > 0 ? AssessmentValue.Completed : AssessmentValue.NotStarted;
        var androidComplianceState = androidCompliancePolicies.Count > 0 ? AssessmentValue.Completed : AssessmentValue.NotStarted;
        var androidDeviceOwnerComplianceState = androidDeviceOwnerCompliancePolicies.Count > 0 ? AssessmentValue.Completed : AssessmentValue.NotStarted;
        var androidWorkProfileComplianceState = androidWorkProfileCompliancePolicies.Count > 0 ? AssessmentValue.Completed : AssessmentValue.NotStarted;
        var iosComplianceState = iosCompliancePolicies.Count > 0 ? AssessmentValue.Completed : AssessmentValue.NotStarted;
        var macOSComplianceState = macOSCompliancePolicies.Count > 0 ? AssessmentValue.Completed : AssessmentValue.NotStarted;
        var windows10ComplianceState = windows10CompliancePolicies.Count > 0 ? AssessmentValue.Completed : AssessmentValue.NotStarted;

        //TODO: Future enhancement: Check transitive group count and if less than 10 (or maybe 10% of users) then set to In Progress.
        SetValue("CH00006_DeviceCompliance_Android_AOSP", aospDeviceOwnerComplianceState);
        SetValue("CH00007_DeviceCompliance_Android_DeviceAdmin", androidComplianceState);
        SetValue("CH00008_DeviceCompliance_Android_EntCorp", androidDeviceOwnerComplianceState);
        SetValue("CH00009_DeviceCompliance_Android_EntPersonal", androidWorkProfileComplianceState);
        SetValue("CH00010_DeviceCompliance_iOS", iosComplianceState);
        SetValue("CH00011_DeviceCompliance_macOS", macOSComplianceState);
        SetValue("CH00012_DeviceCompliance_Windows", windows10ComplianceState);

        CheckDeviceComplianceIosJailbreak(iosCompliancePolicies);
        CheckDeviceComplianceAndroidRoot(aospDeviceOwnerCompliancePolicies, androidCompliancePolicies, androidWorkProfileCompliancePolicies);

        CheckDeviceComplianceBitLocker(windows10CompliancePolicies);
        CheckDeviceComplianceDefenderEndPoint(compliancePolicies.Count > 0,
            androidCompliancePolicies, androidDeviceOwnerCompliancePolicies, androidWorkProfileCompliancePolicies,
            iosCompliancePolicies, macOSCompliancePolicies, windows10CompliancePolicies);

        CheckDeviceComplianceWindowsFirewall(windows10CompliancePolicies);
        CheckDeviceComplianceMacOSFirewall(macOSCompliancePolicies);
    }

    private void AppProtectionConfiguration()
    {
        var androidPolicies = _graphData.ManagedAppPoliciesAndroid ?? new List<AndroidManagedAppProtection>();
        var iosPolicies = _graphData.ManagedAppPoliciesIos ?? new List<IosManagedAppProtection>();

        var androidAssigned = androidPolicies.Count > 0 ? AssessmentValue.Completed : AssessmentValue.NotStarted;
        var iosAssigned = iosPolicies.Count > 0 ? AssessmentValue.Completed : AssessmentValue.NotStarted;

        SetValue("CH00017_AppProtect_Assigned_iOS", iosAssigned);
        SetValue("CH00018_AppProtect_Assigned_Android", androidAssigned);

        var androidRoot = AssessmentValue.NotStarted;
        if (androidPolicies.Any(x => x.AppActionIfDeviceComplianceRequired != ManagedAppRemediationAction.Warn))
        {
            androidRoot = AssessmentValue.Completed;
        }

        var iosJailbreak = AssessmentValue.NotStarted;
        if (iosPolicies.Any(x => x.AppActionIfDeviceComplianceRequired != ManagedAppRemediationAction.Warn))
        {
            iosJailbreak = AssessmentValue.Completed;
        }

        SetValue("CH00019_AppProtect_Root_Android", androidRoot);
        SetValue("CH00020_AppProtect_Root_iOS", iosJailbreak);



    }

    /// <summary>
    /// Completed = At least one iOS compliance policy + All policies should have SecurityBlockJailbrokenDevices set to true.
    /// </summary>
    /// <param name="iosCompliancePolicies"></param>
    private void CheckDeviceComplianceIosJailbreak(List<IosCompliancePolicy> iosCompliancePolicies)
    {
        var result = AssessmentValue.NotStarted;
        if (iosCompliancePolicies.Count() > 0)
        {
            var isJailbreakEnabledOnAll = true;
            foreach (var policy in iosCompliancePolicies)
            {
                isJailbreakEnabledOnAll = isJailbreakEnabledOnAll && policy.SecurityBlockJailbrokenDevices == true;
            }
            result = isJailbreakEnabledOnAll ? AssessmentValue.Completed : AssessmentValue.InProgress;
        }
        SetValue("CH00013_DeviceCompliance_iOS_Jailbreak", result);
    }

    /// <summary>
    /// Completed = At least one Android compliance policy + All policies should have Root set to blocked.
    /// </summary>
    /// <param name="iosCompliancePolicies"></param>
    private void CheckDeviceComplianceAndroidRoot(
        List<AospDeviceOwnerCompliancePolicy> aospDeviceOwnerCompliancePolicies,
        List<AndroidCompliancePolicy> androidCompliancePolicies,
        List<AndroidWorkProfileCompliancePolicy> androidWorkProfileCompliancePolicies)
    {
        var result = AssessmentValue.NotStarted;
        if (aospDeviceOwnerCompliancePolicies.Count > 0)
        {
            if (aospDeviceOwnerCompliancePolicies.All(x => x.SecurityBlockJailbrokenDevices == true))
            {
                result = AssessmentValue.Completed;
            }
            else if (aospDeviceOwnerCompliancePolicies.Any(x => x.SecurityBlockJailbrokenDevices == true))
            {
                result = AssessmentValue.InProgress;
            }
        }

        if (result != AssessmentValue.InProgress && androidCompliancePolicies.Count > 0)
        {
            if (androidCompliancePolicies.All(x => x.SecurityBlockJailbrokenDevices == true))
            {
                result = AssessmentValue.Completed;
            }
            else if (androidCompliancePolicies.Any(x => x.SecurityBlockJailbrokenDevices == true))
            {
                result = AssessmentValue.InProgress;
            }
        }

        if (result != AssessmentValue.InProgress && androidWorkProfileCompliancePolicies.Count > 0)
        {
            if (androidWorkProfileCompliancePolicies.All(x => x.SecurityBlockJailbrokenDevices == true))
            {
                result = AssessmentValue.Completed;
            }
            else if (androidWorkProfileCompliancePolicies.Any(x => x.SecurityBlockJailbrokenDevices == true))
            {
                result = AssessmentValue.InProgress;
            }
        }

        SetValue("CH00015_DeviceCompliance_AndroidRoot", result);
    }

    /// <summary>
    /// Completed = At least one Windows compliance policy + All policies should have Bi set to true.
    /// </summary>
    /// <param name="iosCompliancePolicies"></param>
    private void CheckDeviceComplianceBitLocker(List<Windows10CompliancePolicy> windows10CompliancePolicies)
    {
        var result = AssessmentValue.NotStarted;
        if (windows10CompliancePolicies.Count > 0)
        {
            var isBitLockerEnabledOnAll = windows10CompliancePolicies.All(x => x.BitLockerEnabled == true);
            var isBitLockerEnabledOnOne = windows10CompliancePolicies.Any(x => x.BitLockerEnabled == true); ;
            if (isBitLockerEnabledOnAll)
            {
                result = AssessmentValue.Completed;
            }
            else if (isBitLockerEnabledOnOne)
            {
                result = AssessmentValue.InProgress;
            }
        }
        SetValue("CH00014_DeviceCompliance_Windows_BitLocker", result);
    }

    /// <summary>
    /// Completed = At least one Windows compliance policy + All policies should have Firewall set to true.
    /// </summary>
    /// <param name="windows10CompliancePolicies"></param>
    private void CheckDeviceComplianceWindowsFirewall(List<Windows10CompliancePolicy> windows10CompliancePolicies)
    {
        var result = AssessmentValue.NotStarted;
        if (windows10CompliancePolicies.Count > 0)
        {
            var isFirewallEnabledOnAll = windows10CompliancePolicies.All(x => x.ActiveFirewallRequired == true);
            var isFirewallEnabledOnOne = windows10CompliancePolicies.Any(x => x.ActiveFirewallRequired == true); ;
            if (isFirewallEnabledOnAll)
            {
                result = AssessmentValue.Completed;
            }
            else if (isFirewallEnabledOnOne)
            {
                result = AssessmentValue.InProgress;
            }
        }
        SetValue("CH00016_DeviceCompliance_Windows_Firewall", result);
    }

    /// <summary>
    /// Completed = At least one Windows compliance policy + All policies should have Firewall set to true.
    /// </summary>
    /// <param name="windows10CompliancePolicies"></param>
    private void CheckDeviceComplianceMacOSFirewall(List<MacOSCompliancePolicy> macOSCompliancePolicies)
    {
        var result = AssessmentValue.NotStarted;
        if (macOSCompliancePolicies.Count > 0)
        {
            var isFirewallEnabledOnAll = macOSCompliancePolicies.All(x => x.FirewallEnabled == true);
            var isFirewallEnabledOnOne = macOSCompliancePolicies.Any(x => x.FirewallEnabled == true); ;
            if (isFirewallEnabledOnAll)
            {
                result = AssessmentValue.Completed;
            }
            else if (isFirewallEnabledOnOne)
            {
                result = AssessmentValue.InProgress;
            }
        }
        SetValue("CH00016_DeviceCompliance_macOS_Firewall", result);
    }

    private void CheckDeviceComplianceDefenderEndPoint(bool hasPolicies,
        List<AndroidCompliancePolicy> androidCompliancePolicies,
        List<AndroidDeviceOwnerCompliancePolicy> androidDeviceOwnerCompliancePolicies,
        List<AndroidWorkProfileCompliancePolicy> androidWorkProfileCompliancePolicies,
        List<IosCompliancePolicy> iosCompliancePolicies,
        List<MacOSCompliancePolicy> macOSCompliancePolicies,
        List<Windows10CompliancePolicy> windows10CompliancePolicies)
    {
        var result = AssessmentValue.NotStarted;
        if (hasPolicies)
        {
            var isDefenderEnabledOnAll = true;
            isDefenderEnabledOnAll = isDefenderEnabledOnAll && windows10CompliancePolicies.All(x => x.DefenderEnabled == true);
            isDefenderEnabledOnAll = isDefenderEnabledOnAll && macOSCompliancePolicies.All(x => IsAtpEnabled(x.AdvancedThreatProtectionRequiredSecurityLevel));
            isDefenderEnabledOnAll = isDefenderEnabledOnAll && iosCompliancePolicies.All(x => IsAtpEnabled(x.AdvancedThreatProtectionRequiredSecurityLevel));
            isDefenderEnabledOnAll = isDefenderEnabledOnAll && androidCompliancePolicies.All(x => IsAtpEnabled(x.AdvancedThreatProtectionRequiredSecurityLevel));
            isDefenderEnabledOnAll = isDefenderEnabledOnAll && androidDeviceOwnerCompliancePolicies.All(x => IsAtpEnabled(x.AdvancedThreatProtectionRequiredSecurityLevel));
            isDefenderEnabledOnAll = isDefenderEnabledOnAll && androidWorkProfileCompliancePolicies.All(x => IsAtpEnabled(x.AdvancedThreatProtectionRequiredSecurityLevel));
            result = isDefenderEnabledOnAll ? AssessmentValue.Completed : AssessmentValue.InProgress;
        }

        SetValue("CH00015_DeviceCompliance_DefenderEndPoint", result);
    }

    private bool IsAtpEnabled(DeviceThreatProtectionLevel? atp)
    {
        return atp != null &&
                atp != DeviceThreatProtectionLevel.Unavailable &&
                atp != DeviceThreatProtectionLevel.NotSet;
    }

    private void WindowsHelloForBusiness()
    {
        var result = AssessmentValue.NotStarted;
        var whfbConfig = _graphData.DeviceEnrollmentConfigurations?.Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.WindowsHelloForBusiness).FirstOrDefault();

        if (whfbConfig != null)
        {
            if (whfbConfig is DeviceEnrollmentWindowsHelloForBusinessConfiguration config)
            {
                if (config.State == Enablement.Enabled)
                {
                    result = AssessmentValue.Completed;
                }
            }
        }
        SetValue("CH00021_AppProtect_WHfB", result);
    }

    private void WindowsUpdate()
    {
        var result = AssessmentValue.NotStarted;
        WindowsUpdateForBusinessConfiguration? windowsUpdate;
        var configs = _graphData.DeviceConfigurations;

        if (configs != null)
        {
            foreach (var config in configs)
            {
                if (config is WindowsUpdateForBusinessConfiguration windowsUpdateConfig)
                {
                    windowsUpdate = config as WindowsUpdateForBusinessConfiguration;
                    if (windowsUpdate != null)
                    {
                        result = AssessmentValue.Completed;
                        break;
                    }
                }
            }
            SetValue("CH00022_AppProtect_WindowsUpdate", result);
        }
    }
}