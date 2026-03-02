// Use quicktype (Paste JSON as Code) VSCode extension to generate this typescript interface from ZeroTrustAssessmentReport.json created by PowerShell

export interface ZeroTrustAssessmentReport {
  ExecutedAt: string;
  TenantId: string;
  TenantName: string;
  Domain: string;
  Account: string;
  CurrentVersion: string;
  LatestVersion: string;
  IsDemo?: boolean;
  Tests: Test[];
  TenantInfo: TenantInfo | null;
  TestResultSummary: TestResultSummaryData;
  EndOfJson: string;
}

export interface TenantInfo {
  OverviewCaMfaAllUsers?: SankeyData | null;
  OverviewCaDevicesAllUsers?: SankeyData | null;
  OverviewAuthMethodsPrivilegedUsers?: SankeyData | null;
  OverviewAuthMethodsAllUsers?: SankeyData | null;
  ConfigWindowsEnrollment?: ConfigWindowsEnrollment[] | null;
  ConfigDeviceEnrollmentRestriction?: ConfigDeviceEnrollmentRestriction[] | null;
  ConfigDeviceCompliancePolicies?: ConfigDeviceCompliancePolicies[] | null;
  ConfigDeviceAppProtectionPolicies?: ConfigDeviceAppProtectionPolicies[] | null;
  DeviceOverview?: DeviceOverview | null;
  TenantOverview?: TenantOverview | null;
}

export interface ConfigWindowsEnrollment {
  Type: string | null;
  PolicyName: string | null;
  AppliesTo: string | null;
  Groups: string | null;
}

export interface ConfigDeviceEnrollmentRestriction {
  Platform: string | null;
  Priority: string | number | null;
  Name: string | null;
  MDM: string | null;
  MinVer: string | null;
  MaxVer: string | null;
  PersonallyOwned: string | null;
  BlockedManufacturers: string | null;
  Scope: string | null;
  AssignedTo: string | null;
}

export interface ConfigDeviceCompliancePolicies {
  Platform: string | null;
  PolicyName: string | null;
  DefenderForEndPoint: string | null;
  MinOsVersion: string | null;
  MaxOsVersion: string | null;
  RequirePswd: boolean | string | null;
  MinPswdLength: number | string | null;
  PasswordType: string | null;
  PswdExpiryDays: number | string | null;
  CountOfPreviousPswdToBlock: number | string | null;
  MaxInactivityMin: number | string | null;
  RequireEncryption: string | null;
  RootedJailbrokenDevices: string | null;
  MaxDeviceThreatLevel: string | null;
  RequireFirewall: string | null;
  ActionForNoncomplianceDaysPushNotification: number | string | null;
  ActionForNoncomplianceDaysSendEmail: number | string | null;
  ActionForNoncomplianceDaysRemoteLock: number | string | null;
  ActionForNoncomplianceDaysBlock: number | string | null;
  ActionForNoncomplianceDaysRetire: number | string | null;
  Scope: string | null;
  IncludedGroups: string | null;
  ExcludedGroups: string | null;
}

export interface ConfigDeviceAppProtectionPolicies {
  Platform: string | null;
  Name: string | string[] | null;
  AppsPublic: string | null;
  AppsCustom: string | null;
  BackupOrgDataToICloudOrGoogle: string | null;
  SendOrgDataToOtherApps: string | null;
  AppsToExempt: string | null;
  SaveCopiesOfOrgData: string | null;
  AllowUserToSaveCopiesToSelectedServices: string | null;
  DataProtectionTransferTelecommunicationDataTo: string | null;
  DataProtectionReceiveDataFromOtherApps: string | null;
  DataProtectionOpenDataIntoOrgDocuments: string | null;
  DataProtectionAllowUsersToOpenDataFromSelectedServices: string | null;
  DataProtectionRestrictCutCopyBetweenOtherApps: string | null;
  DataProtectionCutCopyCharacterLimitForAnyApp: string | null;
  DataProtectionEncryptOrgData: string | null;
  DataProtectionSyncPolicyManagedAppDataWithNativeApps: string | null;
  DataProtectionPrintingOrgData: string | null;
  DataProtectionRestrictWebContentTransferWithOtherApps: string | null;
  DataProtectionOrgDataNotifications: string | null;
  ConditionalLaunchAppMaxPinAttempts: string | null;
  ConditionalLaunchAppOfflineGracePeriodBlockAccess: string | null;
  ConditionalLaunchAppOfflineGracePeriodWipeData: string | null;
  ConditionalLaunchAppDisabedAccount: string | null;
  ConditionalLaunchAppMinAppVersion: string | null;
  ConditionalLaunchDeviceRootedJailbrokenDevices: string | null;
  ConditionalLaunchDevicePrimaryMtdService: string | null;
  ConditionalLaunchDeviceMaxAllowedDeviceThreatLevel: string | null;
  ConditionalLaunchDeviceMinOsVersion: string | null;
  ConditionalLaunchDeviceMaxOsVersion: string | null;
  Scope: string | null;
  IncludedGroups: string | null;
  ExcludedGroups: string | null;
}

export interface TestResultSummaryData {
  IdentityPassed: number;
  IdentityTotal: number;
  DevicesPassed: number;
  DevicesTotal: number;
  DataPassed?: number;
  DataTotal?: number;
  NetworkPassed?: number;
  NetworkTotal?: number;
}
export interface SankeyData {
  nodes: SankeyDataNode[];
  description: string;
  totalDevices?: number;
  entrareigstered?: number;
  entrahybridjoined?: number;
  entrajoined?: number;
}
export interface SankeyDataNode {
  value: number | null;
  source: string;
  target: string;
}

export interface TenantOverview {
  UserCount: number;
  GuestCount: number;
  GroupCount: number;
  ApplicationCount: number;
  DeviceCount: number;
  ManagedDeviceCount: number;
}
export interface DeviceOverview {
  DesktopDevicesSummary: SankeyData | null;
  MobileSummary: SankeyData | null;
  ManagedDevices: ManagedDevices | null;
  DeviceCompliance: DeviceCompliance | null;
  DeviceOwnership: DeviceOwnership | null;
}

export interface DeviceOwnership {
  corporateCount: number | null;
  personalCount: number | null;
}

export interface ManagedDevices {
  "@odata.context": string;
  id: string;
  totalCount: number | null;
  desktopCount: number;
  mobileCount: number;
  enrolledDeviceCount: number;
  mdmEnrolledCount: number;
  dualEnrolledDeviceCount: number;
  managedDeviceModelsAndManufacturers: object | null;
  lastModifiedDateTime: string;
  deviceOperatingSystemSummary: DeviceOperatingSystemSummary;
  deviceExchangeAccessStateSummary: DeviceExchangeAccessStateSummary;
}

export interface DeviceOperatingSystemSummary {
  androidCount: number;
  iosCount: number;
  macOSCount: number;
  windowsMobileCount: number;
  windowsCount: number;
  unknownCount: number;
  androidDedicatedCount: number;
  androidDeviceAdminCount: number;
  androidFullyManagedCount: number;
  androidWorkProfileCount: number;
  androidCorporateWorkProfileCount: number;
  configMgrDeviceCount: number;
  aospUserlessCount: number;
  aospUserAssociatedCount: number;
  linuxCount: number;
  chromeOSCount: number;
}

