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
    "IdentityPassed": 0,
    "IdentityTotal": 0,
    "DevicesPassed": 1,
    "DevicesTotal": 1,
    "DataPassed": 0,
    "DataTotal": 0
  },
  "Tests": [
    {
      "TestId": "24546",
      "TestResult": "\nWindows Automatic Enrollment is enabled.\n\n\n## Windows Automatic Enrollment\n\n| Policy Name | User Scope |\n| :---------- | :--------- |\n| [Microsoft Intune](https://intune.microsoft.com/#view/Microsoft_AAD_IAM/MdmConfiguration.ReactView/appId/0000000a-0000-0000-c000-000000000000/appName/Microsoft%20Intune) | ✅ Specific Groups |\n\n\n\n",
      "TestDescription": "If Windows automatic enrollment isn't enabled, unmanaged devices can become an entry point for attackers. Threat actors might use these devices to access corporate data, bypass compliance policies, and introduce vulnerabilities into the environment. Devices joined to Microsoft Entra without Intune enrollment create gaps in visibility and control. These unmanaged endpoints can expose weaknesses in the operating system or misconfigured applications that attackers can exploit.\n\nEnforcing automatic enrollment ensures Windows devices are managed from the start, enabling consistent policy enforcement and visibility into compliance. This supports Zero Trust by ensuring all devices are verified, monitored, and governed by security controls.\n\n**Remediation action**\n\nEnable automatic enrollment for Windows devices using Intune and Microsoft Entra to ensure all domain-joined or Entra-joined devices are managed:  \n- [Enable Windows automatic enrollment](https://learn.microsoft.com/intune/intune-service/enrollment/windows-enroll?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-windows-automatic-enrollment)\n\nFor more information, see:  \n- [Deployment guide - Enrollment for Windows](https://learn.microsoft.com/intune/intune-service/fundamentals/deployment-guide-enroll?tabs=work-profile%2Ccorporate-owned-apple%2Cautomatic-enrollment&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enrollment-for-windows)\n",
      "TestSkipped": "",
      "TestTitle": "Windows automatic device enrollment is enforced to eliminate risks from unmanaged endpoints",
      "TestStatus": "Passed",
      "TestTags": null,
      "TestRisk": "High",
      "TestPillar": "Devices",
      "TestImpact": "Low",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestCategory": "Devices",
      "TestImplementationCost": "Low",
      "SkippedReason": null,
      "TestAppliesTo": null
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
