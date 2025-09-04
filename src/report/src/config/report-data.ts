// Use quicktype (Paste JSON as Code) VSCode extension to generate this typescript interface from ZeroTrustAssessmentReport.json created by PowerShell

export interface ZeroTrustAssessmentReport {
  ExecutedAt: string;
  TenantId: string;
  TenantName: string;
  Domain: string;
  Account: string;
  CurrentVersion: string;
  LatestVersion: string;
  Tests: Test[];
  TenantInfo: TenantInfo | null;
  TestResultSummary: TestResultSummaryData;
  EndOfJson: string;
}

export interface TenantInfo {
  OverviewCaMfaAllUsers: SankeyData | null;
  OverviewCaDevicesAllUsers: SankeyData | null
  OverviewAuthMethodsPrivilegedUsers: SankeyData | null;
  OverviewAuthMethodsAllUsers: SankeyData | null;
  ConfigWindowsEnrollment: ConfigWindowsEnrollment[] | null;
  ConfigDeviceEnrollmentRestriction: ConfigDeviceEnrollmentRestriction[] | null;
  ConfigDeviceCompliancePolicies: ConfigDeviceCompliancePolicies[] | null;
  ConfigDeviceAppProtectionPolicies: ConfigDeviceAppProtectionPolicies[] | null;
}

export interface ConfigWindowsEnrollment {
  Type: string | null;
  PolicyName: string | null;
  AppliesTo: string | null;
  Groups: string | null;
}

export interface ConfigDeviceEnrollmentRestriction {
  Platform: string | null;
  Priority: number | null;
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
  RequirePswd: string | null;
  MinPswdLength: string | null;
  PasswordType: string | null;
  PswdExpiryDays: string | null;
  CountOfPreviousPswdToBlock: string | null;
  MaxInactivityMin: string | null;
  RequireEncryption: string | null;
  RootedJailbrokenDevices: string | null;
  MaxDeviceThreatLevel: string | null;
  RequireFirewall: string | null;
  ActionForNoncomplianceDaysPushNotification: string | null;
  ActionForNoncomplianceDaysSendEmail: string | null;
  ActionForNoncomplianceDaysRemoteLock: string | null;
  ActionForNoncomplianceDaysBlock: string | null;
  ActionForNoncomplianceDaysRetire: string | null;
  Scope: string | null;
  IncludedGroups: string | null;
  ExcludedGroups: string | null;
}

export interface ConfigDeviceAppProtectionPolicies {
  Platform: string | null;
  Name: string | null;
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
  DataPassed: number;
  DataTotal: number;
}
export interface SankeyData {
  nodes: SankeyDataNode[];
  description: string;
}
export interface SankeyDataNode {
  value: number;
  source: string;
  target: string;
}

export interface Test {
  TestTitle: string;
  TestRisk: string;
  TestAppliesTo: string[];
  TestImpact: string;
  TestCategory: string | null;
  TestImplementationCost: string;
  TestSfiPillar: string | null;
  TestPillar: string | null;
  SkippedReason: string | null;
  TestResult: string;
  TestSkipped: string;
  TestStatus: string;
  TestTags: string[];
  TestId: string;
  TestDescription: string;
}