export interface DeviceExchangeAccessStateSummary {
  allowedDeviceCount: number;
  blockedDeviceCount: number;
  quarantinedDeviceCount: number;
  unknownDeviceCount: number;
  unavailableDeviceCount: number;
}

export interface DeviceCompliance {
  "@odata.context": string;
  inGracePeriodCount: number;
  configManagerCount: number;
  id: string;
  unknownDeviceCount: number;
  notApplicableDeviceCount: number;
  compliantDeviceCount: number;
  remediatedDeviceCount: number;
  nonCompliantDeviceCount: number;
  errorDeviceCount: number;
  conflictDeviceCount: number;
}

export interface Test {
  TestTitle: string;
  TestRisk: string;
  TestAppliesTo: string[] | null;
  TestImpact: string;
  TestCategory: string | null;
  TestImplementationCost: string;
  TestMinimumLicense?: string[] | null;
  TestSfiPillar: string | null;
  TestPillar: string | null;
  SkippedReason: string | null;
  TestResult: string;
  TestSkipped: string;
  TestStatus: string;
  TestTags: string[] | null;
  TestId: string;
  TestDescription: string;
  TestRegulatory?: string[] | null;
  TestZtPrinciple?: string | null;
}

export const reportData: ZeroTrustAssessmentReport = {
  "ExecutedAt": "2025-10-21T08:07:56.502298+11:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora Inc.",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "0.18.0",
  "LatestVersion": "0.18.0",
  "TestResultSummary": {
    "IdentityPassed": 5,
    "IdentityTotal": 15,
    "DevicesPassed": 4,
    "DevicesTotal": 14,
    "DataPassed": 3,
    "DataTotal": 10,
    "NetworkPassed": 2,
    "NetworkTotal": 10
  },
  "Tests": [
    {
      "TestId": "24546",
      "TestResult": "\nWindows Automatic Enrollment is enabled.\n\n\n## Windows Automatic Enrollment\n\n| Policy Name | User Scope |\n| :---------- | :--------- |\n| [Microsoft Intune](https://intune.microsoft.com/#view/Microsoft_AAD_IAM/MdmConfiguration.ReactView/appId/0000000a-0000-0000-c000-000000000000/appName/Microsoft%20Intune) | ✅ Specific Groups |\n\n\n\n",
      "TestDescription": "If Windows automatic enrollment isn't enabled, unmanaged devices can become an entry point for attackers.\n\n**Remediation action**\n\nEnable automatic enrollment for Windows devices using Intune and Microsoft Entra.",
      "TestSkipped": "",
      "TestTitle": "Windows automatic device enrollment is enforced to eliminate risks from unmanaged endpoints",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Enrollment",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CIS"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "10001",
      "TestResult": "MFA is not enforced for all users. 34% of users authenticate without MFA.\n\n| Policy | Coverage |\n| :-- | :-- |\n| CA-001 MFA All Users | 66% of users |",
      "TestDescription": "Multi-factor authentication should be required for all users to prevent credential-based attacks.",
      "TestSkipped": "",
      "TestTitle": "Multi-factor authentication is enforced for all users",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Identity",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Authentication",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": ["All Users"],
      "TestRegulatory": ["NIST", "CISA", "CIS"],
      "TestZtPrinciple": "Verify explicitly"
    },
    {
      "TestId": "10002",
      "TestResult": "Legacy authentication protocols are not fully blocked. 12 users still use basic auth.\n\n| Protocol | Users |\n| :-- | :-- |\n| SMTP AUTH | 8 |\n| POP3 | 4 |",
      "TestDescription": "Legacy authentication protocols bypass MFA and should be blocked to prevent credential spray attacks.",
      "TestSkipped": "",
      "TestTitle": "Legacy authentication protocols are blocked across the tenant",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Identity",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Authentication",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["All Users"],
      "TestRegulatory": ["NIST", "CISA"],
      "TestZtPrinciple": "Verify explicitly"
    },
    {
      "TestId": "10003",
      "TestResult": "Privileged Identity Management is configured.\n\n| Role | Eligible | Active |\n| :-- | :-- | :-- |\n| Global Admin | 3 | 1 |\n| Security Admin | 5 | 2 |",
      "TestDescription": "Privileged roles should use just-in-time activation through PIM to minimize standing access.",
      "TestSkipped": "",
      "TestTitle": "Privileged Identity Management is enabled for all admin roles",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Identity",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Privileged Access",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": ["Admins"],
      "TestRegulatory": ["NIST", "CIS", "ISO"],
      "TestZtPrinciple": "Use least privilege access"
    },
    {
      "TestId": "10004",
      "TestResult": "7 permanent Global Administrator assignments found.\n\n| User | Assignment Type |\n| :-- | :-- |\n| admin@elapora.com | Permanent |\n| john@elapora.com | Permanent |",
      "TestDescription": "Permanent Global Administrator assignments create excessive standing privileges and increase risk of compromise.",
      "TestSkipped": "",
      "TestTitle": "No permanent Global Administrator assignments exist outside break-glass accounts",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Identity",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Privileged Access",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["Admins"],
      "TestRegulatory": ["NIST", "CISA", "CIS", "ISO"],
      "TestZtPrinciple": "Use least privilege access"
    },
    {
      "TestId": "10005",
      "TestResult": "Sign-in risk policy is not configured for all users.\n\n| Policy | Status |\n| :-- | :-- |\n| Sign-in risk | Not configured |",
      "TestDescription": "Sign-in risk-based conditional access policies detect anomalous sign-in behavior and challenge or block risky sign-ins.",
      "TestSkipped": "",
      "TestTitle": "Sign-in risk-based conditional access policy is configured for all users",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Identity",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Conditional Access",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": ["All Users"],
      "TestRegulatory": ["NIST", "CISA"],
      "TestZtPrinciple": "Assume breach"
    },
    {
      "TestId": "10006",
      "TestResult": "User risk policy is configured.\n\n| Policy | Scope | Action |\n| :-- | :-- | :-- |\n| User risk | All Users | Require password change |",
      "TestDescription": "User risk-based policies detect compromised accounts and require password changes or block access.",
      "TestSkipped": "",
      "TestTitle": "User risk-based conditional access policy is configured for all users",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Identity",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Conditional Access",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": ["All Users"],
      "TestRegulatory": ["NIST", "CIS"],
      "TestZtPrinciple": "Assume breach"
    },
    {
      "TestId": "10007",
      "TestResult": "Self-service password reset is enabled for all users with MFA registration required.",
      "TestDescription": "SSPR reduces helpdesk load and ensures users can securely reset passwords with strong authentication.",
      "TestSkipped": "",
      "TestTitle": "Self-service password reset is enabled with strong authentication methods",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Identity",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Authentication",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["All Users"],
      "TestRegulatory": ["CIS"],
      "TestZtPrinciple": "Verify explicitly"
    },
    {
      "TestId": "10008",
      "TestResult": "Password protection is not configured. No custom banned password list is defined.",
      "TestDescription": "Custom banned password lists prevent users from choosing easily guessable passwords specific to the organization.",
      "TestSkipped": "",
      "TestTitle": "Custom banned password list is configured in Microsoft Entra password protection",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Identity",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Authentication",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["All Users"],
      "TestRegulatory": ["NIST", "CIS"],
      "TestZtPrinciple": "Verify explicitly"
    },
    {
      "TestId": "10009",
      "TestResult": "Guest access review is not configured. 12 guest accounts have not been reviewed in 180+ days.",
      "TestDescription": "Guest accounts should be regularly reviewed and recertified to ensure external users still require access.",
      "TestSkipped": "",
      "TestTitle": "Access reviews are configured for guest user accounts",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Identity",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Guest Access",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["Guests"],
      "TestRegulatory": ["ISO", "CIS"],
      "TestZtPrinciple": "Use least privilege access"
    },
    {
      "TestId": "10010",
      "TestResult": "Emergency access accounts are configured correctly with monitoring alerts.\n\n| Account | MFA Excluded | Monitored |\n| :-- | :-- | :-- |\n| breakglass1@ | Yes | Yes |\n| breakglass2@ | Yes | Yes |",
      "TestDescription": "Break-glass accounts provide emergency access and must be properly secured and monitored.",
      "TestSkipped": "",
      "TestTitle": "Emergency access (break-glass) accounts are properly configured and monitored",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Identity",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Privileged Access",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["Admins"],
      "TestRegulatory": ["NIST", "CISA", "CIS"],
      "TestZtPrinciple": "Assume breach"
    },
    {
      "TestId": "10011",
      "TestResult": "Conditional access policies do not require compliant or hybrid-joined devices for admin portals.",
      "TestDescription": "Admin portal access should require managed devices to prevent administrative actions from uncontrolled endpoints.",
      "TestSkipped": "",
      "TestTitle": "Conditional access requires compliant devices for admin portal access",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Identity",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Conditional Access",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": ["Admins"],
      "TestRegulatory": ["NIST", "CISA"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "10012",
      "TestResult": "Named locations are configured but several high-risk countries are not blocked.\n\n| Location | Status |\n| :-- | :-- |\n| Trusted Office IPs | Configured |\n| High-risk countries | Not blocked |",
      "TestDescription": "Named locations should be used to block or challenge sign-ins from high-risk geographic regions.",
      "TestSkipped": "",
      "TestTitle": "Named locations are configured to restrict sign-ins from high-risk countries",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Identity",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Conditional Access",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["All Users"],
      "TestRegulatory": ["NIST"],
      "TestZtPrinciple": "Verify explicitly"
    },
    {
      "TestId": "10013",
      "TestResult": "Token protection is not enforced. Sign-in tokens can be replayed from any device.",
      "TestDescription": "Token protection binds tokens to specific devices, preventing token theft and replay attacks.",
      "TestSkipped": "",
      "TestTitle": "Token protection is enforced for sensitive applications via conditional access",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Identity",
      "TestImpact": "High",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Conditional Access",
      "TestImplementationCost": "High",
      "SkippedReason": null,
      "TestAppliesTo": ["All Users"],
      "TestRegulatory": ["NIST", "CISA"],
      "TestZtPrinciple": "Assume breach"
    },
    {
      "TestId": "10014",
      "TestResult": "Phishing-resistant MFA methods are available but not enforced for admin roles.\n\n| Method | Admins Using |\n| :-- | :-- |\n| FIDO2 | 2 of 10 |\n| Windows Hello | 3 of 10 |",
      "TestDescription": "Phishing-resistant MFA such as FIDO2 keys or Windows Hello should be required for privileged roles.",
      "TestSkipped": "",
      "TestTitle": "Phishing-resistant MFA is required for all privileged roles",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Identity",
      "TestImpact": "High",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Authentication",
      "TestImplementationCost": "High",
      "SkippedReason": null,
      "TestAppliesTo": ["Admins"],
      "TestRegulatory": ["NIST", "CISA", "ISO"],
      "TestZtPrinciple": "Verify explicitly"
    },
    {
      "TestId": "10015",
      "TestResult": "Continuous access evaluation is enabled for supported applications.",
      "TestDescription": "CAE enables real-time revocation of access when user conditions change (e.g., location change, account disable).",
      "TestSkipped": "",
      "TestTitle": "Continuous access evaluation is enabled for critical applications",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Identity",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect identities and secrets",
      "TestCategory": "Conditional Access",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["All Users"],
      "TestRegulatory": ["NIST"],
      "TestZtPrinciple": "Verify explicitly"
    },
    {
      "TestId": "20001",
      "TestResult": "Device compliance policies are configured but not all platforms are covered.\n\n| Platform | Policy |\n| :-- | :-- |\n| Windows | Configured |\n| iOS | Configured |\n| Android | Missing |\n| macOS | Missing |",
      "TestDescription": "All device platforms accessing corporate resources must have compliance policies to enforce security baselines.",
      "TestSkipped": "",
      "TestTitle": "Device compliance policies are configured for all managed platforms",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Compliance",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": ["All Devices"],
      "TestRegulatory": ["NIST", "CIS", "ISO"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20002",
      "TestResult": "BitLocker encryption is required on Windows devices.\n\n| Setting | Value |\n| :-- | :-- |\n| Require Encryption | Yes |",
      "TestDescription": "Device encryption protects data at rest and prevents unauthorized access to data on lost or stolen devices.",
      "TestSkipped": "",
      "TestTitle": "BitLocker encryption is required on all Windows managed devices",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Encryption",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["Windows"],
      "TestRegulatory": ["NIST", "CISA", "CIS"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20003",
      "TestResult": "Conditional access does not require compliant devices for all users.\n\n| Policy | Scope | Requirement |\n| :-- | :-- | :-- |\n| Require compliant device | Admins only | Compliant |",
      "TestDescription": "Conditional access should require device compliance for all users to prevent access from unmanaged or non-compliant endpoints.",
      "TestSkipped": "",
      "TestTitle": "Conditional access requires compliant or Entra-joined device for all users",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "High",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Conditional Access",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": ["All Users"],
      "TestRegulatory": ["NIST", "CISA", "CIS"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20004",
      "TestResult": "App protection policies are configured for iOS and Android.\n\n| Platform | Policy |\n| :-- | :-- |\n| iOS | iOS Policy |\n| Android | Android Policy |",
      "TestDescription": "App protection policies enforce data loss prevention controls on mobile apps to protect corporate data.",
      "TestSkipped": "",
      "TestTitle": "App protection policies are configured for iOS and Android managed apps",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "App Protection",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": ["Mobile"],
      "TestRegulatory": ["NIST", "CIS"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20005",
      "TestResult": "Windows Defender Antivirus is not required in compliance policies.\n\n| Policy | Defender Requirement |\n| :-- | :-- |\n| Min Windows Compliance | Not configured |",
      "TestDescription": "Compliance policies should require active antimalware protection to detect and prevent threats.",
      "TestSkipped": "",
      "TestTitle": "Windows Defender Antivirus is required in device compliance policies",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Compliance",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["Windows"],
      "TestRegulatory": ["NIST", "CISA", "CIS"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20006",
      "TestResult": "Microsoft Defender for Endpoint integration is not enabled in Intune.\n\n| Setting | Value |\n| :-- | :-- |\n| MDE Integration | Not connected |",
      "TestDescription": "Defender for Endpoint integration with Intune provides device risk scores for compliance evaluation.",
      "TestSkipped": "",
      "TestTitle": "Microsoft Defender for Endpoint is integrated with Microsoft Intune",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "Low",
      "TestSfiPillar": "Monitor and detect threats",
      "TestCategory": "Threat Protection",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": ["All Devices"],
      "TestRegulatory": ["NIST", "CISA"],
      "TestZtPrinciple": "Assume breach"
    },
    {
      "TestId": "20007",
      "TestResult": "Jailbreak detection is enabled for iOS devices. Rooted Android detection is enabled.",
      "TestDescription": "Jailbroken or rooted devices bypass security controls and should be blocked from accessing corporate data.",
      "TestSkipped": "",
      "TestTitle": "Jailbreak and root detection is enabled in compliance policies for all mobile platforms",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Devices",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Compliance",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["Mobile"],
      "TestRegulatory": ["CIS"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20008",
      "TestResult": "Personal device enrollment restrictions allow personal devices on all platforms.",
      "TestDescription": "Personal device enrollment should be restricted or scoped to prevent uncontrolled BYOD access.",
      "TestSkipped": "",
      "TestTitle": "Personal device enrollment is restricted to approved platforms only",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Devices",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Enrollment",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["All Devices"],
      "TestRegulatory": ["ISO", "CIS"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20009",
      "TestResult": "Windows Update for Business is not configured. Devices may have outdated OS versions.",
      "TestDescription": "OS update policies ensure devices receive critical security patches in a timely manner.",
      "TestSkipped": "",
      "TestTitle": "Windows Update for Business policies enforce timely security updates",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Updates",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": ["Windows"],
      "TestRegulatory": ["NIST", "CISA", "CIS"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20010",
      "TestResult": "Firewall is not required by all Windows compliance policies.\n\n| Policy | Firewall Required |\n| :-- | :-- |\n| Min Windows Compliance | Not configured |\n| My Windows policy | Yes |",
      "TestDescription": "Windows Firewall should be required in compliance policies to protect against network-based attacks.",
      "TestSkipped": "",
      "TestTitle": "Windows Firewall is required in all Windows compliance policies",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Devices",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Compliance",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["Windows"],
      "TestRegulatory": ["CIS", "NIST"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20011",
      "TestResult": "Non-compliance actions are not configured for some policies. Devices remain non-compliant indefinitely without action.",
      "TestDescription": "Non-compliance actions should include escalating responses (notify, block, retire) to enforce remediation.",
      "TestSkipped": "",
      "TestTitle": "Non-compliance actions are configured with escalating responses for all policies",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Devices",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Compliance",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["All Devices"],
      "TestRegulatory": ["ISO"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20012",
      "TestResult": "macOS FileVault encryption is required.\n\n| Setting | Value |\n| :-- | :-- |\n| Require Encryption | Yes |",
      "TestDescription": "FileVault encryption must be enabled on macOS devices to protect data at rest.",
      "TestSkipped": "",
      "TestTitle": "FileVault encryption is required on all managed macOS devices",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Encryption",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["macOS"],
      "TestRegulatory": ["NIST", "CIS"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "20013",
      "TestResult": "Minimum OS version is not enforced consistently.\n\n| Platform | Min Version Required |\n| :-- | :-- |\n| iOS | 4 |\n| Windows 10 | Not set |\n| macOS | 1 |",
      "TestDescription": "Minimum OS version requirements ensure devices are running supported and patched operating systems.",
      "TestSkipped": "",
      "TestTitle": "Minimum OS version requirements are enforced across all device platforms",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Compliance",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": ["All Devices"],
      "TestRegulatory": ["NIST", "CIS", "ISO"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "30001",
      "TestResult": "No network segmentation policies are configured for cloud workloads.",
      "TestDescription": "Network micro-segmentation limits lateral movement by isolating workloads and enforcing traffic rules.",
      "TestSkipped": "",
      "TestTitle": "Network micro-segmentation is implemented for cloud workloads",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Network",
      "TestImpact": "High",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Segmentation",
      "TestImplementationCost": "High",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CISA", "ISO"],
      "TestZtPrinciple": "Verify and secure every network"
    },
    {
      "TestId": "30002",
      "TestResult": "TLS 1.2 is enforced. TLS 1.0 and 1.1 are disabled.\n\n| Protocol | Status |\n| :-- | :-- |\n| TLS 1.2 | Enabled |\n| TLS 1.0 | Disabled |\n| TLS 1.1 | Disabled |",
      "TestDescription": "Deprecated TLS versions contain known vulnerabilities and should be disabled to enforce encrypted communications.",
      "TestSkipped": "",
      "TestTitle": "TLS 1.2 or higher is enforced for all network communications",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Network",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Encryption",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CIS", "ISO"],
      "TestZtPrinciple": "Verify and secure every network"
    },
    {
      "TestId": "30003",
      "TestResult": "DNS filtering is not configured. Users can access any domain without restriction.",
      "TestDescription": "DNS filtering blocks access to known malicious domains and prevents command-and-control communications.",
      "TestSkipped": "",
      "TestTitle": "DNS filtering is enabled to block access to known malicious domains",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Network",
      "TestImpact": "Low",
      "TestSfiPillar": "Monitor and detect threats",
      "TestCategory": "DNS Security",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["CISA", "CIS"],
      "TestZtPrinciple": "Verify and secure every network"
    },
    {
      "TestId": "30004",
      "TestResult": "VPN split tunneling is enabled but security-critical traffic is not forced through the tunnel.",
      "TestDescription": "Split tunnel VPN configurations should force security-critical traffic through the corporate network.",
      "TestSkipped": "",
      "TestTitle": "VPN split tunneling is configured to route security-critical traffic through the corporate network",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Network",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "VPN",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST"],
      "TestZtPrinciple": "Verify and secure every network"
    },
    {
      "TestId": "30005",
      "TestResult": "Private endpoints are not configured for Azure PaaS services.\n\n| Service | Private Endpoint |\n| :-- | :-- |\n| Azure SQL | Not configured |\n| Storage | Not configured |",
      "TestDescription": "Private endpoints remove public internet exposure of PaaS services by routing traffic through the Azure backbone.",
      "TestSkipped": "",
      "TestTitle": "Private endpoints are configured for all Azure PaaS services",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Network",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Private Access",
      "TestImplementationCost": "High",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CISA", "ISO"],
      "TestZtPrinciple": "Verify and secure every network"
    },
    {
      "TestId": "30006",
      "TestResult": "Network security groups are configured but lack deny-all default rules on some subnets.",
      "TestDescription": "NSGs should have explicit deny-all default rules with specific allow rules to enforce least-privilege network access.",
      "TestSkipped": "",
      "TestTitle": "Network security groups enforce deny-all default rules with explicit allow lists",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Network",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Firewall",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CIS"],
      "TestZtPrinciple": "Verify and secure every network"
    },
    {
      "TestId": "30007",
      "TestResult": "DDoS protection is enabled on the virtual network.\n\n| Resource | DDoS Plan |\n| :-- | :-- |\n| vnet-prod | Standard |",
      "TestDescription": "Azure DDoS Protection Standard provides advanced mitigation for volumetric and protocol attacks.",
      "TestSkipped": "",
      "TestTitle": "Azure DDoS Protection Standard is enabled for production virtual networks",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Network",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "DDoS Protection",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "ISO"],
      "TestZtPrinciple": "Verify and secure every network"
    },
    {
      "TestId": "30008",
      "TestResult": "Web Application Firewall is not enabled on Application Gateway.\n\n| Resource | WAF Status |\n| :-- | :-- |\n| appgw-prod | Not configured |",
      "TestDescription": "WAF protects web applications from common exploits like SQL injection, XSS, and other OWASP top 10 threats.",
      "TestSkipped": "",
      "TestTitle": "Web Application Firewall is enabled on all internet-facing application gateways",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Network",
      "TestImpact": "Low",
      "TestSfiPillar": "Monitor and detect threats",
      "TestCategory": "Firewall",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CISA", "CIS"],
      "TestZtPrinciple": "Verify and secure every network"
    },
    {
      "TestId": "30009",
      "TestResult": "Network flow logs are not enabled for all NSGs.",
      "TestDescription": "Network flow logs provide visibility into network traffic patterns and are essential for threat detection and forensics.",
      "TestSkipped": "",
      "TestTitle": "Network flow logs are enabled for all network security groups",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Network",
      "TestImpact": "Low",
      "TestSfiPillar": "Monitor and detect threats",
      "TestCategory": "Monitoring",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CIS"],
      "TestZtPrinciple": "Assume breach"
    },
    {
      "TestId": "30010",
      "TestResult": "Azure Firewall is not deployed for centralized network traffic control.",
      "TestDescription": "Azure Firewall provides centralized network traffic filtering with built-in high availability and threat intelligence.",
      "TestSkipped": "",
      "TestTitle": "Azure Firewall or equivalent NVA is deployed for centralized network traffic control",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Network",
      "TestImpact": "High",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Firewall",
      "TestImplementationCost": "High",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CISA", "CIS", "ISO"],
      "TestZtPrinciple": "Verify and secure every network"
    },
    {
      "TestId": "40001",
      "TestResult": "DLP policies are not configured for Exchange Online or SharePoint.\n\n| Service | DLP Policy |\n| :-- | :-- |\n| Exchange Online | Not configured |\n| SharePoint | Not configured |",
      "TestDescription": "Data loss prevention policies detect and prevent sensitive data from being shared or leaked outside the organization.",
      "TestSkipped": "",
      "TestTitle": "Data loss prevention policies are configured for Exchange Online and SharePoint",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Data",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Data Loss Prevention",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CISA", "ISO"],
      "TestZtPrinciple": "Use least privilege access"
    },
    {
      "TestId": "40002",
      "TestResult": "Sensitivity labels are published but not applied by default to new documents.",
      "TestDescription": "Sensitivity labels classify and protect data based on its sensitivity level. Default labels ensure all content is classified.",
      "TestSkipped": "",
      "TestTitle": "Sensitivity labels are configured with a default label for all new documents and emails",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Data",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Information Protection",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "ISO"],
      "TestZtPrinciple": "Use least privilege access"
    },
    {
      "TestId": "40003",
      "TestResult": "SharePoint external sharing is set to 'Anyone' for some sites.\n\n| Site | Sharing Level |\n| :-- | :-- |\n| Marketing | Anyone |\n| Finance | Org only |",
      "TestDescription": "External sharing should be restricted to prevent unauthorized data access by external parties.",
      "TestSkipped": "",
      "TestTitle": "SharePoint external sharing is restricted to authenticated guests only",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Data",
      "TestImpact": "Medium",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Sharing",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CIS", "ISO"],
      "TestZtPrinciple": "Use least privilege access"
    },
    {
      "TestId": "40004",
      "TestResult": "Audit logging is enabled for all Microsoft 365 workloads.\n\n| Workload | Audit Status |\n| :-- | :-- |\n| Exchange | Enabled |\n| SharePoint | Enabled |\n| Teams | Enabled |",
      "TestDescription": "Unified audit logging provides visibility into user and admin activities for security investigation and compliance.",
      "TestSkipped": "",
      "TestTitle": "Unified audit logging is enabled for all Microsoft 365 workloads",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Data",
      "TestImpact": "Low",
      "TestSfiPillar": "Monitor and detect threats",
      "TestCategory": "Auditing",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CISA", "CIS", "ISO"],
      "TestZtPrinciple": "Assume breach"
    },
    {
      "TestId": "40005",
      "TestResult": "Customer-managed keys are not configured for data encryption at rest.\n\n| Service | Encryption |\n| :-- | :-- |\n| Exchange | Microsoft-managed |\n| SharePoint | Microsoft-managed |",
      "TestDescription": "Customer-managed encryption keys provide additional control over data encryption and meet regulatory requirements.",
      "TestSkipped": "",
      "TestTitle": "Customer-managed encryption keys are configured for sensitive workloads",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Data",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Encryption",
      "TestImplementationCost": "High",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "ISO"],
      "TestZtPrinciple": "Use least privilege access"
    },
    {
      "TestId": "40006",
      "TestResult": "Retention policies are configured for Exchange but missing for Teams and SharePoint.",
      "TestDescription": "Data retention policies ensure data is retained for compliance and deleted when no longer needed.",
      "TestSkipped": "",
      "TestTitle": "Data retention policies are configured for all Microsoft 365 workloads",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Data",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Retention",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "ISO"],
      "TestZtPrinciple": "Use least privilege access"
    },
    {
      "TestId": "40007",
      "TestResult": "Auto-labeling policies are configured for credit card and SSN patterns.\n\n| Pattern | Action |\n| :-- | :-- |\n| Credit Card | Apply Confidential label |\n| SSN | Apply Highly Confidential label |",
      "TestDescription": "Auto-labeling automatically classifies and protects sensitive data based on content patterns without user intervention.",
      "TestSkipped": "",
      "TestTitle": "Auto-labeling policies are configured for common sensitive information types",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "Medium",
      "TestPillar": "Data",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Information Protection",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CIS"],
      "TestZtPrinciple": "Use least privilege access"
    },
    {
      "TestId": "40008",
      "TestResult": "Conditional access does not block downloads from unmanaged devices.",
      "TestDescription": "Unmanaged devices should be prevented from downloading sensitive data to protect against data exfiltration.",
      "TestSkipped": "",
      "TestTitle": "Conditional access restricts data downloads from unmanaged devices",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Data",
      "TestImpact": "High",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Data Loss Prevention",
      "TestImplementationCost": "Medium",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CISA"],
      "TestZtPrinciple": "Verify and secure every device"
    },
    {
      "TestId": "40009",
      "TestResult": "Insider risk management policies are not configured.",
      "TestDescription": "Insider risk management detects and investigates potential insider threats based on user activity signals.",
      "TestSkipped": "",
      "TestTitle": "Insider risk management policies are configured to detect data exfiltration",
      "TestStatus": "Failed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Data",
      "TestImpact": "Low",
      "TestSfiPillar": "Monitor and detect threats",
      "TestCategory": "Insider Risk",
      "TestImplementationCost": "High",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["NIST", "CISA"],
      "TestZtPrinciple": "Assume breach"
    },
    {
      "TestId": "40010",
      "TestResult": "eDiscovery premium is licensed but content search auditing is not enabled.",
      "TestDescription": "eDiscovery capabilities must include auditing to track who searches for and accesses sensitive content.",
      "TestSkipped": "",
      "TestTitle": "eDiscovery content search activities are audited and monitored",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "Low",
      "TestPillar": "Data",
      "TestImpact": "Low",
      "TestSfiPillar": "Monitor and detect threats",
      "TestCategory": "Auditing",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": null,
      "TestRegulatory": ["ISO"],
      "TestZtPrinciple": "Assume breach"
    }
  ],
  "TenantInfo": {
    "ConfigWindowsEnrollment": [
      {
        "Type": "MDM",
        "PolicyName": "Microsoft Intune",
        "AppliesTo": "Selected",
        "Groups": "All active users"
      },
      {
        "Type": "MDM",
        "PolicyName": "Microsoft Intune Enrollment",
        "AppliesTo": "None",
        "Groups": "Not Applicable"
      }
    ],
    "ConfigDeviceCompliancePolicies": [
      {
        "Platform": "iOS/iPadOS",
        "PolicyName": "My iOS policy",
        "DefenderForEndPoint": "Clear",
        "MinOsVersion": "4",
        "MaxOsVersion": "5",
        "RequirePswd": true,
        "MinPswdLength": 5,
        "PasswordType": "Alphanumeric",
        "PswdExpiryDays": 34,
        "CountOfPreviousPswdToBlock": 5,
        "RequireEncryption": "Not Applicable",
        "RootedJailbrokenDevices": "Blocked",
        "MaxDeviceThreatLevel": "Secured",
        "RequireFirewall": "Not Applicable",
        "MaxInactivityMin": 0,
        "ActionForNoncomplianceDaysPushNotification": 2.0,
        "ActionForNoncomplianceDaysSendEmail": 2.0,
        "ActionForNoncomplianceDaysRemoteLock": 2.0,
        "ActionForNoncomplianceDaysBlock": 1.0,
        "ActionForNoncomplianceDaysRetire": 3.0,
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "Android Enterprise (Personal)",
        "PolicyName": "My android personally-owned",
        "DefenderForEndPoint": "",
        "MinOsVersion": "3",
        "MaxOsVersion": "4",
        "RequirePswd": "Yes",
        "MinPswdLength": 5,
        "PasswordType": null,
        "PswdExpiryDays": 200,
        "CountOfPreviousPswdToBlock": 12,
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "Blocked",
        "MaxDeviceThreatLevel": "Low",
        "RequireFirewall": "Not Applicable",
        "MaxInactivityMin": 5,
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": 2.0,
        "ActionForNoncomplianceDaysBlock": 2.0,
        "ActionForNoncomplianceDaysRetire": "Immediately",
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "Windows 10 and later",
        "PolicyName": "Min Windows Compliance",
        "DefenderForEndPoint": "",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": "",
        "MinPswdLength": null,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "Not Applicable",
        "MaxDeviceThreatLevel": "Not Applicable",
        "RequireFirewall": "",
        "MaxInactivityMin": null,
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "Immediately",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "macOS",
        "PolicyName": "My macOS policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "1",
        "MaxOsVersion": "2",
        "RequirePswd": "Yes",
        "MinPswdLength": 6,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "Not Applicable",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Yes",
        "MaxInactivityMin": 15,
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": 4.0,
        "ActionForNoncomplianceDaysBlock": "Immediately",
        "ActionForNoncomplianceDaysRetire": 6.0,
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "Windows 10 and later",
        "PolicyName": "My Windows policy",
        "DefenderForEndPoint": "High",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": "Yes",
        "MinPswdLength": 5,
        "PasswordType": null,
        "PswdExpiryDays": 22,
        "CountOfPreviousPswdToBlock": 6,
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "Not Applicable",
        "MaxDeviceThreatLevel": "Not Applicable",
        "RequireFirewall": "Yes",
        "MaxInactivityMin": 1,
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "Immediately",
        "ActionForNoncomplianceDaysRetire": "Immediately",
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "Android device administrator",
        "PolicyName": "My android device policy",
        "DefenderForEndPoint": "Clear",
        "MinOsVersion": "2",
        "MaxOsVersion": "3",
        "RequirePswd": "Yes",
        "MinPswdLength": null,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "Blocked",
        "MaxDeviceThreatLevel": "Low",
        "RequireFirewall": "Not Applicable",
        "MaxInactivityMin": 1,
        "ActionForNoncomplianceDaysPushNotification": 12.0,
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "Immediately",
        "ActionForNoncomplianceDaysBlock": "Immediately",
        "ActionForNoncomplianceDaysRetire": "Immediately",
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "Android Enterprise (Corp)",
        "PolicyName": "My android enterprise policy",
        "DefenderForEndPoint": "Low",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": "Yes",
        "MinPswdLength": 4,
        "PasswordType": null,
        "PswdExpiryDays": 200,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
        "MaxInactivityMin": 15,
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "Immediately",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "Windows 8.1 and later",
        "PolicyName": "My Windows 8 policy",
        "DefenderForEndPoint": "Not Applicable",
        "MinOsVersion": "1.1",
        "MaxOsVersion": "2.1",
        "RequirePswd": "Yes",
        "MinPswdLength": null,
        "PasswordType": null,
        "PswdExpiryDays": 22,
        "CountOfPreviousPswdToBlock": 10,
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "Not Applicable",
        "MaxDeviceThreatLevel": "Not Applicable",
        "RequireFirewall": "Not Applicable",
        "MaxInactivityMin": 240,
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "Immediately",
        "ActionForNoncomplianceDaysRetire": 4.0,
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "Android (AOSP)",
        "PolicyName": "My android aosp policy",
        "DefenderForEndPoint": "Not Applicable",
        "MinOsVersion": "1",
        "MaxOsVersion": "2",
        "RequirePswd": "Yes",
        "MinPswdLength": 16,
        "PasswordType": null,
        "PswdExpiryDays": "Not Applicable",
        "CountOfPreviousPswdToBlock": "Not Applicable",
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "Blocked",
        "MaxDeviceThreatLevel": "Not Applicable",
        "RequireFirewall": "Not Applicable",
        "MaxInactivityMin": 480,
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "Immediately",
        "ActionForNoncomplianceDaysBlock": "Immediately",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      }
    ],
    "ConfigDeviceAppProtectionPolicies": [
      {
        "Platform": "Android",
        "Name": "Android Policy",
        "AppsPublic": "Cortana, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Microsoft Dynamics 365 for tablets, Microsoft Invoicing, Microsoft Edge, Power Automate, Azure Information Protection, Microsoft Launcher, Microsoft Lists, Microsoft Kaizala, Microsoft Power Apps, Microsoft Excel, Skype for Business, Microsoft 365 (Office) (China), Microsoft Office (HL), Microsoft 365 Copilot, Microsoft Lens, Microsoft OneNote, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft Planner, Microsoft Power BI, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Microsoft 365 Admin, Viva Engage, Microsoft StaffHub",
        "AppsCustom": "com.microsoft.d365.fs.mobile, com.microsoft.ramobile, com.microsoft.stream, com.oracle.java.pdfviewer",
        "BackupOrgDataToICloudOrGoogle": "Allow",
        "SendOrgDataToOtherApps": "Policy managed apps",
        "AppsToExempt": "Trello:app:trello",
        "SaveCopiesOfOrgData": "Block",
        "AllowUserToSaveCopiesToSelectedServices": "Box, Local storage, OneDrive for Business, SharePoint, Photo library",
        "DataProtectionTransferTelecommunicationDataTo": "A specific dialer app",
        "DataProtectionReceiveDataFromOtherApps": "Policy managed apps",
        "DataProtectionOpenDataIntoOrgDocuments": "",
        "DataProtectionAllowUsersToOpenDataFromSelectedServices": "",
        "DataProtectionRestrictCutCopyBetweenOtherApps": "",
        "DataProtectionCutCopyCharacterLimitForAnyApp": "",
        "DataProtectionEncryptOrgData": "",
        "DataProtectionSyncPolicyManagedAppDataWithNativeApps": "",
        "DataProtectionPrintingOrgData": "",
        "DataProtectionRestrictWebContentTransferWithOtherApps": "",
        "DataProtectionOrgDataNotifications": "",
        "ConditionalLaunchAppMaxPinAttempts": "",
        "ConditionalLaunchAppOfflineGracePeriodBlockAccess": "",
        "ConditionalLaunchAppOfflineGracePeriodWipeData": "",
        "ConditionalLaunchAppDisabedAccount": "",
        "ConditionalLaunchAppMinAppVersion": "",
        "ConditionalLaunchDeviceRootedJailbrokenDevices": "Block access",
        "ConditionalLaunchDevicePrimaryMtdService": "",
        "ConditionalLaunchDeviceMaxAllowedDeviceThreatLevel": "",
        "ConditionalLaunchDeviceMinOsVersion": "",
        "ConditionalLaunchDeviceMaxOsVersion": "",
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "iOS/iPadOS",
        "Name": "iOS Policy",
        "AppsPublic": "Adobe Acrobat Reader, Cortana, Microsoft Dynamics 365, Microsoft Invoicing, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Skype for Business, Microsoft Kaizala, Microsoft Power Apps, Microsoft Edge, Microsoft 365 Admin, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft Lens, Microsoft 365 Copilot, Microsoft OneNote, Microsoft Planner, Microsoft Power BI, Power Automate, Azure Information Protection, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft StaffHub, Microsoft OneDrive, Microsoft Teams, Microsoft Lists, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Vera for Intune, Viva Engage",
        "AppsCustom": "com.microsoft.d365.fs.mobile, com.microsoft.ramobile, com.microsoft.stream, com.microsoft.visio, my.merill.net",
        "BackupOrgDataToICloudOrGoogle": "Block",
        "SendOrgDataToOtherApps": "Policy managed apps with OS sharing",
        "AppsToExempt": "",
        "SaveCopiesOfOrgData": "Allow",
        "AllowUserToSaveCopiesToSelectedServices": "Box, Local storage, OneDrive for Business, SharePoint, Photo library",
        "DataProtectionTransferTelecommunicationDataTo": "A specific dialer app",
        "DataProtectionReceiveDataFromOtherApps": "None",
        "DataProtectionOpenDataIntoOrgDocuments": "",
        "DataProtectionAllowUsersToOpenDataFromSelectedServices": "",
        "DataProtectionRestrictCutCopyBetweenOtherApps": "",
        "DataProtectionCutCopyCharacterLimitForAnyApp": "",
        "DataProtectionEncryptOrgData": "",
        "DataProtectionSyncPolicyManagedAppDataWithNativeApps": "",
        "DataProtectionPrintingOrgData": "",
        "DataProtectionRestrictWebContentTransferWithOtherApps": "",
        "DataProtectionOrgDataNotifications": "",
        "ConditionalLaunchAppMaxPinAttempts": "",
        "ConditionalLaunchAppOfflineGracePeriodBlockAccess": "",
        "ConditionalLaunchAppOfflineGracePeriodWipeData": "",
        "ConditionalLaunchAppDisabedAccount": "",
        "ConditionalLaunchAppMinAppVersion": "",
        "ConditionalLaunchDeviceRootedJailbrokenDevices": "Wipe data",
        "ConditionalLaunchDevicePrimaryMtdService": "",
        "ConditionalLaunchDeviceMaxAllowedDeviceThreatLevel": "",
        "ConditionalLaunchDeviceMinOsVersion": "",
        "ConditionalLaunchDeviceMaxOsVersion": "",
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "Windows",
        "Name": "Windows Info Protect",
        "AppsPublic": "",
        "AppsCustom": "",
        "BackupOrgDataToICloudOrGoogle": "",
        "SendOrgDataToOtherApps": "",
        "AppsToExempt": "",
        "SaveCopiesOfOrgData": "",
        "AllowUserToSaveCopiesToSelectedServices": "",
        "DataProtectionTransferTelecommunicationDataTo": null,
        "DataProtectionReceiveDataFromOtherApps": null,
        "DataProtectionOpenDataIntoOrgDocuments": "",
        "DataProtectionAllowUsersToOpenDataFromSelectedServices": "",
        "DataProtectionRestrictCutCopyBetweenOtherApps": "",
        "DataProtectionCutCopyCharacterLimitForAnyApp": "",
        "DataProtectionEncryptOrgData": "",
        "DataProtectionSyncPolicyManagedAppDataWithNativeApps": "",
        "DataProtectionPrintingOrgData": "",
        "DataProtectionRestrictWebContentTransferWithOtherApps": "",
        "DataProtectionOrgDataNotifications": "",
        "ConditionalLaunchAppMaxPinAttempts": "",
        "ConditionalLaunchAppOfflineGracePeriodBlockAccess": "",
        "ConditionalLaunchAppOfflineGracePeriodWipeData": "",
        "ConditionalLaunchAppDisabedAccount": "",
        "ConditionalLaunchAppMinAppVersion": "",
        "ConditionalLaunchDeviceRootedJailbrokenDevices": null,
        "ConditionalLaunchDevicePrimaryMtdService": "",
        "ConditionalLaunchDeviceMaxAllowedDeviceThreatLevel": "",
        "ConditionalLaunchDeviceMinOsVersion": "",
        "ConditionalLaunchDeviceMaxOsVersion": "",
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      }
    ],
    "ConfigDeviceEnrollmentRestriction": [
      {
        "Platform": "iOS/iPadOS",
        "Priority": 2,
        "Name": "iOS Restriction 2",
        "MDM": "Blocked",
        "MinVer": null,
        "MaxVer": null,
        "PersonallyOwned": "Allowed",
        "BlockedManufacturers": null,
        "Scope": "Default",
        "AssignedTo": "All users"
      },
      {
        "Platform": "Android Enterprise (work profile)",
        "Priority": 1,
        "Name": "Andy Penn",
        "MDM": "Allowed",
        "MinVer": "5.0",
        "MaxVer": "5.1.1",
        "PersonallyOwned": "Allowed",
        "BlockedManufacturers": "Samsung",
        "Scope": "Biscope, Default",
        "AssignedTo": "aad-conditional-access-allow-legacy-auth"
      },
      {
        "Platform": "Android device administrator",
        "Priority": 1,
        "Name": "Andy Penn",
        "MDM": "Allowed",
        "MinVer": "5.0",
        "MaxVer": "6.0",
        "PersonallyOwned": "Allowed",
        "BlockedManufacturers": "Samsung",
        "Scope": "Biscope, Default",
        "AssignedTo": "aad-conditional-access-allow-legacy-auth"
      },
      {
        "Platform": "iOS/iPadOS",
        "Priority": 1,
        "Name": "iOS Restriction",
        "MDM": "Allowed",
        "MinVer": "9.0",
        "MaxVer": "10.0",
        "PersonallyOwned": "Blocked",
        "BlockedManufacturers": null,
        "Scope": "Default",
        "AssignedTo": "aad-conditional-access-excluded, Avanade Users"
      },
      {
        "Platform": "Windows",
        "Priority": 1,
        "Name": "Win1",
        "MDM": "Allowed",
        "MinVer": null,
        "MaxVer": null,
        "PersonallyOwned": "Allowed",
        "BlockedManufacturers": null,
        "Scope": "Biscope, Default",
        "AssignedTo": "All users"
      },
      {
        "Platform": "iOS/iPadOS",
        "Priority": "Default",
        "Name": "All users",
        "MDM": "Allowed",
        "MinVer": "9.0",
        "MaxVer": "10.0",
        "PersonallyOwned": "Blocked",
        "BlockedManufacturers": null,
        "Scope": "",
        "AssignedTo": "All devices"
      },
      {
        "Platform": "Windows",
        "Priority": "Default",
        "Name": "All users",
        "MDM": "Allowed",
        "MinVer": "10.0",
        "MaxVer": "11.0",
        "PersonallyOwned": "Blocked",
        "BlockedManufacturers": null,
        "Scope": "",
        "AssignedTo": "All devices"
      },
      {
        "Platform": "Android device administrator",
        "Priority": "Default",
        "Name": "All users",
        "MDM": "Allowed",
        "MinVer": "7.0",
        "MaxVer": "8.0",
        "PersonallyOwned": "Blocked",
        "BlockedManufacturers": "Samsung",
        "Scope": "",
        "AssignedTo": "All devices"
      },
      {
        "Platform": "macOS",
        "Priority": "Default",
        "Name": "All users",
        "MDM": "Allowed",
        "MinVer": null,
        "MaxVer": null,
        "PersonallyOwned": "Blocked",
        "BlockedManufacturers": null,
        "Scope": "",
        "AssignedTo": "All devices"
      },
      {
        "Platform": "Android Enterprise (work profile)",
        "Priority": "Default",
        "Name": "All users",
        "MDM": "Allowed",
        "MinVer": "5.0",
        "MaxVer": "6.0",
        "PersonallyOwned": "Blocked",
        "BlockedManufacturers": "Samsung",
        "Scope": "",
        "AssignedTo": "All devices"
      }
    ],
    "DeviceOverview": {
      "DesktopDevicesSummary": {
        "nodes": [
          {
            "source": "Desktop devices",
            "target": "Windows",
            "value": 11.0
          },
          {
            "source": "Desktop devices",
            "target": "macOS",
            "value": 2.0
          },
          {
            "source": "Windows",
            "target": "Entra joined",
            "value": 8.0
          },
          {
            "source": "Windows",
            "target": "Entra hybrid joined",
            "value": 0
          },
          {
            "source": "Windows",
            "target": "Entra registered",
            "value": 3.0
          },
          {
            "source": "macOS",
            "target": "Compliant",
            "value": 1.0
          },
          {
            "source": "macOS",
            "target": "Non-compliant",
            "value": 1.0
          },
          {
            "source": "macOS",
            "target": "Unmanaged",
            "value": null
          },
          {
            "source": "Entra joined",
            "target": "Compliant",
            "value": null
          },
          {
            "source": "Entra joined",
            "target": "Non-compliant",
            "value": 4.0
          },
          {
            "source": "Entra joined",
            "target": "Unmanaged",
            "value": null
          },
          {
            "source": "Entra hybrid joined",
            "target": "Compliant",
            "value": null
          },
          {
            "source": "Entra hybrid joined",
            "target": "Non-compliant",
            "value": null
          },
          {
            "source": "Entra hybrid joined",
            "target": "Unmanaged",
            "value": null
          },
          {
            "source": "Entra registered",
            "target": "Compliant",
            "value": null
          },
          {
            "source": "Entra registered",
            "target": "Non-compliant",
            "value": null
          },
          {
            "source": "Entra registered",
            "target": "Unmanaged",
            "value": null
          }
        ],
        "entrahybridjoined": 0,
        "description": "Desktop devices (Windows and macOS) by join type and compliance status.",
        "totalDevices": 13.0,
        "entrajoined": 9.0,
        "entrareigstered": 4.0
      },
      "MobileSummary": {
        "nodes": [
          {
            "source": "Mobile devices",
            "target": "Android",
            "value": 40
          },
          {
            "source": "Mobile devices",
            "target": "iOS",
            "value": 53
          },
          {
            "source": "Android",
            "target": "Android (Company)",
            "value": 20
          },
          {
            "source": "Android",
            "target": "Android (Personal)",
            "value": 20
          },
          {
            "source": "iOS",
            "target": "iOS (Company)",
            "value": 28
          },
          {
            "source": "iOS",
            "target": "iOS (Personal)",
            "value": 25
          },
          {
            "source": "Android (Company)",
            "target": "Compliant",
            "value": 15
          },
          {
            "source": "Android (Company)",
            "target": "Non-compliant",
            "value": 5
          },
          {
            "source": "Android (Personal)",
            "target": "Compliant",
            "value": 8
          },
          {
            "source": "Android (Personal)",
            "target": "Non-compliant",
            "value": 12
          },
          {
            "source": "iOS (Company)",
            "target": "Compliant",
            "value": 25
          },
          {
            "source": "iOS (Company)",
            "target": "Non-compliant",
            "value": 3
          },
          {
            "source": "iOS (Personal)",
            "target": "Compliant",
            "value": 18
          },
          {
            "source": "iOS (Personal)",
            "target": "Non-compliant",
            "value": 7
          }
        ],
        "description": "Mobile devices by compliance status.",
        "totalDevices": 93
      },
      "ManagedDevices": {
        "@odata.context": "https://graph.microsoft.com/beta/$metadata#microsoft.graph.managedDeviceOverview",
        "id": "4a197fb2-79de-4f46-89e3-bd318ca08984",
        "enrolledDeviceCount": 0,
        "mdmEnrolledCount": 0,
        "dualEnrolledDeviceCount": 0,
        "managedDeviceModelsAndManufacturers": null,
        "lastModifiedDateTime": "2025-10-20T21:07:52.4781572Z",
        "deviceOperatingSystemSummary": {
          "androidCount": 300,
          "iosCount": 340,
          "macOSCount": 10,
          "windowsMobileCount": 0,
          "windowsCount": 1000,
          "unknownCount": 0,
          "androidDedicatedCount": 0,
          "androidDeviceAdminCount": 0,
          "androidFullyManagedCount": 0,
          "androidWorkProfileCount": 0,
          "androidCorporateWorkProfileCount": 0,
          "configMgrDeviceCount": 0,
          "aospUserlessCount": 0,
          "aospUserAssociatedCount": 0,
          "linuxCount": 20,
          "chromeOSCount": 0
        },
        "deviceExchangeAccessStateSummary": {
          "allowedDeviceCount": 0,
          "blockedDeviceCount": 0,
          "quarantinedDeviceCount": 0,
          "unknownDeviceCount": 0,
          "unavailableDeviceCount": 0
        },
        "desktopCount": 20,
        "mobileCount": 30,
        "totalCount": 50
      },
      "DeviceCompliance": {
        "@odata.context": "https://graph.microsoft.com/beta/$metadata#deviceManagement/deviceCompliancePolicyDeviceStateSummary/$entity",
        "inGracePeriodCount": 0,
        "configManagerCount": 0,
        "id": "afaac8a4-5f74-40f5-a213-51af45bedc36",
        "unknownDeviceCount": 0,
        "notApplicableDeviceCount": 0,
        "compliantDeviceCount": 10,
        "remediatedDeviceCount": 0,
        "nonCompliantDeviceCount": 10,
        "errorDeviceCount": 0,
        "conflictDeviceCount": 0
      },
      "DeviceOwnership": {
        "corporateCount": 20,
        "personalCount": 10
      }
    },
    "TenantOverview": {
      "UserCount": 71000,
      "GuestCount": 12,
      "GroupCount": 1890,
      "ApplicationCount": 120,
      "DeviceCount": 20,
      "ManagedDeviceCount": 0
    }
  },
  "EndOfJson": "EndOfJson"
}
