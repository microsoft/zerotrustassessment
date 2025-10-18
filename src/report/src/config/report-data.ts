// @ts-nocheck

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
  DeviceOverview: DeviceOverview | null;
  TenantOverview: TenantOverview | null;
}

export interface ConfigWindowsEnrollment {
  Type: string | null;
  PolicyName: string | null;
  AppliesTo: string | null;
  Groups: string | null;
}

export interface ConfigDeviceEnrollmentRestriction {
  Platform: string | null;
  Priority: string | null;
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

export interface TenantOverview {
  UserCount: number;
  GroupCount: number;
  ApplicationCount: number;
  DeviceCount: number;
  ManagedDeviceCount: number;
}
export interface DeviceOverview {
  WindowsJoinSummary: SankeyData | null;
  ManagedDevices: ManagedDevices | null;
  DeviceCompliance: DeviceCompliance | null;
}

export interface ManagedDevices {
  "@odata.context": string;
  id: string;
  totalDeviceCount: number;
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
  "ExecutedAt": "2025-10-18T08:08:54.93436+11:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora Inc.",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "0.18.0",
  "LatestVersion": "0.18.0",
  "TestResultSummary": {
    "IdentityPassed": 39,
    "IdentityTotal": 84,
    "DevicesPassed": 16,
    "DevicesTotal": 36,
    "DataPassed": 0,
    "DataTotal": 0
  },
  "Tests": [
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When sign-ins are not restricted to managed devices, threat actors can use unmanaged devices to establish initial access to organizational resources. Unmanaged devices lack organizational security controls, endpoint protection, and compliance verification, creating entry points for threat actors to exploit. Unmanaged devices lack centralized security controls, compliance monitoring, and policy enforcement, creating gaps in the organization's security perimeter. Threat actors can compromise these devices through malware, keyloggers, or credential harvesting tools, then use the captured credentials to authenticate corporate resources without detection. Accounts that are assigned administrative rights are a target for attackers. Requiring users with these highly privileged rights to perform actions from devices marked as compliant or Microsoft Entra hybrid joined can help limit possible exposure. Without device compliance requirements, threat actors can maintain persistence through uncontrolled endpoints, bypass security monitoring that would typically detect anomalous behavior on managed devices and use unmanaged devices as staging areas for lateral movement across network resources. \n",
      "TestId": "21892",
      "SkippedReason": null,
      "TestImpact": "High",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "❌ Not all sign-in activity comes from managed devices.\n\n### Managed device conditional access policy summary\n\nThe table below lists all Conditional Access policies that require a compliant device or a hybrid joined device.\n| Name | All users | All apps | Compliant device | Hybrid joined device | Policy state | Status |\n| :--- | :---:  | :---: | :---: | :---: | :--- | :--- |\n| [\\[RaviK\\] - CA policy for Compliant devices](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/dfde11d6-2433-45dc-86dc-f191dcac3bd9) | 🔴 | 🔴 | 🟢 | 🔴 | 🟢 Enabled | ❌ Fail |\n| [\\[RaviK\\] - Require app protection policy](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6909c0fb-c830-42b6-a438-c41d4010518f) | 🔴 | 🔴 | 🟢 | 🔴 | 🟢 Enabled | ❌ Fail |\n| [ALEX - MFA for risky sign-ins](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/5167662e-2022-45a5-825c-4514e5a0cfd4) | 🔴 | 🟢 | 🟢 | 🟢 | 🟡 Report-only | ❌ Fail |\n| [All sign-in activity comes from managed devices](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/7701ec7b-8983-4dd2-ae60-27cb0b2d3c6d) | 🟢 | 🟢 | 🟢 | 🟢 | 🟡 Report-only | ❌ Fail |\n| [Device compliance #1](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/2965e1d4-6146-41a5-abae-5219abf7d68f) | 🔴 | 🟢 | 🟢 | 🟢 | 🟢 Enabled | ❌ Fail |\n| [Device compliancy](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/206c9071-89d7-4b57-adaf-87f78a4bd7f5) | 🔴 | 🟢 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n| [Require compliant or hybrid Azure AD joined device for admins](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/5ee30a46-6df0-48ff-b60b-45073b7e4e3e) | 🔴 | 🟢 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n| [Require compliant or hybrid Azure AD joined device or multifactor authentication for all users](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/05439c0a-90b2-45e9-92cc-0e13ddc3b9c3) | 🔴 | 🟢 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n| [Require compliant or hybrid Azure AD joined device or multifactor authentication for all users](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/ee4fdb05-5aec-4616-b2da-6d16a2cb2a54) | 🔴 | 🟢 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n| [Securing security info registration](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/28ba1d93-c70c-4c7f-93e4-852705472e3d) | 🟢 | 🔴 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n",
      "TestTitle": "All sign-in activity comes from managed devices",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Enabling the Admin consent workflow in a Microsoft Entra tenant is a vital security measure that mitigates risks associated with unauthorized application access and privilege escalation. This check is important because it ensures that any application requesting elevated permission undergoes a review process by designated administrators before consent is granted. The admin consent workflow in Microsoft Entra ID notifies reviewers who evaluate and approve or deny consent requests based on the application's legitimacy and necessity. If this check doesn't pass, meaning the workflow is disabled, any application can request and potentially receive elevated permissions without administrative review. This poses a substantial security risk, as malicious actors could exploit this lack of oversight to gain unauthorized access to sensitive data, perform privilege escalation, or execute other malicious activities.\n\n**Remediation action**\n\nFor admin consent requests, set the **Users can request admin consent to apps they are unable to consent to** setting to **Yes**. Specify other settings, such as who can review requests.\n\n- [Enable the admin consent workflow](https://learn.microsoft.com/entra/identity/enterprise-apps/configure-admin-consent-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-the-admin-consent-workflow)\n- Or use the [Update adminConsentRequestPolicy](https://learn.microsoft.com/graph/api/adminconsentrequestpolicy-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) API to set the `isEnabled` property to true and other settings\n",
      "TestId": "21809",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nAdmin consent workflow is disabled.\n\nThe adminConsentRequestPolicy.isEnabled property is set to false.\n\n",
      "TestTitle": "Admin consent workflow is enabled",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "",
      "TestSkipped": "",
      "TestDescription": "**Remediation action**\n\n- [](https://learn.microsoft.com/intune/intune-service/?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24871",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo Microsoft Defender for Endpoint Connector found in the tenant.\n\n\n\n",
      "TestTitle": "Automatic enrollment to Defender is enabled on Android to support threat protection",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Monitoring",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "TestDescription": "The activity logs and reports in Microsoft Entra can help detect unauthorized access attempts or identify when tenant configuration changes. When logs are archived or integrated with Security Information and Event Management (SIEM) tools, security teams can implement powerful monitoring and detection security controls, proactive threat hunting, and incident response processes. The logs and monitoring features can be used to assess tenant health and provide evidence for compliance and audits.\n\nIf logs aren't regularly archived or sent to a SIEM tool for querying, it's challenging to investigate sign-in issues. The absence of historical logs means that security teams might miss patterns of failed sign-in attempts, unusual activity, and other indicators of compromise. This lack of visibility can prevent the timely detection of breaches, allowing attackers to maintain undetected access for extended periods.\n\n**Remediation action**\n\n- [Configure Microsoft Entra diagnostic settings](https://learn.microsoft.com/entra/identity/monitoring-health/howto-configure-diagnostic-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Integrate Microsoft Entra logs with Azure Monitor logs](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Stream Microsoft Entra logs to an event hub](https://learn.microsoft.com/entra/identity/monitoring-health/howto-stream-logs-to-event-hub?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21860",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Application"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nSome Entra Logs are not configured with Diagnostic settings.\n\n## Log archiving\n\nLog | Archiving enabled |\n| :--- | :---: |\n|ADFSSignInLogs | ❌ |\n|AuditLogs | ❌ |\n|EnrichedOffice365AuditLogs | ❌ |\n|ManagedIdentitySignInLogs | ❌ |\n|MicrosoftGraphActivityLogs | ❌ |\n|NetworkAccessTrafficLogs | ❌ |\n|NonInteractiveUserSignInLogs | ❌ |\n|ProvisioningLogs | ❌ |\n|RemoteNetworkHealthLogs | ❌ |\n|RiskyServicePrincipals | ❌ |\n|RiskyUsers | ❌ |\n|ServicePrincipalRiskEvents | ❌ |\n|ServicePrincipalSignInLogs | ❌ |\n|SignInLogs | ❌ |\n|UserRiskEvents | ❌ |\n\n\n",
      "TestTitle": "Diagnostic settings are configured for all Microsoft Entra logs",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "When guest users are assigned highly privileged directory roles such as Global Administrator or Privileged Role Administrator, organizations create significant security vulnerabilities that threat actors can exploit for initial access through compromised external accounts or business partner environments. Since guest users originate from external organizations without direct control of security policies, threat actors who compromise these external identities can gain privileged access to the target organization's Microsoft Entra tenant.\n\nWhen threat actors obtain access through compromised guest accounts with elevated privileges, they can escalate their own privilege to create other backdoor accounts, modify security policies, or assign themselves permanent roles within the organization. The compromised privileged guest accounts enable threat actors to establish persistence and then make all the changes they need to remain undetected. For example they could create cloud-only accounts, bypass Conditional Access policies applied to internal users, and maintain access even after the guest's home organization detects the compromise. Threat actors can then conduct lateral movement using administrative privileges to access sensitive resources, modify audit settings, or disable security monitoring across the entire tenant. Threat actors can reach complete compromise of the organization's identity infrastructure while maintaining plausible deniability through the external guest account origin. \n\n**Remediation action**\n\n- [Remove Guest users from privileged roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/best-practices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "22128",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nGuests with privileged roles were detected.\n\n\n## Users with assigned high privileged directory roles\n\n\n| Role Name | User Name | User Principal Name | User Type | Assignment Type |\n| :-------- | :-------- | :------------------ | :-------- | :-------------- |\n| Application Administrator | [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true) | Komal.p@elapora.com | Member | Permanent |\n| Application Administrator | [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true) | chukka.p@elapora.com | Member | Permanent |\n| Application Administrator | [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true) | chukka.p@elapora.com | Member | Permanent |\n| Application Administrator | [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true) | manoj.p@elapora.com | Member | Eligible |\n| Application Administrator | [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true) | manoj.p@elapora.com | Member | Permanent |\n| Application Administrator | [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true) | perennial_ash@elapora.com | Member | Permanent |\n| Application Administrator | [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true) | sandeep.p@elapora.com | Member | Permanent |\n| Application Administrator | [sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/96252680-04a0-4bec-b5f7-a552c8150525/hidePreviewBanner~/true) | sushant.p@elapora.com | Member | Permanent |\n| Global Administrator | [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true) | aleksandar@elapora.com | Member | Permanent |\n| Global Administrator | [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true) | ann@elapora.com | Member | Permanent |\n| Global Administrator | [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true) | merillf_gmail.com#EXT#@pora.onmicrosoft.com | Guest | Permanent |\n| Global Administrator | [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true) | damien.bowden@elapora.com | Member | Permanent |\n| Global Administrator | [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true) | emergency@elapora.com | Member | Permanent |\n| Global Administrator | [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0/hidePreviewBanner~/true) | gael@elapora.com | Member | Eligible |\n| Global Administrator | [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0/hidePreviewBanner~/true) | gael@elapora.com | Member | Permanent |\n| Global Administrator | [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true) | joshua@elapora.com | Member | Permanent |\n| Global Administrator | [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true) | Komal.p@elapora.com | Member | Permanent |\n| Global Administrator | [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true) | madura@elapora.com | Member | Permanent |\n| Global Administrator | [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true) | merill@elapora.com | Member | Permanent |\n| Global Administrator | [Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/1433571b-3d7c-4a56-a9cc-67580848bc73/hidePreviewBanner~/true) | ravi.kalwani@elapora.com | Member | Permanent |\n| Global Administrator | [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true) | tyler@elapora.com | Member | Permanent |\n| Global Administrator | [Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/a85798bd-652b-4eb9-ba90-3ee882df0179/hidePreviewBanner~/true) | varsha.mane@elapora.com | Member | Permanent |\n| Global Administrator | [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true) | chukka.p@elapora.com | Member | Permanent |\n| Global Administrator | [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true) | manoj.p@elapora.com | Member | Permanent |\n| Global Administrator | [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true) | sandeep.p@elapora.com | Member | Permanent |\n| Global Administrator | [sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/96252680-04a0-4bec-b5f7-a552c8150525/hidePreviewBanner~/true) | sushant.p@elapora.com | Member | Permanent |\n| Global Reader | [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true) | Komal.p@elapora.com | Member | Permanent |\n| Global Reader | [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true) | chukka.p@elapora.com | Member | Permanent |\n| Global Reader | [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true) | manoj.p@elapora.com | Member | Permanent |\n| Global Reader | [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true) | perennial_ash@elapora.com | Member | Permanent |\n| Global Reader | [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true) | sandeep.p@elapora.com | Member | Permanent |\n| Global Reader | [sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/96252680-04a0-4bec-b5f7-a552c8150525/hidePreviewBanner~/true) | sushant.p@elapora.com | Member | Permanent |\n| User Administrator | [Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true) | GradyA@elapora.com | Member | Permanent |\n\n\n\n",
      "TestTitle": "Guests are not assigned high privileged directory roles",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without properly configured and assigned FileVault encryption policies in Intune, threat actors can exploit physical access to unmanaged or misconfigured macOS devices to extract sensitive corporate data. Unencrypted devices allow attackers to bypass operating system-level security by booting from external media or removing the storage drive. These attacks can expose credentials, certificates, and cached authentication tokens, enabling privilege escalation and lateral movement. Additionally, unencrypted devices undermine compliance with data protection regulations and increase the risk of reputational damage and financial penalties in the event of a breach.\n\nEnforcing FileVault encryption protects data at rest on macOS devices, even if lost or stolen. It disrupts credential harvesting and lateral movement, supports regulatory compliance, and aligns with Zero Trust principles of device trust.\n\n**Remediation action**\n\nUse Intune to enforce FileVault encryption and monitor compliance on all managed macOS devices:  \n- [Create a FileVault disk encryption policy for macOS in Intune](https://learn.microsoft.com/intune/intune-service/protect/encrypt-devices-filevault?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-endpoint-security-policy-for-filevault)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n- [Monitor device encryption with Intune](https://learn.microsoft.com/intune/intune-service/protect/encryption-monitor?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "24569",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo relevant macOS FileVault encryption policies are configured or assigned.\n\n\n## Intune macOS FileVault policy is created and Assigned\n\n\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n\n\n\n",
      "TestTitle": "FileVault encryption protects data on macOS devices",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "If certificates aren't rotated regularly, they can give threat actors an extended window to extract and exploit them, leading to unauthorized access. When credentials like these are exposed, attackers can blend their malicious activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the application's privileges.\n\nQuery all of your service principals and application registrations that have certificate credentials. Make sure the certificate start date is less than 180 days.\n\n**Remediation action**\n\n- [Define an application management policy to manage certificate lifetimes](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Define a trusted certificate chain of trust](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create a least privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) \n- [Learn more about app management policies to manage certificate based credentials](https://devblogs.microsoft.com/identity/app-management-policy/)\n",
      "TestId": "21992",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound 4 applications and 10 service principals in your tenant with certificates that have not been rotated within 180 days.\n\n\n## Applications with certificates that have not been rotated within 180 days\n\n| Application | Certificate Start Date |\n| :--- | :--- |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2025-03-03 |\n| [InfinityDemo - Sample](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/20f152d5-856c-449d-aa07-81f5e510dfa7) | 2021-05-03 |\n| [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | 2021-02-28 |\n| [test public client](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/79a0c604-f215-4c52-8fbe-641d08aa7937) | 2021-10-22 |\n\n\n## Service principals with certificates that have not been rotated within 180 days\n\n| Service principal | App owner tenant | Certificate Start Date |\n| :--- | :--- | :--- |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-10-26 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2021-02-17 |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/05c98ca9-d208-4d3e-ad24-911bfc3d028c/appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2023-06-11 |\n| [SPO Version](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/4c780b09-998f-4b35-b41f-b125dc9f729a/appId/2d6d9bf1-1f6e-48cf-bb02-31beec2f442e/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2023-11-17 |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-10-02 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-11-17 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2021-02-15 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-02-15 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-02-26 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-10-10 |\n\n\n",
      "TestTitle": "Application certificates must be rotated on a regular basis",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "TestDescription": "If Microsoft Defender Antivirus policies aren't properly configured and assigned to macOS devices in Intune, attackers can exploit unprotected endpoints to execute malware, disable antivirus protections, and persist in the environment. Without enforced policies, devices run outdated definitions, lack real-time protection, or have misconfigured scan schedules, increasing the risk of undetected threats and privilege escalation. This enables lateral movement across the network, credential harvesting, and data exfiltration. The absence of antivirus enforcement undermines device compliance, increases exposure of endpoints to zero-day threats, and can result in regulatory noncompliance. Attackers use these gaps to maintain persistence and evade detection, especially in environments without centralized policy enforcement.\n\nEnforcing Defender Antivirus policies ensures that macOS devices are consistently protected against malware, supports real-time threat detection, and aligns with Zero Trust by maintaining a secure and compliant endpoint posture.\n\n**Remediation action**\n\nUse Intune to configure and assign Microsoft Defender Antivirus policies for macOS devices to enforce real-time protection, maintain up-to-date definitions, and reduce exposure to malware:  \n- [Configure Intune policies to manage Microsoft Defender Antivirus](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-antivirus-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#macos)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)",
      "TestId": "24784",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo relevant Defender Antivirus policies are configured or assigned for macOS.\n\nNo relevant Defender Antivirus policies are configured or assigned for macOS.\n\n\n",
      "TestTitle": "Defender Antivirus policies protect macOS devices from malware",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "A threat actor can intercept or extract authentication tokens from memory, local storage on a legitimate device, or by inspecting network traffic. The attacker might replay those tokens to bypass authentication controls on users and devices, get unauthorized access to sensitive data, or run further attacks. Because these tokens are valid and time bound, traditional anomaly detection often fails to flag the activity, which might allow sustained access until the token expires or is revoked.\n\nToken protection, also called token binding, helps prevent token theft by making sure a token is usable only from the intended device. Token protection uses cryptography so that without the client device key, no one can use the token.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to require token protection](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21786",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nThe tenant is missing properly configured Token Protection policies.\n\n",
      "TestTitle": "User sign-in activity uses token protection",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "Allowing unrestricted external collaboration with unverified organizations can increase the risk surface area of the tenant because it allows guest accounts that might not have proper security controls. Threat actors can attempt to gain access by compromising identities in these loosely governed external tenants. Once granted guest access, they can then use legitimate collaboration pathways to infiltrate resources in your tenant and attempt to gain sensitive information. Threat actors can also exploit misconfigured permissions to escalate privileges and try different types of attacks.\n\nWithout vetting the security of organizations you collaborate with, malicious external accounts can persist undetected, exfiltrate confidential data, and inject malicious payloads. This type of exposure can weaken organizational control and enable cross-tenant attacks that bypass traditional perimeter defenses and undermine both data integrity and operational resilience. Cross-tenant settings for outbound access in Microsoft Entra provide the ability to block collaboration with unknown organizations by default, reducing the attack surface.\n\n**Remediation action**\n\n- [Cross-tenant access overview](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure cross-tenant access settings](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-default-settings)\n- [Modify outbound access settings](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21790",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nTenant has a default cross-tenant access setting outbound policy with unrestricted access.\n## [Outbound access settings - Default settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/OutboundAccessSettings.ReactView/isDefault~/true/name//id/)\n### B2B Collaboration\nUsers and groups\n- Access status: blocked\n- Applies to: Selected users and groups (0 users, 1 groups)\n\nExternal applications\n- Access status: blocked\n- Applies to: Selected external applications (2 applications)\n\n### B2B Direct Connect\nUsers and groups\n- Access status: allowed\n- Applies to: All users\n\nExternal applications\n- Access status: allowed\n- Applies to: All external applications\n\n\n",
      "TestTitle": "Outbound cross-tenant access settings are configured",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "Without properly configured and assigned Intune security baselines for Windows, devices remain vulnerable to a wide array of attack vectors that threat actors exploit to gain persistence and escalate privileges. Adversaries leverage default Windows configurations that lack hardened security settings to perform lateral movement using techniques like credential dumping, privilege escalation via unpatched vulnerabilities, and exploitation of weak authentication mechanisms. In the absence of enforced security baselines, threat actors can bypass critical security controls, maintain persistence through registry modifications, and exfiltrate sensitive data through unmonitored channels. Failing to implement a defense-in-depth strategy makes devices easier to exploit as attackers progress through the kill chain—from initial access to data exfiltration—ultimately compromising the organization’s security posture and increasing the risk of compliance violations.\n\nApplying security baselines ensures Windows devices are configured with hardened settings, reducing attack surface, enforcing defense-in-depth, and supporting Zero Trust by standardizing security controls across the environment.\n\n**Remediation action**\n\nConfigure and assign Intune security baselines to Windows devices to enforce standardized security settings and monitor compliance:\n- [Deploy security baselines to help secure Windows devices](https://learn.microsoft.com/intune/intune-service/protect/security-baselines-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-profile-for-a-security-baseline)\n- [Monitor security baseline compliance](https://learn.microsoft.com/intune/intune-service/protect/security-baselines-monitor?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "24573",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo security baselines are configured or assigned to Windows devices in Intune.\n\n\n\n",
      "TestTitle": "Security baselines are applied to Windows devices to strengthen security posture",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "TestDescription": "If policies for Microsoft Defender Antivirus aren't properly configured and assigned in Intune, threat actors can exploit unprotected endpoints to execute malware, disable antivirus protections, and persist within the environment. Without enforced antivirus policies, devices operate with outdated definitions, disabled real-time protection, or misconfigured scan schedules. These gaps allow attackers to bypass detection, escalate privileges, and move laterally across the network. The absence of antivirus enforcement undermines device compliance, increases exposure to zero-day threats, and can result in regulatory noncompliance. Attackers leverage these weaknesses to maintain persistence and evade detection, especially in environments lacking centralized policy enforcement.\n\nEnforcing Defender Antivirus policies ensures consistent protection against malware, supports real-time threat detection, and aligns with Zero Trust by maintaining a secure and compliant endpoint posture.\n\n**Remediation action**\n\nConfigure and assign Intune policies for Microsoft Defender Antivirus to enforce real-time protection, maintain up-to-date definitions, and reduce exposure to malware:\n\n- [Configure Intune policies to manage Microsoft Defender Antivirus](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-antivirus-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#windows)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n",
      "TestId": "24575",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo relevant Windows Defender Antivirus policies are configured or assigned.\n\n\n\n",
      "TestTitle": "Defender Antivirus policies protect Windows devices from malware",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "TestDescription": "If Wi-Fi profiles aren't properly configured and assigned, users can connect insecurely or fail to connect to trusted networks, exposing corporate data to interception or unauthorized access. Without centralized management, devices rely on manual configuration, increasing the risk of misconfiguration, weak authentication, and connection to rogue networks.\n\nCentrally managing Wi-Fi profiles for iOS devices in Intune ensures secure and consistent connectivity to enterprise networks. This enforces authentication and encryption standards, simplifies onboarding, and supports Zero Trust by reducing exposure to untrusted networks.\n\n**Remediation action**\n\nUse Intune to configure and assign secure Wi-Fi profiles for iOS/iPadOS devices to enforce authentication and encryption standards:\n\n- [Deploy Wi-Fi profiles to devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/wi-fi-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-profile)\n\nFor more information, see:  \n- [Review the available Wi-Fi settings for iOS and iPadOS devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/wi-fi-settings-ios?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24839",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo Enterprise Wi-Fi profile for iOS exists or none are assigned.\n\n\n## iOS WiFi Configuration Profiles\n\n| Policy Name | Wi-Fi Security Type | Status | Assignment |\n| :---------- | :----- | :--------- | :--------- |\n| [Wifi test WPAEnterprise](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesIosMenu/~/configuration) | Enterprise | ❌ Not Assigned | None |\n\n\n\n",
      "TestTitle": "Secure Wi-Fi profiles protect iOS devices from unauthorized network access",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If compliance policies for macOS devices aren't configured and assigned, threat actors can exploit unmanaged or noncompliant endpoints to gain unauthorized access to corporate resources, bypass security controls, and persist within the environment. Without enforced compliance, macOS devices can lack critical security configurations like data storage encryption, password requirements, and OS version controls. These gaps increase the risk of data leakage, privilege escalation, and lateral movement. Inconsistent device compliance weakens the organization’s security posture and makes it harder to detect and remediate threats before significant damage occurs.\n\nEnforcing compliance policies ensures macOS devices meet core security requirements and supports Zero Trust by validating device health and reducing exposure to misconfigured endpoints.\n\n**Remediation actions**\n\nCreate and assign Intune compliance policies to macOS devices to enforce organizational standards for secure access and management:  \n- [Create and assign Intune compliance policies](https://learn.microsoft.com/intune/intune-service/protect/create-compliance-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-policy)\n- [Review the macOS compliance settings you can manage with Intune](https://learn.microsoft.com/intune/intune-service/protect/compliance-policy-create-mac-os?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24542",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo compliance policy for macOS exists or none are assigned.\n\n\n## macOS Compliance Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [My macOS policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/compliance) | ❌ Not assigned | None |\n\n\n\n",
      "TestTitle": "Compliance policies protect macOS devices",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "TestDescription": "If Intune profiles for Attack Surface Reduction (ASR) rules aren't properly configured and assigned to Windows devices, threat actors can exploit unprotected endpoints to execute obfuscated scripts and invoke Win32 API calls from Office macros. These techniques are commonly used in phishing campaigns and malware delivery, allowing attackers to bypass traditional antivirus defenses and gain initial access. Once inside, attackers escalate privileges, establish persistence, and move laterally across the network. Without ASR enforcement, devices remain vulnerable to script-based attacks and macro abuse, undermining the effectiveness of Microsoft Defender and exposing sensitive data to exfiltration. This gap in endpoint protection increases the likelihood of successful compromise and reduces the organization’s ability to contain and respond to threats.\n\nEnforcing ASR rules helps block common attack techniques such as script-based execution and macro abuse, reducing the risk of initial compromise and supporting Zero Trust by hardening endpoint defenses.\n\n**Remediation action**\n\nUse Intune to deploy **Attack Surface Reduction Rules** profiles for Windows devices to block high-risk behaviors and strengthen endpoint protection:\n- [Configure Intune profiles for Attack Surface Reduction Rules](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-asr-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#devices-managed-by-intune)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n\nFor more information, see:  \n- [Attack surface reduction rules reference](https://learn.microsoft.com/defender-endpoint/attack-surface-reduction-rules-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in the Microsoft Defender documentation.",
      "TestId": "24574",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo Attack Surface Reduction policies found for Windows devices in Intune.\n\n**Required ASR Rules:**\n- Block execution of potentially obfuscated scripts\n- Block Win32 API calls from Office macros\n\n\n",
      "TestTitle": "Attack Surface Reduction rules are applied to Windows devices to prevent exploitation of vulnerable system components",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production",
      "TestSkipped": "",
      "TestDescription": "If a macOS cloud LAPS (Local Administrator Password Solution) policy is not configured and assigned in Intune, local admin accounts on enrolled macOS devices may remain unmanaged, increasing the risk of unauthorized access, privilege escalation, and lateral movement by threat actors. Without enforced LAPS policies, organizations cannot ensure that admin account credentials are rotated, unique, and securely managed, exposing sensitive systems to potential compromise.\n\n**Remediation action**\n\n- [Configure support for macOS ADE local account configuration with LAPS in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/enrollment/macos-laps)\n- [DEP onboarding setting resource type](https://learn.microsoft.com/graph/api/resources/intune-enrollment-deponboardingsetting?view=graph-rest-beta)\n\n",
      "TestId": "24561",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo macOS DEP tokens found in the tenant.\n\n\n",
      "TestTitle": "A macOS Cloud LAPS Policy is Created and Assigned",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy a Conditional Access policy to target privileged accounts and require phishing resistant credentials](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestId": "21783",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "AccessControl",
        "Authentication"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound Roles don’t have policies to enforce phishing resistant Credentials\n\n\n\n## Conditional Access Policies with phishing resistant authentication policies \n\nFound 3 phishing resistant conditional access policies.\n\n  - [MFA CA Policy](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/e589544c-0c92-432e-86ae-4e4ef103eac8)\n  - [Guest-Meferna-Woodgrove-PhishingResistantAuthStrength](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/0f0a0c1c-41b0-4c18-ae20-d02492d03737)\n  - [NewphishingCA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/3fe49849-5ab6-4717-a22d-aa42536eb560) (Disabled)\n\n\n## Privileged Roles\n\nFound 2 of 29 privileged roles protected by phishing resistant authentication.\n\n| Role Name | Phishing resistance enforced |\n| :--- | :---: |\n| Hybrid Identity Administrator | ✅ |\n| Security Administrator | ✅ |\n| Application Administrator | ❌ |\n| Application Developer | ❌ |\n| Attribute Provisioning Administrator | ❌ |\n| Attribute Provisioning Reader | ❌ |\n| Authentication Administrator | ❌ |\n| Authentication Extensibility Administrator | ❌ |\n| B2C IEF Keyset Administrator | ❌ |\n| Cloud Application Administrator | ❌ |\n| Cloud Device Administrator | ❌ |\n| Conditional Access Administrator | ❌ |\n| Directory Writers | ❌ |\n| Domain Name Administrator | ❌ |\n| ExamStudyTest | ❌ |\n| External Identity Provider Administrator | ❌ |\n| Global Administrator | ❌ |\n| Global Reader | ❌ |\n| Helpdesk Administrator | ❌ |\n| Intune Administrator | ❌ |\n| Lifecycle Workflows Administrator | ❌ |\n| Partner Tier1 Support | ❌ |\n| Partner Tier2 Support | ❌ |\n| Password Administrator | ❌ |\n| Privileged Authentication Administrator | ❌ |\n| Privileged Role Administrator | ❌ |\n| Security Operator | ❌ |\n| Security Reader | ❌ |\n| User Administrator | ❌ |\n## Authentication Strength Policies\n\nFound 2 custom phishing resistant authentication strength policies.\n\n  - [ACSC Maturity Level 3](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n  - [Phishing-resistant MFA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n\n\n",
      "TestTitle": "Privileged Microsoft Entra built-in roles are targeted with Conditional Access policies to enforce phishing-resistant methods",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Identity",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "When Microsoft Entra Connect Sync uses a user account instead of a service principal to connect to the cloud, threat actors who compromise the connector user accounts can maintain persistent access to identity synchronization infrastructure. Legacy service account authentication relies on username and a randomly generated password that can be more compromised through credential theft, or password attacks. Once compromised, threat actors can exploit these accounts to manipulate identity synchronization processes, potentially creating backdoor accounts, escalating privileges, or disrupting the entire hybrid identity infrastructure. Service principal authentication with certificate-based credentials provides stronger authentication mechanisms, making it significantly harder for threat actors to establish persistence in the identity infrastructure.\n\n**Remediation action**\n\nConfigure application identity for Entra Connect:\n- [Microsoft Entra Connect: Accounts and permissions](https://learn.microsoft.com/entra/identity/hybrid/connect/reference-connect-accounts-permissions)\n\nRemove legacy Directory Synchronization Accounts:\n- [Directory Synchronization Accounts](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference#directory-synchronization-accounts)\n\n",
      "TestId": "24570",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nFound enabled user accounts with Microsoft Entra Connect connector permissions.\n\n**Hybrid Identity Status**: True\n\n\n## Identities for Entra Connect Sync\n\n| Directory Synchronization Accounts Role Member | User Principal Name | Enabled | User Type |\n| :--------------------------------------------- | :------------------ | :------ | :-------- |\n| [On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f) | Sync_DC1_d8475d81663f@pora.onmicrosoft.com | ❌ Yes | Member |\n\n\n\n \n \n",
      "TestTitle": "Entra Connect Sync is configured with Service Principal Credentials",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "App instance property lock prevents changes to sensitive properties of a multitenant application after the application is provisioned in another tenant. Without a lock, critical properties such as application credentials can be maliciously or unintentionally modified, causing disruptions, increased risk, unauthorized access, or privilege escalations.\n\n**Remediation action**\nEnable the app instance property lock for all multitenant applications and specify the properties to lock.\n- [Configure an app instance lock](https://learn.microsoft.com/en-us/entra/identity-platform/howto-configure-app-instance-property-locks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-an-app-instance-lock)   \n",
      "TestId": "21777",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound multi-tenant apps without app instance property lock configured.\n\n\n## Multi-tenant applications and their App Instance Property Lock setting\n\n\n| Application | Application ID | App Instance Property Lock configured |\n| :---------- | :------------- | :------------------------------------ |\n| [AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/2e311a1d-f5c0-41c6-b866-77af3289871e/isMSAApp~/false) | 2e311a1d-f5c0-41c6-b866-77af3289871e | False |\n| [Adatum Demo App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/d2934d2a-3fbc-44a1-bda0-13e8d8a73b15/isMSAApp~/false) | d2934d2a-3fbc-44a1-bda0-13e8d8a73b15 | False |\n| [EAM Provider](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/f8642471-b7d7-4432-9527-776071e69b8b/isMSAApp~/false) | f8642471-b7d7-4432-9527-776071e69b8b | True |\n| [ExtProperties](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/61a54643-d4b6-471d-bd7c-a55586155dfc/isMSAApp~/false) | 61a54643-d4b6-471d-bd7c-a55586155dfc | False |\n| [Graph Filter](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975/isMSAApp~/false) | c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975 | False |\n| [My Properties Bag](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/303b4699-5b62-451c-b951-7e10b01d9b6d/isMSAApp~/false) | 303b4699-5b62-451c-b951-7e10b01d9b6d | False |\n| [Tenant Extension Properties App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/7db77c2b-30c1-4379-838f-8767c1e0d619/isMSAApp~/false) | 7db77c2b-30c1-4379-838f-8767c1e0d619 | False |\n| [Tenant Extension Properties App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/271b9db4-6e96-430c-808f-973a776adeaf/isMSAApp~/false) | 271b9db4-6e96-430c-808f-973a776adeaf | False |\n| [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/e7dfcbb6-fe86-44a2-b512-8d361dcc3d30/isMSAApp~/false) | e7dfcbb6-fe86-44a2-b512-8d361dcc3d30 | True |\n| [da-typespec-todo-aad](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/9358444a-41ec-4a93-915a-4970b3f33738/isMSAApp~/false) | 9358444a-41ec-4a93-915a-4970b3f33738 | False |\n| [graph-developer-proxy-samples](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/3658d9e9-dc87-4345-b59b-184febcf6781/isMSAApp~/false) | 3658d9e9-dc87-4345-b59b-184febcf6781 | False |\n| [idpowerelectron](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/909fff82-5b0a-4ce5-b66d-db58ee1a925d/isMSAApp~/false) | 909fff82-5b0a-4ce5-b66d-db58ee1a925d | True |\n| [test-mta](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/5ebc726d-e583-4822-b111-95ee05503c7e/isMSAApp~/false) | 5ebc726d-e583-4822-b111-95ee05503c7e | True |\n\n\n\n",
      "TestTitle": "App instance property lock is configured for all multitenant applications",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Accelerate response and remediation",
      "TestSkipped": "",
      "TestDescription": "When high-risk sign-ins are not properly restricted through Conditional Access policies, organizations expose themselves to security vulnerabilities. Threat actors can exploit these gaps for initial access through compromised credentials, credential stuffing attacks, or anomalous sign-in patterns that Microsoft Entra ID Protection identifies as risky behaviors. Without appropriate restrictions, threat actors who successfully authenticate during high-risk scenarios can perform privilege escalation by misusing the authenticated session to access sensitive resources, modify security configurations, or conduct reconnaissance activities within the environment. Once threat actors establish access through uncontrolled high-risk sign-ins, they can achieve persistence by creating additional accounts, installing backdoors, or modifying authentication policies to maintain long-term access to the organization's resources. The unrestricted access enables threat actors to conduct lateral movement across systems and applications using the authenticated session, potentially accessing sensitive data stores, administrative interfaces, or critical business applications. Finally, threat actors achieve impact through data exfiltration, or compromise business-critical systems while maintaining plausible deniability by exploiting the fact that their risky authentication was not properly challenged or blocked.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to require MFA for elevated sign-in risk](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-risk-based-sign-in?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21799",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nSome high-risk sign-in attempts are not adequately mitigated by Conditional Access policies.\n\n",
      "TestTitle": "Restrict high risk sign-ins",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Protect identities and secrets",
      "TestSfiPillar": "",
      "TestSkipped": "",
      "TestDescription": "Without a properly configured and assigned Local Users and Groups policy in Intune, threat actors can exploit unmanaged or misconfigured local accounts on Windows devices. This can lead to unauthorized privilege escalation, persistence, and lateral movement within the environment. If local administrator accounts aren't controlled, attackers can create hidden accounts or elevate privileges, bypassing compliance and security controls. This gap increases the risk of data exfiltration, ransomware deployment, and regulatory noncompliance.\n\nEnsuring that Local Users and Groups policies are enforced on managed Windows devices, by using account protection profiles, is critical to maintaining a secure and compliant device fleet.\n\n\n**Remediation action**\n\nConfigure and deploy a **Local user group membership** profile from Intune account protection policy to restrict and manage local account usage on Windows devices:  \n- Create an [Account protection policy for endpoint security in Intune](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-account-protection-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#account-protection-profiles)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n",
      "TestId": "24564",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo Local Users and Groups policy is configured or assigned.\n\n\n\n",
      "TestTitle": "Local account usage on Windows is restricted to reduce unauthorized access",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Credential management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When weak authentication methods like SMS and voice calls remain enabled in Microsoft Entra ID, threat actors can exploit these vulnerabilities through multiple attack vectors. Initially, attackers often conduct reconnaissance to identify organizations using these weaker authentication methods through social engineering or technical scanning. Then they can execute initial access through credential stuffing attacks, password spraying, or phishing campaigns targeting user credentials.\n\nOnce basic credentials are compromised, threat actors use these weaknesses in SMS and voice-based authentication. SMS messages can be intercepted through SIM swapping attacks, SS7 network vulnerabilities, or malware on mobile devices, while voice calls are susceptible to voice phishing (vishing) and call forwarding manipulation. With these weak second factors bypassed, attackers achieve persistence by registering their own authentication methods. Compromised accounts can be used to target higher-privileged users through internal phishing or social engineering, allowing attackers to escalate privileges within the organization. Finally, threat actors achieve their objectives through data exfiltration, lateral movement to critical systems, or deployment of other malicious tools, all while maintaining stealth by using legitimate authentication pathways that appear normal in security logs. \n\n**Remediation action**\n\n- [Deploy authentication method registration campaigns to encourage stronger methods](https://learn.microsoft.com/graph/api/authenticationmethodspolicy-update?view=graph-rest-beta&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Disable authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Disable phone-based methods in legacy MFA settings](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-mfa-mfasettings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policies using authentication strength](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strength-how-it-works?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21804",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound weak authentication methods that are still enabled.\n\n## Weak authentication methods\n| Method ID | Is method weak? | State |\n| :-------- | :-------------- | :---- |\n| Sms | Yes | enabled |\n| Voice | Yes | disabled |\n\n\n",
      "TestTitle": "SMS and Voice Call authentication methods are disabled",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "",
      "TestSkipped": "",
      "TestDescription": "**Remediation action**\n\n- [](https://learn.microsoft.com/intune/intune-service/?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24870",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo Enterprise Wi-Fi profile for macOS exists or none are assigned.\n\n\n\n",
      "TestTitle": "Secure Wi-Fi profiles are configured to protect macOS connectivity and devices",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When security key attestation is not enforced, threat actors can exploit weak or compromised authentication hardware to establish persistent presence within organizational environments. Without attestation validation, malicious actors can register unauthorized or counterfeit FIDO2 security keys that bypass hardware-backed security controls, enabling them to perform credential stuffing attacks using fabricated authenticators that mimic legitimate security keys. This initial access allows threat actors to escalate privileges by leveraging the trusted nature of hardware authentication methods, then move laterally through the environment by registering additional compromised security keys on high-privilege accounts. The lack of attestation enforcement creates a pathway for threat actors to establish command and control through persistent hardware-based authentication methods, ultimately leading to data exfiltration or system compromise while maintaining the appearance of legitimate hardware-secured authentication throughout the attack chain.\n\n**Remediation action**\n- [Enable attestation enforcement through the Authentication methods policy configuration.](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-enable-passkey-fido2#enable-passkey-fido2-authentication-method)\n- [Configure key restrictions for vendor requirements](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-fido2-hardware-vendor)  \n",
      "TestId": "21840",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nSecurity key attestation is not enforced, allowing unverified or potentially compromised security keys to be registered.\n## [Security key attestation policy details](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConfigureAuthMethodsBlade/authMethod~/%7B%22%40odata.type%22%3A%22%23microsoft.graph.fido2AuthenticationMethodConfiguration%22%2C%22id%22%3A%22Fido2%22%2C%22state%22%3A%22enabled%22%2C%22isSelfServiceRegistrationAllowed%22%3Atrue%2C%22isAttestationEnforced%22%3Afalse%2C%22excludeTargets%22%3A%5B%7B%22id%22%3A%2243b7bc87-77eb-4263-abad-e3c2478f0a35%22%2C%22targetType%22%3A%22group%22%2C%22displayName%22%3A%22eam-block-user%22%7D%5D%2C%22keyRestrictions%22%3A%7B%22isEnforced%22%3Afalse%2C%22enforcementType%22%3A%22allow%22%2C%22aaGuids%22%3A%5B%22de1e552d-db1d-4423-a619-566b625cdc84%22%2C%2290a3ccdf-635c-4729-a248-9b709135078f%22%2C%2277010bd7-212a-4fc9-b236-d2ca5e9d4084%22%2C%22b6ede29c-3772-412c-8a78-539c1f4c62d2%22%2C%22ee041bce-25e5-4cdb-8f86-897fd6418464%22%2C%2273bb0cd4-e502-49b8-9c6f-b59445bf720b%22%5D%7D%2C%22includeTargets%40odata.context%22%3A%22https%3A%2F%2Fgraph.microsoft.com%2Fbeta%2F%24metadata%23policies%2FauthenticationMethodsPolicy%2FauthenticationMethodConfigurations('Fido2')%2Fmicrosoft.graph.fido2AuthenticationMethodConfiguration%2FincludeTargets%22%2C%22includeTargets%22%3A%5B%7B%22targetType%22%3A%22group%22%2C%22id%22%3A%22all_users%22%2C%22isRegistrationRequired%22%3Afalse%7D%5D%2C%22enabled%22%3Atrue%2C%22target%22%3A%22All%20users%2C%20excluding%201%20group%22%2C%22isAllUsers%22%3Atrue%2C%22voiceDisabled%22%3Afalse%7D/canModify~/true/voiceDisabled~/false/userMemberIds~/%5B%5D/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/isCiamTenant~/false/isCiamTrialTenant~/false)\n- **Enforce attestation** : False ❌\n- **Key restriction policy** :\n  - **Enforce key restrictions** : False\n  - **Restrict specific keys** : Allow\n  - **AAGUID** :\n    - de1e552d-db1d-4423-a619-566b625cdc84\n    - 90a3ccdf-635c-4729-a248-9b709135078f\n    - 77010bd7-212a-4fc9-b236-d2ca5e9d4084\n    - b6ede29c-3772-412c-8a78-539c1f4c62d2\n    - ee041bce-25e5-4cdb-8f86-897fd6418464\n    - 73bb0cd4-e502-49b8-9c6f-b59445bf720b\n\n",
      "TestTitle": "Security key attestation is enforced",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Credential management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When on-premises password protection isn’t enabled or enforced, threat actors can use low-and-slow password spray with common variants, such as season+year+symbol or local terms, to gain initial access to Active Directory Domain Services accounts. Domain Controllers (DCs) can accept weak passwords when either of the following statements are true:\n\n- Microsoft Entra Password Protection DC agent isn't installed\n- The password protection tenant setting is disabled or in audit-only mode\n\nWith valid on-premises credentials, attackers laterally move by reusing passwords across endpoints, escalate to domain admin through local admin reuse or service accounts, and persist by adding backdoors, while weak or disabled enforcement produces fewer blocking events and predictable signals. Microsoft’s design requires a proxy that brokers policy from Microsoft Entra ID and a DC agent that enforces the combined global and tenant custom banned lists on password change/reset; consistent enforcement requires DC agent coverage on all DCs in a domain and using Enforced mode after audit evaluation.\n\n**Remediation action**\n\n- [Deploy Microsoft Entra password protection](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-password-ban-bad-on-premises-deploy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21847",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\n\n❌ **Fail**: Password protection for on-premises is not set to 'Enforce' mode.\n\n## Password Protection Settings\n\n| Setting | Value |\n| :---- | :---- |\n| Password Protection for Active Directory Domain Services | ✅ Enabled |\n| Enabled Mode (Audit/Enforce) | ❌ Audit |\n\n\n",
      "TestTitle": "Password protection for on-premises is enabled",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "If policies for Windows Hello for Business (WHfB) aren't configured and assigned to all users and devices, threat actors can exploit weak authentication mechanisms—like passwords—to gain unauthorized access. This can lead to credential theft, privilege escalation, and lateral movement within the environment. Without strong, policy-driven authentication like WHfB, attackers can compromise devices and accounts, increasing the risk of widespread impact.\n\nEnforcing WHfB disrupts this attack chain by requiring strong, multifactor authentication, which helps reduce the risk of credential-based attacks and unauthorized access.\n\n**Remediation action**\n\nDeploy Windows Hello for Business in Intune to enforce strong, multifactor authentication:  \n- [Configure a tenant-wide Windows Hello for Business policy](https://learn.microsoft.com/intune/intune-service/protect/windows-hello?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-windows-hello-for-business-policy-for-device-enrollment) that applies at the time a device enrolls with Intune.\n- After enrollment, [configure Account protection profiles](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-account-protection-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#account-protection-profiles) and [assign](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups) different configurations for Windows Hello for Business to different groups of users and devices. ",
      "TestId": "24551",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nWindows Hello for Business policy is not assigned or not enforced.\n\n\n## Windows Hello for Business Policy is Configured and Assigned\n\nWindows Hello For Business ([Tenant Wide Setting](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesEnrollmentMenu/~/windowsEnrollment) ): ❓ Not Configured.\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [Windows Hello for Business](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ❌ Not Assigned | None |\n\n\n\n",
      "TestTitle": "Authentication on Windows uses Windows Hello for Business",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without a properly configured and assigned BitLocker policy in Intune, threat actors can exploit unencrypted Windows devices to gain unauthorized access to sensitive corporate data. Devices that lack enforced encryption are vulnerable to physical attacks, like disk removal or booting from external media, allowing attackers to bypass operating system security controls. These attacks can result in data exfiltration, credential theft, and further lateral movement within the environment.\n\nEnforcing BitLocker across managed Windows devices is critical for compliance with data protection regulations and for reducing the risk of data breaches.\n\n**Remediation action**\n\nUse Intune to enforce BitLocker encryption and monitor compliance across all managed Windows devices:  \n- [Create a BitLocker policy for Windows devices in Intune](https://learn.microsoft.com/intune/intune-service/protect/encrypt-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-and-deploy-policy)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n- [Monitor device encryption with Intune](https://learn.microsoft.com/intune/intune-service/protect/encryption-monitor?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "24550",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo Windows BitLocker policy is configured or assigned.\n\n\n\n",
      "TestTitle": "Data on Windows is protected by BitLocker encryption",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Monitoring",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "TestDescription": "Organizations without proper activation alerts for highly privileged roles lack visibility into when users access these critical permissions. Threat actors can exploit this monitoring gap to perform privilege escalation by activating highly privileged roles without detection, then establish persistence through admin account creation or security policy modifications. The absence of real-time alerts enables attackers to conduct lateral movement, modify audit configurations, and disable security controls without triggering immediate response procedures.\n\n**Remediation action**\n\n- [Configure Microsoft Entra role settings in Privileged Identity Management](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#require-justification-on-activation)\n",
      "TestId": "21818",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nRole notifications are not properly configured.\n\nNote: To save time, this check stops when it finds the first role that does not have notifications. After fixing this role and all other roles, we recommend running the check again to verify.\n\n\n## Notifications for high privileged roles\n\n\n| Role Name | Notification Scenario | Notification Type | Default Recipients Enabled | Additional Recipients |\n| :-------- | :-------------------- | :---------------- | :------------------------- | :-------------------- |\n| Application Administrator | Send notifications when members are assigned as eligible to this role | Role assignment alert | True | aleksandar@elapora.com |\n| Application Administrator | Send notifications when members are assigned as eligible to this role | Notification to the assigned user (assignee) | True | merill@elapora.com |\n| Application Administrator | Send notifications when members are assigned as eligible to this role | Request to approve a role assignment renewal/extension | True |  |\n\n\n\n",
      "TestTitle": "Privileged role activations have monitoring and alerting configured",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "External collaboration",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestSkipped": "",
      "TestDescription": "When workload identities operate without network-based Conditional Access restrictions, threat actors can compromise service principal credentials through various methods, such as exposed secrets in code repositories or intercepted authentication tokens. The threat actors can then use these credentials from any location globally. This unrestricted access enables threat actors to perform reconnaissance activities, enumerate resources, and map the tenant's infrastructure while appearing legitimate. Once the threat actor is established within the environment, they can move laterally between services, access sensitive data stores, and potentially escalate privileges by exploiting overly permissive service-to-service permissions. The lack of network restrictions makes it impossible to detect anomalous access patterns based on location. This gap allows threat actors to maintain persistent access and exfiltrate data over extended periods without triggering security alerts that would normally flag connections from unexpected networks or geographic locations. \n\n**Remediation action**\n\n- [Configure Conditional Access for workload identities](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create named locations](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Follow best practices for securing workload identities](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21884",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nFound workload identities with credentials that lack network-based access restrictions.\n\n## Unprotected service principals\n| Service principal display name | Credential type | Applied policy names | Location restrictions |\n|-------------------------------|-----------------|---------------------|---------------------|\n| [RemixTest](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0531b659-1c33-4de0-92c8-46a226fdea92/appId/d4588485-154e-4b32-935f-31ceaf993cdc) |  | None | None |\n| [Message Center](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/158f6ef9-a65d-45f2-bdf0-b0a1db70ebd4/appId/83f76a08-fa60-48e6-9cb5-fd8ced5ae314) |  | None | None |\n| [Lokka](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1abc3899-a5df-40ab-8aa7-95d31edd4c01/appId/f581405a-9e57-4e81-91f1-40cd62f7595e) |  | None | None |\n| [Atlassian - Jira](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2425e515-5720-4071-9fae-fd50f153c0aa/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c) |  | None | None |\n| [Graph PowerShell - Privileged Perms](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2811ef1d-8be1-4f71-8cd4-ae05adfb7ba3/appId/c5338ce0-3e9e-4895-8f49-5e176836a348) |  | None | None |\n| [Trello](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3d6c91cf-d48f-4272-ac4c-9f989bbec779/appId/d77611ee-5051-4383-9af3-5ba3627306a7) |  | None | None |\n| [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/427b14ca-13b3-4911-b67e-9ff626614781/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) |  | None | None |\n| [SharePoint On-Prem App Proxy](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/53c7bdb1-cae2-43b0-9e2e-d8605395ceec/appId/19a70df3-cddf-48c7-be44-97b25b9857f1) |  | None | None |\n| [WebApplication4](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5bc56e47-7a8a-4e71-b25f-8c4e373f40a6/appId/b2d1f868-27ee-4ecd-ae81-0ee96b028605) |  | None | None |\n| [test public client](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5e80ea33-31fa-49fd-9a94-61894bd1a6c9/appId/79a0c604-f215-4c52-8fbe-641d08aa7937) |  | None | None |\n| [WingtipToys App](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/606738dd-7f66-43ce-9959-f411ced435fd/appId/56a89db1-6ed2-4171-88f6-b4f7597dbce3) |  | None | None |\n| [SharePoint Version App](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/666a58ef-c3e5-4efc-828a-2ab3c0120677/appId/2bb68591-782c-4c64-9415-bdf9414ae400) |  | None | None |\n| [M365PronounKit](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6bf7c616-88e8-4f7c-bdad-452e561fa777/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) |  | None | None |\n| [PnPPowerShell](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6d2e8d37-82b8-41e7-aa95-443a7401e8b8/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) |  | None | None |\n| [entra-docs-email github DO NOT DELETE](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7a94aec7-a5e3-48dd-b20f-3db74d689434/appId/ae06b71a-a0aa-4211-b846-fd74f25ccd45) |  | None | None |\n| [Entry Kiosk](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/83adcc80-3a35-4fdc-9c5b-1f6b9061508e/appId/b903f17a-87b0-460b-9978-962c812e4f98) |  | None | None |\n| [testuserread](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/89bd9c7a-0c81-4a0a-9153-ff7cd0b81352/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) |  | None | None |\n| [sptest1](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/89bfd334-91cb-41d9-8b9f-76420049798e/appId/022dac2c-8763-4a45-bc41-34cf58e8e35d) |  | None | None |\n| [GraphPermissionApp](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a15dc834-08ce-4fd8-85de-3729fff8e34f/appId/d36fe320-bc28-40c8-a141-a512d65d112c) |  | None | None |\n| [Postman](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/aa64efdb-2d05-4c81-a9e5-80294bf0afac/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) |  | None | None |\n| [WebApplication3_20210211261232](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b6f85bf9-cf44-4260-acc6-1a645b0c954f/appId/ac49e193-bd5f-40fe-b4ff-e62136419388) |  | None | None |\n| [InfinityDemo](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bac0ba57-1876-448e-96bf-6f0481c99fda/appId/fef811e1-2354-43b0-961b-248fe15e737d) |  | None | None |\n| [InfinityDemo - Sample](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bce9a7f6-34f9-422d-b9ca-08970846b1f8/appId/20f152d5-856c-449d-aa07-81f5e510dfa7) |  | None | None |\n| [aadgraphmggraph](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d091eae9-b200-4625-83af-ccf62ced703a/appId/24b66505-1142-452f-9472-2ecbb37deac1) |  | None | None |\n| [Mailbox Migration Account](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d22f071d-e8d3-41fc-a516-b29753cdd1f6/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) |  | None | None |\n| [test](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d4c517a0-9451-4dc5-8fd3-9d8521c91ccc/appId/4f50c653-dae4-44e7-ae2e-a081cce1f830) |  | None | None |\n| [WebApplication3](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dab46eb8-90cf-4c0b-8dfd-3a589617ea34/appId/bcdb1ed5-9470-41e6-821b-1fc42ae94cfb) |  | None | None |\n| [Maester DevOps Account - GitHub - Secret (demo)](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e31cd01e-afaf-4cc3-8d15-d3f9f7eb61e8/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) |  | None | None |\n| [MyTestForBlock](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e9fca357-cccd-4ec4-840f-7482f6f02818/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) |  | None | None |\n| [Automation](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f79df990-9ad2-4142-b5fd-8945ff334da3/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | Password | None | None |\n| [P2P Server](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/05c98ca9-d208-4d3e-ad24-911bfc3d028c/appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06) | Password, Certificate | None | None |\n| [Salesforce](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9) | Password, Certificate | None | None |\n| [SumoLogic](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1) | Password, Certificate | None | None |\n| [test](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa) | Password, Certificate | None | None |\n| [Madura AWS Account](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c) | Password, Certificate | None | None |\n| [Dropbox Business](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664) | Password, Certificate | None | None |\n| [Madura- Genesys Cloud for Azure](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/84dc13ec-5754-4745-90f9-5cc92a5ded28/appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b) | Password, Certificate | None | None |\n| [ServiceNow](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94) | Password, Certificate | None | None |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ba63bb52-182c-4ec6-9cc8-ad2287cf51ed/appId/76249b01-8747-4db4-843f-6478d5b32b14) | Password, Certificate | None | None |\n| [Saml test entity id](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52) | Password, Certificate | None | None |\n| [AWS Single-Account Access](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987) | Password, Certificate | None | None |\n| [claimtest](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35) | Password, Certificate | None | None |\n",
      "TestTitle": "Conditional Access policies for workload identities based on known networks are configured",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "Unmaintained or orphaned redirect URIs in app registrations create significant security vulnerabilities when they reference domains that no longer point to active resources. Threat actors can exploit these \"dangling\" DNS entries by provisioning resources at abandoned domains, effectively taking control of redirect endpoints. This vulnerability enables attackers to intercept authentication tokens and credentials during OAuth 2.0 flows, which can lead to unauthorized access, session hijacking, and potential broader organizational compromise.\n\n**Remediation action**\n\n- [Redirect URI (reply URL) outline and restrictions](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21888",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe Redirect URIs |\n| :--- | :--- | :--- |\n|  | [Contoso Access Verifier](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/41d3b041-9859-4830-8feb-72ffd7afad65/appId/a6af3433-bc44-4d27-9b35-81d10fd51315/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `https://demoeam2025.blob.core.windows.net/data/index.html` |  |\n|  | [My nice app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d41cfc13-11d1-4f93-835a-88e729725564/appId/2946f286-2b59-4f29-876c-0ed8bbe1c482/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `https://mysalmon.azurewebsites.net/login.saml` |  |\n|  | [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `https://dev92989.service-now.com/navpage.do` |  |\n|  | [aad-extensions-app. Do not modify. Used by AAD for storing user data.](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/b5277031-31cb-4a88-b5a1-316878166f55/appId/d211b2a1-0c5e-4be8-a40a-46033a0b6df2/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `https://pora.onmicrosoft.com/cpimextensions` |  |\n|  | [saml test app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/daa6074c-db6f-4bdc-a41b-bc0052c536a5/appId/c266d677-a5f8-47bc-9f0a-1b6fbe0bddad/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `https://appclaims.azurewebsites.net/signin-saml`, `https://appclaims.azurewebsites.net/signin-oidc` |  |\n\n\n",
      "TestTitle": "App registrations must not have dangling or abandoned domain redirect URIs",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy a Conditional Access policy to target privileged accounts and require phishing resistant credentials](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestId": "21782",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Credential"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound privileged users that have not yet registered phishing resistant authentication methods\n\n## Privileged users\n\nFound privileged users that have not registered phishing resistant authentication methods.\n\nUser | Role Name | Phishing resistant method registered |\n| :--- | :--- | :---: |\n|[Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true)| Application Administrator | ❌ |\n|[chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0b37813c-ae19-4399-982f-16587f17f9c0/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true)| User Administrator | ❌ |\n|[Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true)| Application Administrator | ❌ |\n|[Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true)| Application Administrator | ❌ |\n|[On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f/hidePreviewBanner~/true)| Directory Synchronization Accounts | ❌ |\n|[Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1433571b-3d7c-4a56-a9cc-67580848bc73/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true)| Application Administrator | ❌ |\n|[sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/96252680-04a0-4bec-b5f7-a552c8150525/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/96252680-04a0-4bec-b5f7-a552c8150525/hidePreviewBanner~/true)| Application Administrator | ❌ |\n|[sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/96252680-04a0-4bec-b5f7-a552c8150525/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a85798bd-652b-4eb9-ba90-3ee882df0179/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Attribute Assignment Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Attribute Definition Administrator | ✅ |\n|[perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true)| Global Reader | ✅ |\n|[perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true)| Application Administrator | ✅ |\n\n\n",
      "TestTitle": "Privileged accounts have phishing-resistant methods registered",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Threat actors target privileged accounts because they have access to the data and resources they want. This might include more access to your Microsoft Entra tenant, data in Microsoft SharePoint, or the ability to establish long-term persistence. Without a just-in-time (JIT) activation model, administrative privileges remain continuously exposed, providing attackers with an extended window to operate undetected. Just-in-time access mitigates risk by enforcing time-limited privilege activation with extra controls such as approvals, justification, and Conditional Access policy, ensuring that high-risk permissions are granted only when needed and for a limited duration. This restriction minimizes the attack surface, disrupts lateral movement, and forces adversaries to trigger actions that can be specially monitored and denied when not expected. Without just-in-time access, compromised admin accounts grant indefinite control, letting attackers disable security controls, erase logs, and maintain stealth, amplifying the impact of a compromise.\n\nUse Microsoft Entra Privileged Identity Management (PIM) to provide time-bound just-in-time access to privileged role assignments. Use access reviews in Microsoft Entra ID Governance to regularly review privileged access to ensure continued need.\n\n**Remediation action**\n\n- [Start using Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-getting-started?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create an access review of Azure resource and Microsoft Entra roles in PIM](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-create-roles-and-resource-roles-review?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21815",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPrivileged users with permanent role assignments were found.\n\n\n## Privileged users with permanent role assignments\n\n\n| User | UPN | Role Name | Assignment Type |\n| :--- | :-- | :-------- | :-------------- |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | chukka.p@elapora.com | Global Reader | Permanent |\n| [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | ann@elapora.com | Global Administrator | Permanent |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | sandeep.p@elapora.com | Global Administrator | Permanent |\n| [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | merill@elapora.com | Global Administrator | Permanent |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | chukka.p@elapora.com | Global Administrator | Permanent |\n| [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | tyler@elapora.com | Global Administrator | Permanent |\n| [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | manoj.p@elapora.com | Application Administrator | Permanent |\n| [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | gael@elapora.com | Global Administrator | Permanent |\n| [sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | sushant.p@elapora.com | Global Reader | Permanent |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | chukka.p@elapora.com | Application Administrator | Permanent |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | sandeep.p@elapora.com | Global Reader | Permanent |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | Komal.p@elapora.com | Global Administrator | Permanent |\n| [Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | GradyA@elapora.com | User Administrator | Permanent |\n| [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | emergency@elapora.com | Global Administrator | Permanent |\n| [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | aleksandar@elapora.com | Global Administrator | Permanent |\n| [sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | sushant.p@elapora.com | Application Administrator | Permanent |\n| [Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | ravi.kalwani@elapora.com | Global Administrator | Permanent |\n| [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | joshua@elapora.com | Global Administrator | Permanent |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | sandeep.p@elapora.com | Application Administrator | Permanent |\n| [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | damien.bowden@elapora.com | Global Administrator | Permanent |\n| [PimLevel](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) |  | Application Administrator | Permanent |\n| [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | manoj.p@elapora.com | Global Reader | Permanent |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | Komal.p@elapora.com | Application Administrator | Permanent |\n| [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | manoj.p@elapora.com | Global Administrator | Permanent |\n| [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | merillf_gmail.com#EXT#@pora.onmicrosoft.com | Global Administrator | Permanent |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | perennial_ash@elapora.com | Application Administrator | Permanent |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | Komal.p@elapora.com | Global Reader | Permanent |\n| [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) |  | Global Administrator | Permanent |\n| [sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | sushant.p@elapora.com | Global Administrator | Permanent |\n| [Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | varsha.mane@elapora.com | Global Administrator | Permanent |\n| [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | madura@elapora.com | Global Administrator | Permanent |\n| [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) |  | Application Administrator | Permanent |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | perennial_ash@elapora.com | Global Reader | Permanent |\n| [elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) |  | Global Administrator | Permanent |\n\n\n\n",
      "TestTitle": "All privileged role assignments are activated just in time and not permanently active",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Applications that use client secrets might store them in configuration files, hardcode them in scripts, or risk their exposure in other ways. The complexities of secret management make client secrets susceptible to leaks and attractive to attackers. Client secrets, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's client secret, they can escalate their privileges within the system, leading to broader access and control, depending on the permissions of the application.\n\nApplications and service principals that have permissions for Microsoft Graph APIs or other APIs have a higher risk because an attacker can potentially exploit these additional permissions.\n\n**Remediation action**\n\n- [Move applications away from shared secrets to managed identities and adopt more secure practices](https://learn.microsoft.com/entra/identity/enterprise-apps/migrate-applications-from-secrets?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n   - Use managed identities for Azure resources\n   - Deploy Conditional Access policies for workload identities\n   - Implement secret scanning\n   - Deploy application authentication policies to enforce secure authentication practices\n   - Create a least-privileged custom role to rotate application credentials\n   - Ensure you have a process to triage and monitor applications\n",
      "TestId": "21772",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Application"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound 31 applications and 14 service principals with client secrets configured.\n\n\n## Applications with client secrets\n\n| Application | Secret expiry |\n| :--- | :--- |\n| [AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2e311a1d-f5c0-41c6-b866-77af3289871e) | 2024-02-11 |\n| [Atlassian - Jira](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c) | 2026-03-16 |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2325-01-01 |\n| [Entry Kiosk](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b903f17a-87b0-460b-9978-962c812e4f98) | 2021-11-25 |\n| [Graph Filter](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975) | 2024-09-16 |\n| [Graph PowerShell - Privileged Perms](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/c5338ce0-3e9e-4895-8f49-5e176836a348) | 2024-05-15 |\n| [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d36fe320-bc28-40c8-a141-a512d65d112c) | 2026-09-02 |\n| [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/fef811e1-2354-43b0-961b-248fe15e737d) | 2022-11-02 |\n| [Lokka](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/f581405a-9e57-4e81-91f1-40cd62f7595e) | 2026-10-01 |\n| [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | 2022-03-29 |\n| [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) | 2026-02-20 |\n| [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | 2022-08-19 |\n| [Message Center](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/83f76a08-fa60-48e6-9cb5-fd8ced5ae314) | 2026-02-17 |\n| [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) | 2124-02-21 |\n| [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) | 2025-07-06 |\n| [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | 2022-03-29 |\n| [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) | 2023-10-16 |\n| [RemixTest](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d4588485-154e-4b32-935f-31ceaf993cdc) | 2024-06-24 |\n| [SharePoint On-Prem App Proxy](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/19a70df3-cddf-48c7-be44-97b25b9857f1) | 2025-12-12 |\n| [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | 2024-05-15 |\n| [Trello](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d77611ee-5051-4383-9af3-5ba3627306a7) | 2022-08-16 |\n| [WebApplication3](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/bcdb1ed5-9470-41e6-821b-1fc42ae94cfb) | 2022-11-02 |\n| [WebApplication3_20210211261232](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/ac49e193-bd5f-40fe-b4ff-e62136419388) | 2022-11-02 |\n| [WebApplication4](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b2d1f868-27ee-4ecd-ae81-0ee96b028605) | 2022-04-03 |\n| [WingtipToys App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/56a89db1-6ed2-4171-88f6-b4f7597dbce3) | 2025-11-27 |\n| [aadgraphmggraph](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/24b66505-1142-452f-9472-2ecbb37deac1) | 2022-11-26 |\n| [da-typespec-todo-aad](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/9358444a-41ec-4a93-915a-4970b3f33738) | 2026-06-04 |\n| [entra-docs-email github DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/ae06b71a-a0aa-4211-b846-fd74f25ccd45) | 2027-07-14 |\n| [sptest1](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/022dac2c-8763-4a45-bc41-34cf58e8e35d) | 2026-08-02 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/4f50c653-dae4-44e7-ae2e-a081cce1f830) | 2023-02-25 |\n| [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) | 2025-09-03 |\n\n\n## Service Principals with client secrets\n\n| Service principal | App owner tenant | Secret expiry |\n| :--- | :--- | :--- |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/76249b01-8747-4db4-843f-6478d5b32b14/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-07-30 |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-10-26 |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/dc7d83b5-d38b-4488-8952-7abf02e71590/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2027-03-03 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-02-17 |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-01-07 |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-07-30 |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-06-11 |\n| [SPO Version](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/2d6d9bf1-1f6e-48cf-bb02-31beec2f442e/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-11-17 |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-10-02 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-11-17 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-02-15 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2027-02-15 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-02-26 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-10-10 |\n\n\n",
      "TestTitle": "Applications don't have client secrets configured",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "OAuth applications configured with URLs that include wildcards, or URL shorteners increase the attack surface for threat actors. Insecure redirect URIs (reply URLs) might allow adversaries to manipulate authentication requests, hijack authorization codes, and intercept tokens by directing users to attacker-controlled endpoints. Wildcard entries expand the risk by permitting unintended domains to process authentication responses, while shortener URLs might facilitate phishing and token theft in uncontrolled environments. \n\nWithout strict validation of redirect URIs, attackers can bypass security controls, impersonate legitimate applications, and escalate their privileges. This misconfiguration enables persistence, unauthorized access, and lateral movement, as adversaries exploit weak OAuth enforcement to infiltrate protected resources undetected.\n\n**Remediation action**\n\n- [Check the redirect URIs for your application registrations.](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) Make sure the redirect URIs don't have *.azurewebsites.net, wildcards, or URL shorteners.\n",
      "TestId": "21885",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe Redirect URIs |\n| :--- | :--- | :--- |\n|  | [Azure AD SAML Toolkit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/4317fd0a-dcee-45bf-8e94-9a66638b11e0/appId/6f5ed68c-9fad-4d78-bf88-2b16bbe16338/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://samltoolkit.azurewebsites.net/SAML/Consume` |  |\n|  | [My nice app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d41cfc13-11d1-4f93-835a-88e729725564/appId/2946f286-2b59-4f29-876c-0ed8bbe1c482/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://mysalmon.azurewebsites.net/login.saml` |  |\n|  | [saml test app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/daa6074c-db6f-4bdc-a41b-bc0052c536a5/appId/c266d677-a5f8-47bc-9f0a-1b6fbe0bddad/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://appclaims.azurewebsites.net/signin-saml`, `2️⃣ https://appclaims.azurewebsites.net/signin-oidc` |  |\n\n\n",
      "TestTitle": "App registrations use safe redirect URIs",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "Non-Microsoft and multitenant applications configured with URLs that include wildcards, localhost, or URL shorteners increase the attack surface for threat actors. These insecure redirect URIs (reply URLs) might allow adversaries to manipulate authentication requests, hijack authorization codes, and intercept tokens by directing users to attacker-controlled endpoints. Wildcard entries expand the risk by permitting unintended domains to process authentication responses, while localhost and shortener URLs might facilitate phishing and token theft in uncontrolled environments.\n\nWithout strict validation of redirect URIs, attackers can bypass security controls, impersonate legitimate applications, and escalate their privileges. This misconfiguration enables persistence, unauthorized access, and lateral movement, as adversaries exploit weak OAuth enforcement to infiltrate protected resources undetected.\n\n**Remediation action**\n\n- [Check the redirect URIs for your application registrations.](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) Make sure the redirect URIs don't have localhost, *.azurewebsites.net, wildcards, or URL shorteners.\n",
      "TestId": "23183",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe Redirect URIs |App owner tenant |\n| :--- | :--- | :--- | :--- |\n|  | [EAM Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24b12ae7-4648-4aae-b00c-6349a565d24c/appId/e6e0be31-7040-4084-ac44-600b67661f2c) | `2️⃣ https://eamdemo.azurewebsites.net` | 1852b10f-a011-428b-98f9-d09c37d477cf |\n|  | [FIDO2-passkeys-MFA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1aa7e155-cbf8-4970-8458-05a0c7a2d1a5/appId/4fabcfc0-5c44-45a1-8c80-8537f0625949) | `2️⃣ https://fidomfaserver.azurewebsites.net/connect/authorize` | 1852b10f-a011-428b-98f9-d09c37d477cf |\n|  | [Graph Explorer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f8f300a-870a-46ff-bdab-934e1436920d/appId/d3ce4cf8-6810-442d-b42e-375e14710095) | `2️⃣ https://graphexplorer.azurewebsites.net/` | 5508eaf2-e7b4-4510-a4fb-9f5970550d80 |\n|  | [Graph explorer (official site)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cd2e9b58-eb21-4a50-a338-33f9daa1599c/appId/de8bc8b5-d9f9-48b1-a8ad-b748da725064) | `2️⃣ https://graphtryit.azurewebsites.net`, `2️⃣ https://graphtryit.azurewebsites.net/` | 72f988bf-86f1-41af-91ab-2d7cd011db47 |\n|  | [Internal_AccessScope](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/180a3ccb-3f2f-486f-8b56-025fc225166d/appId/3f9bd1ee-5a72-4ad3-b67d-cb016f935bcf) | `1️⃣ http://featureconfiguration.onmicrosoft.com/Internal_AccessScope` | 0d2db716-b331-4d7b-aa37-7f1ac9d35dae |\n|  | [Modern Workplace Concierge](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad1c51e8-f8a8-4bf2-ac09-a3a20cba5fa5/appId/c65c4011-1b90-4ec9-b5e9-1ee17786ad84) | `2️⃣ https://mwconcierge.azurewebsites.net/` | 7955e1b3-cbad-49eb-9a84-e14aed7f3400 |\n|  | [entraChatAppMultiTenant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/855a57ff-88a6-4ad0-85d7-4f46d742730e/appId/5e00b345-a805-42a0-9caa-7d6cb761c668) | `2️⃣ https://entrachatapp.azurewebsites.net`, `2️⃣ https://entrachatapp.azurewebsites.net/redirect` | 8b047ec6-6d2e-481d-acfa-5d562c09f49a |\n\n\n",
      "TestTitle": "Service principals use safe redirect URIs",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "If privileged role activations aren't restricted to dedicated Privileged Access Workstations (PAWs), threat actors can exploit compromised endpoint devices to perform privileged escalation attacks from unmanaged or noncompliant workstations. Standard productivity workstations often contain attack vectors such as unrestricted web browsing, email clients vulnerable to phishing, and locally installed applications with potential vulnerabilities. When administrators activated privileged roles from these workstations, threat actors who gain initial access through malware, browser exploits, or social engineering can then use the locally cached privileged credentials or hijack existing authenticated sessions to escalate their privileges. Privileged role activations grant extensive administrative rights across Microsoft Entra ID and connected services, so attackers can create new administrative accounts, modify security policies, access sensitive data across all organizational resources, and deploy malware or backdoors throughout the environment to establish persistent access. This lateral movement from a compromised endpoint to privileged cloud resources represents a critical attack path that bypasses many traditional security controls. The privileged access appears legitimate when originating from an authenticated administrator's session.\n\nIf this check passes, your tenant has a Conditional Access policy that restricts privileged role access to PAW devices, but it isn't the only control required to fully enable a PAW solution. You also need to configure an Intune device configuration and compliance policy and a device filter.\n\n**Remediation action**\n\n- [Deploy a privileged access workstation solution](https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-deployment?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - Provides guidance for configuring the Conditional Access and Intune device configuration and compliance policies.\n- [Configure device filters in Conditional Access to restrict privileged access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-condition-filters-for-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21830",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nNo Conditional Access policies found that restrict privileged roles to PAW device.\n\n**❌ Found 0 policy(s) with compliant device control targeting all privileged roles**\n\n\n**❌ Found 0 policy(s) with PAW/SAW device filter targeting all privileged roles**\n\n\n",
      "TestTitle": "Conditional Access policies for Privileged Access Workstations are configured",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "",
      "TestSkipped": "",
      "TestDescription": "If Wi-Fi profiles aren't properly configured and assigned, Android devices can fail to connect to secure networks or connect insecurely, exposing corporate data to interception or unauthorized access. Without centralized management, devices rely on manual configuration, increasing the risk of misconfiguration, weak authentication, and connection to rogue networks.\n\nCentrally managing Wi-Fi profiles for Android devices in Intune ensures secure and consistent connectivity to enterprise networks. This enforces authentication and encryption standards, simplifies onboarding, and supports Zero Trust by reducing exposure to untrusted networks.\n\n\n\nUse Intune to configure secure Wi-Fi profiles that enforce authentication and encryption standards.\n\n**Remediation action**\n\nUse Intune to configure and assign secure Wi-Fi profiles for Android devices to enforce authentication and encryption standards:  \n- [Deploy Wi-Fi profiles to devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/wi-fi-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-profile)\n\nFor more information, see:  \n- [Review the available Wi-Fi settings for Android devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/wi-fi-settings-android-enterprise?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24840",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo Enterprise Wi-Fi profile for android exists or none are assigned.\n\n\n\n",
      "TestTitle": "Secure Wi-Fi profiles protect Android devices from unauthorized network access",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "TestDescription": "Without a centrally managed firewall policy, macOS devices might rely on default or user-modified settings, which often fail to meet corporate security standards. This exposes devices to unsolicited inbound connections, enabling threat actors to exploit vulnerabilities, establish outbound command-and-control (C2) traffic for data exfiltration, and move laterally within the network—significantly escalating the scope and impact of a breach.\n\nEnforcing macOS Firewall policies ensures consistent control over inbound and outbound traffic, reducing exposure to unauthorized access and supporting Zero Trust through device-level protection and network segmentation.\n\n**Remediation action**\n\nConfigure and assign **macOS Firewall** profiles in Intune to block unauthorized traffic and enforce consistent network protections across all managed macOS devices:\n\n- [Configure the built-in firewall on macOS devices](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n\nFor more information, see:  \n-  [Available macOS firewall settings](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-profile-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#macos-firewall-profile)",
      "TestId": "24552",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo assigned macOS firewall policy was found in Intune.\n\nNo macOS firewall policies found in this tenant.\n\n\n",
      "TestTitle": "macOS Firewall policies protect against unauthorized network access",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Monitoring",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "TestDescription": "Leaving high-priority Microsoft Entra recommendations unaddressed can create a gap in an organization’s security posture, offering threat actors opportunities to exploit known weaknesses. Not acting on these items might result in an increased attack surface area, suboptimal operations, or poor user experience. \n\n**Remediation action**\n\n- [Address all high priority recommendations in the Microsoft Entra admin center](https://learn.microsoft.com/entra/identity/monitoring-health/overview-recommendations?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-does-it-work)\n",
      "TestId": "22124",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": [
        "Application"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound 4 unaddressed high priority Entra recommendations.\n\n\n## Unaddressed high priority Entra recommendations\n\n| Display Name | Status | Insights |\n| :--- | :--- | :--- |\n| Protect all users with a user risk policy  | active | You have 3 of 70 users that don’t have a user risk policy enabled.  |\n| Protect all users with a sign-in risk policy | active | You have 70 of 70 users that don't have a sign-in risk policy turned on. |\n| Ensure all users can complete multifactor authentication | active | You have 44 of 70 users that aren’t registered with MFA.  |\n| Require multifactor authentication for administrative roles | active | You have 3 of 18 users with administrative roles that aren’t registered and protected with MFA. |\n\n\n",
      "TestTitle": "High priority Microsoft Entra recommendations are addressed",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "Global Administrators with persistent access to Azure subscriptions expand the attack surface for threat actors. If a Global Administrator account is compromised, attackers can immediately enumerate resources, modify configurations, assign roles, and exfiltrate sensitive data across all subscriptions. Requiring just-in-time elevation for subscription access introduces detectable signals, slows attacker velocity, and routes high-impact operations through observable control points.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths.md)\n\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity.md)",
      "TestId": "21788",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nStanding access to Root Management group was found.\n\n\n## Entra ID objects with standing access to Root Management group\n\n\n| Entra ID Object | Object ID | Principal type |\n| :-------------- | :-------- | :------------- |\n| merill@elapora.com | 513f3db2-044c-41be-af14-431bf88a2b3e | User |\n| madura@elapora.com | 5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a | User |\n\n\n\n",
      "TestTitle": "Global Administrators don't have standing access to Azure subscriptions",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Identity",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Threat actors who compromise a permanently assigned privileged account (e.g., Global Administrator or Privileged Role Administrator) gain continuous, uninterrupted access to high-impact directory operations. This extended dwell time enables attackers to more easily establish persistent backdoors, delete critical data and security configurations, disable monitoring systems, and register malicious applications for data exfiltration and lateral movement. These actions can result in full organizational disruption, widespread data compromise, and total loss of operational control over the tenant. Microsoft Entra PIM’s eligible role assignment model narrows escalation pathways, constrains attacker dwell time and provides the option of role elevation approval workflows.\n\n**Remediation action**\n- [Use Privileged Identity Management to manage privileged Microsoft Entra roles](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-getting-started)\n- [Manage emergency access admin accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access) \n\n",
      "TestId": "21816",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nFound Microsoft Entra privileged role assignments that are not managed with PIM.\n\n\n## Assessment summary\n\n| Metric | Count |\n| :----- | :---- |\n| Privileged roles found | 29 |\n| Eligible Global Administrators | 5 |\n| Non-PIM privileged users | 7 |\n| Non-PIM privileged groups | 1 |\n| Permanent Global Administrator users | 13 |\n\n## Non-PIM managed privileged role assignments\n\n| Display name | User principal name | Role name | Assignment type |\n| :----------- | :------------------ | :-------- | :-------------- |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true) | perennial_ash@elapora.com | Application Administrator | Assigned |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true) | Komal.p@elapora.com | Global Reader | Assigned |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true) | chukka.p@elapora.com | Global Reader | Assigned |\n| [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true) | manoj.p@elapora.com | Global Reader | Assigned |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true) | sandeep.p@elapora.com | Global Reader | Assigned |\n| [sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/96252680-04a0-4bec-b5f7-a552c8150525/hidePreviewBanner~/true) | sushant.p@elapora.com | Global Reader | Assigned |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true) | perennial_ash@elapora.com | Global Reader | Assigned |\n| [PimLevel](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/RolesAndAdministrators/groupId/e8971185-8150-402e-b90f-5c1eb0d30dfe/menuId/) | N/A (Group) | Application Administrator | Assigned |\n\n## Permanent Global Administrator assignments\n\n| Display name | User principal name | Assignment type | On-Premises synced |\n| :----------- | :------------------ | :-------------- | :----------------- |\n| [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true) | merill@elapora.com | Assigned | N/A |\n| [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true) | merillf_gmail.com#EXT#@pora.onmicrosoft.com | Assigned | N/A |\n| [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true) | joshua@elapora.com | Assigned | N/A |\n| [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true) | damien.bowden@elapora.com | Assigned | N/A |\n| [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true) | emergency@elapora.com | Assigned | N/A |\n| [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true) | tyler@elapora.com | Assigned | N/A |\n| [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true) | ann@elapora.com | Assigned | N/A |\n| [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true) | aleksandar@elapora.com | Assigned | N/A |\n| [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true) | madura@elapora.com | Assigned | N/A |\n| [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0b37813c-ae19-4399-982f-16587f17f9c0/hidePreviewBanner~/true) | gael@elapora.com | Assigned | N/A |\n| [Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1433571b-3d7c-4a56-a9cc-67580848bc73/hidePreviewBanner~/true) | ravi.kalwani@elapora.com | Assigned | N/A |\n| [Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/a85798bd-652b-4eb9-ba90-3ee882df0179/hidePreviewBanner~/true) | varsha.mane@elapora.com | Assigned | N/A |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true) | chukka.p@elapora.com | Assigned | N/A |\n\n",
      "TestTitle": "All Microsoft Entra privileged role assignments are managed with PIM",
      "TestStatus": "Investigate"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Credential management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Legacy multifactor authentication (MFA) and self-service password reset (SSPR) policies in Microsoft Entra ID manage authentication methods separately, leading to fragmented configurations and suboptimal user experience. Moreover, managing these policies independently increases administrative overhead and the risk of misconfiguration.  \n\nMigrating to the combined Authentication Methods policy consolidates the management of MFA, SSPR, and passwordless authentication methods into a single policy framework. This unification allows for more granular control, enabling administrators to target specific authentication methods to user groups and enforce consistent security measures across the organization. Additionally, the unified policy supports modern authentication methods, such as FIDO2 security keys and Windows Hello for Business, enhancing the organization's security posture.\n\nMicrosoft announced the deprecation of legacy MFA and SSPR policies, with a retirement date set for September 30, 2025. Organizations are advised to complete the migration to the Authentication Methods policy before this date to avoid potential disruptions and to benefit from the enhanced security and management capabilities of the unified policy.\n\n**Remediation action**\n\n- [Enable combined security information registration](https://learn.microsoft.com/entra/identity/authentication/howto-registration-mfa-sspr-combined?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [How to migrate MFA and SSPR policy settings to the Authentication methods policy for Microsoft Entra ID](https://learn.microsoft.com/entra/identity/authentication/how-to-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21803",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nCombined registration is enabled.\n\n\n\n",
      "TestTitle": "Migrate from legacy MFA and SSPR policies",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "Without approval workflows, threat actors who compromise Global Administrator credentials through phishing, credential stuffing, or other authentication bypass techniques can immediately activate the most privileged role in a tenant without any other verification or oversight. Privileged Identity Management (PIM) allows eligible role activations to become active within seconds, so compromised credentials can allow near-instant privilege escalation. Once activated, threat actors can use the Global Administrator role to use the following attack paths to gain persistent access to the tenant:\n- Create new privileged accounts\n- Modify Conditional Access policies to exclude those new accounts\n- Establish alternate authentication methods such as certificate-based authentication or application registrations with high privileges\n\nThe Global Administrator role provides access to administrative features in Microsoft Entra ID and services that use Microsoft Entra identities, including Microsoft Defender XDR, Microsoft Purview, Exchange Online, and SharePoint Online. Without approval gates, threat actors can rapidly escalate to complete tenant takeover, exfiltrating sensitive data, compromising all user accounts, and establishing long-term backdoors through service principals or federation modifications that persist even after the initial compromise is detected. \n\n**Remediation action**\n\n- [Configure role settings to require approval for Global Administrator activation](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Set up approval workflow for privileged roles](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-approval-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21817",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\n✅ **Pass**: Approval required with 2 primary approver(s) configured.\n\n\n## Global Administrator role activation and approval workflow\n\n\n| Approval Required | Primary Approvers | Escalation Approvers |\n| :---------------- | :---------------- | :------------------- |\n| Yes | Aleksandar Nikolic, Merill Fernando |  |\n\n\n\n",
      "TestTitle": "Global Administrator role activation triggers an approval workflow",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If Windows automatic enrollment isn't enabled, unmanaged devices can become an entry point for attackers. Threat actors might use these devices to access corporate data, bypass compliance policies, and introduce vulnerabilities into the environment. Devices joined to Microsoft Entra without Intune enrollment create gaps in visibility and control. These unmanaged endpoints can expose weaknesses in the operating system or misconfigured applications that attackers can exploit.\n\nEnforcing automatic enrollment ensures Windows devices are managed from the start, enabling consistent policy enforcement and visibility into compliance. This supports Zero Trust by ensuring all devices are verified, monitored, and governed by security controls.\n\n**Remediation action**\n\nEnable automatic enrollment for Windows devices using Intune and Microsoft Entra to ensure all domain-joined or Entra-joined devices are managed:  \n- [Enable Windows automatic enrollment](https://learn.microsoft.com/intune/intune-service/enrollment/windows-enroll?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-windows-automatic-enrollment)\n\nFor more information, see:  \n- [Deployment guide - Enrollment for Windows](https://learn.microsoft.com/intune/intune-service/fundamentals/deployment-guide-enroll?tabs=work-profile%2Ccorporate-owned-apple%2Cautomatic-enrollment&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enrollment-for-windows)\n",
      "TestId": "24546",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nWindows Automatic Enrollment is enabled.\n\n\n## Windows Automatic Enrollment\n\n| Policy Name | User Scope |\n| :---------- | :--------- |\n| [Microsoft Intune](https://intune.microsoft.com/#view/Microsoft_AAD_IAM/MdmConfiguration.ReactView/appId/0000000a-0000-0000-c000-000000000000/appName/Microsoft%20Intune) | ✅ Specific Groups |\n\n\n\n",
      "TestTitle": "Windows automatic device enrollment is enforced to eliminate risks from unmanaged endpoints",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When local administrators on Microsoft Entra joined devices are not managed by the organization, threat actors who could compromise user accounts can execute device takeover attacks that result in permanent loss of organizational control. Threat actors can leverage compromised account credentials to perform account manipulation by removing all organizational administrators from the device’s local administrators, including the global administrators who normally retain management access. Once threat actors do that, they can modify user account control settings and disable the device's connection to Microsoft Entra, effectively severing the cloud management channel. This attack progression results in a complete device takeover where organizational global administrators lose all administrative pathways to regain control. The device becomes an orphaned asset that cannot be managed any more.\n\n**Remediation action**\n- [Manage the local administrators on Microsoft Entra joined devices](https://learn.microsoft.com/en-us/entra/identity/devices/assign-local-admin)\n",
      "TestId": "21955",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nLocal administrators on Microsoft Entra joined devices are managed by the organization.\n\n[Global administrator role is added as local administrator on the device during Microsoft Entra join?](https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview)\n\n- **Yes** → ✅\n",
      "TestTitle": "Manage the local administrators on Microsoft Entra joined devices",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Enabling the security key authentication method in Microsoft Entra ID mitigates the risk of credential theft and unauthorized access by requiring hardware-backed, phishing-resistant authentication. If this best practice is not followed, threat actors can exploit weak or reused passwords, perform credential stuffing attacks, and escalate privileges through compromised accounts. The kill chain begins with reconnaissance where attackers gather information about user accounts, followed by credential harvesting through various techniques like social engineering or data breaches. Attackers then gain initial access using stolen credentials, move laterally within the network by exploiting trust relationships, and establish persistence to maintain long-term access. Without hardware-backed authentication like FIDO2 security keys, attackers can bypass basic password defenses and multi-factor authentication, increasing the likelihood of data exfiltration and business disruption. Security keys provide cryptographic proof of identity that is bound to the specific device and cannot be replicated or phished, effectively breaking the attack chain at the initial access stage. \n\n**Remediation action**\n\n* [Enable passkey (FIDO2) authentication method](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-enable-passkey-fido2#enable-passkey-fido2-authentication-method)\n\n* [Authentication method policy management](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods-manage)\n\n",
      "TestId": "21838",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nSecurity key authentication method is enabled for your tenant, providing hardware-backed phishing-resistant authentication.\n\n\n## FIDO2 security key authentication settings\n\n✅ **FIDO2 authentication method**\n- Status: Enabled\n- Include targets: All users\n- Exclude targets: Group: eam-block-user\n\n\n",
      "TestTitle": "Security key authentication method enabled",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they're legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable inactive privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases. If so, [analyze if a OAuth2 permission is a better fit](https://learn.microsoft.com/entra/identity-platform/v2-app-types?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21771",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Application"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nNo inactive applications with privileged Entra built-in roles\n\n\n## Apps with privileged Entra built-in roles\n\n| | Name | Role | Assignment | App owner tenant | Last sign in|\n| :--- | :--- | :--- | :--- | :--- | :--- |\n| ✅ | [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d22f071d-e8d3-41fc-a516-b29753cdd1f6/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | Global Administrator, Application Administrator | Permanent | Pora Inc. | 2025-09-09 | \n| ✅ | [elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c5632968-35cd-445d-926e-16e0afc9160e/appId/e876f7cb-13f3-48a4-8329-66d7b1fa33fb) | Global Administrator | Permanent | Pora Inc. | 2025-10-01 | \n\n\n",
      "TestTitle": "Inactive applications don’t have highly privileged built-in roles",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Monitoring",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "TestDescription": "Risky sign-ins flagged by Microsoft Entra ID Protection indicate a high probability of unauthorized access attempts. Threat actors use these sign-ins to gain an initial foothold. If these sign-ins remain uninvestigated, adversaries can establish persistence by repeatedly authenticating under the guise of legitimate users. \n\nA lack of response lets attackers execute reconnaissance, attempt to escalate their access, and blend into normal patterns. When untriaged sign-ins continue to generate alerts and there's no intervention, security gaps widen, facilitating lateral movement and defense evasion, as adversaries recognize the absence of an active security response.\n\n**Remediation action**\n\n- [Investigate risky sign-ins](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Remediate risks and unblock users](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-remediate-unblock?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21863",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nNo untriaged risky sign ins in the tenant.\n\n",
      "TestTitle": "All high-risk sign-ins are triaged",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If compliance policies aren't assigned to fully managed Android Enterprise devices in Intune, threat actors can exploit noncompliant endpoints to gain unauthorized access to corporate resources, bypass security controls, and persist in the environment. Without enforced compliance, devices can lack critical security configurations such as passcode requirements, data storage encryption, and OS version controls. These gaps increase the risk of data leakage, privilege escalation, and lateral movement. Inconsistent device compliance weakens the organization’s security posture and makes it harder to detect and remediate threats before significant damage occurs.\n\nEnforcing compliance policies ensures Android Enterprise devices meet core security requirements and supports Zero Trust by validating device health and reducing exposure to misconfigured or unmanaged endpoints.\n\n**Remediation action**\n\nCreate and assign Intune compliance policies to fully managed and corporate-owned Android Enterprise devices to enforce organizational standards for secure access and management:  \n- [Create a compliance policy in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/create-compliance-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-policy)\n- [Review the Android Enterprise compliance settings you can manage with Intune](https://learn.microsoft.com/intune/intune-service/protect/compliance-policy-create-android-for-work?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "24545",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAt least one compliance policy for Android Enterprise Fully managed devices exists and is assigned.\n\n\n## Compliance policy assignment for Android Enterprise Fully managed device is configured and assigned\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [My android enterprise policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesComplianceMenu/~/policies) | ✅ Assigned | **Included:** All Users, **Excluded:** testPIM |\n\n\n",
      "TestTitle": "Compliance policies protect fully managed and corporate-owned Android devices",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "## Risk Explanation\n\nWhen administrators retain access to Self-Service Password Reset (SSPR), threat actors who compromise administrative credentials can leverage this capability to bypass additional security controls and maintain persistent access to the environment. An administrative account with SSPR enabled creates a privileged pathway that allows password changes without requiring secondary authentication factors or administrative oversight, enabling lateral movement across critical systems. If threat actors obtain initial access to an administrative account through credential stuffing, phishing, or password spraying attacks, they can immediately reset the compromised account's password to prevent legitimate administrators from regaining control while establishing persistence through additional backdoor accounts or privileged role assignments. This autonomy in password management eliminates the security checkpoint that centralized password reset procedures provide, allowing threat actors to operate undetected while they escalate privileges, exfiltrate sensitive data, and deploy additional malicious payloads across the organization's infrastructure.\n\n## Remediation Resources\n\n- Disable SSPR for administrators by updating the authorization policy.\n- Administrator reset policy differences: [Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-policy#administrator-reset-policy-differences)\n\n",
      "TestId": "21842",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\n✅ Administrators are properly blocked from using Self-Service Password Reset, ensuring password changes go through controlled processes.\n",
      "TestTitle": "Block administrators from using SSPR",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without Conditional Access policies protecting security information registration, threat actors can exploit unprotected registration flows to compromise authentication methods. When users register multifactor authentication and self-service password reset methods without proper controls, threat actors can intercept these registration sessions through adversary-in-the-middle attacks or exploit unmanaged devices accessing registration from untrusted locations. Once threat actors gain access to an unprotected registration flow, they can register their own authentication methods, effectively hijacking the target's authentication profile. The threat actors can bypass security controls and potentially escalate privileges throughout the environment because they can maintain persistent access by controlling the MFA methods. The compromised authentication methods then become the foundation for lateral movement as threat actors can authenticate as the legitimate user across multiple services and applications.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy for security info registration](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-security-info-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure known network locations](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Enable combined security info registration](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-registration-mfa-sspr-combined?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21806",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nSecurity information registration is protected by Conditional Access policies.\n## Conditional Access Policies targeting security information registration\n\n\n| Policy Name | User Actions Targeted | Grant Controls Applied |\n| :---------- | :-------------------- | :--------------------- |\n| [Security regisrtation info](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/508ae024-d4c4-42bf-a8c9-40257c214c10) | urn:user:registersecurityinfo |  |\n\n\n\n",
      "TestTitle": "Secure the MFA registration (My Security Info) page",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "If an on-premises account is compromised and is synchronized to Microsoft Entra, the attacker might gain access to the tenant as well. This risk increases because on-premises environments typically have more attack surfaces due to older infrastructure and limited security controls. Attackers might also target the infrastructure and tools used to enable connectivity between on-premises environments and Microsoft Entra. These targets might include tools like Microsoft Entra Connect or Active Directory Federation Services, where they could impersonate or otherwise manipulate other on-premises user accounts.\n\nIf privileged cloud accounts are synchronized with on-premises accounts, an attacker who acquires credentials for on-premises can use those same credentials to access cloud resources and move laterally to the cloud environment.\n\n**Remediation action**\n\n- [Protecting Microsoft 365 from on-premises attacks](https://learn.microsoft.com/entra/architecture/protect-m365-from-on-premises-attacks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#specific-security-recommendations)\n\nFor each role with high privileges (assigned permanently or eligible through Microsoft Entra Privileged Identity Management), you should do the following actions:\n\n- Review the users that have onPremisesImmutableId and onPremisesSyncEnabled set. See [Microsoft Graph API user resource type](https://learn.microsoft.com/graph/api/resources/user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Create cloud-only user accounts for those individuals and remove their hybrid identity from privileged roles.\n",
      "TestId": "21814",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "PrivilegedIdentity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nValidated that standing or eligible privileged accounts are cloud only accounts.\n\n## Privileged Roles\n\n| Role Name | User | Source | Status |\n| :--- | :--- | :--- | :---: |\n| Global Administrator | [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | Cloud native identity | ✅ |\n| Global Administrator | [Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1433571b-3d7c-4a56-a9cc-67580848bc73) | Cloud native identity | ✅ |\n| Global Administrator | [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6) | Cloud native identity | ✅ |\n| Global Administrator | [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165) | Cloud native identity | ✅ |\n| Global Administrator | [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e) | Cloud native identity | ✅ |\n| Global Administrator | [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/518ce209-faf4-4717-add9-7129a669fa11) | Cloud native identity | ✅ |\n| Global Administrator | [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a) | Cloud native identity | ✅ |\n| Global Administrator | [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7) | Cloud native identity | ✅ |\n| Global Administrator | [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003) | Cloud native identity | ✅ |\n| Global Administrator | [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7e92f268-bb12-469a-a869-210d596d4c1f) | Cloud native identity | ✅ |\n| Global Administrator | [sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/96252680-04a0-4bec-b5f7-a552c8150525) | Cloud native identity | ✅ |\n| Global Administrator | [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91) | Cloud native identity | ✅ |\n| Global Administrator | [Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/a85798bd-652b-4eb9-ba90-3ee882df0179) | Cloud native identity | ✅ |\n| Global Administrator | [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a) | Cloud native identity | ✅ |\n| Global Administrator | [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d) | Cloud native identity | ✅ |\n| Global Administrator | [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854) | Cloud native identity | ✅ |\n| Global Administrator | [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6) | Cloud native identity | ✅ |\n| Global Reader | [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6) | Cloud native identity | ✅ |\n| Global Reader | [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/518ce209-faf4-4717-add9-7129a669fa11) | Cloud native identity | ✅ |\n| Global Reader | [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7e92f268-bb12-469a-a869-210d596d4c1f) | Cloud native identity | ✅ |\n| Global Reader | [sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/96252680-04a0-4bec-b5f7-a552c8150525) | Cloud native identity | ✅ |\n| Global Reader | [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91) | Cloud native identity | ✅ |\n| Global Reader | [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/df02402a-e291-42cc-b449-79366daa2a40) | Cloud native identity | ✅ |\n\n\n",
      "TestTitle": "Privileged accounts are cloud native identities",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If Microsoft Entra Conditional Access policies don't enforce device compliance, users can connect to corporate resources from devices that don't meet security standards. This exposes sensitive data to risks like malware, unauthorized access, and regulatory noncompliance. Without controls like encryption enforcement, device health checks, and access restrictions, threat actors can exploit noncompliant devices to bypass security measures and maintain persistence.\n\n\nRequiring device compliance in Conditional Access policies ensures only trusted and secure devices can access corporate resources. This supports Zero Trust by enforcing access decisions based on device health and compliance posture.\n\n**Remediation action**\n\nConfigure Conditional Access policies in Microsoft Entra to require device compliance before granting access to corporate resources:  \n- [Create a device compliance-based Conditional Access policy](https://learn.microsoft.com/intune/intune-service/protect/create-conditional-access-intune?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:\n- [What is Conditional Access?](https://learn.microsoft.com/entra/identity/conditional-access/overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Integrate device compliance results with Conditional Access](https://learn.microsoft.com/intune/intune-service/protect/device-compliance-get-started?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#integrate-with-conditional-access)",
      "TestId": "24824",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAt least one enabled conditional access policy with device compliance exists for each platform (Windows, macOS, iOS, Android), or a policy exists with no platform section (applies to all).\n\n\n## Conditional Access Policies with Device Compliance\n\n| Policy Name | Platforms |\n| :---------- | :-------- |\n| [Device compliance #1](https://intune.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies) | All Platforms || [\\[RaviK\\] - Require app protection policy](https://intune.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies) | android, iOS || [\\[RaviK\\] - CA policy for Compliant devices](https://intune.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies) | android, iOS |\n\n\n",
      "TestTitle": "Conditional Access policies block access from noncompliant devices",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Device code flow is a cross-device authentication flow designed for input-constrained devices. It can be exploited in phishing attacks, where an attacker initiates the flow and tricks a user into completing it on their device, thereby sending the user's tokens to the attacker. Given the security risks and the infrequent legitimate use of device code flow, you should enable a Conditional Access policy to block this flow by default.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to block device code flow](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-authentication-flows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#device-code-flow-policies).\n",
      "TestId": "21808",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": [
        "ConditionalAccess"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nDevice code flow is properly restricted in the tenant.\n## Conditional Access Policies targeting Device Code Flow\n\n| Policy Name | Status | Target Users | Target Resources | Grant Controls |\n| :---------- | :----- | :----------- | :--------------- | :------------ |\n| [Block Device Code](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/db2153a1-40a2-457f-917c-c280b204b5cd) | Enabled | All Users, Excluded: 4 users/groups | All Applications | Block (ANY) |\n\n## Inactive Conditional Access Policies targeting Device Code Flow\nThese policies are not contributing to your security posture because they are not enabled:\n\n| Policy Name | Status | Target Users | Target Resources | Grant Controls |\n| :---------- | :----- | :----------- | :--------------- | :------------ |\n| [Block DCF](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/b5ff217b-3d84-4581-bd92-5d8f8b8bab6a) | Disabled | All Users | All Applications | Block (ANY) |\n\n\n",
      "TestTitle": "Restrict device code flow",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "An on-premises federation server introduces a critical attack surface by serving as a central authentication point for cloud applications. Threat actors often gain a foothold by compromising a privileged user such as a help desk representative or an operations engineer through attacks like phishing, credential stuffing, or exploiting weak passwords. They might also target unpatched vulnerabilities in infrastructure, use remote code execution exploits, attack the Kerberos protocol, or use pass-the-hash attacks to escalate privileges. Misconfigured remote access tools like remote desktop protocol (RDP), virtual private network (VPN), or jump servers provide other entry points, while supply chain compromises or malicious insiders further increase exposure. Once inside, threat actors can manipulate authentication flows, forge security tokens to impersonate any user, and pivot into cloud environments. Establishing persistence, they can disable security logs, evade detection, and exfiltrate sensitive data.\n\n**Remediation action**\n\n- [Migrate from federation to cloud authentication like Microsoft Entra Password hash synchronization (PHS)](https://learn.microsoft.com/entra/identity/hybrid/connect/migrate-from-federation-to-cloud-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestId": "21829",
      "SkippedReason": null,
      "TestImpact": "High",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nAll domains are using cloud authentication.\n\n\n\n",
      "TestTitle": "Use cloud authentication",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Monitoring",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Threat actors increasingly target workload identities (applications, service principals, and managed identities) because they lack human factors and often use long-lived credentials. A compromise typically starts with credential abuse or key theft, followed by non-interactive sign-ins to cloud resources, lateral movement via app permissions, and persistence through new secrets or role assignments. Microsoft Entra ID Protection continuously generates risky workload identity detections and flags sign-in events with risk state and detail. If risky workload identity sign-ins aren’t triaged (confirmed compromised, dismissed as benign, or marked safe), detection fatigue and alert backlog allow repeated malicious access, privilege escalation, and token replay to continue unnoticed. Triaging sign-ins closes the loop by recording an authoritative decision on each risky event and driving containment actions such as disabling the service principal, rotating credentials, or revoking sessions.\n\n**Remediation action**\n\n- [Investigate risky workload identities and perform appropriate remediation ](https://learn.microsoft.com/en-us/entra/id-protection/concept-workload-identity-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Dismiss workload identity risks when determined to be false positives](https://learn.microsoft.com/graph/api/riskyserviceprincipal-dismiss?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Confirm compromised workload identities when risks are validated](https://learn.microsoft.com/graph/api/riskyserviceprincipal-confirmcompromised?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "22659",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\n✅ All risky workload identity sign-ins have been triaged and resolved.\n",
      "TestTitle": "All risky workload identity sign-ins are triaged",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without enforcing Local Administrator Password Solution (LAPS) policies, threat actors who gain access to endpoints can exploit static or weak local administrator passwords to escalate privileges, move laterally, and establish persistence. The attack chain typically begins with device compromise—via phishing, malware, or physical access—followed by attempts to harvest local admin credentials. Without LAPS, attackers can reuse compromised credentials across multiple devices, increasing the risk of privilege escalation and domain-wide compromise.\n\nEnforcing Windows LAPS on all corporate Windows devices ensures unique, regularly rotated local administrator passwords. This disrupts the attack chain at the credential access and lateral movement stages, significantly reducing the risk of widespread compromise.\n\n**Remediation action**\n\nUse Intune to enforce Windows LAPS policies that rotate strong and unique local admin passwords, and that back them up securely:  \n- [Deploy Windows LAPS policy with Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/windows-laps-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-laps-policy)\n\nFor more information, see:  \n- [Windows LAPS policy settings reference](https://learn.microsoft.com/windows-server/identity/laps/laps-management-policy-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Learn about Intune support for Windows LAPS](https://learn.microsoft.com/intune/intune-service/protect/windows-laps-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "24560",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nCloud LAPS policy is assigned and enforced.\n\n\n## Windows Cloud LAPS policy is created and assigned\n\n| Policy Name | Status | Assignment | Backup Directory | Automatic Account Management |\n| :---------- | :----- | :--------- | :--------------- | :--------------------------- |\n| [relaps](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/accountprotection) | ✅ Assigned | **Included:** All Devices | ✅ Entra ID (AAD) | ❌ Not Configured |\n| [test](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/accountprotection) | ✅ Assigned | **Included:** All Users | ✅ Active Directory | ✅ Enabled |\n\n\n\n",
      "TestTitle": "Local administrator credentials on Windows are protected by Windows LAPS",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If compliance policies for Windows devices aren't configured and assigned, threat actors can exploit unmanaged or noncompliant endpoints to gain unauthorized access to corporate resources, bypass security controls, and persist within the environment. Without enforced compliance, devices can lack critical security configurations like BitLocker encryption, password requirements, firewall settings, and OS version controls. These gaps increase the risk of data leakage, privilege escalation, and lateral movement. Inconsistent device compliance weakens the organization’s security posture and makes it harder to detect and remediate threats before significant damage occurs.\n\nEnforcing compliance policies ensures Windows devices meet core security requirements and supports Zero Trust by validating device health and reducing exposure to misconfigured endpoints.\n\n**Remediation action**\n\nCreate and assign Intune compliance policies to Windows devices to enforce organizational standards for secure access and management:\n- [Create and assign Intune compliance policies](https://learn.microsoft.com/intune/intune-service/protect/create-compliance-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-policy)\n- [Review the Windows compliance settings you can manage with Intune](https://learn.microsoft.com/intune/intune-service/protect/compliance-policy-create-windows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "24541",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAt least one compliance policy for Windows exists and is assigned.\n\n\n## Windows Compliance Policies\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [Min Windows Compliance](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/compliance) | ✅ Assigned | **Included:** All Devices |\n| [My Windows policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/compliance) | ✅ Assigned | **Included:** All guests, **Excluded:** All active users |\n\n\n\n",
      "TestTitle": "Compliance policies protect Windows devices",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "TestDescription": "Tenant Restrictions v2 (TRv2) allows organizations to enforce policies that restrict access to specified Microsoft Entra tenants, preventing unauthorized exfiltration of corporate data to external tenants using local accounts. Without TRv2, threat actors can exploit this vulnerability, which leads to potential data exfiltration and compliance violations, followed by credential harvesting if those external tenants have weaker controls. Once credentials are obtained, threat actors can gain initial access to these external tenants. TRv2 provides the mechanism to prevent users from authenticating to unauthorized tenants. Otherwise, threat actors can move laterally, escalate privileges, and potentially exfiltrate sensitive data, all while appearing as legitimate user activity that bypasses traditional data loss prevention controls focused on internal tenant monitoring.\n\nImplementing TRv2 enforces policies that restrict access to specified tenants, mitigating these risks by ensuring that authentication and data access are confined to authorized tenants only. \n\nIf this check passes, your tenant has a TRv2 policy configured but more steps are required to validate the scenario end-to-end.\n\n**Remediation action**\n- [Set up Tenant Restrictions v2](https://learn.microsoft.com/en-us/entra/external-id/tenant-restrictions-v2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21793",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nTenant Restrictions v2 policy is properly configured.\n\n\n## Tenant restriction settings\n\n\n| Policy Configured | External users and groups | External applications |\n| :---------------- | :------------------------ | :-------------------- |\n| [Yes](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/TenantRestrictions.ReactView/isDefault~/true/name//id/) | All external users and groups | All external applications |\n\n\n\n",
      "TestTitle": "Tenant restrictions v2 policy is configured",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If Microsoft Entra Conditional Access policies aren't combined with app protection controls, users can connect to corporate resources through unmanaged or unsecured applications. This exposes sensitive data to risks such as data leakage, unauthorized access, and regulatory noncompliance. Without safeguards like app-level data protection, access restrictions, and data loss prevention, threat actors can exploit unprotected apps to bypass security controls and compromise organizational data.\n\nEnforcing Intune app protection policies within Conditional Access ensures only trusted apps can access corporate data. This supports Zero Trust by enforcing access decisions based on app trust, data containment, and usage restrictions.\n\n**Remediation action**\n\nConfigure app-based Conditional Access policies in Microsoft Entra and Intune to require app protection for access to corporate resources:  \n- [Set up app-based Conditional Access policies with Intune](https://learn.microsoft.com/intune/intune-service/protect/app-based-conditional-access-intune-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:  \n- [What is Conditional Access?](https://learn.microsoft.com/entra/identity/conditional-access/overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Learn about app-based Conditional Access policies with Intune](https://learn.microsoft.com/intune/intune-service/protect/app-based-conditional-access-intune?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24827",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAt least one enabled conditional access policy with Application Protection exists for iOS and Android. The platforms could be part of same or different policy with the required grant control.\n\n\n## iOS & Android Conditional Access Policies\n\n| Policy Name | Platforms |\n| :---------- | :-------- |\n| [\\[RaviK\\] - Require app protection policy](https://intune.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies) | android, iOS || [\\[RaviK\\] - CA policy for Compliant devices](https://intune.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies) | android, iOS |\n\n\n",
      "TestTitle": "Conditional Access policies block access from unmanaged apps",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without Local Admin Password Solution (LAPS) deployed, threat actors can exploit static local administrator passwords to establish initial access through credential stuffing or password spraying attacks targeting common default passwords. Once threat actors compromise a single device with a shared local administrator credential, they gain the ability to move laterally across the environment using pass-the-hash attacks, where hashes of compromised local administrator accounts are reused to authenticate to other systems sharing the same password. This enables lateral traversal attacks where threat actors can systematically compromise additional devices within the network using the same local administrator credentials. The compromised local administrator access provides threat actors with system-level privileges, allowing them to disable security controls, install persistent backdoors, exfiltrate sensitive data, and establish command and control channels. Without automated password rotation and centralized management, organizations cannot detect or respond to unauthorized use of local administrator accounts, providing threat actors with extended dwell time to achieve their objectives while remaining undetected.\n\n**Remediation action**\n- [Configure Windows Local Administrator Password Solution in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/devices/howto-manage-local-admin-passwords)\n\n",
      "TestId": "21953",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nLocal Admin Password Solution is deployed.\n## Local Admin Password Solution (LAPS) settings\n\n| Setting | Status |\n| :---- | :---- |\n|[Enable Microsoft Entra Local Administrator Password Solution (LAPS)](https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview) | Enabled\n\n",
      "TestTitle": "Local Admin Password Solution is deployed",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If compliance policies aren't assigned to Android Enterprise personally owned devices in Intune, threat actors can exploit noncompliant endpoints to gain unauthorized access to corporate resources, bypass security controls, and introduce vulnerabilities. Without enforced compliance, devices can lack critical security configurations like passcode requirements, data storage encryption, and OS version controls. These gaps increase the risk of data leakage and unauthorized access. Inconsistent device compliance weakens the organization’s security posture and makes it harder to detect and remediate threats before significant damage occurs.\n\nEnforcing compliance policies ensures that personally owned Android devices meet core security requirements and supports Zero Trust by validating device health and reducing exposure to misconfigured or unmanaged endpoints.\n\n**Remediation action**\n\nCreate and assign Intune compliance policies to Android Enterprise personally owned devices to enforce organizational standards for secure access and management:  \n- [Create a compliance policy in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/create-compliance-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-policy)\n- [Review the Android Enterprise compliance settings you can manage with Intune](https://learn.microsoft.com/intune/intune-service/protect/compliance-policy-create-android-for-work?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24547",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAt least one compliance policy for Android Enterprise Personally-Owned Work Profile exists and is assigned.\n\n\n## Compliance policy assignment for Android Enterprise Fully managed device is configured and assigned\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [My android personally-owned](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesComplianceMenu/~/policies) | ✅ Assigned | **Included:** aad-conditional-access-allow-legacy-auth, **Excluded:** Executive Management, HR |\n\n\n",
      "TestTitle": "Compliance policies protect personally owned Android devices",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Microsoft services applications that operate in your tenant are identified as service principals with the owner organization ID \"f8cdef31-a31e-4b4a-93e4-5f571e91255a.\" When these service principals have credentials configured in your tenant, they might create potential attack vectors that threat actors can exploit. If an administrator added the credentials and they're no longer needed, they can become a target for attackers. Although less likely when proper preventive and detective controls are in place on privileged activities, threat actors can also maliciously add credentials. In either case, threat actors can use these credentials to authenticate as the service principal, gaining the same permissions and access rights as the Microsoft service application. This initial access can lead to privilege escalation if the application has high-level permissions, allowing lateral movement across the tenant. Attackers can then proceed to data exfiltration or persistence establishment through creating other backdoor credentials.\n\nWhen credentials (like client secrets or certificates) are configured for these service principals in your tenant, it means someone - either an administrator or a malicious actor - enabled them to authenticate independently within your environment. These credentials should be investigated to determine their legitimacy and necessity. If they're no longer needed, they should be removed to reduce the risk. \n\nIf this check doesn't pass, the recommendation is to \"investigate\" because you need to identify and review any applications with unused credentials configured.\n\n**Remediation action**\n\n- Confirm if the credentials added are still valid use cases. If not, remove credentials from Microsoft service applications to reduce security risk. \n    - In the Microsoft Entra admin center, browse to **Entra ID** > **App registrations** and select the affected application.\n    - Go to the **Certificates & secrets** section and remove any credentials that are no longer needed.",
      "TestId": "21774",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nNo Microsoft services applications have credentials configured in the tenant.\n\n",
      "TestTitle": "Microsoft services applications don't have credentials configured",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When passkey authentication is not enabled in Entra ID, organizations expose themselves to a comprehensive kill chain that begins with credential-based attacks and escalates to full environment compromise. Threat actors initiate attacks through spear-phishing campaigns targeting password credentials, exploiting the inherent vulnerability of password-based authentication systems that can be easily compromised, replayed, or phished from users. Once initial credentials are obtained, attackers leverage these stolen passwords to gain legitimate access to cloud resources, bypassing traditional multi-factor authentication through advanced phishing techniques such as Adversary-in-the-Middle (AiTM) attacks that intercept and relay authentication tokens in real-time. With established access, threat actors perform lateral movement through the environment, escalating privileges by targeting high-value accounts and exploiting trust relationships between systems. The attack culminates in persistent access establishment, where attackers maintain long-term presence through token theft and replay mechanisms, enabling continuous data exfiltration, privilege escalation, and potential deployment of additional malicious payloads. This kill chain demonstrates why phishing-resistant authentication methods like passkeys are critical, as they eliminate the foundational vulnerability that enables the entire attack sequence by providing cryptographic proof of authentication that cannot be phished, intercepted, or replayed by threat actors.\n\n**Remediation action**\n- [Enable passkey authentication in the Authentication methods policy](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-enable-passkey-fido2#enable-passkey-fido2-authentication-method)\n- [Configure passkey settings using Microsoft Graph API](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-enable-passkey-fido2#enable-passkeys-fido2-using-microsoft-graph-api)  \n- [Plan phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication) \n\n",
      "TestId": "21839",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nPasskey authentication method is enabled and configured for users in your tenant.\n## [Passkey authentication method details](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConfigureAuthMethodsBlade/authMethod~/%7B%22%40odata.type%22%3A%22%23microsoft.graph.fido2AuthenticationMethodConfiguration%22%2C%22id%22%3A%22Fido2%22%2C%22state%22%3A%22enabled%22%2C%22isSelfServiceRegistrationAllowed%22%3Atrue%2C%22isAttestationEnforced%22%3Afalse%2C%22excludeTargets%22%3A%5B%7B%22id%22%3A%2243b7bc87-77eb-4263-abad-e3c2478f0a35%22%2C%22targetType%22%3A%22group%22%2C%22displayName%22%3A%22eam-block-user%22%7D%5D%2C%22keyRestrictions%22%3A%7B%22isEnforced%22%3Afalse%2C%22enforcementType%22%3A%22allow%22%2C%22aaGuids%22%3A%5B%22de1e552d-db1d-4423-a619-566b625cdc84%22%2C%2290a3ccdf-635c-4729-a248-9b709135078f%22%2C%2277010bd7-212a-4fc9-b236-d2ca5e9d4084%22%2C%22b6ede29c-3772-412c-8a78-539c1f4c62d2%22%2C%22ee041bce-25e5-4cdb-8f86-897fd6418464%22%2C%2273bb0cd4-e502-49b8-9c6f-b59445bf720b%22%5D%7D%2C%22includeTargets%40odata.context%22%3A%22https%3A%2F%2Fgraph.microsoft.com%2Fbeta%2F%24metadata%23policies%2FauthenticationMethodsPolicy%2FauthenticationMethodConfigurations('Fido2')%2Fmicrosoft.graph.fido2AuthenticationMethodConfiguration%2FincludeTargets%22%2C%22includeTargets%22%3A%5B%7B%22targetType%22%3A%22group%22%2C%22id%22%3A%22all_users%22%2C%22isRegistrationRequired%22%3Afalse%7D%5D%2C%22enabled%22%3Atrue%2C%22target%22%3A%22All%20users%2C%20excluding%201%20group%22%2C%22isAllUsers%22%3Atrue%2C%22voiceDisabled%22%3Afalse%7D/canModify~/true/voiceDisabled~/false/userMemberIds~/%5B%5D/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/isCiamTenant~/false/isCiamTrialTenant~/false)\n- **Status** : Enabled ✅\n- **Include targets** : All users\n- **Enforce attestation** : False\n- **Key restriction policy** :\n  - **Enforce key restrictions** : False\n  - **Restrict specific keys** : Allow\n\n",
      "TestTitle": "Passkey authentication method enabled",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If Intune scope tags aren't properly configured for delegated administration, attackers who gain privileged access to Intune or Microsoft Entra ID can escalate privileges and access sensitive device configurations across the tenant. Without granular scope tags, administrative boundaries are unclear, allowing attackers to move laterally, manipulate device policies, exfiltrate configuration data, or deploy malicious settings to all users and devices. A single compromised admin account can impact the entire environment. The absence of delegated administration also undermines least-privileged access, making it difficult to contain breaches and enforce accountability. Attackers might exploit global administrator roles or misconfigured role-based access control (RBAC) assignments to bypass compliance policies and gain broad control over device management.\n\nEnforcing scope tags segments administrative access and aligns it with organizational boundaries. This limits the blast radius of compromised accounts, supports least-privilege access, and aligns with Zero Trust principles of segmentation, role-based control, and containment.\n\n**Remediation action**\n\nUse Intune scope tags and RBAC roles to limit admin access based on role, geography, or business unit:  \n- [Learn how to create and deploy scope tags for distributed IT](https://learn.microsoft.com/intune/intune-service/fundamentals/scope-tags?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Implement role-based access control with Microsoft Intune](https://learn.microsoft.com/intune/intune-service/fundamentals/role-based-access-control?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24555",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nDelegated administration is enforced with custom Intune Scope Tags assignments.\n\n\n## Scope Tags\n\n| Scope Tag Name | Status | Assignment Target |\n| :------------- | :----- | :---------------- |\n| [Biscope](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/RolesLandingMenuBlade/~/scopeTags) | ✅ Assigned | **Included:** aad-conditional-access-excluded |\n\n\n\n",
      "TestTitle": "Scope tag configuration is enforced to support delegated administration and least-privilege access",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without app protection policies, corporate data accessed on iOS/iPadOS devices is vulnerable to leakage through unmanaged or personal apps. Users can unintentionally copy sensitive information into unsecured apps, store data outside corporate boundaries, or bypass authentication controls. This risk is especially high on BYOD devices, where personal and work contexts coexist, increasing the likelihood of data exfiltration or unauthorized access.\n\nApp protection policies ensure corporate data remains secure within approved apps, even on personal devices. These policies enforce encryption, restrict data sharing, and require authentication, reducing the risk of data leakage and aligning with Zero Trust principles of data protection and conditional access.\n \n**Remediation action**\n\nDeploy Intune app protection policies that encrypt corporate data, restrict sharing, and require authentication in approved iOS/iPadOS apps:  \n- [Deploy Intune app protection policies](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policies?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-an-iosipados-or-android-app-protection-policy)\n- [Review the iOS app protection settings reference](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policy-settings-ios?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:  \n- [Learn about using app protection policies](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "24548",
      "SkippedReason": null,
      "TestImpact": "High",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAt least one App protection policy for iOS exists and is assigned.\n\n\n## OS App Protection policies configured for iOS\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [iOS Policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/protection) | ✅ Assigned | **Included:** WFgroup, **Excluded:** graph test |\n\n\n\n",
      "TestTitle": "Data on iOS/iPadOS is protected by app protection policies",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If macOS update policies aren’t properly configured and assigned, threat actors can exploit unpatched vulnerabilities in macOS devices within the organization. Without enforced update policies, devices remain on outdated software versions, increasing the attack surface for privilege escalation, remote code execution, or persistence techniques. Threat actors can leverage these weaknesses to gain initial access, escalate privileges, and move laterally within the environment. If policies exist but aren’t assigned to device groups, endpoints remain unprotected, and compliance gaps go undetected. This can result in widespread compromise, data exfiltration, and operational disruption.\n\nEnforcing macOS update policies ensures devices receive timely patches, reducing the risk of exploitation and supporting Zero Trust by maintaining a secure, compliant device fleet.\n\n**Remediation action**\n\nConfigure and assign macOS update policies in Intune to enforce timely patching and reduce risk from unpatched vulnerabilities:  \n- [Manage macOS software updates in Intune](https://learn.microsoft.com/intune/intune-service/protect/software-updates-macos?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24690",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAt least one macOS update policy is assigned to a group.\n\n\n## macOS Update Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [macOS_Update_1](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/iOSiPadOSUpdate) | ✅ Assigned | **Included:** All Devices, **Excluded:** WFgroup |\n| [alex_macOS_SoftwareUpdate](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ✅ Assigned | **Included:** All Devices, **Excluded:** WFgroup |\n| [alex_macOS_SoftwareUpdateEnforceLatest](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ❌ Not assigned | None |\n\n\n\n",
      "TestTitle": "Update policies for macOS are enforced to reduce risk from unpatched vulnerabilities",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Accelerate response and remediation",
      "TestSkipped": "",
      "TestDescription": "Assume high risk users are compromised by threat actors. Without investigation and remediation, threat actors can execute scripts, deploy malicious applications, or manipulate API calls to establish persistence, based on the potentially compromised user's permissions. Threat actors can then exploit misconfigurations or abuse OAuth tokens to move laterally across workloads like documents, SaaS applications, or Azure resources. Threat actors can gain access to sensitive files, customer records, or proprietary code and exfiltrate it to external repositories while maintaining stealth through legitimate cloud services. Finally, threat actors might disrupt operations by modifying configurations, encrypting data for ransom, or using the stolen information for further attacks, resulting in financial, reputational, and regulatory consequences.\n\nOrganizations using passwords can rely on password reset to automatically remediate risky users.\n\nOrganizations using passwordless credentials already mitigate most risk events that accrue to user risk levels, thus the volume of risky users should be considerably lower. Risky users in an organization that uses passwordless credentials must be blocked from access until the user risk is investigated and remediated.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to require a secure password change for elevated user risk](https://learn.microsoft.com/entra/identity/conditional-access/policy-risk-based-user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Use Microsoft Entra ID Protection to [investigate risk further](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestId": "21797",
      "SkippedReason": null,
      "TestImpact": "High",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPolicies to restrict access for high risk users are properly implemented.\n## Passwordless Authentication Methods allowed in tenant\n\n| Authentication Method Name | State | Additional Info |\n| :------------------------ | :---- | :-------------- |\n| Fido2 | enabled |  |\n\n## Conditional Access Policies targeting high risk users\n\n| Conditional Access Policy Name | Status | Conditions |\n| :--------------------- | :----- | :--------- |\n| [Require password change for high-risk users](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/ddbc3bb1-3749-474f-b8c3-0d997118b24b) | Enabled | User Risk Level: High, Control: Password Change |\n| [CISA SCuBA.MS.AAD.2.3: Users detected as high risk SHALL be blocked.](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/94c7d8d0-5c8c-460d-8ace-364374250893) | Enabled | User Risk Level: High, Control: Block |\n| [Force Password Change](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/5848211d-96f2-40ae-92a4-af1aa8f48572) | Disabled | User Risk Level: High, Control: Password Change |\n\n\n",
      "TestTitle": "Restrict access to high risk users",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "A threat actor or a well-intentioned but uninformed employee can create a new Microsoft Entra tenant if there are no restrictions in place. By default, the user who creates a tenant is automatically assigned the Global Administrator role. Without proper controls, this action fractures the identity perimeter by creating a tenant outside the organization's governance and visibility. It introduces risk though a shadow identity platform that can be exploited for token issuance, brand impersonation, consent phishing, or persistent staging infrastructure. Since the rogue tenant might not be tethered to the enterprise’s administrative or monitoring planes, traditional defenses are blind to its creation, activity, and potential misuse.\n\n**Remediation action**\n\nEnable the **Restrict non-admin users from creating tenants** setting. For users that need the ability to create tenants, assign them the Tenant Creator role. You can also review tenant creation events in the Microsoft Entra audit logs.\n\n- [Restrict member users' default permissions](https://learn.microsoft.com/entra/fundamentals/users-default-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#restrict-member-users-default-permissions)\n- [Assign the Tenant Creator role](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#tenant-creator)\n- [Review tenant creation events](https://learn.microsoft.com/entra/identity/monitoring-health/reference-audit-activities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#core-directory). Look for OperationName==\"Create Company\", Category == \"DirectoryManagement\".\n",
      "TestId": "21787",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nNon-privileged users are restricted from creating tenants.\n\n\n\n",
      "TestTitle": "Permissions to create new tenants are limited to the Tenant Creator role",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If compliance policies aren't assigned to iOS/iPadOS devices in Intune, threat actors can exploit noncompliant endpoints to gain unauthorized access to corporate resources, bypass security controls, and persist in the environment. Without enforced compliance, devices can lack critical security configurations like passcode requirements and OS version controls. These gaps increase the risk of data leakage, privilege escalation, and lateral movement. Inconsistent device compliance weakens the organization’s security posture and makes it harder to detect and remediate threats before significant damage occurs.\n\nEnforcing compliance policies ensures iOS/iPadOS devices meet core security requirements and supports Zero Trust by validating device health and reducing exposure to misconfigured or unmanaged endpoints.\n\n**Remediation action**\n\nCreate and assign Intune compliance policies to iOS/iPadOS devices to enforce organizational standards for secure access and management:  \n- [Create a compliance policy in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/create-compliance-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-policy)\n- [Review the iOS/iPadOS compliance settings you can manage with Intune](https://learn.microsoft.com/intune/intune-service/protect/compliance-policy-create-ios?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24543",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAt least one compliance policy for iOS/iPadOS exists and is assigned.\n\n\n## iOS/iPadOS Compliance Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [My iOS policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/compliance) | ✅ Assigned | **Included:** All Devices, All Users, **Excluded:** aad-conditional-access-excluded |\n\n\n\n",
      "TestTitle": "Compliance policies protect iOS/iPadOS devices",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If iOS update policies aren’t configured and assigned, threat actors can exploit unpatched vulnerabilities in outdated operating systems on managed devices. The absence of enforced update policies allows attackers to use known exploits to gain initial access, escalate privileges, and move laterally within the environment. Without timely updates, devices remain susceptible to exploits that have already been addressed by Apple, enabling threat actors to bypass security controls, deploy malware, or exfiltrate sensitive data. This kill chain begins with device compromise through an unpatched vulnerability, followed by persistence and potential data breach that impacts both organizational security and compliance posture.\n\nEnforcing update policies disrupts this chain by ensuring devices are consistently protected against known threats.\n\n**Remediation action**\n\nConfigure and assign iOS/iPadOS update policies in Intune to enforce timely patching and reduce risk from unpatched vulnerabilities:  \n- [Manage iOS/iPadOS software updates in Intune](https://learn.microsoft.com/intune/intune-service/protect/software-updates-guide-ios-ipados?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)",
      "TestId": "24554",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAn iOS update policy is configured and assigned.\n\n\n## iOS Update Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [iOS_Update_1](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/iOSiPadOSUpdate) | ❌ Not assigned | None |\n| [alex_ios_DDM_SoftwareUpdate](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ✅ Assigned | **Included:** All Devices, **Excluded:** WFgroup |\n| [alex_ios_DDM_SoftwareUpdateEnforceLatest](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ✅ Assigned | **Included:** All Devices, **Excluded:** WFgroup |\n| [alex_ios_policy1](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ❌ Not assigned | None |\n| [alex_ios_policy2](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ✅ Assigned | **Included:** All Users |\n\n\n\n",
      "TestTitle": "Update policies for iOS/iPadOS are enforced to reduce risk from unpatched vulnerabilities",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If Windows Update policies aren't enforced across all corporate Windows devices, threat actors can exploit unpatched vulnerabilities to gain unauthorized access, escalate privileges, and move laterally within the environment. The attack chain often begins with device compromise via phishing, malware, or exploitation of known vulnerabilities, and is followed by attempts to bypass security controls. Without enforced update policies, attackers leverage outdated software to persist in the environment, increasing the risk of privilege escalation and domain-wide compromise.\n\nEnforcing Windows Update policies ensures timely patching of security flaws, disrupting attacker persistence, and reducing the risk of widespread compromise.\n\n**Remediation action**\n\nStart with [Manage Windows software updates in Intune](https://learn.microsoft.com/intune/intune-service/protect/windows-update-for-business-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to understand the available Windows Update policy types and how to configure them.\n\nIntune includes the following Windows update policy type: \n- [Windows quality updates policy](https://learn.microsoft.com/intune/intune-service/protect/windows-quality-update-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to install the regular monthly updates for Windows.*\n- [Expedite updates policy](https://learn.microsoft.com/intune/intune-service/protect/windows-10-expedite-updates?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to quickly install critical security patches.*\n- [Feature updates policy](https://learn.microsoft.com/intune/intune-service/protect/windows-10-feature-updates?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Update rings policy](https://learn.microsoft.com/intune/intune-service/protect/windows-10-update-rings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to manage how and when devices install feature and quality updates.*\n- [Windows driver updates](https://learn.microsoft.com/intune/intune-service/protect/windows-driver-updates-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to update hardware components.*\n",
      "TestId": "24553",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nWindows Update policy is assigned and enforced.\n\n\n| Policy Name | Status | Assignment |\n| :---------- | :------------- | :--------- |\n| [PROD](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesWindowsMenu/~/windows10Update) | ✅ Assigned | **Included:** All Devices, **Excluded:** WFgroup |\n\n\n",
      "TestTitle": "Windows Update policies are enforced to reduce risk from unpatched vulnerabilities",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without app protection policies, corporate data accessed on Android devices is vulnerable to leakage through unmanaged or malicious apps. Users can unintentionally copy sensitive information into personal apps, store data insecurely, or bypass authentication controls. This risk is amplified on devices that aren't fully managed, where corporate and personal contexts coexist, increasing the likelihood of data exfiltration or unauthorized access.\n\nEnforcing app protection policies ensures that corporate data is only accessible through trusted apps and remains protected even on personal or BYOD Android devices. \n\nThese policies enforce encryption, restrict data sharing, and require authentication, reducing the risk of data leakage and aligning with Zero Trust principles of data protection and conditional access\n\n**Remediation action**\n\nDeploy Intune app protection policies that encrypt data, restrict sharing, and require authentication in approved Android apps:  \n- [Deploy Intune app protection policies](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policies?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-an-iosipados-or-android-app-protection-policy)\n- [Review the Android app protection settings reference](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policy-settings-android?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:  \n- [Learn about using app protection policies](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "24549",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAt least one App protection policy for Android exists and is assigned.\n\n\n## Android App Protection policies configured for Android\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [Android Policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/protection) | ✅ Assigned | **Included:** aad-conditional-access-excluded |\n\n\n\n",
      "TestTitle": "Data on Android is protected by app protection policies",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Devices",
      "TestCategory": "Device management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "Without enforced SSO policies, macOS endpoints may rely on insecure or inconsistent authentication mechanisms, allowing attackers to bypass conditional access and compliance policies. This opens the door to lateral movement across cloud services and on-premises resources, especially when federated identities are used. Threat actors can persist by leveraging stolen tokens or cached credentials, and exfiltrate sensitive data through unmanaged apps or browser sessions. The absence of SSO enforcement also undermines app protection policies and device posture assessments, making it difficult to detect and contain breaches. Ultimately, failure to configure and assign macOS SSO policies compromises identity security and weakens the organization's zero trust posture.\n\n**Remediation action**\n\nmacOS SSO guide:\n- [Platform SSO configuration guide for macOS devices using Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/platform-sso-macos)\n\nOverview of macOS SSO: \n- [Single sign-on (SSO) overview and options for Apple devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/use-enterprise-sso-plug-in-ios-ipados-macos?pivots=macos)\n\n",
      "TestId": "24568",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nmacOS SSO policies are configured and assigned in Intune.\n\n\n## macOS SSO Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [Platform SSO](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ✅ Assigned | **Included:** All Users |\n\n\n \n \n",
      "TestTitle": "macOS - Platform SSO is configured and assigned",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Blocking authentication transfer in Microsoft Entra ID is a critical security control. It helps protect against token theft and replay attacks by preventing the use of device tokens to silently authenticate on other devices or browsers. When authentication transfer is enabled, a threat actor who gains access to one device can access resources to nonapproved devices, bypassing standard authentication and device compliance checks. When administrators block this flow, organizations can ensure that each authentication request must originate from the original device, maintaining the integrity of the device compliance and user session context.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to block authentication transfer](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-block-authentication-flows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-transfer-policies)\n",
      "TestId": "21828",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nAuthentication transfer is blocked by Conditional Access Policy(s).\n## Conditional Access Policies targeting Authentication Transfer\n\n\n| Policy Name | Policy ID | State | Created | Modified |\n| :---------- | :-------- | :---- | :------ | :------- |\n| [Block Device Code](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/db2153a1-40a2-457f-917c-c280b204b5cd) | db2153a1-40a2-457f-917c-c280b204b5cd | enabled | 02/28/2024 00:22:50 | 07/29/2025 11:42:31 |\n\n\n\n",
      "TestTitle": "Authentication transfer is blocked",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Monitoring",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "TestDescription": "Users considered at high risk by Microsoft Entra ID Protection have a high probability of compromise by threat actors. Threat actors can gain initial access via compromised valid accounts, where their suspicious activities continue despite triggering risk indicators. This oversight can enable persistence as threat actors perform activities that normally warrant investigation, such as unusual login patterns or suspicious inbox manipulation. \n\nA lack of triage of these risky users allows for expanded reconnaissance activities and lateral movement, with anomalous behavior patterns continuing to generate uninvestigated alerts. Threat actors become emboldened as security teams show they aren't actively responding to risk indicators.\n\n**Remediation action**\n\n- [Investigate high risk users](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in Microsoft Entra ID Protection\n- [Remediate high risk users and unblock](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-remediate-unblock?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in Microsoft Entra ID Protection\n",
      "TestId": "21861",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nAll high-risk users are properly triaged in Entra ID Protection.\n\n",
      "TestTitle": "All high-risk users are triaged",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without restricted user consent settings, threat actors can exploit permissive application consent configurations to gain unauthorized access to sensitive organizational data. When user consent is unrestricted, attackers can:\n\n- Use social engineering and illicit consent grant attacks to trick users into approving malicious applications.\n- Impersonate legitimate services to request broad permissions, such as access to email, files, calendars, and other critical business data.\n- Obtain legitimate OAuth tokens that bypass perimeter security controls, making access appear normal to security monitoring systems.\n- Establish persistent access to organizational resources, conduct reconnaissance across Microsoft 365 services, move laterally through connected systems, and potentially escalate privileges.\n\nUnrestricted user consent also limits an organization's ability to enforce centralized governance over application access, making it difficult to maintain visibility into which non-Microsoft applications have access to sensitive data. This gap creates compliance risks where unauthorized applications might violate data protection regulations or organizational security policies.\n\n**Remediation action**\n\n-  [Configure restricted user consent settings](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-user-consent?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to prevent illicit consent grants by disabling user consent or limiting it to verified publishers with low-risk permissions only.",
      "TestId": "21776",
      "SkippedReason": null,
      "TestImpact": "High",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\n✅ **Pass**: User consent settings are properly restricted to prevent illicit consent grant attacks.\n\n\n## Authorization Policy Configuration\n\n\n**Current [user consent settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/~/UserSettings)**\n\n- Allow user consent for apps from verified publishers, for selected permissions (Recommended).\nAll users can consent for permissions classified as \"low impact\", for apps from verified publishers or apps registered in this organization.\n\n\n",
      "TestTitle": "User consent settings are restricted",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Threat actors can exploit the lack of multifactor authentication during new device registration. Once authenticated, they can register rogue devices, establish persistence, and circumvent security controls tied to trusted endpoints. This foothold enables attackers to exfiltrate sensitive data, deploy malicious applications, or move laterally, depending on the permissions of the accounts being used by the attacker. Without MFA enforcement, risk escalates as adversaries can continuously reauthenticate, evade detection, and execute objectives.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to require multifactor authentication for device registration](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-device-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestId": "21872",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\n**Properly configured Conditional Access policies found** that require MFA for device registration/join actions.\n## Device Settings Configuration\n\n| Setting | Value | Recommended Value | Status |\n| :------ | :---- | :---------------- | :----- |\n| Require Multi-Factor Authentication to register or join devices | No | No | ✅ Correctly configured |\n\n## Device Registration/Join Conditional Access Policies\n\n| Policy Name | State | Requires MFA | Status |\n| :---------- | :---- | :----------- | :----- |\n| [testdevicereg21872](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/620a9c5c-09c4-4558-a0fe-7fc8b3540992) | enabled | Yes | ✅ Properly configured |\n\n\n",
      "TestTitle": "Require multifactor authentication for device join and device registration using user action",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "TestDescription": "If policies for Windows Firewall aren't configured and assigned, threat actors can exploit unprotected endpoints to gain unauthorized access, move laterally, and escalate privileges within the environment. Without enforced firewall rules, attackers can bypass network segmentation, exfiltrate data, or deploy malware, increasing the risk of widespread compromise.\n\nEnforcing Windows Firewall policies ensures consistent application of inbound and outbound traffic controls, reducing exposure to unauthorized access and supporting Zero Trust through network segmentation and device-level protection.\n\n**Remediation action**\n\nConfigure and assign firewall policies for Windows in Intune to block unauthorized traffic and enforce consistent network protections across all managed devices:\n\n- [Configure firewall policies for Windows devices](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci). Intune uses two complementary profiles to manage firewall settings:\n  - **Windows Firewall** - Use this profile to configure overall firewall behavior based on network type.\n  - **Windows Firewall rules** - Use this profile to define traffic rules for apps, ports, or IPs, tailored to specific groups or workloads. This Intune profile also supports use of [reusable settings groups](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#add-reusable-settings-groups-to-profiles-for-firewall-rules) to help simplify management of common settings you use for different profile instances.\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n\nFor more information, see:  \n- [Available Windows Firewall settings](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-profile-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#windows-firewall-profile)\n",
      "TestId": "24540",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "High",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAt least one Windows Firewall policy is created and assigned to a group.\n\n\n## Windows Firewall Configuration Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [WF_Policy](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/firewall) | ✅ Assigned | **Included:** WFgroup, My Test Device Group |\n| [WF_Policy2](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/firewall) | ❌ Not assigned | None |\n| [WF_Policy3](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/firewall) | ✅ Assigned | **Included:** All Devices, **Excluded:** My Test Device Group, WFgroup |\n\n\n\n",
      "TestTitle": "Windows Firewall policies protect against unauthorized network access",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21881",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Azure subscriptions used by Identity Governance are secured consistently with Identity Governance roles",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "If administrators assign privileged roles to workload identities, such as service principals or managed identities, the tenant can be exposed to significant risk if those identities are compromised. Threat actors who gain access to a privileged workload identity can perform reconnaissance to enumerate resources, escalate privileges, and manipulate or exfiltrate sensitive data. The attack chain typically begins with credential theft or abuse of a vulnerable application. Next step is privilege escalation through the assigned role, lateral movement across cloud resources, and finally persistence via other role assignments or credential updates. Workload identities are often used in automation and might not be monitored as closely as user accounts. Compromise can then go undetected, allowing threat actors to maintain access and control over critical resources. Workload identities aren't subject to user-centric protections like MFA, making least-privilege assignment and regular review essential. \n\n**Remediation action**\n- [Review and remove privileged roles assignments](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-resource-roles-assign-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#update-or-remove-an-existing-role-assignment).\n- [Follow the best practices for workload identities](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#key-scenarios).\n- [Learn about privileged roles and permissions in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/privileged-roles-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21836",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "Workload Identities are not assigned privileged roles",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "Configuring password reset notifications for administrator roles in Microsoft Entra ID enhances security by notifying privileged administrators when another administrator resets their password. This visibility helps detect unauthorized or suspicious activity that could indicate credential compromise or insider threats. Without these notifications, malicious actors could exploit elevated privileges to establish persistence, escalate access, or extract sensitive data. Proactive notifications support quick action, preserve privileged access integrity, and strengthen the overall security posture.   \n\n**Remediation action**\n\n- [Notify all admins when other admins reset their passwords](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-howitworks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#notify-all-admins-when-other-admins-reset-their-passwords) \n",
      "TestId": "21891",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "Require password reset notifications for administrator roles",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "Without owners, enterprise applications become orphaned assets that threat actors can exploit through credential harvesting and privilege escalation techniques. These applications often retain elevated permissions and access to sensitive resources while lacking proper oversight and security governance. The elevation of privilege to owners can raise a security concern, depending on the application's permissions. More critically, applications without an owner can create uncertainty in security monitoring where threat actors can establish persistence by using existing application permissions to access data or create backdoor accounts without triggering ownership-based detection mechanisms.\n\nWhen applications lack owners, security teams can't effectively conduct application lifecycle management. This gap leaves applications with potentially excessive permissions, outdated configurations, or compromised credentials that threat actors can discover through enumeration techniques and exploit to move laterally within the environment. The absence of ownership also prevents proper access reviews and permission audits, allowing threat actors to maintain long-term access through applications that should be decommissioned or had their permissions reduced. Not maintaining a clean application portfolio can provide persistent access vectors that can be used for data exfiltration or further compromise of the environment.\n\n**Remediation action**\n\n- [Assign owners to applications](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/assign-app-owners?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21867",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "Enterprise applications with high privilege Microsoft Graph API permissions have owners",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21912",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Azure resources used by Microsoft Entra only allow access from privileged roles",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy a Conditional Access policy to target privileged accounts and require phishing resistant credentials](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestId": "21781",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Authentication"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound Accounts have not registered phishing resistant methods\n\n\n\n",
      "TestTitle": "Privileged users sign in with phishing-resistant methods",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21864",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "All risk detections are triaged",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "Microsoft recommends that organizations have two cloud-only emergency access accounts permanently assigned the [Global Administrator](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#global-administrator) role. These accounts are highly privileged and aren't assigned to specific individuals. The accounts are limited to emergency or \"break glass\" scenarios where normal accounts can't be used or all other administrators are accidentally locked out.\n\n**Remediation action**\n\nCreate accounts following the [emergency access account recommendations](https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestId": "21835",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "Emergency access accounts are configured appropriately",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "If you don't enable ID Protection notifications, your organization loses critical real-time alerts when threat actors compromise user accounts or conduct reconnaissance activities. When Microsoft Entra ID Protection detects accounts at risk, it sends email alerts with **Users at risk detected** as the subject and links to the **Users flagged for risk** report. Without these notifications, security teams remain unaware of active threats, allowing threat actors to maintain persistence in compromised accounts without being detected. You can feed these risks into tools like Conditional Access to make access decisions or send them to a security information and event management (SIEM) tool for investigation and correlation. Threat actors can use this detection gap to conduct lateral movement activities, privilege escalation attempts, or data exfiltration operations while administrators remain unaware of the ongoing compromise. The delayed response enables threat actors to establish more persistence mechanisms, change user permissions, or access sensitive resources before you can fix the issue. Without proactive notification of risk detections, organizations must rely solely on manual monitoring of risk reports, which significantly increases the time it takes to detect and respond to identity-based attacks.   \n\n**Remediation action**\n\n- [Configure users at risk detected alerts](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-notifications?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-users-at-risk-detected-alerts)  \n",
      "TestId": "21798",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "High",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "ID Protection notifications are enabled",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Threat actors increasingly rely on prompt bombing and real-time phishing proxies to coerce or trick users into approving fraudulent multifactor authentication (MFA) challenges. Without the Microsoft Authenticator “Report suspicious activity” capability enabled, a coerced denial or ignored prompt produces minimal actionable signal; the attacker can iterate until a fatigued user accepts. When reporting is enabled and targeted to users, any unexpected push or phone prompt can be actively flagged, immediately elevating the user to High User Risk and generating a high-fidelity risk detection (userReportedSuspiciousActivity) that downstream Conditional Access or response automation can block or require secure remediation. If disabled, threat actors who gain initial credentials via phishing can continuously attempt MFA approvals (harvested session replay or AiTM) without triggering rapid risk-based containment. This gap lets them escalate: (1) credential theft and session token interception; (2) iterative MFA fatigue attacks; (3) eventual push approval; (4) privilege escalation or persistence (adding methods, creating service principals); (5) lateral movement into sensitive workloads; (6) data exfiltration or destructive actions. Enabling and targeting this feature converts ambiguous user friction into a deterministic, high-signal containment control, shrinking attacker dwell time and strengthening the detection-to-response feedback loop using built-in risk pipelines. Leaving it off forfeits a low-noise human sensor that materially improves blast radius reduction.\n\n**Remediation action**\n- [Enable Settings](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-mfasettings#report-suspicious-activity)\n",
      "TestId": "21841",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAuthenticator app report suspicious activity is [not enabled](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AuthMethodsSettings).\n",
      "TestTitle": "Authenticator app report suspicious activity is enabled",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "An excessive number of Global Administrator accounts creates an expanded attack surface that threat actors can exploit through various initial access vectors. Each extra privileged account represents a potential entry point for threat actors. An excess of Global Administrator accounts undermines the principle of least privilege. Microsoft recommends that organizations have no more than eight Global Administrators.\n\n**Remediation action**\n\n- [Follow best practices for Microsoft Entra roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/best-practices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21812",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nMaximum number of Global Administrators exceeds eight users/service principals.\n\n\n## Global Administrators\n\n### Total number of Global Administrators: 19\n\n| Display Name | Object Type | User Principal Name |\n| :----------- | :---------- | :------------------ |\n| [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | User | gael@elapora.com |\n| [Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1433571b-3d7c-4a56-a9cc-67580848bc73) | User | ravi.kalwani@elapora.com |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6) | User | chukka.p@elapora.com |\n| [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165) | User | ann@elapora.com |\n| [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e) | User | merill@elapora.com |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/518ce209-faf4-4717-add9-7129a669fa11) | User | sandeep.p@elapora.com |\n| [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a) | User | madura@elapora.com |\n| [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7) | User | merillf_gmail.com#EXT#@pora.onmicrosoft.com |\n| [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003) | User | tyler@elapora.com |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7e92f268-bb12-469a-a869-210d596d4c1f) | User | Komal.p@elapora.com |\n| [sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/96252680-04a0-4bec-b5f7-a552c8150525) | User | sushant.p@elapora.com |\n| [manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91) | User | manoj.p@elapora.com |\n| [Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/a85798bd-652b-4eb9-ba90-3ee882df0179) | User | varsha.mane@elapora.com |\n| [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a) | User | joshua@elapora.com |\n| [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d) | User | aleksandar@elapora.com |\n| [elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/e876f7cb-13f3-48a4-8329-66d7b1fa33fb) | Service Principal | N/A |\n| [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854) | User | emergency@elapora.com |\n| [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | Service Principal | N/A |\n| [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6) | User | damien.bowden@elapora.com |\n\n\n\n",
      "TestTitle": "Maximum number of Global Administrators doesn't exceed eight users",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If endpoint analytics isn't enabled, threat actors can exploit gaps in device health, performance, and security posture. Without the visibility Endpoint analytics brings, it can be difficult for an organization to detect indicators such as anomalous device behavior, delayed patching, or configuration drift. These gaps allow attackers to establish persistence, escalate privileges, and move laterally across the environment. An absence of analytics data can impede rapid detection and response, allowing attackers to exploit unmonitored endpoints for command and control, data exfiltration, or further compromise.\n\nEnabling Endpoint Analytics provides visibility into device health and behavior, helping organizations detect risks, respond quickly to threats, and maintain a strong Zero Trust posture.\n\n**Remediation action**\n\nEnroll Windows devices into Endpoint Analytics in Intune to monitor device health and identify risks:  \n- [Enroll Intune devices into Endpoint analytics](https://learn.microsoft.com/intune/analytics/enroll-intune?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:\n- [What is Endpoint analytics?](https://learn.microsoft.com/intune/analytics?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24576",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nEndpoint analytics policy is not created or not assigned.\n\nNo Endpoint Analytics policies found in this tenant.\n\n\n",
      "TestTitle": "Endpoint Analytics is enabled to help identify risks on Windows devices",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If the Intune Company Portal branding isn't configured to represent your organization’s details, users can encounter a generic interface and lack direct support information. This reduces user trust, increases support overhead, and can lead to confusion or delays in resolving issues.\n\nCustomizing the Company Portal with your organization’s branding and support contact details improves user trust, streamlines support, and reinforces the legitimacy of device management communications.\n\n\n**Remediation action**\n\nConfigure the Intune Company Portal with your organization’s branding and support contact information to enhance user experience and reduce support overhead:  \n- [Configure the Intune Company Portal](https://learn.microsoft.com/intune/intune-service/apps/company-portal-app?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "24823",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo Company Portal branding profile with support settings exists or none are assigned.\n\n\n## Company Portal Branding Profiles\n\n| Profile Name | Branding Properties | Status | Assignment Target |\n| :----------- | :------------------ | :----- | :---------------- |\n| [Default Branding profile.](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/TenantAdminMenu/~/companyPortalBranding) | **Display Name**: Pora Labs Inc., **Contact Phone**: Not configured, **Contact Email**: merill@elapora.com | N/A | N/A |\n\n\n\n",
      "TestTitle": "Company Portal branding and support settings enhance user experience and trust",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production",
      "TestSkipped": "",
      "TestDescription": "If device cleanup rules aren't configured in Intune, stale or inactive devices can remain visible in the tenant indefinitely. This leads to cluttered device lists, inaccurate reporting, and reduced visibility into the active device landscape. Unused devices might retain access credentials or tokens, increasing the risk of unauthorized access or misinformed policy decisions. \n\nDevice cleanup rules automatically hide inactive devices from admin views and reports, improving tenant hygiene and reducing administrative burden. This supports Zero Trust by maintaining an accurate and trustworthy device inventory while preserving historical data for audit or investigation.\n\n**Remediation action**\n\nConfigure Intune device cleanup rules to automatically hide inactive devices from the tenant:  \n- [Create a device cleanup rule](https://learn.microsoft.com/intune/intune-service/fundamentals/device-cleanup-rules?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-to-create-a-device-cleanup-rule)\n\nFor more information, see:  \n- [Using Intune device cleanup rules](https://techcommunity.microsoft.com/blog/devicemanagementmicrosoft/using-intune-device-cleanup-rules-updated-version/3760854) *on the Microsoft Tech Community blog*\n\n",
      "TestId": "24802",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo device clean-up rule exists.\n\n\n\n",
      "TestTitle": "Device cleanup rules maintain tenant hygiene by hiding inactive devices",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Organizations that fail to enable custom banned password lists expose themselves to a systematic attack chain where threat actors exploit predictable organizational password patterns. When custom banned passwords are not configured, threat actors can leverage publicly available information about the organization—such as company names, product names, locations, and industry-specific terminology—to construct targeted password dictionaries for credential-based attacks. These threat actors typically begin with reconnaissance phases where they gather organizational intelligence from websites, social media, and public records to identify likely password components. Armed with this knowledge, they launch password spray attacks that test organization-specific password variations across multiple user accounts, staying below lockout thresholds to avoid detection. The absence of custom banned password protection means that even when organizations educate users about password security, employees often still incorporate familiar organizational terms into their passwords, creating consistent attack vectors. This vulnerability becomes particularly severe when threat actors combine organizational terms with common password patterns, as the global banned password list alone cannot anticipate every organization's specific terminology, leaving critical gaps in password protection that enable successful initial access and subsequent lateral movement within the enterprise environment.\n\n**Remediation action**\n\nEnable custom banned password protection and populate with organizational terms:\n- [Configure custom banned passwords for Microsoft Entra password protection](https://learn.microsoft.com/entra/identity/authentication/tutorial-configure-custom-password-protection)\n\n",
      "TestId": "21848",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nCustom banned passwords are properly configured with organization-specific terms to prevent predictable password patterns.\n\n\n## Password protection settings\n\n| Enforce custom list | Custom banned password list | Number of terms |\n| :------------------ | :-------------------------- | :-------------- |\n| [Yes](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/PasswordProtection/fromNav/) | test | 1 |\n\n\n",
      "TestTitle": "Enable custom banned passwords",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Guest accounts with extended sign-in sessions to increase risk surface area that threat actors can exploit through multiple attack vectors. When guest sessions persist beyond necessary timeframes, threat actors who gain initial access through credential stuffing, password spraying, or social engineering attacks can maintain unauthorized access for extended periods without re-authentication challenges. Extended sessions increase risk by allowing unauthorized access to Microsoft Entra artifacts, enabling threat actors to perform reconnaissance activities within the environment, identifying sensitive resources and mapping organizational structures. Once established, these compromised sessions allow threat actors to persist within the network by leveraging legitimate authentication tokens, making detection significantly more challenging as the activity appears as normal user behavior. The extended session duration provides threat actors with a longer window of time to escalate privileges through techniques like accessing shared resources, discovering additional credentials, or exploiting trust relationships between systems. Without proper session controls, threat actors can achieve lateral movement across the organization's infrastructure, accessing critical data and systems that extend far beyond the original guest account's intended scope of access. Microsoft recommends guests to sign in once a day or more often.  \n\n**Remediation action**\n\nReconfigure sign-in frequency policies to have shorter live sign-in sessions. For more information, visit the articles: Configure adaptive session lifetime policies - Microsoft Entra ID | Microsoft Learn \n\nCommon considerations for multitenant user management in Microsoft Entra ID | Azure Docs \n\n",
      "TestId": "21846",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nTemporary Access Pass is configured for one-time use only.\n\n\n## Temporary Access Pass Configuration\n\n| Setting | Value | Status |\n| :------ | :---- | :----- |\n| [One-time use restriction](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AdminAuthMethods/fromNav/) | Enabled | ✅ Pass |\n\n",
      "TestTitle": "Temporary access pass restricted to one-time use",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21964",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Enable protected actions to secure Conditional Access policy creation and changes",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21820",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Activation alert for all privileged role assignments",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "",
      "TestCategory": "Access control",
      "TestSfiPillar": "",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21775",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Tenant app management policy is configured",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21954",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Restrict nonadministrator users from recovering the BitLocker keys for their owned devices",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21813",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "High Global Administrator to privileged user ratio",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21834",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Directory sync account is locked down to specific named location",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21984",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "No Active low priority Entra recommendations found",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21833",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Directory Sync account credentials haven't been rotated recently",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21894",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "All certificates Microsoft Entra Application Registrations and Service Principals must be issued by an approved certification authority",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21843",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Block legacy Microsoft Online PowerShell module",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21893",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Enable Microsoft Entra ID Protection policy to enforce multifactor authentication registration",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "",
      "TestCategory": "Access control",
      "TestSfiPillar": "",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21889",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Reduce the user-visible password surface area",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21895",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Application Certificate Credentials are managed using HSM",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Device management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21837",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Low",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Limit the maximum number of devices per user to 10",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "Without device enrollment notifications, users might be unaware that their device has been enrolled in Intune—particularly in cases of unauthorized or unexpected enrollment. This lack of visibility can delay user reporting of suspicious activity and increase the risk of unmanaged or compromised devices gaining access to corporate resources. Attackers who obtain user credentials or exploit self-enrollment flows can silently onboard devices, bypassing user scrutiny and enabling data exposure or lateral movement.\n\nEnrollment notifications provide users with improved visibility into device onboarding activity. They help detect unauthorized enrollment, reinforce secure provisioning practices, and support Zero Trust principles of visibility, verification, and user engagement.\n\n**Remediation action**\n\nConfigure Intune enrollment notifications to alert users when their device is enrolled and reinforce secure onboarding practices:  \n- [Set up enrollment notifications in Intune](https://learn.microsoft.com/intune/intune-service/enrollment/enrollment-notifications?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\n\n\n\n\n",
      "TestId": "24572",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo device enrollment notification is configured or assigned in Intune.\n\n\n\n",
      "TestTitle": "Device enrollment notifications are enforced to ensure user awareness and secure onboarding",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "External collaboration",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "Guest accounts with extended sign-in sessions increase the risk surface area that threat actors can exploit. When guest sessions persist beyond necessary timeframes, threat actors often attempt to gain initial access through credential stuffing, password spraying, or social engineering attacks. Once they gain access, they can maintain unauthorized access for extended periods without reauthentication challenges. These compromised and extended sessions:\n\n- Allow unauthorized access to Microsoft Entra artifacts, enabling threat actors to identify sensitive resources and map organizational structures.\n- Allow threat actors to persist within the network by using legitimate authentication tokens, making detection more challenging as the activity appears as typical user behavior.\n- Provides threat actors with a longer window of time to escalate privileges through techniques like accessing shared resources, discovering more credentials, or exploiting trust relationships between systems.\n\nWithout proper session controls, threat actors can achieve lateral movement across the organization's infrastructure, accessing critical data and systems that extend far beyond the original guest account's intended scope of access. \n\n**Remediation action**\n- [Configure adaptive session lifetime policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-session-lifetime?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) so sign-in frequency policies have shorter live sign-in sessions.",
      "TestId": "21824",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nGuests do have long lived sign-in sessions.\n\n\n## Sign-in frequency policies\n\n| Policy Name | Sign-in Frequency | Status |\n| :---------- | :---------------- | :----- |\n| [Guest 10 hr MFA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/bcc1a12e-c68d-419e-a6c4-6d4bdfa8bfc8) | 10 hours | ✅ |\n| [MT-Test-MtCaMfaForGuest](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/a16cd40e-1fa7-4151-82f0-baca22b68ede) | Not configured | ❌ |\n| [ALEX - MFA for risky sign-ins](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/5167662e-2022-45a5-825c-4514e5a0cfd4) | 23 hours | ✅ |\n\n\n\n",
      "TestTitle": "Guests don't have long lived sign-in sessions",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Certificates, if not securely stored, can be extracted and exploited by attackers, leading to unauthorized access. Long-lived certificates are more likely to be exposed over time. Credentials, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the privileges of the application.\n\n**Remediation action**\n\n- [Define certificate based application configuration](https://devblogs.microsoft.com/identity/app-management-policy/)\n- [Define trusted certificate authorities for apps and service principals in the tenant](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Define application management policies](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Enforce secret and certificate standards](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/tutorial-enforce-secret-standards?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create a least-privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21773",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Application"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound 6 applications and 5 service principals with certificates longer than 180 days\n\n\n## Applications with long-lived credentials\n\n| Application | Certificate expiry |\n| :--- | :--- |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2125-03-03 |\n\n\n## Service principals with long-lived credentials\n\n| Service principal | App owner tenant | Certificate expiry |\n| :--- | :--- | :--- |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/ba63bb52-182c-4ec6-9cc8-ad2287cf51ed/appId/76249b01-8747-4db4-843f-6478d5b32b14/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-07-30 |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-01-07 |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/84dc13ec-5754-4745-90f9-5cc92a5ded28/appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-07-30 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2027-02-15 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-02-26 |\n\n\n",
      "TestTitle": "Applications don't have certificates with expiration longer than 180 days",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Devices",
      "TestCategory": "Devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "If Terms and Conditions policies aren't configured and assigned in Intune, users can access corporate resources without agreeing to required legal, security, or usage terms. This omission exposes the organization to compliance risks, legal liabilities, and potential misuse of resources.\n\nEnforcing Terms and Conditions ensures users acknowledge and accept company policies before accessing sensitive data or systems, supporting regulatory compliance and responsible resource use.\n\n**Remediation action**\n\nCreate and assign Terms and Conditions policies in Intune to require user acceptance before granting access to corporate resources:  \n- [Create terms and conditions policy](https://learn.microsoft.com/intune/intune-service/enrollment/terms-and-conditions-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "24794",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo Terms and Conditions policy exists or none are assigned.\n\n\n\n",
      "TestTitle": "Terms and Conditions policies protect access to sensitive data",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "## Description\n\nVerifies that all user sign-ins are protected by Conditional Access policies requiring phishing-resistant authentication methods (Windows Hello for Business, FIDO2 security keys, or certificate-based authentication).\n\n**Remediation action**\n\n- [Configure Conditional Access policies to enforce phishing-resistant authentication](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-mfa-strength)\n\n- [Deploy phishing-resistant authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-deploy-phishing-resistant-passwordless-authentication)\n\n",
      "TestId": "21784",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\n❌ Not all users are protected by Conditional Access policies requiring phishing-resistant authentication methods.\n\n**Reason**: Found policies with user exclusions that create coverage gaps\n## Conditional Access Policies with Phishing-Resistant Authentication (Issues Found)\n\n| Policy | Authentication strength | Included Users | Excluded Users |\n| :---------- | :---------------------- | :------------- | :------------- |\n| [Security regisrtation info](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/508ae024-d4c4-42bf-a8c9-40257c214c10) | [Multifactor authentication](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/menuId//fromNav/Identity) | All Users | ⚠️ 2 users |\n\n\n",
      "TestTitle": "All user sign in activity uses phishing-resistant authentication methods",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Monitoring",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "TestDescription": "Microsoft Entra recommendations give organizations opportunities to implement best practices and optimize their security posture. Not acting on these items might result in an increased attack surface area, suboptimal operations, or poor user experience.\n\n**Remediation action**\n\n- [Address all active or postponed recommendations in the Microsoft Entra admin center](https://learn.microsoft.com/entra/identity/monitoring-health/overview-recommendations?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-does-it-work)\n",
      "TestId": "21866",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound 8 unaddressed Entra recommendations.\n\n\n## Unaddressed Entra recommendations\n\n| Display Name | Status | Insights | Priority |\n| :--- | :--- | :--- | :--- |\n| Protect your tenant with Insider Risk condition in Conditional Access policy | active | You have 70 of 70 users that aren’t covered by the Insider Risk condition in a Conditional Access policy. | medium |\n| Protect all users with a user risk policy  | active | You have 3 of 70 users that don’t have a user risk policy enabled.  | high |\n| Protect all users with a sign-in risk policy | active | You have 70 of 70 users that don't have a sign-in risk policy turned on. | high |\n| Enable password hash sync if hybrid | active | You have disabled password hash sync. | medium |\n| Ensure all users can complete multifactor authentication | active | You have 44 of 70 users that aren’t registered with MFA.  | high |\n| Require multifactor authentication for administrative roles | active | You have 3 of 18 users with administrative roles that aren’t registered and protected with MFA. | high |\n| Remove unused credentials from applications | active | Your tenant has applications with credentials which have not been used in more than 30 days. | medium |\n| Remove unused applications | active | This recommendation will surface if your tenant has applications that have not been used for over 90 days. Applications that were created but never used, client applications which have not been issued a token or resource apps that have not been a target of a token request, will show under this recommendation. | medium |\n\n\n",
      "TestTitle": "All Microsoft Entra recommendations are addressed",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without expiration dates, entitlement management policies create persistent access that threat actors can exploit for initial access. When user assignments lack time bounds, compromised credentials maintain access indefinitely, allowing threat actors to establish persistence within the environment. Threat actors can leverage these perpetual assignments to conduct credential access attacks against additional resources. Once threat actors gain initial access through compromised accounts with non-expiring assignments, they can perform privilege escalation by requesting additional access packages or extending existing permissions through the same entitlement management system.Without automatic expiration, threat actors can establish long-term persistence, potentially remaining undetected for extended periods while conducting data exfiltration or further reconnaissance activities.\nRisk Level: Medium - Creates persistent access that can be exploited but requires initial compromise\nUser Impact: Medium - Users must request access renewals when assignments expire\nImplementation Cost: Medium - Organizations need to establish access review processes and renewal workflows\n",
      "TestId": "21878",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "❌ Not all entitlement management policies have expiration dates configured.\n### Entitlement Management Assignment Policies with Expiration Dates\n| Name | Expiration Type | Duration / End DateTime |\n| :--- | :--- | ---: |\n| [test Policy](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/test%20Policy) | afterDuration | P365D |\n| [All users](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/All%20users) | afterDateTime | 11/15/2027 12:59:59 |\n| [Initial Policy](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/Initial%20Policy) | afterDuration | P365D |\n| [Initial Policy](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/Initial%20Policy) | afterDuration | P365D |\n\n#### Policies missing expiration:\n| Name | Expiration Type | Duration / End DateTime |\n| :--- | :--- | ---: |\n| [External](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/External) | noExpiration |  |  |\n| [All users](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/All%20users) | noExpiration |  |  |\n| [All users](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/All%20users) | noExpiration |  |  |\n",
      "TestTitle": "All entitlement management policies have an expiration date",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Credential management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.\n\nAttackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.\n\n**Remediation action**\n\n- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy a Conditional Access policy to require phishing-resistant MFA for all users](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestId": "21801",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Credential"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound users that have not yet registered phishing resistant authentication methods\n\n## Users strong authentication methods\n\nFound users that have not registered phishing resistant authentication methods.\n\nUser | Last sign in | Phishing resistant method registered |\n| :--- | :--- | :---: |\n|[Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true)| 2025-11-10 | ❌ |\n|[Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Anna Jorayew](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/58d9ed99-93ca-4674-8c5f-ec770f5ba17d/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Bagul Atayewa](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5655cf54-34bc-4f36-bb74-44da35547975/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true)| 10/16/2025 12:44:48 | ❌ |\n|[Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true)| 01/20/2024 08:00:27 | ❌ |\n|[Daniel Nguyen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ddfb9311-801e-4a84-9466-a18086768b73/hidePreviewBanner~/true)| Unknown | ❌ |\n|[David Kim](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1b156c3d-79c5-44d2-a88c-23f69216777f/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Emma Johnson](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e498eab5-b6b5-493f-8353-b8c350083791/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Faiza Malkia](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/36bf7e02-3abc-46aa-895f-cf95227377fd/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0b37813c-ae19-4399-982f-16587f17f9c0/hidePreviewBanner~/true)| 09/29/2025 20:06:21 | ❌ |\n|[Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true)| 11/15/2023 18:36:22 | ❌ |\n|[Hamisi Khari](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/494995bf-5510-450c-a317-6d24f63cd15b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Henrietta Mueller](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/eb6a4040-3ff6-4911-a80d-68c701384c38/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Isaiah Langer](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2a054082-8f05-4e05-8fce-4e35c3bb40cc/hidePreviewBanner~/true)| 2023-12-12 | ❌ |\n|[Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0145d508-50fd-4f86-a47a-bf1c043c8358/hidePreviewBanner~/true)| Unknown | ❌ |\n|[James Thompson](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ba635de8-4625-42eb-a59a-87f507ad9a9e/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Jane Doe](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/57c41b80-a96a-4c06-8ab9-9539818a637f/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Jessica Taylor](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/983164a3-87fa-4071-aa67-ff1530092df1/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Johanna Lorenz](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/8994aee7-8c36-4e04-9116-8f21d8acdeb7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John Doe Test 1](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/fcebe3cc-ca26-49c6-9bb1-c9eafb243634/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John Doe Test 1](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/69a2da18-6395-4a90-bde8-72e8aaa6c775/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John1 Doe](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/77d4be98-c05d-4478-be25-3ee710b5247e/hidePreviewBanner~/true)| 2024-04-11 | ❌ |\n|[Joni Sherman](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2da436f2-952a-47de-9dfe-84bd2f0d93e9/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true)| 10/16/2025 12:16:25 | ❌ |\n|[Lee Gu](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0a9e313b-8777-4741-ba14-0f2724179117/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Lidia Holloway](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/9188d3d3-386c-4145-a811-0d777a288e11/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Lynne Robbins](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/8e5f7749-d5e7-46fc-8eb7-3b8ab7e20ae5/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true)| 07/30/2025 03:28:21 | ❌ |\n|[manoj.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true)| 10/16/2025 12:36:46 | ❌ |\n|[Megan Bowen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/96d29f01-873c-46a3-b542-f7ee192cc675/hidePreviewBanner~/true)| 06/28/2025 12:47:54 | ❌ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a0883b7a-c6a8-440f-84f0-d6e1b79aaf4c/hidePreviewBanner~/true)| 2025-10-08 | ❌ |\n|[Michael Wong](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/63e4e634-15e4-4a85-bc9c-532855574377/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Miriam Graham](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f5745554-1894-4fb0-9560-65d6fc489724/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Nestor Wilke](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/24b9254d-1bc5-435c-ad3d-7dbee86f8b9a/hidePreviewBanner~/true)| Unknown | ❌ |\n|[New User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/6eef8ea0-1263-4973-9b0b-1e7aed0d21cd/hidePreviewBanner~/true)| Unknown | ❌ |\n|[No Location](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/696743fa-055b-42fb-aac4-ab451a4617d6/hidePreviewBanner~/true)| Unknown | ❌ |\n|[NoMail Enabled](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a740d122-ee21-4354-9423-adccf8b6b233/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Olivia Patel](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/03a5c332-4d75-47fd-b211-838e8cd0ee1b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f/hidePreviewBanner~/true)| 06/17/2024 04:12:01 | ❌ |\n|[Patti Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/3bae3a95-7605-4271-8418-e35733991834/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Pradeep Gupta](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ac712f60-0052-4911-8c5d-146cf9d4dc59/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1433571b-3d7c-4a56-a9cc-67580848bc73/hidePreviewBanner~/true)| 09/23/2025 23:03:25 | ❌ |\n|[Rhea Stone](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ac49a6e5-09c1-404b-915e-0d28574b3d72/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Richard Wilkings](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c27e2b23-c322-4a79-8c6f-9dba8fd9f4e2/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Roi Fraguela](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e0a814e5-5169-4af2-bb19-63930b42ac41/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Ryan Chen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/9605b9f8-9823-4c33-8018-57ad32d9fcb9/hidePreviewBanner~/true)| Unknown | ❌ |\n|[sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true)| 10/16/2025 06:38:12 | ❌ |\n|[Sandy](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d5e32d0c-3f3c-43ef-abe1-75890a73f40c/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Sarah Mehrotra](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2d79a82a-ae19-461a-a0aa-807045ec3c4e/hidePreviewBanner~/true)| 10/15/2025 07:05:29 | ❌ |\n|[Sarah Mitchell](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0ca3a9f0-7e3c-44c5-9638-250be0d94621/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Shonali Balakrishna](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/305bbf73-eee4-4e0c-9c7d-627e00ed3665/hidePreviewBanner~/true)| 2025-05-05 | ❌ |\n|[Simon Burn](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c3aab1a2-0733-438d-bc14-90dc8f6d876d/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Sophia Rodriguez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d5d9f31f-c8d7-4b6c-bfca-b25b1cd4c1f1/hidePreviewBanner~/true)| Unknown | ❌ |\n|[sushant.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/96252680-04a0-4bec-b5f7-a552c8150525/hidePreviewBanner~/true)| 09/30/2025 04:27:48 | ❌ |\n|[Tegra Núnez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/25e54254-3719-4c07-a880-3aee6bc60876/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Tracy yu](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/80153e0b-dcce-42de-9df6-59a3fc89479b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true)| 2025-04-02 | ❌ |\n|[Unlicensed User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7804b01c-1223-4045-a393-43171298fa6b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[usernonick](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/b531f68f-8d01-467b-9db6-a57438b0e8af/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a85798bd-652b-4eb9-ba90-3ee882df0179/hidePreviewBanner~/true)| 2025-08-10 | ❌ |\n|[Wilna Rossouw](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/62cd4528-8e5d-4789-84f6-8b33d0af5ca7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Yakup Meredow](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/767bcbda-28a0-4e5f-841d-e918c5a1c229/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Diego Siciliani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/cdfa577c-972f-4399-98aa-1ec4be7fa6d1/hidePreviewBanner~/true)| 06/28/2025 23:31:12 | ✅ |\n|[Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true)| 07/15/2025 14:47:39 | ✅ |\n|[Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true)| 08/27/2025 03:23:04 | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| 10/16/2025 11:51:23 | ✅ |\n|[perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true)| 10/16/2025 05:23:06 | ✅ |\n\n\n",
      "TestTitle": "Users have strong authentication methods configured",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Accelerate response and remediation",
      "TestSkipped": "",
      "TestDescription": "Set up risk-based Conditional Access policies for workload identities based on risk policy in Microsoft Entra ID to make sure only trusted and verified workloads use sensitive resources. Without these policies, threat actors can compromise workload identities with minimal detection and perform further attacks. Without conditional controls to detect anomalous activity and other risks, there's no check against malicious operations like token forgery, access to sensitive resources, and disruption of workloads. The lack of automated containment mechanisms increases dwell time and affects the confidentiality, integrity, and availability of critical services.   \n\n**Remediation action**\nCreate a risk-based Conditional Access policy for workload identities.\n- [Create a risk-based Conditional Access policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-risk-based-conditional-access-policy)   \n",
      "TestId": "21883",
      "SkippedReason": null,
      "TestImpact": "High",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nWorkload identities based on risk policy is not configured.\n\n",
      "TestTitle": "Workload Identities are configured with risk-based policies",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Legacy authentication protocols such as basic authentication for SMTP and IMAP don't support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This lack of protection makes accounts using these protocols vulnerable to password-based attacks, and provides attackers with a means to gain initial access using stolen or guessed credentials.\n\nWhen an attacker successfully gains unauthorized access to credentials, they can use them to access linked services, using the weak authentication method as an entry point. Attackers who gain access through legacy authentication might make changes to Microsoft Exchange, such as configuring mail forwarding rules or changing other settings, allowing them to maintain continued access to sensitive communications.\n\nLegacy authentication also provides attackers with a consistent method to reenter a system using compromised credentials without triggering security alerts or requiring reauthentication.\n\nFrom there, attackers can use legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement. Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to Block legacy authentication](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21796",
      "SkippedReason": null,
      "TestImpact": "High",
      "TestRisk": "Medium",
      "TestTags": [
        "User",
        "Credential"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPolicies to block legacy authentication were found but are not properly configured.\n\n  - [Block legacy authentication](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/4086128c-3850-48ac-8962-e19a956828bd) (Report-only)\n  - [Block legacy authentication - Testing](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/bedecc1e-85c9-4d54-b885-cefe6bcc8763) (Report-only)\n\n\n",
      "TestTitle": "Block legacy authentication policy is configured",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they’re legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21770",
      "SkippedReason": null,
      "TestImpact": "High",
      "TestRisk": "Medium",
      "TestTags": [
        "Application"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nInactive Application(s) with high privileges were found\n\n\n## Apps with privileged Graph permissions\n\n| | Name | Risk | Delegate Permission | Application Permission | App owner tenant | Last sign in|\n| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n| ❌ | [Modern Workplace Concierge](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad1c51e8-f8a8-4bf2-ac09-a3a20cba5fa5/appId/c65c4011-1b90-4ec9-b5e9-1ee17786ad84) | High | openid, profile, RoleManagement.Read.Directory, Application.Read.All, User.ReadBasic.All, Group.ReadWrite.All, DeviceManagementRBAC.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, Policy.Read.All, User.Read, DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All |  | Nicolonsky Tech | Unknown | \n| ❌ | [Azure AD Assessment (Test)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d4cf4286-0fbe-424d-b4f2-65aa2c568631/appId/c62a9fcb-53bf-446e-8063-ea6e2bfcc023) | High | AuditLog.Read.All, Directory.AccessAsUser.All, Directory.ReadWrite.All, Group.ReadWrite.All, IdentityProvider.ReadWrite.All, Policy.ReadWrite.TrustFramework, PrivilegedAccess.ReadWrite.AzureAD, PrivilegedAccess.ReadWrite.AzureResources, TrustFrameworkKeySet.ReadWrite.All, User.Invite.All, offline_access, openid, profile |  | Microsoft Accounts | Unknown | \n| ❌ | [Windows Virtual Desktop AME](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8369f33c-da25-4a8a-866d-b0145e29ef29/appId/5a0aa725-4958-4b0c-80a9-34562e23f3b7) | High |  | User.Read.All, Directory.Read.All | MS Azure Cloud | Unknown | \n| ❌ | [Graph Explorer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f8f300a-870a-46ff-bdab-934e1436920d/appId/d3ce4cf8-6810-442d-b42e-375e14710095) | High | User.Read, Directory.AccessAsUser.All |  | graphExplorerMT | Unknown | \n| ❌ | [Microsoft Sample Data Packs](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/63e1f0d4-bc2c-497a-bfe2-9eb4c8c2600e/appId/a1cffbc6-1cb3-44e4-a1d2-cee9cce700f1) | High | Files.ReadWrite, User.ReadWrite | Calendars.ReadWrite.All, Mail.ReadWrite, User.ReadWrite.All, MailboxSettings.ReadWrite, Sites.ReadWrite.All, Mail.Send, Sites.FullControl.All, Calendars.ReadWrite, Application.ReadWrite.OwnedBy, Contacts.ReadWrite, Sites.Manage.All, Directory.ReadWrite.All, Files.ReadWrite.All, Group.ReadWrite.All | Microsoft | Unknown | \n| ❌ | [Reset Viral Users Redemption Status](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3a8785da-9965-473f-a97c-25fefdc39fee/appId/cc7b0696-1956-408b-876a-ad6bf2b9890b) | High | User.Read, User.Invite.All, User.ReadWrite.All, Directory.ReadWrite.All, offline_access, profile, openid |  | Microsoft | Unknown | \n| ✅ | [Microsoft Assessment React](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0a8b4459-b0c2-4cb8-baeb-c4c5a6a8f14b/appId/c4b110d7-6f1d-473d-aa9e-6e74b8b8bd4b) | Unranked | User.Read, openid, profile, offline_access |  | Microsoft | 2023-02-25 | \n| ✅ | [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/043dd83b-94ce-4d12-b54b-45d77979f05a/appId/0b75bb7b-d365-4c29-92ea-e2799d2a3fce) | Unranked | User.Read, openid, profile, offline_access |  | Merill | 2023-03-11 | \n| ✅ | [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/30aa6cd2-1aab-42fd-a235-0521713f4532/appId/afe793df-19e0-455a-8403-2e863379bfaa) | Unranked | User.Read, openid, profile, offline_access |  | Merill | 2023-03-11 | \n| ✅ | [Canva](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/37ae3acb-5850-49e8-a0f8-cb06f5a77417/appId/2c0bebe0-bdb3-4909-8955-7ef311f0db22) | Unranked | email, openid, profile, User.Read |  | Default Directory | 2023-04-27 | \n| ✅ | [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b66231c2-9568-46f1-b61e-c5f8fd9edee4/appId/50827722-4f53-48ba-ae58-db63bb53626b) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  | Merill | 2023-07-05 | \n| ✅ | [idPowerToys - Release](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4654e05d-9f59-4925-807c-8eb2306e1cb1/appId/904e4864-f3c3-4d2f-ace2-c37a4ed55145) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  | Merill | 2023-10-24 | \n| ✅ | [Azure AD Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6c74be7f-bcc9-4541-bfe1-f113b90b0497/appId/68bc31c0-f891-4f4c-9309-c6104f7be41b) | High | Organization.Read.All, RoleManagement.Read.Directory, Application.Read.All, User.Read.All, Group.Read.All, Policy.Read.All, Directory.Read.All, SecurityEvents.Read.All, UserAuthenticationMethod.Read.All, AuditLog.Read.All, Reports.Read.All, openid, offline_access, profile |  | Microsoft | 2023-10-27 | \n| ✅ | [EAM Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24b12ae7-4648-4aae-b00c-6349a565d24c/appId/e6e0be31-7040-4084-ac44-600b67661f2c) | Unranked | profile, openid |  | Merill | 2024-01-30 | \n| ✅ | [Azure Static Web Apps](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6b1f4a00-db4e-43ae-b62b-2286d4fcc4ea/appId/d414ee2d-73e5-4e5b-bb16-03ef55fea597) | Unranked | openid, profile, email |  | MS Azure Cloud | 2024-05-27 | \n| ✅ | [FIDO2-passkeys-MFA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1aa7e155-cbf8-4970-8458-05a0c7a2d1a5/appId/4fabcfc0-5c44-45a1-8c80-8537f0625949) | Unranked | profile, openid |  | Merill | 2024-09-25 | \n| ✅ | [idPowerToys for Desktop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24cc58d8-2844-4974-b7cd-21c8a470e6bb/appId/520aa3af-bd78-4631-8f87-d48d356940ed) | High | Directory.Read.All, Policy.Read.All, Agreement.Read.All, CrossTenantInformation.ReadBasic.All, openid, profile, offline_access |  | Merill | 2025-02-16 | \n| ✅ | [entraChatAppMultiTenant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/855a57ff-88a6-4ad0-85d7-4f46d742730e/appId/5e00b345-a805-42a0-9caa-7d6cb761c668) | High | User.Read, openid, profile, offline_access, APIConnectors.Read.All, Application.ReadWrite.All, Policy.ReadWrite.AuthenticationFlows, Policy.Read.All, EventListener.ReadWrite.All, Policy.ReadWrite.AuthenticationMethod, Group.Read.All, AuditLog.Read.All, Policy.ReadWrite.ConditionalAccess, IdentityUserFlow.Read.All, Policy.ReadWrite.TrustFramework, TrustFrameworkKeySet.Read.All, Directory.ReadWrite.All |  | JJ Industries | 2025-05-08 | \n| ✅ | [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad36b6e2-273d-4652-a505-8481f096e513/appId/6ce0484b-2ae6-4458-b2b9-b3369f42fd6f) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  | Merill | 2025-05-30 | \n| ✅ | [Opticom](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3f142d86-14ba-4173-9458-be7fb36b37f7/appId/dd939d5a-d248-4f58-a25f-26a6b3f5183e) | Unranked | email, openid, profile, User.Read |  | Pora Inc. | 2025-07-24 | \n| ✅ | [Intune Documentation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/97b66fb0-f682-41e0-9aef-47f170c2abae/appId/56066daa-baba-438f-89d0-7ea3be2e2222) | High | User.Read, DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All, DeviceManagementManagedDevices.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, Group.Read.All, openid, profile, offline_access |  | Ugur Koc Lab | 2025-09-01 | \n| ✅ | [AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/77198970-f1eb-4574-9a1a-6af175a283af/appId/2e311a1d-f5c0-41c6-b866-77af3289871e) | Unranked | User.Read, openid, profile, offline_access |  | Pora Inc. | 2025-09-09 | \n| ✅ | [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3dde25cc-223f-4a16-8e8f-6695940b9680/appId/e7dfcbb6-fe86-44a2-b512-8d361dcc3d30) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, DeviceManagementServiceConfig.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementApps.Read.All, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, PrivilegedEligibilitySchedule.Read.AzureADGroup, openid, profile, offline_access |  | Pora | 2025-09-09 | \n| ✅ | [graph-developer-proxy-samples](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e6570bb8-fdea-4329-82e2-2809d8fb67a7/appId/3658d9e9-dc87-4345-b59b-184febcf6781) | Unranked | User.Read.All, Presence.Read.All |  | Pora | 2025-09-09 | \n| ✅ | [idpowerelectron](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cb64f850-a076-42d5-8dd8-cfd67d9e67f1/appId/909fff82-5b0a-4ce5-b66d-db58ee1a925d) | Unranked | openid, profile, offline_access |  | Pora | 2025-09-09 | \n| ✅ | [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/35cbeecb-be21-4596-9869-0157d84f2d67/appId/c823a25d-fe94-494c-91f6-c7d51bf2df82) | High | User.Read | Sites.FullControl.All | Pora | 2025-09-09 | \n| ✅ | [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f79df990-9ad2-4142-b5fd-8945ff334da3/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | High | User.Read | Directory.ReadWrite.All | Entra.Chat | 2025-09-09 | \n| ✅ | [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6bf7c616-88e8-4f7c-bdad-452e561fa777/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | High |  | User.ReadWrite.All | Pora | 2025-09-09 | \n| ✅ | [test public client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5e80ea33-31fa-49fd-9a94-61894bd1a6c9/appId/79a0c604-f215-4c52-8fbe-641d08aa7937) | High |  | User.Read.All | Pora | 2025-09-09 | \n| ✅ | [Atlassian - Jira](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2425e515-5720-4071-9fae-fd50f153c0aa/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c) | Unranked | User.Read |  | Pora Inc. | 2025-09-09 | \n| ✅ | [Entry Kiosk](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/83adcc80-3a35-4fdc-9c5b-1f6b9061508e/appId/b903f17a-87b0-460b-9978-962c812e4f98) | Unranked | User.Read |  | Pora | 2025-09-09 | \n| ✅ | [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a15dc834-08ce-4fd8-85de-3729fff8e34f/appId/d36fe320-bc28-40c8-a141-a512d65d112c) | High | User.Read | Application.Read.All | Pora | 2025-09-09 | \n| ✅ | [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bac0ba57-1876-448e-96bf-6f0481c99fda/appId/fef811e1-2354-43b0-961b-248fe15e737d) | High | User.Read, Directory.Read.All |  | Pora | 2025-09-09 | \n| ✅ | [Lokka](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1abc3899-a5df-40ab-8aa7-95d31edd4c01/appId/f581405a-9e57-4e81-91f1-40cd62f7595e) | High |  | PrivilegedAccess.Read.AzureADGroup, DirectoryRecommendations.Read.All, Policy.ReadWrite.Authorization, PrivilegedAccess.Read.AzureAD, Reports.Read.All, Mail.Send, DeviceManagementConfiguration.ReadWrite.All, IdentityRiskEvent.Read.All, Policy.Read.All, User.Read.All, Mail.Read, Directory.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, UserAuthenticationMethod.Read.All | Pora Inc. | 2025-09-09 | \n| ✅ | [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e31cd01e-afaf-4cc3-8d15-d3f9f7eb61e8/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) | High |  | Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, SecurityIdentitiesSensors.Read.All, Mail.Send, SecurityIdentitiesHealth.Read.All, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | Pora Inc. | 2025-09-09 | \n| ✅ | [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e9fca357-cccd-4ec4-840f-7482f6f02818/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) | High |  | User.Read.All | Pora | 2025-09-09 | \n| ✅ | [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6d2e8d37-82b8-41e7-aa95-443a7401e8b8/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | High | User.Read | User.ReadWrite.All, TermStore.Read.All, User.Read.All, Sites.FullControl.All | Pora | 2025-09-09 | \n| ✅ | [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/aa64efdb-2d05-4c81-a9e5-80294bf0afac/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) | High | Policy.Read.All, User.Read, Directory.ReadWrite.All, Mail.ReadWrite | Mail.ReadWrite, Directory.ReadWrite.All | Pora | 2025-09-09 | \n| ✅ | [SharePoint On-Prem App Proxy](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/53c7bdb1-cae2-43b0-9e2e-d8605395ceec/appId/19a70df3-cddf-48c7-be44-97b25b9857f1) | Unranked | User.Read |  | Pora Inc. | 2025-09-09 | \n| ✅ | [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/666a58ef-c3e5-4efc-828a-2ab3c0120677/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | High | User.Read | Sites.Read.All, Sites.Read.All | Pora | 2025-09-09 | \n| ✅ | [Trello](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3d6c91cf-d48f-4272-ac4c-9f989bbec779/appId/d77611ee-5051-4383-9af3-5ba3627306a7) | High |  | Application.Read.All | Pora Inc. | 2025-09-09 | \n| ✅ | [WebApplication4](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5bc56e47-7a8a-4e71-b25f-8c4e373f40a6/appId/b2d1f868-27ee-4ecd-ae81-0ee96b028605) | Unranked | User.Read |  | Pora | 2025-09-09 | \n| ✅ | [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/89bd9c7a-0c81-4a0a-9153-ff7cd0b81352/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) | High |  | GroupMember.Read.All, User.Read.All | Pora | 2025-09-09 | \n| ✅ | [My Doc Gen](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a445d652-f72d-4a88-9493-79d3c3c23d1b/appId/e580347d-d0aa-4aa1-9113-5daa0bb1c805) | High | User.Read, openid, profile, offline_access, Directory.Read.All, Policy.Read.All, Agreement.Read.All, CrossTenantInformation.ReadBasic.All |  | Pora | 2025-09-09 | \n| ✅ | [MyTokenTestApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/60923f18-748f-42bb-a0b2-ee60d44e17fc/appId/6a846cb7-35ad-41b2-b10a-0c5decde9855) | Unranked | profile, openid |  | Pora | 2025-09-09 | \n| ✅ | [Microsoft Graph PowerShell - Used by Team Incredibles](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e67821d9-a20b-43ef-9c34-76a321643b4f/appId/2935f660-810c-41ff-b9ad-168cc649e36f) | Unranked | User.Read, openid, profile, offline_access |  | Pora | 2025-09-09 | \n| ✅ | [MyZt](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/716038b1-2811-40fc-8622-93e093890af0/appId/eee51d92-0bb5-4467-be6a-8f24ef677e4d) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, DeviceManagementServiceConfig.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementApps.Read.All, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, PrivilegedEligibilitySchedule.Read.AzureADGroup, openid, profile, offline_access |  | Pora | 2025-09-09 | \n| ✅ | [MyZtA\\[\\[](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d2a2a09d-7562-45fc-a950-36fedfb790f8/appId/d159fcf5-a613-435b-8195-8add3cdf4bff) | High | RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, Policy.Read.All, Agreement.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, User.Read, Directory.Read.All, PrivilegedEligibilitySchedule.Read.AzureADGroup, CrossTenantInformation.ReadBasic.All |  | Pora | 2025-09-09 | \n| ✅ | [CachingSampleApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/59187561-8df5-4792-b3a4-f6ca8b54bfc7/appId/3d6835ff-f7f4-4a83-adb5-67ccdd934717) | Unranked | User.Read, openid, profile, offline_access |  | Pora | 2025-09-09 | \n| ✅ | [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d54232da-de3b-4874-aef2-5203dbd7342a/appId/d99dd249-6ab3-4e92-be40-81af11658359) | High | User.Read | Mail.Send, DirectoryRecommendations.Read.All, PrivilegedAccess.Read.AzureAD, Reports.Read.All, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All | Pora | 2025-09-09 | \n| ✅ | [Graph PS - Zero Trust Workshop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f6e8dfdd-4c84-441f-ae6e-f2f51fd20699/appId/a9632ced-c276-4c2b-9288-3a34b755eaa9) | High | AuditLog.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, UserAuthenticationMethod.Read.All, openid, profile, offline_access |  | Pora | 2025-09-09 | \n| ✅ | [Maester DevOps Account - GitHub](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ce3af345-b0e0-4b15-808c-937d825bcf03/appId/f050a85f-390b-4d43-85a0-2196b706bfd6) | High |  | Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, Mail.Send, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | Entra.Chat | 2025-09-09 | \n| ✅ | [Maester DevOps Account - New GitHub Action](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7c1885fd-fdf8-413a-86a6-f8867914272f/appId/143cb1b1-81af-4999-a292-a8c537601119) | High | User.Read | Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | Pora Inc. | 2025-09-09 | \n| ✅ | [Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/552daa69-8057-4684-8c93-2c41963aff01/appId/f864cc86-0f4f-4861-9583-2580817e4f88) | Unranked | openid, profile |  | Pora Inc. | 2025-09-09 | \n| ✅ | [Maester Automation App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e3972142-1d36-4e7d-a777-ecd64619fcab/appId/55635484-743e-42e2-a78e-6bc15050ebde) | High | User.Read | Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, Mail.Send, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | Pora Inc. | 2025-09-09 | \n| ✅ | [Lokka-2-interactive](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/794b2542-39aa-433c-90c6-6ab5df851ffc/appId/e6ea9510-0e81-465a-ae7b-efaff41bd719) | Unranked | User.Read, User.Read.All |  | Pora Inc. | 2025-09-09 | \n| ✅ | [Contoso Access Verifier](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/41d3b041-9859-4830-8feb-72ffd7afad65/appId/a6af3433-bc44-4d27-9b35-81d10fd51315) | Unranked | openid, profile, User.Read |  | Pora | 2025-09-09 | \n| ✅ | [elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c5632968-35cd-445d-926e-16e0afc9160e/appId/e876f7cb-13f3-48a4-8329-66d7b1fa33fb) | High |  | Policy.ReadWrite.Authorization, Policy.ReadWrite.DeviceConfiguration, Directory.ReadWrite.All | Pora Inc. | 2025-10-01 | \n| ✅ | [Message Center](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/158f6ef9-a65d-45f2-bdf0-b0a1db70ebd4/appId/83f76a08-fa60-48e6-9cb5-fd8ced5ae314) | Unranked | User.Read | ServiceMessage.Read.All | Pora Inc. | 2025-10-11 | \n| ✅ | [ASPNET-Tutorial](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6e2f1852-1b3c-4516-a078-551846b5cf49/appId/059da61d-d02e-40ee-8140-6842d5819f18) | Unranked | User.Read |  | Pora | 2025-10-15 | \n| ✅ | [elapora-maester-demo-39ecb2b6-d900-496e-886f-d112cca4f1a9](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cc578aea-b1bd-434d-86d2-8a22c5728ded/appId/efec213e-0a85-4d7a-938f-3d97edd4ade0) | High |  | Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, Reports.Read.All, ThreatHunting.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, SecurityIdentitiesSensors.Read.All, ReportSettings.Read.All, SecurityIdentitiesHealth.Read.All, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | Pora Inc. | 2025-10-15 | \n| ✅ | [elapora-Maester-54d3ea01-5a07-45d0-8d69-e5f5b0b20098](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4faa0456-5ecb-49f3-bb9a-2dbe516e939a/appId/a8c184ae-8ddf-41f3-8881-c090b43c385f) | High |  | Mail.Send, Directory.Read.All, Policy.Read.All, DirectoryRecommendations.Read.All, Reports.Read.All | Pora | 2025-10-15 | \n| ✅ | [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7c32eaee-ff26-4435-be3d-b4ced08f9edc/appId/303774c1-3c6f-4dfd-8505-f24e82f9212a) | High | User.Read | Policy.Read.ConditionalAccess, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | Pora | 2025-10-15 | \n| ✅ | [entra-docs-email github DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7a94aec7-a5e3-48dd-b20f-3db74d689434/appId/ae06b71a-a0aa-4211-b846-fd74f25ccd45) | High | User.Read | Mail.Send | Pora Inc. | 2025-10-15 | \n| ✅ | [Maester DevOps Account - merill/maester-demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fdce906b-d2f6-4738-8c76-e4559b9e17e8/appId/91c84d77-3dce-4fb0-b0de-474a8606c812) | High |  | DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, SecurityIdentitiesSensors.Read.All, ReportSettings.Read.All, SecurityIdentitiesHealth.Read.All, DirectoryRecommendations.Read.All, Reports.Read.All, ThreatHunting.Read.All, PrivilegedAccess.Read.AzureAD, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | Pora Inc. | 2025-10-15 | \n| ✅ | [GitHub Actions App for Microsoft Info script](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/852b4218-67d2-4046-a9a6-f8b47430ccdf/appId/38535360-9f3e-4b1e-a41e-b4af46afcb0c) | High |  | Application.Read.All | Pora | 2025-10-16 | \n| ✅ | [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/427b14ca-13b3-4911-b67e-9ff626614781/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) | Unranked |  | ServiceMessage.Read.All | Entra.Chat | 2025-10-16 | \n| ✅ | [Calendar Pro](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/36e156e4-4566-44a0-b05c-a112017086b5/appId/fb507a6d-2eaa-4f1f-b43a-140f388c4445) | Unranked | profile, offline_access, email, openid, User.Read, User.ReadBasic.All |  | Witivio | Unknown | \n\n\n",
      "TestTitle": "Inactive applications don’t have highly privileged Microsoft Graph API permissions",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When workload identities such as service principals and applications are compromised, threat actors gain persistence and elevated access to organizational resources without requiring user interaction or multifactor authentication. Microsoft Entra ID Protection continuously monitors workload identities for suspicious activities including leaked credentials, anomalous API traffic, malicious applications, and suspicious sign-in patterns. Unaddressed risky workload identities provide threat actors with a pathway to escalate privileges through credential exploitation, perform lateral movement across cloud resources, exfiltrate sensitive data through automated access patterns, and establish persistent backdoors that bypass traditional user-based security controls. Organizations must implement systematic triage processes to investigate detected risks, confirm legitimate activity or compromised states, and apply appropriate remediation actions to prevent threat actors from leveraging compromised workload identities to achieve their objectives within the Microsoft cloud ecosystem.\n\n**Remediation action**\n\n- [Investigate and remediate risky workload identities](https://learn.microsoft.com/entra/id-protection/concept-workload-identity-risk)\n- [Securing workload identities with Microsoft Entra ID Protection](https://learn.microsoft.com/entra/id-protection/concept-workload-identity-risk)\n- [Apply conditional access policies for workload identities](https://learn.microsoft.com/entra/identity/conditional-access/workload-identity) (requires Microsoft Entra Workload ID licensing)\n- [Microsoft Entra Conditional Access for workload identities](https://learn.microsoft.com/entra/identity/conditional-access/workload-identity)\n\n",
      "TestId": 21862,
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nFound 1 untriaged risky service principals and 0 untriaged risk detections\n\n## Untriaged Risky Service Principals\n\n| Service Principal | Type | Risk Level | Risk State | Risk Last Updated |\n| :--- | :--- | :--- | :--- | :--- |\n| [WingtipToys App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/606738dd-7f66-43ce-9959-f411ced435fd/appId/56a89db1-6ed2-4171-88f6-b4f7597dbce3) | Application | High | At Risk | 12/04/2023 22:34:28 |\n\n",
      "TestTitle": "All risky workload identities are triaged",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "External collaboration",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "Without configured domain allow/deny lists for external collaboration, organizations lack essential domain-level access controls that act as the frontline defense in their security model. Domain allow/deny lists operate at the tenant level and take precedence over Cross-Tenant Access Policies (XTAP), blocking invitations from domains on the deny list regardless of cross-tenant access settings. While XTAP enables granular controls for specific trusted tenants, domain restrictions are critical for preventing invitations from unknown or unverified domains that haven't been explicitly allowed.\n\nWithout these restrictions, internal users can invite external accounts from any domain—including potentially compromised or attacker-controlled domains. Threat actors can register domains that appear legitimate to conduct social engineering attacks, tricking users into sending collaboration invitations that circumvent XTAP's targeted protections. Once granted access, these external guest accounts can be used for reconnaissance, mapping internal resources, user relationships, and collaboration patterns.\n\nThese invited accounts provide persistent access that appears legitimate in audit logs and security monitoring systems. Attackers can maintain a long-term presence to collect data, access shared resources, documents, and applications configured for external collaboration, and potentially exfiltrate data through authorized channels without triggering alerts.\n\n**Remediation action**\n- [Configure domain-based allow or deny lists](https://learn.microsoft.com/en-us/entra/external-id/allow-deny-list?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#set-the-allow-or-blocklist-policy-in-the-portal)",
      "TestId": "21874",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nAllow/Deny lists of domains to restrict external collaboration are not configured.\n\n",
      "TestTitle": "Allow/Deny lists of domains to restrict external collaboration are configured",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "Letting group owners consent to applications in Microsoft Entra ID creates a lateral escalation path that lets threat actors persist and steal data without admin credentials. If an attacker compromises a group owner account, they can register or use a malicious application and consent to high-privilege Graph API permissions scoped to the group. Attackers can potentially read all Teams messages, access SharePoint files, or manage group membership. This consent action creates a long-lived application identity with delegated or application permissions. The attacker maintains persistence with OAuth tokens, steals sensitive data from team channels and files, and impersonates users through messaging or email permissions. Without centralized enforcement of app consent policies, security teams lose visibility, and malicious applications spread under the radar, enabling multi-stage attacks across collaboration platforms.\n\n**Remediation action**\nConfigure preapproval of Resource-Specific Consent (RSC) permissions.\n- [Preapproval of RSC permissions](https://learn.microsoft.com/microsoftteams/platform/graph-api/rsc/preapproval-instruction-docs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21810",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nResource-Specific Consent is not restricted.\n\nThe current state is ManagedByMicrosoft.\n\n\n",
      "TestTitle": "Resource-specific consent is restricted",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "External collaboration",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "When guest identities remain active but unused for extended periods, threat actors can exploit these dormant accounts as entry vectors into the organization. Inactive guest accounts represent a significant attack surface because they often maintain persistent access permissions to resources, applications, and data while remaining unmonitored by security teams. Threat actors frequently target these accounts through credential stuffing, password spraying, or by compromising the guest's home organization to gain lateral access. Once an inactive guest account is compromised, attackers can utilize existing access grants to:\n- Move laterally within the tenant\n- Escalate privileges through group memberships or application permissions\n- Establish persistence through techniques like creating more service principals or modifying existing permissions\n\nThe prolonged dormancy of these accounts provides attackers with extended dwell time to conduct reconnaissance, exfiltrate sensitive data, and establish backdoors without detection, as organizations typically focus monitoring efforts on active internal users rather than external guest accounts.\n\n**Remediation action**\n- [Monitor and clean up stale guest accounts](https://learn.microsoft.com/en-us/entra/identity/users/clean-up-stale-guest-accounts?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21858",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\n❌ **FAIL**: Found 2 inactive guest user(s) with no sign-in activity in the last 90 days:\n\n\n## Inactive guest accounts in the tenant\n\n\n| Display Name | User Principal Name | Last Sign-in Date | Created Date |\n| :----------- | :------------------ | :---------------- | :----------- |\n| [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true) | merillf_gmail.com#EXT#@pora.onmicrosoft.com | Unknown | 2021-02-06 |\n| [Shonali Balakrishna](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/305bbf73-eee4-4e0c-9c7d-627e00ed3665/hidePreviewBanner~/true) | shobalak_outlook.com#EXT#@pora.onmicrosoft.com | 2025-05-05 | 03/25/2025 22:18:10 |\n\n\n\n",
      "TestTitle": "Inactive guest identities are disabled or removed from the tenant",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without limiting guest access to approved tenants, threat actors can exploit unrestricted guest access to establish initial access through compromised external accounts or by creating accounts in untrusted tenants. Organizations can configure an allowlist or blocklist to control B2B collaboration invitations from specific organizations, and without these controls, threat actors can leverage social engineering techniques to obtain invitations from legitimate internal users. Once threat actors gain guest access through unrestricted domains, they can perform discovery activities to enumerate internal resources, users, and applications that guest accounts can access. The compromised guest account then serves as a persistent foothold, allowing threat actors to execute collection activities against accessible SharePoint sites, Teams channels, and other resources granted to guest users. From this position, threat actors can attempt lateral movement by exploiting trust relationships between the compromised tenant and partner organizations, or by leveraging guest permissions to access sensitive data that can be used for further credential compromise or business email compromise attacks.\n\n**Remediation action**\n\n- [Configure Domain-Based Allow or Deny Lists](https://learn.microsoft.com/en-us/entra/external-id/allow-deny-list)\n\n",
      "TestId": "21822",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nGuest access is not limited to approved tenants.\n\n\n## [Collaboration restrictions](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/)\n\nThe tenant is configured to: **Allow invitations to be sent to any domain (most inclusive)** ❌\n\n",
      "TestTitle": "Guest access is limited to approved tenants",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Applications management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When applications that support both authentication and provisioning through Microsoft Entra aren't configured for automatic provisioning, organizations become vulnerable to identity lifecycle gaps that threat actors can exploit. Without automated provisioning, user accounts might persist in applications after employees leave the organization. This vulnerability creates dormant accounts that threat actors can discover through reconnaissance activities. These orphaned accounts often retain their original access permissions but lack active monitoring, making them attractive targets for initial access.\n\nThreat actors who gain access to these dormant accounts can use them to establish persistence in the target application, as the accounts appear legitimate and might not trigger security alerts. From these compromised application accounts, attackers can:\n\n- Attempt to escalate their privileges by exploring application-specific permissions\n- Access sensitive data stored within the application\n- Use the application as a pivot point to access other connected systems\n\nThe lack of centralized identity lifecycle management also makes it difficult for security teams to detect when an attacker is using these orphaned accounts, as the accounts might not be properly correlated with the organization's active user directory. \n\n**Remediation action**\n\n- [Configure application provisioning for missing applications](https://learn.microsoft.com/en-us/entra/identity/app-provisioning/configure-automatic-user-provisioning-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21886",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nApplications that are configured for SSO and support provisioning are NOT configured for provisioning.\n\n\n## Applications that are NOT configured for provisioning\n\n\n| Application Name | Object ID | Application ID |\n| :--------------- | :-------- | :------------- |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ba63bb52-182c-4ec6-9cc8-ad2287cf51ed/appId/76249b01-8747-4db4-843f-6478d5b32b14/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | ba63bb52-182c-4ec6-9cc8-ad2287cf51ed | 76249b01-8747-4db4-843f-6478d5b32b14 |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | dc89bf5d-83e8-4419-9162-3b9280a85755 | 091edd89-b342-4bb5-9144-82fe6c913987 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | f7b07e81-79a0-4e51-b93a-169b8f2f6c4e | f816d68b-aec7-4eab-9ebc-bd23b0d04e35 |\n| [Docusign](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c6c64515-9c2c-4458-830d-fda30f7f55b5/appId/bc582926-d3ef-48e0-9a43-e813b898afb0/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | c6c64515-9c2c-4458-830d-fda30f7f55b5 | bc582926-d3ef-48e0-9a43-e813b898afb0 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 5eec0e98-b81a-422a-ab61-f8de2729330d | f76d7d98-02ee-4e62-9345-36016a72e664 |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 39861745-eda1-4e3c-8358-d0ba931f12bb | d3a04f85-a969-436b-bf4d-eae0a91efb4c |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/84dc13ec-5754-4745-90f9-5cc92a5ded28/appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 84dc13ec-5754-4745-90f9-5cc92a5ded28 | 9c599cd2-9fb0-4815-b65c-83be33f5df1b |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 13720002-03b6-462f-ac2f-765f0f9b3f58 | 1a2a1d4c-1d76-44ec-95f4-3ed5345423a9 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | d589a2e6-4a78-4cdd-901b-f574dc7880db | 6590313e-1c00-4c07-be28-72858e837a52 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 9a8af246-0d94-42eb-aaaf-836a9f9a4974 | ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 31e80a1b-3faa-4ce9-9794-2b77f61f20f7 | 8ae2b566-71f5-467e-8960-cfe8da3a2cfa |\n\n\n\n",
      "TestTitle": "Applications are configured for automatic user provisioning",
      "TestStatus": "Failed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "For service principals that are owned by your organization authenticate using credentials defined in the app registration object.\n\nFor service principals that are not owned by your organization that have credentials, if the credentials added are still valid use cases. If not, remove credentials from service principal to reduce security risk.\n\n**Remediation action**\n[Add and manage appcredentials in Microsoft Entra ID- Microsoft identity platform |Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-credentials?tabs=certificate)\n",
      "TestId": "21896",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nFound Service Principals with credentials configured in the tenant, which represents a security risk.\n\n\n## Service Principals with credentials configured in the tenant\n\n\n| Service Principal Name | Credentials Type | Credentials Expiration Date | Expiry Status |\n| :--------------------- | :--------------- | :-------------------------- | :------------ |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ba63bb52-182c-4ec6-9cc8-ad2287cf51ed/appId/76249b01-8747-4db4-843f-6478d5b32b14) | Password Credentials | 2028-07-30 | ✅ Current |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987) | Password Credentials | 2025-10-26 | ✅ Current |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f79df990-9ad2-4142-b5fd-8945ff334da3/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | Password Credentials | 2027-03-03 | ✅ Current |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664) | Password Credentials | 2024-02-17 | ❗ Expired |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c) | Password Credentials | 2028-01-07 | ✅ Current |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/84dc13ec-5754-4745-90f9-5cc92a5ded28/appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b) | Password Credentials | 2028-07-30 | ✅ Current |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/05c98ca9-d208-4d3e-ad24-911bfc3d028c/appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06) | Password Credentials | 2024-06-11 | ❗ Expired |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9) | Password Credentials | 2025-10-02 | ❗ Expired |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52) | Password Credentials | 2025-11-17 | ✅ Current |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94) | Password Credentials | 2024-02-15 | ❗ Expired |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1) | Password Credentials | 2027-02-15 | ✅ Current |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35) | Password Credentials | 2028-02-26 | ✅ Current |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa) | Password Credentials | 2025-10-10 | ❗ Expired |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ba63bb52-182c-4ec6-9cc8-ad2287cf51ed/appId/76249b01-8747-4db4-843f-6478d5b32b14) | Key Credentials | 2028-07-30 | ✅ Current |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987) | Key Credentials | 2025-10-26 | ✅ Current |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664) | Key Credentials | 2024-02-17 | ❗ Expired |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c) | Key Credentials | 2028-01-07 | ✅ Current |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/84dc13ec-5754-4745-90f9-5cc92a5ded28/appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b) | Key Credentials | 2028-07-30 | ✅ Current |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/05c98ca9-d208-4d3e-ad24-911bfc3d028c/appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06) | Key Credentials | 2024-06-11 | ❗ Expired |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9) | Key Credentials | 2025-10-02 | ❗ Expired |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52) | Key Credentials | 2025-11-17 | ✅ Current |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94) | Key Credentials | 2024-02-15 | ❗ Expired |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1) | Key Credentials | 2027-02-15 | ✅ Current |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35) | Key Credentials | 2028-02-26 | ✅ Current |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa) | Key Credentials | 2025-10-10 | ❗ Expired |\n\n\n",
      "TestTitle": "Service principals don't have certificates or credentials associated with them",
      "TestStatus": "Investigate"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without configuring access packages for external users to use specific connected organizations, organizations expose themselves to uncontrolled access from any external identity source. When access packages allow \"All users\" threat actors can potentially request access through compromised external accounts from any domain or organization, including those not authorized by the organization. This broad external access scope bypasses the principle of least privilege and creates multiple attack vectors for lateral movement within the environment. Threat actors can exploit weakly configured access packages to establish initial access through legitimate-appearing requests, then use these granted permissions to perform reconnaissance activities. Once internal access is established through these overprivileged external access paths, threat actors can attempt escalate their privileges, persist in the environment through additional access requests, and potentially move laterally to compromise critical business systems and data repositories.\n\n**Remediation action**\n\n* [Explicitly define the list of organizations allowed in your tenant as connected organizations](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-organization)\n\n* [Configure access packages assignment policies to specific connected organizations](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-access-package-create#allow-users-not-in-your-directory-to-request-the-access-package)\n\n",
      "TestId": "21875",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nAssignment policies that allow any connected organization were found.\n## Evaluated assignment policies\n| Access package | Assignment policy | Target scope | Status |\n| :--- | :--- | :--- | :--- |\n| [PS-GraphCmdLetScriptTest4](https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlement/menuId/) | External | allConfiguredConnectedOrganizationUsers | ⚠️ Investigate |\n| [Get user info demo](https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlement/menuId/) | Initial Policy | specificConnectedOrganizationUsers | ✅ Pass |\n| [UserInfo](https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlement/menuId/) | Initial Policy | allConfiguredConnectedOrganizationUsers | ⚠️ Investigate |\n\n",
      "TestTitle": "Tenant has all external organizations allowed to collaborate as connected organization",
      "TestStatus": "Investigate"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Microsoft ended all support and security fixes for ADAL on June 30, 2023. Each ADAL token request represents a deliberate bypass of modern protections available only in MSAL-based implementations—such as continuous resilience improvements, modern protocol feature uptake, conditional access enforcement edge-cases coverage, and advanced token protection scenarios. Persisting ADAL traffic extends the attack surface: threat actors monitor for weaker legacy libraries, abuse older refresh patterns, and exploit dependency chains that still pull ADAL transitively. Maintaining any ADAL activity increases lateral movement opportunity because those apps frequently also call deprecated Azure AD Graph endpoints rather than Microsoft Graph, compounding technical debt and obscuring audit visibility. Continued reliance on ADAL delays adoption of hardened flows (like CAE, PoP tokens, and improved brokered authentication) and raises the probability that a future security advisory cannot be mitigated without emergency rewrites.\n\n**Remediation action**\n\n* [Migrate ADAL applications to MSAL](https://learn.microsoft.com/en-us/entra/identity-platform/msal-migration)\n\n",
      "TestId": "21780",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nNo ADAL applications found in the tenant.\n",
      "TestTitle": "No usage of ADAL in the tenant",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Without sign-in context, threat actors can exploit authentication fatigue by flooding users with push notifications, increasing the chance that a user accidentally approves a malicious request. When users get generic push notifications without the application name or geographic location, they don't have the information they need to make informed approval decisions. This lack of context makes users vulnerable to social engineering attacks, especially when threat actors time their requests during periods of legitimate user activity. This vulnerability is especially dangerous when threat actors gain initial access through credential harvesting or password spraying attacks and then try to establish persistence by approving multifactor authentication (MFA) requests from unexpected applications or locations. Without contextual information, users can't detect unusual sign-in attempts, allowing threat actors to maintain access and escalate privileges by moving laterally through systems after bypassing the initial authentication barrier. Without application and location context, security teams also lose valuable telemetry for detecting suspicious authentication patterns that can indicate ongoing compromise or reconnaissance activities.   \n\n**Remediation action**\nGive users the context they need to make informed approval decisions. Configure Microsoft Authenticator notifications by setting the Authentication methods policy to include the application name and geographic location.  \n- [Use additional context in Authenticator notifications - Authentication methods policy](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-additional-context?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21802",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nMicrosoft Authenticator shows application name and geographic location in push notifications.\n\n\n## Microsoft Authenticator settings\n\n\nFeature Settings:\n\n✅ **Application Name**\n- Status: Enabled\n- Include Target: All users\n- Exclude Target: No exclusions\n\n✅ **Geographic Location**\n- Status: Enabled\n- Include Target: All users\n- Exclude Target: No exclusions\n\n\n",
      "TestTitle": "Authenticator app shows sign-in context",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When smart lockout threshold is set to 10 or below, threat actors can exploit this configuration by conducting reconnaissance to identify valid user accounts without triggering lockout protections. Through credential stuffing attacks using compromised credentials from data breaches, attackers can systematically test account credentials while staying below the lockout threshold. This allows threat actors to establish initial access to user accounts without detection. Once initial access is gained, attackers can move laterally through the environment by leveraging the compromised account to access resources and escalate privileges. The persistence mechanism is strengthened because the account remains functional and unlocked, enabling continued access for data exfiltration or deployment of additional tools. A threshold of 10 or below provides insufficient protection against automated password spray attacks that distribute authentication attempts across multiple accounts, making it easier for threat actors to compromise accounts while evading detection mechanisms.\n\n**Remediation action**\n* [Configure smart lockout](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-password-smart-lockout)\n\n",
      "TestId": "21850",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nSmart lockout threshold is configured above 10.\n## Smart lockout configuration\n\n| Setting | Value |\n| :---- | :---- |\n| [Lockout threshold](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/PasswordProtection/fromNav/) | 11 attempts|\n\n",
      "TestTitle": "Smart lockout threshold isn't greater than 10",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "External collaboration",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "When guest self-service sign-up is enabled, threat actors can exploit this functionality to establish unauthorized initial access by creating legitimate guest accounts without requiring invitation approval from authorized personnel. Adversaries may create accounts that only have access to specific services, which can reduce the chance of detection, effectively bypassing traditional invitation-based controls that validate external user legitimacy.\n\nOnce threat actors successfully create these self-provisioned guest accounts, they gain persistent access to organizational resources and applications, enabling them to conduct reconnaissance activities to map internal systems, identify sensitive data repositories, and enumerate additional attack vectors within the tenant.  \nThe persistence tactic allows adversaries to maintain their foothold across restarts, changed credentials, and other interruptions that could cut off their access, while the guest account provides a seemingly legitimate identity that may evade detection by security monitoring systems focused on suspicious external access attempts.\n\nFurthermore, threat actors can leverage these compromised guest identities to establish credential persistence and potentially escalate privileges by exploiting trust relationships between guest accounts and internal resources, or by using the guest account as a staging ground for lateral movement attacks against more privileged organizational assets. \n\n**Remediation action**\n- [Configure guest self-service sign-up With Microsoft Entra External ID](https://learn.microsoft.com/en-us/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-self-service-sign-up)",
      "TestId": "21823",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\n[Guest self-service sign up via user flow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/ExternalIdentitiesGettingStarted) is disabled.\n\n",
      "TestTitle": "Guest self-service sign-up via user flow is disabled",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When Smart Lockout duration is configured below 60 seconds, threat actors can exploit shortened lockout periods to conduct password spray attacks with reduced detection windows. The default lockout duration is 60 seconds (one minute) and setting it below this threshold creates an opportunity for attackers to perform credential stuffing operations with faster iteration cycles. Threat actors can leverage automated tools to systematically attempt authentication against multiple accounts, and with lockout periods under 60 seconds, they can resume attacks against the same accounts more rapidly. This enables them to maintain persistence in their credential harvesting efforts while potentially evading detection systems that rely on longer observation windows. The compressed timeframe allows attackers to execute more authentication attempts per account over a given period, increasing their probability of success in compromising user credentials through brute force techniques or dictionary attacks.\n\n**Remediation action**\n- [Configure Smart Lockout duration](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-password-smart-lockout)\n\n",
      "TestId": "21849",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nSmart Lockout duration is configured to 60 seconds or higher.\n## Smart Lockout Settings\n\n| Setting | Value |\n| :---- | :---- |\n| [Lockout Duration (seconds)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/PasswordProtection/fromNav/) | 60 |\n\n",
      "TestTitle": "Smart lockout duration is set to a minimum of 60",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "Inviting external guests is beneficial for organizational collaboration. However, in the absence of an assigned internal sponsor for each guest, these accounts might persist within the directory without clear accountability. This oversight creates a risk: threat actors could potentially compromise an unused or unmonitored guest account, and then establish an initial foothold within the tenant. Once granted access as an apparent \"legitimate\" user, an attacker might explore accessible resources and attempt privilege escalation, which could ultimately expose sensitive information or critical systems. An unmonitored guest account might therefore become the vector for unauthorized data access or a significant security breach. A typical attack sequence might use the following pattern, all achieved under the guise of a standard external collaborator:\n\n1. Initial access gained through compromised guest credentials\n1. Persistence due to a lack of oversight.\n1. Further escalation or lateral movement if the guest account possesses group memberships or elevated permissions.\n1. Execution of malicious objectives. \n\nMandating that every guest account is assigned to a sponsor directly mitigates this risk. Such a requirement ensures that each external user is linked to a responsible internal party who is expected to regularly monitor and attest to the guest's ongoing need for access. The sponsor feature within Microsoft Entra ID supports accountability by tracking the inviter and preventing the proliferation of \"orphaned\" guest accounts. When a sponsor manages the guest account lifecycle, such as removing access when collaboration concludes, the opportunity for threat actors to exploit neglected accounts is substantially reduced. This best practice is consistent with Microsoft’s guidance to require sponsorship for business guests as part of an effective guest access governance strategy. It strikes a balance between enabling collaboration and enforcing security, as it guarantees that each guest user's presence and permissions remain under ongoing internal oversight.\n\n**Remediation action**\n- For each guest user that has no sponsor, assign a sponsor in Microsoft Entra ID.\n    - [Add a sponsor to a guest user in the Microsoft Entra admin center](https://learn.microsoft.com/en-us/entra/external-id/b2b-sponsors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - [Add a sponsor to a guest user using Microsoft Graph](https://learn.microsoft.com/graph/api/user-post-sponsors?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21877",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\n✅ All guest accounts in the tenant have an assigned sponsor.\n\n",
      "TestTitle": "All guests have a sponsor",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "TestDescription": "If nonprivileged users can create applications and service principals, these accounts might be misconfigured or be granted more permissions than necessary, creating new vectors for attackers to gain initial access. Attackers can exploit these accounts to establish valid credentials in the environment and bypass some security controls.\n\nIf these nonprivileged accounts are mistakenly granted elevated application owner permissions, attackers can use them to move from a lower level of access to a more privileged level of access. Attackers who compromise nonprivileged accounts might add their own credentials or change the permissions associated with the applications created by the nonprivileged users to ensure they can continue to access the environment undetected.\n\nAttackers can use service principals to blend in with legitimate system processes and activities. Because service principals often perform automated tasks, malicious activities carried out under these accounts might not be flagged as suspicious.\n\n**Remediation action**\n\n- [Block nonprivileged users from creating apps](https://learn.microsoft.com/entra/identity/role-based-access-control/delegate-app-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21807",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Application"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nTenant is configured to prevent users from registering applications.\n\n**[Users can register applications](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)** → **No** ✅\n\n",
      "TestTitle": "Creating new applications and service principals is restricted to privileged users",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "Token protection policies in Entra ID tenants are crucial for safeguarding authentication tokens from misuse and unauthorized access. Without these policies, threat actors can intercept and manipulate tokens, leading to unauthorized access to sensitive resources. This can result in data exfiltration, lateral movement within the network, and potential compromise of privileged accounts.\n\nWhen token protection is not properly configured, threat actors can exploit several attack vectors:\n\n1. **Token theft and replay attacks** - Attackers can steal authentication tokens from compromised devices and replay them from different locations\n2. **Session hijacking** - Without secure sign-in session controls, attackers can hijack legitimate user sessions\n3. **Cross-platform token abuse** - Tokens issued for one platform (like mobile) can be misused on other platforms (like web browsers)\n4. **Persistent access** - Compromised tokens can provide long-term unauthorized access without triggering security alerts\n\nThe attack chain typically involves initial access through token theft, followed by privilege escalation and persistence, ultimately leading to data exfiltration and impact across the organization's Microsoft 365 environment.\n\n**Remediation action**\n- [Configure Conditional Access policies as per the best practices](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection#create-a-conditional-access-policy)\n- [Microsoft Entra Conditional Access token protection explained](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection)\n- [Configure session controls in Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session)\n\n",
      "TestId": 21941,
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nToken protection policies are configured.\n\n### Token protection policy summary\n\nThe table below lists all the token protection Conditional Access policies found in the tenant.\n\n| Name | Policy state | Users | Applications | Token protection | Status |\n| :--- | :---: | :---: | :---: | :---: | :---: |\n| [Token protection](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/ff7b71d1-fa63-4073-a959-4790f299de0f) | 🟡 Report-only | All | Selected | 🟢 | ❌ Fail |\n| [token protection with 1 apps](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/c51217bf-4044-4001-bfe6-ed8ef2624beb) | 🟢 Enabled | Selected | Selected | 🟢 | ✅ Pass |\n\n",
      "TestTitle": "Token protection policies are configured",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "\n## Overview\n\nThreat actors frequently target legacy management interfaces such as the Azure AD PowerShell module (AzureAD and AzureADPreview), which do not support modern authentication, Conditional Access enforcement, or advanced audit logging. Continued use of these modules exposes the environment to risks including weak authentication, bypass of security controls, and incomplete visibility into administrative actions. Attackers can exploit these weaknesses to gain unauthorized access, escalate privileges, and perform malicious changes without triggering modern security controls.\n\nLegacy PowerShell modules lack support for modern authentication methods like multi-factor authentication (MFA) and certificate-based authentication, making them vulnerable to credential-based attacks. These modules also bypass Conditional Access policies, allowing attackers to circumvent location-based restrictions, device compliance requirements, and risk-based access controls. The limited audit logging capabilities of legacy modules provide attackers with the opportunity to perform administrative actions with reduced detection risk.\n\nBlocking the Azure AD PowerShell module and enforcing the use of Microsoft Graph PowerShell or Microsoft Entra PowerShell ensures that only secure, supported, and auditable management channels are available, closing critical gaps in the attack chain.\n\n**Remediation action**\n\n- [Disable user sign-in for the Azure Active Directory PowerShell Enterprise Application](https://learn.microsoft.com/entra/identity/enterprise-apps/disable-user-sign-in-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Action required: MSOnline and AzureAD PowerShell retirement - 2025 info and resources | Microsoft Community Hub](https://techcommunity.microsoft.com/blog/microsoft-entra-blog/action-required-msonline-and-azuread-powershell-retirement---2025-info-and-resou/4364991)\n\n",
      "TestId": "21844",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nSummary\n\n- [Azure AD PowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/39921e28-0140-4bfc-ad89-26a3294f6ca9/appId/1b730954-1685-4b74-9bfd-dac224a7b894)\n- Sign in disabled: Yes\n\nAzure AD PowerShell is blocked in the tenant by turning off user sign in to the Azure Active Directory PowerShell Enterprise Application.\n",
      "TestTitle": "Block legacy Azure AD PowerShell module",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Credential management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "When password expiration policies remain enabled, threat actors can exploit the predictable password rotation patterns that users typically follow when forced to change passwords regularly. Users frequently create weaker passwords by making minimal modifications to existing ones, such as incrementing numbers or adding sequential characters. Threat actors can easily anticipate and exploit these types of changes through credential stuffing attacks or targeted password spraying campaigns. These predictable patterns enable threat actors to establish persistence through:\n\n- Compromised credentials\n- Escalated privileges by targeting administrative accounts with weak rotated passwords\n- Maintaining long-term access by predicting future password variations\n\nResearch shows that users create weaker, more predictable passwords when they are forced to expire. These predictable passwords are easier for experienced attackers to crack, as they often make simple modifications to existing passwords rather than creating entirely new, strong passwords. Additionally, when users are required to frequently change passwords, they might resort to insecure practices such as writing down passwords or storing them in easily accessible locations, creating more attack vectors for threat actors to exploit during physical reconnaissance or social engineering campaigns. \n\n**Remediation action**\n\n- [Set the password expiration policy for your organization](https://learn.microsoft.com/microsoft-365/admin/manage/set-password-expiration-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n    - Sign in to the [Microsoft 365 admin center](https://admin.microsoft.com/). Go to **Settings** > **Org Settings** >** Security & Privacy** > **Password expiration policy**. Ensure the **Set passwords to never expire** setting is checked.\n- [Disable password expiration using Microsoft Graph](https://learn.microsoft.com/graph/api/domain-update?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- [Set individual user passwords to never expire using Microsoft Graph PowerShell](https://learn.microsoft.com/microsoft-365/admin/add-users/set-password-to-never-expire?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - `Update-MgUser -UserId <UserID> -PasswordPolicies DisablePasswordExpiration`",
      "TestId": "21811",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPassword expiration is properly disabled across all domains and users.\n\n",
      "TestTitle": "Password expiration is disabled",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "External collaboration",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "Without restrictions preventing guest users from registering and owning applications, threat actors can exploit external user accounts to establish persistent backdoor access to organizational resources through application registrations that might evade traditional security monitoring. When guest users own applications, compromised guest accounts can be used to exploit guest-owned applications that might have broad permissions. This vulnerability enables threat actors to request access to sensitive organizational data such as emails, files, and user information without the same level of scrutiny for internal user-owned applications.\n\nThis attack vector is dangerous because guest-owned applications can be configured to request high-privilege permissions and, once granted consent, provide threat actors with legitimate OAuth tokens. Furthermore, guest-owned applications can serve as command and control infrastructure, so threat actors can maintain access even after the compromised guest account is detected and remediated. Application credentials and permissions might persist independently of the original guest user account, so threat actors can retain access. Guest-owned applications also complicate security auditing and governance efforts, as organizations might have limited visibility into the purpose and security posture of applications registered by external users. These hidden weaknesses in the application lifecycle management make it difficult to assess the true scope of data access granted to non-Microsoft entities through seemingly legitimate application registrations.\n\n**Remediation action**\n- Remove guest users as owners from applications and service principals, and implement controls to prevent future guest user application ownership.\n- [Restrict guest user access permissions](https://learn.microsoft.com/en-us/entra/identity/users/users-restrict-guest-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21868",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nNo guest users own any applications or service principals in the tenant.\n\n",
      "TestTitle": "Guests do not own apps in the tenant",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "TestDescription": "## Overview\n\nWithout Temporary Access Pass (TAP) enabled, organizations face significant challenges in securely bootstrapping users credentials, creating vulnerability windows where users rely on weaker authentication mechanisms during initial setup. When users cannot register phishing-resistant credentials like FIDO2 security keys or Windows Hello for Business due to lack of existing strong authentication methods, they remain exposed to credential-based attacks including phishing, password spray, or similar attacks. Threat actors can exploit this registration gap by targeting users during their most vulnerable state - when they have limited authentication options available and must rely on traditional username-password combinations. This exposure enables threat actors to compromise user accounts during the critical bootstrapping phase, allowing them to intercept or manipulate the registration process for stronger authentication methods, ultimately gaining persistent access to organizational resources and potentially escalating privileges before security controls are fully established.\n\n**Remediation action**\n\n- [Enable Temporary Access Pass authentication method in the Authentication methods policy](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-temporary-access-pass#enable-the-temporary-access-pass-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create Conditional Access policy for security info registration with authentication strength enforcement](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-security-info-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Update authentication strength policies to include Temporary Access Pass](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-custom-authentication-strength)\n\n",
      "TestId": "21845",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": null,
      "TestAppliesTo": null,
      "TestResult": "\nTemporary Access Pass is enabled, targeting all users, and enforced with conditional access policies.\n\n**Configuration summary**\n\n[Temporary Access Pass](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AdminAuthMethods/fromNav/Identity): Enabled ✅\n\n[Conditional Access policy for Security info registration](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies/fromNav/Identity): Enabled ✅\n\n[Authentication strength policy for Temporary Access Pass](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/AuthenticationStrength.ReactView/fromNav/Identity): Enabled ✅\n\n",
      "TestTitle": "Temporary access pass is enabled",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "TestDescription": "Without named locations configured in Microsoft Entra ID, threat actors can exploit the absence of location intelligence to conduct attacks without triggering location-based risk detections or security controls. When organizations fail to define named locations for trusted networks, branch offices, and known geographic regions, Microsoft Entra ID Protection can't assess location-based risk signals. Not having these policies in place can lead to increased false positives that create alert fatigue and potentially mask genuine threats. This configuration gap prevents the system from distinguishing between legitimate and illegitimate locations. For example, legitimate sign-ins from corporate networks and suspicious authentication attempts from high-risk locations (anonymous proxy networks, Tor exit nodes, or regions where the organization has no business presence). Threat actors can use this uncertainty to conduct credential stuffing attacks, password spray campaigns, and initial access attempts from malicious infrastructure without triggering location-based detections that would normally flag such activity as suspicious. Organizations can also lose the ability to implement adaptive security policies that could automatically apply stricter authentication requirements or block access entirely from untrusted geographic regions. Threat actors can maintain persistence and conduct lateral movement from any global location without encountering location-based security barriers, which should serve as an extra layer of defense against unauthorized access attempts.\n\n**Remediation action**\n\n- [Configure named locations to define trusted IP ranges and geographic regions for enhanced location-based risk detection and Conditional Access policy enforcement](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21865",
      "SkippedReason": null,
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\n✅ **Pass**: Trusted named locations are configured in Microsoft Entra ID to support location-based security controls.\n\n\n## All named locations\n\n5 [named locations](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations/menuId//fromNav/) found.\n\n| Name | Location type | Trusted | Creation date | Modified date |\n| :--- | :------------ | :------ | :------------ | :------------ |\n| Melbourne Branch | IP-based | Yes | Unknown | Unknown |\n| Boston Head Office | IP-based | Yes | Unknown | Unknown |\n| Untrusted Locations | Country-based | No | Unknown | Unknown |\n| Corporate IPs | IP-based | Yes | Unknown | Unknown |\n| Merill home | IP-based | Yes | 04/16/2025 04:55:11 | 04/16/2025 04:55:11 |\n\n\n\n",
      "TestTitle": "Named locations are configured",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "External collaboration",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.  \n\nExternal accounts with permissions to read directory object permissions provide attackers with broader initial access if compromised. These accounts allow attackers to gather additional information from the directory for reconnaissance.\n\n**Remediation action**\n\n- [Restrict guest access to their own directory objects](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-user-access)\n",
      "TestId": "21792",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Application"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\n✅ Validated guest user access is restricted.\n\n",
      "TestTitle": "Guests have restricted access to directory objects",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "External collaboration",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.  \n\nAllowing external users to onboard other external users increases the risk of unauthorized access. If an attacker compromises an external user's account, they can use it to create more external accounts, multiplying their access points and making it harder to detect the intrusion.\n\n**Remediation action**\n\n- [Restrict who can invite guests to only users assigned to specific admin roles](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-invite-settings)\n",
      "TestId": "21791",
      "SkippedReason": null,
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "ExternalCollaboration"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nTenant restricts who can invite guests.\n\n**Guest invite settings**\n\n  * Guest invite restrictions → Member users and users assigned to specific admin roles can invite guest users including guests with member permissions\n\n",
      "TestTitle": "Guests can’t invite other guests",
      "TestStatus": "Passed"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21857",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Guest identities are lifecycle managed with access reviews",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21859",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "GDAP admin least privilege",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21854",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Privileged roles aren't assigned to stale identities",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21929",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "All entitlement management packages that apply to guests have expirations or access reviews configured in their assignment policies",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Credential management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "Without Self-Service Password Reset (SSPR) enabled, users with password-related issues must contact help desk support, which can cause in operational delays and lost productivity. There are also potential security vulnerabilities during the extended timeframe required for administrative password resets. These delays not only reduce employee efficiency (especially in time-sensitive roles), but also increase support costs and strain IT resources. During these periods, threat actors might exploit locked accounts through social engineering attacks targeting help desk personnel. Threat actors can potentially convince support staff to reset passwords for accounts they don't legitimately control, enabling initial access to user credentials.\n\nWhen users are unable to reset their own passwords through secure, automated processes, they frequently resort to insecure workarounds. Examples include sharing accounts with colleagues, using weak passwords that are easier to remember, or writing down passwords in discoverable locations, all of which expand the attack surface for credential harvesting techniques. The lack of SSPR forces users to maintain static passwords for longer periods between administrative resets. This type of password policy increases the likelihood that compromised credentials from previous breaches or password spray attacks remain valid and usable by threat actors. The absence of user-controlled password reset capabilities also delays the response time for users to secure their accounts when they suspect compromise. This delay allows threat actors extended persistence within compromised accounts to perform reconnaissance, establish other access methods, or exfiltrate sensitive data before the account is eventually reset through administrative channels \n\n**Remediation action**\n\n- [Enable Self-Service Password Reset](https://learn.microsoft.com/en-us/entra/identity/authentication/tutorial-enable-sspr?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21870",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "Enable self-service password reset",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21898",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "All supported access lifecycle resources are managed with entitlement management packages",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21897",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "High",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "All app assignment and group membership is governed",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Application management",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "When enterprise applications lack both explicit assignment requirements AND scoped provisioning controls, threat actors can exploit this dual weakness to gain unauthorized access to sensitive applications and data. The highest risk occurs when applications are configured with the default setting: \"Assignment required\" is set to \"No\" *and* provisioning isn't required or scoped. This dangerous combination allows threat actors who compromise any user account within the tenant to immediately access applications with broad user bases, expanding their attack surface and potential for lateral movement within the organization.\n\nWhile an application with open assignment but proper provisioning scoping (such as department-based filters or group membership requirements) maintains security controls through the provisioning layer, applications lacking both controls create unrestricted access pathways that threat actors can exploit. When applications provision accounts for all users without assignment restrictions, threat actors can abuse compromised accounts to conduct reconnaissance activities, enumerate sensitive data across multiple systems, or use the applications as staging points for further attacks against connected resources. This unrestricted access model is dangerous for applications that have elevated permissions or are connected to critical business systems. Threat actors can use any compromised user account to access sensitive information, modify data, or perform unauthorized actions that the application's permissions allow. The absence of both assignment controls and provisioning scoping also prevents organizations from implementing proper access governance. Without proper governance, it's difficult to track who has access to which applications, when access was granted, and whether access should be revoked based on role changes or employment status. Furthermore, applications with broad provisioning scopes can create cascading security risks where a single compromised account provides access to an entire ecosystem of connected applications and services.\n\n**Remediation action**\n- Evaluate business requirements to determine appropriate access control method. [Restrict a Microsoft Entra app to a set of users](https://learn.microsoft.com/en-us/entra/identity-platform/howto-restrict-your-app-to-a-set-of-users?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Configure enterprise applications to require assignment for sensitive applications. [Learn about the \"Assignment required\" enterprise application property](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/application-properties?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assignment-required).\n- Implement scoped provisioning based on groups, departments, or attributes. [Create scoping filters](https://learn.microsoft.com/en-us/entra/identity/app-provisioning/define-conditional-rules-for-provisioning-user-accounts?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-scoping-filters).",
      "TestId": "21869",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "Enterprise applications must require explicit assignment or scoped provisioning",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Credential management",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "Microsoft Entra seamless single sign-on (Seamless SSO) is a legacy authentication feature designed to provide passwordless access for domain-joined devices that are not hybrid Microsoft Entra ID joined. Seamless SSO relies on Kerberos authentication and is primarily beneficial for older operating systems like Windows 7 and Windows 8.1, which do not support Primary Refresh Tokens (PRT). If these legacy systems are no longer present in the environment, continuing to use Seamless SSO introduces unnecessary complexity and potential security exposure. Threat actors could exploit misconfigured or stale Kerberos tickets, or compromise the `AZUREADSSOACC` computer account in Active Directory, which holds the Kerberos decryption key used by Microsoft Entra ID. Once compromised, attackers could impersonate users, bypass modern authentication controls, and gain unauthorized access to cloud resources. Disabling Seamless SSO in environments where it is no longer needed reduces the attack surface and enforces the use of modern, token-based authentication mechanisms that offer stronger protections. \n\n**Remediation action**\n\n- [Review how Seamless SSO works](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sso-how-it-works?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Disable Seamless SSO](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sso-faq?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-can-i-disable-seamless-sso-)\n- [Clean up stale devices in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/devices/manage-stale-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21985",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "Turn off Seamless SSO if there is no usage",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21899",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "All privileged role assignments have a recipient that can receive notifications",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Monitoring",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.\n\nAttackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.\n\n**Remediation action**\n\n- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy a Conditional Access policy to require phishing-resistant MFA for all users](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestId": "21800",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "All user sign-in activity uses strong authentication methods",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Monitoring",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "Legacy authentication protocols such as basic authentication for SMTP and IMAP don't support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This lack of protection makes accounts using these protocols vulnerable to password-based attacks, and provides attackers with a means to gain initial access using stolen or guessed credentials.\n\nWhen an attacker successfully gains unauthorized access to credentials, they can use them to access linked services, using the weak authentication method as an entry point. Attackers who gain access through legacy authentication might make changes to Microsoft Exchange, such as configuring mail forwarding rules or changing other settings, allowing them to maintain continued access to sensitive communications.\n\nLegacy authentication also provides attackers with a consistent method to reenter a system using compromised credentials without triggering security alerts or requiring reauthentication.\n\nFrom there, attackers can use legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement. Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.\n\n**Remediation action**\n\n- [Exchange protocols can be deactivated in Exchange](https://learn.microsoft.com/exchange/clients-and-mobile-in-exchange-online/disable-basic-authentication-in-exchange-online?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Legacy authentication protocols can be blocked with Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Sign-ins using legacy authentication workbook to help determine whether it's safe to turn off legacy authentication](https://learn.microsoft.com/entra/identity/monitoring-health/workbook-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestId": "21795",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "High",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "No legacy authentication sign-in activity",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21831",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Conditional Access protected actions are enabled",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "22072",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Self-Service Password Reset does not use Q & A",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "External collaboration",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your organization. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.\n\nAttackers might gain access with external user accounts, if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. They might also gain access by exploiting the vulnerabilities of weaker MFA methods like SMS and phone calls using social engineering techniques, such as SIM swapping or phishing, to intercept the authentication codes.\n\nOnce an attacker gains access to an account without MFA or a session with weak MFA methods, they might attempt to manipulate MFA settings (for example, registering attacker controlled methods) to establish persistence to plan and execute further attacks based on the privileges of the compromised accounts.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to enforce authentication strength for guests](https://learn.microsoft.com/entra/identity/conditional-access/policy-guests-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- For organizations with a closer business relationship and vetting on their MFA practices, consider deploying cross-tenant access settings to accept the MFA claim.\n   - [Configure B2B collaboration cross-tenant access settings](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-change-inbound-trust-settings-for-mfa-and-device-claims)\n",
      "TestId": "21851",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Application"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "Guest access is protected by strong authentication methods",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21879",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "All entitlement management policies that apply to External users require approval",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "High",
      "TestPillar": "",
      "TestCategory": "Application management",
      "TestSfiPillar": "",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21778",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Line-of-business and partner apps use MSAL",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21887",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "All registered redirect URIs must have proper DNS records and ownerships",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21890",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Require password reset notifications for user roles",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21983",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "No Active Medium priority Entra recommendations found",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "",
      "TestCategory": "Monitoring",
      "TestSfiPillar": "",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21789",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Tenant creation events are triaged",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21882",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "No nested groups in PIM for groups",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21832",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "All groups in Conditional Access policies belong to a restricted management administrative unit",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "",
      "TestCategory": "Application management",
      "TestSfiPillar": "",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21779",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Use recent versions of Microsoft Applications",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21821",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Guest access is restricted",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21876",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Use PIM for Microsoft Entra privileged roles",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Medium",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21855",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Privileged roles have access reviews",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Access control",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "When privileged users are allowed to maintain long-lived sign-in sessions without periodic reauthentication, threat actors can gain extended windows of opportunity to exploit compromised credentials or hijack active sessions. Once a privileged account is compromised through techniques like credential theft, phishing, or session fixation, extended session timeouts allow threat actors to maintain persistence within the environment for prolonged periods. With long-lived sessions, threat actors can perform lateral movement across systems, escalate privileges further, and access sensitive resources without triggering another authentication challenge. The extended session duration also increases the window for session hijacking attacks, where threat actors can steal session tokens and impersonate the privileged user. Once a threat actor is established in a privileged session, they can:\n\n- Create backdoor accounts\n- Modify security policies\n- Access sensitive data\n- Establish more persistence mechanisms\n\nThe lack of periodic reauthentication requirements means that even if the original compromise is detected, the threat actor might continue operating undetected using the hijacked privileged session until the session naturally expires or the user manually signs out.\n\n**Remediation action**\n\n- [Learn about Conditional Access adaptive session lifetime policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-session-lifetime?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure sign-in frequency for privileged users with Conditional Access policies ](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-session-lifetime?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestId": "21825",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Medium",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n\n",
      "TestTitle": "Privileged users have short-lived sign-in sessions",
      "TestStatus": "Planned"
    },
    {
      "TestImplementationCost": "Low",
      "TestPillar": "Identity",
      "TestCategory": "Privileged access",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestId": "21819",
      "SkippedReason": "UnderConstruction",
      "TestImpact": "Low",
      "TestRisk": "Medium",
      "TestTags": [
        "Identity"
      ],
      "TestAppliesTo": [
        "Identity"
      ],
      "TestResult": "\nPlanned for future release.\n",
      "TestTitle": "Activation alert for Global Administrator role assignments",
      "TestStatus": "Planned"
    }
  ],
  "TenantInfo": {
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
    "OverviewCaDevicesAllUsers": {
      "nodes": [
        {
          "target": "Unmanaged",
          "source": "User sign in",
          "value": 964
        },
        {
          "target": "Managed",
          "source": "User sign in",
          "value": 0
        },
        {
          "target": "Non-compliant",
          "source": "Managed",
          "value": 0
        },
        {
          "target": "Compliant",
          "source": "Managed",
          "value": 0
        }
      ],
      "description": "Over the past 30 days, 0% of sign-ins were from compliant devices."
    },
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
    "OverviewCaMfaAllUsers": {
      "nodes": [
        {
          "target": "No CA applied",
          "source": "User sign in",
          "value": 201
        },
        {
          "target": "CA applied",
          "source": "User sign in",
          "value": 763
        },
        {
          "target": "No MFA",
          "source": "CA applied",
          "value": 58
        },
        {
          "target": "MFA",
          "source": "CA applied",
          "value": 705
        }
      ],
      "description": "Over the past 30 days, 73.1% of sign-ins were protected by conditional access policies enforcing multifactor."
    },
    "OverviewAuthMethodsAllUsers": {
      "nodes": [
        {
          "target": "Single factor",
          "source": "Users",
          "value": 44
        },
        {
          "target": "Phishable",
          "source": "Users",
          "value": 34
        },
        {
          "target": "Phone",
          "source": "Phishable",
          "value": 10
        },
        {
          "target": "Authenticator",
          "source": "Phishable",
          "value": 24
        },
        {
          "target": "Phish resistant",
          "source": "Users",
          "value": 6
        },
        {
          "target": "Passkey",
          "source": "Phish resistant",
          "value": 4
        },
        {
          "target": "WHfB",
          "source": "Phish resistant",
          "value": 2
        }
      ],
      "description": "Strongest authentication method registered by all users."
    },
    "TenantOverview": {
      "UserCount": 71,
      "GroupCount": 89,
      "ApplicationCount": 120,
      "DeviceCount": 20,
      "ManagedDeviceCount": 0
    },
    "DeviceOverview": {
      "WindowsJoinSummary": {
        "nodes": [
          {
            "target": "Entra joined",
            "source": "Windows",
            "value": 8.0
          },
          {
            "target": "Entra hybrid joined",
            "source": "Windows",
            "value": 0
          },
          {
            "target": "Entra registered",
            "source": "Windows",
            "value": 3.0
          },
          {
            "target": "Compliant",
            "source": "Entra joined",
            "value": null
          },
          {
            "target": "Non-compliant",
            "source": "Entra joined",
            "value": 4.0
          },
          {
            "target": "Unmanaged",
            "source": "Entra joined",
            "value": null
          },
          {
            "target": "Compliant",
            "source": "Entra hybrid joined",
            "value": null
          },
          {
            "target": "Non-compliant",
            "source": "Entra hybrid joined",
            "value": null
          },
          {
            "target": "Unmanaged",
            "source": "Entra hybrid joined",
            "value": null
          },
          {
            "target": "Compliant",
            "source": "Entra registered",
            "value": null
          },
          {
            "target": "Non-compliant",
            "source": "Entra registered",
            "value": null
          },
          {
            "target": "Unmanaged",
            "source": "Entra registered",
            "value": null
          }
        ],
        "totalDevices": 11.0,
        "entrareigstered": 3.0,
        "entrahybridjoined": 0,
        "description": "Windows devices by join type and compliance status.",
        "entrajoined": 8.0
      },
      "ManagedDevices": {
        "@odata.context": "https://graph.microsoft.com/beta/$metadata#microsoft.graph.managedDeviceOverview",
        "id": "79a56d4c-cb32-4bd8-b23a-d7d858233248",
        "enrolledDeviceCount": 0,
        "mdmEnrolledCount": 0,
        "dualEnrolledDeviceCount": 0,
        "managedDeviceModelsAndManufacturers": null,
        "lastModifiedDateTime": "2025-10-17T21:08:51.3263033Z",
        "deviceOperatingSystemSummary": {
          "androidCount": 0,
          "iosCount": 0,
          "macOSCount": 0,
          "windowsMobileCount": 0,
          "windowsCount": 0,
          "unknownCount": 0,
          "androidDedicatedCount": 0,
          "androidDeviceAdminCount": 0,
          "androidFullyManagedCount": 0,
          "androidWorkProfileCount": 0,
          "androidCorporateWorkProfileCount": 0,
          "configMgrDeviceCount": 0,
          "aospUserlessCount": 0,
          "aospUserAssociatedCount": 0,
          "linuxCount": 0,
          "chromeOSCount": 0
        },
        "deviceExchangeAccessStateSummary": {
          "allowedDeviceCount": 0,
          "blockedDeviceCount": 0,
          "quarantinedDeviceCount": 0,
          "unknownDeviceCount": 0,
          "unavailableDeviceCount": 0
        },
        "desktopCount": 0,
        "mobileCount": 0,
        "totalCount": 0
      },
      "DeviceCompliance": {
        "@odata.context": "https://graph.microsoft.com/beta/$metadata#deviceManagement/deviceCompliancePolicyDeviceStateSummary/$entity",
        "inGracePeriodCount": 0,
        "configManagerCount": 0,
        "id": "afaac8a4-5f74-40f5-a213-51af45bedc36",
        "unknownDeviceCount": 0,
        "notApplicableDeviceCount": 0,
        "compliantDeviceCount": 0,
        "remediatedDeviceCount": 0,
        "nonCompliantDeviceCount": 0,
        "errorDeviceCount": 0,
        "conflictDeviceCount": 0
      }
    },
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
    ],
    "OverviewAuthMethodsPrivilegedUsers": {
      "nodes": [
        {
          "target": "Single factor",
          "source": "Users",
          "value": 4
        },
        {
          "target": "Phishable",
          "source": "Users",
          "value": 22
        },
        {
          "target": "Phone",
          "source": "Phishable",
          "value": 6
        },
        {
          "target": "Authenticator",
          "source": "Phishable",
          "value": 16
        },
        {
          "target": "Phish resistant",
          "source": "Users",
          "value": 5
        },
        {
          "target": "Passkey",
          "source": "Phish resistant",
          "value": 4
        },
        {
          "target": "WHfB",
          "source": "Phish resistant",
          "value": 1
        }
      ],
      "description": "Strongest authentication method registered by privileged users."
    }
  },
  "EndOfJson": "EndOfJson"
}