export const reportData: ZeroTrustAssessmentReport = {
  "ExecutedAt": "2025-08-14T21:07:07.24614+10:00",
  "TenantId": "0ae863cb-7e9c-481a-9762-cc7fd08df299",
  "TenantName": "Merill - Sep 25",
  "Domain": "merillsep25.onmicrosoft.com",
  "Account": "merill@merillsep25.onmicrosoft.com",
  "CurrentVersion": "0.11.0",
  "LatestVersion": "0.11.0",
  "TestResultSummary": {
    "IdentityPassed": 1,
    "IdentityTotal": 1,
    "DevicesPassed": 0,
    "DevicesTotal": 0,
    "DataPassed": 0,
    "DataTotal": 0
  },
  "Tests": [
    {
      "TestResult": "\nNo inactive applications with privileged Entra built-in roles\n\n\n\n",
      "TestPillar": "Identity",
      "SkippedReason": null,
      "TestSkipped": "",
      "TestTags": [
        "Application"
      ],
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Passed",
      "TestId": "21771",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestCategory": "Application management",
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they're legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable inactive privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases. If so, [analyze if a OAuth2 permission is a better fit](https://learn.microsoft.com/entra/identity-platform/v2-app-types?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestRisk": "High",
      "TestImpact": "Low",
      "TestTitle": "Inactive applications don’t have highly privileged built-in roles",
      "TestImplementationCost": "Low"
    }
  ],
  "TenantInfo": {
    "OverviewCaMfaAllUsers": {
      "nodes": [
        {
          "source": "User sign in",
          "value": 25,
          "target": "No CA applied"
        },
        {
          "source": "User sign in",
          "value": 27,
          "target": "CA applied"
        },
        {
          "source": "CA applied",
          "value": 3,
          "target": "No MFA"
        },
        {
          "source": "CA applied",
          "value": 24,
          "target": "MFA"
        }
      ],
      "description": "Over the past 29 days, 46.2% of sign-ins were protected by conditional access policies enforcing multifactor."
    },
    "OverviewCaDevicesAllUsers": {
      "nodes": [
        {
          "source": "User sign in",
          "value": 52,
          "target": "Unmanaged"
        },
        {
          "source": "User sign in",
          "value": 0,
          "target": "Managed"
        },
        {
          "source": "Managed",
          "value": 0,
          "target": "Non-compliant"
        },
        {
          "source": "Managed",
          "value": 0,
          "target": "Compliant"
        }
      ],
      "description": "Over the past 29 days, 0% of sign-ins were from compliant devices."
    },
    "OverviewAuthMethodsAllUsers": {
      "nodes": [
        {
          "source": "Users",
          "value": 1,
          "target": "Single factor"
        },
        {
          "source": "Users",
          "value": 3,
          "target": "Phishable"
        },
        {
          "source": "Phishable",
          "value": 1,
          "target": "Phone"
        },
        {
          "source": "Phishable",
          "value": 2,
          "target": "Authenticator"
        },
        {
          "source": "Users",
          "value": 0,
          "target": "Phish resistant"
        },
        {
          "source": "Phish resistant",
          "value": 0,
          "target": "Passkey"
        },
        {
          "source": "Phish resistant",
          "value": 0,
          "target": "WHfB"
        }
      ],
      "description": "Strongest authentication method registered by all users."
    },
    "OverviewAuthMethodsPrivilegedUsers": {
      "nodes": [
        {
          "source": "Users",
          "value": 1,
          "target": "Single factor"
        },
        {
          "source": "Users",
          "value": 3,
          "target": "Phishable"
        },
        {
          "source": "Phishable",
          "value": 1,
          "target": "Phone"
        },
        {
          "source": "Phishable",
          "value": 2,
          "target": "Authenticator"
        },
        {
          "source": "Users",
          "value": 0,
          "target": "Phish resistant"
        },
        {
          "source": "Phish resistant",
          "value": 0,
          "target": "Passkey"
        },
        {
          "source": "Phish resistant",
          "value": 0,
          "target": "WHfB"
        }
      ],
      "description": "Strongest authentication method registered by privileged users."
    },
    "ConfigDeviceCompliancePolicies": [
      {
        "Platform": "",
        "PolicyName": "My iOS policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "",
        "MaxOsVersion": "",
        "RequirePswd": "",
        "MinPswdLength": "",
        "PasswordType": "",
        "PswdExpiryDays": "",
        "CountOfPreviousPswdToBlock": "",
        "MaxInactivityMin": "",
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "",
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "",
        "PolicyName": "My android personally-owned",
        "DefenderForEndPoint": "",
        "MinOsVersion": "",
        "MaxOsVersion": "",
        "RequirePswd": "",
        "MinPswdLength": "",
        "PasswordType": "",
        "PswdExpiryDays": "",
        "CountOfPreviousPswdToBlock": "",
        "MaxInactivityMin": "",
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "",
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "",
        "PolicyName": "Min Windows Compliance",
        "DefenderForEndPoint": "",
        "MinOsVersion": "",
        "MaxOsVersion": "",
        "RequirePswd": "",
        "MinPswdLength": "",
        "PasswordType": "",
        "PswdExpiryDays": "",
        "CountOfPreviousPswdToBlock": "",
        "MaxInactivityMin": "",
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "",
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "",
        "PolicyName": "My macOS policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "",
        "MaxOsVersion": "",
        "RequirePswd": "",
        "MinPswdLength": "",
        "PasswordType": "",
        "PswdExpiryDays": "",
        "CountOfPreviousPswdToBlock": "",
        "MaxInactivityMin": "",
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "",
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "",
        "PolicyName": "My Windows policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "",
        "MaxOsVersion": "",
        "RequirePswd": "",
        "MinPswdLength": "",
        "PasswordType": "",
        "PswdExpiryDays": "",
        "CountOfPreviousPswdToBlock": "",
        "MaxInactivityMin": "",
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "",
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "",
        "PolicyName": "My android device policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "",
        "MaxOsVersion": "",
        "RequirePswd": "",
        "MinPswdLength": "",
        "PasswordType": "",
        "PswdExpiryDays": "",
        "CountOfPreviousPswdToBlock": "",
        "MaxInactivityMin": "",
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "",
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "",
        "PolicyName": "My android enterprise policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "",
        "MaxOsVersion": "",
        "RequirePswd": "",
        "MinPswdLength": "",
        "PasswordType": "",
        "PswdExpiryDays": "",
        "CountOfPreviousPswdToBlock": "",
        "MaxInactivityMin": "",
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "",
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "",
        "PolicyName": "My Windows 8 policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "",
        "MaxOsVersion": "",
        "RequirePswd": "",
        "MinPswdLength": "",
        "PasswordType": "",
        "PswdExpiryDays": "",
        "CountOfPreviousPswdToBlock": "",
        "MaxInactivityMin": "",
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "",
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "",
        "PolicyName": "My android aosp policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "",
        "MaxOsVersion": "",
        "RequirePswd": "",
        "MinPswdLength": "",
        "PasswordType": "",
        "PswdExpiryDays": "",
        "CountOfPreviousPswdToBlock": "",
        "MaxInactivityMin": "",
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "",
        "ActionForNoncomplianceDaysPushNotification": "",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      }
    ],
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
    "ConfigDeviceAppProtectionPolicies": [
      {
        "Platform": "",
        "Name": "Test",
        "AppsPublic": "",
        "AppsCustom": "",
        "BackupOrgDataToICloudOrGoogle": "",
        "SendOrgDataToOtherApps": "",
        "AppsToExempt": "",
        "SaveCopiesOfOrgData": "",
        "AllowUserToSaveCopiesToSelectedServices": "",
        "DataProtectionTransferTelecommunicationDataTo": "",
        "DataProtectionReceiveDataFromOtherApps": "",
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
        "ConditionalLaunchDeviceRootedJailbrokenDevices": "",
        "ConditionalLaunchDevicePrimaryMtdService": "",
        "ConditionalLaunchDeviceMaxAllowedDeviceThreatLevel": "",
        "ConditionalLaunchDeviceMinOsVersion": "",
        "ConditionalLaunchDeviceMaxOsVersion": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "",
        "Name": null,
        "AppsPublic": "",
        "AppsCustom": "",
        "BackupOrgDataToICloudOrGoogle": "",
        "SendOrgDataToOtherApps": "",
        "AppsToExempt": "",
        "SaveCopiesOfOrgData": "",
        "AllowUserToSaveCopiesToSelectedServices": "",
        "DataProtectionTransferTelecommunicationDataTo": "",
        "DataProtectionReceiveDataFromOtherApps": "",
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
        "ConditionalLaunchDeviceRootedJailbrokenDevices": "",
        "ConditionalLaunchDevicePrimaryMtdService": "",
        "ConditionalLaunchDeviceMaxAllowedDeviceThreatLevel": "",
        "ConditionalLaunchDeviceMinOsVersion": "",
        "ConditionalLaunchDeviceMaxOsVersion": "",
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "",
        "Name": null,
        "AppsPublic": "",
        "AppsCustom": "",
        "BackupOrgDataToICloudOrGoogle": "",
        "SendOrgDataToOtherApps": "",
        "AppsToExempt": "",
        "SaveCopiesOfOrgData": "",
        "AllowUserToSaveCopiesToSelectedServices": "",
        "DataProtectionTransferTelecommunicationDataTo": "",
        "DataProtectionReceiveDataFromOtherApps": "",
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
        "ConditionalLaunchDeviceRootedJailbrokenDevices": "",
        "ConditionalLaunchDevicePrimaryMtdService": "",
        "ConditionalLaunchDeviceMaxAllowedDeviceThreatLevel": "",
        "ConditionalLaunchDeviceMinOsVersion": "",
        "ConditionalLaunchDeviceMaxOsVersion": "",
        "Scope": "",
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
        "BlockedManufacturers": "",
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
        "BlockedManufacturers": "",
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
        "BlockedManufacturers": "",
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
        "BlockedManufacturers": "",
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
        "BlockedManufacturers": "",
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
        "BlockedManufacturers": "",
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
    ]
  },
  "EndOfJson": "EndOfJson"
}
