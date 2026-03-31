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
  TestMinimumLicense?: string | string[] | null;
  TestSfiPillar: string | null;
  TestPillar: string | null;
  SkippedReason: string | null;
  TestResult: string;
  TestSkipped: string;
  TestStatus: string;
  TestTags: string[] | null;
  TestId: string | number;
  TestDescription: string;
  ZtmmMaturity?: string | null;
  ZtmmFunction?: string | null;
  ZtmmFunctionName?: string | null;
}

export const reportData: ZeroTrustAssessmentReport = {
  "ExecutedAt": "2026-03-26T13:40:10.037798+11:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora Inc.",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "2.1.8",
  "LatestVersion": "2.2.0",
  "TestResultSummary": {
    "IdentityPassed": 42,
    "IdentityTotal": 135,
    "DevicesPassed": 14,
    "DevicesTotal": 36,
    "NetworkPassed": 24,
    "NetworkTotal": 67,
    "DataPassed": 20,
    "DataTotal": 40
  },
  "Tests": [
    {
      "TestId": "21841",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Microsoft Authenticator app report suspicious activity setting is enabled",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAuthenticator app report suspicious activity is [not enabled](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AuthMethodsSettings).\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Threat actors increasingly rely on prompt bombing and real-time phishing proxies to coerce or trick users into approving fraudulent multifactor authentication (MFA) challenges. Without the Microsoft Authenticator app's **Report suspicious activity** capability enabled, an attacker can iterate until a fatigued user accepts. This type of attack can lead to privilege escalation, persistence, lateral movement into sensitive workloads, data exfiltration, or destructive actions.\n\nWhen reporting is enabled for all users, any unexpected push or phone prompt can be actively flagged, immediately elevating the user to high user risk and generating a high-fidelity user risk detection (userReportedSuspiciousActivity) that risk-based Conditional Access policies or other response automation can use to block or require secure remediation. \n\n**Remediation action**\n\n- [Enable the report suspicious activity setting in the Microsoft Authenticator app](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-mfasettings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#report-suspicious-activity)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.3",
      "ZtmmFunctionName": "Risk Assessments"
    },
    {
      "TestId": "24551",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Authentication on Windows uses Windows Hello for Business",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nWindows Hello for Business policy is not assigned or not enforced.\n\n\n## Windows Hello for Business Policy is Configured and Assigned\n\nWindows Hello For Business ([Tenant Wide Setting](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesEnrollmentMenu/~/windowsEnrollment) ): ❓ Not Configured.\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [Windows Hello for Business](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ❌ Not assigned | None |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "If policies for Windows Hello for Business (WHfB) aren't configured and assigned to all users and devices, threat actors can exploit weak authentication mechanisms—like passwords—to gain unauthorized access. This can lead to credential theft, privilege escalation, and lateral movement within the environment. Without strong, policy-driven authentication like WHfB, attackers can compromise devices and accounts, increasing the risk of widespread impact.\n\nEnforcing WHfB disrupts this attack chain by requiring strong, multifactor authentication, which helps reduce the risk of credential-based attacks and unauthorized access.\n\n**Remediation action**\n\nDeploy Windows Hello for Business in Intune to enforce strong, multifactor authentication:  \n- [Configure a tenant-wide Windows Hello for Business policy](https://learn.microsoft.com/intune/intune-service/protect/windows-hello?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-windows-hello-for-business-policy-for-device-enrollment) that applies at the time a device enrolls with Intune.\n- After enrollment, [configure Account protection profiles](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-account-protection-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#account-protection-profiles) and [assign](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups) different configurations for Windows Hello for Business to different groups of users and devices.\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": null,
      "TestDescription": "Container labels extend sensitivity labels beyond individual items to entire collaboration workspaces like Microsoft Teams, Microsoft 365 Groups, and SharePoint sites. These labels control workspace-level settings such as external sharing, guest access, device restrictions, and privacy.\n\nWithout container labels, users might be able to create Teams with external guest access even when handling confidential information. This action creates data exfiltration risks where properly labeled documents exist in improperly secured workspaces. Container labels can help to ensure that workspace security matches the sensitivity of stored content, for example, prevent documents labeled as \"Highly Confidential\" from residing in Teams sites that permit external sharing.\n\n**Remediation action**\n\n- [Use sensitivity labels to protect content in Microsoft Teams, Microsoft 365 groups, and SharePoint sites](https://learn.microsoft.com/purview/sensitivity-labels-teams-groups-sites?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Container labels are configured for Teams, groups, and sites",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Sensitivity Labels Configuration",
      "TestId": "35012",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Passed"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": null,
      "TestDescription": "The Azure Rights Management service provides the foundational encryption and access control technology for Microsoft Purview Information Protection. It's used with sensitivity labels that apply encryption, protects emails with Microsoft Purview Message Encryption, and even used with the older protection technologies such as SharePoint IRM and mail flow rules that apply encryption. This service should be activated for the tenant before you configure any other information protection features.\n\n**Remediation action**\n\n- [Activate the Azure Rights Management service](https://learn.microsoft.com/purview/activate-rights-management-service?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Azure Rights Management service is enabled",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"ExchangeOnline\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Rights Management Service",
      "TestId": "35024",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Passed"
    },
    {
      "TestId": "24550",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Data on Windows is protected by BitLocker encryption",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo Windows BitLocker policy is configured or assigned.\n\n\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Without a properly configured and assigned BitLocker policy in Intune, threat actors can exploit unencrypted Windows devices to gain unauthorized access to sensitive corporate data. Devices that lack enforced encryption are vulnerable to physical attacks, like disk removal or booting from external media, allowing attackers to bypass operating system security controls. These attacks can result in data exfiltration, credential theft, and further lateral movement within the environment.\n\nEnforcing BitLocker across managed Windows devices is critical for compliance with data protection regulations and for reducing the risk of data breaches.\n\n**Remediation action**\n\nUse Intune to enforce BitLocker encryption and monitor compliance across all managed Windows devices:  \n- [Create a BitLocker policy for Windows devices in Intune](https://learn.microsoft.com/intune/intune-service/protect/encrypt-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-and-deploy-policy)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n- [Monitor device encryption with Intune](https://learn.microsoft.com/intune/intune-service/protect/encryption-monitor?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Comprehensive deployment of the Global Secure Access client is foundational to achieving Zero Trust network security. If you don't deploy the Global Secure Access client to managed endpoints, those devices operate outside the organization's Security Service Edge controls. Threat actors can exploit unprotected endpoints to establish initial access, move laterally, or exfiltrate data without triggering network-level security policies.\n\nWithout the Global Secure Access client:\n\n- Devices can't benefit from compliant network checks in Conditional Access policies, source IP restoration, or tenant restrictions.\n- Credential theft and token replay attacks are more difficult to detect when traffic bypasses the security perimeter.\n- Managed endpoints can't access private applications through Microsoft Entra Private Access.\n\n**Remediation action**\n- Install the Global Secure Access client:\n    - [Windows client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-windows-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - [macOS client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-macos-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - [iOS client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-ios-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - [Android client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-android-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Monitor the Global Secure Access client health and connection status by using the [Global Secure Access dashboard](https://learn.microsoft.com/entra/global-secure-access/concept-traffic-dashboard?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Global Secure Access client is deployed on all managed endpoints",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\") OR (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access",
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25372",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21874",
      "TestMinimumLicense": "Free",
      "TestCategory": "External collaboration",
      "TestTitle": "Guest access is limited to approved tenants",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nAllow/Deny lists of domains to restrict external collaboration are not configured.\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "High",
      "TestRisk": "Medium",
      "TestDescription": "Limiting guest access to a known and approved list of tenants helps to prevent threat actors from exploiting unrestricted guest access to establish initial access through compromised external accounts or by creating accounts in untrusted tenants. Threat actors who gain access through an unrestricted domain can discover internal resources, users, and applications to perform additional attacks. \n\nOrganizations should take inventory and configure an allowlist or blocklist to control B2B collaboration invitations from specific organizations. Without these controls, threat actors might use social engineering techniques to obtain invitations from legitimate internal users. \n\n**Remediation action**\n\n- Learn how to [set up a list of approved domains](https://learn.microsoft.com/entra/external-id/allow-deny-list?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#add-an-allowlist).\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": "26888",
      "TestMinimumLicense": "Azure_Application_Gateway_WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "Diagnostic logging is enabled in Application Gateway WAF",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Application Gateway Web Application Firewall (WAF) protects web applications from common exploits and vulnerabilities such as SQL injection, cross-site scripting, and other OWASP Top 10 threats. When diagnostic logging is not enabled, security operations teams lose visibility into blocked attacks, rule matches, access patterns, and firewall events. A threat actor attempting to exploit web application vulnerabilities would go undetected because no WAF logs are being captured or analyzed. The absence of logging prevents correlation of WAF events with other security telemetry, eliminating the ability to construct attack timelines during incident investigations. Furthermore, compliance frameworks such as PCI-DSS, HIPAA, and SOC 2 require organizations to maintain audit logs of web application security events, and the lack of WAF diagnostic logging creates audit failures. Azure Application Gateway WAF provides multiple log categories including Application Gateway Access Logs, Performance Logs, and Firewall Logs, all of which must be routed to a destination such as Log Analytics, Storage Account, or Event Hub to enable security monitoring and forensic analysis.\n\n**Remediation action**\n\nCreate a Log Analytics workspace for storing Application Gateway WAF logs\n- [Create a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/quick-create-workspace)\n\nConfigure diagnostic settings for Application Gateway to enable log collection\n- [Create diagnostic settings in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/create-diagnostic-settings)\n\nEnable WAF logging to capture firewall events and rule matches\n- [Application Gateway WAF logs and metrics](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-metrics)\n\nMonitor Application Gateway using diagnostic logs and metrics\n- [Monitor Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-diagnostics)\n\nUse Azure Monitor Workbooks for visualizing and analyzing WAF logs\n- [Azure Monitor Workbooks](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics"
    },
    {
      "TestId": "26879",
      "TestMinimumLicense": "Azure WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "Request Body Inspection is enabled in Application Gateway WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Application Gateway Web Application Firewall (WAF) provides centralized protection for web applications against common exploits and vulnerabilities at the regional level. Request body inspection is a critical capability that allows the WAF to analyze the content of HTTP POST, PUT, and PATCH request bodies for malicious patterns. When request body inspection is disabled, threat actors can craft attacks that embed malicious SQL statements, scripts, or command injection payloads within form submissions, API calls, or file uploads that bypass all WAF rule evaluation. This creates a direct path for exploitation where threat actors gain initial access through unprotected application endpoints, execute arbitrary commands or queries against backend databases through SQL injection, exfiltrate sensitive data including credentials and customer information, establish persistence by modifying application data or injecting backdoors, and pivot to internal systems through compromised application server credentials. The WAF's managed rule sets, including OWASP Core Rule Set and Microsoft's Bot Manager rules, cannot evaluate threats they cannot see; disabling request body inspection renders these protections ineffective against body-based attack vectors that represent the majority of modern web application attacks.\n\n**Remediation action**\n\nOverview of WAF capabilities on Application Gateway including request body inspection\n- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview)\n\nGuidance on creating and configuring WAF policies including request body inspection settings\n- [Create Web Application Firewall policies for Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-waf-policy-ag)\n\nFAQ and best practices for tuning WAF including request body inspection limits\n- [Tuning Web Application Firewall for Azure Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-faq)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21816",
      "TestMinimumLicense": "P2",
      "TestCategory": "Privileged access",
      "TestTitle": "All Microsoft Entra privileged role assignments are managed with PIM",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound Microsoft Entra privileged role assignments that are not managed with PIM.\n\n\n## Assessment summary\n\n| Metric | Count |\n| :----- | :---- |\n| Privileged roles found | 31 |\n| Eligible Global Administrators | 6 |\n| Non-PIM privileged users | 12 |\n| Non-PIM privileged groups | 1 |\n| Permanent Global Administrator users | 20 |\n\n## Non-PIM managed privileged role assignments\n\n| Display name | User principal name | Role name | Assignment type |\n| :----------- | :------------------ | :-------- | :-------------- |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true) | perennial_ash@elapora.com | Application Administrator | Assigned |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true) | Komal.p@elapora.com | Global Reader | Assigned |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true) | chukka.p@elapora.com | Global Reader | Assigned |\n| [Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true) | Manoj.Kesana@elapora.com | Global Reader | Assigned |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true) | sandeep.p@elapora.com | Global Reader | Assigned |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true) | perennial_ash@elapora.com | Global Reader | Assigned |\n| [Afif](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0d6cfd05-fc46-440b-b605-66dd26dcd7d2/hidePreviewBanner~/true) | afif.p@elapora.com | Global Reader | Assigned |\n| [manoj-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/d71ccc09-c0a3-4604-9d02-49f7a3715f49/hidePreviewBanner~/true) | manoj-test@elapora.com | Global Reader | Assigned |\n| [praneeth-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/c1bdb03c-0079-40b1-96a8-3595de3b94a2/hidePreviewBanner~/true) | praneeth-test@elapora.com | Global Reader | Assigned |\n| [ash-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/c5c8ba63-4620-4e91-ac40-b66bebe07a0d/hidePreviewBanner~/true) | ash-test@elapora.com | Global Reader | Assigned |\n| [Aahmed Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/6f467d0a-25ec-435c-8fb9-9d53eb21e02f/hidePreviewBanner~/true) | aahmed-test@elapora.com | Global Reader | Assigned |\n| [komal-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/e0952dcb-8d63-496d-8661-05c86c1a51f0/hidePreviewBanner~/true) | komal-test@elapora.com | Global Reader | Assigned |\n| [PimLevel](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/RolesAndAdministrators/groupId/e8971185-8150-402e-b90f-5c1eb0d30dfe/menuId/) | N/A (Group) | Application Administrator | Assigned |\n\n## Permanent Global Administrator assignments\n\n| Display name | User principal name | Assignment type | On-Premises synced |\n| :----------- | :------------------ | :-------------- | :----------------- |\n| [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true) | merill@elapora.com | Assigned | N/A |\n| [Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0145d508-50fd-4f86-a47a-bf1c043c8358/hidePreviewBanner~/true) | jackief@elapora.com | Assigned | N/A |\n| [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true) | joshua@elapora.com | Assigned | N/A |\n| [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true) | damien.bowden@elapora.com | Assigned | N/A |\n| [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true) | emergency@elapora.com | Assigned | N/A |\n| [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true) | tyler@elapora.com | Assigned | N/A |\n| [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true) | ann@elapora.com | Assigned | N/A |\n| [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true) | aleksandar@elapora.com | Assigned | N/A |\n| [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true) | madura@elapora.com | Assigned | N/A |\n| [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0b37813c-ae19-4399-982f-16587f17f9c0/hidePreviewBanner~/true) | gael@elapora.com | Assigned | N/A |\n| [Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1433571b-3d7c-4a56-a9cc-67580848bc73/hidePreviewBanner~/true) | ravi.kalwani@elapora.com | Assigned | N/A |\n| [Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/a85798bd-652b-4eb9-ba90-3ee882df0179/hidePreviewBanner~/true) | varsha.mane@elapora.com | Assigned | N/A |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true) | Komal.p@elapora.com | Assigned | N/A |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true) | chukka.p@elapora.com | Assigned | N/A |\n| [Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true) | Manoj.Kesana@elapora.com | Assigned | N/A |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true) | sandeep.p@elapora.com | Assigned | N/A |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true) | perennial_ash@elapora.com | Assigned | N/A |\n| [Afif Ahmed](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/c0b65b13-37b1-4081-bcfc-14844159b4a5/hidePreviewBanner~/true) | AfifAhmed@elapora.com | Assigned | N/A |\n| [Ty Grady](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/210d3e96-015f-462d-b6d6-81e6023263df/hidePreviewBanner~/true) | Tyler.GradyTaylor_microsoft.com#EXT#@pora.onmicrosoft.com | Assigned | N/A |\n| [Ty Grady Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/43482f27-d1af-420f-84ba-e9148a700f45/hidePreviewBanner~/true) | tygradytest@elapora.com | Assigned | N/A |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Threat actors who compromise permanently assigned privileged accounts gain continuous access to high-impact directory operations. This extended access allows attackers to establish persistent backdoors, modify security configurations, and disable monitoring systems. Without time-limited access controls, compromised privileged accounts provide indefinite tenant control.\n\nRequiring eligible role assignments to be activated just-in-time, reduces the attack surface and limits attacker dwell time.\n\n**Remediation action**\n\n- [Use Privileged Identity Management to manage privileged Microsoft Entra roles](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-getting-started?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "25541",
      "TestMinimumLicense": [
        "Azure WAF",
        "Azure Application Gateway Standard SKU"
      ],
      "TestCategory": "Azure Network Security",
      "TestTitle": "Application Gateway WAF is Enabled in Prevention mode",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Application Gateway Web Application Firewall (WAF) protects web applications from common exploits and vulnerabilities, including SQL injection, cross-site scripting, and other OWASP Top 10 threats. WAF operates in two modes: Detection and Prevention. Detection mode logs matched requests but doesn't block traffic, while Prevention mode actively blocks malicious requests before they reach the backend application. When WAF is in Detection mode, web applications remain exposed to exploitation even though threats are being identified.\n\nWithout WAF in Prevention mode:\n\n- Threat actors can exploit web application vulnerabilities such as SQL injection and cross-site scripting, because matched requests are only logged, not blocked.\n- Organizations lose the active protection that managed and custom WAF rules provide, which reduces WAF to an observability tool rather than a security control.\n\n**Remediation action**\n\n- [Configure WAF on Azure Application Gateway](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#waf-modes) to switch the WAF policy from **Detection mode** to **Prevention mode**.\n- [Create and manage WAF policies for Application Gateway](https://learn.microsoft.com/azure/web-application-firewall/ag/create-waf-policy-ag?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to apply Prevention mode settings across all Application Gateway instances.\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestRisk": "Low",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": null,
      "TestDescription": "Double Key Encryption (DKE) provides an extra layer of protection for highly sensitive data by requiring two keys to decrypt content: one managed by Microsoft and one by the customer. This \"hold your own key\" approach ensures Microsoft can't decrypt content even with legal compulsion, meeting stringent regulatory requirements for data sovereignty.\n\nHowever, DKE introduces significant operational complexity including dedicated key service infrastructure, reduced feature compatibility, and increased support burden. Organizations should maintain 1-3 labels reserved for truly mission-critical or heavily regulated data, with documented business justification for each DKE label. Use standard encryption for general business content. Excessive DKE labels (4 or more) create management overhead, user confusion, and reduce collaboration. DKE should never be broadly deployed, as key service unavailability prevents access to business-critical documents.\n\n**Remediation action**\n\n- [Double Key Encryption](https://learn.microsoft.com/purview/double-key-encryption?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Set up Double Key Encryption](https://learn.microsoft.com/purview/double-key-encryption-setup?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Double Key Encryption labels are configured",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Encryption",
      "TestId": "35010",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data labeling and tagging",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21984",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "No Active low priority Entra recommendations found",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption"
    },
    {
      "TestId": "21806",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Secure the MFA registration (My Security Info) page",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSecurity information registration is protected by Conditional Access policies.\n## Conditional Access Policies targeting security information registration\n\n\n| Policy Name | User Actions Targeted | Grant Controls Applied |\n| :---------- | :-------------------- | :--------------------- |\n| [Security regisrtation info](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/508ae024-d4c4-42bf-a8c9-40257c214c10) | urn:user:registersecurityinfo |  |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Without Conditional Access policies protecting security information registration, threat actors can exploit unprotected registration flows to compromise authentication methods. When users register multifactor authentication and self-service password reset methods without proper controls, threat actors can intercept these registration sessions through adversary-in-the-middle attacks or exploit unmanaged devices accessing registration from untrusted locations. Once threat actors gain access to an unprotected registration flow, they can register their own authentication methods, effectively hijacking the target's authentication profile. The threat actors can bypass security controls and potentially escalate privileges throughout the environment because they can maintain persistent access by controlling the MFA methods. The compromised authentication methods then become the foundation for lateral movement as threat actors can authenticate as the legitimate user across multiple services and applications.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy for security info registration](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-security-info-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure known network locations](https://learn.microsoft.com/entra/identity/conditional-access/concept-assignment-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Enable combined security info registration](https://learn.microsoft.com/entra/identity/authentication/howto-registration-mfa-sspr-combined?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "When the Internet Access forwarding profile isn't enabled, users can access internet resources without routing traffic through the Secure Web Gateway. This gap allows threat actors to bypass security controls that block threats, malicious content, and unsafe destinations.\n\nWithout this protection:\n\n- Organizations lose visibility into traffic patterns. They can't detect data exfiltration, connections to malicious domains, or unauthorized external access.\n- Threat actors can deliver malware, establish command and control connections, or exfiltrate data through unmonitored channels.\n- Threat actors can use compromised credentials or social engineering to gain initial access, download tools, establish persistence, or communicate with external infrastructure.\n- Threat actors can use compromised accounts to blend with typical user behavior and access external resources without triggering security alerts based on user context, device compliance, or location.\n\n**Remediation action**\n- Enable the Internet Access forwarding profile to route traffic through the Secure Web Gateway. For more information, see [How to manage the Internet Access traffic forwarding profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-internet-access-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Assign users and groups to the Internet Access profile to limit traffic forwarding to specific users. For more information, see [Global Secure Access traffic forwarding profiles](https://learn.microsoft.com/entra/global-secure-access/concept-traffic-forwarding?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Internet access forwarding profile is enabled",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25406",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.3",
      "ZtmmFunctionName": "Data monitoring and access control",
      "TestStatus": "Passed"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "The super user feature of the Azure Rights Management service grants designated accounts the ability to decrypt content your organization has encrypted by using this service, regardless of the original permissions assigned. Super users might be necessary for eDiscovery, data recovery, compliance investigations, and content migration. The super user feature ensures that authorized people and services can always read and inspect the data that the Azure Rights Management service encrypts for your organization.\n\nWhen you use a group to designate super user accounts, membership of that group must be carefully controlled and limited, for example, to service accounts used by compliance tools or eDiscovery platforms. Unless you have a feature or business need that requires the feature to be enabled all the time, Microsoft recommends keeping the feature disabled by default, and enabling it only when needed. When you use a group to designate super user accounts, use Microsoft Entra Privileged Identity Management (PIM) to reduce risk by enabling just‑in‑time access when required and minimizing permanent privilege.\n\n**Remediation action**\n\n- [Configure Azure Rights Management super users for discovery services or data recovery](https://learn.microsoft.com/purview/encryption-super-users?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#security-best-practices-for-the-super-user-feature)\n",
      "TestTitle": "Super user membership is configured for Microsoft Purview Information Protection",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"AipService\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Advanced Label Features",
      "TestId": "35011",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Failed"
    },
    {
      "TestId": "25466",
      "TestMinimumLicense": "Entra_Premium_Private_Access",
      "TestCategory": "Private Access",
      "TestTitle": "At least two Private Access connectors are active and healthy per connector group",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n❌ One or more Private Access connector groups have fewer than two active connectors, exposing private application access to a single point of failure.\n\n\n#### [Private Access Connector Groups](https://entra.microsoft.com/#view/Microsoft_Entra_GSA_Connect/Connectors.ReactView)\n\n| Connector group name | Region | Active connectors | Total connectors | Status |\n| :------------------- | :----- | ----------------: | ---------------: | :----- |\n| Default | aus | 0 | 0 | ❌ Fail |\n\n\n#### Connector Details for Failing Groups\n\n**Connector Group: Default** (Region: aus)\n\n_No connectors found in this group._\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Microsoft Entra Private Access relies on private network connectors—lightweight Windows Server agents that broker outbound connections from on-premises or cloud-hosted networks to the Global Secure Access service. Each connector group acts as the sole access path for the private applications assigned to it. If only one connector is deployed in a group serving a region, any failure of that host—whether due to a hardware fault, OS crash, scheduled patch reboot, or a threat actor deliberately disrupting connector host connectivity—immediately eliminates all private application access for users in that region. A threat actor who achieves enough access to terminate the connector Windows service or block its outbound TLS communication on ports 443/80 can silently deny access to private applications without triggering identity-layer alerts. The service marks a connector `inactive` after it stops heartbeating and removes it after 10 days; during that window, no automated failover occurs if it was the sole connector in the group. Because Private Access enforces Conditional Access policies at the point of connection—requiring the connector to be reachable to validate session tokens and enforce per-app policies—a downed single connector means Zero Trust controls cannot be applied, and users are denied access rather than routed through an alternative enforcement point. Microsoft documentation explicitly states: \"maintain a minimum of two healthy connectors to ensure resiliency and consistent availability,\" and \"you might experience downtime during an update if you have only one connector.\" Deploying at least two active connectors per connector group ensures load balancing, seamless automatic updates (which target one connector at a time), and continuity of Zero Trust enforcement if one connector fails.\n\n**Remediation action**\n\nInstall and register an additional private network connector on a Windows Server in the affected region\n- [How to configure private network connectors for Microsoft Entra Private Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-connectors)\n\nUnderstand connector group high-availability requirements and best practices\n- [Microsoft Entra private network connectors — Connector groups](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-connectors#connector-groups)\n\nReview sizing and resiliency guidance including the minimum two-connector recommendation\n- [Microsoft Entra private network connectors — Specifications and sizing requirements](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-connectors#specifications-and-sizing-requirements)\n\nApplication Proxy high-availability load balancing best practices applicable to Private Access connector groups\n- [Best practices for high availability of connectors](https://learn.microsoft.com/en-us/entra/identity/app-proxy/application-proxy-high-availability-load-balancing#best-practices-for-high-availability-of-connectors)\n\nTroubleshoot inactive or malfunctioning connectors\n- [Troubleshoot connectors](https://learn.microsoft.com/en-us/entra/global-secure-access/troubleshoot-connectors)\n\n\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Excessive assignment of roles like Global Administrator and Global Secure Access Administrator create a path for threat actors to compromise these identities. With these roles an attacker can authenticate, manipulate security policies, create or elevate accounts, disable monitoring, access all corporate data, and more. Limit access to these roles to a small set of administrators, and enable monitoring of assignments and activation for groups, guests, service principals, and disabled accounts to reduce the attack surface and enforce least privilege.\n\n**Remediation action**\n\n- [Emergency access accounts are configured appropriately](https://learn.microsoft.com/entra/fundamentals/zero-trust-protect-engineering-systems?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#emergency-access-accounts-are-configured-appropriately)\n- [Limit Global Administrator and Global Secure Access Administrator role assignments to a small set of administrators.](https://learn.microsoft.com/entra/fundamentals/zero-trust-protect-identities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#high-global-administrator-to-privileged-user-ratio)\n- [Configure role settings to require approval for Global Administrator activation](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Administrative privileges are tightly limited to prevent compromise",
      "TestPillar": "Network",
      "TestResult": "\n❌ GA/GSA roles include groups, guests, or service principals requiring immediate review.\n\n\n## [Global Administrator assignments](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles)\n\n**Role Definition ID**: 62e90394-69f5-4237-9190-012177145e10  \n**Total Assignment Count**: 29  \n**Valid Assignment Count**: 25  \n**Issue Count**: 4  \n\n### ❌ Non-compliant assignments\n\n| Name | Principal name | Type | User type | Account enabled | Status |\n| :----------- | :-- | :--- | :-------- | :-------------- | :----- |\n| Ty Grady | Tyler.GradyTaylor_microsoft.com#EXT#@pora.onmicrosoft.com | user | Guest | True | Fail |\n| PIMGlobalAdmin |  | group |  |  | Fail |\n| elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db |  | servicePrincipal |  |  | Fail |\n| Mailbox Migration Account |  | servicePrincipal |  |  | Fail |\n\n### ✅ Valid Member User assignments\n\n| Name | Principal name | Type | User type | Account enabled | Status |\n| :----------- | :-- | :--- | :-------- | :-------------- | :----- |\n| Adele Vance | AdeleV@pora.onmicrosoft.com | user | Member | True | Valid |\n| Afif Ahmed | AfifAhmed@elapora.com | user | Member | True | Valid |\n| Aleksandar Nikolic | aleksandar@elapora.com | user | Member | True | Valid |\n| Ann Quinzon | ann@elapora.com | user | Member | True | Valid |\n| Bagul Atayewa | bagula@elapora.com | user | Member | True | Valid |\n\n*Showing first 5 of 25 records. [View all assignments in Entra Portal](https://entra.microsoft.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/62e90394-69f5-4237-9190-012177145e10/roleId/62e90394-69f5-4237-9190-012177145e10/roleTemplateId/62e90394-69f5-4237-9190-012177145e10/roleName/Global%20Administrator/isRoleCustom~/false/resourceScopeId/%2F/resourceId/0817c655-a853-4d8f-9723-3a333b5b9235)*\n\n\n## [Global Secure Access Administrator assignments](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles)\n\n**Role Definition ID**: ac434307-12b9-4fa1-a708-88bf58caabc1  \n**Total Assignment Count**: 0  \n**Valid Assignment Count**: 0  \n**Issue Count**: 0  \n\n\n\n",
      "TestSfiPillar": "Protect identities and secrets",
      "TestMinimumLicense": [
        "AAD_PREMIUM",
        "AAD_PREMIUM_P2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25383",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation",
      "TestStatus": "Passed"
    },
    {
      "TestId": "24560",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Local administrator credentials on Windows are protected by Windows LAPS",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nCloud LAPS policy is assigned and enforced.\n\n\n## Windows Cloud LAPS policy is created and assigned\n\n| Policy Name | Status | Assignment | Backup Directory | Automatic Account Management |\n| :---------- | :----- | :--------- | :--------------- | :--------------------------- |\n| [relaps](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/accountprotection) | ✅ Assigned | **Included:** All Devices | ✅ Entra ID (AAD) | ❌ Not Configured |\n| [test](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/accountprotection) | ✅ Assigned | **Included:** All Users | ✅ Active Directory | ✅ Enabled |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Without enforcing Local Administrator Password Solution (LAPS) policies, threat actors who gain access to endpoints can exploit static or weak local administrator passwords to escalate privileges, move laterally, and establish persistence. The attack chain typically begins with device compromise—via phishing, malware, or physical access—followed by attempts to harvest local admin credentials. Without LAPS, attackers can reuse compromised credentials across multiple devices, increasing the risk of privilege escalation and domain-wide compromise.\n\nEnforcing Windows LAPS on all corporate Windows devices ensures unique, regularly rotated local administrator passwords. This disrupts the attack chain at the credential access and lateral movement stages, significantly reducing the risk of widespread compromise.\n\n**Remediation action**\n\nUse Intune to enforce Windows LAPS policies that rotate strong and unique local admin passwords, and that back them up securely:  \n- [Deploy Windows LAPS policy with Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/windows-laps-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-laps-policy)\n\nFor more information, see:  \n- [Windows LAPS policy settings reference](https://learn.microsoft.com/windows-server/identity/laps/laps-management-policy-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Learn about Intune support for Windows LAPS](https://learn.microsoft.com/intune/intune-service/protect/windows-laps-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "2.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21838",
      "TestMinimumLicense": "Free",
      "TestCategory": "Credential management",
      "TestTitle": "Security key authentication method enabled",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSecurity key authentication method is enabled for your tenant, providing hardware-backed phishing-resistant authentication.\n\n\n## FIDO2 security key authentication settings\n\n✅ **FIDO2 authentication method**\n- Status: Enabled\n- Include targets: All users\n- Exclude targets: Group: eam-block-user\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "FIDO2 security keys provide hardware-backed, phishing-resistant authentication that protects against credential theft and unauthorized access. Security keys use cryptographic proof of identity bound to a specific device, making credentials impossible to replicate or phish. Enabling this authentication method allows users to register security keys for strong passwordless authentication.\n\n**Remediation action**\n\n- [Enable FIDO2 security key authentication method](https://learn.microsoft.com/entra/identity/authentication/how-to-enable-passkey-fido2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-passkey-fido2-authentication-method)\n- [Manage authentication methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Web content filtering policies are the foundation of internet access control in Global Secure Access. Without any configured policies, users have unrestricted access to all internet destinations, exposing the organization to malware, phishing sites, and inappropriate content. Create filtering policies to block dangerous website categories and establish baseline internet access controls.\n\n**Remediation action**\n\n- [Configure web content filtering policies](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-web-content-filtering?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Web content filtering policies are configured",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25408",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption",
      "TestStatus": "Passed"
    },
    {
      "TestId": "24555",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Scope tag configuration is enforced to support delegated administration and least-privilege access",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nDelegated administration is enforced with custom Intune Scope Tags assignments.\n\n\n## Scope Tags\n\n| Scope Tag Name | Status | Assignment Target |\n| :------------- | :----- | :---------------- |\n| [Biscope](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/RolesLandingMenuBlade/~/scopeTags) | ✅ Assigned | **Included:** aad-conditional-access-excluded |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "If Intune scope tags aren't properly configured for delegated administration, attackers who gain privileged access to Intune or Microsoft Entra ID can escalate privileges and access sensitive device configurations across the tenant. Without granular scope tags, administrative boundaries are unclear, allowing attackers to move laterally, manipulate device policies, exfiltrate configuration data, or deploy malicious settings to all users and devices. A single compromised admin account can impact the entire environment. The absence of delegated administration also undermines least-privileged access, making it difficult to contain breaches and enforce accountability. Attackers might exploit global administrator roles or misconfigured role-based access control (RBAC) assignments to bypass compliance policies and gain broad control over device management.\n\nEnforcing scope tags segments administrative access and aligns it with organizational boundaries. This limits the blast radius of compromised accounts, supports least-privilege access, and aligns with Zero Trust principles of segmentation, role-based control, and containment.\n\n**Remediation action**\n\nUse Intune scope tags and RBAC roles to limit admin access based on role, geography, or business unit:  \n- [Learn how to create and deploy scope tags for distributed IT](https://learn.microsoft.com/intune/intune-service/fundamentals/scope-tags?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Implement role-based access control with Microsoft Intune](https://learn.microsoft.com/intune/intune-service/fundamentals/role-based-access-control?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "24540",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Windows Firewall policies protect against unauthorized network access",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAt least one Windows Firewall policy is created and assigned to a group.\n\n\n## Windows Firewall Configuration Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [WF_Policy](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/firewall) | ✅ Assigned | **Included:** WFgroup, My Test Device Group |\n| [WF_Policy2](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/firewall) | ❌ Not assigned | None |\n| [WF_Policy3](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/firewall) | ✅ Assigned | **Included:** All Devices, **Excluded:** My Test Device Group, WFgroup |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If policies for Windows Firewall aren't configured and assigned, threat actors can exploit unprotected endpoints to gain unauthorized access, move laterally, and escalate privileges within the environment. Without enforced firewall rules, attackers can bypass network segmentation, exfiltrate data, or deploy malware, increasing the risk of widespread compromise.\n\nEnforcing Windows Firewall policies ensures consistent application of inbound and outbound traffic controls, reducing exposure to unauthorized access and supporting Zero Trust through network segmentation and device-level protection.\n\n**Remediation action**\n\nConfigure and assign firewall policies for Windows in Intune to block unauthorized traffic and enforce consistent network protections across all managed devices:\n\n- [Configure firewall policies for Windows devices](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci). Intune uses two complementary profiles to manage firewall settings:\n  - **Windows Firewall** - Use this profile to configure overall firewall behavior based on network type.\n  - **Windows Firewall rules** - Use this profile to define traffic rules for apps, ports, or IPs, tailored to specific groups or workloads. This Intune profile also supports use of [reusable settings groups](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#add-reusable-settings-groups-to-profiles-for-firewall-rules) to help simplify management of common settings you use for different profile instances.\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n\nFor more information, see:  \n- [Available Windows Firewall settings](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-profile-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#windows-firewall-profile)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "25537",
      "TestMinimumLicense": [
        "Azure_Firewall_Standard",
        "Azure_Firewall_Premium"
      ],
      "TestCategory": "Azure Network Security",
      "TestTitle": "Threat intelligence is Enabled in Deny Mode on Azure Firewall",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Firewall threat intelligence-based filtering alerts on and denies traffic to and from known malicious IP addresses, fully qualified domain names (FQDNs), and URLs sourced from the Microsoft Threat Intelligence feed. When you don't enable threat intelligence in `Alert and deny` mode, Azure Firewall doesn't actively block traffic to known malicious destinations.\n\nIf you don't enable threat intelligence in `Alert and deny` mode:\n\n- Threat actors can communicate with known malicious infrastructure, enabling data exfiltration and command-and-control communication without active blocking.\n- Organizations that use `Alert only` mode can see threat activity in logs but can't prevent connections to known bad destinations.\n- All firewall policy tiers remain exposed to threats that the Microsoft Threat Intelligence feed already identified.\n\n**Remediation action**\n\n- [Configure threat intelligence settings in Azure Firewall Manager](https://learn.microsoft.com/azure/firewall-manager/threat-intelligence-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to set the threat intelligence mode to `Alert and deny` in the firewall policy.\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "24574",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Attack Surface Reduction rules are applied to Windows devices to prevent exploitation of vulnerable system components",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo Attack Surface Reduction policies found for Windows devices in Intune.\n\n**Required ASR Rules:**\n- Block execution of potentially obfuscated scripts\n- Block Win32 API calls from Office macros\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "If Intune profiles for Attack Surface Reduction (ASR) rules aren't properly configured and assigned to Windows devices, threat actors can exploit unprotected endpoints to execute obfuscated scripts and invoke Win32 API calls from Office macros. These techniques are commonly used in phishing campaigns and malware delivery, allowing attackers to bypass traditional antivirus defenses and gain initial access. Once inside, attackers escalate privileges, establish persistence, and move laterally across the network. Without ASR enforcement, devices remain vulnerable to script-based attacks and macro abuse, undermining the effectiveness of Microsoft Defender and exposing sensitive data to exfiltration. This gap in endpoint protection increases the likelihood of successful compromise and reduces the organization’s ability to contain and respond to threats.\n\nEnforcing ASR rules helps block common attack techniques such as script-based execution and macro abuse, reducing the risk of initial compromise and supporting Zero Trust by hardening endpoint defenses.\n\n**Remediation action**\n\nUse Intune to deploy **Attack Surface Reduction Rules** profiles for Windows devices to block high-risk behaviors and strengthen endpoint protection:\n- [Configure Intune profiles for Attack Surface Reduction Rules](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-asr-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#devices-managed-by-intune)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n\nFor more information, see:  \n- [Attack surface reduction rules reference](https://learn.microsoft.com/defender-endpoint/attack-surface-reduction-rules-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in the Microsoft Defender documentation.\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.4",
      "ZtmmFunctionName": "Device threat detection"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestDescription": "Sensitivity labels are the foundation of Microsoft Purview Information Protection. They enable organizations to classify and protect sensitive data across Microsoft 365, on-premises locations, and non-Microsoft applications.\n\nWithout sensitivity labels, organizations lack a standardized way to protect their data, leaving it vulnerable to unauthorized access and sharing. A well-designed label taxonomy typically includes 3-7 top-level labels—too many labels overwhelm users and reduce effectiveness.\n\n**Remediation action**\n\n- [Get started with sensitivity labels](https://learn.microsoft.com/purview/get-started-with-sensitivity-labels?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create and configure sensitivity labels and their policies](https://learn.microsoft.com/purview/create-sensitivity-labels?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Sensitivity labels are configured",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "NotConnectedToService",
      "TestCategory": "sensitivity-labels",
      "TestId": "35003",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Skipped"
    },
    {
      "TestId": "21832",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "All groups in Conditional Access policies belong to a restricted management administrative unit",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21781",
      "TestMinimumLicense": "P1",
      "TestCategory": "Privileged access",
      "TestTitle": "Privileged users sign in with phishing-resistant methods",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nFound Accounts have not registered phishing resistant methods\n\n\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy a Conditional Access policy to target privileged accounts and require phishing resistant credentials](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestTags": [
        "Authentication"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.4",
      "ZtmmFunctionName": "Network resilience"
    },
    {
      "TestId": "26887",
      "TestMinimumLicense": [
        "Azure_Firewall_Standard",
        "Azure_Firewall_Premium"
      ],
      "TestCategory": "Azure Network Security",
      "TestTitle": "Diagnostic logging is enabled in Azure Firewall",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Firewall processes all inbound and outbound network traffic for protected workloads, making it a critical control point for network security monitoring. When diagnostic logging is not enabled, security operations teams lose visibility into traffic patterns, denied connection attempts, threat intelligence matches, and IDPS signature detections. A threat actor who gains initial access to an environment can move laterally through the network without detection because no firewall logs are being captured or analyzed. The absence of logging prevents correlation of network events with other security telemetry, eliminating the ability to construct attack timelines during incident investigations. Furthermore, compliance frameworks such as PCI-DSS, HIPAA, and SOC 2 require organizations to maintain audit logs of network security events, and the lack of firewall diagnostic logging creates audit failures. Azure Firewall provides multiple log categories including application rule logs, network rule logs, NAT rule logs, threat intelligence logs, IDPS signature logs, and DNS proxy logs, all of which must be routed to a destination such as Log Analytics, Storage Account, or Event Hub to enable security monitoring and forensic analysis.\n\n**Remediation action**\n\nCreate a Log Analytics workspace for storing Azure Firewall logs\n- [Create a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/quick-create-workspace)\n\nConfigure diagnostic settings for Azure Firewall to enable log collection\n- [Create diagnostic settings in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/create-diagnostic-settings)\n\nEnable structured logs (resource-specific mode) for improved query performance and cost optimization\n- [Azure Firewall structured logs](https://learn.microsoft.com/en-us/azure/firewall/monitor-firewall#structured-azure-firewall-logs)\n\nUse Azure Firewall Workbook for visualizing and analyzing firewall logs\n- [Azure Firewall Workbook](https://learn.microsoft.com/en-us/azure/firewall/firewall-workbook)\n\nMonitor Azure Firewall metrics and logs for security operations\n- [Monitor Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/monitor-firewall)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Without compliant network controls in Conditional Access policies, organizations can't enforce that users connect to corporate resources through the Global Secure Access service. This limitation leaves authentication traffic vulnerable to interception and replay attacks from arbitrary network locations. \n\nA threat actor who obtains valid user credentials through phishing or credential theft can authenticate from any internet location, bypassing Global Secure Access network controls. Once authenticated, the threat actor can access Microsoft Entra ID-integrated applications and services, exfiltrate data, or establish persistence by creating additional credentials or modifying user permissions. \n\nThe compliant network check reduces this risk by requiring that authentication traffic originates from the Global Secure Access service, which tags authentication requests with tenant-specific network identity signals. This requirement enables Microsoft Entra ID Conditional Access to verify that users connect through the organization's secured network path before granting access.\n\n**Remediation action**\n- Enable Global Secure Access signaling for Conditional Access. For more information, see [Enable compliant network check with Conditional Access](https://learn.microsoft.com/entra/global-secure-access/how-to-compliant-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-global-secure-access-signaling-for-conditional-access).\n- Create a Conditional Access policy that requires compliant network for access. For more information, see [Protect your resources behind the compliant network](https://learn.microsoft.com/entra/global-secure-access/how-to-compliant-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#protect-your-resources-behind-the-compliant-network).\n- Deploy Global Secure Access clients on devices. For more information, see [Global Secure Access clients overview](https://learn.microsoft.com/entra/global-secure-access/concept-clients?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Understand compliant network enforcement. For more information, see [Compliant network check enforcement](https://learn.microsoft.com/entra/global-secure-access/how-to-compliant-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#compliant-network-check-enforcement).\n",
      "TestTitle": "Conditional Access policies use compliant network controls",
      "TestPillar": "Network",
      "TestResult": "\n❌ **Fail**: Global Secure Access signaling is disabled. Compliant network controls cannot function without this prerequisite.\n\n\n### [Global Secure Access Signaling Status](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Security.ReactView)\n\n| Setting | Value |\n| :------ | :---- |\n| Signaling status | ❌ Disabled |\n### [Compliant Network Named Location](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations)\n\n| Property | Value |\n| :------- | :---- |\n| Display name | All Compliant Network locations |\n| Network type | allTenantCompliantNetworks |\n| Is trusted | ✅ True |\n| Location ID | 3d46dbda-8382-466a-856d-eb00cbc6b910 |\n### [Conditional Access Policies Using Compliant Network](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies)\n\n❌ No enabled Conditional Access policies reference the compliant network location.\n\n**Summary:**\n\n- Global Secure Access signaling enabled: False\n- Compliant network location exists: True\n- Policies using standard pattern (block all except compliant): 0\n- Policies using alternative patterns: 0\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "AAD_PREMIUM",
        "AAD_PREMIUM_P2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25379",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption",
      "TestStatus": "Passed"
    },
    {
      "TestId": "24870",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Data",
      "TestTitle": "Secure Wi-Fi profiles protect macOS devices from unauthorized network access",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo Enterprise Wi-Fi profile for macOS exists or none are assigned.\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If Wi-Fi profiles aren't properly configured and assigned, macOS devices can fail to connect to secure networks or connect insecurely, exposing corporate data to interception or unauthorized access. Without centralized management, devices rely on manual configuration, increasing the risk of misconfiguration, weak authentication, and connection to rogue networks. These gaps can lead to data interception, unauthorized network access, and compliance violations.\n\nCentrally managing Wi-Fi profiles for macOS devices in Intune ensures secure and consistent connectivity to enterprise networks. This enforces authentication and encryption standards, simplifies onboarding, and supports Zero Trust by reducing exposure to untrusted networks.\n\n**Remediation action**\n\nUse Intune to configure and assign secure Wi-Fi profiles for macOS devices to enforce authentication and encryption standards:\n\n- [Configure Wi-Fi settings for macOS devices in Intune](https://learn.microsoft.com/intune/intune-service/configuration/wi-fi-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-profile)\n\nFor more information, see:\n\n- [Review the available Wi-Fi settings for macOS devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/wi-fi-settings-macos?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "27015",
      "TestMinimumLicense": "Azure WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "HTTP DDoS Protection Ruleset is Enabled in Application Gateway WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Application Gateway Web Application Firewall (WAF) provides HTTP DDoS protection through the Microsoft HTTP DDoS Ruleset (Microsoft_HTTPDDoSRuleSet), which detects and mitigates volumetric HTTP-based attacks at the application layer. Unlike network-layer DDoS attacks that target bandwidth and infrastructure, HTTP-based DDoS attacks exploit the application layer by sending seemingly legitimate HTTP requests at extremely high volumes to exhaust server resources, database connections, and application threads. \n\nWithout HTTP DDoS protection enabled, threat actors can execute HTTP flood attacks that overwhelm backend servers with GET or POST requests at rates far exceeding normal traffic patterns, slowloris attacks that hold connections open by sending partial HTTP requests to exhaust connection pools, and high-frequency request patterns designed to trigger resource-intensive operations like complex database queries or file processing. \n\nThe HTTP DDoS ruleset contains rule groups like ExcessiveRequests with rules 500100 and 500110 that detect abnormal request rates based on configurable sensitivity levels (High, Medium, Low) and can block, log, or redirect malicious traffic. These rules identify clients making excessive requests within short time windows and can automatically block them before they impact application performance. By enabling this ruleset on Application Gateway WAF policies, malicious HTTP traffic is identified and blocked at the gateway before reaching backend application servers, preserving application availability and protecting infrastructure from resource exhaustion attacks.\n\n**Remediation action**\n\n- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview) - Overview of WAF capabilities on Application Gateway including DDoS protection rulesets\n- [Web Application Firewall CRS rule groups and rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules) - Documentation of available managed rulesets including HTTP DDoS rules\n- [Create Web Application Firewall policies for Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-waf-policy-ag) - Step-by-step guidance on creating and configuring WAF policies with managed rulesets\n- [Azure DDoS Protection overview](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview) - Overview of Azure DDoS Protection capabilities including application-layer protection\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Without private DNS configuration, remote users can't resolve internal domain names through Microsoft Entra Private Access and must rely on public DNS servers. Threat actors can exploit this gap through DNS spoofing attacks that redirect users to malicious sites, enabling credential harvesting and data exfiltration. Organizations also lose visibility into DNS queries and can't enforce consistent security policies.\n\n**Remediation action**\n\n- [Configure private DNS for internal name resolution](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-quick-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#add-private-dns-suffixes)\n",
      "TestTitle": "Private DNS is configured for internal name resolution",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25399",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management",
      "TestStatus": "Failed"
    },
    {
      "TestId": "24561",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Local administrator credentials on macOS are protected during enrollment by macOS LAPS",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nNo macOS DEP tokens found in the tenant.\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Without enforcing macOS LAPS policies during Automated Device Enrollment (ADE), threat actors can exploit static or reused local administrator passwords to escalate privileges, move laterally, and establish persistence. Devices provisioned without randomized credentials are vulnerable to credential harvesting and reuse across multiple endpoints, increasing the risk of domain-wide compromise.\n\nEnforcing macOS LAPS ensures that each device is provisioned with a unique, encrypted local administrator password managed by Intune. This disrupts the attack chain at the credential access and lateral movement stages, significantly reducing the risk of widespread compromise and aligning with Zero Trust principles of least privilege and credential hygiene.\n\n**Remediation action**\n\nUse Intune to configure macOS ADE profiles that provision a local admin account with a randomized and encrypted password, and that enables secure rotation:  \n- [Configure macOS LAPS in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/enrollment/macos-laps?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Rotate local admin password (macOS)](https://learn.microsoft.com/intune/intune-service/remote-actions/device-rotate-local-admin-password?pivots=macos&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:  \n- [macOS ADE setup guide](https://learn.microsoft.com/intune/intune-service/enrollment/device-enrollment-program-enroll-macos?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "2.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "When PDF labeling is disabled (the default) in SharePoint, PDF files can't be labeled or display existing labels, which creates a protection gap. Unlike Office files, PDFs can circulate externally without visible classification markers, making it impossible for recipients to determine the handling requirements or for data loss prevention (DLP) policies to detect sensitive content.\n\nEnabling PDF labeling for SharePoint and OneDrive extends sensitivity label support to PDFs, allowing users to apply labels by using Office for the web and SharePoint, and supports other labeling methods such as auto-labeling policies to classify PDF content automatically.\n\n**Remediation action**\n\n- [Enable sensitivity labels for PDF files in SharePoint and OneDrive](https://learn.microsoft.com/purview/sensitivity-labels-sharepoint-onedrive-files?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#adding-support-for-pdf)\n",
      "TestTitle": "PDF labeling is enabled in SharePoint",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SharePointOnline\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "SharePoint Online",
      "TestId": "35006",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Investigate"
    },
    {
      "TestId": "21840",
      "TestMinimumLicense": "Free",
      "TestCategory": "Credential management",
      "TestTitle": "Security key attestation is enforced",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSecurity key attestation is not enforced, allowing unverified or potentially compromised security keys to be registered.\n## [Security key attestation policy details](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConfigureAuthMethodsBlade/authMethod~/%7B%22%40odata.type%22%3A%22%23microsoft.graph.fido2AuthenticationMethodConfiguration%22%2C%22id%22%3A%22Fido2%22%2C%22state%22%3A%22enabled%22%2C%22isSelfServiceRegistrationAllowed%22%3Atrue%2C%22isAttestationEnforced%22%3Afalse%2C%22excludeTargets%22%3A%5B%7B%22id%22%3A%2243b7bc87-77eb-4263-abad-e3c2478f0a35%22%2C%22targetType%22%3A%22group%22%2C%22displayName%22%3A%22eam-block-user%22%7D%5D%2C%22keyRestrictions%22%3A%7B%22isEnforced%22%3Afalse%2C%22enforcementType%22%3A%22allow%22%2C%22aaGuids%22%3A%5B%22de1e552d-db1d-4423-a619-566b625cdc84%22%2C%2290a3ccdf-635c-4729-a248-9b709135078f%22%2C%2277010bd7-212a-4fc9-b236-d2ca5e9d4084%22%2C%22b6ede29c-3772-412c-8a78-539c1f4c62d2%22%2C%22ee041bce-25e5-4cdb-8f86-897fd6418464%22%2C%2273bb0cd4-e502-49b8-9c6f-b59445bf720b%22%5D%7D%2C%22includeTargets%40odata.context%22%3A%22https%3A%2F%2Fgraph.microsoft.com%2Fbeta%2F%24metadata%23policies%2FauthenticationMethodsPolicy%2FauthenticationMethodConfigurations('Fido2')%2Fmicrosoft.graph.fido2AuthenticationMethodConfiguration%2FincludeTargets%22%2C%22includeTargets%22%3A%5B%7B%22targetType%22%3A%22group%22%2C%22id%22%3A%22all_users%22%2C%22isRegistrationRequired%22%3Afalse%7D%5D%2C%22enabled%22%3Atrue%2C%22target%22%3A%22All%20users%2C%20excluding%201%20group%22%2C%22isAllUsers%22%3Atrue%2C%22voiceDisabled%22%3Afalse%7D/canModify~/true/voiceDisabled~/false/userMemberIds~/%5B%5D/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/isCiamTenant~/false/isCiamTrialTenant~/false)\n- **Enforce attestation** : False ❌\n- **Key restriction policy** :\n  - **Enforce key restrictions** : False\n  - **Restrict specific keys** : Allow\n  - **AAGUID** :\n    - de1e552d-db1d-4423-a619-566b625cdc84\n    - 90a3ccdf-635c-4729-a248-9b709135078f\n    - 77010bd7-212a-4fc9-b236-d2ca5e9d4084\n    - b6ede29c-3772-412c-8a78-539c1f4c62d2\n    - ee041bce-25e5-4cdb-8f86-897fd6418464\n    - 73bb0cd4-e502-49b8-9c6f-b59445bf720b\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "When security key attestation isn't enforced, threat actors can exploit weak or compromised authentication hardware to establish persistent presence within organizational environments. Without attestation validation, malicious actors can register unauthorized or counterfeit FIDO2 security keys that bypass hardware-backed security controls, enabling them to perform credential stuffing attacks using fabricated authenticators that mimic legitimate security keys. This initial access lets threat actors escalate privileges by using the trusted nature of hardware authentication methods, then move laterally through the environment by registering more compromised security keys on high-privilege accounts. The lack of attestation enforcement creates a pathway for threat actors to establish command and control through persistent hardware-based authentication methods, ultimately leading to data exfiltration or system compromise while maintaining the appearance of legitimate hardware-secured authentication throughout the attack chain. \n\n**Remediation action**\n\n- [Enable attestation enforcement through the Authentication methods policy configuration](https://learn.microsoft.com/entra/identity/authentication/how-to-enable-passkey-fido2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-passkey-fido2-authentication-method).\n- [Configure approved list of security keys by Authenticator Attestation Globally Unique Identifier (AAGUID)](https://learn.microsoft.com/entra/identity/authentication/concept-fido2-hardware-vendor?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "21786",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "User sign-in activity uses token protection",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nThe tenant is missing properly configured Token Protection policies.\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "A threat actor can intercept or extract authentication tokens from memory, local storage on a legitimate device, or by inspecting network traffic. The attacker might replay those tokens to bypass authentication controls on users and devices, get unauthorized access to sensitive data, or run further attacks. Because these tokens are valid and time bound, traditional anomaly detection often fails to flag the activity, which might allow sustained access until the token expires or is revoked.\n\nToken protection, also called token binding, helps prevent token theft by making sure a token is usable only from the intended device. Token protection uses cryptography so that without the client device key, no one can use the token.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to require token protection](https://learn.microsoft.com/entra/identity/conditional-access/concept-token-protection?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "21777",
      "TestMinimumLicense": "Free",
      "TestCategory": "Access control",
      "TestTitle": "App instance property lock is configured for all multitenant applications",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound multi-tenant apps without app instance property lock configured.\n\n\n## Multi-tenant applications and their App Instance Property Lock setting\n\n\n| Application | Application ID | App Instance Property Lock configured |\n| :---------- | :------------- | :------------------------------------ |\n| [AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/2e311a1d-f5c0-41c6-b866-77af3289871e/isMSAApp~/false) | 2e311a1d-f5c0-41c6-b866-77af3289871e | False |\n| [Adatum Demo App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/d2934d2a-3fbc-44a1-bda0-13e8d8a73b15/isMSAApp~/false) | d2934d2a-3fbc-44a1-bda0-13e8d8a73b15 | False |\n| [EAM Provider](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/f8642471-b7d7-4432-9527-776071e69b8b/isMSAApp~/false) | f8642471-b7d7-4432-9527-776071e69b8b | True |\n| [ExtProperties](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/61a54643-d4b6-471d-bd7c-a55586155dfc/isMSAApp~/false) | 61a54643-d4b6-471d-bd7c-a55586155dfc | False |\n| [Graph Filter](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975/isMSAApp~/false) | c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975 | False |\n| [My Properties Bag](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/303b4699-5b62-451c-b951-7e10b01d9b6d/isMSAApp~/false) | 303b4699-5b62-451c-b951-7e10b01d9b6d | False |\n| [Tenant Extension Properties App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/7db77c2b-30c1-4379-838f-8767c1e0d619/isMSAApp~/false) | 7db77c2b-30c1-4379-838f-8767c1e0d619 | False |\n| [Tenant Extension Properties App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/271b9db4-6e96-430c-808f-973a776adeaf/isMSAApp~/false) | 271b9db4-6e96-430c-808f-973a776adeaf | False |\n| [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/e7dfcbb6-fe86-44a2-b512-8d361dcc3d30/isMSAApp~/false) | e7dfcbb6-fe86-44a2-b512-8d361dcc3d30 | True |\n| [da-typespec-todo-aad](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/9358444a-41ec-4a93-915a-4970b3f33738/isMSAApp~/false) | 9358444a-41ec-4a93-915a-4970b3f33738 | False |\n| [graph-developer-proxy-samples](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/3658d9e9-dc87-4345-b59b-184febcf6781/isMSAApp~/false) | 3658d9e9-dc87-4345-b59b-184febcf6781 | False |\n| [idpowerelectron](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/909fff82-5b0a-4ce5-b66d-db58ee1a925d/isMSAApp~/false) | 909fff82-5b0a-4ce5-b66d-db58ee1a925d | True |\n| [test-mta](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/5ebc726d-e583-4822-b111-95ee05503c7e/isMSAApp~/false) | 5ebc726d-e583-4822-b111-95ee05503c7e | True |\n| [test1](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/8d0c8cec-8d54-414b-abfd-7418b8d0bfa0/isMSAApp~/false) | 8d0c8cec-8d54-414b-abfd-7418b8d0bfa0 | True |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "App instance property lock prevents changes to sensitive properties of a multitenant application after the application is provisioned in another tenant. Without a lock, critical properties such as application credentials can be maliciously or unintentionally modified, causing disruptions, increased risk, unauthorized access, or privilege escalations.\n\n**Remediation action**\nEnable the app instance property lock for all multitenant applications and specify the properties to lock.\n- [Configure an app instance lock](https://learn.microsoft.com/entra/identity-platform/howto-configure-app-instance-property-locks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-an-app-instance-lock)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "24784",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Defender Antivirus policies protect macOS devices from malware",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nDefender Antivirus policies are configured and assigned in Intune for macOS.\n\n\n## A Microsoft Defender Antivirus policy is created and assigned in Intune for macOS\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [macOS Defender Antivirus Policy](https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/antivirus) | ✅ Assigned | **Included:** antivirustest |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If Microsoft Defender Antivirus policies aren't properly configured and assigned to macOS devices in Intune, attackers can exploit unprotected endpoints to execute malware, disable antivirus protections, and persist in the environment. Without enforced policies, devices run outdated definitions, lack real-time protection, or have misconfigured scan schedules, increasing the risk of undetected threats and privilege escalation. This enables lateral movement across the network, credential harvesting, and data exfiltration. The absence of antivirus enforcement undermines device compliance, increases exposure of endpoints to zero-day threats, and can result in regulatory noncompliance. Attackers use these gaps to maintain persistence and evade detection, especially in environments without centralized policy enforcement.\n\nEnforcing Defender Antivirus policies ensures that macOS devices are consistently protected against malware, supports real-time threat detection, and aligns with Zero Trust by maintaining a secure and compliant endpoint posture.\n\n**Remediation action**\n\nUse Intune to configure and assign Microsoft Defender Antivirus policies for macOS devices to enforce real-time protection, maintain up-to-date definitions, and reduce exposure to malware:  \n- [Configure Intune policies to manage Microsoft Defender Antivirus](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-antivirus-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#macos)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.4",
      "ZtmmFunctionName": "Device threat detection"
    },
    {
      "TestId": "24564",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Local account usage on Windows is restricted to reduce unauthorized access",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nNo Local Users and Groups policy is configured or assigned.\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Without a properly configured and assigned Local Users and Groups policy in Intune, threat actors can exploit unmanaged or misconfigured local accounts on Windows devices. This can lead to unauthorized privilege escalation, persistence, and lateral movement within the environment. If local administrator accounts aren't controlled, attackers can create hidden accounts or elevate privileges, bypassing compliance and security controls. This gap increases the risk of data exfiltration, ransomware deployment, and regulatory noncompliance.\n\nEnsuring that Local Users and Groups policies are enforced on managed Windows devices, by using account protection profiles, is critical to maintaining a secure and compliant device fleet.\n\n\n**Remediation action**\n\nConfigure and deploy a **Local user group membership** profile from Intune account protection policy to restrict and manage local account usage on Windows devices:  \n- Create an [Account protection policy for endpoint security in Intune](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-account-protection-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#account-protection-profiles)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "25413",
      "TestMinimumLicense": "Entra_Premium_Internet_Access",
      "TestCategory": "Global Secure Access",
      "TestTitle": "Sensitive data exfiltration through file transfers is prevented by network content filtering policies",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n❌ No file policy is configured. File transfers are unmonitored and the organization is exposed to data exfiltration risk.\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "Without network content filtering through file policies, threat actors can exfiltrate data to unsanctioned destinations through browsers, applications, add-ins, and APIs. When file policies are not configured, threat actors exploit unmanaged cloud applications and generative AI tools as exfiltration channels for sensitive information.\n\n**Remediation action**\n\nFollow these steps to configure file policy protection:\n\n- [Configure web content filtering policies in Global Secure Access, which covers the foundational approach for creating filtering policies including file policies](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering)\n- [Create and manage security profiles that group filtering policies for enforcement through Conditional Access](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-traffic-forwarding)\n- [Link security profiles to Conditional Access policies for user-aware and context-aware enforcement of network security policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session)\n- [Deploy the Global Secure Access client on end-user devices to enable traffic acquisition and policy enforcement](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-install-windows-client)\n\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21886",
      "TestMinimumLicense": "P1",
      "TestCategory": "Applications management",
      "TestTitle": "Applications are configured for automatic user provisioning",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nApplications that are configured for SSO and support provisioning are NOT configured for provisioning.\n\n\n## Applications that are NOT configured for provisioning\n\n\n| Application Name | Object ID | Application ID |\n| :--------------- | :-------- | :------------- |\n| [21869testapp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e69e29be-ba40-445a-9824-a3a45e0ae57a/appId/dd63d132-18fb-4f2e-aec4-82b97f30301f/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | e69e29be-ba40-445a-9824-a3a45e0ae57a | dd63d132-18fb-4f2e-aec4-82b97f30301f |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ba63bb52-182c-4ec6-9cc8-ad2287cf51ed/appId/76249b01-8747-4db4-843f-6478d5b32b14/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | ba63bb52-182c-4ec6-9cc8-ad2287cf51ed | 76249b01-8747-4db4-843f-6478d5b32b14 |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | dc89bf5d-83e8-4419-9162-3b9280a85755 | 091edd89-b342-4bb5-9144-82fe6c913987 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | f7b07e81-79a0-4e51-b93a-169b8f2f6c4e | f816d68b-aec7-4eab-9ebc-bd23b0d04e35 |\n| [Docusign](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c6c64515-9c2c-4458-830d-fda30f7f55b5/appId/bc582926-d3ef-48e0-9a43-e813b898afb0/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | c6c64515-9c2c-4458-830d-fda30f7f55b5 | bc582926-d3ef-48e0-9a43-e813b898afb0 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 5eec0e98-b81a-422a-ab61-f8de2729330d | f76d7d98-02ee-4e62-9345-36016a72e664 |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 39861745-eda1-4e3c-8358-d0ba931f12bb | d3a04f85-a969-436b-bf4d-eae0a91efb4c |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/84dc13ec-5754-4745-90f9-5cc92a5ded28/appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 84dc13ec-5754-4745-90f9-5cc92a5ded28 | 9c599cd2-9fb0-4815-b65c-83be33f5df1b |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 13720002-03b6-462f-ac2f-765f0f9b3f58 | 1a2a1d4c-1d76-44ec-95f4-3ed5345423a9 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | d589a2e6-4a78-4cdd-901b-f574dc7880db | 6590313e-1c00-4c07-be28-72858e837a52 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 9a8af246-0d94-42eb-aaaf-836a9f9a4974 | ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | 31e80a1b-3faa-4ce9-9794-2b77f61f20f7 | 8ae2b566-71f5-467e-8960-cfe8da3a2cfa |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "When applications that support both authentication and provisioning through Microsoft Entra aren't configured for automatic provisioning, organizations become vulnerable to identity lifecycle gaps that threat actors can exploit. Without automated provisioning, user accounts might persist in applications after employees leave the organization. This vulnerability creates dormant accounts that threat actors can discover through reconnaissance activities. These orphaned accounts often retain their original access permissions but lack active monitoring, making them attractive targets for initial access.\n\nThreat actors who gain access to these dormant accounts can use them to establish persistence in the target application, as the accounts appear legitimate and might not trigger security alerts. From these compromised application accounts, attackers can:\n\n- Attempt to escalate their privileges by exploring application-specific permissions\n- Access sensitive data stored within the application\n- Use the application as a pivot point to access other connected systems\n\nThe lack of centralized identity lifecycle management also makes it difficult for security teams to detect when an attacker is using these orphaned accounts, as the accounts might not be properly correlated with the organization's active user directory. \n\n**Remediation action**\n\n- [Configure application provisioning for missing applications](https://learn.microsoft.com/entra/identity/app-provisioning/configure-automatic-user-provisioning-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.6",
      "ZtmmFunctionName": "Automation & Orchestration"
    },
    {
      "TestId": "21898",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "All supported access lifecycle resources are managed with entitlement management packages",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "High",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21890",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "Require password reset notifications for user roles",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics"
    },
    {
      "TestId": "21953",
      "TestMinimumLicense": "P1",
      "TestCategory": "Devices",
      "TestTitle": "Local Admin Password Solution is deployed",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nLocal Admin Password Solution is deployed.\n## Local Admin Password Solution (LAPS) settings\n\n| Setting | Status |\n| :---- | :---- |\n|[Enable Microsoft Entra Local Administrator Password Solution (LAPS)](https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview) | Enabled\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Without Local Admin Password Solution (LAPS) deployed, threat actors exploit static local administrator passwords to establish initial access. After threat actors compromise a single device with a shared local administrator credential, they can move laterally across the environment and authenticate to other systems sharing the same password. Compromised local administrator access gives threat actors system-level privileges, letting them disable security controls, install persistent backdoors, exfiltrate sensitive data, and establish command and control channels. \n\nThe automated password rotation and centralized management of LAPS closes this security gap and adds controls to help manage who has access to these critical accounts. Without solutions like LAPS, you can't detect or respond to unauthorized use of local administrator accounts, giving threat actors extended dwell time to achieve their objectives while remaining undetected.\n\n**Remediation action**\n\n- [Configure Windows Local Administrator Password Solution](https://learn.microsoft.com/entra/identity/devices/howto-manage-local-admin-passwords?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "21828",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Authentication transfer is blocked",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAuthentication transfer is blocked by Conditional Access Policy(s).\n## Conditional Access Policies targeting Authentication Transfer\n\n\n| Policy Name | Policy ID | State | Created | Modified |\n| :---------- | :-------- | :---- | :------ | :------- |\n| [Block Device Code](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/db2153a1-40a2-457f-917c-c280b204b5cd) | db2153a1-40a2-457f-917c-c280b204b5cd | enabled | 02/28/2024 00:22:50 | 2026-07-01 |\n\n\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Blocking authentication transfer in Microsoft Entra ID is a critical security control. It helps protect against token theft and replay attacks by preventing the use of device tokens to silently authenticate on other devices or browsers. When authentication transfer is enabled, a threat actor who gains access to one device can access resources to nonapproved devices, bypassing standard authentication and device compliance checks. When administrators block this flow, organizations can ensure that each authentication request must originate from the original device, maintaining the integrity of the device compliance and user session context.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to block authentication transfer](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-authentication-flows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-transfer-policies)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "21799",
      "TestMinimumLicense": "P2",
      "TestCategory": "Access control",
      "TestTitle": "Restrict high risk sign-ins",
      "TestSfiPillar": "Accelerate response and remediation",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSome high-risk sign-in attempts are not adequately mitigated by Conditional Access policies.\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "When high-risk sign-ins are not properly restricted through Conditional Access policies, organizations expose themselves to security vulnerabilities. Threat actors can exploit these gaps for initial access through compromised credentials, credential stuffing attacks, or anomalous sign-in patterns that Microsoft Entra ID Protection identifies as risky behaviors. Without appropriate restrictions, threat actors who successfully authenticate during high-risk scenarios can perform privilege escalation by misusing the authenticated session to access sensitive resources, modify security configurations, or conduct reconnaissance activities within the environment. Once threat actors establish access through uncontrolled high-risk sign-ins, they can achieve persistence by creating additional accounts, installing backdoors, or modifying authentication policies to maintain long-term access to the organization's resources. The unrestricted access enables threat actors to conduct lateral movement across systems and applications using the authenticated session, potentially accessing sensitive data stores, administrative interfaces, or critical business applications. Finally, threat actors achieve impact through data exfiltration, or compromise business-critical systems while maintaining plausible deniability by exploiting the fact that their risky authentication was not properly challenged or blocked.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to require MFA for elevated sign-in risk](https://learn.microsoft.com/entra/identity/conditional-access/policy-risk-based-sign-in?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.3",
      "ZtmmFunctionName": "Risk Assessments"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Global Secure Access requires specific Microsoft Entra licenses to function, including Microsoft Entra Internet Access and Microsoft Entra Private Access, both of which require Microsoft Entra ID P1 as a prerequisite. Without valid licenses provisioned in the tenant, administrators can't configure traffic forwarding profiles, security policies, or remote network connections. If you don't assign licenses to users, their traffic doesn't route through Global Secure Access, and remains unprotected by security controls.\n\nWithout this protection:\n\n- Threat actors can bypass web content filtering, threat protection, and Conditional Access policies.\n- Expired or suspended subscriptions can halt the Global Secure Access service, creating security gaps where previously protected traffic flows go unmonitored.\n\n**Remediation action**\n- Review Global Secure Access licensing requirements and purchase appropriate licenses. For more information, see [Licensing overview](https://learn.microsoft.com/entra/global-secure-access/overview-what-is-global-secure-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#licensing-overview).\n- Assign licenses to users through the Microsoft Entra admin center. For more information, see [Assign licenses to users](https://learn.microsoft.com/entra/fundamentals/license-users-groups?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Use group-based licensing for easier management at scale. For more information, see [Group-based licensing](https://learn.microsoft.com/entra/fundamentals/concept-group-based-licensing?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Monitor license utilization through Microsoft 365 admin center. For more information, see [Microsoft 365 admin center](https://admin.microsoft.com/Adminportal/Home#/licenses).\n- Review Microsoft Entra Suite as an alternative that includes both Internet Access and Private Access. For more information, see [What's new in Microsoft Entra](https://learn.microsoft.com/entra/fundamentals/whats-new?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#microsoft-entra-suite).\n",
      "TestTitle": "Global Secure Access licenses are available in the tenant and assigned to users",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\") OR (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access",
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25375",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption",
      "TestStatus": "Passed"
    },
    {
      "TestId": 21862,
      "TestMinimumLicense": "P2",
      "TestCategory": "Monitoring",
      "TestTitle": "All risky workload identities are triaged",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test is for tenants that are licensed for Entra Workload ID. See [Entra Workload ID licensing](https://learn.microsoft.com/entra/workload-id/workload-identities-faqs)\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "Compromised workload identities (service principals and applications) allow threat actors to gain persistent access without user interaction or multifactor authentication. Microsoft Entra ID Protection monitors these identities for suspicious activities like leaked credentials, anomalous API traffic, and malicious applications. Unaddressed risky workload identities enable privilege escalation, lateral movement, data exfiltration, and persistent backdoors that bypass traditional security controls. Organizations must systematically investigate and remediate these risks to prevent unauthorized access. \n\n**Remediation action**\n\n- [Investigate and remediate risky workload identities](https://learn.microsoft.com/entra/id-protection/concept-workload-identity-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#investigate-risky-workload-identities)\n- [Apply Conditional Access policies for workload identities](https://learn.microsoft.com/entra/identity/conditional-access/workload-identity?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21892",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "All sign-in activity comes from managed devices",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n❌ Not all sign-in activity comes from managed devices.\n\n### Managed device conditional access policy summary\n\nThe table below lists all Conditional Access policies that require a compliant device or a hybrid joined device.\n| Name | All users | All apps | Compliant device | Hybrid joined device | Policy state | Status |\n| :--- | :---:  | :---: | :---: | :---: | :--- | :--- |\n| [\\[RaviK\\] - CA policy for Compliant devices](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/dfde11d6-2433-45dc-86dc-f191dcac3bd9) | 🔴 | 🔴 | 🟢 | 🔴 | 🔴 Disabled | ❌ Fail |\n| [\\[RaviK\\] - Require app protection policy](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6909c0fb-c830-42b6-a438-c41d4010518f) | 🔴 | 🔴 | 🟢 | 🔴 | 🟢 Enabled | ❌ Fail |\n| [ALEX - MFA for risky sign-ins](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/5167662e-2022-45a5-825c-4514e5a0cfd4) | 🔴 | 🟢 | 🟢 | 🟢 | 🟡 Report-only | ❌ Fail |\n| [All sign-in activity comes from managed devices](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/7701ec7b-8983-4dd2-ae60-27cb0b2d3c6d) | 🟢 | 🟢 | 🟢 | 🟢 | 🟡 Report-only | ❌ Fail |\n| [Device compliance #1](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/2965e1d4-6146-41a5-abae-5219abf7d68f) | 🔴 | 🟢 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n| [Device compliancy](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/206c9071-89d7-4b57-adaf-87f78a4bd7f5) | 🔴 | 🟢 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n| [Require compliant or hybrid Azure AD joined device for admins](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/5ee30a46-6df0-48ff-b60b-45073b7e4e3e) | 🔴 | 🟢 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n| [Require compliant or hybrid Azure AD joined device or multifactor authentication for all users](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/05439c0a-90b2-45e9-92cc-0e13ddc3b9c3) | 🔴 | 🟢 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n| [Require compliant or hybrid Azure AD joined device or multifactor authentication for all users](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/ee4fdb05-5aec-4616-b2da-6d16a2cb2a54) | 🔴 | 🟢 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n| [Securing security info registration](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/28ba1d93-c70c-4c7f-93e4-852705472e3d) | 🟢 | 🔴 | 🟢 | 🟢 | 🔴 Disabled | ❌ Fail |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "Requiring sign-ins from managed devices ensures that users access organizational resources only from devices that meet your security and compliance requirements. Unmanaged devices lack organizational security controls and endpoint protection, creating potential entry points for attackers. Using Conditional Access to require compliant or Microsoft Entra hybrid joined devices helps protect against credential theft and unauthorized access from untrusted endpoints.\n\n**Remediation action**\n\n- [Require compliant or hybrid joined devices with Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-device-compliance?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure device compliance policies in Microsoft Intune](https://learn.microsoft.com/mem/intune/protect/device-compliance-get-started?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "High",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "21869",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "Enterprise applications must require explicit assignment or scoped provisioning",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound enterprise applications that lack both assignment requirements and provisioning scoping.\n## Applications without provisioning jobs (1)\n\n| Display name | Reason |\n| :----------- | :----- |\n| [21869testapp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e69e29be-ba40-445a-9824-a3a45e0ae57a/appId/dd63d132-18fb-4f2e-aec4-82b97f30301f) | No provisioning jobs configured |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "When enterprise applications lack both explicit assignment requirements AND scoped provisioning controls, threat actors can exploit this dual weakness to gain unauthorized access to sensitive applications and data. The highest risk occurs when applications are configured with the default setting: \"Assignment required\" is set to \"No\" *and* provisioning isn't required or scoped. This dangerous combination allows threat actors who compromise any user account within the tenant to immediately access applications with broad user bases, expanding their attack surface and potential for lateral movement within the organization.\n\nWhile an application with open assignment but proper provisioning scoping (such as department-based filters or group membership requirements) maintains security controls through the provisioning layer, applications lacking both controls create unrestricted access pathways that threat actors can exploit. When applications provision accounts for all users without assignment restrictions, threat actors can abuse compromised accounts to conduct reconnaissance activities, enumerate sensitive data across multiple systems, or use the applications as staging points for further attacks against connected resources. This unrestricted access model is dangerous for applications that have elevated permissions or are connected to critical business systems. Threat actors can use any compromised user account to access sensitive information, modify data, or perform unauthorized actions that the application's permissions allow. The absence of both assignment controls and provisioning scoping also prevents organizations from implementing proper access governance. Without proper governance, it's difficult to track who has access to which applications, when access was granted, and whether access should be revoked based on role changes or employment status. Furthermore, applications with broad provisioning scopes can create cascading security risks where a single compromised account provides access to an entire ecosystem of connected applications and services.\n\n**Remediation action**\n- Evaluate business requirements to determine appropriate access control method. [Restrict a Microsoft Entra app to a set of users](https://learn.microsoft.com/entra/identity-platform/howto-restrict-your-app-to-a-set-of-users?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Configure enterprise applications to require assignment for sensitive applications. [Learn about the \"Assignment required\" enterprise application property](https://learn.microsoft.com/entra/identity/enterprise-apps/application-properties?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assignment-required).\n- Implement scoped provisioning based on groups, departments, or attributes. [Create scoping filters](https://learn.microsoft.com/entra/identity/app-provisioning/define-conditional-rules-for-provisioning-user-accounts?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-scoping-filters).\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "24547",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Compliance policies protect personally owned Android devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAt least one compliance policy for Android Enterprise Personally-Owned Work Profile exists and is assigned.\n\n\n## Compliance policy assignment for Android Enterprise Fully managed device is configured and assigned\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [My android personally-owned](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesComplianceMenu/~/policies) | ✅ Assigned | **Included:** aad-conditional-access-allow-legacy-auth, **Excluded:** Executive Management, HR |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If compliance policies aren't assigned to Android Enterprise personally owned devices in Intune, threat actors can exploit noncompliant endpoints to gain unauthorized access to corporate resources, bypass security controls, and introduce vulnerabilities. Without enforced compliance, devices can lack critical security configurations like passcode requirements, data storage encryption, and OS version controls. These gaps increase the risk of data leakage and unauthorized access. Inconsistent device compliance weakens the organization’s security posture and makes it harder to detect and remediate threats before significant damage occurs.\n\nEnforcing compliance policies ensures that personally owned Android devices meet core security requirements and supports Zero Trust by validating device health and reducing exposure to misconfigured or unmanaged endpoints.\n\n**Remediation action**\n\nCreate and assign Intune compliance policies to Android Enterprise personally owned devices to enforce organizational standards for secure access and management:  \n- [Create a compliance policy in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/create-compliance-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-policy)\n- [Review the Android Enterprise compliance settings you can manage with Intune](https://learn.microsoft.com/intune/intune-service/protect/compliance-policy-create-android-for-work?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "If organizations don't use Prompt Shield protection, threat actors can exploit prompt injection vulnerabilities to compromise AI-powered workflows. Malicious users can craft adversarial inputs that manipulate large language models into ignoring system instructions, disclosing confidential data, or executing unintended actions like generating phishing content.\n\nWithout network-level prompt filtering:\n\n- Direct prompt injection attacks can bypass application-layer safety mechanisms through sophisticated jailbreak techniques.\n- Indirect prompt injection occurs when threat actors embed malicious instructions in external content that the AI processes.\n- Each AI application must independently implement protection, creating inconsistent security postures and inadequate safeguards against new or custom AI deployments.\n\n**Remediation action**\n\n- [Enable the Internet Access traffic forwarding profile to route internet traffic through Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-internet-access-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- [Configure TLS inspection settings and deploy the CA certificate to allow inspection of encrypted AI application traffic](https://learn.microsoft.com/entra/global-secure-access/how-to-transport-layer-security-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Follow the steps in [Protect enterprise generative AI applications with Prompt Shield](https://learn.microsoft.com/entra/global-secure-access/how-to-ai-prompt-shield?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to:\n    - Create prompt policies to scan and block malicious prompts targeting generative AI applications.\n    - Link prompt policies to security profiles to organize them for Conditional Access targeting.\n    - Create Conditional Access policies to apply security profiles with prompt policies to users accessing internet resources.\n- [Install the Global Secure Access client on user devices to enable traffic acquisition](https://learn.microsoft.com/entra/global-secure-access/how-to-install-windows-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "AI Gateway protects enterprise generative AI applications from prompt injection attacks",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25415",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation",
      "TestStatus": "Passed"
    },
    {
      "TestId": "27000",
      "TestMinimumLicense": "Entra_Premium_Internet_Access",
      "TestCategory": "Global Secure Access",
      "TestTitle": "Web content filtering blocks high-risk categories",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n❌ One or more high-risk web content filtering categories (Criminal activity, Hacking, Illegal software) are not blocked. Configure web content filtering policies to block these Liability categories to protect against security risks and policy violations.\n\n\n## [Web Content Filtering – Category block status](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/WebFilteringPolicy.ReactView)\n\n| Category | Enforced by | CA enforced | Status |\n| :------- | :---------- | :---------- | :----- |\n| Criminal activity | None | N/A | ❌ Not blocked |\n| Hacking | None | N/A | ❌ Not blocked |\n| Illegal software | None | N/A | ❌ Not blocked |\n\n\n**Summary:**\n- Total required categories: 3\n- Categories blocked: 0\n- Categories not blocked: 3\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "When high-risk web content filtering categories such as Criminal activity, Hacking, and Illegal software are not blocked, users and devices connected through Global Secure Access remain exposed to dangerous attack vectors and liability risks. Sites categorized as Criminal activity provide guidance on committing illegal acts including fraud, building weapons, and evading detection, and users who access these resources may inadvertently download tools or scripts that threat actors can leverage to establish initial access to the corporate environment. Hacking sites promote unauthorized access techniques, distribute exploit code, and provide tutorials on stealing information and creating malicious software, enabling threat actors who compromise user devices to learn advanced attack methods and escalate their capabilities within the network. Illegal software sites distribute pirated applications, software cracks, and license key generators that frequently contain embedded malware, and users who download from these sources risk executing trojanized installers that establish persistence and enable lateral movement across corporate systems. The absence of blocking for these categories allows users to access content that introduces both security vulnerabilities and legal liability, as downloaded tools may violate software licensing agreements or facilitate unauthorized activities. Organizations that do not enforce blocking of these high-risk Liability categories through their Secure Web Gateway expose themselves to preventable attack vectors while potentially enabling policy violations that create regulatory and legal exposure.\n\n\n**Remediation action**\n\n1. [Configure web content filtering](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering) - Create web content filtering policies that block high-risk Liability categories including Criminal activity, Hacking, and Illegal software.\n\n2. [Web content filtering categories reference](https://learn.microsoft.com/en-us/entra/global-secure-access/reference-web-content-filtering-categories) - Review the complete list of available web categories and their descriptions to understand what content is blocked.\n\n3. [Create security profiles](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering#create-a-security-profile) - Group filtering policies into security profiles that can be linked to Conditional Access policies for user-aware enforcement.\n\n4. [Enable Internet Access traffic forwarding](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-internet-access-profile) - Ensure the Internet Access traffic forwarding profile is enabled to route traffic through Global Secure Access for web content filtering to apply.\n\n5. [Link security profiles to Conditional Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering#create-and-link-conditional-access-policy) - Associate security profiles with Conditional Access policies to enforce web content filtering for targeted users and groups.\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "22128",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "Guests are not assigned high privileged directory roles",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nGuests with privileged roles were detected.\n\n\n## Guests with privileged roles\n\n\n| Role Name | User Name | User Principal Name | User Type | Assignment Type |\n| :-------- | :-------- | :------------------ | :-------- | :-------------- |\n| Application Administrator | [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true) | merillf_gmail.com#EXT#@pora.onmicrosoft.com | Guest | Eligible |\n| Global Administrator | [Ty Grady](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/210d3e96-015f-462d-b6d6-81e6023263df/hidePreviewBanner~/true) | Tyler.GradyTaylor_microsoft.com#EXT#@pora.onmicrosoft.com | Guest | Permanent |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "When guest users are assigned highly privileged directory roles such as Global Administrator or Privileged Role Administrator, organizations create significant security vulnerabilities that threat actors can exploit for initial access through compromised external accounts or business partner environments. Since guest users originate from external organizations without direct control of security policies, threat actors who compromise these external identities can gain privileged access to the target organization's Microsoft Entra tenant.\n\nWhen threat actors obtain access through compromised guest accounts with elevated privileges, they can escalate their own privilege to create other backdoor accounts, modify security policies, or assign themselves permanent roles within the organization. The compromised privileged guest accounts enable threat actors to establish persistence and then make all the changes they need to remain undetected. For example they could create cloud-only accounts, bypass Conditional Access policies applied to internal users, and maintain access even after the guest's home organization detects the compromise. Threat actors can then conduct lateral movement using administrative privileges to access sensitive resources, modify audit settings, or disable security monitoring across the entire tenant. Threat actors can reach complete compromise of the organization's identity infrastructure while maintaining plausible deniability through the external guest account origin. \n\n**Remediation action**\n\n- [Remove Guest users from privileged roles](https://learn.microsoft.com/entra/identity/role-based-access-control/best-practices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "24569",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "FileVault encryption protects data on macOS devices",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo relevant macOS FileVault encryption policies are configured or assigned.\n\n\n## Intune macOS FileVault policy is created and Assigned\n\n\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Without properly configured and assigned FileVault encryption policies in Intune, threat actors can exploit physical access to unmanaged or misconfigured macOS devices to extract sensitive corporate data. Unencrypted devices allow attackers to bypass operating system-level security by booting from external media or removing the storage drive. These attacks can expose credentials, certificates, and cached authentication tokens, enabling privilege escalation and lateral movement. Additionally, unencrypted devices undermine compliance with data protection regulations and increase the risk of reputational damage and financial penalties in the event of a breach.\n\nEnforcing FileVault encryption protects data at rest on macOS devices, even if lost or stolen. It disrupts credential harvesting and lateral movement, supports regulatory compliance, and aligns with Zero Trust principles of device trust.\n\n**Remediation action**\n\nUse Intune to enforce FileVault encryption and monitor compliance on all managed macOS devices:  \n- [Create a FileVault disk encryption policy for macOS in Intune](https://learn.microsoft.com/intune/intune-service/protect/encrypt-devices-filevault?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-endpoint-security-policy-for-filevault)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n- [Monitor device encryption with Intune](https://learn.microsoft.com/intune/intune-service/protect/encryption-monitor?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "When auto-labeling for SharePoint and OneDrive isn't set up, files uploaded without sensitivity labels might not be visible to Data Loss Protection (DLP) policies that rely on labels. As a result, those files can move through the environment with fewer safeguards, which can raise the risk of inappropriate sharing or access.\n    \nFor example, enabling at least one auto-labeling policy in enforcement mode for SharePoint and OneDrive helps classify sensitive files when users create or edit them. Auto-labeling classification supports downstream protections, such as DLP policies, so they can respond based on the file’s sensitivity and help reduce data exposure risk.\n\n**Remediation action**\n\n- [Apply sensitivity labels automatically for SharePoint and OneDrive](https://learn.microsoft.com/purview/apply-sensitivity-label-automatically?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Auto-labeling policies are enabled for SharePoint and OneDrive",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Information Protection",
      "TestId": "35021",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Passed"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": null,
      "TestDescription": "When users attach sensitive documents to emails, the email should inherit the highest sensitivity label from attachments to maintain consistent protection. Without this setting enabled, users might send unlabeled emails that contain sensitive attachments, creating a mismatch between the email's sensitivity and its actual content.\n\nEmail label inheritance automatically applies the attachment's highest priority label to the email message, ensuring protection levels match and prevent accidental data exposure.\n\n**Remediation action**\n\n- [Publish sensitivity labels](https://learn.microsoft.com/purview/create-sensitivity-labels?tabs=modern-label-scheme&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#publish-sensitivity-labels-by-creating-a-label-policy) to [Configure label inheritance from email attachments](https://learn.microsoft.com/purview/sensitivity-labels-office-apps?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-label-inheritance-from-email-attachments).\n",
      "TestTitle": "Email label policies inherit sensitivity from attachments",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Label Policy Configuration",
      "TestId": "35014",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Passed"
    },
    {
      "TestId": 21941,
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Token protection policies are configured",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nToken protection policies are configured.\n\n### Token protection policy summary\n\nThe table below lists all the token protection Conditional Access policies found in the tenant.\n\n| Name | Policy state | Users | Applications | Token protection | Status |\n| :--- | :---: | :---: | :---: | :---: | :---: |\n| [Token protection](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/ff7b71d1-fa63-4073-a959-4790f299de0f) | 🟡 Report-only | All | Selected | 🟢 | ❌ Fail |\n| [token protection with 1 apps](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/c51217bf-4044-4001-bfe6-ed8ef2624beb) | 🟢 Enabled | Selected | Selected | 🟢 | ✅ Pass |\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Token protection policies in Entra ID tenants are crucial for safeguarding authentication tokens from misuse and unauthorized access. Without these policies, threat actors can intercept and manipulate tokens, leading to unauthorized access to sensitive resources. This can result in data exfiltration, lateral movement within the network, and potential compromise of privileged accounts.\n\nWhen token protection is not properly configured, threat actors can exploit several attack vectors:\n\n1. **Token theft and replay attacks** - Attackers can steal authentication tokens from compromised devices and replay them from different locations\n2. **Session hijacking** - Without secure sign-in session controls, attackers can hijack legitimate user sessions\n3. **Cross-platform token abuse** - Tokens issued for one platform (like mobile) can be misused on other platforms (like web browsers)\n4. **Persistent access** - Compromised tokens can provide long-term unauthorized access without triggering security alerts\n\nThe attack chain typically involves initial access through token theft, followed by privilege escalation and persistence, ultimately leading to data exfiltration and impact across the organization's Microsoft 365 environment.\n\n**Remediation action**\n- [Configure Conditional Access policies as per the best practices](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection#create-a-conditional-access-policy)\n- [Microsoft Entra Conditional Access token protection explained](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection)\n- [Configure session controls in Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21844",
      "TestMinimumLicense": "Free",
      "TestCategory": "Access control",
      "TestTitle": "Block legacy Azure AD PowerShell module",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSummary\n\n- [Azure AD PowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/39921e28-0140-4bfc-ad89-26a3294f6ca9/appId/1b730954-1685-4b74-9bfd-dac224a7b894)\n- Sign in disabled: Yes\n\nAzure AD PowerShell is blocked in the tenant by turning off user sign in to the Azure Active Directory PowerShell Enterprise Application.\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Threat actors frequently target legacy management interfaces such as the Azure AD PowerShell module (AzureAD and AzureADPreview), which don't support modern authentication, Conditional Access enforcement, or advanced audit logging. Continued use of these modules exposes the environment to risks including weak authentication, bypass of security controls, and incomplete visibility into administrative actions. Attackers can exploit these weaknesses to gain unauthorized access, escalate privileges, and perform malicious changes. \n\nBlock the Azure AD PowerShell module and enforce the use of Microsoft Graph PowerShell or Microsoft Entra PowerShell to ensure that only secure, supported, and auditable management channels are available, which closes critical gaps in the attack chain. \n\n**Remediation action**\n\n- [Disable user sign-in for application](https://learn.microsoft.com/entra/identity/enterprise-apps/disable-user-sign-in-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Microsoft Rights Management Service (RMS) is the protection technology that enforces encryption for sensitivity labels and information protection policies. When users access encrypted content, their applications must authenticate to the RMS service (App ID: `00000012-0000-0000-c000-000000000000`) to decrypt the content. If Conditional Access policies incorrectly block or restrict this authentication - for example, by requiring multi-factor authentication (MFA), device compliance, or specific network locations - users will be unable to open encrypted emails, documents, or files protected by sensitivity labels.\nThis is most notable when trying to collaborate on MIP protected content from an external tenant to the source tenant.\nThe RMS service should be explicitly excluded from Conditional Access policies that enforce authentication controls, as the application itself is handling the decryption and the user has already authenticated through their primary client application. Blocking RMS authentication prevents the decryption process and breaks information protection workflows across Microsoft 365 services including Outlook, Word, Excel, PowerPoint, Teams, and SharePoint.\n\n**Remediation action**\n\nTo exclude RMS from Conditional Access policies:\n1. Navigate to [Microsoft Entra admin center > Entra ID > Conditional Access > Policies](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies)\n2. Select the policy that is blocking RMS\n3. Under Target resources > All resources (formerly 'All cloud apps')\n4. Under Exclude, select 'Select resources' and add \"Microsoft Rights Management Services\" (App ID: `00000012-0000-0000-c000-000000000000`)\n5. Save the policy\n\n- [Microsoft Entra configuration for Azure Information Protection](https://learn.microsoft.com/purview/encryption-azure-ad-configuration)\n- [Conditional Access policies and encrypted documents](https://learn.microsoft.com/purview/encryption-azure-ad-configuration#conditional-access-policies-and-encrypted-documents)\n- [Conditional Access: Cloud apps, actions, and authentication context](https://learn.microsoft.com/entra/identity/conditional-access/concept-conditional-access-cloud-apps)\n\n",
      "TestTitle": "Conditional Access policies don't exclude Rights Management workloads",
      "TestPillar": "Data",
      "TestResult": "\n❌ Microsoft Rights Management Service (RMS) is blocked or restricted by one or more Conditional Access policies.\n\n**Policies Affecting RMS:**\n\n| Policy Name | State | RMS Targeted | RMS Excluded | Grant Controls | Session Controls |\n| :--- | :--- | :--- | :--- | :--- | :--- |\n| [MFA - All users](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/474ddef4-5620-4e7a-8976-6e9b095b2675) | enabled | Yes | No | mfa | None |\n| [Guest-Meferna-Woodgrove-PhishingResistantAuthStrength](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/0f0a0c1c-41b0-4c18-ae20-d02492d03737) | enabled | Yes | No | None | None |\n| [Block Device Code](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/db2153a1-40a2-457f-917c-c280b204b5cd) | enabled | Yes | No | block | None |\n| [Block access except Compliant Network](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/9ee6df4b-165d-4f86-a176-0ddcc4ad886c) | enabled | Yes | No | block | None |\n\n",
      "TestSfiPillar": "",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Entra",
      "TestId": "35001",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Failed"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Adaptive Protection ensures that data loss prevention (DLP) policies are tailored to each user's risk profile, rather than applying the same rules to everyone. Without Adaptive Protection, organizations miss the chance to prevent insider threats because they can't respond to behavioral indicators like unusual data access or risky activities.\n\nBy integrating Insider Risk Management with DLP, Adaptive Protection uses machine learning to identify users as high, moderate, or low risk. This lets Adaptive Protection automatically apply stricter DLP controls to those at higher risk, while allowing more flexibility for others, an approach that helps protect sensitive data and supports operational efficiency.\n\n**Remediation action**\n\n- [Help dynamically mitigate risks with Adaptive Protection](https://learn.microsoft.com/purview/insider-risk-management-adaptive-protection?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Adaptive Protection is enabled in data loss prevention policies",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Data Loss Prevention (DLP)",
      "TestId": "35032",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.3",
      "ZtmmFunctionName": "Data monitoring and access control",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21808",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Restrict device code flow",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nDevice code flow is properly restricted in the tenant.\n## Conditional Access Policies targeting Device Code Flow\n\n| Policy Name | Status | Target Users | Target Resources | Grant Controls |\n| :---------- | :----- | :----------- | :--------------- | :------------ |\n| [Block Device Code](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/db2153a1-40a2-457f-917c-c280b204b5cd) | Enabled | All Users, Excluded: 8 users/groups | All Applications | Block (ANY) |\n\n## Inactive Conditional Access Policies targeting Device Code Flow\nThese policies are not contributing to your security posture because they are not enabled:\n\n| Policy Name | Status | Target Users | Target Resources | Grant Controls |\n| :---------- | :----- | :----------- | :--------------- | :------------ |\n| [Block DCF](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/b5ff217b-3d84-4581-bd92-5d8f8b8bab6a) | Disabled | All Users, Excluded: 1 users/groups | All Applications | Block (ANY) |\n\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Device code flow is a cross-device authentication flow designed for input-constrained devices. It can be exploited in phishing attacks, where an attacker initiates the flow and tricks a user into completing it on their device, thereby sending the user's tokens to the attacker. Given the security risks and the infrequent legitimate use of device code flow, you should enable a Conditional Access policy to block this flow by default.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to block device code flow](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-authentication-flows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#device-code-flow-policies).\n",
      "TestTags": [
        "ConditionalAccess"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "21796",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Block legacy authentication policy is configured",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nConditional Access to block legacy Authentication are configured and enabled.\n\n  - [Block legacy authentication](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/4086128c-3850-48ac-8962-e19a956828bd) (Report-only)\n  - [Block legacy authentication - Testing](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/bedecc1e-85c9-4d54-b885-cefe6bcc8763) (Report-only)\n  - [Block access except Compliant Network](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/9ee6df4b-165d-4f86-a176-0ddcc4ad886c)\n  - [Microsoft-managed: Block legacy authentication](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/612edf32-7535-48ef-a074-570a198adc17) (Disabled)\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Legacy authentication protocols such as basic authentication for SMTP and IMAP don't support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This lack of protection makes accounts using these protocols vulnerable to password-based attacks, and provides attackers with a means to gain initial access using stolen or guessed credentials.\n\nWhen an attacker successfully gains unauthorized access to credentials, they can use them to access linked services, using the weak authentication method as an entry point. Attackers who gain access through legacy authentication might make changes to Microsoft Exchange, such as configuring mail forwarding rules or changing other settings, allowing them to maintain continued access to sensitive communications.\n\nLegacy authentication also provides attackers with a consistent method to reenter a system using compromised credentials without triggering security alerts or requiring reauthentication.\n\nFrom there, attackers can use legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement. Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to Block legacy authentication](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "User",
        "Credential"
      ],
      "TestImpact": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Setting a default label ensures a base level of protection settings for all new and edited items that support sensitivity labels, and for new containers such as Teams. Users can manually override the label if necessary, and other labeling methods such as auto-labeling can replace the default label with a label that has a higher sensitivity level. Setting a default sensitivity label extends your labeling reach and reduces decision fatigue for users, ensuring content has at least a minimum level of protection.\n\nUnlabeled content might bypass data loss prevention (DLP) policies, and other protection solutions that rely on label detection. If appropriate, set a different default sensitivity label for unlabeled documents and Loop components and pages, emails and meeting invites, new containers, and also a default label for Power BI content.\n\n**Remediation action**\n\n- [Publish sensitivity labels by creating a label policy](https://learn.microsoft.com/purview/create-sensitivity-labels?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#publish-sensitivity-labels-by-creating-a-label-policy)\n- [Default label policy for Fabric and Power BI](https://learn.microsoft.com/fabric/governance/sensitivity-label-default-label-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "A default sensitivity label is configured in label policies",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Information Protection",
      "TestId": "35017",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation",
      "TestStatus": "Passed"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestDescription": "Without Microsoft Entra preauthentication configured on Application Proxy applications, threat actors can directly reach the internal URL of published on-premises applications without first proving their identity. When you use passthrough authentication, Application Proxy forwards traffic without validating the requestor, and all authentication responsibility falls to the internal application.\n\nIf you don't configure preauthentication on Application Proxy applications:\n\n- Threat actors can access internal application endpoints without identity verification, enabling reconnaissance and exploitation of backend vulnerabilities.\n- Conditional Access policies can't be enforced, so you can't require multifactor authentication, evaluate sign-in risk, or apply location-based restrictions.\n- You can't integrate with Microsoft Defender for Cloud Apps for real-time session monitoring and control.\n\n**Remediation action**\n\n- [Configure Microsoft Entra preauthentication for Application Proxy applications](https://learn.microsoft.com/entra/identity/app-proxy/application-proxy-add-on-premises-application?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#add-an-on-premises-app-to-microsoft-entra-id) by changing the Pre-Authentication method from **Passthrough** to **Microsoft Entra ID**.\n- [Use Microsoft Graph API to programmatically update Application Proxy settings](https://learn.microsoft.com/graph/application-proxy-configure-api?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Application Proxy applications require preauthentication to block anonymous access",
      "TestPillar": "Network",
      "TestResult": "\n❌ One or more Application Proxy applications are configured with passthrough authentication, allowing unauthenticated access to on-premises resources.\n\n\n\n## Application Proxy Pre-Authentication Configuration\n\n| Application name | Pre-Authentication type | Compliant |\n| :--------------- | :---------------------- | :-------- |\n| [SharePoint On-Prem App Proxy](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/AppProxy/objectId/53c7bdb1-cae2-43b0-9e2e-d8605395ceec/appId/19a70df3-cddf-48c7-be44-97b25b9857f1/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/) | aadPreAuthentication | ✅ Yes |\n| [Atlassian - Jira](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/AppProxy/objectId/2425e515-5720-4071-9fae-fd50f153c0aa/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/) | passthru | ❌ No |\n\n\n\n",
      "TestSfiPillar": "Protect identities and secrets",
      "TestMinimumLicense": [
        "AAD_PREMIUM",
        "AAD_PREMIUM_P2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "NotConnectedToService",
      "TestCategory": "Application Proxy",
      "TestId": "25401",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption",
      "TestStatus": "Skipped"
    },
    {
      "TestId": "21879",
      "TestMinimumLicense": "P2",
      "TestCategory": "External collaboration",
      "TestTitle": "All entitlement management assignment policies that apply to external users require approval",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo access package assignment policies found that apply to external users.\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Access package assignment policies that allow external users to request access should require approval. Without an approval gate, external users can self-provision access to organizational resources without oversight. Requiring approval ensures that a designated approver reviews each request, providing an opportunity to validate the requestor's identity and business justification before granting access.\n\n**Remediation action**\n\n- [Configure approval for access package assignment policies](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-approval-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review access package policies for external users](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-request-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "21845",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Temporary access pass is enabled",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nTemporary Access Pass is enabled, targeting all users, and enforced with conditional access policies.\n\n**Configuration summary**\n\n[Temporary Access Pass](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AdminAuthMethods/fromNav/Identity): Enabled ✅\n\n[Conditional Access policy for Security info registration](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies/fromNav/Identity): Enabled ✅\n\n[Authentication strength policy for Temporary Access Pass](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/AuthenticationStrength.ReactView/fromNav/Identity): Enabled ✅\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Without Temporary Access Pass (TAP) enabled, organizations face significant challenges in securely bootstrapping user credentials, creating a vulnerability where users rely on weaker authentication mechanisms during their initial setup. When users cannot register phishing-resistant credentials like FIDO2 security keys or Windows Hello for Business due to lack of existing strong authentication methods, they remain exposed to credential-based attacks including phishing, password spray, or similar attacks. Threat actors can exploit this registration gap by targeting users during their most vulnerable state, when they have limited authentication options available and must rely on traditional username + password combinations. This exposure enables threat actors to compromise user accounts during the critical bootstrapping phase, allowing them to intercept or manipulate the registration process for stronger authentication methods, ultimately gaining persistent access to organizational resources and potentially escalating privileges before security controls are fully established. \n\nEnable TAP and use it with security info registration to secure this potential gap in your defenses.\n\n**Remediation action**\n\n- [Learn how to enable Temporary Access Pass in the Authentication methods policy](https://learn.microsoft.com/entra/identity/authentication/howto-authentication-temporary-access-pass?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-the-temporary-access-pass-policy)\n- [Learn how to update authentication strength policies to include Temporary Access Pass](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strength-advanced-options?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Learn how to create a Conditional Access policy for security info registration with authentication strength enforcement](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-security-info-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": null,
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they’re legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Inactive applications don’t have highly privileged Microsoft Graph API permissions",
      "TestPillar": "Identity",
      "TestResult": "\nInactive Application(s) with high privileges were found\n\n\n## Apps with privileged Graph permissions\n\n| | Name | Risk | Delegate Permission | Application Permission | App owner tenant | Last sign in|\n| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n| ❌ | [Microsoft Sample Data Packs](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/63e1f0d4-bc2c-497a-bfe2-9eb4c8c2600e/appId/a1cffbc6-1cb3-44e4-a1d2-cee9cce700f1) | High | Files.ReadWrite, User.ReadWrite | Mail.Send, Calendars.ReadWrite, Calendars.ReadWrite.All, Mail.ReadWrite, User.ReadWrite.All, Sites.FullControl.All, Contacts.ReadWrite, Sites.Manage.All, MailboxSettings.ReadWrite, Sites.ReadWrite.All, Application.ReadWrite.OwnedBy, Directory.ReadWrite.All, Files.ReadWrite.All, Group.ReadWrite.All | Microsoft | Unknown | \n| ❌ | [Graph Explorer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f8f300a-870a-46ff-bdab-934e1436920d/appId/d3ce4cf8-6810-442d-b42e-375e14710095) | High | User.Read, Directory.AccessAsUser.All |  | graphExplorerMT | Unknown | \n| ❌ | [Modern Workplace Concierge](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad1c51e8-f8a8-4bf2-ac09-a3a20cba5fa5/appId/c65c4011-1b90-4ec9-b5e9-1ee17786ad84) | High | openid, profile, RoleManagement.Read.Directory, Application.Read.All, User.ReadBasic.All, Group.ReadWrite.All, DeviceManagementRBAC.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, Policy.Read.All, User.Read, DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All |  | Nicolonsky Tech | Unknown | \n| ❌ | [Azure AD Assessment (Test)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d4cf4286-0fbe-424d-b4f2-65aa2c568631/appId/c62a9fcb-53bf-446e-8063-ea6e2bfcc023) | High | AuditLog.Read.All, Directory.AccessAsUser.All, Directory.ReadWrite.All, Group.ReadWrite.All, IdentityProvider.ReadWrite.All, Policy.ReadWrite.TrustFramework, PrivilegedAccess.ReadWrite.AzureAD, PrivilegedAccess.ReadWrite.AzureResources, TrustFrameworkKeySet.ReadWrite.All, User.Invite.All, offline_access, openid, profile |  | Microsoft Accounts | Unknown | \n| ❌ | [Windows Virtual Desktop AME](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8369f33c-da25-4a8a-866d-b0145e29ef29/appId/5a0aa725-4958-4b0c-80a9-34562e23f3b7) | High |  | User.Read.All, Directory.Read.All | MS Azure Cloud | Unknown | \n| ❌ | [Reset Viral Users Redemption Status](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3a8785da-9965-473f-a97c-25fefdc39fee/appId/cc7b0696-1956-408b-876a-ad6bf2b9890b) | High | User.Read, User.Invite.All, User.ReadWrite.All, Directory.ReadWrite.All, offline_access, profile, openid |  | Microsoft | Unknown | \n| ✅ | [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b66231c2-9568-46f1-b61e-c5f8fd9edee4/appId/50827722-4f53-48ba-ae58-db63bb53626b) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  | Merill | 2023-07-05 | \n| ✅ | [idPowerToys - Release](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4654e05d-9f59-4925-807c-8eb2306e1cb1/appId/904e4864-f3c3-4d2f-ace2-c37a4ed55145) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  | Merill | 2023-10-24 | \n| ✅ | [Azure AD Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6c74be7f-bcc9-4541-bfe1-f113b90b0497/appId/68bc31c0-f891-4f4c-9309-c6104f7be41b) | High | Organization.Read.All, RoleManagement.Read.Directory, Application.Read.All, User.Read.All, Group.Read.All, Policy.Read.All, Directory.Read.All, SecurityEvents.Read.All, UserAuthenticationMethod.Read.All, AuditLog.Read.All, Reports.Read.All, openid, offline_access, profile |  | Microsoft | 2023-10-27 | \n| ✅ | [idPowerToys for Desktop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24cc58d8-2844-4974-b7cd-21c8a470e6bb/appId/520aa3af-bd78-4631-8f87-d48d356940ed) | High | Directory.Read.All, Policy.Read.All, Agreement.Read.All, CrossTenantInformation.ReadBasic.All, openid, profile, offline_access |  | Merill | 2025-02-16 | \n| ✅ | [entraChatAppMultiTenant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/855a57ff-88a6-4ad0-85d7-4f46d742730e/appId/5e00b345-a805-42a0-9caa-7d6cb761c668) | High | User.Read, openid, profile, offline_access, APIConnectors.Read.All, Application.ReadWrite.All, Policy.ReadWrite.AuthenticationFlows, Policy.Read.All, EventListener.ReadWrite.All, Policy.ReadWrite.AuthenticationMethod, Group.Read.All, AuditLog.Read.All, Policy.ReadWrite.ConditionalAccess, IdentityUserFlow.Read.All, Policy.ReadWrite.TrustFramework, TrustFrameworkKeySet.Read.All, Directory.ReadWrite.All |  | JJ Industries | 2025-05-08 | \n| ✅ | [Intune Documentation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/97b66fb0-f682-41e0-9aef-47f170c2abae/appId/56066daa-baba-438f-89d0-7ea3be2e2222) | High | User.Read, DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All, DeviceManagementManagedDevices.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, Group.Read.All, openid, profile, offline_access |  | Ugur Koc Lab | 2025-09-01 | \n| ✅ | [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f79df990-9ad2-4142-b5fd-8945ff334da3/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | High | User.Read | Directory.ReadWrite.All | Entra.Chat | 2025-09-09 | \n| ✅ | [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6bf7c616-88e8-4f7c-bdad-452e561fa777/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | High |  | User.ReadWrite.All | Pora | 2025-09-09 | \n| ✅ | [test public client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5e80ea33-31fa-49fd-9a94-61894bd1a6c9/appId/79a0c604-f215-4c52-8fbe-641d08aa7937) | High |  | User.Read.All | Pora | 2025-09-09 | \n| ✅ | [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bac0ba57-1876-448e-96bf-6f0481c99fda/appId/fef811e1-2354-43b0-961b-248fe15e737d) | High | User.Read, Directory.Read.All |  | Pora | 2025-09-09 | \n| ✅ | [Lokka](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1abc3899-a5df-40ab-8aa7-95d31edd4c01/appId/f581405a-9e57-4e81-91f1-40cd62f7595e) | High |  | DirectoryRecommendations.Read.All, Policy.ReadWrite.Authorization, PrivilegedAccess.Read.AzureAD, Reports.Read.All, Mail.Read, Directory.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, UserAuthenticationMethod.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, User.Read.All, PrivilegedAccess.Read.AzureADGroup, Mail.Send, DeviceManagementConfiguration.ReadWrite.All | Pora Inc. | 2025-09-09 | \n| ✅ | [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e31cd01e-afaf-4cc3-8d15-d3f9f7eb61e8/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) | High |  | DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, Mail.Send, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All, SecurityIdentitiesHealth.Read.All, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, SecurityIdentitiesSensors.Read.All | Pora Inc. | 2025-09-09 | \n| ✅ | [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e9fca357-cccd-4ec4-840f-7482f6f02818/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) | High |  | User.Read.All | Pora | 2025-09-09 | \n| ✅ | [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6d2e8d37-82b8-41e7-aa95-443a7401e8b8/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | High | User.Read | TermStore.Read.All, User.ReadWrite.All, User.Read.All, Sites.FullControl.All | Pora | 2025-09-09 | \n| ✅ | [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/aa64efdb-2d05-4c81-a9e5-80294bf0afac/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) | High | Policy.Read.All, User.Read, Directory.ReadWrite.All, Mail.ReadWrite | Mail.ReadWrite, Directory.ReadWrite.All | Pora | 2025-09-09 | \n| ✅ | [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/666a58ef-c3e5-4efc-828a-2ab3c0120677/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | High | User.Read | Sites.Read.All, Sites.Read.All | Pora | 2025-09-09 | \n| ✅ | [Trello](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3d6c91cf-d48f-4272-ac4c-9f989bbec779/appId/d77611ee-5051-4383-9af3-5ba3627306a7) | High |  | Application.Read.All | Pora Inc. | 2025-09-09 | \n| ✅ | [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/89bd9c7a-0c81-4a0a-9153-ff7cd0b81352/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) | High |  | GroupMember.Read.All, User.Read.All | Pora | 2025-09-09 | \n| ✅ | [My Doc Gen](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a445d652-f72d-4a88-9493-79d3c3c23d1b/appId/e580347d-d0aa-4aa1-9113-5daa0bb1c805) | High | User.Read, openid, profile, offline_access, Directory.Read.All, Policy.Read.All, Agreement.Read.All, CrossTenantInformation.ReadBasic.All |  | Pora | 2025-09-09 | \n| ✅ | [MyZt](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/716038b1-2811-40fc-8622-93e093890af0/appId/eee51d92-0bb5-4467-be6a-8f24ef677e4d) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, DeviceManagementServiceConfig.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementApps.Read.All, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, PrivilegedEligibilitySchedule.Read.AzureADGroup, openid, profile, offline_access |  | Pora | 2025-09-09 | \n| ✅ | [MyZtA\\[\\[](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d2a2a09d-7562-45fc-a950-36fedfb790f8/appId/d159fcf5-a613-435b-8195-8add3cdf4bff) | High | RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, Policy.Read.All, Agreement.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, User.Read, Directory.Read.All, PrivilegedEligibilitySchedule.Read.AzureADGroup, CrossTenantInformation.ReadBasic.All |  | Pora | 2025-09-09 | \n| ✅ | [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d54232da-de3b-4874-aef2-5203dbd7342a/appId/d99dd249-6ab3-4e92-be40-81af11658359) | High | User.Read | DirectoryRecommendations.Read.All, PrivilegedAccess.Read.AzureAD, Reports.Read.All, Mail.Send, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All | Pora | 2025-09-09 | \n| ✅ | [Graph PS - Zero Trust Workshop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f6e8dfdd-4c84-441f-ae6e-f2f51fd20699/appId/a9632ced-c276-4c2b-9288-3a34b755eaa9) | High | AuditLog.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, UserAuthenticationMethod.Read.All, openid, profile, offline_access |  | Pora | 2025-09-09 | \n| ✅ | [Maester DevOps Account - GitHub](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ce3af345-b0e0-4b15-808c-937d825bcf03/appId/f050a85f-390b-4d43-85a0-2196b706bfd6) | High |  | Mail.Send, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All, Policy.Read.ConditionalAccess, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All | Entra.Chat | 2025-09-09 | \n| ✅ | [Maester DevOps Account - New GitHub Action](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7c1885fd-fdf8-413a-86a6-f8867914272f/appId/143cb1b1-81af-4999-a292-a8c537601119) | High | User.Read | DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All | Pora Inc. | 2025-09-09 | \n| ✅ | [Maester Automation App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e3972142-1d36-4e7d-a777-ecd64619fcab/appId/55635484-743e-42e2-a78e-6bc15050ebde) | High | User.Read | Policy.Read.ConditionalAccess, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, Mail.Send, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All | Pora Inc. | 2025-09-09 | \n| ✅ | [elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c5632968-35cd-445d-926e-16e0afc9160e/appId/e876f7cb-13f3-48a4-8329-66d7b1fa33fb) | High |  | Policy.ReadWrite.Authorization, Policy.ReadWrite.DeviceConfiguration, Directory.ReadWrite.All | Pora Inc. | 2025-10-01 | \n| ✅ | [elapora-Maester-54d3ea01-5a07-45d0-8d69-e5f5b0b20098](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4faa0456-5ecb-49f3-bb9a-2dbe516e939a/appId/a8c184ae-8ddf-41f3-8881-c090b43c385f) | High |  | Mail.Send, DirectoryRecommendations.Read.All, Reports.Read.All, Directory.Read.All, Policy.Read.All | Pora | 2025-11-01 | \n| ✅ | [elapora-maester-demo-39ecb2b6-d900-496e-886f-d112cca4f1a9](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cc578aea-b1bd-434d-86d2-8a22c5728ded/appId/efec213e-0a85-4d7a-938f-3d97edd4ade0) | High |  | ReportSettings.Read.All, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, SecurityIdentitiesSensors.Read.All, SecurityIdentitiesHealth.Read.All, Policy.Read.ConditionalAccess, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All, DirectoryRecommendations.Read.All, Reports.Read.All, ThreatHunting.Read.All, PrivilegedAccess.Read.AzureAD, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All | Pora Inc. | 2025-11-01 | \n| ✅ | [MyVscode](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dfc83a5d-36e5-4506-ae9d-6ad5bb403377/appId/92abdce1-3952-4a8b-8720-e59257edd421) | Unranked | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All |  | Pora Inc. | 2025-11-15 | \n| ✅ | [Agent Identity Blueprint Example 4208296](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c845b130-ce1b-4124-96ca-465df0eaa10f/appId/d0e3212f-58a2-4511-8b56-bd57b023106d) | High | User.Read, Mail.Read, Calendars.Read | AgentIdUser.ReadWrite.IdentityParentedBy | Pora Inc. | 2025-11-18 | \n| ✅ | [Agent Identity Blueprint Example 4209295](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/20aaa39b-821d-40a5-8d8a-eff27f86bb4a/appId/f522f080-5192-4665-87a4-e1211b7adca6) | High | User.Read, Files.Read | AgentIdUser.ReadWrite.IdentityParentedBy | Pora Inc. | 2025-11-18 | \n| ✅ | [testSP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2361fd8a-fe89-4d07-9199-c117feb52b5e/appId/e47d8f25-5327-40f8-99fe-d832b99d938d) | High |  | CrossTenantInformation.ReadBasic.All, Policy.Read.ConditionalAccess, DeviceManagementManagedDevices.Read.All, RoleManagement.Read.All, DeviceManagementRBAC.Read.All, Policy.Read.PermissionGrant, DeviceManagementServiceConfig.Read.All, DirectoryRecommendations.Read.All, PrivilegedAccess.Read.AzureAD, AuditLog.Read.All, DeviceManagementConfiguration.Read.All, InformationProtectionPolicy.Read.All, UserAuthenticationMethod.Read.All, Directory.Read.All, IdentityRiskEvent.Read.All, LifecycleWorkflows-Reports.Read.All, NetworkAccessPolicy.Read.All, EntitlementManagement.Read.All, NetworkAccess-Reports.Read.All, IdentityRiskyUser.Read.All | Pora Inc. | 2025-11-27 | \n| ✅ | [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad36b6e2-273d-4652-a505-8481f096e513/appId/6ce0484b-2ae6-4458-b2b9-b3369f42fd6f) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  | Merill | 2025-12-02 | \n| ✅ | [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/35cbeecb-be21-4596-9869-0157d84f2d67/appId/c823a25d-fe94-494c-91f6-c7d51bf2df82) | High | User.Read | Sites.FullControl.All | Pora | 2026-03-02 | \n| ✅ | [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3dde25cc-223f-4a16-8e8f-6695940b9680/appId/e7dfcbb6-fe86-44a2-b512-8d361dcc3d30) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, DeviceManagementServiceConfig.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementApps.Read.All, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, PrivilegedEligibilitySchedule.Read.AzureADGroup, openid, profile, offline_access |  | Pora | 2026-03-07 | \n| ✅ | [ZT-PermissionTest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b264ce7f-a584-49bf-8dd4-d2a3971e97b9/appId/be667b5a-b863-4698-9f60-868ef968b857) | High | User.Read, AuditLog.Read.All, DeviceManagementConfiguration.Read.All, CrossTenantInformation.ReadBasic.All, Policy.Read.All, DeviceManagementApps.Read.All, Directory.Read.All, Reports.Read.All, DeviceManagementRBAC.Read.All, IdentityRiskyServicePrincipal.Read.All, DeviceManagementManagedDevices.Read.All, offline_access, DeviceManagementServiceConfig.Read.All, Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, EntitlementManagement.Read.All, IdentityRiskEvent.Read.All, IdentityRiskyUser.Read.All, Policy.Read.PermissionGrant, NetworkAccess.Read.All, PrivilegedAccess.Read.AzureAD, RoleManagement.Read.All, UserAuthenticationMethod.Read.All, openid, profile |  | Pora Inc. | 2026-03-13 | \n| ✅ | [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7c32eaee-ff26-4435-be3d-b4ced08f9edc/appId/303774c1-3c6f-4dfd-8505-f24e82f9212a) | High | User.Read | RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | Pora | 2026-03-24 | \n| ✅ | [entra-docs-email github DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7a94aec7-a5e3-48dd-b20f-3db74d689434/appId/ae06b71a-a0aa-4211-b846-fd74f25ccd45) | High | User.Read | Mail.Send | Pora Inc. | 2026-03-24 | \n| ✅ | [Maester DevOps Account - merill/maester-demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fdce906b-d2f6-4738-8c76-e4559b9e17e8/appId/91c84d77-3dce-4fb0-b0de-474a8606c812) | High |  | DirectoryRecommendations.Read.All, Reports.Read.All, ThreatHunting.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, SecurityIdentitiesSensors.Read.All, SecurityIdentitiesHealth.Read.All, Policy.Read.ConditionalAccess, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, ReportSettings.Read.All, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | Pora Inc. | 2026-03-24 | \n| ✅ | [GitHub Actions App for Microsoft Info script](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/852b4218-67d2-4046-a9a6-f8b47430ccdf/appId/38535360-9f3e-4b1e-a41e-b4af46afcb0c) | High |  | Application.Read.All | Pora | 2026-03-25 | \n| ✅ | [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a15dc834-08ce-4fd8-85de-3729fff8e34f/appId/d36fe320-bc28-40c8-a141-a512d65d112c) | High | User.Read | Application.Read.All | Pora Inc. | 2026-03-25 | \n| ✅ | [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/427b14ca-13b3-4911-b67e-9ff626614781/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) | Unranked |  | ServiceMessage.Read.All | Entra.Chat | 2026-03-25 | \n| ✅ | [ChatGPT](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ede526ec-83dd-4e66-8ed0-98e05dca5454/appId/e0476654-c1d5-430b-ab80-70cbd947616a) | Unranked | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All |  | OpenAI | Unknown | \n| ✅ | [MyVisualStudioMcpClient](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cae606b7-4a44-4d07-a7a5-a6fb285e41f1/appId/84ad8697-445d-4b26-affd-1b1459e97aae) | Unranked | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All |  | Pora Inc. | Unknown | \n| ✅ | [custommcp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fba0c411-7019-4c32-bec4-2f281824b698/appId/aca7e359-22cf-4d86-9338-6d6051245755) | Unranked | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.UserAuthenticationMethod.Read.All |  | Pora Inc. | Unknown | \n| ✅ | [TestMcPClient](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cf30c6da-890f-4e66-b353-06adbae9933f/appId/55c372a3-9a33-42bb-ac50-7f49224fee47) | Unranked | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All |  | Pora Inc. | Unknown | \n| ✅ | [MyTestMcPClient](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/84fbf039-0d23-41d0-b58b-f7a7b76a0486/appId/b6e43d0e-e33f-4223-bae4-144e5974ec3b) | Unranked | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All |  | Pora Inc. | Unknown | \n| ✅ | [M365 MCP Client for Claude](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/73f345ba-56fb-4d92-b2f6-2fe168131092/appId/08ad6f98-a4f8-4635-bb8d-f1a3044760f0) | Unranked | MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All |  | Anthropic | Unknown | \n\n\n",
      "TestSfiPillar": "Protect engineering systems",
      "TestMinimumLicense": [
        "AAD_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Access control",
      "TestId": "21770",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.7",
      "ZtmmFunctionName": "Governance",
      "TestStatus": "Failed"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestDescription": "When Microsoft Entra Private Access applications lack user or group assignments, users can't establish tunnels through the application to reach the configured fully qualified domain names (FQDNs) and IP addresses. This restriction prevents access to protected internal resources. Without assignments, organizations can't enforce Conditional Access policies because these policies require explicit user-to-application relationships to evaluate risk signals, device compliance, and authentication strength requirements.\n\nWithout user assignments on Private Access applications:\n\n- Organizations lose the ability to enforce least privilege access controls where users get access only to the specific resources they need.\n- Organizations can't apply risk-based access policies that block or challenge authentication based on sign-in risk, user risk, or device compliance.\n- Identity protection signals that detect credential compromise, impossible travel, or anonymous IP addresses can't protect private resources.\n\n**Remediation action**\n\n- [Assign users and groups to Private Access applications](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-per-app-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-users-and-groups) to enable Zero Trust access controls and Conditional Access enforcement.\n",
      "TestTitle": "All Private Access apps have user or group assignments",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "NotConnectedToService",
      "TestCategory": "Global Secure Access",
      "TestId": "25481",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.3",
      "ZtmmFunctionName": "Data monitoring and access control",
      "TestStatus": "Skipped"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "When sensitivity label integration is disabled (the default) in SharePoint, files in SharePoint and OneDrive can't be labeled or display existing labels, and can't benefit from the additional protection of sensitivity labels that apply encryption. This protection gap leaves sensitive files unclassified and vulnerable to unauthorized access and external sharing.\n\nEnabling sensitivity labels in SharePoint allows users to apply labels by using Office for the web and SharePoint. It's also a requirement for default labeling for these locations, and for auto-labeling policies that can classify files automatically. Sensitivity labels for these files can also strengthen security for Microsoft 365 Copilot, and be used with data loss prevention policies and other Microsoft Purview solutions.\n\n**Remediation action**\n\n- [Enable sensitivity labels for files in SharePoint and OneDrive](https://learn.microsoft.com/purview/sensitivity-labels-sharepoint-onedrive-files?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Sensitivity labels are enabled for SharePoint and OneDrive",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SharePointOnline\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "SharePoint Online",
      "TestId": "35005",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Investigate"
    },
    {
      "TestId": "21812",
      "TestMinimumLicense": "P1",
      "TestCategory": "Privileged access",
      "TestTitle": "Maximum number of Global Administrators doesn't exceed eight users",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nMaximum number of Global Administrators exceeds eight users/service principals.\n\n\n## Global Administrators\n\n### Total number of Global Administrators: 24\n\n| Display Name | Object Type | User Principal Name |\n| :----------- | :---------- | :------------------ |\n| [Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0145d508-50fd-4f86-a47a-bf1c043c8358) | User | jackief@elapora.com |\n| [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | User | gael@elapora.com |\n| [Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1433571b-3d7c-4a56-a9cc-67580848bc73) | User | ravi.kalwani@elapora.com |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6) | User | chukka.p@elapora.com |\n| [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165) | User | ann@elapora.com |\n| [Ty Grady](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/210d3e96-015f-462d-b6d6-81e6023263df) | User | Tyler.GradyTaylor_microsoft.com#EXT#@pora.onmicrosoft.com |\n| [Ty Grady Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/43482f27-d1af-420f-84ba-e9148a700f45) | User | tygradytest@elapora.com |\n| [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e) | User | merill@elapora.com |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/518ce209-faf4-4717-add9-7129a669fa11) | User | sandeep.p@elapora.com |\n| [Bagul Atayewa](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5655cf54-34bc-4f36-bb74-44da35547975) | User | bagula@elapora.com |\n| [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a) | User | madura@elapora.com |\n| [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003) | User | tyler@elapora.com |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7e92f268-bb12-469a-a869-210d596d4c1f) | User | Komal.p@elapora.com |\n| [Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91) | User | Manoj.Kesana@elapora.com |\n| [Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/a85798bd-652b-4eb9-ba90-3ee882df0179) | User | varsha.mane@elapora.com |\n| [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a) | User | joshua@elapora.com |\n| [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d) | User | aleksandar@elapora.com |\n| [Afif Ahmed](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/c0b65b13-37b1-4081-bcfc-14844159b4a5) | User | AfifAhmed@elapora.com |\n| [elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/e876f7cb-13f3-48a4-8329-66d7b1fa33fb) | Service Principal | N/A |\n| [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854) | User | emergency@elapora.com |\n| [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | Service Principal | N/A |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/df02402a-e291-42cc-b449-79366daa2a40) | User | perennial_ash@elapora.com |\n| [Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b) | User | AdeleV@pora.onmicrosoft.com |\n| [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6) | User | damien.bowden@elapora.com |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Low",
      "TestDescription": "An excessive number of Global Administrator accounts creates an expanded attack surface that threat actors can exploit through various initial access vectors. Each extra privileged account represents a potential entry point for threat actors. An excess of Global Administrator accounts undermines the principle of least privilege. Microsoft recommends that organizations have no more than eight Global Administrators.\n\n**Remediation action**\n\n- [Follow best practices for Microsoft Entra roles](https://learn.microsoft.com/entra/identity/role-based-access-control/best-practices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21801",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Users have strong authentication methods configured",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound users that have not yet registered phishing resistant authentication methods\n\n## Users strong authentication methods\n\nFound users that have not registered phishing resistant authentication methods.\n\nUser | Last sign in | Phishing resistant method registered |\n| :--- | :--- | :---: |\n|[Aahmed Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/6f467d0a-25ec-435c-8fb9-9d53eb21e02f/hidePreviewBanner~/true)| 2026-03-03 | ❌ |\n|[Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Afif](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0d6cfd05-fc46-440b-b605-66dd26dcd7d2/hidePreviewBanner~/true)| 01/28/2026 12:30:09 | ❌ |\n|[Afif Ahmed](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c0b65b13-37b1-4081-bcfc-14844159b4a5/hidePreviewBanner~/true)| 2026-11-03 | ❌ |\n|[Agent User Example 3791943](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/76112b45-5214-4fa5-8054-30bafc588e5e/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Agent User Example 3792567](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7ecf3e6f-2343-455e-8d4f-73d661ac3ae3/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Agent User Example 3792993](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/b5d9a21a-3d15-474b-abd0-21c8d3c65589/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Agent User Example 4181693](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d83e2c6c-7e80-4343-b8ec-7fc49b1b100d/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Agent User Example 4208366](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d0ce1a0b-90a1-4493-92ca-58abbe556065/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Agent User Example 4208785](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e3916bda-a99d-47c6-8a28-4f89540c32b8/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Agent User Example 4209371](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f863e6af-79b3-46e4-82a6-dc47ee626346/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true)| 03/25/2026 16:27:57 | ❌ |\n|[Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Anna Jorayew](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/58d9ed99-93ca-4674-8c5f-ec770f5ba17d/hidePreviewBanner~/true)| Unknown | ❌ |\n|[antivirustest](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1d131633-dd0e-4438-8ceb-df7577d2e0fd/hidePreviewBanner~/true)| Unknown | ❌ |\n|[ash-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c5c8ba63-4620-4e91-ac40-b66bebe07a0d/hidePreviewBanner~/true)| 2026-03-03 | ❌ |\n|[Bagul Atayewa](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5655cf54-34bc-4f36-bb74-44da35547975/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true)| 03/25/2026 08:40:00 | ❌ |\n|[Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true)| 01/20/2024 08:00:27 | ❌ |\n|[Daniel Nguyen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ddfb9311-801e-4a84-9466-a18086768b73/hidePreviewBanner~/true)| Unknown | ❌ |\n|[David Kim](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1b156c3d-79c5-44d2-a88c-23f69216777f/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Emma Johnson](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e498eab5-b6b5-493f-8353-b8c350083791/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Faiza Malkia](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/36bf7e02-3abc-46aa-895f-cf95227377fd/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0b37813c-ae19-4399-982f-16587f17f9c0/hidePreviewBanner~/true)| 03/25/2026 17:05:20 | ❌ |\n|[Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true)| 11/15/2023 18:36:22 | ❌ |\n|[Hamisi Khari](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/494995bf-5510-450c-a317-6d24f63cd15b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Henrietta Mueller](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/eb6a4040-3ff6-4911-a80d-68c701384c38/hidePreviewBanner~/true)| Unknown | ❌ |\n|[HR Agent](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/143c26fd-d308-4cb4-9c80-b54e66d6192c/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Isaiah Langer](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2a054082-8f05-4e05-8fce-4e35c3bb40cc/hidePreviewBanner~/true)| 2023-12-12 | ❌ |\n|[Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0145d508-50fd-4f86-a47a-bf1c043c8358/hidePreviewBanner~/true)| Unknown | ❌ |\n|[James Thompson](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ba635de8-4625-42eb-a59a-87f507ad9a9e/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Jane Doe](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/57c41b80-a96a-4c06-8ab9-9539818a637f/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Jessica Taylor](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/983164a3-87fa-4071-aa67-ff1530092df1/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Johanna Lorenz](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/8994aee7-8c36-4e04-9116-8f21d8acdeb7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John Doe Test 1](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/fcebe3cc-ca26-49c6-9bb1-c9eafb243634/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John Doe Test 1](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/69a2da18-6395-4a90-bde8-72e8aaa6c775/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John1 Doe](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/77d4be98-c05d-4478-be25-3ee710b5247e/hidePreviewBanner~/true)| 2024-04-11 | ❌ |\n|[Joni Sherman](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2da436f2-952a-47de-9dfe-84bd2f0d93e9/hidePreviewBanner~/true)| Unknown | ❌ |\n|[komal-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e0952dcb-8d63-496d-8661-05c86c1a51f0/hidePreviewBanner~/true)| 2026-03-03 | ❌ |\n|[Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true)| 03/17/2026 03:14:18 | ❌ |\n|[Lee Gu](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0a9e313b-8777-4741-ba14-0f2724179117/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Lidia Holloway](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/9188d3d3-386c-4145-a811-0d777a288e11/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Lynne Robbins](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/8e5f7749-d5e7-46fc-8eb7-3b8ab7e20ae5/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true)| 07/30/2025 03:28:21 | ❌ |\n|[Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true)| 03/25/2026 12:44:10 | ❌ |\n|[manoj-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d71ccc09-c0a3-4604-9d02-49f7a3715f49/hidePreviewBanner~/true)| 2026-03-03 | ❌ |\n|[Megan Bowen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/96d29f01-873c-46a3-b542-f7ee192cc675/hidePreviewBanner~/true)| 06/28/2025 12:47:54 | ❌ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a0883b7a-c6a8-440f-84f0-d6e1b79aaf4c/hidePreviewBanner~/true)| 2025-10-08 | ❌ |\n|[Michael Wong](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/63e4e634-15e4-4a85-bc9c-532855574377/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Miriam Graham](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f5745554-1894-4fb0-9560-65d6fc489724/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Nestor Wilke](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/24b9254d-1bc5-435c-ad3d-7dbee86f8b9a/hidePreviewBanner~/true)| Unknown | ❌ |\n|[New User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/6eef8ea0-1263-4973-9b0b-1e7aed0d21cd/hidePreviewBanner~/true)| Unknown | ❌ |\n|[No Location](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/696743fa-055b-42fb-aac4-ab451a4617d6/hidePreviewBanner~/true)| Unknown | ❌ |\n|[NoMail Enabled](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a740d122-ee21-4354-9423-adccf8b6b233/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Olivia Patel](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/03a5c332-4d75-47fd-b211-838e8cd0ee1b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f/hidePreviewBanner~/true)| 06/17/2024 04:12:01 | ❌ |\n|[Patti Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/3bae3a95-7605-4271-8418-e35733991834/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Pradeep Gupta](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ac712f60-0052-4911-8c5d-146cf9d4dc59/hidePreviewBanner~/true)| Unknown | ❌ |\n|[praneeth-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c1bdb03c-0079-40b1-96a8-3595de3b94a2/hidePreviewBanner~/true)| 2026-09-03 | ❌ |\n|[Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1433571b-3d7c-4a56-a9cc-67580848bc73/hidePreviewBanner~/true)| 09/23/2025 23:03:25 | ❌ |\n|[Rhea Stone](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ac49a6e5-09c1-404b-915e-0d28574b3d72/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Richard Wilkings](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c27e2b23-c322-4a79-8c6f-9dba8fd9f4e2/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Roi Fraguela](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e0a814e5-5169-4af2-bb19-63930b42ac41/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Ryan Chen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/9605b9f8-9823-4c33-8018-57ad32d9fcb9/hidePreviewBanner~/true)| Unknown | ❌ |\n|[sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true)| 03/25/2026 16:08:04 | ❌ |\n|[Sandy](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d5e32d0c-3f3c-43ef-abe1-75890a73f40c/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Sarah Mehrotra](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2d79a82a-ae19-461a-a0aa-807045ec3c4e/hidePreviewBanner~/true)| 03/24/2026 22:58:45 | ❌ |\n|[Sarah Mitchell](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0ca3a9f0-7e3c-44c5-9638-250be0d94621/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Shonali Balakrishna](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/305bbf73-eee4-4e0c-9c7d-627e00ed3665/hidePreviewBanner~/true)| 2025-05-05 | ❌ |\n|[Simon Burn](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c3aab1a2-0733-438d-bc14-90dc8f6d876d/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Sophia Rodriguez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d5d9f31f-c8d7-4b6c-bfca-b25b1cd4c1f1/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Tegra Núnez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/25e54254-3719-4c07-a880-3aee6bc60876/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Tracy yu](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/80153e0b-dcce-42de-9df6-59a3fc89479b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Ty Grady](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/210d3e96-015f-462d-b6d6-81e6023263df/hidePreviewBanner~/true)| 02/13/2026 08:56:19 | ❌ |\n|[Ty Grady Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/43482f27-d1af-420f-84ba-e9148a700f45/hidePreviewBanner~/true)| 03/25/2026 16:27:42 | ❌ |\n|[Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true)| 2025-04-02 | ❌ |\n|[Unlicensed User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7804b01c-1223-4045-a393-43171298fa6b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[usernonick](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/b531f68f-8d01-467b-9db6-a57438b0e8af/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a85798bd-652b-4eb9-ba90-3ee882df0179/hidePreviewBanner~/true)| 02/19/2026 11:02:30 | ❌ |\n|[Wilna Rossouw](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/62cd4528-8e5d-4789-84f6-8b33d0af5ca7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Yakup Meredow](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/767bcbda-28a0-4e5f-841d-e918c5a1c229/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Alex Wilber](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f10bc459-0bcf-49d0-8f86-4553b8f015b8/hidePreviewBanner~/true)| 2026-12-03 | ✅ |\n|[Diego Siciliani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/cdfa577c-972f-4399-98aa-1ec4be7fa6d1/hidePreviewBanner~/true)| 06/28/2025 23:31:12 | ✅ |\n|[Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true)| 2025-06-12 | ✅ |\n|[Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true)| 10/30/2025 00:28:28 | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| 03/25/2026 16:44:45 | ✅ |\n|[perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true)| 03/25/2026 13:39:12 | ✅ |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.\n\nAttackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.\n\n**Remediation action**\n\n- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy a Conditional Access policy to require phishing-resistant MFA for all users](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestTags": [
        "Credential"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "21870",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Enable self-service password reset",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Without Self-Service Password Reset (SSPR) enabled, users with password-related issues must contact help desk support, which can cause in operational delays and lost productivity. There are also potential security vulnerabilities during the extended timeframe required for administrative password resets. These delays not only reduce employee efficiency (especially in time-sensitive roles), but also increase support costs and strain IT resources. During these periods, threat actors might exploit locked accounts through social engineering attacks targeting help desk personnel. Threat actors can potentially convince support staff to reset passwords for accounts they don't legitimately control, enabling initial access to user credentials.\n\nWhen users are unable to reset their own passwords through secure, automated processes, they frequently resort to insecure workarounds. Examples include sharing accounts with colleagues, using weak passwords that are easier to remember, or writing down passwords in discoverable locations, all of which expand the attack surface for credential harvesting techniques. The lack of SSPR forces users to maintain static passwords for longer periods between administrative resets. This type of password policy increases the likelihood that compromised credentials from previous breaches or password spray attacks remain valid and usable by threat actors. The absence of user-controlled password reset capabilities also delays the response time for users to secure their accounts when they suspect compromise. This delay allows threat actors extended persistence within compromised accounts to perform reconnaissance, establish other access methods, or exfiltrate sensitive data before the account is eventually reset through administrative channels \n\n**Remediation action**\n\n- [Enable Self-Service Password Reset](https://learn.microsoft.com/entra/identity/authentication/tutorial-enable-sspr?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": null,
      "TestDescription": "Publishing too many labels globally creates confusion and decision paralysis for users, reducing adoption and increasing misclassification. When users face more than 25 labels, they struggle to identify the appropriate classification, leading to incorrect labels or avoiding the feature entirely.\n\nMicrosoft recommends no more than 25 labels in global policies, ideally organized as five main labels with up to five sublabels each. Use scoped policies to publish specialized labels only to specific users, groups, or departments, keeping the global label set focused on common scenarios.\n\n**Remediation action**\n\n- [Sensitivity label limitations per tenant](https://learn.microsoft.com/purview/sensitivity-labels?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#sensitivity-label-limitations-per-tenant)\n- [Create and publish sensitivity labels](https://learn.microsoft.com/microsoft-365/compliance/create-sensitivity-labels?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Globally published sensitivity labels don't exceed the recommended maximum",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "sensitivity-labels",
      "TestId": "35015",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.3",
      "ZtmmFunctionName": "Data monitoring and access control",
      "TestStatus": "Passed"
    },
    {
      "TestId": "24824",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Data",
      "TestTitle": "Conditional Access policies block access from noncompliant devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo conditional access policy with device compliance exists for one or more platforms, and no policy applies to all platforms.\n\n\n## Conditional Access Policies with Device Compliance\n\n| Policy Name | Platforms |\n| :---------- | :-------- |\n| [\\[RaviK\\] - Require app protection policy](https://intune.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies) | android, iOS |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If Microsoft Entra Conditional Access policies don't enforce device compliance, users can connect to corporate resources from devices that don't meet security standards. This exposes sensitive data to risks like malware, unauthorized access, and regulatory noncompliance. Without controls like encryption enforcement, device health checks, and access restrictions, threat actors can exploit noncompliant devices to bypass security measures and maintain persistence.\n\n\nRequiring device compliance in Conditional Access policies ensures only trusted and secure devices can access corporate resources. This supports Zero Trust by enforcing access decisions based on device health and compliance posture.\n\n**Remediation action**\n\nConfigure Conditional Access policies in Microsoft Entra to require device compliance before granting access to corporate resources:  \n- [Create a device compliance-based Conditional Access policy](https://learn.microsoft.com/intune/intune-service/protect/create-conditional-access-intune?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:\n- [What is Conditional Access?](https://learn.microsoft.com/entra/identity/conditional-access/overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Integrate device compliance results with Conditional Access](https://learn.microsoft.com/intune/intune-service/protect/device-compliance-get-started?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#integrate-with-conditional-access)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.3",
      "ZtmmFunctionName": "Resource access"
    },
    {
      "TestId": "26883",
      "TestMinimumLicense": "Azure WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "Default rule set is assigned in Azure Front Door WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Front Door Web Application Firewall (WAF) provides centralized, edge-based protection for globally distributed web applications through managed rulesets that contain pre-configured detection signatures for known attack patterns. The Microsoft Default Ruleset is a continuously updated managed ruleset that protects against the most common and dangerous web vulnerabilities without requiring security expertise to configure. When no managed ruleset is enabled, the WAF policy provides no protection against known attack patterns, effectively operating as a pass-through despite being deployed at the edge. Threat actors routinely scan for unprotected web applications and exploit well-documented vulnerabilities using automated toolkits; without managed rules, attackers can execute SQL injection to extract or modify database contents, perform cross-site scripting to hijack user sessions and steal credentials, exploit local file inclusion to read sensitive configuration files, and leverage command injection to gain shell access on backend servers. These attack techniques have known signatures that managed rulesets detect and block at the edge before malicious traffic reaches origin servers, but an empty or disabled ruleset configuration means the WAF cannot recognize these patterns and will allow malicious requests to pass through to the application.\n\n**Remediation action**\n\nOverview of WAF capabilities on Azure Front Door including managed rulesets\n- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)\n\nDetailed documentation of Default Rule Set groups and rules for Azure Front Door\n- [Web Application Firewall DRS rule groups and rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-drs)\n\nStep-by-step guidance on creating and configuring WAF policies with managed rulesets\n- [Tutorial: Create a Web Application Firewall policy on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-create-portal)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestDescription": "Without Data Loss Prevention (DLP) policies, employees can freely share sensitive information through email, file uploads, or Microsoft Teams communications, increasing the risk of data breaches and regulatory violations.\n\nDLP policies automatically monitor, detect, and prevent the disclosure of sensitive information across Microsoft 365 workloads, providing automated protection against unauthorized data exfiltration.\n\n**Remediation action**\n\n- [Create and configure DLP policies](https://learn.microsoft.com/purview/dlp-create-deploy-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Data loss prevention policies are enabled",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "NotConnectedToService",
      "TestCategory": "Data Loss Prevention (DLP)",
      "TestId": "35030",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Skipped"
    },
    {
      "TestId": "21833",
      "TestMinimumLicense": null,
      "TestCategory": "Privileged access",
      "TestTitle": "Directory Sync account credentials haven't been rotated recently",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "High",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": "25535",
      "TestMinimumLicense": [
        "Azure_Firewall_Basic",
        "Azure_Firewall_Standard",
        "Azure_Firewall_Premium"
      ],
      "TestCategory": "Azure Network Security",
      "TestTitle": "Outbound traffic from VNET integrated workloads is routed through Azure Firewall",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Azure Firewall provides centralized inspection, logging, and enforcement for outbound network traffic. When you don't route outbound traffic from virtual network (VNet) integrated workloads through Azure Firewall, traffic can leave your environment without inspection or policy enforcement. VNet integrated workloads include virtual machines, AKS node pools, App Service with VNet integration, and Azure Functions in VNet.\n\nWithout routing outbound traffic through Azure Firewall:\n\n- Threat actors can use uninspected outbound paths for data exfiltration and command-and-control communication.\n- Organizations lose consistent enforcement of egress security controls such as threat intelligence filtering, intrusion detection and prevention, and TLS inspection.\n- Security teams lack visibility into outbound traffic patterns, which makes it difficult to detect and investigate suspicious network activity.\n\n**Remediation action**\n\n- [Configure Azure Firewall routing](https://learn.microsoft.com/azure/firewall/tutorial-firewall-deploy-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-routing) to direct outbound traffic from workload subnets through the firewall's private IP address.\n- [Manage route tables and routes](https://learn.microsoft.com/azure/virtual-network/manage-route-table?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to create user-defined routes for the default route (0.0.0.0/0) pointing to the Azure Firewall private IP.\n- [Control App Service outbound traffic with Azure Firewall](https://learn.microsoft.com/azure/app-service/network-secure-outbound-traffic-azure-firewall?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) for App Service VNet integration scenarios.\n- [Configure Azure Firewall rules](https://learn.microsoft.com/azure/firewall/rule-processing?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to allow required outbound traffic while blocking malicious destinations.\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": 21964,
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Enable protected actions to secure Conditional Access policy creation and changes",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n\n### Conditional Access Policies by Protected Action\n\n#### Update basic properties for Conditional Access policies - ✅ Pass\n\n**Auth Context:** Require FIDO2 key (ID: c1)\n\n| Display Name | State | Authentication Context | Authentication Strength | Device Filters | SignIn Frequency |\n| :--- | :--- | :--- | :--- | :--- | :--- |\n| [AuthContext: Require FIDO2 ](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/) | Enabled | Require FIDO2 key | ✅ | ❌ | ✅ |\n| [Test-PA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/) | Disabled | Require FIDO2 key,MFA,Strong auth | ✅ | ❌ | ✅ |\n\n#### Create Conditional Access policies - ✅ Pass\n\n**Auth Context:** Require FIDO2 key (ID: c1)\n\n| Display Name | State | Authentication Context | Authentication Strength | Device Filters | SignIn Frequency |\n| :--- | :--- | :--- | :--- | :--- | :--- |\n| [AuthContext: Require FIDO2 ](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/) | Enabled | Require FIDO2 key | ✅ | ❌ | ✅ |\n| [Test-PA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/) | Disabled | Require FIDO2 key,MFA,Strong auth | ✅ | ❌ | ✅ |\n\n#### Delete Conditional Access policies - ✅ Pass\n\n**Auth Context:** Require FIDO2 key (ID: c1)\n\n| Display Name | State | Authentication Context | Authentication Strength | Device Filters | SignIn Frequency |\n| :--- | :--- | :--- | :--- | :--- | :--- |\n| [AuthContext: Require FIDO2 ](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/) | Enabled | Require FIDO2 key | ✅ | ❌ | ✅ |\n| [Test-PA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/) | Disabled | Require FIDO2 key,MFA,Strong auth | ✅ | ❌ | ✅ |\n\n#### Update Conditional Access authentication context of Microsoft 365 role-based access control (RBAC) resource actions - ✅ Pass\n\n**Auth Context:** Require FIDO2 key (ID: c1)\n\n| Display Name | State | Authentication Context | Authentication Strength | Device Filters | SignIn Frequency |\n| :--- | :--- | :--- | :--- | :--- | :--- |\n| [AuthContext: Require FIDO2 ](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/) | Enabled | Require FIDO2 key | ✅ | ❌ | ✅ |\n| [Test-PA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/) | Disabled | Require FIDO2 key,MFA,Strong auth | ✅ | ❌ | ✅ |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Threat actors who gain privileged access to a tenant can manipulate Conditional Access policies, potentially disabling critical security controls and enabling persistent access or lateral movement. This type of attack can result in environment-wide compromise by bypassing authentication and authorization barriers.\n\nProtected actions let administrators secure Conditional Access policy creation and modification with extra security controls, such as stronger authentication methods (passwordless MFA or phishing-resistant MFA), the use of Privileged Access Workstation (PAW) devices, or shorter session timeouts.\n\n**Remediation action**\n\n- [Add, test, or remove protected actions in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/role-based-access-control/protected-actions-add?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Exact data match (EDM) is an advanced sensitive information type that detects organization-specific data by matching exact values against an uploaded reference database. Unlike pattern-based sensitive information types (SITs) that detect common formats, EDM identifies things like customer lists, employee IDs, or proprietary codes unique to your organization. Without EDM, auto-labeling policies and DLP rules can't detect this proprietary data, leaving it at risk of exposure.\n\n**Remediation action**\n\n- [Learn about exact data match based sensitive information types](https://learn.microsoft.com/purview/sit-learn-about-exact-data-match-based-sits?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with exact data match based sensitive information types](https://learn.microsoft.com/purview/sit-get-started-exact-data-match-based-sits-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Exact Data Match is configured for sensitive information detection",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Advanced Classification",
      "TestId": "35034",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data labeling and tagging",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21773",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "Applications don't have certificates with expiration longer than 180 days",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound 6 applications and 7 service principals with certificates longer than 180 days\n\n\n## Applications with long-lived credentials\n\n| Application | Certificate expiry |\n| :--- | :--- |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2125-03-03 |\n\n\n## Service principals with long-lived credentials\n\n| Service principal | App owner tenant | Certificate expiry |\n| :--- | :--- | :--- |\n| [21869testapp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/e69e29be-ba40-445a-9824-a3a45e0ae57a/appId/dd63d132-18fb-4f2e-aec4-82b97f30301f/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-10-27 |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/ba63bb52-182c-4ec6-9cc8-ad2287cf51ed/appId/76249b01-8747-4db4-843f-6478d5b32b14/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-07-30 |\n| [Azure AD SAML Toolkit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/4317fd0a-dcee-45bf-8e94-9a66638b11e0/appId/6f5ed68c-9fad-4d78-bf88-2b16bbe16338/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-10-11 |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-01-07 |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/84dc13ec-5754-4745-90f9-5cc92a5ded28/appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-07-30 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2027-02-15 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-02-26 |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Certificates, if not securely stored, can be extracted and exploited by attackers, leading to unauthorized access. Long-lived certificates are more likely to be exposed over time. Credentials, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the privileges of the application.\n\n**Remediation action**\n\n- [Define certificate based application configuration](https://devblogs.microsoft.com/identity/app-management-policy/)\n- [Define trusted certificate authorities for apps and service principals in the tenant](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Define application management policies](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Enforce secret and certificate standards](https://learn.microsoft.com/entra/identity/enterprise-apps/tutorial-enforce-secret-standards?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create a least-privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "22124",
      "TestMinimumLicense": "P1",
      "TestCategory": "Monitoring",
      "TestTitle": "High priority Microsoft Entra recommendations are addressed",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nFound 6 unaddressed high priority Entra recommendations.\n\n\n## Unaddressed high priority Entra recommendations\n\n| Display Name | Status | Insights |\n| :--- | :--- | :--- |\n| Protect all users with a user risk policy  | active | You have 3 of 88 users that don’t have a user risk policy enabled.  |\n| Protect all users with a sign-in risk policy | active | You have 86 of 88 users that don't have a sign-in risk policy turned on. |\n| Ensure all users can complete multifactor authentication | active | You have 57 of 88 users that aren’t registered with MFA.  |\n| Enable policy to block legacy authentication | active | You have 1 of 88 users that don’t have legacy authentication blocked.  |\n| Require multifactor authentication for administrative roles | active | You have 6 of 26 users with administrative roles that aren’t registered and protected with MFA. |\n| Renew expiring application credentials | active | Your tenant has applications with credentials that will expire soon. |\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Leaving high-priority Microsoft Entra recommendations unaddressed can create a gap in an organization’s security posture, offering threat actors opportunities to exploit known weaknesses. Not acting on these items might result in an increased attack surface area, suboptimal operations, or poor user experience. \n\n**Remediation action**\n\n- [Address all high priority recommendations in the Microsoft Entra admin center](https://learn.microsoft.com/entra/identity/monitoring-health/overview-recommendations?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-does-it-work)\n",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21817",
      "TestMinimumLicense": "P2",
      "TestCategory": "Application management",
      "TestTitle": "Global Administrator role activation triggers an approval workflow",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n✅ **Pass**: Approval required with 2 primary approver(s) configured.\n\n\n## Global Administrator role activation and approval workflow\n\n\n| Approval Required | Primary Approvers | Escalation Approvers |\n| :---------------- | :---------------- | :------------------- |\n| Yes | Aleksandar Nikolic, Merill Fernando |  |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Without approval workflows, threat actors who compromise Global Administrator credentials through phishing, credential stuffing, or other authentication bypass techniques can immediately activate the most privileged role in a tenant without any other verification or oversight. Privileged Identity Management (PIM) allows eligible role activations to become active within seconds, so compromised credentials can allow near-instant privilege escalation. Once activated, threat actors can use the Global Administrator role to use the following attack paths to gain persistent access to the tenant:\n- Create new privileged accounts\n- Modify Conditional Access policies to exclude those new accounts\n- Establish alternate authentication methods such as certificate-based authentication or application registrations with high privileges\n\nThe Global Administrator role provides access to administrative features in Microsoft Entra ID and services that use Microsoft Entra identities, including Microsoft Defender XDR, Microsoft Purview, Exchange Online, and SharePoint Online. Without approval gates, threat actors can rapidly escalate to complete tenant takeover, exfiltrating sensitive data, compromising all user accounts, and establishing long-term backdoors through service principals or federation modifications that persist even after the initial compromise is detected. \n\n**Remediation action**\n\n- [Configure role settings to require approval for Global Administrator activation](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Set up approval workflow for privileged roles](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-approval-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Transport Layer Security (TLS) inspection bypass rules create exceptions where encrypted traffic skips deep packet inspection. Without regular review, bypass rules accumulate as temporary exceptions become permanent, applications are decommissioned while their rules remain, or initial justifications become obsolete. Threat actors target uninspected traffic channels. They know that malware command-and-control communications, data exfiltration, and credential theft over HTTPS evade detection when traffic bypasses TLS inspection. Policies not modified in over 90 days might contain stale bypass rules that create blind spots in your network security posture.\n\n**Remediation action**\n\n- Establish a quarterly review process for TLS inspection bypass rules, document a business justification for each bypass rule, and remove rules that are no longer necessary.\n- [Review and manage TLS inspection policies](https://learn.microsoft.com/graph/api/resources/networkaccess-tlsinspectionpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in the Microsoft Entra admin center under **Global Secure Access** > **Secure** > **TLS inspection**.\n- Review the steps in [Configure Transport Layer Security inspection policies](https://learn.microsoft.com/entra/global-secure-access/how-to-transport-layer-security?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to understand how to modify or remove bypass rules as part of the review process.\n",
      "TestTitle": "TLS inspection bypass rules are regularly reviewed",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "27001",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Passed"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "An Application Administrator role scoped at the tenant level can manage every app registration and enterprise application. If a threat actor compromises an Application Administrator with tenant-wide scope, they can add credentials to any service principal, consent to malicious APIs, modify or create applications that enable data exfiltration, and disable or tamper with Private Access apps. Scoping the role to only required Private Access enterprise apps enforces least privilege and limits the blast radius.\n\nIf you don't scope Application Administrator assignments to specific apps:\n\n- A compromised Application Administrator can manage every app registration and enterprise application in your tenant.\n- Threat actors can add credentials to any service principal, enabling persistence and lateral movement.\n- There's no blast radius containment; a single compromised identity can affect all applications.\n\n**Remediation action**\n\n- [Assign Application Administrator roles scoped to specific app registrations](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-enterprise-app-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) instead of tenant-wide.\n- [Assign Microsoft Entra roles](https://learn.microsoft.com/entra/identity/role-based-access-control/manage-roles-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) with the least privilege necessary to perform required tasks.\n- [Use Privileged Identity Management to manage just-in-time role activation](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- [Manage Microsoft Entra role assignments in the admin center](https://learn.microsoft.com/entra/identity/role-based-access-control/manage-roles-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Application admin rights are constrained to specific Private Access apps",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\") OR (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect identities and secrets",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access",
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Role management",
      "TestId": "25384",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.3",
      "ZtmmFunctionName": "Data monitoring and access control",
      "TestStatus": "Passed"
    },
    {
      "TestRisk": "Low",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Information Rights Management (IRM) integration in SharePoint Online libraries is a legacy feature that has been replaced by Enhanced SharePoint Permissions (ESP). Any library using this legacy capability should be flagged to move to newer capabilities.\n\n**Remediation action**\n\nTo disable legacy IRM in SharePoint Online:\n1. Identify libraries currently using IRM protection (audit existing sites)\n2. Plan migration to modern sensitivity labels with encryption\n3. Connect to SharePoint Online: `Connect-SPOService -Url https://<tenant>-admin.sharepoint.com`\n4. Disable legacy IRM: `Set-SPOTenant -IrmEnabled $false`\n5. Enable modern sensitivity labels: `Set-SPOTenant -EnableAIPIntegration $true`\n6. Configure and publish sensitivity labels with encryption to replace IRM policies\n\n- [Enable sensitivity labels for SharePoint and OneDrive](https://learn.microsoft.com/microsoft-365/compliance/sensitivity-labels-sharepoint-onedrive-files)\n- [SharePoint IRM and sensitivity labels (migration guidance)](https://learn.microsoft.com/microsoft-365/compliance/sensitivity-labels-sharepoint-onedrive-files#sharepoint-information-rights-management-irm-and-sensitivity-labels)\n- [Create and configure sensitivity labels with encryption](https://learn.microsoft.com/microsoft-365/compliance/encryption-sensitivity-labels)\n\n",
      "TestTitle": "Information Rights Management is enabled in SharePoint Online",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SharePointOnline\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestSfiPillar": "",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "SharePoint Online",
      "TestId": "35007",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Failed"
    },
    {
      "TestRisk": "Low",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Labels must be published by using label policies before users can apply them to items, such as files, emails, and meetings. Label policies define which users receive which labels, set default labeling behavior, and other labeling requirements. Without published policies, sensitivity labels remain unavailable to users.\n\n**Remediation action**\n\n- [Create and configure sensitivity labels and their policies](https://learn.microsoft.com/purview/create-sensitivity-labels?tabs=classic-label-scheme&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#publish-sensitivity-labels-by-creating-a-label-policy)\n",
      "TestTitle": "Sensitivity label policies are published to users",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Sensitivity Labels",
      "TestId": "35004",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data labeling and tagging",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21861",
      "TestMinimumLicense": "P2",
      "TestCategory": "Monitoring",
      "TestTitle": "All high-risk users are triaged",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAll high-risk users are properly triaged in Entra ID Protection.\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "Users considered at high risk by Microsoft Entra ID Protection have a high probability of compromise by threat actors. Threat actors can gain initial access via compromised valid accounts, where their suspicious activities continue despite triggering risk indicators. This oversight can enable persistence as threat actors perform activities that normally warrant investigation, such as unusual login patterns or suspicious inbox manipulation. \n\nA lack of triage of these risky users allows for expanded reconnaissance activities and lateral movement, with anomalous behavior patterns continuing to generate uninvestigated alerts. Threat actors become emboldened as security teams show they aren't actively responding to risk indicators.\n\n**Remediation action**\n\n- [Investigate high risk users](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in Microsoft Entra ID Protection\n- [Remediate high risk users and unblock](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-remediate-unblock?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in Microsoft Entra ID Protection\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.3",
      "ZtmmFunctionName": "Risk Assessments"
    },
    {
      "TestId": "27019",
      "TestMinimumLicense": "Azure WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "JavaScript Challenge is Enabled in Azure Front Door WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Azure Front Door Web Application Firewall (WAF) supports JavaScript challenge as a defense mechanism against automated bots and headless browsers across the global edge network. JavaScript challenge works by serving a small JavaScript snippet that must be executed by the client browser to prove that the request originates from a real browser capable of running JavaScript, rather than a simple HTTP client or bot.\n\nWhen a request triggers a JavaScript challenge, the WAF responds with a challenge page containing JavaScript code that the browser must execute to obtain a valid challenge cookie. Bots and automated tools that cannot execute JavaScript fail this challenge and are blocked from accessing protected resources.\n\nThe `javascriptChallengeExpirationInMinutes` setting controls how long the challenge cookie remains valid before the client must complete another challenge. JavaScript challenge provides a middle ground between allowing all traffic and blocking suspected bots outright.\n\nThis check identifies Azure Front Door WAF policies that are attached to an Azure Front Door and verifies that at least one custom rule with JavaScript challenge action is configured and enabled.\n\n**Remediation action**\n\n- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)\n- [Web Application Firewall custom rules for Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-custom-rules)\n- [Configure JavaScript challenge for Azure Front Door WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-tuning#javascript-challenge)\n- [Tutorial: Create a Web Application Firewall policy on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-create-portal)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Without retention policies, emails persist indefinitely in user mailboxes, creating liability for regulatory violations (GDPR, HIPAA, SOX), increased eDiscovery costs, and uncontrolled storage expenses.\n\nRetention policies automatically manage email lifecycle by deleting or preserving messages based on compliance requirements, reducing legal risk, and ensuring regulatory record-keeping obligations are met.\n\n**Remediation action**\n\n- [Create and manage retention policies](https://learn.microsoft.com/purview/create-retention-policies?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Email retention policies are configured",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Information Protection",
      "TestId": "35028",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21848",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Add organizational terms to the banned password list",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nCustom banned passwords are properly configured with organization-specific terms to prevent predictable password patterns.\n\n\n## Password protection settings\n\n| Enforce custom list | Custom banned password list | Number of terms |\n| :------------------ | :-------------------------- | :-------------- |\n| [Yes](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/PasswordProtection/fromNav/) | test | 1 |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Organizations that don't populate and enforce the custom banned password list expose themselves to a systematic attack chain where threat actors exploit predictable organizational password patterns. These threat actors typically start with reconnaissance phases, where they gather open-source intelligence (OSINT) from websites, social media, and public records to identify likely password components. With this knowledge, they launch password spray attacks that test organization-specific password variations across multiple user accounts, staying under lockout thresholds to avoid detection. Without the protection the custom banned password list offers, employees often add familiar organizational terms to their passwords, like locations, product names, and industry terms, creating consistent attack vectors. \n\nThe custom banned password list helps organizations plug this critical gap to prevent easily guessed passwords that could lead to initial access and subsequent lateral movement within the environment.\n\n**Remediation action**\n\n- [Learn how to enable custom banned password protection and add organizational terms](https://learn.microsoft.com/entra/identity/authentication/tutorial-configure-custom-password-protection?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "25405",
      "TestMinimumLicense": "P1",
      "TestCategory": "Global Secure Access",
      "TestTitle": "Intelligent Local Access is enabled and configured",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\n✅ At least one private network is configured in your tenant.\n\n\n## Private Networks\n\nFound 1 private network(s) configured for Intelligent Local Access.\n\n| Network name | Id |\n| :--- | :--- |\n| [Test PN](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/PrivateNetworks.ReactView) | 93060521-eab5-48e0-be22-30ce7aa0fd4f |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Intelligent Local Access (ILA) routes Microsoft Entra Private Access traffic locally instead of through the cloud, improving performance while maintaining policy enforcement. Without ILA, users might disable the Global Secure Access client to improve performance and bypass Conditional Access policies. Configure private networks for your user sites to ensure local routing while preserving security controls.\n\n**Remediation action**\n\n- [Enable Intelligent Local Network](https://learn.microsoft.com/entra/global-secure-access/enable-intelligent-local-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "24573",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Security baselines are applied to Windows devices to strengthen security posture",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo security baselines are configured or assigned to Windows devices in Intune.\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Without properly configured and assigned Intune security baselines for Windows, devices remain vulnerable to a wide array of attack vectors that threat actors exploit to gain persistence and escalate privileges. Adversaries leverage default Windows configurations that lack hardened security settings to perform lateral movement using techniques like credential dumping, privilege escalation via unpatched vulnerabilities, and exploitation of weak authentication mechanisms. In the absence of enforced security baselines, threat actors can bypass critical security controls, maintain persistence through registry modifications, and exfiltrate sensitive data through unmonitored channels. Failing to implement a defense-in-depth strategy makes devices easier to exploit as attackers progress through the attack chain—from initial access to data exfiltration—ultimately compromising the organization’s security posture and increasing the risk of compliance violations.\n\nApplying security baselines ensures Windows devices are configured with hardened settings, reducing attack surface, enforcing defense-in-depth, and supporting Zero Trust by standardizing security controls across the environment.\n\n**Remediation action**\n\nConfigure and assign Intune security baselines to Windows devices to enforce standardized security settings and monitor compliance:\n- [Deploy security baselines to help secure Windows devices](https://learn.microsoft.com/intune/intune-service/protect/security-baselines-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-profile-for-a-security-baseline)\n- [Monitor security baseline compliance](https://learn.microsoft.com/intune/intune-service/protect/security-baselines-monitor?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "21782",
      "TestMinimumLicense": "P1",
      "TestCategory": "Privileged access",
      "TestTitle": "Privileged accounts have phishing-resistant methods registered",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound privileged users that have not yet registered phishing resistant authentication methods\n\n## Privileged users\n\nFound privileged users that have not registered phishing resistant authentication methods.\n\nUser | Role Name | Phishing resistant method registered |\n| :--- | :--- | :---: |\n|[Aahmed Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/6f467d0a-25ec-435c-8fb9-9d53eb21e02f/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[Aahmed Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/6f467d0a-25ec-435c-8fb9-9d53eb21e02f/hidePreviewBanner~/true)| Exchange Administrator | ❌ |\n|[Aahmed Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/6f467d0a-25ec-435c-8fb9-9d53eb21e02f/hidePreviewBanner~/true)| SharePoint Administrator | ❌ |\n|[Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b/hidePreviewBanner~/true)| Billing Administrator | ❌ |\n|[Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b/hidePreviewBanner~/true)| Application Administrator | ❌ |\n|[Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Afif](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0d6cfd05-fc46-440b-b605-66dd26dcd7d2/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[Afif Ahmed](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c0b65b13-37b1-4081-bcfc-14844159b4a5/hidePreviewBanner~/true)| Compliance Administrator | ❌ |\n|[Afif Ahmed](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c0b65b13-37b1-4081-bcfc-14844159b4a5/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Anna Jorayew](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/58d9ed99-93ca-4674-8c5f-ec770f5ba17d/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[ash-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c5c8ba63-4620-4e91-ac40-b66bebe07a0d/hidePreviewBanner~/true)| SharePoint Administrator | ❌ |\n|[ash-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c5c8ba63-4620-4e91-ac40-b66bebe07a0d/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[ash-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c5c8ba63-4620-4e91-ac40-b66bebe07a0d/hidePreviewBanner~/true)| Exchange Administrator | ❌ |\n|[Bagul Atayewa](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5655cf54-34bc-4f36-bb74-44da35547975/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true)| Application Administrator | ❌ |\n|[chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true)| Azure AD Joined Device Local Administrator | ❌ |\n|[chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true)| Compliance Administrator | ❌ |\n|[Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0b37813c-ae19-4399-982f-16587f17f9c0/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true)| User Administrator | ❌ |\n|[Isaiah Langer](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2a054082-8f05-4e05-8fce-4e35c3bb40cc/hidePreviewBanner~/true)| Application Administrator | ❌ |\n|[Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0145d508-50fd-4f86-a47a-bf1c043c8358/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[komal-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e0952dcb-8d63-496d-8661-05c86c1a51f0/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[komal-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e0952dcb-8d63-496d-8661-05c86c1a51f0/hidePreviewBanner~/true)| Exchange Administrator | ❌ |\n|[komal-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e0952dcb-8d63-496d-8661-05c86c1a51f0/hidePreviewBanner~/true)| SharePoint Administrator | ❌ |\n|[Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[manoj-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d71ccc09-c0a3-4604-9d02-49f7a3715f49/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[manoj-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d71ccc09-c0a3-4604-9d02-49f7a3715f49/hidePreviewBanner~/true)| SharePoint Administrator | ❌ |\n|[manoj-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d71ccc09-c0a3-4604-9d02-49f7a3715f49/hidePreviewBanner~/true)| Exchange Administrator | ❌ |\n|[Megan Bowen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/96d29f01-873c-46a3-b542-f7ee192cc675/hidePreviewBanner~/true)| Application Administrator | ❌ |\n|[On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f/hidePreviewBanner~/true)| Directory Synchronization Accounts | ❌ |\n|[praneeth-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c1bdb03c-0079-40b1-96a8-3595de3b94a2/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1433571b-3d7c-4a56-a9cc-67580848bc73/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true)| Global Reader | ❌ |\n|[sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true)| Attribute Log Administrator | ❌ |\n|[sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true)| Global Secure Access Log Reader | ❌ |\n|[Ty Grady](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/210d3e96-015f-462d-b6d6-81e6023263df/hidePreviewBanner~/true)| Compliance Administrator | ❌ |\n|[Ty Grady](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/210d3e96-015f-462d-b6d6-81e6023263df/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Ty Grady Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/43482f27-d1af-420f-84ba-e9148a700f45/hidePreviewBanner~/true)| Compliance Administrator | ❌ |\n|[Ty Grady Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/43482f27-d1af-420f-84ba-e9148a700f45/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Unlicensed User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7804b01c-1223-4045-a393-43171298fa6b/hidePreviewBanner~/true)| Yammer Administrator | ❌ |\n|[Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a85798bd-652b-4eb9-ba90-3ee882df0179/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Alex Wilber](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f10bc459-0bcf-49d0-8f86-4553b8f015b8/hidePreviewBanner~/true)| Billing Administrator | ✅ |\n|[Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Attribute Assignment Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Attribute Definition Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true)| Application Administrator | ✅ |\n|[perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true)| Global Reader | ✅ |\n|[perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true)| Compliance Administrator | ✅ |\n|[perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true)| Azure Information Protection Administrator | ✅ |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy a Conditional Access policy to target privileged accounts and require phishing resistant credentials](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestTags": [
        "Credential"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "21835",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "Emergency access accounts are configured appropriately",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFewer than two emergency access accounts were identified based on cloud-only state, registered phishing-resistant credentials and Conditional Access policy exclusions.\n\n**Summary:**\n- Total permanent Global Administrators: 20\n- Cloud-only GAs with phishing-resistant auth: 4\n- Emergency access accounts (excluded from all CA): 1\n- Enabled Conditional Access policies: 14\n\n## Emergency access accounts\n\n| Display name | UPN | Synced from on-premises | Authentication methods |\n| :----------- | :-- | :---------------------- | :--------------------- |\n| Emergency Access | [emergency@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/ceef37b7-c865-48fb-80c9-4def11201854) | No | password, phone, softwareOath, fido2 |\n\n## All permanent Global Administrators\n\n| Display name | UPN | Cloud only | All CA excluded | Phishing resistant auth |\n| :----------- | :-- | :--------: | :---------: | :---------------------: |\n| Emergency Access | [emergency@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ✅ | ✅ |\n| Merill Fernando | [merill@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ✅ |\n| perennial_ash | [perennial_ash@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ✅ |\n| Joshua Fernando | [joshua@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ✅ |\n| Damien Bowden | [damien.bowden@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Komal.p | [Komal.p@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Varsha Mane | [varsha.mane@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| sandeep.p | [sandeep.p@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Manoj Kesana | [Manoj.Kesana@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Ravi Kalwani | [ravi.kalwani@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Ann Quinzon | [ann@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Ty Grady | [Tyler.GradyTaylor_microsoft.com#EXT#@pora.onmicrosoft.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Ty Grady Test | [tygradytest@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Madura Sonnadara | [madura@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Tyler Chan | [tyler@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Aleksandar Nikolic | [aleksandar@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Afif Ahmed | [AfifAhmed@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| chukka.p | [chukka.p@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Gael Colas | [gael@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ✅ | ❌ | ❌ |\n| Jackie Fernandez | [jackief@elapora.com](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | ❌ | ❌ | ❌ |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "Microsoft recommends that organizations have two cloud-only emergency access accounts permanently assigned the [Global Administrator](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#global-administrator) role. These accounts are highly privileged and aren't assigned to specific individuals. The accounts are limited to emergency or \"break glass\" scenarios where normal accounts can't be used or all other administrators are accidentally locked out.\n\n**Remediation action**\n\n- Create accounts following the [emergency access account recommendations](https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21888",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "App registrations must not have dangling or abandoned domain redirect URIs",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe redirect URIs |\n| :--- | :--- | :--- |\n|  | [21869testapp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/e69e29be-ba40-445a-9824-a3a45e0ae57a/appId/dd63d132-18fb-4f2e-aec4-82b97f30301f/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `4️⃣ https://testapp.local/callback` |  |\n|  | [Contoso Access Verifier](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/41d3b041-9859-4830-8feb-72ffd7afad65/appId/a6af3433-bc44-4d27-9b35-81d10fd51315/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `4️⃣ https://demoeam2025.blob.core.windows.net/data/index.html` |  |\n|  | [My nice app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d41cfc13-11d1-4f93-835a-88e729725564/appId/2946f286-2b59-4f29-876c-0ed8bbe1c482/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `4️⃣ https://mysalmon.azurewebsites.net/login.saml` |  |\n|  | [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `4️⃣ https://MYDOMAIN.my.salesforce.com/ENTITYI` |  |\n|  | [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `4️⃣ https://dev92989.service-now.com/navpage.do` |  |\n|  | [aad-extensions-app. Do not modify. Used by AAD for storing user data.](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/b5277031-31cb-4a88-b5a1-316878166f55/appId/d211b2a1-0c5e-4be8-a40a-46033a0b6df2/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `4️⃣ https://pora.onmicrosoft.com/cpimextensions` |  |\n|  | [saml test app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/daa6074c-db6f-4bdc-a41b-bc0052c536a5/appId/c266d677-a5f8-47bc-9f0a-1b6fbe0bddad/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `4️⃣ https://appclaims.azurewebsites.net/signin-saml`, `4️⃣ https://appclaims.azurewebsites.net/signin-oidc` |  |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Unmaintained or orphaned redirect URIs in app registrations create significant security vulnerabilities when they reference domains that no longer point to active resources. Threat actors can exploit these \"dangling\" DNS entries by provisioning resources at abandoned domains, effectively taking control of redirect endpoints. This vulnerability enables attackers to intercept authentication tokens and credentials during OAuth 2.0 flows, which can lead to unauthorized access, session hijacking, and potential broader organizational compromise.\n\n**Remediation action**\n\n- [Redirect URI (reply URL) outline and restrictions](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "The baseline profile applies the same filtering rules to all users and sessions. Conditional Access integration enables identity-aware filtering that adapts based on user risk, device compliance, location, or group membership. Apply stricter filtering to risky sessions while allowing standard access for verified users on compliant devices, preventing compromised accounts from bypassing security controls.\n\n**Remediation action**\n\n- [Link security profiles to Conditional Access policies](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-web-content-filtering?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-and-link-conditional-access-policy)\n",
      "TestTitle": "Web content filtering integrates with Conditional Access",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25407",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21897",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "All app assignment and group membership is governed",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "High",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21821",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "Guest access is restricted",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": null,
      "TestDescription": "Internal RMS licensing allows users and services in the organization to license protected content for internal distribution and sharing. It's enabled automatically when Azure RMS is activated. If disabled, users can't collaborate on encrypted emails and files internally, and legal holds, eDiscovery, and data recovery operations can't access encrypted content.\n\n**Remediation action**\n\n- [Set up Message Encryption](https://learn.microsoft.com/purview/set-up-new-message-encryption-capabilities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Internal Rights Management licensing is enabled",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"ExchangeOnline\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Rights Management Service (RMS)",
      "TestId": "35025",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data labeling and tagging",
      "TestStatus": "Investigate"
    },
    {
      "TestId": "24839",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Data",
      "TestTitle": "Secure Wi-Fi profiles protect iOS devices from unauthorized network access",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo Enterprise Wi-Fi profile for iOS exists or none are assigned.\n\n\n## iOS WiFi Configuration Profiles\n\n| Policy Name | Wi-Fi Security Type | Status | Assignment |\n| :---------- | :----- | :--------- | :--------- |\n| [Wifi test WPAEnterprise](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesIosMenu/~/configuration) | Enterprise | ❌ Not Assigned | None |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "If Wi-Fi profiles aren't properly configured and assigned, users can connect insecurely or fail to connect to trusted networks, exposing corporate data to interception or unauthorized access. Without centralized management, devices rely on manual configuration, increasing the risk of misconfiguration, weak authentication, and connection to rogue networks.\n\nCentrally managing Wi-Fi profiles for iOS devices in Intune ensures secure and consistent connectivity to enterprise networks. This enforces authentication and encryption standards, simplifies onboarding, and supports Zero Trust by reducing exposure to untrusted networks.\n\n**Remediation action**\n\nUse Intune to configure and assign secure Wi-Fi profiles for iOS/iPadOS devices to enforce authentication and encryption standards:\n\n- [Deploy Wi-Fi profiles to devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/wi-fi-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-profile)\n\nFor more information, see:  \n- [Review the available Wi-Fi settings for iOS and iPadOS devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/wi-fi-settings-ios?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "21813",
      "TestMinimumLicense": "Free",
      "TestCategory": "Privileged access",
      "TestTitle": "High Global Administrator to privileged user ratio",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nMore than 50% of privileged role assignments in the tenant are Global Administrator.\n## Privileged role assignment summary\n\n**Global administrator role count:** 22 (56.41%) - ❌ Failed\n\n**Other privileged role count:** 17 (43.59%)\n\n## User privileged role assignments\n\n| User | Global administrator | Other Privileged Role(s) |\n| :--- | :------------------- | :------ |\n| [Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b/hidePreviewBanner~/true) | Yes | Application Administrator |\n| [Afif Ahmed](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/c0b65b13-37b1-4081-bcfc-14844159b4a5/hidePreviewBanner~/true) | Yes | - |\n| [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true) | Yes | - |\n| [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true) | Yes | - |\n| [Bagul Atayewa](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5655cf54-34bc-4f36-bb74-44da35547975/hidePreviewBanner~/true) | Yes | - |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/hidePreviewBanner~/true) | Yes | Global Reader |\n| [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true) | Yes | - |\n| [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true) | Yes | - |\n| [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0b37813c-ae19-4399-982f-16587f17f9c0/hidePreviewBanner~/true) | Yes | - |\n| [Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0145d508-50fd-4f86-a47a-bf1c043c8358/hidePreviewBanner~/true) | Yes | - |\n| [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true) | Yes | - |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7e92f268-bb12-469a-a869-210d596d4c1f/hidePreviewBanner~/true) | Yes | Global Reader |\n| [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true) | Yes | - |\n| [Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91/hidePreviewBanner~/true) | Yes | Global Reader |\n| [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true) | Yes | - |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/df02402a-e291-42cc-b449-79366daa2a40/hidePreviewBanner~/true) | Yes | Application Administrator, Global Reader |\n| [Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1433571b-3d7c-4a56-a9cc-67580848bc73/hidePreviewBanner~/true) | Yes | - |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/518ce209-faf4-4717-add9-7129a669fa11/hidePreviewBanner~/true) | Yes | Global Reader |\n| [Ty Grady](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/210d3e96-015f-462d-b6d6-81e6023263df/hidePreviewBanner~/true) | Yes | - |\n| [Ty Grady Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/43482f27-d1af-420f-84ba-e9148a700f45/hidePreviewBanner~/true) | Yes | - |\n| [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true) | Yes | - |\n| [Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/a85798bd-652b-4eb9-ba90-3ee882df0179/hidePreviewBanner~/true) | Yes | - |\n| [Aahmed Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/6f467d0a-25ec-435c-8fb9-9d53eb21e02f/hidePreviewBanner~/true) | No | Global Reader |\n| [Afif](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0d6cfd05-fc46-440b-b605-66dd26dcd7d2/hidePreviewBanner~/true) | No | Global Reader |\n| [Anna Jorayew](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/58d9ed99-93ca-4674-8c5f-ec770f5ba17d/hidePreviewBanner~/true) | No | Global Reader |\n| [ash-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/c5c8ba63-4620-4e91-ac40-b66bebe07a0d/hidePreviewBanner~/true) | No | Global Reader |\n| [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true) | No | Application Administrator |\n| [Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true) | No | User Administrator |\n| [Isaiah Langer](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2a054082-8f05-4e05-8fce-4e35c3bb40cc/hidePreviewBanner~/true) | No | Application Administrator |\n| [komal-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/e0952dcb-8d63-496d-8661-05c86c1a51f0/hidePreviewBanner~/true) | No | Global Reader |\n| [manoj-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/d71ccc09-c0a3-4604-9d02-49f7a3715f49/hidePreviewBanner~/true) | No | Global Reader |\n| [Megan Bowen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/96d29f01-873c-46a3-b542-f7ee192cc675/hidePreviewBanner~/true) | No | Application Administrator |\n| [praneeth-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/c1bdb03c-0079-40b1-96a8-3595de3b94a2/hidePreviewBanner~/true) | No | Global Reader |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "When organizations maintain a disproportionately high ratio of Global Administrators relative to their total privileged user population, they expose themselves to significant security risks that threat actors might exploit through various attack vectors. Excessive Global Administrator assignments create multiple high-value targets for threat actors who might leverage initial access through credential compromise, phishing attacks, or insider threats to gain unrestricted access to the entire Microsoft Entra ID tenant and connected Microsoft 365 services. \n\n**Remediation action**\n\n- [Minimize the number of Global Administrator role assignments](https://learn.microsoft.com/entra/identity/role-based-access-control/best-practices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#5-limit-the-number-of-global-administrators-to-less-than-5)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "21788",
      "TestMinimumLicense": "Free",
      "TestCategory": "Privileged access",
      "TestTitle": "Global Administrators don't have standing access to Azure subscriptions",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nStanding access to Root Management group was found.\n\n\n## Entra ID objects with standing access to Root Management group\n\n\n| Entra ID Object | Object ID | Principal type |\n| :-------------- | :-------- | :------------- |\n| merill@elapora.com | 513f3db2-044c-41be-af14-431bf88a2b3e | User |\n| madura@elapora.com | 5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a | User |\n| Komal.p@elapora.com | 7e92f268-bb12-469a-a869-210d596d4c1f | User |\n| Manoj.Kesana@elapora.com | 990fd38a-c516-4e3f-82e4-d458a1ab0f91 | User |\n| chukka.p@elapora.com | 1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6 | User |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Global Administrators with persistent access to Azure subscriptions expand the attack surface for threat actors. If a Global Administrator account is compromised, attackers can immediately enumerate resources, modify configurations, assign roles, and exfiltrate sensitive data across all subscriptions. Requiring just-in-time elevation for subscription access introduces detectable signals, slows attacker velocity, and routes high-impact operations through observable control points.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths.md)\n\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity.md)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "27002",
      "TestMinimumLicense": "Entra_Premium_Internet_Access",
      "TestCategory": "Global Secure Access",
      "TestTitle": "TLS inspection certificates have sufficient validity period to prevent service disruption",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test is not applicable to the current environment.\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "TLS inspection in Global Secure Access relies on an intermediate certificate authority certificate to dynamically generate leaf certificates for decrypting and inspecting encrypted traffic. When this certificate expires, the service can no longer perform TLS termination, which immediately disables all TLS inspection capabilities including URL filtering, threat detection, and data loss prevention on HTTPS traffic. Threat actors are aware that security controls often lapse during certificate expiration windows and may time attacks accordingly, knowing that encrypted malware delivery, command-and-control communications, and data exfiltration will bypass inspection. Organizations that do not proactively monitor certificate expiration risk sudden loss of visibility into encrypted traffic, potentially during a critical security incident. Microsoft documentation recommends that signed certificates remain valid for at least 6 months. Maintaining a 90-day buffer before expiration provides adequate time to complete the certificate renewal process.\n\n**Remediation action**\n\n1. Generate a new Certificate Signing Request (CSR) and upload a renewed certificate in the Microsoft Entra admin center under Global Secure Access > Secure > TLS inspection policies > TLS inspection settings tab\n2. Sign the CSR using your organization's PKI infrastructure with a validity period of at least 6 months (Microsoft recommendation)\n3. Use Active Directory Certificate Services (AD CS) or OpenSSL to sign the CSR\n\n",
      "TestTags": null,
      "TestImpact": "High",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption"
    },
    {
      "TestId": "24794",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Terms and Conditions policies protect access to sensitive data",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo Terms and Conditions policy exists or none are assigned.\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "If Terms and Conditions policies aren't configured and assigned in Intune, users can access corporate resources without agreeing to required legal, security, or usage terms. This omission exposes the organization to compliance risks, legal liabilities, and potential misuse of resources.\n\nEnforcing Terms and Conditions ensures users acknowledge and accept company policies before accessing sensitive data or systems, supporting regulatory compliance and responsible resource use.\n\n**Remediation action**\n\nCreate and assign Terms and Conditions policies in Intune to require user acceptance before granting access to corporate resources:  \n- [Create terms and conditions policy](https://learn.microsoft.com/intune/intune-service/enrollment/terms-and-conditions-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "24568",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Platform SSO is configured to strengthen authentication on macOS devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nmacOS SSO policies are configured and assigned in Intune.\n\n\n## macOS SSO Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [Platform SSO](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ✅ Assigned | **Included:** All Users |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "If Platform SSO policies aren't enforced on macOS devices, endpoints might rely on insecure or inconsistent authentication mechanisms, allowing attackers to bypass Conditional Access and compliance policies. This opens the door to lateral movement across cloud services and on-premises resources, especially when federated identities are used. Threat actors can persist by leveraging stolen tokens or cached credentials and exfiltrate sensitive data through unmanaged apps or browser sessions. The absence of SSO enforcement also undermines app protection policies and device posture assessments, making it difficult to detect and contain breaches. Ultimately, failure to configure and assign macOS Platform SSO policies compromises identity security and weakens the organization's Zero Trust posture.\n\nEnforcing Platform SSO policies on macOS devices ensures consistent, secure authentication across apps and services. This strengthens identity protection, supports Conditional Access enforcement, and aligns with Zero Trust by reducing reliance on local credentials and improving posture assessments.\n\n**Remediation action**\n\nUse Intune to configure and assign Platform SSO policies for macOS devices to enforce secure authentication and strengthen identity protection, see:\n\n- [Configure Platform SSO for macOS in Intune](https://learn.microsoft.com/intune/intune-service/configuration/platform-sso-macos?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) – *Step-by-step guidance for enabling Platform SSO on macOS devices.*\n- [Single sign-on (SSO) overview and options for Apple devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/use-enterprise-sso-plug-in-ios-ipados-macos?pivots=macos&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) – *Overview of SSO options available for Apple platforms.*\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "2.3",
      "ZtmmFunctionName": "Resource access"
    },
    {
      "TestId": "21846",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Restrict Temporary Access Pass to Single Use",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nTemporary Access Pass is configured for one-time use only.\n\n\n## Temporary Access Pass Configuration\n\n| Setting | Value | Status |\n| :------ | :---- | :----- |\n| [One-time use restriction](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AdminAuthMethods/fromNav/) | Enabled | ✅ Pass |\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "When Temporary Access Pass (TAP) is configured to allow multiple uses, threat actors who compromise the credential can reuse it repeatedly during its validity period, extending their unauthorized access window beyond the intended single bootstrapping event. This situation creates an extended opportunity for threat actors to establish persistence by registering additional strong authentication methods under the compromised account during the credential lifetime. A reusable TAP that falls into the wrong hands lets threat actors conduct reconnaissance activities across multiple sessions, gradually mapping the environment and identifying high-value targets while maintaining legitimate-looking access patterns. The compromised TAP can also serve as a reliable backdoor mechanism, allowing threat actors to maintain access even if other compromised credentials are detected and revoked, since the TAP appears as a legitimate administrative tool in security logs.\n\n**Remediation action**\n\n- [Configure Temporary Access Pass for one-time use in authentication methods policy](https://learn.microsoft.com/entra/identity/authentication/howto-authentication-temporary-access-pass?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-the-temporary-access-pass-policy)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "24548",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Data",
      "TestTitle": "Data on iOS/iPadOS is protected by app protection policies",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAt least one App protection policy for iOS exists and is assigned.\n\n\n## OS App Protection policies configured for iOS\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [iOS Policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/protection) | ✅ Assigned | **Included:** WFgroup, **Excluded:** graph test |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Without app protection policies, corporate data accessed on iOS/iPadOS devices is vulnerable to leakage through unmanaged or personal apps. Users can unintentionally copy sensitive information into unsecured apps, store data outside corporate boundaries, or bypass authentication controls. This risk is especially high on BYOD devices, where personal and work contexts coexist, increasing the likelihood of data exfiltration or unauthorized access.\n\nApp protection policies ensure corporate data remains secure within approved apps, even on personal devices. These policies enforce encryption, restrict data sharing, and require authentication, reducing the risk of data leakage and aligning with Zero Trust principles of data protection and Conditional Access.\n \n**Remediation action**\n\nDeploy Intune app protection policies that encrypt corporate data, restrict sharing, and require authentication in approved iOS/iPadOS apps:  \n- [Deploy Intune app protection policies](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policies?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-an-iosipados-or-android-app-protection-policy)\n- [Review the iOS app protection settings reference](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policy-settings-ios?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:  \n- [Learn about using app protection policies](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "High",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "24518",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "Enterprise applications have owners",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNot all enterprise applications have at least two owners.\n\n## Enterprise Application Ownership\n\n| App name | Multi-tenant | Permission  | Classification | Owner count |\n| :-------- | :------------ | :---------- | :------------- | :----------- |\n| [Microsoft Assessment React](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/0a8b4459-b0c2-4cb8-baeb-c4c5a6a8f14b) | False | offline_access, openid, profile, User.Read | Low | 0 |\n| [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/043dd83b-94ce-4d12-b54b-45d77979f05a) | False | offline_access, openid, profile, User.Read | Low | 0 |\n| [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/30aa6cd2-1aab-42fd-a235-0521713f4532) | False | offline_access, openid, profile, User.Read | Low | 0 |\n| [Canva](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/37ae3acb-5850-49e8-a0f8-cb06f5a77417) | False | email, openid, profile, User.Read | Low | 0 |\n| [EAM Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/24b12ae7-4648-4aae-b00c-6349a565d24c) | False | openid, profile | Low | 0 |\n| [Azure Static Web Apps](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/6b1f4a00-db4e-43ae-b62b-2286d4fcc4ea) | False | email, openid, profile | Low | 0 |\n| [FIDO2-passkeys-MFA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/1aa7e155-cbf8-4970-8458-05a0c7a2d1a5) | False | openid, profile | Low | 0 |\n| [Opticom](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/3f142d86-14ba-4173-9458-be7fb36b37f7) | False | email, openid, profile, User.Read | Low | 0 |\n| [AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/77198970-f1eb-4574-9a1a-6af175a283af) | True | offline_access, openid, profile, User.Read | Low | 0 |\n| [graph-developer-proxy-samples](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/e6570bb8-fdea-4329-82e2-2809d8fb67a7) | True | Presence.Read.All, User.Read.All | Low | 0 |\n| [idpowerelectron](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/cb64f850-a076-42d5-8dd8-cfd67d9e67f1) | True | offline_access, openid, profile | Low | 0 |\n| [Atlassian - Jira](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/2425e515-5720-4071-9fae-fd50f153c0aa) | False | User.Read | Low | 0 |\n| [Entry Kiosk](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/83adcc80-3a35-4fdc-9c5b-1f6b9061508e) | False | User.Read | Low | 0 |\n| [SharePoint On-Prem App Proxy](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/53c7bdb1-cae2-43b0-9e2e-d8605395ceec) | False | User.Read | Low | 0 |\n| [WebApplication4](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/5bc56e47-7a8a-4e71-b25f-8c4e373f40a6) | False | User.Read | Low | 0 |\n| [MyTokenTestApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/60923f18-748f-42bb-a0b2-ee60d44e17fc) | False | openid, profile | Low | 0 |\n| [Microsoft Graph PowerShell - Used by Team Incredibles](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/e67821d9-a20b-43ef-9c34-76a321643b4f) | False | offline_access, openid, profile, User.Read | Low | 0 |\n| [CachingSampleApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/59187561-8df5-4792-b3a4-f6ca8b54bfc7) | False | offline_access, openid, profile, User.Read | Low | 0 |\n| [Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/552daa69-8057-4684-8c93-2c41963aff01) | False | openid, profile | Low | 0 |\n| [Lokka-2-interactive](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/794b2542-39aa-433c-90c6-6ab5df851ffc) | False | User.Read, User.Read.All | Low | 0 |\n| [Contoso Access Verifier](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/41d3b041-9859-4830-8feb-72ffd7afad65) | False | openid, profile, User.Read | Low | 0 |\n| [ASPNET-Tutorial](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/6e2f1852-1b3c-4516-a078-551846b5cf49) | False | User.Read | Low | 0 |\n| [PowerShell Gallery ](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/a07b4145-250d-4a58-98eb-ab57e7e77d53) | False | email, openid, profile | Low | 0 |\n| [Merill Nov 13 Test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/e515f788-f41c-4c34-aeaa-fded2cc006ed) | False | AgentIdUser.ReadWrite.IdentityParentedBy, User.Read | Low | 0 |\n| [Merill-Test-Nov13](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/4499f84e-928d-44c7-a288-51fc4c4374e0) | False | AgentIdUser.ReadWrite.IdentityParentedBy, User.Read | Low | 0 |\n| [Agent Identity Blueprint Example 3792929](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/a746a0f2-205f-49fb-ab32-b17b7ccf8cb8) | False | AgentIdUser.ReadWrite.IdentityParentedBy, User.Read | Low | 0 |\n| [MyVscode](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/dfc83a5d-36e5-4506-ae9d-6ad5bb403377) | False | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All | Unranked | 0 |\n| [MerillTestNov24](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/8eb7566e-6766-407d-b02e-562bce27c389) | False | AgentIdUser.ReadWrite.IdentityParentedBy, User.Read | Low | 0 |\n| [Merill Test Agent](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/4a371380-42bf-44df-9aab-0485be48bbef) | False | AgentIdUser.ReadWrite.IdentityParentedBy, User.Read | Low | 0 |\n| [Agent Identity Blueprint Example 4208710](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/7c8d289b-aa63-497f-a4bf-6f98d2323e7c) | False | AgentIdUser.ReadWrite.IdentityParentedBy, User.Read | Low | 0 |\n| [Chopin Agent](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/09ac3973-23bc-4ea8-abbb-ce4ed641f39e) | False | AgentIdUser.ReadWrite.IdentityParentedBy, User.Read | Low | 0 |\n| [AADInternals OSINT](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/8aa2d89a-65ce-4b30-87a6-7c0aae6a55da) | False | openid, profile | Low | 0 |\n| [Agent0 API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/8b627fed-f28e-4749-b5ca-05fa9be291a0) | False | User.Read | Low | 0 |\n| [agent0-blueprint](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/6d92662d-d10d-4a03-8c77-4f904ce22c44) | False | AgentIdentity.CreateAsManager, User.Read | Low | 0 |\n| [Agent Identity Blueprint Example 12612901](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/fe22156d-6b3b-45e4-867a-646e08707dcf) | False | AgentIdentity.CreateAsManager, User.Read | Low | 0 |\n| [Message Center](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/158f6ef9-a65d-45f2-bdf0-b0a1db70ebd4) | False | ServiceMessage.Read.All, User.Read | Low | 0 |\n| [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/427b14ca-13b3-4911-b67e-9ff626614781) | False | ServiceMessage.Read.All | Unranked | 0 |\n| [ChatGPT](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/ede526ec-83dd-4e66-8ed0-98e05dca5454) | False | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All | Unranked | 0 |\n| [Calendar Pro](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/36e156e4-4566-44a0-b05c-a112017086b5) | False | email, offline_access, openid, profile, User.Read, User.ReadBasic.All | Low | 0 |\n| [MyVisualStudioMcpClient](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/cae606b7-4a44-4d07-a7a5-a6fb285e41f1) | False | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All | Unranked | 0 |\n| [custommcp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/fba0c411-7019-4c32-bec4-2f281824b698) | False | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.UserAuthenticationMethod.Read.All | Unranked | 0 |\n| [TestMcPClient](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/cf30c6da-890f-4e66-b353-06adbae9933f) | False | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All | Unranked | 0 |\n| [WPNinja1](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/8b75d9d0-1b26-4143-98d0-e87df8b835b1) | False | AgentIdentity.CreateAsManager, User.Read | Low | 0 |\n| [MyTestMcPClient](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/84fbf039-0d23-41d0-b58b-f7a7b76a0486) | False | MCP.AccessReview.Read.All, MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All | Unranked | 0 |\n| [M365 MCP Client for Claude](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/73f345ba-56fb-4d92-b2f6-2fe168131092) | False | MCP.AdministrativeUnit.Read.All, MCP.Application.Read.All, MCP.AuditLog.Read.All, MCP.AuthenticationContext.Read.All, MCP.Device.Read.All, MCP.DirectoryRecommendations.Read.All, MCP.Domain.Read.All, MCP.EntitlementManagement.Read.All, MCP.GroupMember.Read.All, MCP.HealthMonitoringAlert.Read.All, MCP.IdentityRiskEvent.Read.All, MCP.IdentityRiskyServicePrincipal.Read.All, MCP.IdentityRiskyUser.Read.All, MCP.LicenseAssignment.Read.All, MCP.LifecycleWorkflows-CustomExt.Read.All, MCP.LifecycleWorkflows-Reports.Read.All, MCP.LifecycleWorkflows-Workflow.Read.All, MCP.LifecycleWorkflows-Workflow.ReadBasic.All, MCP.LifecycleWorkflows.Read.All, MCP.NetworkAccess-Reports.Read.All, MCP.NetworkAccess.Read.All, MCP.Organization.Read.All, MCP.Policy.Read.All, MCP.Policy.Read.ConditionalAccess, MCP.ProvisioningLog.Read.All, MCP.Reports.Read.All, MCP.RoleAssignmentSchedule.Read.Directory, MCP.RoleEligibilitySchedule.Read.Directory, MCP.RoleManagement.Read.Directory, MCP.Synchronization.Read.All, MCP.User.Read.All, MCP.UserAuthenticationMethod.Read.All | Unranked | 0 |\n\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Enterprise applications without owners become orphaned assets that threat actors can exploit. These applications often retain elevated permissions and access to sensitive resources while lacking proper oversight and security governance.\n\nApplications without owners create blind spots in security monitoring where attackers can establish persistence by leveraging existing application permissions to access data or create backdoor accounts. The absence of ownership also prevents proper access reviews and permission audits, allowing applications with excessive permissions or outdated configurations to remain unmanaged.\n\nAssigning owners enables effective application lifecycle management and ensures proper security oversight.   \n\n**Remediation action**\n\n- [Assign enterprise application owners](https://learn.microsoft.com/entra/identity/enterprise-apps/assign-app-owners?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21992",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "Application certificates must be rotated on a regular basis",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound 4 applications and 13 service principals in your tenant with certificates that have not been rotated within 180 days.\n\n\n## Applications with certificates that have not been rotated within 180 days\n\n| Application | Certificate Start Date |\n| :--- | :--- |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2025-03-03 |\n| [InfinityDemo - Sample](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/20f152d5-856c-449d-aa07-81f5e510dfa7) | 2021-05-03 |\n| [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | 2021-02-28 |\n| [test public client](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/79a0c604-f215-4c52-8fbe-641d08aa7937) | 2021-10-22 |\n\n\n## Service principals with certificates that have not been rotated within 180 days\n\n| Service principal | App owner tenant | Certificate Start Date |\n| :--- | :--- | :--- |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/ba63bb52-182c-4ec6-9cc8-ad2287cf51ed/appId/76249b01-8747-4db4-843f-6478d5b32b14/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-07-30 |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-10-26 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2021-02-17 |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-01-07 |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/84dc13ec-5754-4745-90f9-5cc92a5ded28/appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-07-30 |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/05c98ca9-d208-4d3e-ad24-911bfc3d028c/appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2023-06-11 |\n| [SPO Version](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/4c780b09-998f-4b35-b41f-b125dc9f729a/appId/2d6d9bf1-1f6e-48cf-bb02-31beec2f442e/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2023-11-17 |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-10-02 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-11-17 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2021-02-15 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-02-15 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-02-26 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-10-10 |\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "If certificates aren't rotated regularly, they can give threat actors an extended window to extract and exploit them, leading to unauthorized access. When credentials like these are exposed, attackers can blend their malicious activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the application's privileges.\n\nQuery all of your service principals and application registrations that have certificate credentials. Make sure the certificate start date is less than 180 days.\n\n**Remediation action**\n\n- [Define an application management policy to manage certificate lifetimes](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Define a trusted certificate chain of trust](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create a least privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) \n- [Learn more about app management policies to manage certificate based credentials](https://devblogs.microsoft.com/identity/app-management-policy/)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "26881",
      "TestMinimumLicense": "Azure WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "Default Ruleset is enabled in Application Gateway WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Application Gateway Web Application Firewall (WAF) provides centralized protection for web applications through managed rulesets that contain pre-configured detection signatures for known attack patterns.\n\nThe Microsoft Default Ruleset and OWASP Core Rule Set are continuously updated managed rulesets that protect against the most common and dangerous web vulnerabilities without requiring security expertise to configure.\n\nWhen no managed ruleset is enabled, the WAF policy provides no protection against known attack patterns, effectively operating as a pass-through despite being deployed.\n\nThreat actors routinely scan for unprotected web applications and exploit well-documented vulnerabilities using automated toolkits; without managed rules, attackers can execute SQL injection to extract or modify database contents, perform cross-site scripting to hijack user sessions and steal credentials, exploit local file inclusion to read sensitive configuration files, and leverage command injection to gain shell access on backend servers.\n\nThese attack techniques have known signatures that managed rulesets detect and block, but an empty or disabled ruleset configuration means the WAF cannot recognize these patterns and will allow malicious requests to reach backend applications unimpeded.\n\n\n**Remediation action**\n\n- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview) - Overview of WAF capabilities on Application Gateway including managed rulesets\n- [Web Application Firewall CRS rule groups and rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules) - Detailed documentation of available rulesets and rule groups\n- [Create Web Application Firewall policies for Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-waf-policy-ag) - Step-by-step guidance on creating and configuring WAF policies with managed rulesets\n\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21867",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "Enterprise applications with high privilege Microsoft Graph API permissions have owners",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNot all enterprise applications with high privilege permissions have owners\n\n## Applications lacking sufficient owners\n\n| App name | Multi-tenant | Permission  | Classification | Owner count |\n| :-------- | :------------ | :---------- | :------------- | :----------- |\n| [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/b66231c2-9568-46f1-b61e-c5f8fd9edee4) | False | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, offline_access, openid, Policy.Read.All, profile, User.Read | High | 0 |\n| [idPowerToys - Release](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/4654e05d-9f59-4925-807c-8eb2306e1cb1) | False | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, offline_access, openid, Policy.Read.All, profile, User.Read | High | 0 |\n| [Azure AD Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/6c74be7f-bcc9-4541-bfe1-f113b90b0497) | False | Application.Read.All, AuditLog.Read.All, Directory.Read.All, Group.Read.All, offline_access, openid, Organization.Read.All, Policy.Read.All, profile, Reports.Read.All, RoleManagement.Read.Directory, SecurityEvents.Read.All, User.Read.All, UserAuthenticationMethod.Read.All | High | 0 |\n| [idPowerToys for Desktop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/24cc58d8-2844-4974-b7cd-21c8a470e6bb) | False | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, offline_access, openid, Policy.Read.All, profile | High | 0 |\n| [entraChatAppMultiTenant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/855a57ff-88a6-4ad0-85d7-4f46d742730e) | False | APIConnectors.Read.All, Application.ReadWrite.All, AuditLog.Read.All, Directory.ReadWrite.All, EventListener.ReadWrite.All, Group.Read.All, IdentityUserFlow.Read.All, offline_access, openid, Policy.Read.All, Policy.ReadWrite.AuthenticationFlows, Policy.ReadWrite.AuthenticationMethod, Policy.ReadWrite.ConditionalAccess, Policy.ReadWrite.TrustFramework, profile, TrustFrameworkKeySet.Read.All, User.Read | High | 0 |\n| [Intune Documentation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/97b66fb0-f682-41e0-9aef-47f170c2abae) | False | DeviceManagementApps.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, Group.Read.All, offline_access, openid, profile, User.Read | High | 0 |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/f79df990-9ad2-4142-b5fd-8945ff334da3) | False | Directory.ReadWrite.All, User.Read | High | 0 |\n| [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/6bf7c616-88e8-4f7c-bdad-452e561fa777) | False | User.ReadWrite.All | High | 0 |\n| [test public client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/5e80ea33-31fa-49fd-9a94-61894bd1a6c9) | False | User.Read.All | High | 0 |\n| [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/bac0ba57-1876-448e-96bf-6f0481c99fda) | False | Directory.Read.All, User.Read | High | 0 |\n| [Lokka](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/1abc3899-a5df-40ab-8aa7-95d31edd4c01) | False | DeviceManagementConfiguration.ReadWrite.All, Directory.ReadWrite.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Mail.Read, Mail.Send, Policy.Read.All, Policy.ReadWrite.Authorization, Policy.ReadWrite.ConditionalAccess, PrivilegedAccess.Read.AzureAD, PrivilegedAccess.Read.AzureADGroup, Reports.Read.All, User.Read.All, UserAuthenticationMethod.Read.All | High | 0 |\n| [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/e31cd01e-afaf-4cc3-8d15-d3f9f7eb61e8) | False | DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Mail.Send, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, SecurityIdentitiesHealth.Read.All, SecurityIdentitiesSensors.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | High | 0 |\n| [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/e9fca357-cccd-4ec4-840f-7482f6f02818) | False | User.Read.All | High | 0 |\n| [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/6d2e8d37-82b8-41e7-aa95-443a7401e8b8) | False | Sites.FullControl.All, TermStore.Read.All, User.Read, User.Read.All, User.ReadWrite.All | High | 0 |\n| [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/aa64efdb-2d05-4c81-a9e5-80294bf0afac) | False | Directory.ReadWrite.All, Mail.ReadWrite, Policy.Read.All, User.Read | High | 0 |\n| [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/666a58ef-c3e5-4efc-828a-2ab3c0120677) | False | Sites.Read.All, User.Read | High | 0 |\n| [Trello](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/3d6c91cf-d48f-4272-ac4c-9f989bbec779) | False | Application.Read.All | High | 0 |\n| [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/89bd9c7a-0c81-4a0a-9153-ff7cd0b81352) | False | GroupMember.Read.All, User.Read.All | High | 0 |\n| [My Doc Gen](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/a445d652-f72d-4a88-9493-79d3c3c23d1b) | False | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, offline_access, openid, Policy.Read.All, profile, User.Read | High | 0 |\n| [MyZt](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/716038b1-2811-40fc-8622-93e093890af0) | False | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, DeviceManagementApps.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, Directory.Read.All, offline_access, openid, Policy.Read.All, PrivilegedEligibilitySchedule.Read.AzureADGroup, profile, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, User.Read | High | 0 |\n| [MyZtA\\[\\[](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/d2a2a09d-7562-45fc-a950-36fedfb790f8) | False | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, DeviceManagementApps.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, Directory.Read.All, Policy.Read.All, PrivilegedEligibilitySchedule.Read.AzureADGroup, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, User.Read | High | 0 |\n| [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/d54232da-de3b-4874-aef2-5203dbd7342a) | False | Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Mail.Send, Policy.Read.All, PrivilegedAccess.Read.AzureAD, Reports.Read.All, User.Read | High | 0 |\n| [Graph PS - Zero Trust Workshop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/f6e8dfdd-4c84-441f-ae6e-f2f51fd20699) | False | AuditLog.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, offline_access, openid, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, profile, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, UserAuthenticationMethod.Read.All | High | 0 |\n| [Maester DevOps Account - GitHub](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/ce3af345-b0e0-4b15-808c-937d825bcf03) | False | DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Mail.Send, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All | High | 0 |\n| [Maester DevOps Account - New GitHub Action](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/7c1885fd-fdf8-413a-86a6-f8867914272f) | False | DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, SharePointTenantSettings.Read.All, User.Read, UserAuthenticationMethod.Read.All | High | 0 |\n| [Maester Automation App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/e3972142-1d36-4e7d-a777-ecd64619fcab) | False | DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Mail.Send, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, SharePointTenantSettings.Read.All, User.Read, UserAuthenticationMethod.Read.All | High | 0 |\n| [elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/c5632968-35cd-445d-926e-16e0afc9160e) | False | Directory.ReadWrite.All, Policy.ReadWrite.Authorization, Policy.ReadWrite.DeviceConfiguration | High | 0 |\n| [elapora-Maester-54d3ea01-5a07-45d0-8d69-e5f5b0b20098](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/4faa0456-5ecb-49f3-bb9a-2dbe516e939a) | False | Directory.Read.All, DirectoryRecommendations.Read.All, Mail.Send, Policy.Read.All, Reports.Read.All | High | 0 |\n| [elapora-maester-demo-39ecb2b6-d900-496e-886f-d112cca4f1a9](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/cc578aea-b1bd-434d-86d2-8a22c5728ded) | False | DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, ReportSettings.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, SecurityIdentitiesHealth.Read.All, SecurityIdentitiesSensors.Read.All, SharePointTenantSettings.Read.All, ThreatHunting.Read.All, UserAuthenticationMethod.Read.All | High | 0 |\n| [Agent Identity Blueprint Example 4208296](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/c845b130-ce1b-4124-96ca-465df0eaa10f) | False | AgentIdUser.ReadWrite.IdentityParentedBy, Calendars.Read, Mail.Read, User.Read | High | 0 |\n| [Agent Identity Blueprint Example 4209295](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/20aaa39b-821d-40a5-8d8a-eff27f86bb4a) | False | AgentIdUser.ReadWrite.IdentityParentedBy, Files.Read, User.Read | High | 0 |\n| [testSP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/2361fd8a-fe89-4d07-9199-c117feb52b5e) | False | AuditLog.Read.All, CrossTenantInformation.ReadBasic.All, DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, Directory.Read.All, DirectoryRecommendations.Read.All, EntitlementManagement.Read.All, IdentityRiskEvent.Read.All, IdentityRiskyUser.Read.All, InformationProtectionPolicy.Read.All, LifecycleWorkflows-Reports.Read.All, NetworkAccess-Reports.Read.All, NetworkAccessPolicy.Read.All, Policy.Read.ConditionalAccess, Policy.Read.PermissionGrant, PrivilegedAccess.Read.AzureAD, RoleManagement.Read.All, UserAuthenticationMethod.Read.All | High | 0 |\n| [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/ad36b6e2-273d-4652-a505-8481f096e513) | False | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, offline_access, openid, Policy.Read.All, profile, User.Read | High | 0 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/35cbeecb-be21-4596-9869-0157d84f2d67) | False | Sites.FullControl.All, User.Read | High | 0 |\n| [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/3dde25cc-223f-4a16-8e8f-6695940b9680) | True | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, DeviceManagementApps.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, Directory.Read.All, offline_access, openid, Policy.Read.All, PrivilegedEligibilitySchedule.Read.AzureADGroup, profile, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, User.Read | High | 0 |\n| [ZT-PermissionTest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/b264ce7f-a584-49bf-8dd4-d2a3971e97b9) | False | AuditLog.Read.All, CrossTenantInformation.ReadBasic.All, DeviceManagementApps.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, Directory.Read.All, DirectoryRecommendations.Read.All, EntitlementManagement.Read.All, IdentityRiskEvent.Read.All, IdentityRiskyServicePrincipal.Read.All, IdentityRiskyUser.Read.All, NetworkAccess.Read.All, offline_access, openid, Policy.Read.All, Policy.Read.ConditionalAccess, Policy.Read.PermissionGrant, PrivilegedAccess.Read.AzureAD, profile, Reports.Read.All, RoleManagement.Read.All, User.Read, UserAuthenticationMethod.Read.All | High | 0 |\n| [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/7c32eaee-ff26-4435-be3d-b4ced08f9edc) | False | Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, SharePointTenantSettings.Read.All, User.Read, UserAuthenticationMethod.Read.All | High | 0 |\n| [entra-docs-email github DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/7a94aec7-a5e3-48dd-b20f-3db74d689434) | False | Mail.Send, User.Read | High | 0 |\n| [Maester DevOps Account - merill/maester-demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/fdce906b-d2f6-4738-8c76-e4559b9e17e8) | False | DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, ReportSettings.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, SecurityIdentitiesHealth.Read.All, SecurityIdentitiesSensors.Read.All, SharePointTenantSettings.Read.All, ThreatHunting.Read.All, UserAuthenticationMethod.Read.All | High | 0 |\n| [GitHub Actions App for Microsoft Info script](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/852b4218-67d2-4046-a9a6-f8b47430ccdf) | False | Application.Read.All | High | 0 |\n| [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/a15dc834-08ce-4fd8-85de-3729fff8e34f) | False | Application.Read.All, User.Read | High | 0 |\n| [Microsoft Sample Data Packs](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/63e1f0d4-bc2c-497a-bfe2-9eb4c8c2600e) | False | Application.ReadWrite.OwnedBy, Calendars.ReadWrite, Calendars.ReadWrite.All, Contacts.ReadWrite, Directory.ReadWrite.All, Files.ReadWrite, Files.ReadWrite.All, Group.ReadWrite.All, Mail.ReadWrite, Mail.Send, MailboxSettings.ReadWrite, Sites.FullControl.All, Sites.Manage.All, Sites.ReadWrite.All, User.ReadWrite, User.ReadWrite.All | High | 0 |\n| [Graph Explorer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/8f8f300a-870a-46ff-bdab-934e1436920d) | False | Directory.AccessAsUser.All, User.Read | High | 0 |\n| [Modern Workplace Concierge](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/ad1c51e8-f8a8-4bf2-ac09-a3a20cba5fa5) | False | Application.Read.All, DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementRBAC.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, Group.ReadWrite.All, openid, Policy.Read.All, Policy.ReadWrite.ConditionalAccess, profile, RoleManagement.Read.Directory, User.Read, User.ReadBasic.All | High | 0 |\n| [Azure AD Assessment (Test)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/d4cf4286-0fbe-424d-b4f2-65aa2c568631) | False | AuditLog.Read.All, Directory.AccessAsUser.All, Directory.ReadWrite.All, Group.ReadWrite.All, IdentityProvider.ReadWrite.All, offline_access, openid, Policy.ReadWrite.TrustFramework, PrivilegedAccess.ReadWrite.AzureAD, PrivilegedAccess.ReadWrite.AzureResources, profile, TrustFrameworkKeySet.ReadWrite.All, User.Invite.All | High | 0 |\n| [Windows Virtual Desktop AME](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/8369f33c-da25-4a8a-866d-b0145e29ef29) | False | Directory.Read.All, User.Read.All | High | 0 |\n| [Reset Viral Users Redemption Status](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/3a8785da-9965-473f-a97c-25fefdc39fee) | False | Directory.ReadWrite.All, offline_access, openid, profile, User.Invite.All, User.Read, User.ReadWrite.All | High | 0 |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Without owners, enterprise applications become orphaned assets that threat actors can exploit through credential harvesting and privilege escalation techniques. These applications often retain elevated permissions and access to sensitive resources while lacking proper oversight and security governance. The elevation of privilege to owners can raise a security concern, depending on the application's permissions. More critically, applications without an owner can create uncertainty in security monitoring where threat actors can establish persistence by using existing application permissions to access data or create backdoor accounts without triggering ownership-based detection mechanisms.\n\nWhen applications lack owners, security teams can't effectively conduct application lifecycle management. This gap leaves applications with potentially excessive permissions, outdated configurations, or compromised credentials that threat actors can discover through enumeration techniques and exploit to move laterally within the environment. The absence of ownership also prevents proper access reviews and permission audits, allowing threat actors to maintain long-term access through applications that should be decommissioned or had their permissions reduced. Not maintaining a clean application portfolio can provide persistent access vectors that can be used for data exfiltration or further compromise of the environment.\n\n**Remediation action**\n\n- [Assign owners to applications](https://learn.microsoft.com/entra/identity/enterprise-apps/assign-app-owners?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21860",
      "TestMinimumLicense": "P1",
      "TestCategory": "Monitoring",
      "TestTitle": "Diagnostic settings are configured for all Microsoft Entra logs",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSome Entra Logs are not configured with Diagnostic settings.\n\n## Log archiving\n\nLog | Archiving enabled |\n| :--- | :---: |\n|ADFSSignInLogs | ❌ |\n|AuditLogs | ❌ |\n|EnrichedOffice365AuditLogs | ❌ |\n|ManagedIdentitySignInLogs | ❌ |\n|MicrosoftGraphActivityLogs | ❌ |\n|NetworkAccessTrafficLogs | ❌ |\n|NonInteractiveUserSignInLogs | ❌ |\n|ProvisioningLogs | ❌ |\n|RemoteNetworkHealthLogs | ❌ |\n|RiskyServicePrincipals | ❌ |\n|RiskyUsers | ❌ |\n|ServicePrincipalRiskEvents | ❌ |\n|ServicePrincipalSignInLogs | ❌ |\n|SignInLogs | ❌ |\n|UserRiskEvents | ❌ |\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "The activity logs and reports in Microsoft Entra can help detect unauthorized access attempts or identify when tenant configuration changes. When logs are archived or integrated with Security Information and Event Management (SIEM) tools, security teams can implement powerful monitoring and detection security controls, proactive threat hunting, and incident response processes. The logs and monitoring features can be used to assess tenant health and provide evidence for compliance and audits.\n\nIf logs aren't regularly archived or sent to a SIEM tool for querying, it's challenging to investigate sign-in issues. The absence of historical logs means that security teams might miss patterns of failed sign-in attempts, unusual activity, and other indicators of compromise. This lack of visibility can prevent the timely detection of breaches, allowing attackers to maintain undetected access for extended periods.\n\n**Remediation action**\n\n- [Configure Microsoft Entra diagnostic settings](https://learn.microsoft.com/entra/identity/monitoring-health/howto-configure-diagnostic-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Integrate Microsoft Entra logs with Azure Monitor logs](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Stream Microsoft Entra logs to an event hub](https://learn.microsoft.com/entra/identity/monitoring-health/howto-stream-logs-to-event-hub?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.5",
      "ZtmmFunctionName": "Visibility & Analytics"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "When administrators use Microsoft Entra Private Access to reach domain controllers through Remote Desktop Protocol (RDP), they authenticate through Microsoft Entra ID before the Global Secure Access client tunnels their connection to the on-premises network. Domain controllers hold the cryptographic keys to the entire Active Directory forest. Compromising one domain controller offers a way to compromise every identity and resource in the organization.\n\nWithout phishing-resistant authentication:\n\n- Threat actors can intercept credentials during phishing campaigns or adversary-in-the-middle attacks.\n- Stolen session tokens can be replayed to establish RDP connections to domain controllers.\n- Once connected, threat actors can execute DCSync attacks to harvest all password hashes in the domain.\n- Attackers can create golden tickets for indefinite domain persistence.\n- Group Policy Objects can be modified to deploy ransomware or backdoors across all domain-joined machines.\n\nBy requiring phishing-resistant authentication, organizations ensure that even if users are successfully phished, threat actors can't replay credentials because these methods require cryptographic proof of possession.\n\n**Remediation action**\n\n- [Deploy phishing-resistant authentication methods to domain controller administrators](https://learn.microsoft.com/entra/identity/authentication/how-to-deploy-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- [Require phishing-resistant authentication for administrators accessing domain controllers via RDP](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-domain-controllers?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Domain controller RDP access is protected by phishing-resistant authentication through Global Secure Access",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25398",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.7",
      "ZtmmFunctionName": "Governance",
      "TestStatus": "Passed"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Traffic forwarding profiles are the foundational mechanism through which Global Secure Access captures and routes network traffic to Microsoft's Security Service Edge infrastructure. If you don't enable the appropriate traffic forwarding profiles, network traffic bypasses the Global Secure Access service entirely, and users don't get these network access protections.\n\nThere are three distinct profiles:\n\n- **Microsoft traffic profile**: Captures Microsoft Entra ID, Microsoft Graph, SharePoint Online, Exchange Online, and other Microsoft 365 workloads.\n- **Private access profile**: Captures traffic destined for internal corporate resources.\n- **Internet access profile**: Captures traffic to the public internet including non-Microsoft SaaS applications.\n\nIf you don't enable these profiles:\n\n- You can't enforce security policies, web content filtering, threat protection, or Universal Continuous Access Evaluation.\n- Threat actors who compromise user credentials can access corporate resources without the security controls that Global Secure Access would otherwise apply.\n\n**Remediation action**\n\n- Enable the Microsoft traffic forwarding profile. For more information, see [Manage the Microsoft traffic profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-microsoft-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Enable the Private Access traffic forwarding profile. For more information, see [Manage the Private Access traffic forwarding profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-private-access-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Enable the Internet Access traffic forwarding profile. For more information, see [Manage the Internet Access traffic forwarding profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-internet-access-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Network traffic is routed through Global Secure Access for security policy enforcement",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\") OR (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access",
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25381",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management",
      "TestStatus": "Failed"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Global Secure Access deployment logs track the status and progress of configuration changes across the global network. These changes include forwarding profile redistributions, remote network updates, filtering profile changes, and changes to Conditional Access settings. If deployment logs show failed deployments, threat actors can exploit inconsistent security configurations where some edge locations have outdated or misconfigured policies.\n\nIf you don't monitor deployment logs:\n\n- Failed deployments can leave security gaps such as outdated forwarding profiles that don't route traffic through security inspection, or filtering profiles that don't block malicious destinations.\n- Administrators might remain unaware of outdated configurations, believing that changes are applied uniformly.\n- Deployment failures that create exploitable gaps can go undetected.\n\n**Remediation action**\n\n- Follow the steps in [How to use the Global Secure Access deployment logs](https://learn.microsoft.com/entra/global-secure-access/how-to-view-deployment-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to:\n    - Access and review deployment logs in the Microsoft Entra admin center to identify failed deployments.\n    - For failed deployments, examine the error message in the `status.message` field and retry the configuration change that triggered the failure.\n    - Monitor deployment notifications that appear in the admin center when making configuration changes to catch failures in real-time.\n- If deployments consistently fail for remote networks, [review the underlying remote network configuration](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-remote-networks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) for errors.\n- For forwarding profile deployment failures, [verify traffic forwarding configuration](https://learn.microsoft.com/entra/global-secure-access/concept-traffic-forwarding?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Global Secure Access deployment logs are populated and reviewed",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\") OR (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access",
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25422",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Failed"
    },
    {
      "TestId": 21884,
      "TestMinimumLicense": "P1",
      "TestCategory": "External collaboration",
      "TestTitle": "Conditional Access policies for workload identities based on known networks are configured",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test is for tenants that are licensed for Entra Workload ID. See [Entra Workload ID licensing](https://learn.microsoft.com/entra/workload-id/workload-identities-faqs)\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "When workload identities operate without network-based Conditional Access restrictions, threat actors can compromise service principal credentials through various methods, such as exposed secrets in code repositories or intercepted authentication tokens. The threat actors can then use these credentials from any location globally. This unrestricted access enables threat actors to perform reconnaissance activities, enumerate resources, and map the tenant's infrastructure while appearing legitimate. Once the threat actor is established within the environment, they can move laterally between services, access sensitive data stores, and potentially escalate privileges by exploiting overly permissive service-to-service permissions. The lack of network restrictions makes it impossible to detect anomalous access patterns based on location. This gap allows threat actors to maintain persistent access and exfiltrate data over extended periods without triggering security alerts that would normally flag connections from unexpected networks or geographic locations. \n\n**Remediation action**\n\n- [Configure Conditional Access for workload identities](https://learn.microsoft.com/entra/identity/conditional-access/workload-identity?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create named locations](https://learn.microsoft.com/entra/identity/conditional-access/concept-assignment-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Follow best practices for securing workload identities](https://learn.microsoft.com/entra/workload-id/workload-identities-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "24690",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Update policies for macOS are enforced to reduce risk from unpatched vulnerabilities",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nAt least one macOS update policy is assigned to a group.\n\n\n## macOS Update Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [macOS_Update_1](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/iOSiPadOSUpdate) | ✅ Assigned | **Included:** All Devices, **Excluded:** WFgroup |\n| [alex_macOS_SoftwareUpdate](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ✅ Assigned | **Included:** All Devices, **Excluded:** WFgroup |\n| [alex_macOS_SoftwareUpdateEnforceLatest](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ❌ Not assigned | None |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If macOS update policies aren’t properly configured and assigned, threat actors can exploit unpatched vulnerabilities in macOS devices within the organization. Without enforced update policies, devices remain on outdated software versions, increasing the attack surface for privilege escalation, remote code execution, or persistence techniques. Threat actors can leverage these weaknesses to gain initial access, escalate privileges, and move laterally within the environment. If policies exist but aren’t assigned to device groups, endpoints remain unprotected, and compliance gaps go undetected. This can result in widespread compromise, data exfiltration, and operational disruption.\n\nEnforcing macOS update policies ensures devices receive timely patches, reducing the risk of exploitation and supporting Zero Trust by maintaining a secure, compliant device fleet.\n\n**Remediation action**\n\nConfigure and assign macOS update policies in Intune to enforce timely patching and reduce risk from unpatched vulnerabilities:  \n- [Manage macOS software updates in Intune](https://learn.microsoft.com/intune/intune-service/protect/software-updates-macos?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "24541",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Compliance policies protect Windows devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAt least one compliance policy for Windows exists and is assigned.\n\n\n## Windows Compliance Policies\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [Min Windows Compliance](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/compliance) | ✅ Assigned | **Included:** All Devices |\n| [My Windows policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/compliance) | ✅ Assigned | **Included:** All guests, **Excluded:** All active users |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If compliance policies for Windows devices aren't configured and assigned, threat actors can exploit unmanaged or noncompliant endpoints to gain unauthorized access to corporate resources, bypass security controls, and persist within the environment. Without enforced compliance, devices can lack critical security configurations like BitLocker encryption, password requirements, firewall settings, and OS version controls. These gaps increase the risk of data leakage, privilege escalation, and lateral movement. Inconsistent device compliance weakens the organization’s security posture and makes it harder to detect and remediate threats before significant damage occurs.\n\nEnforcing compliance policies ensures Windows devices meet core security requirements and supports Zero Trust by validating device health and reducing exposure to misconfigured endpoints.\n\n**Remediation action**\n\nCreate and assign Intune compliance policies to Windows devices to enforce organizational standards for secure access and management:\n- [Create and assign Intune compliance policies](https://learn.microsoft.com/intune/intune-service/protect/create-compliance-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-policy)\n- [Review the Windows compliance settings you can manage with Intune](https://learn.microsoft.com/intune/intune-service/protect/compliance-policy-create-windows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Without universal tenant restrictions configured, users on corporate devices and networks can authenticate to unauthorized external Microsoft Entra tenants and access cloud applications by using external identities. This vulnerability makes it possible for a threat actor to use compromised user credentials or established persistence on a corporate device to authenticate to a tenant they control. They can bypass traditional network security controls that can't inspect encrypted authentication traffic to Microsoft identity endpoints.\n\nOnce authenticated to an external tenant, a threat actor can access Microsoft Graph APIs and cloud services. This access enables data exfiltration through OneDrive, SharePoint, Teams, or any Microsoft Entra-integrated application in the external tenant. This attack path exploits the inherent trust that corporate networks and devices have with Microsoft identity services. Universal tenant restrictions address this vulnerability by injecting tenant identity headers into authentication plane traffic through Global Secure Access. Microsoft Entra ID uses these headers to enforce tenant restrictions v2 policies that block authentication attempts to unauthorized external tenants.\n\n**Remediation action**\n- [Set up tenant restrictions v2](https://learn.microsoft.com/entra/external-id/tenant-restrictions-v2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) policies to block all external tenants by default.\n- [Turn on universal tenant restrictions](https://learn.microsoft.com/entra/global-secure-access/how-to-universal-tenant-restrictions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) signaling in Global Secure Access.\n- [Deploy Global Secure Access client](https://learn.microsoft.com/entra/global-secure-access/concept-clients?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) on devices.\n- [Enable the Microsoft traffic profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-microsoft-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Universal tenant restrictions block unauthorized external tenant access",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25377",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Failed"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": null,
      "TestDescription": "Without encryption, sensitivity labels denote an item's sensitivity level without preventing unauthorized access, unless supplemented by another protection mechanism. Sensitivity labels that are configured to apply encryption from the Azure Rights Management service enforce access control and usage rights. This protection persists regardless of where the content is stored or shared. For example, users can still share a document labeled as \"Confidential\", but if that label applies encryption, unauthorized people won't be able to open it.\n\nOrganizations using labels without encryption gain visibility of the sensitivity level but the labels themselves lack technical enforcement. Labels that apply encryption ensure only authorized users can decrypt content and use it with any restrictions that are specified for that user. For example, read-only, or prevent copying. This protection helps prevent data exfiltration even if files are leaked or improperly shared. At least one sensitivity label should be configured to apply encryption for high-value data that requires protection beyond identifying the sensitivity level.\n\n**Remediation action**\n\n- [Restrict access to content by using encryption in sensitivity labels](https://learn.microsoft.com/purview/encryption-sensitivity-labels?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Sensitivity labels with encryption are configured",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Sensitivity Labels Configuration",
      "TestId": "35013",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data labeling and tagging",
      "TestStatus": "Passed"
    },
    {
      "TestId": "24871",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Defender for Endpoint automatic enrollment is enforced to reduce risk from unmanaged Android threats",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nNo Microsoft Defender for Endpoint Connector found in the tenant.\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If automatic enrollment into Microsoft Defender for Endpoint isn't configured for Android devices in Intune, managed endpoints might remain unprotected against mobile threats. Without Defender onboarding, devices lack advanced threat detection and response capabilities, increasing the risk of malware, phishing, and other mobile-based attacks. Unprotected devices can bypass security policies, access corporate resources, and expose sensitive data to compromise. This gap in mobile threat defense weakens the organization's Zero Trust posture and reduces visibility into endpoint health.\n\nEnabling automatic Defender enrollment ensures Android devices are protected by advanced threat detection and response capabilities. This supports Zero Trust by enforcing mobile threat protection, improving visibility, and reducing exposure to unmanaged or compromised endpoints.\n\n**Remediation action**\n\nUse Intune to configure automatic enrollment into Microsoft Defender for Endpoint for Android devices to enforce mobile threat protection:\n\n- [Integrate Microsoft Defender for Endpoint with Intune and Onboard Devices](https://learn.microsoft.com/intune/intune-service/protect/advanced-threat-protection-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "2.4",
      "ZtmmFunctionName": "Device threat detection"
    },
    {
      "TestId": "21858",
      "TestMinimumLicense": "Free",
      "TestCategory": "External collaboration",
      "TestTitle": "Inactive guest identities are disabled or removed from the tenant",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\n❌ Found 3 inactive guest user(s) with no sign-in activity in the last 90 days:\n\n\n## Inactive guest accounts in the tenant\n\n\n| Display name | User principal name | Last sign-in date | Created date |\n| :----------- | :------------------ | :---------------- | :----------- |\n| [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/a0883b7a-c6a8-440f-84f0-d6e1b79aaf4c/hidePreviewBanner~/true) | merill_merill.net#EXT#@pora.onmicrosoft.com | 2025-08-10 | 2021-04-11 |\n| [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true) | merillf_gmail.com#EXT#@pora.onmicrosoft.com |  | 2021-06-02 |\n| [Shonali Balakrishna](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/305bbf73-eee4-4e0c-9c7d-627e00ed3665/hidePreviewBanner~/true) | shobalak_outlook.com#EXT#@pora.onmicrosoft.com | 2025-05-05 | 2025-03-25 |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "When guest identities remain active but unused for extended periods, threat actors can exploit these dormant accounts as entry vectors into the organization. Inactive guest accounts represent a significant attack surface because they often maintain persistent access permissions to resources, applications, and data while remaining unmonitored by security teams. Threat actors frequently target these accounts through credential stuffing, password spraying, or by compromising the guest's home organization to gain lateral access. Once an inactive guest account is compromised, attackers can utilize existing access grants to:\n- Move laterally within the tenant\n- Escalate privileges through group memberships or application permissions\n- Establish persistence through techniques like creating more service principals or modifying existing permissions\n\nThe prolonged dormancy of these accounts provides attackers with extended dwell time to conduct reconnaissance, exfiltrate sensitive data, and establish backdoors without detection, as organizations typically focus monitoring efforts on active internal users rather than external guest accounts.\n\n**Remediation action**\n- [Monitor and clean up stale guest accounts](https://learn.microsoft.com/entra/identity/users/clean-up-stale-guest-accounts?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.6",
      "ZtmmFunctionName": "Automation & Orchestration"
    },
    {
      "TestId": "21851",
      "TestMinimumLicense": "Free",
      "TestCategory": "External collaboration",
      "TestTitle": "Guest access is protected by strong authentication methods",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your organization. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.\n\nAttackers might gain access with external user accounts, if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. They might also gain access by exploiting the vulnerabilities of weaker MFA methods like SMS and phone calls using social engineering techniques, such as SIM swapping or phishing, to intercept the authentication codes.\n\nOnce an attacker gains access to an account without MFA or a session with weak MFA methods, they might attempt to manipulate MFA settings (for example, registering attacker controlled methods) to establish persistence to plan and execute further attacks based on the privileges of the compromised accounts.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to enforce authentication strength for guests](https://learn.microsoft.com/entra/identity/conditional-access/policy-guests-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- For organizations with a closer business relationship and vetting on their MFA practices, consider deploying cross-tenant access settings to accept the MFA claim.\n   - [Configure B2B collaboration cross-tenant access settings](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-change-inbound-trust-settings-for-mfa-and-device-claims)\n",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": "21795",
      "TestMinimumLicense": "P1",
      "TestCategory": "Monitoring",
      "TestTitle": "No legacy authentication sign-in activity",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Legacy authentication protocols such as basic authentication for SMTP and IMAP don't support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This lack of protection makes accounts using these protocols vulnerable to password-based attacks, and provides attackers with a means to gain initial access using stolen or guessed credentials.\n\nWhen an attacker successfully gains unauthorized access to credentials, they can use them to access linked services, using the weak authentication method as an entry point. Attackers who gain access through legacy authentication might make changes to Microsoft Exchange, such as configuring mail forwarding rules or changing other settings, allowing them to maintain continued access to sensitive communications.\n\nLegacy authentication also provides attackers with a consistent method to reenter a system using compromised credentials without triggering security alerts or requiring reauthentication.\n\nFrom there, attackers can use legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement. Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.\n\n**Remediation action**\n\n- [Exchange protocols can be deactivated in Exchange](https://learn.microsoft.com/exchange/clients-and-mobile-in-exchange-online/disable-basic-authentication-in-exchange-online?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Legacy authentication protocols can be blocked with Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Sign-ins using legacy authentication workbook to help determine whether it's safe to turn off legacy authentication](https://learn.microsoft.com/entra/identity/monitoring-health/workbook-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": null,
      "TestDescription": "The policy setting **Require users to apply a label** ensures a sensitivity label must be applied before users can save files and send emails or meeting invites, create new groups or sites, and use Power BI content. This setting also prevents users from completely removing a sensitivity label. Unlabeled items create security and compliance risks. For example, threat actors can exfiltrate sensitive data that could be prevented by protection solutions that trigger based on label detection.\n\n**Remediation action**\n\n- [Publish sensitivity labels by creating a label policy](https://learn.microsoft.com/purview/create-sensitivity-labels?tabs=modern-label-scheme&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#publish-sensitivity-labels-by-creating-a-label-policy)\n- [Require users to apply a label to their email and documents](https://learn.microsoft.com/purview/sensitivity-labels-office-apps?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#require-users-to-apply-a-label-to-their-email-and-documents)\n",
      "TestTitle": "Mandatory labeling is enabled in sensitivity label policies",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Information Protection",
      "TestId": "35016",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21866",
      "TestMinimumLicense": "P1",
      "TestCategory": "Monitoring",
      "TestTitle": "All Microsoft Entra recommendations are addressed",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound 11 unaddressed Entra recommendations.\n\n\n## Unaddressed Entra recommendations\n\n| Display Name | Status | Insights | Priority |\n| :--- | :--- | :--- | :--- |\n| Protect your tenant with Insider Risk condition in Conditional Access policy | active | You have 86 of 88 users that aren’t covered by the Insider Risk condition in a Conditional Access policy. | medium |\n| Protect all users with a user risk policy  | active | You have 3 of 88 users that don’t have a user risk policy enabled.  | high |\n| Protect all users with a sign-in risk policy | active | You have 86 of 88 users that don't have a sign-in risk policy turned on. | high |\n| Enable password hash sync if hybrid | active | You have disabled password hash sync. | medium |\n| Ensure all users can complete multifactor authentication | active | You have 57 of 88 users that aren’t registered with MFA.  | high |\n| Enable policy to block legacy authentication | active | You have 1 of 88 users that don’t have legacy authentication blocked.  | high |\n| Require multifactor authentication for administrative roles | active | You have 6 of 26 users with administrative roles that aren’t registered and protected with MFA. | high |\n| Renew expiring application credentials | active | Your tenant has applications with credentials that will expire soon. | high |\n| Remove unused credentials from applications | active | Your tenant has applications with credentials which have not been used in more than 30 days. | medium |\n| Remove unused applications | active | This recommendation will surface if your tenant has applications that have not been used for over 90 days. Applications that were created but never used, client applications which have not been issued a token or resource apps that have not been a target of a token request, will show under this recommendation. | medium |\n| Start your Defender for Identity deployment, installing Sensors on Domain Controllers and other eligible servers. | active | Installing Microsoft Defender for Identity sensors provides you with the ability to detect advanced threats in your entire identity infrastructure. Actionable security alerts are generated through the analysis of network traffic and security events. | low |\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Microsoft Entra recommendations give organizations opportunities to implement best practices and optimize their security posture. Not acting on these items might result in an increased attack surface area, suboptimal operations, or poor user experience.\n\n**Remediation action**\n\n- [Address all active or postponed recommendations in the Microsoft Entra admin center](https://learn.microsoft.com/entra/identity/monitoring-health/overview-recommendations?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-does-it-work)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "24554",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Update policies for iOS/iPadOS are enforced to reduce risk from unpatched vulnerabilities",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAn iOS update policy is configured and assigned.\n\n\n## iOS Update Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [iOS_Update_1](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/iOSiPadOSUpdate) | ❌ Not assigned | None |\n| [alex_ios_DDM_SoftwareUpdate](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ✅ Assigned | **Included:** All Devices, **Excluded:** WFgroup |\n| [alex_ios_DDM_SoftwareUpdateEnforceLatest](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ✅ Assigned | **Included:** All Devices, **Excluded:** WFgroup |\n| [alex_ios_policy1](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ❌ Not assigned | None |\n| [alex_ios_policy2](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration) | ✅ Assigned | **Included:** All Users |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If iOS update policies aren’t configured and assigned, threat actors can exploit unpatched vulnerabilities in outdated operating systems on managed devices. The absence of enforced update policies allows attackers to use known exploits to gain initial access, escalate privileges, and move laterally within the environment. Without timely updates, devices remain susceptible to exploits that have already been addressed by Apple, enabling threat actors to bypass security controls, deploy malware, or exfiltrate sensitive data. This attack chain begins with device compromise through an unpatched vulnerability, followed by persistence and potential data breach that impacts both organizational security and compliance posture.\n\nEnforcing update policies disrupts this chain by ensuring devices are consistently protected against known threats.\n\n**Remediation action**\n\nConfigure and assign iOS/iPadOS update policies in Intune to enforce timely patching and reduce risk from unpatched vulnerabilities:  \n- [Manage iOS/iPadOS software updates in Intune](https://learn.microsoft.com/intune/intune-service/protect/software-updates-guide-ios-ipados?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "21887",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "All registered redirect URIs must have proper DNS records and ownerships",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Autolabeling policies only classify new and modified content. Existing files and emails remain unclassified and invisible to DLP policies that depend on label detection. On-demand scans let you manually trigger sensitive information type detection across specified locations to discover and retroactively classify historical content, giving you a complete view of your information protection posture rather than forward-looking coverage.\n\n**Remediation action**\n\n- [On-demand classification in Microsoft Purview](https://learn.microsoft.com/purview/on-demand-classification?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "On-demand scans are configured for sensitive information discovery",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Information Protection",
      "TestId": "35022",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21875",
      "TestMinimumLicense": [
        "P2",
        "Governance"
      ],
      "TestCategory": "External collaboration",
      "TestTitle": "All entitlement management assignment policies that apply to external users require connected organizations",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAssignment policies without connected organization restrictions were found.\n## Evaluated assignment policies\n| Access package | Assignment policy | Target scope | Status |\n| :--- | :--- | :--- | :--- |\n| [PS-GraphCmdLetScriptTest4](https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlement/menuId/) | 21929Test | allExternalUsers | ❌ Fail |\n| [PS-GraphCmdLetScriptTest4](https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlement/menuId/) | External | allConfiguredConnectedOrganizationUsers | ⚠️ Investigate |\n| [Get user info demo](https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlement/menuId/) | Initial Policy | specificConnectedOrganizationUsers | ✅ Pass |\n| [UserInfo](https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlement/menuId/) | Initial Policy | allConfiguredConnectedOrganizationUsers | ⚠️ Investigate |\n\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Access packages configured to allow \"All users\" instead of specific connected organizations expose your organization to uncontrolled external access. Threat actors can exploit this by requesting access through compromised external accounts from unauthorized organizations, bypassing the principle of least privilege. This enables initial access, reconnaissance, privilege escalation, and lateral movement within your environment. \n\n**Remediation action**\n\n- [Define trusted organizations as connected organizations](https://learn.microsoft.com/entra/id-governance/entitlement-management-organization?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#view-the-list-of-connected-organizations)\n- [Configure access packages to only allow specific connected organizations](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#allow-users-not-in-your-directory-to-request-the-access-package)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "When auto-labeling policies are left in simulation mode, you're not realizing the protection from labeling that data. As a result, users and services can't take additional protective measures to safeguard the identified sensitive data. For example, users won't see in their Office apps that a file is labeled Highly Confidential. Data loss prevention rules might use sensitivity labels to prevent sharing with external users, and other risky actions. Labeled data also provides an additional layer of protection when you use Microsoft 365 Copilot.\n\nTo ensure sensitive information is automatically labeled, turn on at least one auto-labeling policy. Turning on auto-labeling policies after simulation testing puts protective measures into effect and starts reducing risk.\n\n**Remediation action**\n\n- [How to configure auto-labeling policies for SharePoint, OneDrive, and Exchange](https://learn.microsoft.com/purview/apply-sensitivity-label-automatically?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-to-configure-auto-labeling-policies-for-sharepoint-onedrive-and-exchange)\n",
      "TestTitle": "Auto-labeling policies are in enforcement mode",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Information Protection",
      "TestId": "35020",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.3",
      "ZtmmFunctionName": "Data monitoring and access control",
      "TestStatus": "Failed"
    },
    {
      "TestId": 22659,
      "TestMinimumLicense": "P2",
      "TestCategory": "Monitoring",
      "TestTitle": "All risky workload identity sign-ins are triaged",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test is for tenants that are licensed for Entra Workload ID. See [Entra Workload ID licensing](https://learn.microsoft.com/entra/workload-id/workload-identities-faqs)\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "Threat actors increasingly target workload identities (applications, service principals, and managed identities) because they lack human factors and often use long-lived credentials. A compromise often looks like the following path:\n\n1. Credential abuse or key theft.\n1. Non-interactive sign-ins to cloud resources.\n1. Lateral movement via app permissions.\n1. Persistence through new secrets or role assignments.\n\nMicrosoft Entra ID Protection continuously generates risky workload identity detections and flags sign-in events with risk state and detail. Risky workload identity sign-ins that aren’t triaged (confirmed compromised, dismissed, or marked safe), detection fatigue, and a large alert backlog can be challenging for IT admins to manage. This heavy workload can let repeated malicious access, privilege escalation, and token replay to continue to go unnoticed. To make the workload manageable, address risky workload identity sign-ins in two parts:\n\n- Close the loop: Triage sign-ins and record an authoritative decision on each risky event.\n- Drive containment: Disable the service principal, rotate credentials, or revoke sessions.\n\n**Remediation action**\n\n- [Investigate risky workload identities and perform appropriate remediation ](https://learn.microsoft.com/entra/id-protection/concept-workload-identity-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Dismiss workload identity risks when determined to be false positives](https://learn.microsoft.com/graph/api/riskyserviceprincipal-dismiss?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Confirm compromised workload identities when risks are validated](https://learn.microsoft.com/graph/api/riskyserviceprincipal-confirmcompromised?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21791",
      "TestMinimumLicense": "Free",
      "TestCategory": "External collaboration",
      "TestTitle": "Guests can’t invite other guests",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nTenant restricts who can invite guests.\n\n**Guest invite settings**\n\n  * Guest invite restrictions → Member users and users assigned to specific admin roles can invite guest users including guests with member permissions\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.  \n\nAllowing external users to onboard other external users increases the risk of unauthorized access. If an attacker compromises an external user's account, they can use it to create more external accounts, multiplying their access points and making it harder to detect the intrusion.\n\n**Remediation action**\n\n- [Restrict who can invite guests to only users assigned to specific admin roles](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-invite-settings)\n",
      "TestTags": [
        "ExternalCollaboration"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "OCR (optical character recognition) extends sensitive information type and trainable classifier detection to images across Exchange, SharePoint, OneDrive, Teams, and endpoint devices. Without OCR, DLP policies, and auto-labeling policies can't scan image-based content, scanned documents, screenshots, and invoices, leaving sensitive data in images unprotected. OCR requires Azure pay-as-you-go billing for Microsoft Syntex, and is configured at the tenant level.\n\n**Remediation action**\n\n- [Learn about and configure optical character recognition in Microsoft Purview](https://learn.microsoft.com/purview/ocr-learn-about?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "OCR is enabled for sensitive information detection",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Information Protection",
      "TestId": "35023",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21839",
      "TestMinimumLicense": "Free",
      "TestCategory": "Credential management",
      "TestTitle": "Passkey authentication method enabled",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nPasskey authentication method is enabled and configured for users in your tenant.\n## [Passkey authentication method details](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConfigureAuthMethodsBlade/authMethod~/%7B%22%40odata.type%22%3A%22%23microsoft.graph.fido2AuthenticationMethodConfiguration%22%2C%22id%22%3A%22Fido2%22%2C%22state%22%3A%22enabled%22%2C%22isSelfServiceRegistrationAllowed%22%3Atrue%2C%22isAttestationEnforced%22%3Afalse%2C%22excludeTargets%22%3A%5B%7B%22id%22%3A%2243b7bc87-77eb-4263-abad-e3c2478f0a35%22%2C%22targetType%22%3A%22group%22%2C%22displayName%22%3A%22eam-block-user%22%7D%5D%2C%22keyRestrictions%22%3A%7B%22isEnforced%22%3Afalse%2C%22enforcementType%22%3A%22allow%22%2C%22aaGuids%22%3A%5B%22de1e552d-db1d-4423-a619-566b625cdc84%22%2C%2290a3ccdf-635c-4729-a248-9b709135078f%22%2C%2277010bd7-212a-4fc9-b236-d2ca5e9d4084%22%2C%22b6ede29c-3772-412c-8a78-539c1f4c62d2%22%2C%22ee041bce-25e5-4cdb-8f86-897fd6418464%22%2C%2273bb0cd4-e502-49b8-9c6f-b59445bf720b%22%5D%7D%2C%22includeTargets%40odata.context%22%3A%22https%3A%2F%2Fgraph.microsoft.com%2Fbeta%2F%24metadata%23policies%2FauthenticationMethodsPolicy%2FauthenticationMethodConfigurations('Fido2')%2Fmicrosoft.graph.fido2AuthenticationMethodConfiguration%2FincludeTargets%22%2C%22includeTargets%22%3A%5B%7B%22targetType%22%3A%22group%22%2C%22id%22%3A%22all_users%22%2C%22isRegistrationRequired%22%3Afalse%7D%5D%2C%22enabled%22%3Atrue%2C%22target%22%3A%22All%20users%2C%20excluding%201%20group%22%2C%22isAllUsers%22%3Atrue%2C%22voiceDisabled%22%3Afalse%7D/canModify~/true/voiceDisabled~/false/userMemberIds~/%5B%5D/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/isCiamTenant~/false/isCiamTrialTenant~/false)\n- **Status** : Enabled ✅\n- **Include targets** : All users\n- **Enforce attestation** : False\n- **Key restriction policy** :\n  - **Enforce key restrictions** : False\n  - **Restrict specific keys** : Allow\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "When passkey authentication isn't enabled in Microsoft Entra ID, organizations rely on password-based authentication methods that are vulnerable to phishing, credential theft, and replay attacks. Attackers can use stolen passwords to gain initial access, bypass traditional multifactor authentication through Adversary-in-the-Middle (AiTM) attacks, and establish persistent access through token theft.\n\nPasskeys provide phishing-resistant authentication using cryptographic proof that attackers can't phish, intercept, or replay. Enabling passkeys eliminates the foundational vulnerability that enables credential-based attack chains.\n\n**Remediation action**\n\n- Learn how to [enable the passkey authentication method](https://learn.microsoft.com/entra/identity/authentication/how-to-enable-passkey-fido2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-passkey-fido2-authentication-method).\n- Learn how to [plan a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "When users aren't required to provide a justification for changing a label, they can silently replace a label with one that has a lower sensitivity. For example, replace the \"Confidential\" label that applies additional protection settings, with \"General\". This action creates security and compliance risk. Requiring a justification reason makes this risk more obvious to users, and forces them to provide a reason as a visible audit trail.\n\nCompromised accounts or departing employees could downgrade labels to enable data exfiltration. Requiring justification is a lightweight control that increases accountability with low impact on user workflows.\n\n**Remediation action**\n\n- [Publish sensitivity labels by creating a label policy](https://learn.microsoft.com/purview/create-sensitivity-labels?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#publish-sensitivity-labels-by-creating-a-label-policy)\n- [What label policies can do](https://learn.microsoft.com/purview/sensitivity-labels?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#what-label-policies-can-do)\n- [Review labeling activities in activity explorer](https://learn.microsoft.com/purview/data-classification-activity-explorer-available-events?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#protection-removed)\n",
      "TestTitle": "Users must provide justification to downgrade sensitivity labels",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Information Protection",
      "TestId": "35018",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Passed"
    },
    {
      "TestId": "27017",
      "TestMinimumLicense": "Azure WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "JavaScript Challenge is Enabled in Application Gateway WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Azure Application Gateway Web Application Firewall (WAF) supports JavaScript challenge as a defense mechanism against automated bots and headless browsers. JavaScript challenge works by serving a small JavaScript snippet that must be executed by the client browser to prove that the request originates from a real browser capable of running JavaScript, rather than a simple HTTP client or bot.\n\nWhen a request triggers a JavaScript challenge, the WAF responds with a challenge page containing JavaScript code that the browser must execute to obtain a valid challenge cookie. If the client successfully executes the JavaScript and returns with a valid cookie, subsequent requests proceed normally until the cookie expires. Bots and automated tools that cannot execute JavaScript fail this challenge and are blocked from accessing protected resources. This mechanism is particularly effective against credential stuffing bots, web scrapers, and distributed denial of service bots that use simple HTTP libraries without JavaScript engines.\n\nThe `jsChallengeCookieExpirationInMins` setting controls how long the challenge cookie remains valid before the client must complete another challenge. JavaScript challenge provides a middle ground between allowing all traffic and blocking suspected bots outright—it verifies browser capability without requiring user interaction like CAPTCHA. By configuring custom rules with JavaScript challenge action, organizations can protect sensitive endpoints like login pages, API endpoints, and high-value resources from automated abuse while maintaining a seamless experience for legitimate users.\n\n\n**Remediation action**\n\n- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview) - Overview of WAF capabilities on Application Gateway including custom rules and actions\n- [Create and use Web Application Firewall v2 custom rules on Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-custom-waf-rules) - Step-by-step guidance on creating custom rules with different actions including JavaScript challenge\n- [Web Application Firewall custom rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/custom-waf-rules-overview) - Detailed documentation of custom rule types and available actions\n- [Bot protection overview for Application Gateway WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/bot-protection-overview) - Overview of bot protection capabilities including challenge actions\n\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestDescription": "Without extended retention for Global Secure Access audit and traffic logs, threat actors can operate beyond the default 30-day retention window, knowing that their activities are automatically purged before detection occurs. Security investigations often require historical analysis spanning weeks or months to identify compromise vectors, lateral movement patterns, and data exfiltration channels.\n\nWithout adequate log retention:\n\n- Security teams can't establish baseline behavior patterns, perform retrospective threat hunting, or correlate network access events across extended timeframes.\n- Organizations subject to regulatory frameworks like [GDPR](https://learn.microsoft.com/compliance/regulatory/gdpr?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci), HIPAA, PCI DSS, and SOX face compliance violations when they're unable to produce audit trails for mandated retention periods.\n- Root cause analysis during incident response is limited, potentially allowing threat actors to maintain persistence while organizations focus on visible symptoms.\n\n**Remediation action**\n\n- [Configure diagnostic settings with a Log Analytics workspace](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) for an extended retention of 90-730 days, with query capabilities.\n- [Configure Log Analytics workspace retention](https://learn.microsoft.com/azure/azure-monitor/logs/data-retention-archive?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to meet organizational security and compliance requirements (minimum 90 days recommended).\n- [Enable table-level retention](https://learn.microsoft.com/azure/azure-monitor/logs/data-retention-archive?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-table-level-retention) for specific Global Secure Access tables to extend beyond workspace defaults.\n",
      "TestTitle": "Network access logs are retained for security analysis and compliance requirements",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access",
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "NotConnectedToService",
      "TestCategory": "Global Secure Access",
      "TestId": "25420",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management",
      "TestStatus": "Skipped"
    },
    {
      "TestId": 21955,
      "TestMinimumLicense": "P1",
      "TestCategory": "Devices",
      "TestTitle": "Manage the local administrators on Microsoft Entra joined devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test is not applicable to the current environment.\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "When local administrators on Microsoft Entra joined devices aren't properly managed, threat actors with compromised credentials can execute device takeover attacks by removing organizational administrators and disabling the device's connection to Microsoft Entra. This lack of control results in complete loss of organizational control, creating orphaned assets that can't be managed or recovered.\n\n**Remediation action**\n\n- [Manage the local administrators on Microsoft Entra joined devices](https://learn.microsoft.com/entra/identity/devices/assign-local-admin?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#manage-the-microsoft-entra-joined-device-local-administrator-role)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics"
    },
    {
      "TestId": "21842",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management, Privileged access",
      "TestTitle": "Block administrators from using SSPR",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n✅ Administrators are properly blocked from using Self-Service Password Reset, ensuring password changes go through controlled processes.\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Self-Service Password Reset (SSPR) for administrators allows password changes to happen without strong secondary authentication factors or administrative oversight. Threat actors who compromise administrative credentials can use this capability to bypass other security controls and maintain persistent access to the environment.\n\nOnce compromised, attackers can immediately reset the password to lock out legitimate administrators. They can then establish persistence, escalate privileges, and deploy malicious payloads undetected.\n\n**Remediation action**\n\n- [Disable SSPR for administrators by updating the authorization policy](https://learn.microsoft.com/entra/identity/authentication/concept-sspr-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#administrator-reset-policy-differences)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21889",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Reduce the user-visible password surface area",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nYour organization has implemented multiple passwordless authentication methods reducing password exposure.\n## Passwordless authentication methods\n\n| Method | State | Include targets | Authentication mode | Status |\n| :----- | :---- | :-------------- | :------------------ | :----- |\n| FIDO2 Security Keys | ✅ Enabled | All users | N/A | ✅ Pass |\n| Microsoft Authenticator | ✅ Enabled | All users | ✅ any | ✅ Pass |\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Organizations with extensive user-facing password surfaces expose multiple entry points for threat actors to launch credential-based attacks. Frequent user interactions with password prompts across applications, devices, and workflows increase the risk of exploitation. Threat actors often begin with credential stuffing—using compromised credentials from data breaches—followed by password spraying to test common passwords across multiple accounts. Once initial access is gained, they conduct credential discovery by examining browser password stores, cached credentials in memory, and credential managers to harvest additional authentication materials. These stolen credentials enable lateral movement, allowing attackers to access more systems and applications, often escalating privileges by targeting administrative accounts that still rely on password authentication. In the persistence phase, attackers may create backdoor accounts with password-based access or weaken defenses by altering password policies. To evade detection, they leverage legitimate authentication channels, blending in with normal user activity while maintaining persistent access to organizational resources. \n\n**Remediation action**\n\n * [Enable passwordless authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication)\n\n * [Deploy FIDO2 security keys](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-enable-passkey-fido2)\n\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "26889",
      "TestMinimumLicense": [
        "Azure_FrontDoor_Standard",
        "Azure_FrontDoor_Premium"
      ],
      "TestCategory": "Azure Network Security",
      "TestTitle": "Diagnostic logging is enabled in Azure Front Door WAF",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Without diagnostic logging enabled for Azure Front Door WAF, security teams lose visibility into blocked attacks, rule matches, access patterns, and WAF events occurring at the network edge. Threat actors attempting to exploit web application vulnerabilities through SQL injection, cross-site scripting, or other OWASP Top 10 attacks would go undetected because no WAF logs are being captured or analyzed. The absence of logging prevents correlation of WAF events with other security telemetry, eliminating the ability to construct attack timelines during incident investigations. Furthermore, compliance frameworks such as PCI-DSS, HIPAA, and SOC 2 require organizations to maintain audit logs of web application security events, and the lack of WAF diagnostic logging creates audit failures. Azure Front Door WAF provides multiple log categories including Access Logs and WAF Logs, which must be routed to a destination such as Log Analytics, Storage Account, or Event Hub to enable security monitoring and forensic analysis.\n\n**Remediation action**\n\nConfigure diagnostic settings for Azure Front Door to enable WAF log collection\n- [Create diagnostic settings in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/create-diagnostic-settings)\n\nEnable WAF logging to capture firewall events and rule matches\n- [Azure Front Door WAF monitoring and logging](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-monitor)\n\nCreate a Log Analytics workspace for storing and analyzing WAF logs\n- [Create a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/quick-create-workspace)\n\nMonitor Azure Front Door using diagnostic logs and metrics\n- [Monitor metrics and logs in Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-diagnostics)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics"
    },
    {
      "TestId": "24549",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Data",
      "TestTitle": "Data on Android is protected by app protection policies",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nAt least one App protection policy for Android exists and is assigned.\n\n\n## Android App Protection policies configured for Android\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [Android Policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/protection) | ✅ Assigned | **Included:** aad-conditional-access-excluded |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Without app protection policies, corporate data accessed on Android devices is vulnerable to leakage through unmanaged or malicious apps. Users can unintentionally copy sensitive information into personal apps, store data insecurely, or bypass authentication controls. This risk is amplified on devices that aren't fully managed, where corporate and personal contexts coexist, increasing the likelihood of data exfiltration or unauthorized access.\n\nEnforcing app protection policies ensures that corporate data is only accessible through trusted apps and remains protected even on personal or BYOD Android devices.\n\nThese policies enforce encryption, restrict data sharing, and require authentication, reducing the risk of data leakage and aligning with Zero Trust principles of data protection and Conditional Access.\n\n**Remediation action**\n\nDeploy Intune app protection policies that encrypt data, restrict sharing, and require authentication in approved Android apps:  \n- [Deploy Intune app protection policies](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policies?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-an-iosipados-or-android-app-protection-policy)\n- [Review the Android app protection settings reference](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policy-settings-android?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:  \n- [Learn about using app protection policies](https://learn.microsoft.com/intune/intune-service/apps/app-protection-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "High",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "21810",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Resource-specific consent is restricted",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nResource-Specific Consent is not restricted.\n\nThe current state is ManagedByMicrosoft.\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Letting group owners consent to applications in Microsoft Entra ID creates a lateral escalation path that lets threat actors persist and steal data without admin credentials. If an attacker compromises a group owner account, they can register or use a malicious application and consent to high-privilege Graph API permissions scoped to the group. Attackers can potentially read all Teams messages, access SharePoint files, or manage group membership. This consent action creates a long-lived application identity with delegated or application permissions. The attacker maintains persistence with OAuth tokens, steals sensitive data from team channels and files, and impersonates users through messaging or email permissions. Without centralized enforcement of app consent policies, security teams lose visibility, and malicious applications spread under the radar, enabling multi-stage attacks across collaboration platforms.\n\n**Remediation action**\nConfigure preapproval of Resource-Specific Consent (RSC) permissions.\n- [Preapproval of RSC permissions](https://learn.microsoft.com/microsoftteams/platform/graph-api/rsc/preapproval-instruction-docs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Named entity sensitive information types (SITs) are prebuilt Microsoft classifiers that detect common sensitive entities like people's names, physical addresses, and medical terminology. They extend data protection beyond pattern matching into context aware classification, and can be used in auto-labeling policies and DLP rules without any custom development.\n\n**Remediation action**\n\n- [Learn about named entities](https://learn.microsoft.com/purview/sit-named-entities-learn?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Use named entities in your data loss prevention policies](https://learn.microsoft.com/purview/sit-named-entities-use?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Named entity sensitive information types are used in auto-labeling and data loss prevention policies",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Advanced Classification",
      "TestId": "35035",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Failed"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Without Global Secure Access logs integrated into a Microsoft Sentinel workspace, security operations teams lack centralized visibility into network traffic patterns, connection attempts, and access anomalies across Private Access, Internet Access, and Microsoft 365 traffic forwarding. Threat actors who compromise user credentials or devices can use these network access paths to perform reconnaissance, move laterally, or exfiltrate data without detection.\n\nWithout this integration:\n\n- Security teams can't correlate network-layer activities with identity-based signals in Microsoft Entra ID or endpoint detections.\n- Security information and event management (SIEM) systems can't apply behavioral analytics, threat intelligence correlation, or automated response playbooks to Global Secure Access traffic.\n- Security teams can't investigate historical network access patterns or hunt for threats across network and identity signals.\n\n**Remediation action**\n\n- [Configure Microsoft Entra diagnostic settings](https://learn.microsoft.com/entra/global-secure-access/how-to-sentinel-integration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to send Global Secure Access logs to a Log Analytics workspace for Microsoft Sentinel integration.\n- [Enable all required Global Secure Access identity log categories](https://learn.microsoft.com/entra/identity/monitoring-health/concept-diagnostic-settings-logs-options?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci), including `NetworkAccessTrafficLogs`, `EnrichedOffice365AuditLogs`, `RemoteNetworkHealthLogs`, `NetworkAccessAlerts`, `NetworkAccessConnectionEvents`, and `NetworkAccessGenerativeAIInsights` in diagnostic settings.\n- [Integrate Microsoft Entra activity logs with Azure Monitor](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) for centralized log collection.\n- [Configure a Microsoft Sentinel workspace](https://learn.microsoft.com/azure/sentinel/quickstart-onboard?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) and install the Global Secure Access solution from the content hub.\n",
      "TestTitle": "Network access activity is visible to security operations for threat detection and response",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access",
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25419",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21881",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "Azure subscriptions used by Identity Governance are secured consistently with Identity Governance roles",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics"
    },
    {
      "TestId": "21878",
      "TestMinimumLicense": [
        "P2",
        "Governance"
      ],
      "TestCategory": "Identity governance",
      "TestTitle": "All entitlement management policies have an expiration date",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n❌ Not all entitlement management policies have expiration dates configured.\n### Entitlement Management Assignment Policies with Expiration Dates\n| Name | Expiration Type | Duration / End DateTime |\n| :--- | :--- | ---: |\n| [test Policy](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/test%20Policy) | afterDuration | P365D |\n| [All users](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/All%20users) | afterDateTime | 11/15/2027 12:59:59 |\n| [Initial Policy](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/Initial%20Policy) | afterDuration | P365D |\n| [Initial Policy](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/Initial%20Policy) | afterDuration | P365D |\n\n#### Policies missing expiration:\n| Name | Expiration Type | Duration / End DateTime |\n| :--- | :--- | ---: |\n| [21929Test](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/21929Test) | noExpiration |  |  |\n| [External](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/External) | noExpiration |  |  |\n| [All users](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/All%20users) | noExpiration |  |  |\n| [All users](https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId//catalogId//catalogName//entitlementName/All%20users) | noExpiration |  |  |\n\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Entitlement management policies without expiration dates create persistent access that threat actors can exploit. When user assignments lack time bounds, compromised credentials maintain indefinite access, enabling attackers to establish persistence, escalate privileges through additional access packages, and conduct long-term malicious activities while remaining undetected. \n\n**Remediation action**\n\n- [Configure expiration settings for access packages](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-lifecycle-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#specify-a-lifecycle)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "21774",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "Microsoft services applications don't have credentials configured",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo Microsoft services applications have credentials configured in the tenant.\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Microsoft services applications that operate in your tenant are identified as service principals with the owner organization ID \"f8cdef31-a31e-4b4a-93e4-5f571e91255a.\" When these service principals have credentials configured in your tenant, they might create potential attack vectors that threat actors can exploit. If an administrator added the credentials and they're no longer needed, they can become a target for attackers. Although less likely when proper preventive and detective controls are in place on privileged activities, threat actors can also maliciously add credentials. In either case, threat actors can use these credentials to authenticate as the service principal, gaining the same permissions and access rights as the Microsoft service application. This initial access can lead to privilege escalation if the application has high-level permissions, allowing lateral movement across the tenant. Attackers can then proceed to data exfiltration or persistence establishment through creating other backdoor credentials.\n\nWhen credentials (like client secrets or certificates) are configured for these service principals in your tenant, it means someone - either an administrator or a malicious actor - enabled them to authenticate independently within your environment. These credentials should be investigated to determine their legitimacy and necessity. If they're no longer needed, they should be removed to reduce the risk. \n\nIf this check doesn't pass, the recommendation is to \"investigate\" because you need to identify and review any applications with unused credentials configured.\n\n**Remediation action**\n\n- Confirm if the credentials added are still valid use cases. If not, remove credentials from Microsoft service applications to reduce security risk. \n    - In the Microsoft Entra admin center, browse to **Entra ID** > **App registrations** and select the affected application.\n    - Go to the **Certificates & secrets** section and remove any credentials that are no longer needed.\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "24802",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Device cleanup rules maintain tenant hygiene by hiding inactive devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo device clean-up rule exists.\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Low",
      "TestDescription": "If device cleanup rules aren't configured in Intune, stale or inactive devices can remain visible in the tenant indefinitely. This leads to cluttered device lists, inaccurate reporting, and reduced visibility into the active device landscape. Unused devices might retain access credentials or tokens, increasing the risk of unauthorized access or misinformed policy decisions. \n\nDevice cleanup rules automatically hide inactive devices from admin views and reports, improving tenant hygiene and reducing administrative burden. This supports Zero Trust by maintaining an accurate and trustworthy device inventory while preserving historical data for audit or investigation.\n\n**Remediation action**\n\nConfigure Intune device cleanup rules to automatically hide inactive devices from the tenant:  \n- [Create a device cleanup rule](https://learn.microsoft.com/intune/intune-service/fundamentals/device-cleanup-rules?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-to-create-a-device-cleanup-rule)\n\nFor more information, see:  \n- [Using Intune device cleanup rules](https://techcommunity.microsoft.com/blog/devicemanagementmicrosoft/using-intune-device-cleanup-rules-updated-version/3760854) *on the Microsoft Tech Community blog*\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.6",
      "ZtmmFunctionName": "Automation and orchestration"
    },
    {
      "TestId": "21893",
      "TestMinimumLicense": "P2",
      "TestCategory": "Access control",
      "TestTitle": "All users are required to register for MFA",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Low",
      "TestDescription": "Require multifactor authentication (MFA) registration for all users. Based on studies, your account is more than 99% less likely to be compromised if you're using MFA. Even if you don't require MFA all the time, this policy ensures your users are ready when it's needed.\n\n**Remediation action**\n\n- [Configure the multifactor authentication registration policy](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-configure-mfa-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "21882",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "No nested groups in PIM for groups",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Creating filtering policies without linking them to a security profile or the baseline profile leaves them unenforced. Policies must be associated with either the baseline profile (applies to all internet traffic) or a security profile (applies through Conditional Access) to take effect. Unlinked policies provide no protection and create false confidence in your security posture.\n\n**Remediation action**\n\n- [Create security profiles and link filtering policies](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-web-content-filtering?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-security-profile)\n",
      "TestTitle": "Web content filtering policies are linked to security profiles",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25410",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Failed"
    },
    {
      "TestId": "24823",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Company Portal branding and support settings enhance user experience and trust",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo Company Portal branding profile with support settings exists or none are assigned.\n\n\n## Company Portal Branding Profiles\n\n| Profile Name | Branding Properties | Status | Assignment Target |\n| :----------- | :------------------ | :----- | :---------------- |\n| [Default Branding profile.](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/TenantAdminMenu/~/companyPortalBranding) | **Display Name**: Pora Labs Inc., **Contact Phone**: Not configured, **Contact Email**: merill@elapora.com | N/A | N/A |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "If the Intune Company Portal branding isn't configured to represent your organization’s details, users can encounter a generic interface and lack direct support information. This reduces user trust, increases support overhead, and can lead to confusion or delays in resolving issues.\n\nCustomizing the Company Portal with your organization’s branding and support contact details improves user trust, streamlines support, and reinforces the legitimacy of device management communications.\n\n\n**Remediation action**\n\nConfigure the Intune Company Portal with your organization’s branding and support contact information to enhance user experience and reduce support overhead:  \n- [Configure the Intune Company Portal](https://learn.microsoft.com/intune/intune-service/apps/company-portal-app?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Without mail flow rules, organizations depend on users to manually apply sensitivity labels or encrypt messages. This approach can lead to inconsistencies and errors, which may result in sensitive emails being sent without proper protection and increase the risk of unauthorized access and data exfiltration.\n\nMail flow rules help automatically add encryption and set permissions for emails that meet certain conditions, such as:\n- Mail sent to people outside the company  \n- Mail that contains sensitive information  \n- Mail that must follow department-based requirements  \nThis ensures that important messages are protected without relying on users to manually secure them.\n\n**Remediation action**\n\n- [Set up Message Encryption and mail flow rules to use Microsoft Purview Message Encryption](https://learn.microsoft.com/purview/set-up-new-message-encryption-capabilities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#next-steps-define-mail-flow-rules-to-use-microsoft-purview-message-encryption)\n",
      "TestTitle": "Mail flow rules apply rights protection to sensitive messages",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"ExchangeOnline\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Information Protection",
      "TestId": "35029",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21815",
      "TestMinimumLicense": "P2",
      "TestCategory": "Privileged access",
      "TestTitle": "All privileged role assignments are activated just in time and not permanently active",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nPrivileged users with permanent role assignments were found.\n\n\n## Privileged users with permanent role assignments\n\n\n| User | UPN | Role Name | Assignment Type |\n| :--- | :-- | :-------- | :-------------- |\n| [Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | GradyA@elapora.com | User Administrator | Permanent |\n| [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | emergency@elapora.com | Global Administrator | Permanent |\n| [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | aleksandar@elapora.com | Global Administrator | Permanent |\n| [Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | ravi.kalwani@elapora.com | Global Administrator | Permanent |\n| [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | joshua@elapora.com | Global Administrator | Permanent |\n| [komal-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | komal-test@elapora.com | Global Reader | Permanent |\n| [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | tyler@elapora.com | Global Administrator | Permanent |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | perennial_ash@elapora.com | Global Administrator | Permanent |\n| [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | gael@elapora.com | Global Administrator | Permanent |\n| [Afif Ahmed](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | AfifAhmed@elapora.com | Global Administrator | Permanent |\n| [Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | Manoj.Kesana@elapora.com | Global Reader | Permanent |\n| [Aahmed Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | aahmed-test@elapora.com | Global Reader | Permanent |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | chukka.p@elapora.com | Global Reader | Permanent |\n| [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | ann@elapora.com | Global Administrator | Permanent |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | sandeep.p@elapora.com | Global Administrator | Permanent |\n| [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | merill@elapora.com | Global Administrator | Permanent |\n| [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | chukka.p@elapora.com | Global Administrator | Permanent |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | perennial_ash@elapora.com | Application Administrator | Permanent |\n| [ash-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | ash-test@elapora.com | Global Reader | Permanent |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | Komal.p@elapora.com | Global Reader | Permanent |\n| [Afif](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | afif.p@elapora.com | Global Reader | Permanent |\n| [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) |  | Global Administrator | Permanent |\n| [Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | varsha.mane@elapora.com | Global Administrator | Permanent |\n| [manoj-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | manoj-test@elapora.com | Global Reader | Permanent |\n| [Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | jackief@elapora.com | Global Administrator | Permanent |\n| [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | damien.bowden@elapora.com | Global Administrator | Permanent |\n| [PimLevel](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) |  | Application Administrator | Permanent |\n| [Ty Grady Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | tygradytest@elapora.com | Global Administrator | Permanent |\n| [praneeth-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | praneeth-test@elapora.com | Global Reader | Permanent |\n| [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | sandeep.p@elapora.com | Global Reader | Permanent |\n| [Ty Grady](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | Tyler.GradyTaylor_microsoft.com#EXT#@pora.onmicrosoft.com | Global Administrator | Permanent |\n| [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | Komal.p@elapora.com | Global Administrator | Permanent |\n| [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) |  | Application Administrator | Permanent |\n| [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | madura@elapora.com | Global Administrator | Permanent |\n| [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | perennial_ash@elapora.com | Global Reader | Permanent |\n| [Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) | Manoj.Kesana@elapora.com | Global Administrator | Permanent |\n| [elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId//hidePreviewBanner~/true) |  | Global Administrator | Permanent |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "Threat actors target privileged accounts because they have access to the data and resources they want. This might include more access to your Microsoft Entra tenant, data in Microsoft SharePoint, or the ability to establish long-term persistence. Without a just-in-time (JIT) activation model, administrative privileges remain continuously exposed, providing attackers with an extended window to operate undetected. Just-in-time access mitigates risk by enforcing time-limited privilege activation with extra controls such as approvals, justification, and Conditional Access policy, ensuring that high-risk permissions are granted only when needed and for a limited duration. This restriction minimizes the attack surface, disrupts lateral movement, and forces adversaries to trigger actions that can be specially monitored and denied when not expected. Without just-in-time access, compromised admin accounts grant indefinite control, letting attackers disable security controls, erase logs, and maintain stealth, amplifying the impact of a compromise.\n\nUse Microsoft Entra Privileged Identity Management (PIM) to provide time-bound just-in-time access to privileged role assignments. Use access reviews in Microsoft Entra ID Governance to regularly review privileged access to ensure continued need.\n\n**Remediation action**\n\n- [Start using Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-getting-started?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create an access review of Azure resource and Microsoft Entra roles in PIM](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-create-roles-and-resource-roles-review?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "21787",
      "TestMinimumLicense": "Free",
      "TestCategory": "Privileged access",
      "TestTitle": "Permissions to create new tenants are limited to the Tenant Creator role",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNon-privileged users are restricted from creating tenants.\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "A threat actor or a well-intentioned but uninformed employee can create a new Microsoft Entra tenant if there are no restrictions in place. By default, the user who creates a tenant is automatically assigned the Global Administrator role. Without proper controls, this action fractures the identity perimeter by creating a tenant outside the organization's governance and visibility. It introduces risk though a shadow identity platform that can be exploited for token issuance, brand impersonation, consent phishing, or persistent staging infrastructure. Since the rogue tenant might not be tethered to the enterprise’s administrative or monitoring planes, traditional defenses are blind to its creation, activity, and potential misuse.\n\n**Remediation action**\n\nEnable the **Restrict non-admin users from creating tenants** setting. For users that need the ability to create tenants, assign them the Tenant Creator role. You can also review tenant creation events in the Microsoft Entra audit logs.\n\n- [Restrict member users' default permissions](https://learn.microsoft.com/entra/fundamentals/users-default-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#restrict-member-users-default-permissions)\n- [Assign the Tenant Creator role](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#tenant-creator)\n- [Review tenant creation events](https://learn.microsoft.com/entra/identity/monitoring-health/reference-audit-activities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#core-directory). Look for OperationName==\"Create Company\", Category == \"DirectoryManagement\".\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "When you connect remote networks to Global Secure Access through IPsec tunnels but don't set up cloud firewall policies, all internet-bound traffic from branch offices goes through the Security Service Edge without egress filtering controls. If a threat actor gains access to a branch office workstation, they can make outbound connections to command-and-control infrastructure, exfiltrate data over standard ports, or download malicious payloads without network-layer inspection.\n\nWithout Global Secure Access cloud firewall:\n\n- You can't enforce a deny-by-default posture or restrict outbound communications from branch networks to unauthorized internet destinations.\n- Threat actors can stage data for exfiltration, pivot to cloud resources, or move laterally without detection.\n- Traditional perimeter defenses might assume all egress is legitimate, resulting in gaps in security coverage.\n\nCloud firewall policies linked to the baseline profile provide centralized egress control for all remote network traffic. Administrators can use these policies to define granular filtering rules that restrict unauthorized outbound communications.\n\n**Remediation action**\n\n- As a prerequisite for cloud firewall, [configure remote networks for internet access](https://learn.microsoft.com/entra/global-secure-access/how-to-create-remote-networks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Follow the steps in [Configure Global Secure Access cloud firewall](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-cloud-firewall?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to:\n    - Create a cloud firewall policy with appropriate filtering rules.\n    - Add or update firewall rules based on source IP, destination IP, ports, and protocols.\n    - Link the cloud firewall policy to the baseline profile for remote networks.\n",
      "TestTitle": "Global Secure Access cloud firewall protects branch office internet traffic",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25416",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Passed"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "The SimplifiedClientAccessEnabled setting controls whether the Protect button appears in Outlook on the web. This button lets users quickly add encryption to their emails. If the setting is not turned on, users cannot use the Protect button and must find other ways to encrypt their messages.\n\nTo enable this setting, AzureRMSLicensingEnabled must also be active. Azure Rights Management encryption service provides the encryption technology needed for the Protect button to work.\n\n**Remediation action**\n\n- [Manage the display of the Encrypt button in Outlook on the web](https://learn.microsoft.com/purview/manage-office-365-message-encryption?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#manage-the-display-of-the-encrypt-button-in-outlook-on-the-web)\n",
      "TestTitle": "Microsoft Purview Message Encryption is configured with simplified client access",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"ExchangeOnline\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Microsoft Purview Message Encryption",
      "TestId": "35026",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data labeling and tagging",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21899",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "All privileged role assignments have a recipient that can receive notifications",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": 21825,
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Privileged users have short-lived sign-in sessions",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n## Privileged User Sign-In Sessions\n\n**Total Privileged Roles Found:** 31\n\n**CA Policies Targeting Roles:** 9\n\n**Recommended Sign In Session Hours:** 4\n\n**Policies with Compliant Frequency (≤4 hours):** 1\n\n### Conditional Access Policies by Privileged Role\n\n#### Global Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### User Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Helpdesk Administrator\n\n**Status:** ✅ Covered\n\n| Policy Name | Sign-In Frequency | Compliant |\n| :--- | :--- | :--- |\n| [j-test admin](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6c0ef46a-3b58-43a9-b451-7464a16d91d7) | 1 hours | ✅ |\n\n#### Partner Tier1 Support\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Partner Tier2 Support\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Directory Writers\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Application Administrator\n\n**Status:** ✅ Covered\n\n| Policy Name | Sign-In Frequency | Compliant |\n| :--- | :--- | :--- |\n| [j-test admin](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6c0ef46a-3b58-43a9-b451-7464a16d91d7) | 1 hours | ✅ |\n\n#### Application Developer\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Security Reader\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Security Administrator\n\n**Status:** ✅ Covered\n\n| Policy Name | Sign-In Frequency | Compliant |\n| :--- | :--- | :--- |\n| [j-test admin](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6c0ef46a-3b58-43a9-b451-7464a16d91d7) | 1 hours | ✅ |\n\n#### Privileged Role Administrator\n\n**Status:** ✅ Covered\n\n| Policy Name | Sign-In Frequency | Compliant |\n| :--- | :--- | :--- |\n| [j-test admin](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6c0ef46a-3b58-43a9-b451-7464a16d91d7) | 1 hours | ✅ |\n\n#### Intune Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Cloud Application Administrator\n\n**Status:** ✅ Covered\n\n| Policy Name | Sign-In Frequency | Compliant |\n| :--- | :--- | :--- |\n| [j-test admin](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6c0ef46a-3b58-43a9-b451-7464a16d91d7) | 1 hours | ✅ |\n\n#### Conditional Access Administrator\n\n**Status:** ✅ Covered\n\n| Policy Name | Sign-In Frequency | Compliant |\n| :--- | :--- | :--- |\n| [j-test admin](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6c0ef46a-3b58-43a9-b451-7464a16d91d7) | 1 hours | ✅ |\n\n#### Cloud Device Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Authentication Administrator\n\n**Status:** ✅ Covered\n\n| Policy Name | Sign-In Frequency | Compliant |\n| :--- | :--- | :--- |\n| [j-test admin](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6c0ef46a-3b58-43a9-b451-7464a16d91d7) | 1 hours | ✅ |\n\n#### Privileged Authentication Administrator\n\n**Status:** ✅ Covered\n\n| Policy Name | Sign-In Frequency | Compliant |\n| :--- | :--- | :--- |\n| [j-test admin](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6c0ef46a-3b58-43a9-b451-7464a16d91d7) | 1 hours | ✅ |\n\n#### B2C IEF Keyset Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### External Identity Provider Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Security Operator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Global Reader\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Password Administrator\n\n**Status:** ✅ Covered\n\n| Policy Name | Sign-In Frequency | Compliant |\n| :--- | :--- | :--- |\n| [j-test admin](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/6c0ef46a-3b58-43a9-b451-7464a16d91d7) | 1 hours | ✅ |\n\n#### Hybrid Identity Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Domain Name Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### AI Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Authentication Extensibility Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Lifecycle Workflows Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Attribute Provisioning Reader\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Attribute Provisioning Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### Authentication Extensibility Password Administrator\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n#### ExamStudyTest\n\n**Status:** ❌ No CA policies assigned\n\n*No Conditional Access policies target this privileged role.*\n\n❌ **Not all privileged roles are covered by compliant sign-in frequency controls.**\n\n**Recommendation:** Configure Conditional Access policies to enforce sign-in frequency of 4 hours or less for ALL privileged roles.\n\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "When privileged users are allowed to maintain long-lived sign-in sessions without periodic reauthentication, threat actors can gain extended windows of opportunity to exploit compromised credentials or hijack active sessions. Once a privileged account is compromised through techniques like credential theft, phishing, or session fixation, extended session timeouts allow threat actors to maintain persistence within the environment for prolonged periods. With long-lived sessions, threat actors can perform lateral movement across systems, escalate privileges further, and access sensitive resources without triggering another authentication challenge. The extended session duration also increases the window for session hijacking attacks, where threat actors can steal session tokens and impersonate the privileged user. Once a threat actor is established in a privileged session, they can:\n\n- Create backdoor accounts\n- Modify security policies\n- Access sensitive data\n- Establish more persistence mechanisms\n\nThe lack of periodic reauthentication requirements means that even if the original compromise is detected, the threat actor might continue operating undetected using the hijacked privileged session until the session naturally expires or the user manually signs out.\n\n**Remediation action**\n\n- [Learn about Conditional Access adaptive session lifetime policies](https://learn.microsoft.com/entra/identity/conditional-access/concept-session-lifetime?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure sign-in frequency for privileged users with Conditional Access policies ](https://learn.microsoft.com/entra/identity/conditional-access/howto-conditional-access-session-lifetime?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": "25533",
      "TestMinimumLicense": [
        "DDoS_Network_Protection",
        "DDoS_IP_Protection"
      ],
      "TestCategory": "Azure Network Security",
      "TestTitle": "DDoS Protection is enabled for all Public IP Addresses in VNETs",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "DDoS attacks remain a major security and availability risk for customers with cloud-hosted applications. These attacks aim to overwhelm an application's compute, network, or memory resources, rendering it inaccessible to legitimate users. Any public-facing endpoint exposed to the internet can be a potential target for a DDoS attack. Azure DDoS Protection provides always-on monitoring and automatic mitigation against DDoS attacks targeting public-facing workloads.\n\nWithout Azure DDoS Protection (Network Protection or IP Protection), public IP addresses for services such as Application Gateways, Load Balancers, Azure Firewalls, Azure Bastion, Virtual Network Gateways, or virtual machines remain exposed to DDoS attacks that can overwhelm network bandwidth, exhaust system resources, and cause complete service unavailability. These attacks can disrupt access for legitimate users, degrade performance, and create cascading outages across dependent services.\n\nAzure DDoS Protection can be enabled in two ways:\n\n- DDoS IP Protection — Protection is explicitly enabled on individual public IP addresses by setting ddosSettings.protectionMode to Enabled.\n- DDoS Network Protection — Protection is enabled at the VNET level through a DDoS Protection Plan. Public IP addresses associated with resources in that VNET inherit the protection when ddosSettings.protectionMode is set to VirtualNetworkInherited. However, a public IP address with VirtualNetworkInherited is not protected unless the VNET actually has a DDoS Protection Plan associated and enableDdosProtection set to true.\nThis check verifies that every public IP address is actually covered by DDoS protection, either through DDoS IP Protection enabled directly on the public IP, or through DDoS Network Protection enabled on the VNET that the public IP's associated resource resides in. If this check does not pass, your workloads remain significantly more vulnerable to downtime, customer impact, and operational disruption during an attack.\n\n**Remediation action**\n\nTo enable DDoS Protection for public IP addresses, refer to the following Microsoft Learn documentation:\n\n- [Azure DDoS Protection overview](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview)\n- [Quickstart: Create and configure Azure DDoS Network Protection using Azure portal](https://learn.microsoft.com/en-us/azure/ddos-protection/manage-ddos-protection)\n- [Quickstart: Create and configure Azure DDoS IP Protection using Azure portal](https://learn.microsoft.com/en-us/azure/ddos-protection/manage-ddos-ip-protection-portal)\n- [Azure DDoS Protection SKU comparison](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-sku-comparison)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "If you don't deploy Microsoft Entra Private Access sensors to domain controllers, threat actors can exploit Kerberos authentication requests from any device on the network, including unmanaged or compromised endpoints. They can use this vulnerability to get service tickets for on-premises resources without multifactor authentication or device compliance validation.\n\nIf you don't deploy Private Access sensors to domain controllers:\n\n- Threat actors can request Kerberos tickets for privileged resources such as file shares, database servers, and remote desktop services. This vulnerability enables lateral movement across the on-premises environment.\n- Conditional Access policies don't apply to Kerberos authentication, because it operates within a perimeter-based trust model where any authenticated user can request tickets regardless of authentication strength or device posture.\n- Compromised user credentials obtained through phishing or credential theft can be immediately used to access domain-authenticated resources without triggering multifactor authentication requirements.\n\n**Remediation action**\n\n- [Configure Microsoft Entra Private Access for Active Directory domain controllers](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-domain-controllers?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Private Access sensors are enforcing strong authentication policies on domain controllers",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25403",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management",
      "TestStatus": "Passed"
    },
    {
      "TestId": "25550",
      "TestMinimumLicense": "Azure_Firewall_Premium",
      "TestCategory": "Azure Network Security",
      "TestTitle": "Inspection of Outbound TLS Traffic is Enabled on Azure Firewall",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Firewall Premium offers Transport Layer Security (TLS) inspection to decrypt and inspect outbound and east-west TLS traffic, and inbound TLS traffic when used with Azure Application Gateway. TLS inspection is critical for detecting advanced threats that use encrypted channels to evade traditional security controls.\n\nWhen TLS inspection is enabled, Azure Firewall uses a customer-provided CA certificate stored in Azure Key Vault to decrypt, inspect, and then re-encrypt traffic before forwarding it to its destination. This enables advanced security capabilities such as IDPS and URL filtering to analyze encrypted traffic and identify malicious activity that would otherwise remain hidden.\n\nThis check verifies that Azure Firewall Premium has TLS inspection enabled. Without TLS inspection, the firewall cannot inspect encrypted payloads, significantly limiting visibility into threats that leverage TLS to evade detection.\n\n**Remediation action**\n\n- [Azure Firewall Premium features implementation guide](https://learn.microsoft.com/en-us/azure/firewall/premium-features)\n- [Deploy and configure Enterprise CA certificates for Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/premium-deploy-certificates-enterprise-ca)\n- [Azure Firewall Premium certificates](https://learn.microsoft.com/en-us/azure/firewall/premium-certificates)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": "21803",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Migrate from legacy MFA and SSPR policies",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nCombined registration is enabled.\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Legacy multifactor authentication (MFA) and self-service password reset (SSPR) policies in Microsoft Entra ID manage authentication methods separately, leading to fragmented configurations and suboptimal user experience. Moreover, managing these policies independently increases administrative overhead and the risk of misconfiguration.  \n\nMigrating to the combined Authentication Methods policy consolidates the management of MFA, SSPR, and passwordless authentication methods into a single policy framework. This unification allows for more granular control, enabling administrators to target specific authentication methods to user groups and enforce consistent security measures across the organization. Additionally, the unified policy supports modern authentication methods, such as FIDO2 security keys and Windows Hello for Business, enhancing the organization's security posture.\n\nMicrosoft announced the deprecation of legacy MFA and SSPR policies, with a retirement date set for September 30, 2025. Organizations are advised to complete the migration to the Authentication Methods policy before this date to avoid potential disruptions and to benefit from the enhanced security and management capabilities of the unified policy.\n\n**Remediation action**\n\n- [Enable combined security information registration](https://learn.microsoft.com/entra/identity/authentication/howto-registration-mfa-sspr-combined?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [How to migrate MFA and SSPR policy settings to the Authentication methods policy for Microsoft Entra ID](https://learn.microsoft.com/entra/identity/authentication/how-to-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.2",
      "ZtmmFunctionName": "Identity Stores"
    },
    {
      "TestId": "21811",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Password expiration is disabled",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nPassword expiration is properly disabled across all domains and users.\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "When password expiration policies remain enabled, threat actors can exploit the predictable password rotation patterns that users typically follow when forced to change passwords regularly. Users frequently create weaker passwords by making minimal modifications to existing ones, such as incrementing numbers or adding sequential characters. Threat actors can easily anticipate and exploit these types of changes through credential stuffing attacks or targeted password spraying campaigns. These predictable patterns enable threat actors to establish persistence through:\n\n- Compromised credentials\n- Escalated privileges by targeting administrative accounts with weak rotated passwords\n- Maintaining long-term access by predicting future password variations\n\nResearch shows that users create weaker, more predictable passwords when they are forced to expire. These predictable passwords are easier for experienced attackers to crack, as they often make simple modifications to existing passwords rather than creating entirely new, strong passwords. Additionally, when users are required to frequently change passwords, they might resort to insecure practices such as writing down passwords or storing them in easily accessible locations, creating more attack vectors for threat actors to exploit during physical reconnaissance or social engineering campaigns. \n\n**Remediation action**\n\n- [Set the password expiration policy for your organization](https://learn.microsoft.com/microsoft-365/admin/manage/set-password-expiration-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n    - Sign in to the [Microsoft 365 admin center](https://admin.microsoft.com/). Go to **Settings** > **Org Settings** >** Security & Privacy** > **Password expiration policy**. Ensure the **Set passwords to never expire** setting is checked.\n- [Disable password expiration using Microsoft Graph](https://learn.microsoft.com/graph/api/domain-update?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- [Set individual user passwords to never expire using Microsoft Graph PowerShell](https://learn.microsoft.com/microsoft-365/admin/add-users/set-password-to-never-expire?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - `Update-MgUser -UserId <UserID> -PasswordPolicies DisablePasswordExpiration`\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Universal Continuous Access Evaluation (Universal CAE) validates network access tokens every time a connection is established through Global Secure Access tunnels. Without Universal CAE, tokens remain valid for 60 to 90 minutes regardless of changes to user state.\n\nWithout this protection:\n\n- A threat actor who obtains a token through theft or replay can continue accessing all Global Secure Access-protected resources even after the user's account is disabled or password is reset.\n- Critical events like session revocation or high user risk detection don't prompt immediate reauthentication.\n- Departing employees or malicious insiders maintain network-level access to private corporate resources for up to 90 minutes after remediation action is taken.\n- Token replay attacks from different IP addresses aren't blocked without Strict Enforcement mode.\n\n**Remediation action**\n- Review the [Universal CAE](https://learn.microsoft.com/entra/global-secure-access/concept-universal-continuous-access-evaluation?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) capabilities for Global Secure Access.\n- Remove or modify Conditional Access policies that disable CAE for Global Secure Access workloads. For more information, see [Continuous access evaluation](https://learn.microsoft.com/entra/identity/conditional-access/concept-continuous-access-evaluation?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Configure Universal CAE to use Strict Enforcement mode for enhanced token replay protection. For more information, see [Universal Continuous Access Evaluation](https://learn.microsoft.com/entra/global-secure-access/concept-universal-continuous-access-evaluation?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#strict-enforcement-mode).\n",
      "TestTitle": "Network validation is configured through Universal Continuous Access Evaluation",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\") OR (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access",
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25371",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21863",
      "TestMinimumLicense": "P2",
      "TestCategory": "Monitoring",
      "TestTitle": "All high-risk sign-ins are triaged",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo untriaged risky sign ins in the tenant.\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "Risky sign-ins flagged by Microsoft Entra ID Protection indicate a high probability of unauthorized access attempts. Threat actors use these sign-ins to gain an initial foothold. If these sign-ins remain uninvestigated, adversaries can establish persistence by repeatedly authenticating under the guise of legitimate users. \n\nA lack of response lets attackers execute reconnaissance, attempt to escalate their access, and blend into normal patterns. When untriaged sign-ins continue to generate alerts and there's no intervention, security gaps widen, facilitating lateral movement and defense evasion, as adversaries recognize the absence of an active security response.\n\n**Remediation action**\n\n- [Investigate risky sign-ins](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Remediate risks and unblock users](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-remediate-unblock?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.3",
      "ZtmmFunctionName": "Risk Assessments"
    },
    {
      "TestId": "21857",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "Guest identities are lifecycle managed with access reviews",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21797",
      "TestMinimumLicense": "P2",
      "TestCategory": "Access control",
      "TestTitle": "Restrict access to high risk users",
      "TestSfiPillar": "Accelerate response and remediation",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nPasswordless authentication is enabled, but no policies to block high risk users are configured.\n## Passwordless Authentication Methods allowed in tenant\n\n| Authentication Method Name | State | Additional Info |\n| :------------------------ | :---- | :-------------- |\n| Fido2 | enabled |  |\n\n## Conditional Access Policies targeting high risk users\n\nNo conditional access policies targeting high risk users found.\n\n### Inactive policies targeting high risk users (not contributing to security posture):\n\n| Conditional Access Policy Name | Status | Conditions |\n| :--------------------- | :----- | :--------- |\n| [Require password change for high-risk users](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/ddbc3bb1-3749-474f-b8c3-0d997118b24b) | Report-only | User Risk Level: High, Control: Block |\n| [Force Password Change](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/5848211d-96f2-40ae-92a4-af1aa8f48572) | Disabled | User Risk Level: High, Control: Password Change |\n| [CISA SCuBA.MS.AAD.2.3: Users detected as high risk SHALL be blocked.](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/94c7d8d0-5c8c-460d-8ace-364374250893) | Report-only | User Risk Level: High, Control: Block |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Assume high risk users are compromised by threat actors. Without investigation and remediation, threat actors can execute scripts, deploy malicious applications, or manipulate API calls to establish persistence, based on the potentially compromised user's permissions. Threat actors can then exploit misconfigurations or abuse OAuth tokens to move laterally across workloads like documents, SaaS applications, or Azure resources. Threat actors can gain access to sensitive files, customer records, or proprietary code and exfiltrate it to external repositories while maintaining stealth through legitimate cloud services. Finally, threat actors might disrupt operations by modifying configurations, encrypting data for ransom, or using the stolen information for further attacks, resulting in financial, reputational, and regulatory consequences.\n\nOrganizations using passwords can rely on password reset to automatically remediate risky users.\n\nOrganizations using passwordless credentials already mitigate most risk events that accrue to user risk levels, thus the volume of risky users should be considerably lower. Risky users in an organization that uses passwordless credentials must be blocked from access until the user risk is investigated and remediated.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to require a secure password change for elevated user risk](https://learn.microsoft.com/entra/identity/conditional-access/policy-risk-based-user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Use Microsoft Entra ID Protection to [investigate risk further](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.3",
      "ZtmmFunctionName": "Risk Assessments"
    },
    {
      "TestId": "21789",
      "TestMinimumLicense": null,
      "TestCategory": "Monitoring",
      "TestTitle": "Tenant creation events are triaged",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Tenant creation events should be monitored and triaged to detect unauthorized tenant creation. Users with sufficient permissions can create new tenants, which could be used to establish shadow environments outside your organization's security monitoring. Routing audit logs to a SIEM and configuring alerts for tenant creation events enables security teams to quickly investigate and respond to potentially malicious activity.\n\n**Remediation action**\n\n- [Review and restrict permissions to create tenants](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Stream audit logs to an event hub for SIEM integration](https://learn.microsoft.com/entra/identity/monitoring-health/howto-stream-logs-to-event-hub?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure monitoring and alerting for audit events](https://learn.microsoft.com/entra/identity/monitoring-health/overview-monitoring-health?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.5",
      "ZtmmFunctionName": "Visibility & Analytics"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Until organizations use Insider Risk Management with Adaptive Protection, they could fail to detect insider threats, risky behaviors such as misuse of legitimate access to exfiltrate data, or unsafe AI scenarios where users expose sensitive data to large language models or unauthorized cloud AI services.\n\nInsider Risk Management works with Data Loss Prevention (DLP) to combine user behavior signals with content-based rules, helping teams detect risks early and respond before sensitive data is exposed or compromised.\n\n**Remediation action**\n\n- [Create and configure Insider Risk Management policies](https://learn.microsoft.com/purview/insider-risk-management-policies?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Help dynamically mitigate risks with Adaptive Protection](https://learn.microsoft.com/purview/insider-risk-management-adaptive-protection?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Insider Risk Management policies are enabled for risky AI usage",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Data Security Posture Management",
      "TestId": "35038",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data labeling and tagging",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21809",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "Admin consent workflow is enabled",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAdmin consent workflow is disabled.\n\nThe adminConsentRequestPolicy.isEnabled property is set to false.\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Enabling the Admin consent workflow in a Microsoft Entra tenant is a vital security measure that mitigates risks associated with unauthorized application access and privilege escalation. This check is important because it ensures that any application requesting elevated permission undergoes a review process by designated administrators before consent is granted. The admin consent workflow in Microsoft Entra ID notifies reviewers who evaluate and approve or deny consent requests based on the application's legitimacy and necessity. If this check doesn't pass, meaning the workflow is disabled, any application can request and potentially receive elevated permissions without administrative review. This poses a substantial security risk, as malicious actors could exploit this lack of oversight to gain unauthorized access to sensitive data, perform privilege escalation, or execute other malicious activities.\n\n**Remediation action**\n\nFor admin consent requests, set the **Users can request admin consent to apps they are unable to consent to** setting to **Yes**. Specify other settings, such as who can review requests.\n\n- [Enable the admin consent workflow](https://learn.microsoft.com/entra/identity/enterprise-apps/configure-admin-consent-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-the-admin-consent-workflow)\n- Or use the [Update adminConsentRequestPolicy](https://learn.microsoft.com/graph/api/adminconsentrequestpolicy-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) API to set the `isEnabled` property to true and other settings\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "21868",
      "TestMinimumLicense": "Free",
      "TestCategory": "External collaboration",
      "TestTitle": "Guests don't own apps in the tenant",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo guest users own any applications or service principals in the tenant.\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Without restrictions preventing guest users from registering and owning applications, threat actors can exploit external user accounts to establish persistent backdoor access to organizational resources through application registrations that might evade traditional security monitoring. When guest users own applications, compromised guest accounts can be used to exploit guest-owned applications that might have broad permissions. This vulnerability enables threat actors to request access to sensitive organizational data such as emails, files, and user information without the same level of scrutiny for internal user-owned applications.\n\nThis attack vector is dangerous because guest-owned applications can be configured to request high-privilege permissions and, once granted consent, provide threat actors with legitimate OAuth tokens. Furthermore, guest-owned applications can serve as command and control infrastructure, so threat actors can maintain access even after the compromised guest account is detected and remediated. Application credentials and permissions might persist independently of the original guest user account, so threat actors can retain access. Guest-owned applications also complicate security auditing and governance efforts, as organizations might have limited visibility into the purpose and security posture of applications registered by external users. These hidden weaknesses in the application lifecycle management make it difficult to assess the true scope of data access granted to non-Microsoft entities through seemingly legitimate application registrations.\n\n**Remediation action**\n- Remove guest users as owners from applications and service principals, and implement controls to prevent future guest user application ownership.\n- [Restrict guest user access permissions](https://learn.microsoft.com/entra/identity/users/users-restrict-guest-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21834",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "Directory sync account is locked down to specific named location",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "21929",
      "TestMinimumLicense": [
        "P2",
        "Governance"
      ],
      "TestCategory": "Identity governance",
      "TestTitle": "All entitlement management packages that apply to guests have expirations or access reviews configured in their assignment policies",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAccess package assignment policies without expiration and without access reviews were found for external users.\n\n## [Access package assignment policies for external users](https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlement)\n\n| Access package | Assignment policy | Expiry configured | Access review configured | Status |\n| :------------- | :---------------- | :------------------ | :--------------------- | :----- |\n| PS-GraphCmdLetScriptTest4 | External | No | No | ❌ Non-compliant |\n| Get user info demo | Initial Policy | Yes | No | ✅ Compliant |\n| PS-GraphCmdLetScriptTest4 | 21929Test | No | Yes | ✅ Compliant |\n| UserInfo | Initial Policy | Yes | No | ✅ Compliant |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Access packages for guest users without expiration dates or access reviews allow indefinite access to organizational resources. Compromised or stale guest accounts enable threat actors to maintain persistent, undetected access for lateral movement, privilege escalation, and data exfiltration. Without periodic validation, organizations cannot identify when business relationships change or when guest access is no longer needed. \n\n**Remediation action**\n\n- [Configure lifecycle settings](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-lifecycle-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure access reviews](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-reviews-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Trainable classifiers are machine learning-based classifiers that recognize content by meaning and context rather than fixed patterns. Unlike sensitive information types that match predefined formats, trainable classifiers can identify unstructured content like strategic plans, financial reports, or HR documents. Using trainable classifiers in auto-labeling policies, and data loss prevention (DLP) rules, extends protection to sensitive business content that pattern-based rules can't reliably capture.\n\n**Remediation action**\n\n- [Learn about trainable classifiers](https://learn.microsoft.com/purview/classifier-learn-about?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with trainable classifiers](https://learn.microsoft.com/purview/trainable-classifiers-get-started-with?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Trainable classifiers are used in data loss prevention and auto-labeling policies",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "High",
      "TestSkipped": "",
      "TestCategory": "Advanced Classification",
      "TestId": "35036",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Passed"
    },
    {
      "TestId": "27018",
      "TestMinimumLicense": "Azure_WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "Rate Limiting is Enabled in Azure Front Door WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Azure Front Door Web Application Firewall (WAF) supports rate limiting through custom rules that restrict the number of requests clients can make within a specified time window across the global edge network. Rate limiting is a critical defense mechanism that protects applications from abuse by throttling clients that exceed defined request thresholds before traffic reaches origin servers.\n\nWithout rate limiting configured, threat actors can execute brute force attacks, credential stuffing attacks, API abuse, and application-layer denial of service attacks that flood endpoints with requests to exhaust server capacity.\n\nRate limiting rules use the `RateLimitRule` rule type and allow administrators to define thresholds based on request count per minute, with the ability to group requests by client IP address. When a client exceeds the configured threshold, the WAF can block subsequent requests, log the violation, issue a CAPTCHA challenge, or redirect to a custom page.\n\nThis check identifies Azure Front Door WAF policies that are attached to an Azure Front Door and verifies that at least one rate limiting rule is configured and enabled.\n\n**Remediation action**\n\n- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)\n- [Web Application Firewall custom rules for Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-custom-rules)\n- [Rate limiting for Azure Front Door WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-rate-limit)\n- [Tutorial: Create a Web Application Firewall policy on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-create-portal)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption"
    },
    {
      "TestId": "27020",
      "TestMinimumLicense": "Azure WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "CAPTCHA challenge is enabled in Azure Front Door WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Azure Front Door Web Application Firewall (WAF) supports CAPTCHA challenge as a defense mechanism against sophisticated bots and automated tools across the global edge network. CAPTCHA challenge works by presenting users with a visual or audio puzzle that requires human cognitive ability to solve, proving that the request originates from a real human rather than an automated bot or script. When a request triggers a CAPTCHA challenge, the WAF responds with a challenge page containing the CAPTCHA puzzle that the user must solve to obtain a valid challenge cookie. If the user successfully completes the CAPTCHA, subsequent requests proceed normally until the cookie expires. Bots and automated tools that cannot solve the CAPTCHA puzzle are blocked from accessing protected resources at the edge before traffic reaches origin servers. CAPTCHA challenge is more effective than JavaScript challenge against advanced bots that use headless browsers with full JavaScript support, as it requires human-level cognition to pass. The `captchaExpirationInMinutes` setting in the policy controls how long the CAPTCHA cookie remains valid before the user must complete another challenge. CAPTCHA challenge provides the strongest level of interactive verification available in Azure Front Door WAF—it confirms human presence through an interactive puzzle rather than only verifying browser capability like JavaScript challenge. By configuring custom rules with CAPTCHA challenge action on Azure Front Door WAF, organizations can protect highly sensitive endpoints like login pages, registration forms, password reset flows, and payment pages from automated abuse while ensuring that only verified humans can access these resources across globally distributed edge locations.\n\n**Remediation action**\n\n- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)\n- [Web Application Firewall custom rules for Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-custom-rules)\n- [Tutorial: Create a Web Application Firewall policy on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-create-portal)\n- [Configure CAPTCHA challenge for Azure Front Door WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-tuning#captcha-challenge)\n\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestRisk": "Low",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestDescription": "When co-authoring isn't enabled for documents protected by sensitivity labels that apply encryption, only one person can edit the file at a time when they use Office desktop apps. As a result, this can slow down teams, which makes collaboration difficult and can delay project completion. This limitation is especially challenging for groups working on sensitive projects that require encryption for privacy but also need to work together efficiently.\n\nTurning on co-authoring for files encrypted with sensitivity labels lets several authorized users edit the file at the same time in Office desktop apps. Unless you can ensure that all users edit these files by using Office for the web, this change removes the slowdown of requiring checkout and allows teams to efficiently collaborate without sacrificing security. The co-authoring setting might also be a requirement for other labeling features.\n\n**Remediation action**\n\n- [Enable co-authoring for files encrypted with sensitivity labels](https://learn.microsoft.com/purview/sensitivity-labels-coauthoring?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Co-authoring is enabled for files encrypted with sensitivity labels",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "NotConnectedToService",
      "TestCategory": "Sensitivity Labels",
      "TestId": "35009",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Skipped"
    },
    {
      "TestId": "21830",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "Conditional Access policies for Privileged Access Workstations are configured",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nNo Conditional Access policies found that restrict privileged roles to PAW device.\n\n**❌ Found 0 policy(s) with compliant device control targeting all privileged roles**\n\n\n**❌ Found 0 policy(s) with PAW/SAW device filter targeting all privileged roles**\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "If privileged role activations aren't restricted to dedicated Privileged Access Workstations (PAWs), threat actors can exploit compromised endpoint devices to perform privileged escalation attacks from unmanaged or noncompliant workstations. Standard productivity workstations often contain attack vectors such as unrestricted web browsing, email clients vulnerable to phishing, and locally installed applications with potential vulnerabilities. When administrators activated privileged roles from these workstations, threat actors who gain initial access through malware, browser exploits, or social engineering can then use the locally cached privileged credentials or hijack existing authenticated sessions to escalate their privileges. Privileged role activations grant extensive administrative rights across Microsoft Entra ID and connected services, so attackers can create new administrative accounts, modify security policies, access sensitive data across all organizational resources, and deploy malware or backdoors throughout the environment to establish persistent access. This lateral movement from a compromised endpoint to privileged cloud resources represents a critical attack path that bypasses many traditional security controls. The privileged access appears legitimate when originating from an authenticated administrator's session.\n\nIf this check passes, your tenant has a Conditional Access policy that restricts privileged role access to PAW devices, but it isn't the only control required to fully enable a PAW solution. You also need to configure an Intune device configuration and compliance policy and a device filter.\n\n**Remediation action**\n\n- [Deploy a privileged access workstation solution](https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-deployment?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - Provides guidance for configuring the Conditional Access and Intune device configuration and compliance policies.\n- [Configure device filters in Conditional Access to restrict privileged access](https://learn.microsoft.com/entra/identity/conditional-access/concept-condition-filters-for-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Custom sensitive information types (SITs) extend Microsoft Purview's built-in detection to cover organization-specific data patterns, proprietary identifiers, internal classification schemes, specialized industry codes, or other formats that built-in SITs don't match. Without custom SITs, auto-labeling policies and data loss prevention (DLP) rules rely exclusively on generic patterns and might miss sensitive data unique to your organization.\n\n**Remediation action**\n\n- [Create custom sensitive information types](https://learn.microsoft.com/purview/create-a-custom-sensitive-information-type?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Custom sensitive information types are configured",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "High",
      "TestSkipped": "",
      "TestCategory": "Advanced Classification",
      "TestId": "35033",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Passed"
    },
    {
      "TestId": 21836,
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "Workload Identities are not assigned privileged roles",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n**Found workload identities assigned to privileged roles.**\n| Service Principal Name | Privileged Role | Assignment Type |\n| :--- | :--- | :--- |\n| [elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c5632968-35cd-445d-926e-16e0afc9160e/appId/e876f7cb-13f3-48a4-8329-66d7b1fa33fb/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/) | Global Administrator | Permanent |\n| [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d22f071d-e8d3-41fc-a516-b29753cdd1f6/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/) | Application Administrator | Permanent |\n| [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d22f071d-e8d3-41fc-a516-b29753cdd1f6/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/) | Global Administrator | Permanent |\n\n\n**Recommendation:** Review and remove privileged role assignments from workload identities unless absolutely necessary. Use least-privilege principles and consider alternative approaches like managed identities with specific API permissions instead of directory roles.\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "If administrators assign privileged roles to workload identities, such as service principals or managed identities, the tenant can be exposed to significant risk if those identities are compromised. Threat actors who gain access to a privileged workload identity can perform reconnaissance to enumerate resources, escalate privileges, and manipulate or exfiltrate sensitive data. The attack chain typically begins with credential theft or abuse of a vulnerable application. Next step is privilege escalation through the assigned role, lateral movement across cloud resources, and finally persistence via other role assignments or credential updates. Workload identities are often used in automation and might not be monitored as closely as user accounts. Compromise can then go undetected, allowing threat actors to maintain access and control over critical resources. Workload identities aren't subject to user-centric protections like MFA, making least-privilege assignment and regular review essential. \n\n**Remediation action**\n- [Review and remove privileged roles assignments](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-resource-roles-assign-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#update-or-remove-an-existing-role-assignment).\n- [Follow the best practices for workload identities](https://learn.microsoft.com/entra/workload-id/workload-identities-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#key-scenarios).\n- [Learn about privileged roles and permissions in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/role-based-access-control/privileged-roles-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "24546",
      "TestMinimumLicense": "P1",
      "TestCategory": "Tenant",
      "TestTitle": "Windows automatic device enrollment is enforced to eliminate risks from unmanaged endpoints",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nWindows Automatic Enrollment is enabled.\n\n\n## Windows Automatic Enrollment\n\n| Policy Name | User Scope |\n| :---------- | :--------- |\n| [Microsoft Intune](https://intune.microsoft.com/#view/Microsoft_AAD_IAM/MdmConfiguration.ReactView/appId/0000000a-0000-0000-c000-000000000000/appName/Microsoft%20Intune) | ✅ Specific Groups |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If Windows automatic enrollment isn't enabled, unmanaged devices can become an entry point for attackers. Threat actors might use these devices to access corporate data, bypass compliance policies, and introduce vulnerabilities into the environment. Devices joined to Microsoft Entra without Intune enrollment create gaps in visibility and control. These unmanaged endpoints can expose weaknesses in the operating system or misconfigured applications that attackers can exploit.\n\nEnforcing automatic enrollment ensures Windows devices are managed from the start, enabling consistent policy enforcement and visibility into compliance. This supports Zero Trust by ensuring all devices are verified, monitored, and governed by security controls.\n\n**Remediation action**\n\nEnable automatic enrollment for Windows devices using Intune and Microsoft Entra to ensure all domain-joined or Entra-joined devices are managed:  \n- [Enable Windows automatic enrollment](https://learn.microsoft.com/intune/intune-service/enrollment/windows-enroll?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-windows-automatic-enrollment)\n\nFor more information, see:  \n- [Deployment guide - Enrollment for Windows](https://learn.microsoft.com/intune/intune-service/fundamentals/deployment-guide-enroll?tabs=work-profile%2Ccorporate-owned-apple%2Cautomatic-enrollment&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enrollment-for-windows)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "21876",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "Use PIM for Microsoft Entra privileged roles",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption"
    },
    {
      "TestId": "21780",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "No usage of ADAL in the tenant",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo ADAL applications found in the tenant.\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "High",
      "TestRisk": "Medium",
      "TestDescription": "Microsoft ended support and security fixes for ADAL on June 30, 2023. Continued ADAL usage bypasses modern security protections available only in MSAL, including Conditional Access enforcement, Continuous Access Evaluation (CAE), and advanced token protection. ADAL applications create security vulnerabilities by using weaker legacy authentication patterns, often calling deprecated Azure AD Graph endpoints, and preventing adoption of hardened authentication flows that could mitigate future security advisories. \n\n**Remediation action**\n\n- [Migrate applications to the Microsoft Authentication Library (MSAL)](https://learn.microsoft.com/entra/identity-platform/msal-migration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.2",
      "ZtmmFunctionName": "Identity Stores"
    },
    {
      "TestId": "24827",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Data",
      "TestTitle": "Conditional Access policies block access from unmanaged apps",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAt least one enabled conditional access policy with Application Protection exists for iOS and Android. The platforms could be part of same or different policy with the required grant control.\n\n\n## iOS & Android Conditional Access Policies\n\n| Policy Name | Platforms |\n| :---------- | :-------- |\n| [\\[RaviK\\] - Require app protection policy](https://intune.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies) | android, iOS |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If Microsoft Entra Conditional Access policies aren't combined with app protection controls, users can connect to corporate resources through unmanaged or unsecured applications. This exposes sensitive data to risks such as data leakage, unauthorized access, and regulatory noncompliance. Without safeguards like app-level data protection, access restrictions, and data loss prevention, threat actors can exploit unprotected apps to bypass security controls and compromise organizational data.\n\nEnforcing Intune app protection policies within Conditional Access ensures only trusted apps can access corporate data. This supports Zero Trust by enforcing access decisions based on app trust, data containment, and usage restrictions.\n\n**Remediation action**\n\nConfigure app-based Conditional Access policies in Microsoft Entra and Intune to require app protection for access to corporate resources:  \n- [Set up app-based Conditional Access policies with Intune](https://learn.microsoft.com/intune/intune-service/protect/app-based-conditional-access-intune-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:  \n- [What is Conditional Access?](https://learn.microsoft.com/entra/identity/conditional-access/overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Learn about app-based Conditional Access policies with Intune](https://learn.microsoft.com/intune/intune-service/protect/app-based-conditional-access-intune?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.3",
      "ZtmmFunctionName": "Resource access"
    },
    {
      "TestId": "25543",
      "TestMinimumLicense": [
        "Azure WAF on Azure Front Door Premium SKU",
        "Azure Standard SKU"
      ],
      "TestCategory": "Azure Network Security",
      "TestTitle": "Azure Front Door WAF is Enabled in Prevention Mode",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Front Door Web Application Firewall (WAF) protects web applications from common exploits and vulnerabilities, including SQL injection, cross-site scripting, and other OWASP Top 10 threats. WAF operates in two modes: Detection and Prevention. Detection mode evaluates and logs requests that match WAF rules but doesn't block traffic, while Prevention mode actively blocks malicious requests before they reach the backend application. When WAF is in Detection mode, web applications remain exposed to exploitation even though threats are being identified.\n\nWithout WAF in Prevention mode:\n\n- Threat actors can exploit web application vulnerabilities because matched requests are only logged, not blocked.\n- Organizations lose active protection at the global edge that managed and custom WAF rules provide, which reduces WAF to an observation tool rather than a security control.\n\n**Remediation action**\n\n- [Configure WAF for Azure Front Door](https://learn.microsoft.com/azure/web-application-firewall/afds/afds-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to switch the WAF policy from **Detection mode** to **Prevention mode**.\n- [Configure WAF policy settings for Azure Front Door](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#waf-mode) to enable **Prevention mode** in the policy settings.\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21864",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "All risk detections are triaged",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data Categorization"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "When you configure Quick Access in Microsoft Entra Private Access without Conditional Access policies, threat actors who compromise user credentials gain unrestricted access to private resources. The Quick Access application serves as a container for private resources including FQDNs and IP addresses.\n\nWithout policy enforcement:\n\n- Compromised accounts provide a direct pathway to internal systems.\n- Threat actors operating from unmanaged devices or anomalous locations can access private resources indistinguishably from authorized users.\n- Lateral movement across the internal network and data exfiltration from private applications become possible.\n- Multifactor authentication requirements and device health checks can't be enforced.\n\n**Remediation action**\n\n- [Apply Conditional Access Policies to Microsoft Entra Private Access Apps](https://learn.microsoft.com/entra/global-secure-access/how-to-target-resource-private-access-apps?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Quick Access is bound to a Conditional Access policy",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25394",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21807",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "Creating new applications and service principals is restricted to privileged users",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nTenant is configured to prevent users from registering applications.\n\n**[Users can register applications](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)** → **No** ✅\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "If nonprivileged users can create applications and service principals, these accounts might be misconfigured or be granted more permissions than necessary, creating new vectors for attackers to gain initial access. Attackers can exploit these accounts to establish valid credentials in the environment and bypass some security controls.\n\nIf these nonprivileged accounts are mistakenly granted elevated application owner permissions, attackers can use them to move from a lower level of access to a more privileged level of access. Attackers who compromise nonprivileged accounts might add their own credentials or change the permissions associated with the applications created by the nonprivileged users to ensure they can continue to access the environment undetected.\n\nAttackers can use service principals to blend in with legitimate system processes and activities. Because service principals often perform automated tasks, malicious activities carried out under these accounts might not be flagged as suspicious.\n\n**Remediation action**\n\n- [Block nonprivileged users from creating apps](https://learn.microsoft.com/entra/identity/role-based-access-control/delegate-app-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21771",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "Inactive applications don’t have highly privileged built-in roles",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo inactive applications with privileged Entra built-in roles\n\n\n## Apps with privileged Entra built-in roles\n\n| | Name | Role | Assignment | App owner tenant | Last sign in|\n| :--- | :--- | :--- | :--- | :--- | :--- |\n| ✅ | [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d22f071d-e8d3-41fc-a516-b29753cdd1f6/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | Global Administrator, Application Administrator | Permanent | Pora Inc. | 2025-09-09 | \n| ✅ | [elapora-tenant-devops-7576c63d-bc90-4ae4-9f1c-0d959fb520db](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c5632968-35cd-445d-926e-16e0afc9160e/appId/e876f7cb-13f3-48a4-8329-66d7b1fa33fb) | Global Administrator | Permanent | Pora Inc. | 2025-10-01 | \n\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they're legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable inactive privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases. If so, [analyze if a OAuth2 permission is a better fit](https://learn.microsoft.com/entra/identity-platform/v2-app-types?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "35027",
      "TestMinimumLicense": [
        "Microsoft 365 E3",
        "Microsoft 365 E5",
        "Advanced Message Encryption add-on"
      ],
      "TestCategory": "Information Protection",
      "TestTitle": "Custom branding templates are configured for Microsoft Purview Message Encryption",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"ExchangeOnline\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "Low",
      "TestDescription": "When an organization doesn’t use custom branding templates, people outside the company who receive encrypted messages could see a generic Microsoft‑branded portal. Because the portal doesn’t reflect the organization’s identity, recipients can be less confident about where the message came from.\n\nCustom branding templates let organizations add their logo, colors, disclaimers, and contact details to the portal. These elements help the portal look familiar to recipients and can support trust when they view and interact with encrypted messages.\n\n**Remediation action**\n\n- [Add your organization's brand to your encrypted messages](https://learn.microsoft.com/purview/add-your-organization-brand-to-encrypted-messages?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Data",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": "21792",
      "TestMinimumLicense": "Free",
      "TestCategory": "External collaboration",
      "TestTitle": "Guests have restricted access to directory objects",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n✅ Validated guest user access is restricted.\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.  \n\nExternal accounts with permissions to read directory object permissions provide attackers with broader initial access if compromised. These accounts allow attackers to gather additional information from the directory for reconnaissance.\n\n**Remediation action**\n\n- [Restrict guest access to their own directory objects](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-user-access)\n",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "When Conditional Access policies don't protect Private Access applications by requiring strong authentication, threat actors can use phishing attacks, credential stuffing, or password spraying to get user credentials and sign in to private applications with just a compromised password.\n\nWithout strong authentication:\n\n- Threat actors gain initial access to internal resources that should be protected by stronger controls.\n- If multifactor authentication is missing or phishable methods like SMS or voice are used, adversary-in-the-middle attacks can happen where threat actors intercept authentication tokens and session cookies.\n- Threat actors can move laterally from the initially compromised private application to other internal resources.\n\nMicrosoft recommends enforcing phishing-resistant authentication methods such as FIDO2 security keys, Windows Hello for Business, or certificate-based authentication for access to private applications, with multifactor authentication as the minimum acceptable baseline.\n\n**Remediation action**\n\n- [Configure Conditional Access policies to require phishing-resistant authentication](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Conditional Access policies enforce strong authentication for private apps",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect identities and secrets",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25396",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21775",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "Enforce standards for app secrets and certificates",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n❌ Tenant app management policy is enabled but lacks active credential restrictions.`n`n\n\n## Policy configuration assessment\n\n| Property | Status | Value |\n| :------- | :----- | :---- |\n| Policy enabled | ✅ Yes | True |\n\n### Configuration details\n\n**Application restrictions**: ✅ Configured\n\n| Credential type | Restriction type | State | Status |\n| :-------------- | :--------------- | :---- | :----- |\n| Password credentials | passwordAddition | disabled | ⚠️ Configured but inactive |\n| Password credentials | symmetricKeyAddition | disabled | ⚠️ Configured but inactive |\n\n**Service principal restrictions**: ✅ Configured\n\n| Credential type | Restriction type | State | Status |\n| :-------------- | :--------------- | :---- | :----- |\n| Password credentials | passwordAddition | disabled | ⚠️ Configured but inactive |\n| Password credentials | symmetricKeyAddition | disabled | ⚠️ Configured but inactive |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Without proper application management policies, threat actors can exploit weak or misconfigured application credentials to get unauthorized access to organizational resources. Applications using long-lived password secrets or certificates create extended attack windows where compromised credentials stay valid for extended periods. If an application uses client secrets that are hardcoded in configuration files or have weak password requirements, threat actors can extract these credentials through different means, including source code repositories, configuration dumps, or memory analysis. If threat actors get these credentials, they can perform lateral movement within the environment, escalate privileges if the application has elevated permissions, establish persistence by creating more backdoor credentials, modify application configuration, or exfiltrate data. The lack of credential lifecycle management lets compromised credentials remain active indefinitely, giving threat actors sustained access to organizational assets and the ability to conduct data exfiltration, system manipulation, or deploy more malicious tools without detection. \n\nConfiguring appropriate app management policies helps organizations stay ahead of these threats.\n\n**Remediation action**\n\n- [Learn how to enforce secret and certificate standards using application management policies](https://learn.microsoft.com/entra/identity/enterprise-apps/tutorial-enforce-secret-standards?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21877",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "All guests have a sponsor",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n✅ All guest accounts in the tenant have an assigned sponsor.\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Inviting external guests is beneficial for organizational collaboration. However, in the absence of an assigned internal sponsor for each guest, these accounts might persist within the directory without clear accountability. This oversight creates a risk: threat actors could potentially compromise an unused or unmonitored guest account, and then establish an initial foothold within the tenant. Once granted access as an apparent \"legitimate\" user, an attacker might explore accessible resources and attempt privilege escalation, which could ultimately expose sensitive information or critical systems. An unmonitored guest account might therefore become the vector for unauthorized data access or a significant security breach. A typical attack sequence might use the following pattern, all achieved under the guise of a standard external collaborator:\n\n1. Initial access gained through compromised guest credentials\n1. Persistence due to a lack of oversight.\n1. Further escalation or lateral movement if the guest account possesses group memberships or elevated permissions.\n1. Execution of malicious objectives. \n\nMandating that every guest account is assigned to a sponsor directly mitigates this risk. Such a requirement ensures that each external user is linked to a responsible internal party who is expected to regularly monitor and attest to the guest's ongoing need for access. The sponsor feature within Microsoft Entra ID supports accountability by tracking the inviter and preventing the proliferation of \"orphaned\" guest accounts. When a sponsor manages the guest account lifecycle, such as removing access when collaboration concludes, the opportunity for threat actors to exploit neglected accounts is substantially reduced. This best practice is consistent with Microsoft’s guidance to require sponsorship for business guests as part of an effective guest access governance strategy. It strikes a balance between enabling collaboration and enforcing security, as it guarantees that each guest user's presence and permissions remain under ongoing internal oversight.\n\n**Remediation action**\n- For each guest user that has no sponsor, assign a sponsor in Microsoft Entra ID.\n    - [Add a sponsor to a guest user in the Microsoft Entra admin center](https://learn.microsoft.com/entra/external-id/b2b-sponsors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - [Add a sponsor to a guest user using Microsoft Graph](https://learn.microsoft.com/graph/api/user-post-sponsors?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.6",
      "ZtmmFunctionName": "Automation & Orchestration"
    },
    {
      "TestId": "21824",
      "TestMinimumLicense": "P1",
      "TestCategory": "External collaboration",
      "TestTitle": "Guests don't have long lived sign-in sessions",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nGuests do have long lived sign-in sessions.\n\n\n## Sign-in frequency policies\n\n| Policy Name | Sign-in Frequency | Status |\n| :---------- | :---------------- | :----- |\n| [Guest 10 hr MFA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/bcc1a12e-c68d-419e-a6c4-6d4bdfa8bfc8) | 10 hours | ✅ |\n| [MT-Test-MtCaMfaForGuest](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/a16cd40e-1fa7-4151-82f0-baca22b68ede) | Not configured | ❌ |\n| [ALEX - MFA for risky sign-ins](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/5167662e-2022-45a5-825c-4514e5a0cfd4) | 23 hours | ✅ |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Guest accounts with extended sign-in sessions increase the risk surface area that threat actors can exploit. When guest sessions persist beyond necessary timeframes, threat actors often attempt to gain initial access through credential stuffing, password spraying, or social engineering attacks. Once they gain access, they can maintain unauthorized access for extended periods without reauthentication challenges. These compromised and extended sessions:\n\n- Allow unauthorized access to Microsoft Entra artifacts, enabling threat actors to identify sensitive resources and map organizational structures.\n- Allow threat actors to persist within the network by using legitimate authentication tokens, making detection more challenging as the activity appears as typical user behavior.\n- Provides threat actors with a longer window of time to escalate privileges through techniques like accessing shared resources, discovering more credentials, or exploiting trust relationships between systems.\n\nWithout proper session controls, threat actors can achieve lateral movement across the organization's infrastructure, accessing critical data and systems that extend far beyond the original guest account's intended scope of access. \n\n**Remediation action**\n- [Configure adaptive session lifetime policies](https://learn.microsoft.com/entra/identity/conditional-access/howto-conditional-access-session-lifetime?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) so sign-in frequency policies have shorter live sign-in sessions.\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestId": "24570",
      "TestMinimumLicense": "Free",
      "TestCategory": "Hybrid infrastructure",
      "TestTitle": "Entra Connect Sync is configured with Service Principal Credentials",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound enabled user accounts with Microsoft Entra Connect connector permissions.\n\n**Hybrid Identity Status**: True\n\n\n## Identities for Entra Connect Sync\n\n| Directory Synchronization Accounts Role Member | User Principal Name | Enabled | User Type |\n| :--------------------------------------------- | :------------------ | :------ | :-------- |\n| [On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f) | Sync_DC1_d8475d81663f@pora.onmicrosoft.com | ❌ Yes | Member |\n\n\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Microsoft Entra Connect Sync using user accounts instead of service principals creates security vulnerabilities. Legacy user account authentication with passwords is more susceptible to credential theft and password attacks than service principal authentication with certificates. Compromised connector accounts allow threat actors to manipulate identity synchronization, create backdoor accounts, escalate privileges, or disrupt hybrid identity infrastructure.  \n\n**Remediation action**\n\n- [Configure service principal authentication for Entra Connect](https://learn.microsoft.com/entra/identity/hybrid/connect/authenticate-application-id?tabs=default&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#onboard-to-application-based-authentication)\n- [Remove legacy Directory Synchronization Accounts](https://learn.microsoft.com/entra/identity/hybrid/connect/authenticate-application-id?tabs=default&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#remove-a-legacy-service-account)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.2",
      "ZtmmFunctionName": "Identity Stores"
    },
    {
      "TestId": "25539",
      "TestMinimumLicense": "Azure_Firewall_Premium",
      "TestCategory": "Azure Network Security",
      "TestTitle": "IDPS Inspection is Enabled in Deny Mode on Azure Firewall",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Firewall Premium provides signature-based intrusion detection and prevention (IDPS) that identifies attacks by detecting specific patterns in network traffic, such as byte sequences and known malicious instruction sequences used by malware. IDPS applies to inbound, east-west (spoke-to-spoke), and outbound traffic across Layers 3-7. When IDPS isn't configured in `Alert and deny` mode, Azure Firewall only logs detected threats without blocking them.\n\nWithout IDPS enabled in `Alert and deny` mode:\n\n- Threat actors can send traffic that matches known attack signatures without being blocked.\n- Organizations running IDPS in `Alert only` mode gain visibility into threats but can't prevent intrusion attempts from reaching their workloads.\n- Lateral movement and exfiltration traffic that matches known attack signatures passes through the firewall without active intervention.\n\n**Remediation action**\n\n- [Enable IDPS in Alert and Deny mode in Azure Firewall Premium](https://learn.microsoft.com/azure/firewall/premium-features?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) by configuring the intrusion detection mode to `Alert and deny` in the firewall policy.\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": "21894",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "All certificates Microsoft Entra Application Registrations and Service Principals must be issued by an approved certification authority",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "24840",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Data",
      "TestTitle": "Secure Wi-Fi profiles protect Android devices from unauthorized network access",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nNo Enterprise Wi-Fi profile for android exists or none are assigned.\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If Wi-Fi profiles aren't properly configured and assigned, Android devices can fail to connect to secure networks or connect insecurely, exposing corporate data to interception or unauthorized access. Without centralized management, devices rely on manual configuration, increasing the risk of misconfiguration, weak authentication, and connection to rogue networks.\n\nCentrally managing Wi-Fi profiles for Android devices in Intune ensures secure and consistent connectivity to enterprise networks. This enforces authentication and encryption standards, simplifies onboarding, and supports Zero Trust by reducing exposure to untrusted networks.\n\n\n\nUse Intune to configure secure Wi-Fi profiles that enforce authentication and encryption standards.\n\n**Remediation action**\n\nUse Intune to configure and assign secure Wi-Fi profiles for Android devices to enforce authentication and encryption standards:  \n- [Deploy Wi-Fi profiles to devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/wi-fi-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-profile)\n\nFor more information, see:  \n- [Review the available Wi-Fi settings for Android devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/wi-fi-settings-android-enterprise?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "21954",
      "TestMinimumLicense": "Free",
      "TestCategory": "Devices",
      "TestTitle": "Restrict nonadministrator users from recovering the BitLocker keys for their owned devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n[Non-administrator users are restricted from recovering BitLocker keys for their owned devices](https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview)\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "When non-administrator users can access their own BitLocker keys, threat actors who compromise user credentials gain direct access to encryption keys without requiring privilege escalation. Once attackers obtain BitLocker keys, they can decrypt sensitive data stored on the device, including cached credentials, local databases, and confidential files.\n\nWithout proper restrictions, a single compromised user account provides immediate access to all encrypted data on that device, negating the primary security benefit of disk encryption and creating a pathway for lateral movement. \n\n**Remediation action**\n\n- [Restrict non-admin users from recovering the BitLocker key(s) for their owned devices](https://learn.microsoft.com/entra/identity/devices/manage-device-identities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-device-settings)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "<!-- This file is a duplicate of 25380.md. Docs files reference 25380.md.-->\nWhen organizations deploy Global Secure Access as their cloud-based network proxy, Microsoft's Secure Service Edge infrastructure routes user traffic. If you don't enable source IP restoration, all authentication requests come from the proxy's IP address instead of the user's actual public egress IP.\n\nWithout this protection:\n\n- Threat actors who compromise user credentials can authenticate from any location while bypassing IP-based Conditional Access controls and named location policies.\n- Microsoft Entra ID Protection risk detections lose visibility into the original user IP address, which degrades the accuracy of risk scoring algorithms.\n- Sign-in logs and audit trails no longer show the true source of authentication attempts, which makes incident investigation and forensic analysis more difficult.\n\n**Remediation action**\n\n- Enable Global Secure Access signaling in Conditional Access. For more information, see [Source IP restoration](https://learn.microsoft.com/entra/global-secure-access/how-to-source-ip-restoration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Source IP restoration is enabled",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\") OR (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access",
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Network",
      "TestId": "25370",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21891",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Require password reset notifications for administrator roles",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Configuring password reset notifications for administrator roles in Microsoft Entra ID enhances security by notifying privileged administrators when another administrator resets their password. This visibility helps detect unauthorized or suspicious activity that could indicate credential compromise or insider threats. Without these notifications, malicious actors could exploit elevated privileges to establish persistence, escalate access, or extract sensitive data. Proactive notifications support quick action, preserve privileged access integrity, and strengthen the overall security posture.   \n\n**Remediation action**\n\n- [Notify all admins when other admins reset their passwords](https://learn.microsoft.com/entra/identity/authentication/concept-sspr-howitworks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#notify-all-admins-when-other-admins-reset-their-passwords)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data Categorization"
    },
    {
      "TestId": "21985",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Turn off Seamless SSO if there is no usage",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Microsoft Entra seamless single sign-on (Seamless SSO) is a legacy authentication feature designed to provide passwordless access for domain-joined devices that are not hybrid Microsoft Entra ID joined. Seamless SSO relies on Kerberos authentication and is primarily beneficial for older operating systems like Windows 7 and Windows 8.1, which do not support Primary Refresh Tokens (PRT). If these legacy systems are no longer present in the environment, continuing to use Seamless SSO introduces unnecessary complexity and potential security exposure. Threat actors could exploit misconfigured or stale Kerberos tickets, or compromise the `AZUREADSSOACC` computer account in Active Directory, which holds the Kerberos decryption key used by Microsoft Entra ID. Once compromised, attackers could impersonate users, bypass modern authentication controls, and gain unauthorized access to cloud resources. Disabling Seamless SSO in environments where it is no longer needed reduces the attack surface and enforces the use of modern, token-based authentication mechanisms that offer stronger protections. \n\n**Remediation action**\n\n- [Review how Seamless SSO works](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-sso-how-it-works?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Disable Seamless SSO](https://learn.microsoft.com/entra/identity/hybrid/connect/how-to-connect-sso-faq?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-can-i-disable-seamless-sso-)\n- [Clean up stale devices in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/devices/manage-stale-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.2",
      "ZtmmFunctionName": "Identity Stores"
    },
    {
      "TestId": "21820",
      "TestMinimumLicense": "P2",
      "TestCategory": "Privileged access",
      "TestTitle": "Activation alert for all privileged role assignments",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nActivation alerts are missing or improperly configured for privileged roles.\n## Roles with missing or misconfigured alerts\n\n| Role display name | Default recipients | Additional recipients |\n| :---------------- | :----------------- | :------------------- |\n| [User Administrator](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles) | Enabled | N/A |\n\n\n*Not all misconfigured roles may be listed. For performance reasons, this assessment stops at the first detected issue.*\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "Low",
      "TestDescription": "Without activation alerts for privileged role assignments, threat actors can escalate privileges undetected. This lack of visibility creates a blind spot where attackers can activate the most privileged role and perform malicious actions such as creating backdoor accounts, modifying security policies, or accessing sensitive data.\n\nMonitoring these activation alerts can help security teams distinguish between authorized and unauthorized privilege escalation activities. \n\n**Remediation action**\n\n- [Configure notifications for privileged roles](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#require-justification-on-active-assignment)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.5",
      "ZtmmFunctionName": "Visibility & Analytics"
    },
    {
      "TestId": "22072",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Self-service password reset doesn't use security questions",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Allowing security questions as a self-service password reset (SSPR) method weakens the password reset process because answers are frequently guessable, reused across sites, or discoverable through open-source intelligence (OSINT). Threat actors enumerate or phish users, derive likely responses (family names, schools, and locations), and then trigger password reset flows to bypass stronger methods by exploiting the weaker knowledge-based gate. After they successfully reset a password on an account that isn't protected by multifactor authentication they can: gain valid primary credentials, establish session tokens, and laterally expand by registering more durable authentication methods, add forwarding rules, or exfiltrate sensitive data.\n\nEliminating this method removes a weak link in the password reset process. Some organizations might have specific business reasons for leaving security questions enabled, but this isn't recommended.\n\n**Remediation action**\n\n- [Disable security questions in SSPR policy](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-security-questions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Select authentication methods and registration options](https://learn.microsoft.com/entra/identity/authentication/tutorial-enable-sspr?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#select-authentication-methods-and-registration-options)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data Categorization"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestDescription": "Without proper scoping of traffic forwarding profiles, organizations risk either exposing all users to security controls before infrastructure readiness is validated or inadvertently excluding users who should be protected.\n\nRisks of improper scoping:\n\n- **Too broad**: When profiles are assigned to \"all users\" without deliberate planning, a misconfiguration could disrupt network connectivity for the entire organization simultaneously.\n- **Too narrow**: If profiles are scoped too narrowly or assignments are incomplete, a subset of users operates outside the security perimeter, creating gaps that threat actors can exploit.\n- **Unmonitored access**: Attackers who compromise devices belonging to unassigned users can access resources without traffic being inspected, logged, or subject to security policies.\n\nProper scoping ensures controlled rollout—starting with pilot groups to validate functionality, then expanding to broader populations—while maintaining visibility into which users are protected.\n\n**Remediation action**\n\n- Assign users and groups to traffic forwarding profiles. For more information, see [Manage users and groups assignment](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-users-groups-assignment?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Traffic forwarding profiles are scoped to appropriate users and groups for controlled deployment",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\") OR (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access",
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "NotConnectedToService",
      "TestCategory": "Global Secure Access",
      "TestId": "25382",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Skipped"
    },
    {
      "TestId": "24576",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Endpoint Analytics is enabled to help identify risks on Windows devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nEndpoint analytics policy is not created or not assigned.\n\nNo Endpoint Analytics policies found in this tenant.\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Low",
      "TestDescription": "If endpoint analytics isn't enabled, threat actors can exploit gaps in device health, performance, and security posture. Without the visibility endpoint analytics brings, it can be difficult for an organization to detect indicators such as anomalous device behavior, delayed patching, or configuration drift. These gaps allow attackers to establish persistence, escalate privileges, and move laterally across the environment. An absence of analytics data can impede rapid detection and response, allowing attackers to exploit unmonitored endpoints for command and control, data exfiltration, or further compromise.\n\nEnabling endpoint analytics provides visibility into device health and behavior, helping organizations detect risks, respond quickly to threats, and maintain a strong Zero Trust posture.\n\n**Remediation action**\n\nEnroll Windows devices into endpoint analytics in Intune to monitor device health and identify risks:  \n- [Configure endpoint analytics](https://learn.microsoft.com/intune/endpoint-analytics/configure?pivots=intune&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\nFor more information, see:\n- [What is endpoint analytics?](https://learn.microsoft.com/intune/endpoint-analytics/index?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.5",
      "ZtmmFunctionName": "Visibility and analytics"
    },
    {
      "TestId": "24572",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Device enrollment notifications are enforced to ensure user awareness and secure onboarding",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo device enrollment notification is configured or assigned in Intune.\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Without device enrollment notifications, users might be unaware that their device has been enrolled in Intune—particularly in cases of unauthorized or unexpected enrollment. This lack of visibility can delay user reporting of suspicious activity and increase the risk of unmanaged or compromised devices gaining access to corporate resources. Attackers who obtain user credentials or exploit self-enrollment flows can silently onboard devices, bypassing user scrutiny and enabling data exposure or lateral movement.\n\nEnrollment notifications provide users with improved visibility into device onboarding activity. They help detect unauthorized enrollment, reinforce secure provisioning practices, and support Zero Trust principles of visibility, verification, and user engagement.\n\n**Remediation action**\n\nConfigure Intune enrollment notifications to alert users when their device is enrolled and reinforce secure onboarding practices:  \n- [Set up enrollment notifications in Intune](https://learn.microsoft.com/intune/intune-service/enrollment/enrollment-notifications?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "TLS inspection decrypts and inspects HTTPS traffic, enabling visibility into encrypted sessions. Without it, many Microsoft Entra Internet Access features can't function, including URL filtering and advanced threat detection. Most internet traffic is encrypted, so TLS inspection is essential for applying security policies to most user activity.\n\n**Remediation action**\n\n- [Configure Transport Layer Security Inspection Policies](https://learn.microsoft.com/entra/global-secure-access/how-to-transport-layer-security?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "TLS inspection is enabled and correctly configured for outbound traffic",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "High",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25411",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management",
      "TestStatus": "Failed"
    },
    {
      "TestId": "24552",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "macOS Firewall policies protect against unauthorized network access",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo assigned macOS firewall policy was found in Intune.\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Without a centrally managed firewall policy, macOS devices might rely on default or user-modified settings, which often fail to meet corporate security standards. This exposes devices to unsolicited inbound connections, enabling threat actors to exploit vulnerabilities, establish outbound command-and-control (C2) traffic for data exfiltration, and move laterally within the network—significantly escalating the scope and impact of a breach.\n\nEnforcing macOS Firewall policies ensures consistent control over inbound and outbound traffic, reducing exposure to unauthorized access and supporting Zero Trust through device-level protection and network segmentation.\n\n**Remediation action**\n\nConfigure and assign **macOS Firewall** profiles in Intune to block unauthorized traffic and enforce consistent network protections across all managed macOS devices:\n\n- [Configure the built-in firewall on macOS devices](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n\nFor more information, see:  \n-  [Available macOS firewall settings](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-profile-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#macos-firewall-profile)\n",
      "TestTags": null,
      "TestImpact": "High",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "21895",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "Application Certificate Credentials are managed using HSM",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "High",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21859",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "GDAP admin least privilege",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption"
    },
    {
      "TestId": "21872",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Require multifactor authentication for device join and device registration using user action",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n**Properly configured Conditional Access policies found** that require MFA for device registration/join actions.\n## Device Settings Configuration\n\n| Setting | Value | Recommended Value | Status |\n| :------ | :---- | :---------------- | :----- |\n| Require Multi-Factor Authentication to register or join devices | No | No | ✅ Correctly configured |\n\n## Device Registration/Join Conditional Access Policies\n\n| Policy Name | State | Requires MFA | Status |\n| :---------- | :---- | :----------- | :----- |\n| [testdevicereg21872](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/620a9c5c-09c4-4558-a0fe-7fc8b3540992) | enabled | Yes | ✅ Properly configured |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Threat actors can exploit the lack of multifactor authentication during new device registration. Once authenticated, they can register rogue devices, establish persistence, and circumvent security controls tied to trusted endpoints. This foothold enables attackers to exfiltrate sensitive data, deploy malicious applications, or move laterally, depending on the permissions of the accounts being used by the attacker. Without MFA enforcement, risk escalates as adversaries can continuously reauthenticate, evade detection, and execute objectives.\n\n**Remediation action**\n\n- [Deploy a Conditional Access policy to require multifactor authentication for device registration](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-device-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21822",
      "TestMinimumLicense": "Free",
      "TestCategory": "Access control",
      "TestTitle": "Guest access is limited to approved tenants",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nGuest access is not limited to approved tenants.\n\n\n## [Collaboration restrictions](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/)\n\nThe tenant is configured to: **Allow invitations to be sent to any domain (most inclusive)** ❌\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "High",
      "TestRisk": "Medium",
      "TestDescription": "Without limiting guest access to approved tenants, threat actors can exploit unrestricted guest access to establish initial access through compromised external accounts or by creating accounts in untrusted tenants. Organizations can configure an allowlist or blocklist to control B2B collaboration invitations from specific organizations, and without these controls, threat actors can leverage social engineering techniques to obtain invitations from legitimate internal users. Once threat actors gain guest access through unrestricted domains, they can perform discovery activities to enumerate internal resources, users, and applications that guest accounts can access. The compromised guest account then serves as a persistent foothold, allowing threat actors to execute collection activities against accessible SharePoint sites, Teams channels, and other resources granted to guest users. From this position, threat actors can attempt lateral movement by exploiting trust relationships between the compromised tenant and partner organizations, or by leveraging guest permissions to access sensitive data that can be used for further credential compromise or business email compromise attacks.\n\n**Remediation action**\n\n- [Configure Domain-Based Allow or Deny Lists](https://learn.microsoft.com/en-us/entra/external-id/allow-deny-list)\n\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data Categorization"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestDescription": "When Quick Access lacks user or group assignments, the service prevents connections to fully qualified domain names (FQDNs) and IP addresses that you configure in the application segments. This restriction disrupts access to internal resources like file shares, web applications, and databases. When users can't reach resources through the Global Secure Access client, they might seek alternative access methods that bypass security controls such as Conditional Access policies and multifactor authentication.\n\nIf you don't assign users to Quick Access:\n\n- Authorized users can't reach internal resources through Private Access, creating gaps in business continuity.\n- Administrators might implement temporary workarounds that weaken the organization's security posture.\n\n**Remediation action**\n\n- [Assign users and groups to Quick Access](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-quick-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to enable Private Access connectivity to configured application segments.\n",
      "TestTitle": "Quick Access has user or group assignments",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "NotConnectedToService",
      "TestCategory": "Global Secure Access",
      "TestId": "25480",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Skipped"
    },
    {
      "TestId": "21885",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "App registrations use safe redirect URIs",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe redirect URIs |\n| :--- | :--- | :--- |\n|  | [Azure AD SAML Toolkit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/4317fd0a-dcee-45bf-8e94-9a66638b11e0/appId/6f5ed68c-9fad-4d78-bf88-2b16bbe16338/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://samltoolkit.azurewebsites.net/SAML/Consume` |  |\n|  | [My nice app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d41cfc13-11d1-4f93-835a-88e729725564/appId/2946f286-2b59-4f29-876c-0ed8bbe1c482/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://mysalmon.azurewebsites.net/login.saml` |  |\n|  | [MyVisualStudioMcpClient](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/cae606b7-4a44-4d07-a7a5-a6fb285e41f1/appId/84ad8697-445d-4b26-affd-1b1459e97aae/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `1️⃣ http://127.0.0.1:33418` |  |\n|  | [MyVscode](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/dfc83a5d-36e5-4506-ae9d-6ad5bb403377/appId/92abdce1-3952-4a8b-8720-e59257edd421/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `1️⃣ http://127.0.0.1:33418` |  |\n|  | [saml test app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/daa6074c-db6f-4bdc-a41b-bc0052c536a5/appId/c266d677-a5f8-47bc-9f0a-1b6fbe0bddad/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://appclaims.azurewebsites.net/signin-saml`, `2️⃣ https://appclaims.azurewebsites.net/signin-oidc` |  |\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "OAuth applications configured with URLs that include wildcards, or URL shorteners increase the attack surface for threat actors. Insecure redirect URIs (reply URLs) might allow adversaries to manipulate authentication requests, hijack authorization codes, and intercept tokens by directing users to attacker-controlled endpoints. Wildcard entries expand the risk by permitting unintended domains to process authentication responses, while shortener URLs might facilitate phishing and token theft in uncontrolled environments. \n\nWithout strict validation of redirect URIs, attackers can bypass security controls, impersonate legitimate applications, and escalate their privileges. This misconfiguration enables persistence, unauthorized access, and lateral movement, as adversaries exploit weak OAuth enforcement to infiltrate protected resources undetected.\n\n**Remediation action**\n\n- [Check the redirect URIs for your application registrations.](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) Make sure the redirect URIs don't have *.azurewebsites.net, wildcards, or URL shorteners.\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "26884",
      "TestMinimumLicense": "Azure_Front_Door_Premium",
      "TestCategory": "Azure Network Security",
      "TestTitle": "Bot protection rule set is enabled and assigned in Azure Front Door WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Front Door is a global, scalable entry point that uses the Microsoft global edge network to deliver fast, secure, and highly scalable web applications. Web Application Firewall (WAF) integrated with Azure Front Door provides protection against common web exploits and vulnerabilities at the network edge. The Bot Manager rule set is a managed rule set available exclusively in Azure Front Door Premium SKU that provides protection against malicious bots while allowing legitimate bots such as search engine crawlers to access your applications. When bot protection is not enabled, threat actors can deploy automated attacks against web applications including credential stuffing attacks that test stolen username/password combinations at scale, web scraping that extracts sensitive data or intellectual property, inventory hoarding bots that deplete product availability, and application-layer DDoS attacks that exhaust backend resources. The Bot Manager rule set categorizes bots into good bots, bad bots, and unknown bots, allowing security teams to configure appropriate actions for each category. Bad bots can be blocked or challenged with CAPTCHA, while good bots like Googlebot and Bingbot are allowed through. Without bot protection, organizations lack visibility into bot traffic patterns and cannot distinguish between human users and automated clients, making it impossible to defend against sophisticated bot-driven attacks that bypass traditional rate limiting and IP-based controls.\n\n**Remediation action**\n\nUpgrade to Azure Front Door Premium if currently using Standard SKU to access bot protection features\n- [Azure Front Door tier comparison](https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/tier-comparison)\n\nCreate a WAF policy with Premium SKU if one does not exist\n- [Create a WAF policy for Azure Front Door using the Azure portal](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-create-portal)\n\nEnable the Bot Manager rule set in the WAF policy\n- [Configure bot protection for Web Application Firewall](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-policy-configure-bot-protection)\n\nAssociate the WAF policy with your Azure Front Door profile via security policies\n- [Add security policy in Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/how-to-configure-endpoints#add-security-policy)\n\nConfigure bot protection rules to customize actions for different bot categories\n- [Bot protection rule set on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview#bot-protection-rule-set)\n\nMonitor bot traffic using Azure Front Door logs and metrics\n- [Monitor metrics and logs in Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-diagnostics)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": "21855",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "Privileged roles have access reviews",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21798",
      "TestMinimumLicense": "P2",
      "TestCategory": "Access control",
      "TestTitle": "ID Protection notifications are enabled",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If you don't enable ID Protection notifications, your organization loses critical real-time alerts when threat actors compromise user accounts or conduct reconnaissance activities. When Microsoft Entra ID Protection detects accounts at risk, it sends email alerts with **Users at risk detected** as the subject and links to the **Users flagged for risk** report. Without these notifications, security teams remain unaware of active threats, allowing threat actors to maintain persistence in compromised accounts without being detected. You can feed these risks into tools like Conditional Access to make access decisions or send them to a security information and event management (SIEM) tool for investigation and correlation. Threat actors can use this detection gap to conduct lateral movement activities, privilege escalation attempts, or data exfiltration operations while administrators remain unaware of the ongoing compromise. The delayed response enables threat actors to establish more persistence mechanisms, change user permissions, or access sensitive resources before you can fix the issue. Without proactive notification of risk detections, organizations must rely solely on manual monitoring of risk reports, which significantly increases the time it takes to detect and respond to identity-based attacks.   \n\n**Remediation action**\n\n- [Configure users at risk detected alerts](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-configure-notifications?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-users-at-risk-detected-alerts)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.8",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21847",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Password protection for on-premises is enabled",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n\n❌ **Fail**: Password protection for on-premises is not set to 'Enforce' mode.\n\n## Password Protection Settings\n\n| Setting | Value |\n| :---- | :---- |\n| Password Protection for Active Directory Domain Services | ✅ Enabled |\n| Enabled Mode (Audit/Enforce) | ❌ Audit |\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "When on-premises password protection isn’t enabled or enforced, threat actors can use low-and-slow password spray with common variants, such as season+year+symbol or local terms, to gain initial access to Active Directory Domain Services accounts. Domain Controllers (DCs) can accept weak passwords when either of the following statements are true:\n\n- Microsoft Entra Password Protection DC agent isn't installed\n- The password protection tenant setting is disabled or in audit-only mode\n\nWith valid on-premises credentials, attackers laterally move by reusing passwords across endpoints, escalate to domain admin through local admin reuse or service accounts, and persist by adding backdoors, while weak or disabled enforcement produces fewer blocking events and predictable signals. Microsoft’s design requires a proxy that brokers policy from Microsoft Entra ID and a DC agent that enforces the combined global and tenant custom banned lists on password change/reset; consistent enforcement requires DC agent coverage on all DCs in a domain and using Enforced mode after audit evaluation.\n\n**Remediation action**\n\n- [Deploy Microsoft Entra password protection](https://learn.microsoft.com/entra/identity/authentication/howto-password-ban-bad-on-premises-deploy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": 25400,
      "TestMinimumLicense": [
        "AAD_PREMIUM",
        "Entra_Premium_Private_Access"
      ],
      "TestCategory": "Private Access",
      "TestTitle": "Is port 53 published or private DNS configured for Private Access applications",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nPrivate Access is not enabled in this tenant. This check is not applicable until Private Access is configured and enabled.\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Low",
      "TestDescription": "When the Private Access profile is enabled in Global Secure Access but neither port 53 (UDP/TCP) is published in application segments nor private DNS suffixes are configured, the Global Secure Access client on remote devices cannot route DNS queries for internal domain names through the tunnel. DNS queries for internal FQDNs then go to the local resolver on the device, which has no knowledge of internal zones. This causes FQDN-based application segments to fail to match traffic because the client cannot resolve internal host names to IP addresses. A threat actor operating on the same local network as the remote user can observe these unencrypted DNS queries (T1040 - Network Sniffing), map internal resource names, and use that information to identify targets for later stages of an attack. The client may also fall back to direct connections that bypass Conditional Access and security profile enforcement applied through Global Secure Access, reducing the organization's control over access to private resources. Configuring private DNS suffixes or publishing port 53 to an internal DNS server through an application segment ensures that DNS resolution for internal domains occurs within the tunnel, preventing DNS leakage and maintaining traffic acquisition for FQDN-based segments.\n\n**Remediation action**\n\n- [Configure private DNS suffixes for Quick Access or per-app access to route DNS queries for internal domains through Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-quick-access)\n- [Configure per-app access with application segments that include port 53 to an internal DNS server](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-per-app-access)\n- [Understand Private Access and application segment configuration in Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/concept-private-access)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestDescription": "Purview audit logging logs who accessed sensitive data, when policy violations occurred, and what administrative actions were taken across Microsoft 365. When audit logs are available, security teams can investigate incidents, perform eDiscovery, detect insider threats, and demonstrate controls to auditors and regulators.\n\nWithout audit logging enabled, threat actors can often operate undetected, and incident response becomes impossible due to lack of evidence. Organizations that fail to enable audit logging also risk noncompliance with regulatory requirements that mandate activity logging for sensitive operations.\n\n**Remediation action**\n\n- [Turn auditing on or off](https://learn.microsoft.com/purview/audit-log-enable-disable?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Purview audit logging is enabled",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"ExchangeOnline\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "NotConnectedToService",
      "TestCategory": "Data Security Posture Management",
      "TestId": "35037",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Skipped"
    },
    {
      "TestId": "21784",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control; Credential management",
      "TestTitle": "All user sign in activity uses phishing-resistant authentication methods",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\n❌ Not all users are protected by Conditional Access policies requiring phishing-resistant authentication methods.\n\n**Reason**: Found policies with user exclusions that create coverage gaps\n## Conditional Access Policies with Phishing-Resistant Authentication (Issues Found)\n\n| Policy | Authentication strength | Included Users | Excluded Users |\n| :---------- | :---------------------- | :------------- | :------------- |\n| [Security regisrtation info](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/508ae024-d4c4-42bf-a8c9-40257c214c10) | [Multifactor authentication](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/menuId//fromNav/Identity) | All Users | ⚠️ 2 users |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Phishing-resistant authentication methods like passkeys and FIDO2 security keys provide the strongest protection against credential theft and sophisticated phishing attacks. Traditional MFA methods remain vulnerable to adversary-in-the-middle attacks and social engineering. Enforcing phishing-resistant methods for all users through Conditional Access policies helps prevent unauthorized access even when attackers attempt to intercept authentication flows.\n\n**Remediation action**\n\n- [Configure Conditional Access for all users with MFA strength](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy phishing-resistant passwordless authentication](https://learn.microsoft.com/entra/identity/authentication/how-to-deploy-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "21865",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "Named locations are configured",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\n✅ **Pass**: Trusted named locations are configured in Microsoft Entra ID to support location-based security controls.\n\n\n## All named locations\n\n5 [named locations](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations/menuId//fromNav/) found.\n\n| Name | Location type | Trusted | Creation date | Modified date |\n| :--- | :------------ | :------ | :------------ | :------------ |\n| Melbourne Branch | IP-based | Yes | Unknown | Unknown |\n| Boston Head Office | IP-based | Yes | Unknown | Unknown |\n| Untrusted Locations | Country-based | No | Unknown | Unknown |\n| Corporate IPs | IP-based | Yes | Unknown | Unknown |\n| Merill home | IP-based | Yes | 04/16/2025 04:55:11 | 04/16/2025 04:55:11 |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Without named locations configured in Microsoft Entra ID, threat actors can exploit the absence of location intelligence to conduct attacks without triggering location-based risk detections or security controls. When organizations fail to define named locations for trusted networks, branch offices, and known geographic regions, Microsoft Entra ID Protection can't assess location-based risk signals. Not having these policies in place can lead to increased false positives that create alert fatigue and potentially mask genuine threats. This configuration gap prevents the system from distinguishing between legitimate and illegitimate locations. For example, legitimate sign-ins from corporate networks and suspicious authentication attempts from high-risk locations (anonymous proxy networks, Tor exit nodes, or regions where the organization has no business presence). Threat actors can use this uncertainty to conduct credential stuffing attacks, password spray campaigns, and initial access attempts from malicious infrastructure without triggering location-based detections that would normally flag such activity as suspicious. Organizations can also lose the ability to implement adaptive security policies that could automatically apply stricter authentication requirements or block access entirely from untrusted geographic regions. Threat actors can maintain persistence and conduct lateral movement from any global location without encountering location-based security barriers, which should serve as an extra layer of defense against unauthorized access attempts.\n\n**Remediation action**\n\n- [Configure named locations to define trusted IP ranges and geographic regions for enhanced location-based risk detection and Conditional Access policy enforcement](https://learn.microsoft.com/entra/identity/conditional-access/concept-assignment-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "27016",
      "TestMinimumLicense": "Azure WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "Rate Limiting is Enabled in Application Gateway WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Azure Application Gateway Web Application Firewall (WAF) supports rate limiting through custom rules that restrict the number of requests clients can make within a specified time window. Rate limiting is a critical defense mechanism that protects applications from abuse by throttling clients that exceed defined request thresholds. \n\nWithout rate limiting configured, threat actors can execute brute force attacks that attempt thousands of password combinations per minute against authentication endpoints, credential stuffing attacks that test stolen credentials at scale, API abuse that extracts large volumes of data or consumes expensive backend resources, and application-layer denial of service attacks that flood endpoints with requests to exhaust server capacity. \n\nRate limiting rules use the `RateLimitRule` rule type and allow administrators to define thresholds based on request count per minute, with the ability to group requests by client IP address (using `groupBy` with `ClientAddr` variable) to track and limit individual clients. When a client exceeds the configured threshold, the WAF can block subsequent requests, log the violation, or redirect to a custom page. Unlike managed rulesets that detect attack patterns, rate limiting provides a quantitative defense that limits the impact of any volumetric attack regardless of whether the individual requests appear malicious. By configuring rate limiting on Application Gateway WAF, organizations can ensure that no single client can monopolize application resources or execute high-volume automated attacks.\n\n\n**Remediation action**\n\n- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview) - Overview of WAF capabilities on Application Gateway including custom rules\n- [Create and use Web Application Firewall v2 custom rules on Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-custom-waf-rules) - Step-by-step guidance on creating custom rules including rate limiting\n- [Web Application Firewall custom rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/custom-waf-rules-overview) - Detailed documentation of custom rule types including RateLimitRule\n- [Rate limiting in Application Gateway WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/rate-limiting-overview) - Overview of rate limiting capabilities and configuration options\n\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "23183",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "Service principals use safe redirect URIs",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe redirect URIs |App owner tenant |\n| :--- | :--- | :--- | :--- |\n|  | [EAM Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24b12ae7-4648-4aae-b00c-6349a565d24c/appId/e6e0be31-7040-4084-ac44-600b67661f2c) | `2️⃣ https://eamdemo.azurewebsites.net` | 1852b10f-a011-428b-98f9-d09c37d477cf |\n|  | [FIDO2-passkeys-MFA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1aa7e155-cbf8-4970-8458-05a0c7a2d1a5/appId/4fabcfc0-5c44-45a1-8c80-8537f0625949) | `2️⃣ https://fidomfaserver.azurewebsites.net/connect/authorize` | 1852b10f-a011-428b-98f9-d09c37d477cf |\n|  | [Graph Explorer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f8f300a-870a-46ff-bdab-934e1436920d/appId/d3ce4cf8-6810-442d-b42e-375e14710095) | `2️⃣ https://graphexplorer.azurewebsites.net/` | 5508eaf2-e7b4-4510-a4fb-9f5970550d80 |\n|  | [Graph explorer (official site)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cd2e9b58-eb21-4a50-a338-33f9daa1599c/appId/de8bc8b5-d9f9-48b1-a8ad-b748da725064) | `2️⃣ https://graphtryit.azurewebsites.net`, `2️⃣ https://graphtryit.azurewebsites.net/` | 72f988bf-86f1-41af-91ab-2d7cd011db47 |\n|  | [Internal_AccessScope](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/180a3ccb-3f2f-486f-8b56-025fc225166d/appId/3f9bd1ee-5a72-4ad3-b67d-cb016f935bcf) | `1️⃣ http://featureconfiguration.onmicrosoft.com/Internal_AccessScope` | 0d2db716-b331-4d7b-aa37-7f1ac9d35dae |\n|  | [Modern Workplace Concierge](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad1c51e8-f8a8-4bf2-ac09-a3a20cba5fa5/appId/c65c4011-1b90-4ec9-b5e9-1ee17786ad84) | `2️⃣ https://mwconcierge.azurewebsites.net/` | 7955e1b3-cbad-49eb-9a84-e14aed7f3400 |\n|  | [entraChatAppMultiTenant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/855a57ff-88a6-4ad0-85d7-4f46d742730e/appId/5e00b345-a805-42a0-9caa-7d6cb761c668) | `2️⃣ https://entrachatapp.azurewebsites.net`, `2️⃣ https://entrachatapp.azurewebsites.net/redirect` | 8b047ec6-6d2e-481d-acfa-5d562c09f49a |\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "Non-Microsoft and multitenant applications configured with URLs that include wildcards, localhost, or URL shorteners increase the attack surface for threat actors. These insecure redirect URIs (reply URLs) might allow adversaries to manipulate authentication requests, hijack authorization codes, and intercept tokens by directing users to attacker-controlled endpoints. Wildcard entries expand the risk by permitting unintended domains to process authentication responses, while localhost and shortener URLs might facilitate phishing and token theft in uncontrolled environments.\n\nWithout strict validation of redirect URIs, attackers can bypass security controls, impersonate legitimate applications, and escalate their privileges. This misconfiguration enables persistence, unauthorized access, and lateral movement, as adversaries exploit weak OAuth enforcement to infiltrate protected resources undetected.\n\n**Remediation action**\n\n- [Check the redirect URIs for your application registrations.](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) Make sure the redirect URIs don't have localhost, *.azurewebsites.net, wildcards, or URL shorteners.\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21837",
      "TestMinimumLicense": "Free",
      "TestCategory": "Devices",
      "TestTitle": "Limit the maximum number of devices per user to 10",
      "TestSfiPillar": "Protect engineering systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n[Maximum number of devices per user](https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview) is set to 10\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Controlling device proliferation is important. Set a reasonable limit on the number of devices each user can register in your Microsoft Entra ID tenant. Limiting device registration maintains security while allowing business flexibility. Microsoft Entra ID lets users register up to 50 devices by default. Reducing this number to 10 minimizes the attack surface and simplifies device management.\n\n**Remediation action**\n\n- Learn how to [limit the maximum number of devices per user](https://learn.microsoft.com/entra/identity/devices/manage-device-identities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-device-settings).\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "24553",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Windows Update policies are enforced to reduce risk from unpatched vulnerabilities",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nWindows Update policy is assigned and enforced.\n\n\n| Policy Name | Status | Assignment |\n| :---------- | :------------- | :--------- |\n| [PROD](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesWindowsMenu/~/windows10Update) | ✅ Assigned | **Included:** All Devices, **Excluded:** WFgroup |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "If Windows Update policies aren't enforced across all corporate Windows devices, threat actors can exploit unpatched vulnerabilities to gain unauthorized access, escalate privileges, and move laterally within the environment. The attack chain often begins with device compromise via phishing, malware, or exploitation of known vulnerabilities, and is followed by attempts to bypass security controls. Without enforced update policies, attackers leverage outdated software to persist in the environment, increasing the risk of privilege escalation and domain-wide compromise.\n\nEnforcing Windows Update policies ensures timely patching of security flaws, disrupting attacker persistence, and reducing the risk of widespread compromise.\n\n**Remediation action**\n\nStart with [Manage Windows software updates in Intune](https://learn.microsoft.com/intune/device-updates/windows/configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to understand the available Windows Update policy types and how to configure them.\n\nIntune includes the following Windows update policy type: \n- [Windows quality updates policy](https://learn.microsoft.com/intune/device-updates/windows/quality-updates?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to install the regular monthly updates for Windows.*\n- [Expedite updates policy](https://learn.microsoft.com/intune/device-updates/windows/expedite-updates?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to quickly install critical security patches.*\n- [Feature updates policy](https://learn.microsoft.com/intune/device-updates/windows/feature-updates?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Update rings policy](https://learn.microsoft.com/intune/device-updates/windows/update-rings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to manage how and when devices install feature and quality updates.*\n- [Windows driver updates](https://learn.microsoft.com/intune/device-updates/windows/driver-updates?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to update hardware components.*\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "21802",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Microsoft Authenticator app shows sign-in context",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nMicrosoft Authenticator shows application name and geographic location in push notifications.\n\n\n## Microsoft Authenticator settings\n\n\nFeature Settings:\n\n✅ **Application Name**\n- Status: Enabled\n- Include Target: All users\n- Exclude Target: No exclusions\n\n✅ **Geographic Location**\n- Status: Enabled\n- Include Target: All users\n- Exclude Target: No exclusions\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Without sign-in context, threat actors can exploit authentication fatigue by flooding users with push notifications, increasing the chance that a user accidentally approves a malicious request. When users get generic push notifications without the application name or geographic location, they don't have the information they need to make informed approval decisions. This lack of context makes users vulnerable to social engineering attacks, especially when threat actors time their requests during periods of legitimate user activity. This vulnerability is especially dangerous when threat actors gain initial access through credential harvesting or password spraying attacks and then try to establish persistence by approving multifactor authentication (MFA) requests from unexpected applications or locations. Without contextual information, users can't detect unusual sign-in attempts, allowing threat actors to maintain access and escalate privileges by moving laterally through systems after bypassing the initial authentication barrier. Without application and location context, security teams also lose valuable telemetry for detecting suspicious authentication patterns that can indicate ongoing compromise or reconnaissance activities.   \n\n**Remediation action**\nGive users the context they need to make informed approval decisions. Configure Microsoft Authenticator notifications by setting the Authentication methods policy to include the application name and geographic location.  \n- [Use additional context in Authenticator notifications - Authentication methods policy](https://learn.microsoft.com/entra/identity/authentication/how-to-mfa-additional-context?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "21849",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Smart lockout duration is set to a minimum of 60",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSmart Lockout duration is configured to 60 seconds or higher.\n## Smart Lockout Settings\n\n| Setting | Value |\n| :---- | :---- |\n| [Lockout Duration (seconds)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/PasswordProtection/fromNav/) | 60 |\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "When Smart Lockout duration is configured below the default 60 seconds, threat actors can exploit shortened lockout periods to conduct password spray and credential stuffing attacks more effectively. Reduced lockout windows allow attackers to resume authentication attempts more rapidly, increasing their success probability while potentially evading detection systems that rely on longer observation periods. \n\n**Remediation action**\n\n- [Set Smart Lockout duration to 60 seconds or higher](https://learn.microsoft.com/entra/identity/authentication/howto-password-smart-lockout?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#manage-microsoft-entra-smart-lockout-values)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "24545",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Compliance policies protect fully managed and corporate-owned Android devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAt least one compliance policy for Android Enterprise Fully managed devices exists and is assigned.\n\n\n## Compliance policy assignment for Android Enterprise Fully managed device is configured and assigned\n\n| Policy Name | Status | Assignment |\n| :---------- | :----- | :--------- |\n| [My android enterprise policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesComplianceMenu/~/policies) | ✅ Assigned | **Included:** All Users, **Excluded:** testPIM |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If compliance policies aren't assigned to fully managed Android Enterprise devices in Intune, threat actors can exploit noncompliant endpoints to gain unauthorized access to corporate resources, bypass security controls, and persist in the environment. Without enforced compliance, devices can lack critical security configurations such as passcode requirements, data storage encryption, and OS version controls. These gaps increase the risk of data leakage, privilege escalation, and lateral movement. Inconsistent device compliance weakens the organization’s security posture and makes it harder to detect and remediate threats before significant damage occurs.\n\nEnforcing compliance policies ensures Android Enterprise devices meet core security requirements and supports Zero Trust by validating device health and reducing exposure to misconfigured or unmanaged endpoints.\n\n**Remediation action**\n\nCreate and assign Intune compliance policies to fully managed and corporate-owned Android Enterprise devices to enforce organizational standards for secure access and management:  \n- [Create a compliance policy in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/create-compliance-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-policy)\n- [Review the Android Enterprise compliance settings you can manage with Intune](https://learn.microsoft.com/intune/intune-service/protect/compliance-policy-create-android-for-work?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "21818",
      "TestMinimumLicense": "P2",
      "TestCategory": "Monitoring",
      "TestTitle": "Privileged role activations have monitoring and alerting configured",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nRole notifications are not properly configured.\n\nNote: To save time, this check stops when it finds the first role that does not have notifications. After fixing this role and all other roles, we recommend running the check again to verify.\n\n\n## Notifications for high privileged roles\n\n\n| Role Name | Notification Scenario | Notification Type | Default Recipients Enabled | Additional Recipients |\n| :-------- | :-------------------- | :---------------- | :------------------------- | :-------------------- |\n| AI Administrator | Send notifications when members are assigned as eligible to this role | Role assignment alert | True |  |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Organizations without proper activation alerts for highly privileged roles lack visibility into when users access these critical permissions. Threat actors can exploit this monitoring gap to perform privilege escalation by activating highly privileged roles without detection, then establish persistence through admin account creation or security policy modifications. The absence of real-time alerts enables attackers to conduct lateral movement, modify audit configurations, and disable security controls without triggering immediate response procedures.\n\n**Remediation action**\n\n- [Configure Microsoft Entra role settings in Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#require-justification-on-activation)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.5",
      "ZtmmFunctionName": "Visibility & Analytics"
    },
    {
      "TestId": "21783",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Privileged Microsoft Entra built-in roles are targeted with Conditional Access policies to enforce phishing-resistant methods",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSome privileged built-in roles don't have Conditional Access policies to enforce phishing-resistant authentication.\n\n\n\n## Conditional Access policies with phishing resistant authentication policies \n\nFound 4 phishing resistant Conditional Access policies.\n\n  - [MFA CA Policy](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/e589544c-0c92-432e-86ae-4e4ef103eac8)\n  - [Guest-Meferna-Woodgrove-PhishingResistantAuthStrength](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/0f0a0c1c-41b0-4c18-ae20-d02492d03737)\n  - [NewphishingCA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/3fe49849-5ab6-4717-a22d-aa42536eb560) (Disabled)\n  - [Microsoft-managed: Require phishing-resistant multifactor authentication for admins](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/0257f415-12cd-4377-be6a-259c0605e8a5) (Disabled)\n\n\n## Privileged roles\n\nFound 13 of 30 privileged built-in roles protected by phishing resistant authentication.\n\n| Role name | Phishing resistance enforced |\n| :--- | :---: |\n| Application Administrator | ✅ |\n| Authentication Administrator | ✅ |\n| Cloud Application Administrator | ✅ |\n| Conditional Access Administrator | ✅ |\n| Global Administrator | ✅ |\n| Helpdesk Administrator | ✅ |\n| Hybrid Identity Administrator | ✅ |\n| Intune Administrator | ✅ |\n| Password Administrator | ✅ |\n| Privileged Authentication Administrator | ✅ |\n| Privileged Role Administrator | ✅ |\n| Security Administrator | ✅ |\n| User Administrator | ✅ |\n| AI Administrator | ❌ |\n| Application Developer | ❌ |\n| Attribute Provisioning Administrator | ❌ |\n| Attribute Provisioning Reader | ❌ |\n| Authentication Extensibility Administrator | ❌ |\n| Authentication Extensibility Password Administrator | ❌ |\n| B2C IEF Keyset Administrator | ❌ |\n| Cloud Device Administrator | ❌ |\n| Directory Writers | ❌ |\n| Domain Name Administrator | ❌ |\n| External Identity Provider Administrator | ❌ |\n| Global Reader | ❌ |\n| Lifecycle Workflows Administrator | ❌ |\n| Partner Tier1 Support | ❌ |\n| Partner Tier2 Support | ❌ |\n| Security Operator | ❌ |\n| Security Reader | ❌ |\n## Authentication strength policies\n\nFound 2 custom phishing resistant authentication strength policies.\n\n  - [ACSC Maturity Level 3](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n  - [Phishing-resistant MFA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy a Conditional Access policy to target privileged accounts and require phishing resistant credentials](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "21776",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "User consent settings are restricted",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n✅ **Pass**: User consent settings are properly restricted to prevent illicit consent grant attacks.\n\n\n## Authorization Policy Configuration\n\n\n**Current [user consent settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/~/UserSettings)**\n\n- Allow user consent for apps from verified publishers, for selected permissions (Recommended).\nAll users can consent for permissions classified as \"low impact\", for apps from verified publishers or apps registered in this organization.\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Without restricted user consent settings, threat actors can exploit permissive application consent configurations to gain unauthorized access to sensitive organizational data. When user consent is unrestricted, attackers can:\n\n- Use social engineering and illicit consent grant attacks to trick users into approving malicious applications.\n- Impersonate legitimate services to request broad permissions, such as access to email, files, calendars, and other critical business data.\n- Obtain legitimate OAuth tokens that bypass perimeter security controls, making access appear normal to security monitoring systems.\n- Establish persistent access to organizational resources, conduct reconnaissance across Microsoft 365 services, move laterally through connected systems, and potentially escalate privileges.\n\nUnrestricted user consent also limits an organization's ability to enforce centralized governance over application access, making it difficult to maintain visibility into which non-Microsoft applications have access to sensitive data. This gap creates compliance risks where unauthorized applications might violate data protection regulations or organizational security policies.\n\n**Remediation action**\n\n-  [Configure restricted user consent settings](https://learn.microsoft.com/entra/identity/enterprise-apps/configure-user-consent?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to prevent illicit consent grants by disabling user consent or limiting it to verified publishers with low-risk permissions only.\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.4",
      "ZtmmFunctionName": "Access Management"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "When your users send or share encrypted files or emails with people outside your organization, or receive encrypted content from partners, Microsoft Entra ID needs to verify identities. It does this verification for both sides of the send and receive to enforce the encryption settings. If your cross-tenant access settings block access to the Azure Rights Management service, those users see an \"Access is blocked by your organization\" error. In this scenario, they can't open the protected content.\n\nAllow the Microsoft Rights Management Services app by configuring your cross-tenant access settings for both inbound traffic (external users opening content you share) and outbound traffic (your users opening content from partners). Without this configuration, encrypted content sharing breaks, even when the right permissions are assigned.\n\n**Remediation action**\n\n- [Cross-tenant access settings and encrypted content](https://learn.microsoft.com/purview/encryption-azure-ad-configuration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#cross-tenant-access-settings-and-encrypted-content)\n- [Configure cross-tenant access settings for B2B collaboration](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Cross-tenant access settings configured to allow encrypted content sharing",
      "TestPillar": "Data",
      "TestResult": "\n✅ RMS application is allowed (or not restricted) in cross-tenant access policy settings for both inbound and outbound access.\n\n### Cross-Tenant Access Policy (XTAP) RMS Settings\n\n| Policy | Direction | Status | Details |\n|:---|:---|:---|:---|\n| Default | Inbound | ✅ Allowed | B2B Collaboration |\n| Default | Outbound | ✅ Allowed (Implicit) | B2B Collaboration |\n| Partner (48d6943f-580e-40b1-a0e1-c07fa3707873) | Inbound | ✅ Allowed | Explicit Override |\n| Partner (83376efa-bfc4-426c-b2bc-1603ae63e45e) | Outbound | ✅ Allowed | Explicit Override |\n| Partner (1ff50298-fc4f-459b-8460-22f1e3e4f010) | Outbound | ✅ Allowed | Explicit Override |\n\n\n\n\n",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Identity",
      "TestId": "35002",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Investigate"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "When you configure SharePoint with a default label for document libraries, any new files uploaded to that library, or existing files edited in the library will have that label applied if they don't already have a sensitivity label, or they have a sensitivity label but with lower priority. This location-based labeling offers a baseline level of protection and a form of automatic labeling without content inspection. When files aren't labeled, important files can bypass protection and remain vulnerable.\n\nThis configuration is most suitable for document libraries that contain files with the same level of sensitivity. It can be supplemented with auto-labeling policies that uses content inspection, and manual labeling with a higher priority sensitivity label if needed.\n\n**Remediation action**\n\n- [Configure a default sensitivity label for a SharePoint document library](https://learn.microsoft.com/purview/sensitivity-labels-sharepoint-default-label?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Default sensitivity labels are configured for SharePoint document libraries",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SharePointOnline\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "RMS_S_PREMIUM2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "SharePoint Online",
      "TestId": "35008",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.1",
      "ZtmmFunctionName": "Data categorization",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21823",
      "TestMinimumLicense": "Free",
      "TestCategory": "External collaboration",
      "TestTitle": "Guest self-service sign-up via user flow is disabled",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\n[Guest self-service sign up via user flow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/ExternalIdentitiesGettingStarted) is disabled.\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "When guest self-service sign-up is enabled, threat actors can exploit it to establish unauthorized access by creating legitimate guest accounts without requiring approval from authorized personnel. These accounts can be scoped to specific services to reduce detection and effectively bypass invitation-based controls that validate external user legitimacy.\n\nOnce created, self-provisioned guest accounts provide persistent access to organizational resources and applications. Threat actors can use them to conduct reconnaissance activities to map internal systems, identify sensitive data repositories, and plan further attack vectors. This persistence allows adversaries to maintain access across restarts, credential changes, and other interruptions, while the guest account itself offers a seemingly legitimate identity that might evade security monitoring focused on external threats.\n\nAdditionally, compromised guest identities can be used to establish credential persistence and potentially escalate privileges. Attackers can exploit trust relationships between guest accounts and internal resources, or use the guest account as a staging ground for lateral movement toward more privileged organizational assets.\n\n**Remediation action**\n- [Configure guest self-service sign-up With Microsoft Entra External ID](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-self-service-sign-up)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "25380",
      "TestMinimumLicense": [
        "AAD_PREMIUM",
        "Entra_Premium_Internet_Access"
      ],
      "TestCategory": "Global Secure Access",
      "TestTitle": "Global Secure Access signaling for Conditional Access is enabled",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\n❌ Global Secure Access signaling for Conditional Access is disabled. Conditional Access policies do not receive source IP or compliant network signals.\n\n\n\n### [Global Secure Access Conditional Access settings](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Security.ReactView)\n| Property | Value |\n| :--- | :--- |\n| Signaling status | ❌ Disabled |\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "When Global Secure Access routes user traffic through Microsoft's Security Service Edge, the original source IP of the user is replaced by the proxy egress IP. If Global Secure Access signaling for Conditional Access is not enabled, Microsoft Entra ID receives the proxy IP instead of the user's IP. Conditional Access policies that rely on named locations or trusted IP ranges evaluate the proxy IP, which does not correspond to the user's location. A threat actor who compromises user credentials can sign in from any location, and the location-based Conditional Access policy will evaluate the proxy IP, not the threat actor's IP, allowing the sign-in to proceed without triggering a location-based block or step-up authentication. In addition, Microsoft Entra ID Protection risk detections that depend on source IP — such as impossible travel, unfamiliar sign-in properties, and anomalous token — operate on the proxy IP, reducing their ability to detect anomalies. Sign-in logs record the proxy IP, which prevents security operations teams from correlating sign-in events to user locations during incident response. Enabling signaling restores the original source IP to Microsoft Entra ID and Microsoft Graph, and allows Conditional Access to enforce compliant network checks, which verify that the user connects through the Global Secure Access tunnel. \n\n**Remediation actions**\n\n1. [Enable Global Secure Access signaling for Conditional Access in the Microsoft Entra admin center under Global Secure Access > Settings > Session management > Adaptive Access](https://learn.microsoft.com/entra/global-secure-access/how-to-source-ip-restoration)\n\n2. [Understand how Universal Conditional Access works with Global Secure Access traffic profiles](https://learn.microsoft.com/entra/global-secure-access/concept-universal-conditional-access)\n\n3. [Configure compliant network check to require users to connect through Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/how-to-compliant-network)\n\n",
      "TestTags": null,
      "TestImpact": "High",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "24542",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Compliance policies protect macOS devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nNo compliance policy for macOS exists or none are assigned.\n\n\n## macOS Compliance Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [My macOS policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/compliance) | ❌ Not assigned | None |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If compliance policies for macOS devices aren't configured and assigned, threat actors can exploit unmanaged or noncompliant endpoints to gain unauthorized access to corporate resources, bypass security controls, and persist within the environment. Without enforced compliance, macOS devices can lack critical security configurations like data storage encryption, password requirements, and OS version controls. These gaps increase the risk of data leakage, privilege escalation, and lateral movement. Inconsistent device compliance weakens the organization’s security posture and makes it harder to detect and remediate threats before significant damage occurs.\n\nEnforcing compliance policies ensures macOS devices meet core security requirements and supports Zero Trust by validating device health and reducing exposure to misconfigured endpoints.\n\n**Remediation actions**\n\nCreate and assign Intune compliance policies to macOS devices to enforce organizational standards for secure access and management:  \n- [Create and assign Intune compliance policies](https://learn.microsoft.com/intune/intune-service/protect/create-compliance-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-policy)\n- [Review the macOS compliance settings you can manage with Intune](https://learn.microsoft.com/intune/intune-service/protect/compliance-policy-create-mac-os?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": "21790",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "Outbound cross-tenant access settings are configured",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nTenant has a default cross-tenant access setting outbound policy with unrestricted access.\n## [Outbound access settings - Default settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/OutboundAccessSettings.ReactView/isDefault~/true/name//id/)\n### B2B Collaboration\nUsers and groups\n- Access status: blocked\n- Applies to: Selected users and groups (0 users, 1 groups)\n\nExternal applications\n- Access status: blocked\n- Applies to: Selected external applications (2 applications)\n\n### B2B Direct Connect\nUsers and groups\n- Access status: allowed\n- Applies to: All users\n\nExternal applications\n- Access status: allowed\n- Applies to: All external applications\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "Allowing unrestricted external collaboration with unverified organizations can increase the risk surface area of the tenant because it allows guest accounts that might not have proper security controls. Threat actors can attempt to gain access by compromising identities in these loosely governed external tenants. Once granted guest access, they can then use legitimate collaboration pathways to infiltrate resources in your tenant and attempt to gain sensitive information. Threat actors can also exploit misconfigured permissions to escalate privileges and try different types of attacks.\n\nWithout vetting the security of organizations you collaborate with, malicious external accounts can persist undetected, exfiltrate confidential data, and inject malicious payloads. This type of exposure can weaken organizational control and enable cross-tenant attacks that bypass traditional perimeter defenses and undermine both data integrity and operational resilience. Cross-tenant settings for outbound access in Microsoft Entra provide the ability to block collaboration with unknown organizations by default, reducing the attack surface.\n\n**Remediation action**\n\n- [Cross-tenant access overview](https://learn.microsoft.com/entra/external-id/cross-tenant-access-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure cross-tenant access settings](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-default-settings)\n- [Modify outbound access settings](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "When organizations configure Microsoft Entra Private Access with broad application segments—such as wide IP ranges or multiple protocols—they effectively replicate the over-permissive access model of traditional VPNs. This approach contradicts the Zero Trust principle of least-privilege access, where users should only reach the specific resources required for their role. Threat actors who compromise a user's credentials or device can leverage these broad network permissions to perform reconnaissance, identifying additional systems and services within the permitted range. \n\nWith visibility into the network topology, they can escalate privileges by targeting vulnerable systems, move laterally to access sensitive data stores or administrative interfaces, and establish persistence by deploying backdoors across multiple accessible systems. The lack of granular segmentation also complicates incident response, as security teams cannot quickly determine which specific resources a compromised identity could access. By contrast, per-application segmentation with tightly scoped destination hosts, specific ports, and Custom Security Attributes enables dynamic, attribute-driven Conditional Access enforcement—requiring stronger authentication or device compliance for high-risk applications while streamlining access to lower-risk resources. \n\nThis approach aligns with the Zero Trust \"verify explicitly\" principle by ensuring each access request is evaluated against the specific security requirements of the target application rather than applying uniform policies to broad network segments.\n\n**Investigate**: Private Access applications are missing Custom Security Attributes, have CA policies using applicationFilter that require manual review, or no per-app Private Access applications are configured.\n\n**Remediation action**\n- [Transition from Quick Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-per-app-access) to per-app Private Access by creating individual Global Secure Access enterprise applications with specific FQDNs, IP addresses, and ports for each private resource.\n- [Use Application Discovery](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-application-discovery) to identify which resources users access through Quick Access, then create targeted Private Access apps for those resources.\n- [Create Custom Security Attribute sets](https://learn.microsoft.com/en-us/entra/fundamentals/custom-security-attributes-add) and definitions to categorize Private Access applications by risk level, department, or compliance requirements.\n- [Assign Custom Security Attributes](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/custom-security-attributes-apps) to Private Access application service principals to enable attribute-based access control.\n- [Create Conditional Access policies using application filters](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-filter-for-applications) to target Private Access apps based on their Custom Security Attributes, enforcing granular controls like MFA or device compliance.\n- [Apply Conditional Access policies to Private Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-target-resource-private-access-apps) apps from within Global Secure Access for streamlined configuration.\n\n**Review**\n- [Zero Trust network segmentation guidance for software-defined perimeters](https://learn.microsoft.com/en-us/security/zero-trust/deploy/networks#1-network-segmentation-and-software-defined-perimeters)\n\n\n",
      "TestTitle": "Entra Private Access Application segments are defined to enforce least-privilege access",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "High",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25395",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management",
      "TestStatus": "Investigate"
    },
    {
      "TestId": "21772",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "Applications don't have client secrets configured",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound 46 applications and 16 service principals with client secrets configured.\n\n\n## Applications with client secrets\n\n| Application | Secret expiry |\n| :--- | :--- |\n| [AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2e311a1d-f5c0-41c6-b866-77af3289871e) | 2024-02-11 |\n| [Agent Identity Blueprint Example 12612901](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/ef1e370e-626b-4839-9340-83e62875489a) | 2026-05-25 |\n| [Agent Identity Blueprint Example 3792929](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/60253969-9e44-4e0b-85c0-abda1041272c) | 2026-11-02 |\n| [Agent Identity Blueprint Example 4208296](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d0e3212f-58a2-4511-8b56-bd57b023106d) | 2026-02-16 |\n| [Agent Identity Blueprint Example 4208710](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/e79effd2-67cf-4caa-8879-b87389f47819) | 2026-02-16 |\n| [Agent Identity Blueprint Example 4209295](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/f522f080-5192-4665-87a4-e1211b7adca6) | 2026-02-16 |\n| [Agent0 API](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/a8a4a52c-9f15-4e2a-a8fe-c267cc3a6101) | 2026-05-28 |\n| [Atlassian - Jira](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c) | 2026-03-16 |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2325-01-01 |\n| [Chopin Agent](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/7dcdc7c5-09a6-435f-9460-9382d32b7bc6) | 2026-02-18 |\n| [Entry Kiosk](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b903f17a-87b0-460b-9978-962c812e4f98) | 2021-11-25 |\n| [Graph Filter](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975) | 2024-09-16 |\n| [Graph PowerShell - Privileged Perms](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/c5338ce0-3e9e-4895-8f49-5e176836a348) | 2024-05-15 |\n| [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d36fe320-bc28-40c8-a141-a512d65d112c) | 2027-10-26 |\n| [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/fef811e1-2354-43b0-961b-248fe15e737d) | 2022-11-02 |\n| [Lokka](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/f581405a-9e57-4e81-91f1-40cd62f7595e) | 2026-10-01 |\n| [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | 2022-03-29 |\n| [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) | 2026-02-20 |\n| [Mailbox Migration Account](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | 2022-08-19 |\n| [Merill Nov 13 Test](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d65bd82c-b625-48cd-b485-f61939b48727) | 2026-11-02 |\n| [Merill Test Agent](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/e6e0e568-682d-4640-a038-2f2489b1d2aa) | 2026-02-16 |\n| [Merill-Test-Nov13](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/516489b4-b179-4230-b149-440b5c78a7cc) | 2026-11-02 |\n| [MerillTestNov24](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d4407e7a-9644-4e25-8df5-6e6da95a9013) | 2026-02-16 |\n| [Message Center](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/83f76a08-fa60-48e6-9cb5-fd8ced5ae314) | 2026-02-17 |\n| [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) | 2124-02-21 |\n| [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) | 2025-07-06 |\n| [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | 2022-03-29 |\n| [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) | 2023-10-16 |\n| [RemixTest](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d4588485-154e-4b32-935f-31ceaf993cdc) | 2024-06-24 |\n| [SharePoint On-Prem App Proxy](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/19a70df3-cddf-48c7-be44-97b25b9857f1) | 2025-12-12 |\n| [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | 2024-05-15 |\n| [Trello](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d77611ee-5051-4383-9af3-5ba3627306a7) | 2022-08-16 |\n| [WPNinja1](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/eee88dc1-4aab-42b3-b089-4a2cbb19b048) | 2026-05-24 |\n| [WebApplication3](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/bcdb1ed5-9470-41e6-821b-1fc42ae94cfb) | 2022-11-02 |\n| [WebApplication3_20210211261232](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/ac49e193-bd5f-40fe-b4ff-e62136419388) | 2022-11-02 |\n| [WebApplication4](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b2d1f868-27ee-4ecd-ae81-0ee96b028605) | 2022-04-03 |\n| [WingtipToys App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/56a89db1-6ed2-4171-88f6-b4f7597dbce3) | 2025-11-27 |\n| [aadgraphmggraph](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/24b66505-1142-452f-9472-2ecbb37deac1) | 2022-11-26 |\n| [agent0-blueprint](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/00b6bee4-a638-4260-9382-09301b3a1db9) | 2026-02-27 |\n| [da-typespec-todo-aad](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/9358444a-41ec-4a93-915a-4970b3f33738) | 2026-06-04 |\n| [entra-docs-email github DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/ae06b71a-a0aa-4211-b846-fd74f25ccd45) | 2027-07-14 |\n| [sptest1](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/022dac2c-8763-4a45-bc41-34cf58e8e35d) | 2026-08-02 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/99fbef85-8df4-44c5-ac4e-ec93a88a9b5b) | 2026-08-15 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/4f50c653-dae4-44e7-ae2e-a081cce1f830) | 2023-02-25 |\n| [testSP](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/e47d8f25-5327-40f8-99fe-d832b99d938d) | 2026-05-26 |\n| [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) | 2025-09-03 |\n\n\n## Service Principals with client secrets\n\n| Service principal | App owner tenant | Secret expiry |\n| :--- | :--- | :--- |\n| [21869testapp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/dd63d132-18fb-4f2e-aec4-82b97f30301f/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-10-27 |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/76249b01-8747-4db4-843f-6478d5b32b14/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-07-30 |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-10-26 |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/dc7d83b5-d38b-4488-8952-7abf02e71590/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2027-03-03 |\n| [Azure AD SAML Toolkit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/6f5ed68c-9fad-4d78-bf88-2b16bbe16338/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-10-11 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-02-17 |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-01-07 |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-07-30 |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-06-11 |\n| [SPO Version](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/2d6d9bf1-1f6e-48cf-bb02-31beec2f442e/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-11-17 |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-10-02 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-11-17 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-02-15 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2027-02-15 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-02-26 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-10-10 |\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Applications that use client secrets might store them in configuration files, hardcode them in scripts, or risk their exposure in other ways. The complexities of secret management make client secrets susceptible to leaks and attractive to attackers. Client secrets, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's client secret, they can escalate their privileges within the system, leading to broader access and control, depending on the permissions of the application.\n\nApplications and service principals that have permissions for Microsoft Graph APIs or other APIs have a higher risk because an attacker can potentially exploit these additional permissions.\n\n**Remediation action**\n\n- [Move applications away from shared secrets to managed identities and adopt more secure practices](https://learn.microsoft.com/entra/identity/enterprise-apps/migrate-applications-from-secrets?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n   - Use managed identities for Azure resources\n   - Deploy Conditional Access policies for workload identities\n   - Implement secret scanning\n   - Deploy application authentication policies to enforce secure authentication practices\n   - Create a least-privileged custom role to rotate application credentials\n   - Ensure you have a process to triage and monitor applications\n",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "26886",
      "TestMinimumLicense": [
        "DDoS_Network_Protection",
        "DDoS_IP_Protection"
      ],
      "TestCategory": "Azure Network Security",
      "TestTitle": "Diagnostic logging is enabled for DDoS-protected public IPs",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "When Azure DDoS Protection is enabled for public IP addresses, diagnostic logging provides critical visibility into attack patterns, mitigation actions, and traffic flow data. Without diagnostic logs enabled, security teams lack the observability needed to understand attack characteristics, validate mitigation effectiveness, and perform post-incident analysis. Azure DDoS Protection generates three categories of diagnostic logs: DDoSProtectionNotifications (alerts when attacks are detected and when mitigation starts/stops), DDoSMitigationFlowLogs (detailed flow-level information during active attack mitigation), and DDoSMitigationReports (comprehensive attack summaries with traffic statistics and mitigation actions). These logs are essential for security operations to detect ongoing attacks, investigate incidents, meet compliance requirements, and tune protection policies. The absence of logging prevents correlation of network events with other security telemetry, eliminating the ability to construct attack timelines during incident investigations. Furthermore, compliance frameworks such as PCI-DSS, HIPAA, and SOC 2 require organizations to maintain audit logs of network security events, and the lack of DDoS diagnostic logging creates audit failures.\n\n**Remediation action**\n\nConfigure diagnostic settings for DDoS-protected public IP addresses\n- [Configure Azure DDoS Protection diagnostic logging](https://learn.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging)\n\nView and configure DDoS diagnostic logs in the Azure portal\n- [View and configure DDoS diagnostic logging](https://learn.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging#configure-ddos-diagnostic-logs)\n\nCreate a Log Analytics workspace for storing DDoS Protection logs\n- [Create a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/quick-create-workspace)\n\nMonitor and analyze DDoS attack telemetry\n- [Azure DDoS Protection monitoring and logging](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview#monitoring-and-logging)\n\nView and analyze DDoS logs for incident investigation\n- [Tutorial: View and analyze DDoS logs](https://learn.microsoft.com/en-us/azure/ddos-protection/view-logs)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": "21850",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "Smart lockout threshold set to 10 or less",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nSmart lockout threshold is configured above 10.\n## Smart lockout configuration\n\n| Setting | Value |\n| :---- | :---- |\n| [Lockout threshold](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/PasswordProtection/fromNav/) | 11 attempts|\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "When the smart lockout threshold is set to more than 10, threat actors can exploit the configuration to conduct reconnaissance, identify valid user accounts without triggering lockout protections, and establish initial access without detection. Once attackers gain initial access, they can move laterally through the environment by using the compromised account to access resources and escalate privileges.\n\nSmart lockout helps lock out bad actors who try to guess your users' passwords or use brute force methods to get in. Smart lockout recognizes sign-ins that come from valid users and treats them differently than ones of attackers and other unknown sources. A threshold of more than 10 provides insufficient protection against automated password spray attacks, making it easier for threat actors to compromise accounts while evading detection mechanisms. \n\n**Remediation action**\n\n- [Set Microsoft Entra smart lockout threshold to 10 or less](https://learn.microsoft.com/entra/identity/authentication/howto-password-smart-lockout?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "26880",
      "TestMinimumLicense": "Azure WAF",
      "TestCategory": "Azure Network Security",
      "TestTitle": "Request Body Inspection is enabled in Azure Front Door WAF",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "Azure Front Door Web Application Firewall (WAF) provides centralized protection for web applications against common exploits and vulnerabilities. Request body inspection is a critical capability that allows the WAF to analyze the content of HTTP POST, PUT, and PATCH request bodies for malicious patterns. When request body inspection is disabled, threat actors can craft attacks that embed malicious SQL statements, scripts, or command injection payloads within form submissions, API calls, or file uploads that bypass all WAF rule evaluation. This creates a direct path for exploitation where threat actors gain initial access through unprotected application endpoints, execute arbitrary commands or queries against backend databases through SQL injection, exfiltrate sensitive data including credentials and customer information, establish persistence by modifying application data or injecting backdoors, and pivot to internal systems through compromised application server credentials. The WAF's managed rule sets, including OWASP Core Rule Set and Microsoft's threat intelligence-based rules, cannot evaluate threats they cannot see; disabling request body inspection renders these protections ineffective against body-based attack vectors that represent the majority of modern web application attacks.\n\n**Remediation action**\n\nOverview of WAF capabilities on Azure Front Door including request body inspection\n- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)\n\nDetailed guidance on configuring WAF policy settings including request body inspection\n- [Policy settings for Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-policy-settings)\n\nBest practices for tuning WAF including request body inspection limits\n- [Tuning Azure Web Application Firewall for Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-tuning)\n\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestId": "21819",
      "TestMinimumLicense": "P2",
      "TestCategory": "Privileged access",
      "TestTitle": "Activation alert for Global Administrator role assignments",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nActivation alerts are missing or improperly configured for Global Administrator role.\n\n| Role display name | Default recipients | Additional recipients |\n| :---------------- | :----------------- | :------------------- |\n| [Global Administrator](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles) | ❌ Disabled | - |\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Without activation alerts for Global Administrator role assignments, threat actors can escalate privileges undetected. This lack of visibility creates a blind spot where attackers can activate the most privileged role and perform malicious actions such as creating backdoor accounts, modifying security policies, or accessing sensitive data.\n\nMonitoring these activation alerts can help security teams distinguish between authorized and unauthorized privilege escalation activities. \n\n**Remediation action**\n\n- [Configure notifications for privileged roles](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#require-justification-on-active-assignment)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.5",
      "ZtmmFunctionName": "Visibility & Analytics"
    },
    {
      "TestId": "21804",
      "TestMinimumLicense": "P1",
      "TestCategory": "Credential management",
      "TestTitle": "SMS and Voice Call authentication methods are disabled",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nFound weak authentication methods that are still enabled.\n\n## Weak authentication methods\n| Method ID | Is method weak? | State |\n| :-------- | :-------------- | :---- |\n| Sms | Yes | enabled |\n| Voice | Yes | disabled |\n\n\n",
      "TestStatus": "Investigate",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "When weak authentication methods like SMS and voice calls remain enabled in Microsoft Entra ID, threat actors can exploit these vulnerabilities through multiple attack vectors. Initially, attackers often conduct reconnaissance to identify organizations using these weaker authentication methods through social engineering or technical scanning. Then they can execute initial access through credential stuffing attacks, password spraying, or phishing campaigns targeting user credentials.\n\nOnce basic credentials are compromised, threat actors use these weaknesses in SMS and voice-based authentication. SMS messages can be intercepted through SIM swapping attacks, SS7 network vulnerabilities, or malware on mobile devices, while voice calls are susceptible to voice phishing (vishing) and call forwarding manipulation. With these weak second factors bypassed, attackers achieve persistence by registering their own authentication methods. Compromised accounts can be used to target higher-privileged users through internal phishing or social engineering, allowing attackers to escalate privileges within the organization. Finally, threat actors achieve their objectives through data exfiltration, lateral movement to critical systems, or deployment of other malicious tools, all while maintaining stealth by using legitimate authentication pathways that appear normal in security logs. \n\n**Remediation action**\n\n- [Deploy authentication method registration campaigns to encourage stronger methods](https://learn.microsoft.com/graph/api/authenticationmethodspolicy-update?view=graph-rest-beta&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Disable authentication methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Disable phone-based methods in legacy MFA settings](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-mfasettings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policies using authentication strength](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strength-how-it-works?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.1",
      "ZtmmFunctionName": "Authentication"
    },
    {
      "TestId": "24575",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Device",
      "TestTitle": "Defender Antivirus policies protect Windows devices from malware",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nNo relevant Windows Defender Antivirus policies are configured or assigned.\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "If policies for Microsoft Defender Antivirus aren't properly configured and assigned in Intune, threat actors can exploit unprotected endpoints to execute malware, disable antivirus protections, and persist within the environment. Without enforced antivirus policies, devices operate with outdated definitions, disabled real-time protection, or misconfigured scan schedules. These gaps allow attackers to bypass detection, escalate privileges, and move laterally across the network. The absence of antivirus enforcement undermines device compliance, increases exposure to zero-day threats, and can result in regulatory noncompliance. Attackers leverage these weaknesses to maintain persistence and evade detection, especially in environments lacking centralized policy enforcement.\n\nEnforcing Defender Antivirus policies ensures consistent protection against malware, supports real-time threat detection, and aligns with Zero Trust by maintaining a secure and compliant endpoint posture.\n\n**Remediation action**\n\nConfigure and assign Intune policies for Microsoft Defender Antivirus to enforce real-time protection, maintain up-to-date definitions, and reduce exposure to malware:\n\n- [Configure Intune policies to manage Microsoft Defender Antivirus](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-antivirus-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#windows)\n- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)\n",
      "TestTags": null,
      "TestImpact": "Low",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.4",
      "ZtmmFunctionName": "Device threat detection"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Collection Policies provide the data ingestion layer that supports monitoring of enterprise AI app activity. When these policies are in place, Communication Compliance can collect signals from AI app interactions and help organizations understand where data protection risks may exist across AI‑enabled workflows. This visibility helps teams apply data protection controls more consistently as AI use expands beyond Microsoft Copilot.\n\t\t\nIn practice, users may accidentally share sensitive data with custom AI applications, Power Automate flows, AI Builder automations, or non‑Microsoft AI services that aren’t approved to handle confidential information. However, Communication Compliance policies that cover enterprise AI app interactions can help surface potential data exposure to these services and extend data protection practices to custom and third‑party AI solutions.\n\n**Remediation action**\n\n- [Create and Deploy collection policies](https://learn.microsoft.com/purview/collection-policies-create-deploy-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create and manage Communication Compliance policies](https://learn.microsoft.com/purview/communication-compliance-policies?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Communication compliance monitoring is configured for enterprise AI tools",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Data Security Posture Management",
      "TestId": "35040",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Failed"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Auto-labeling greatly extends your labeling reach, by automatically labeling items based on content inspection. When you rely on just manual labeling, users might not always recognize what counts as sensitive data or might forget to label information during their daily tasks. Default labels offer a baseline of protection but don't take into consideration content that requires a higher level of protection. This leads to gaps in classification, allowing sensitive content to move through Microsoft 365 applications without proper labels or protection.\n\nYou can configure auto-labeling settings for labels that trigger when users open files in their Office apps, and auto-labeling policies that require no user interactions. Setting up at least one auto-labeling policy to detect sensitive content automatically labels this content, no matter what actions people take. In turn, this labeled content can be used with other Microsoft Purview solutions to increase your security, such as data loss prevention (DLP) rules and access restrictions.\n\n**Remediation action**\n\n- [Automatically apply a sensitivity label to Microsoft 365 data](https://learn.microsoft.com/purview/apply-sensitivity-label-automatically?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Auto-labeling policies are configured for all Microsoft 365 workloads",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Information Protection",
      "TestId": "35019",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21814",
      "TestMinimumLicense": "Free",
      "TestCategory": "Privileged access",
      "TestTitle": "Privileged accounts are cloud native identities",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nThis tenant has 3 privileged users that are synced from on-premise.\n\n## Privileged Roles\n\n| Role Name | User | Source | Status |\n| :--- | :--- | :--- | :---: |\n| Global Administrator | [Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0145d508-50fd-4f86-a47a-bf1c043c8358) | Synced from on-premise | ❌ |\n| Global Administrator | [Gael Colas](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0b37813c-ae19-4399-982f-16587f17f9c0) | Cloud native identity | ✅ |\n| Global Administrator | [Ravi Kalwani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1433571b-3d7c-4a56-a9cc-67580848bc73) | Cloud native identity | ✅ |\n| Global Administrator | [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6) | Cloud native identity | ✅ |\n| Global Administrator | [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165) | Cloud native identity | ✅ |\n| Global Administrator | [Ty Grady](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/210d3e96-015f-462d-b6d6-81e6023263df) | Cloud native identity | ✅ |\n| Global Administrator | [Ty Grady Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/43482f27-d1af-420f-84ba-e9148a700f45) | Cloud native identity | ✅ |\n| Global Administrator | [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e) | Cloud native identity | ✅ |\n| Global Administrator | [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/518ce209-faf4-4717-add9-7129a669fa11) | Cloud native identity | ✅ |\n| Global Administrator | [Bagul Atayewa](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5655cf54-34bc-4f36-bb74-44da35547975) | Synced from on-premise | ❌ |\n| Global Administrator | [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a) | Cloud native identity | ✅ |\n| Global Administrator | [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003) | Cloud native identity | ✅ |\n| Global Administrator | [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7e92f268-bb12-469a-a869-210d596d4c1f) | Cloud native identity | ✅ |\n| Global Administrator | [Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91) | Cloud native identity | ✅ |\n| Global Administrator | [Varsha Mane](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/a85798bd-652b-4eb9-ba90-3ee882df0179) | Cloud native identity | ✅ |\n| Global Administrator | [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a) | Cloud native identity | ✅ |\n| Global Administrator | [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d) | Cloud native identity | ✅ |\n| Global Administrator | [Afif Ahmed](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/c0b65b13-37b1-4081-bcfc-14844159b4a5) | Cloud native identity | ✅ |\n| Global Administrator | [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854) | Cloud native identity | ✅ |\n| Global Administrator | [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/df02402a-e291-42cc-b449-79366daa2a40) | Cloud native identity | ✅ |\n| Global Administrator | [Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b) | Cloud native identity | ✅ |\n| Global Administrator | [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6) | Cloud native identity | ✅ |\n| Global Reader | [Afif](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/0d6cfd05-fc46-440b-b605-66dd26dcd7d2) | Cloud native identity | ✅ |\n| Global Reader | [chukka.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6) | Cloud native identity | ✅ |\n| Global Reader | [sandeep.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/518ce209-faf4-4717-add9-7129a669fa11) | Cloud native identity | ✅ |\n| Global Reader | [Anna Jorayew](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/58d9ed99-93ca-4674-8c5f-ec770f5ba17d) | Synced from on-premise | ❌ |\n| Global Reader | [Aahmed Test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/6f467d0a-25ec-435c-8fb9-9d53eb21e02f) | Cloud native identity | ✅ |\n| Global Reader | [Komal.p](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7e92f268-bb12-469a-a869-210d596d4c1f) | Cloud native identity | ✅ |\n| Global Reader | [Manoj Kesana](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/990fd38a-c516-4e3f-82e4-d458a1ab0f91) | Cloud native identity | ✅ |\n| Global Reader | [praneeth-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/c1bdb03c-0079-40b1-96a8-3595de3b94a2) | Cloud native identity | ✅ |\n| Global Reader | [ash-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/c5c8ba63-4620-4e91-ac40-b66bebe07a0d) | Cloud native identity | ✅ |\n| Global Reader | [manoj-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/d71ccc09-c0a3-4604-9d02-49f7a3715f49) | Cloud native identity | ✅ |\n| Global Reader | [perennial_ash](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/df02402a-e291-42cc-b449-79366daa2a40) | Cloud native identity | ✅ |\n| Global Reader | [komal-test](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/e0952dcb-8d63-496d-8661-05c86c1a51f0) | Cloud native identity | ✅ |\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "If an on-premises account is compromised and is synchronized to Microsoft Entra, the attacker might gain access to the tenant as well. This risk increases because on-premises environments typically have more attack surfaces due to older infrastructure and limited security controls. Attackers might also target the infrastructure and tools used to enable connectivity between on-premises environments and Microsoft Entra. These targets might include tools like Microsoft Entra Connect or Active Directory Federation Services, where they could impersonate or otherwise manipulate other on-premises user accounts.\n\nIf privileged cloud accounts are synchronized with on-premises accounts, an attacker who acquires credentials for on-premises can use those same credentials to access cloud resources and move laterally to the cloud environment.\n\n**Remediation action**\n\n- [Protecting Microsoft 365 from on-premises attacks](https://learn.microsoft.com/entra/architecture/protect-m365-from-on-premises-attacks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#specific-security-recommendations)\n\nFor each role with high privileges (assigned permanently or eligible through Microsoft Entra Privileged Identity Management), you should do the following actions:\n\n- Review the users that have onPremisesImmutableId and onPremisesSyncEnabled set. See [Microsoft Graph API user resource type](https://learn.microsoft.com/graph/api/resources/user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Create cloud-only user accounts for those individuals and remove their hybrid identity from privileged roles.\n",
      "TestTags": [
        "PrivilegedIdentity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.2",
      "ZtmmFunctionName": "Identity Stores"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Until organizations configure Communication Compliance policies to capture Copilot interactions, they can’t see when users expose sensitive data to AI services. They also can’t tell how people use Copilot with confidential information or spot possible policy violations. As a result, users may unknowingly share customer records, financial data, source code, or trade secrets with AI services.\n\nCommunication Compliance policies that focus on Copilot interactions give organizations clear oversight of AI use while respecting privacy controls. These policies show how users work with sensitive data in AI features and help ensure teams follow data governance and compliance requirements.\n\n**Remediation action**\n\n- [Create and manage Communication Compliance policies](https://learn.microsoft.com/purview/communication-compliance-policies?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Communication compliance monitoring is configured for Microsoft Copilot",
      "TestPillar": "Data",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestMinimumLicense": [
        "EXCHANGE_S_ENTERPRISE"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Data Security Posture Management",
      "TestId": "35039",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data labeling and tagging",
      "TestStatus": "Passed"
    },
    {
      "TestId": "25393",
      "TestMinimumLicense": [
        "AAD_PREMIUM",
        "Entra_Premium_Private_Access"
      ],
      "TestCategory": "Global Secure Access",
      "TestTitle": "Quick Access is enabled and bound to a connector",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nQuick Access is not bound to a connector group with active connectors, or the Private Access traffic forwarding profile is not enabled.\n\n\n## [Quick Access Connector Binding Status](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/QuickAccessMenuBlade/~/GlobalSecureAccess)\n\n| Property | Value |\n| :--- | :--- |\n| Private Access Profile State | disabled |\n| Connector Group Name | Default |\n| Quick Access App Assigned | Yes |\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "When Quick Access is not configured or is not bound to a connector group with connectors, private network resources remain accessible through paths that bypass Global Secure Access controls. Threat actors who compromise user credentials can access internal FQDNs and IP ranges without Conditional Access evaluation, because the traffic does not route through the Global Secure Access service. Without connector-mediated traffic brokering, there is no enforcement point between the user and the private resource, which means Conditional Access policies targeting the Quick Access enterprise application do not apply. A threat actor can use stolen credentials to authenticate, reach internal resources over a VPN or direct network path, move between internal systems, and exfiltrate data without the organization having visibility through Global Secure Access traffic logs. Binding Quick Access to a connector group with connectors ensures that private network traffic routes through Global Secure Access, where Conditional Access policies, user assignments, and traffic logging apply.\n\n**Remediation action**\n\nConfigure Quick Access and connectors for Entra Private Access, and ensure the Private Access forwarding profile is enabled:\n- [Configure Quick Access for Global Secure Access Private Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-quick-access)\n- [Configure connectors for Global Secure Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-connectors)\n- [Enable the Private Access traffic forwarding profile](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-private-access-profile)\n- [Understand Microsoft Entra Private Access concepts](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-private-access)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Network",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestId": "21831",
      "TestMinimumLicense": "P1",
      "TestCategory": "Privileged access",
      "TestTitle": "Protected actions are enabled for high-impact management tasks",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Threat actors who gain privileged access to a tenant can manipulate identity, access, and security configurations. This type of attack can result in environment-wide compromise and loss of control over organizational assets. Take action to protect high-impact management tasks associated with Conditional Access policies, cross-tenant access settings, hard deletions, and network locations that are critical to maintaining security.\n\nProtected actions let administrators secure these tasks with extra security controls, such as stronger authentication methods (passwordless MFA or phishing-resistant MFA), the use of Privileged Access Workstation (PAW) devices, or shorter session timeouts.\n\n**Remediation action**\n\n- [Add, test, or remove protected actions in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/role-based-access-control/protected-actions-add?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics"
    },
    {
      "TestId": "21854",
      "TestMinimumLicense": null,
      "TestCategory": "Privileged access",
      "TestTitle": "Privileged roles aren't assigned to stale identities",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Privileged roles should not remain assigned to identities that show no recent sign-in activity. Stale accounts with administrative privileges are attractive targets for attackers because they can be compromised without triggering behavioral analytics alerts. Regularly reviewing and removing privileged role assignments from inactive identities reduces the risk of credential-based attacks and helps maintain least-privilege access.\n\n**Remediation action**\n\n- [Review privileged role assignments using access reviews](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-create-roles-and-resource-roles-review?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Remove privileged role assignments from inactive identities](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-resource-roles-assign-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#update-or-remove-an-existing-role-assignment)\n- [Configure automated access reviews for privileged roles](https://learn.microsoft.com/entra/id-governance/access-reviews-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.6",
      "ZtmmFunctionName": "Automation & Orchestration"
    },
    {
      "TestId": "21793",
      "TestMinimumLicense": "P1",
      "TestCategory": "Application management",
      "TestTitle": "Tenant restrictions v2 policy is configured",
      "TestSfiPillar": "Protect networks",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nTenant Restrictions v2 policy is properly configured.\n\n\n## Tenant restriction settings\n\n\n| Policy Configured | External users and groups | External applications |\n| :---------------- | :------------------------ | :-------------------- |\n| [Yes](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/TenantRestrictions.ReactView/isDefault~/true/name//id/) | All external users and groups | All external applications |\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "Medium",
      "TestRisk": "High",
      "TestDescription": "Tenant Restrictions v2 (TRv2) allows organizations to enforce policies that restrict access to specified Microsoft Entra tenants, preventing unauthorized exfiltration of corporate data to external tenants using local accounts. Without TRv2, threat actors can exploit this vulnerability, which leads to potential data exfiltration and compliance violations, followed by credential harvesting if those external tenants have weaker controls. Once credentials are obtained, threat actors can gain initial access to these external tenants. TRv2 provides the mechanism to prevent users from authenticating to unauthorized tenants. Otherwise, threat actors can move laterally, escalate privileges, and potentially exfiltrate sensitive data, all while appearing as legitimate user activity that bypasses traditional data loss prevention controls focused on internal tenant monitoring.\n\nImplementing TRv2 enforces policies that restrict access to specified tenants, mitigating these risks by ensuring that authentication and data access are confined to authorized tenants only. \n\nIf this check passes, your tenant has a TRv2 policy configured but more steps are required to validate the scenario end-to-end.\n\n**Remediation action**\n- [Set up Tenant Restrictions v2](https://learn.microsoft.com/entra/external-id/tenant-restrictions-v2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "35041",
      "TestMinimumLicense": [
        "Microsoft 365 E5",
        "Microsoft Purview PAYG"
      ],
      "TestCategory": "Data Security Posture Management",
      "TestTitle": "Browser data loss prevention is enabled for AI apps via Edge for Business",
      "TestSfiPillar": "Protect tenants and production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"SecurityCompliance\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "High",
      "TestRisk": "Medium",
      "TestDescription": "Browser Data Loss Prevention (DLP) for cloud apps in Microsoft Edge for Business prevents users from uploading, downloading, copying, or pasting sensitive data to and from unmanaged cloud AI services (ChatGPT, Google Gemini, Claude, etc.) directly through the browser. Without Browser DLP policies for AI apps configured, users can access consumer AI services through Edge for Business and exfiltrate sensitive organizational data by uploading files or pasting confidential information, circumventing cloud-based DLP controls.\n\nBrowser DLP acts as the final enforcement point at the browser level, blocking data transfers to AI services even if data governance policies allow access to the service itself. Organizations using Microsoft 365 Copilot or allowing employee access to generative AI tools must enable Browser DLP policies targeting unmanaged AI apps to prevent uncontrolled data exposure. Browser DLP for AI apps requires PAYG billing activation, Intune-managed devices, and Edge for Business deployment to function.\n\n**Remediation action**\n\n**To enable Browser DLP for AI Apps (Minimal Setup):**\n\n1. **Activate PAYG Billing** (One-time setup)\n   - Navigate to [Purview Settings > Account](https://purview.microsoft.com/settings/account)\n   - Enable \"Purview Pay-as-You-Go billing\"\n   - Activate trial or start paid subscription\n   - This is the only hard requirement\n\n2. **Create Browser DLP Policy** (via Purview UI)\n   - Navigate to [Microsoft Purview portal](https://purview.microsoft.com)\n   - Data Loss Prevention > Policies > + Create policy\n   - Choose \"Custom\" policy template\n   - Name: \"Browser DLP - AI Apps\" (or similar)\n   - Add locations: Select \"Edge for Business\"\n   - Add cloud apps: Select \"All unmanaged AI apps\" OR add specific apps manually\n   - Configure scope: All users or specific groups\n   - Create rule:\n     - Name: \"Block Sensitive Data to Unmanaged AI Apps\"\n     - Condition: Content contains [pick sensitive info types: credit card, SSN, bank account, etc.]\n     - Action: \"Restrict browser activities\" > Block file uploads and text sharing to unmanaged apps\n   - Incident reports: Enable alerts for rule matches\n   - Policy mode: Start with \"Simulate\" (TestWithoutNotifications) for testing\n   - Enable policy\n\n3. **Deployment Requirements**\n   - Managed devices: Intune enrollment required (Windows 10/11)\n   - Browser: Edge for Business v144+\n   - Microsoft Edge management automatically syncs policy\n\n4. **Validation**\n   - Navigate to Activity Explorer in Purview\n   - Filter: Enforcement Plane = \"Browser\"\n   - Monitor for browser DLP activities\n   - Review [Microsoft Defender](https://security.microsoft.com) for related alerts\n\n**Optional Enhancement: Add Collection Policies** (Data classification layer)\n- If you want more granular data classification, create collection policies targeting AI apps\n- Collection policies define what data to monitor (optional for basic protection)\n- Link collection policies to Browser DLP rules (if UI supports linking)\n\n**Via PowerShell (After PAYG activation):**\n```powershell\nConnect-ExchangeOnline\nConnect-IPPSSession\n\n# List browser DLP policies\nGet-DlpCompliancePolicy | Where-Object { $_.EnforcementPlanes -contains \"Browser\" } | Select-Object Name, Enabled, Mode\n\n# Enable specific policy\nSet-DlpCompliancePolicy -Identity <PolicyGUID> -Enabled $true\n\n# List rules for browser policy\nGet-DlpCompliancePolicy | Where-Object { $_.EnforcementPlanes -contains \"Browser\" } | ForEach-Object { Get-DlpComplianceRule -Policy $_.Identity }\n```\n\n**For more information:**\n- [Learn about Browser DLP for Cloud Apps](https://learn.microsoft.com/en-us/purview/dlp-browser-dlp-learn)\n- [Create policy for browser cloud app protection](https://learn.microsoft.com/en-us/purview/dlp-create-policy-prevent-cloud-sharing-from-edge-biz)\n- [Create policy for AI app protection](https://learn.microsoft.com/en-us/purview/dlp-create-policy-block-to-ai-via-edge)\n- [Billing and PAYG activation](https://learn.microsoft.com/en-us/purview/purview-billing-models)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Data",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.5",
      "ZtmmFunctionName": "Data Encryption"
    },
    {
      "TestId": "21800",
      "TestMinimumLicense": "P1",
      "TestCategory": "Monitoring",
      "TestTitle": "All user sign-in activity uses strong authentication methods",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.\n\nAttackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.\n\n**Remediation action**\n\n- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy a Conditional Access policy to require phishing-resistant MFA for all users](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "5.2",
      "ZtmmFunctionName": "Data Categorization"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "The private network connector is a key component of Microsoft Entra Private Access and Application Proxy. To maintain security, stability, and performance, all connector machines must run the latest software version.\n\nIf your connectors don't run the latest version:\n\n- They might be missing critical security patches, which leaves connectors vulnerable to known exploits.\n- You don't get the latest performance improvements and bug fixes, which can affect reliability.\n- Compatibility problems might arise with the Global Secure Access service as it evolves.\n\n**Remediation action**\n\n- [Configure private network connectors for Microsoft Entra Private Access and Microsoft Entra application proxy](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Verify that all your connectors are up to date and install the latest [connector updates](https://learn.microsoft.com/entra/global-secure-access/concept-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#connector-updates).\n",
      "TestTitle": "Private network connectors are running the latest version",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Private Access",
      "TestId": "25392",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Failed"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "High",
      "SkippedReason": null,
      "TestDescription": "When default outbound B2B collaboration settings allow all users to access all applications in any external Microsoft Entra organization, organizations can't control where corporate data flows or who employees collaborate with. Users might intentionally or accidentally upload sensitive data to external tenants, accept invitations from spoofed or malicious tenants designed for phishing, or grant OAuth consent to risky applications that compromise corporate data.\n\nFor regulated industries, unrestricted external collaboration might violate data residency requirements or prohibitions on sharing data with unapproved organizations.\n\nBy blocking default outbound B2B collaboration, organizations enforce a deny-by-default posture that restricts external relationships to vetted partners, protects intellectual property, and ensures visibility over every cross-tenant collaboration.\n\n**Remediation action**\n- Learn about cross-tenant access settings and planning considerations before making changes. For more information, see [Cross-tenant access overview](https://learn.microsoft.com/entra/external-id/cross-tenant-access-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Use the cross-tenant access activity workbook to identify current external collaboration patterns before blocking default access. For more information, see [Cross-tenant access activity workbook](https://learn.microsoft.com/entra/identity/monitoring-health/workbook-cross-tenant-access-activity?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Configure default outbound B2B collaboration settings to block access. For more information, see [Modify outbound access settings](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#modify-outbound-access-settings).\n- Add organization-specific settings for approved partner tenants that require B2B collaboration. For more information, see [Add an organization](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#add-an-organization).\n- Update default cross-tenant access policy via Microsoft Graph API. For more information, see [Update default cross-tenant access policy](https://learn.microsoft.com/graph/api/crosstenantaccesspolicyconfigurationdefault-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "External collaboration is governed by explicit Cross-Tenant Access Policies",
      "TestPillar": "Network",
      "TestResult": "\n⚠️ Default outbound B2B collaboration has partial restrictions configured; review settings to ensure they align with organizational security policies.\n\n\n## [Default Cross-tenant access settings - Outbound B2B collaboration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/CrossTenantAccessSettings)\n\n| Setting | Configured value | Expected value | Status |\n| :------ | :--------------- | :------------- | :----: |\n| Is service default | false | false | ✅ |\n| Users and groups access type | blocked | blocked | ✅ |\n| Users and groups target | OutboundAccess | AllUsers | ❌ |\n| Applications access type | blocked | blocked | ✅ |\n| Applications target | Office365, AADReporting | AllApplications | ❌ |\n\n\n",
      "TestSfiPillar": "Protect identities and secrets",
      "TestMinimumLicense": [
        "AAD_PREMIUM",
        "AAD_PREMIUM_P2"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "External Identities",
      "TestId": "25378",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.7",
      "ZtmmFunctionName": "Governance",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21912",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "Azure resources used by Microsoft Entra only allow access from privileged roles",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21829",
      "TestMinimumLicense": "P1",
      "TestCategory": "Access control",
      "TestTitle": "Use cloud authentication",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAll domains are using cloud authentication.\n\n\n\n",
      "TestStatus": "Passed",
      "TestImplementationCost": "High",
      "TestRisk": "High",
      "TestDescription": "An on-premises federation server introduces a critical attack surface by serving as a central authentication point for cloud applications. Threat actors often gain a foothold by compromising a privileged user such as a help desk representative or an operations engineer through attacks like phishing, credential stuffing, or exploiting weak passwords. They might also target unpatched vulnerabilities in infrastructure, use remote code execution exploits, attack the Kerberos protocol, or use pass-the-hash attacks to escalate privileges. Misconfigured remote access tools like remote desktop protocol (RDP), virtual private network (VPN), or jump servers provide other entry points, while supply chain compromises or malicious insiders further increase exposure. Once inside, threat actors can manipulate authentication flows, forge security tokens to impersonate any user, and pivot into cloud environments. Establishing persistence, they can disable security logs, evade detection, and exfiltrate sensitive data.\n\n**Remediation action**\n\n- [Migrate from federation to cloud authentication like Microsoft Entra Password hash synchronization (PHS)](https://learn.microsoft.com/entra/identity/hybrid/connect/migrate-from-federation-to-cloud-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "1.2",
      "ZtmmFunctionName": "Identity Stores"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "By using Transport Layer Security (TLS) inspection, Global Secure Access can decrypt encrypted HTTPS traffic and check it for threats, malicious content, and policy violations. If TLS inspection fails for a connection, that traffic bypasses security controls. Inspection failures can let potential malware delivery, command-and-control communications, or data exfiltration go undetected.\n\nFailure rates above 1% point to systemic problems. These problems include certificate trust issues on endpoints, incompatible applications that use certificate pinning without proper bypass rules, or certificate authority configuration errors. Threat actors can also intentionally create connections that cause TLS inspection failures.\n\n**Remediation action**\n\n- [Configure diagnostic settings to export traffic logs](https://learn.microsoft.com/entra/global-secure-access/how-to-view-traffic-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-diagnostic-settings-to-export-logs) to a Log Analytics workspace. Use these logs to monitor TLS inspection success rates and investigate the root causes of failures.\n- Follow the steps in [Troubleshoot Global Secure Access Transport Layer Security inspection errors](https://learn.microsoft.com/entra/global-secure-access/troubleshoot-transport-layer-security?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to resolve common inspection failures.\n- For destinations with certificate pinning, [add TLS bypass rules](https://learn.microsoft.com/entra/global-secure-access/how-to-transport-layer-security?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to reduce failure rates while keeping inspection for other traffic.\n",
      "TestTitle": "TLS inspection failure rate is below 1%",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires connection to the service(s) \"Azure\" currently disconnected.  Please use _Connect-ZtAssessment_ to connect.\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "27003",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management",
      "TestStatus": "Passed"
    },
    {
      "TestId": "21843",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "Block legacy Microsoft Online PowerShell module",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "High",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestId": "21896",
      "TestMinimumLicense": "Free",
      "TestCategory": "Application management",
      "TestTitle": "Service principals don't have certificates or credentials associated with them",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "NotConnectedToService",
      "SkippedReason": "This test requires connection to the service(s) currently disconnected.",
      "TestResult": "\nFound Service Principals with credentials configured in the tenant, which represents a security risk.\n\n\n## Service Principals with credentials configured in the tenant\n\n\n| Service Principal Name | Credentials Type | Credentials Expiration Date | Expiry Status |\n| :--------------------- | :--------------- | :-------------------------- | :------------ |\n| [21869testapp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e69e29be-ba40-445a-9824-a3a45e0ae57a/appId/dd63d132-18fb-4f2e-aec4-82b97f30301f) | Password Credentials | 2028-10-27 | ✅ Current |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ba63bb52-182c-4ec6-9cc8-ad2287cf51ed/appId/76249b01-8747-4db4-843f-6478d5b32b14) | Password Credentials | 2028-07-30 | ✅ Current |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987) | Password Credentials | 2025-10-26 | ❗ Expired |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f79df990-9ad2-4142-b5fd-8945ff334da3/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | Password Credentials | 2027-03-03 | ✅ Current |\n| [Azure AD SAML Toolkit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4317fd0a-dcee-45bf-8e94-9a66638b11e0/appId/6f5ed68c-9fad-4d78-bf88-2b16bbe16338) | Password Credentials | 2028-10-11 | ✅ Current |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664) | Password Credentials | 2024-02-17 | ❗ Expired |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c) | Password Credentials | 2028-01-07 | ✅ Current |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/84dc13ec-5754-4745-90f9-5cc92a5ded28/appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b) | Password Credentials | 2028-07-30 | ✅ Current |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/05c98ca9-d208-4d3e-ad24-911bfc3d028c/appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06) | Password Credentials | 2024-06-11 | ❗ Expired |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9) | Password Credentials | 2025-10-02 | ❗ Expired |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52) | Password Credentials | 2025-11-17 | ❗ Expired |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94) | Password Credentials | 2024-02-15 | ❗ Expired |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1) | Password Credentials | 2027-02-15 | ✅ Current |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35) | Password Credentials | 2028-02-26 | ✅ Current |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa) | Password Credentials | 2025-10-10 | ❗ Expired |\n| [21869testapp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e69e29be-ba40-445a-9824-a3a45e0ae57a/appId/dd63d132-18fb-4f2e-aec4-82b97f30301f) | Key Credentials | 2028-10-27 | ✅ Current |\n| [APP-2732_Genesys Cloud TCCC-G-TFS-Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ba63bb52-182c-4ec6-9cc8-ad2287cf51ed/appId/76249b01-8747-4db4-843f-6478d5b32b14) | Key Credentials | 2028-07-30 | ✅ Current |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987) | Key Credentials | 2025-10-26 | ❗ Expired |\n| [Azure AD SAML Toolkit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4317fd0a-dcee-45bf-8e94-9a66638b11e0/appId/6f5ed68c-9fad-4d78-bf88-2b16bbe16338) | Key Credentials | 2028-10-11 | ✅ Current |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664) | Key Credentials | 2024-02-17 | ❗ Expired |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c) | Key Credentials | 2028-01-07 | ✅ Current |\n| [Madura- Genesys Cloud for Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/84dc13ec-5754-4745-90f9-5cc92a5ded28/appId/9c599cd2-9fb0-4815-b65c-83be33f5df1b) | Key Credentials | 2028-07-30 | ✅ Current |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/05c98ca9-d208-4d3e-ad24-911bfc3d028c/appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06) | Key Credentials | 2024-06-11 | ❗ Expired |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9) | Key Credentials | 2025-10-02 | ❗ Expired |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52) | Key Credentials | 2025-11-17 | ❗ Expired |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94) | Key Credentials | 2024-02-15 | ❗ Expired |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1) | Key Credentials | 2027-02-15 | ✅ Current |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35) | Key Credentials | 2028-02-26 | ✅ Current |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa) | Key Credentials | 2025-10-10 | ❗ Expired |\n\n\n\n",
      "TestStatus": "Skipped",
      "TestImplementationCost": "Medium",
      "TestRisk": "Medium",
      "TestDescription": "Service principals without proper authentication credentials (certificates or client secrets) create security vulnerabilities that allow threat actors to impersonate these identities. This can lead to unauthorized access, lateral movement within your environment, privilege escalation, and persistent access that's difficult to detect and remediate. \n\n**Remediation action**\n\n- For your organization's service principals: [Add certificates or client secrets to the app registration](https://learn.microsoft.com/entra/identity-platform/how-to-add-credentials?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- For external service principals: Review and remove any unnecessary credentials to reduce security risk\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "1.7",
      "ZtmmFunctionName": "Governance"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "When Microsoft Entra private network connectors are inactive or unhealthy, organizations might resort to using less secure access methods. This condition creates opportunities where threat actors can target externally exposed services or use compromised credentials.\n\nWithout functional connectors:\n\n- Token-based authentication and authorization for all Microsoft Entra Private Access scenarios is eliminated.\n- Threat actors can bypass intended security boundaries to access resources beyond their authorization scope.\n- The service can't route requests properly, directly disrupting network access controls.\n\n**Remediation action**\n\n- [Configure connectors for high availability](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Monitor connector health in the Microsoft Entra admin center under Global Secure Access > Connect > Connectors.\n- [Troubleshoot connector installation and connectivity issues](https://learn.microsoft.com/entra/global-secure-access/troubleshoot-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Private network connectors are active and healthy to maintain Zero Trust access to internal resources",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25391",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation",
      "TestStatus": "Passed"
    },
    {
      "TestId": "24543",
      "TestMinimumLicense": "Intune",
      "TestCategory": "Tenant",
      "TestTitle": "Compliance policies protect iOS/iPadOS devices",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nAt least one compliance policy for iOS/iPadOS exists and is assigned.\n\n\n## iOS/iPadOS Compliance Policies\n\n| Policy Name | Status | Assignment Target |\n| :---------- | :----- | :---------------- |\n| [My iOS policy](https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/compliance) | ✅ Assigned | **Included:** All Devices, All Users, **Excluded:** aad-conditional-access-excluded |\n\n\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "High",
      "TestDescription": "If compliance policies aren't assigned to iOS/iPadOS devices in Intune, threat actors can exploit noncompliant endpoints to gain unauthorized access to corporate resources, bypass security controls, and persist in the environment. Without enforced compliance, devices can lack critical security configurations like passcode requirements and OS version controls. These gaps increase the risk of data leakage, privilege escalation, and lateral movement. Inconsistent device compliance weakens the organization’s security posture and makes it harder to detect and remediate threats before significant damage occurs.\n\nEnforcing compliance policies ensures iOS/iPadOS devices meet core security requirements and supports Zero Trust by validating device health and reducing exposure to misconfigured or unmanaged endpoints.\n\n**Remediation action**\n\nCreate and assign Intune compliance policies to iOS/iPadOS devices to enforce organizational standards for secure access and management:  \n- [Create a compliance policy in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/create-compliance-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-the-policy)\n- [Review the iOS/iPadOS compliance settings you can manage with Intune](https://learn.microsoft.com/intune/intune-service/protect/compliance-policy-create-ios?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": null,
      "TestImpact": "Medium",
      "TestAppliesTo": null,
      "TestPillar": "Devices",
      "ZtmmMaturity": "Initial",
      "ZtmmFunction": "2.1",
      "ZtmmFunctionName": "Policy enforcement and compliance monitoring"
    },
    {
      "TestId": 21883,
      "TestMinimumLicense": "Workload",
      "TestCategory": "Access control",
      "TestTitle": "Workload Identities are configured with risk-based policies",
      "TestSfiPillar": "Accelerate response and remediation",
      "TestSkipped": "",
      "SkippedReason": null,
      "TestResult": "\nSkipped. This test is for tenants that are licensed for Entra Workload ID. See [Entra Workload ID licensing](https://learn.microsoft.com/entra/workload-id/workload-identities-faqs)\n\n",
      "TestStatus": "Failed",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "Set up risk-based Conditional Access policies for workload identities based on risk policy in Microsoft Entra ID to make sure only trusted and verified workloads use sensitive resources. Without these policies, threat actors can compromise workload identities with minimal detection and perform further attacks. Without conditional controls to detect anomalous activity and other risks, there's no check against malicious operations like token forgery, access to sensitive resources, and disruption of workloads. The lack of automated containment mechanisms increases dwell time and affects the confidentiality, integrity, and availability of critical services.   \n\n**Remediation action**\nCreate a risk-based Conditional Access policy for workload identities.\n- [Create a risk-based Conditional Access policy](https://learn.microsoft.com/entra/identity/conditional-access/workload-identity?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-risk-based-conditional-access-policy)\n",
      "TestTags": null,
      "TestImpact": "High",
      "TestAppliesTo": null,
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.1",
      "ZtmmFunctionName": "Network segmentation"
    },
    {
      "TestRisk": "Low",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "Global Secure Access maintains a system bypass list of destinations that are automatically excluded from Transport Layer Security (TLS) inspection. These bypass destinations represent known incompatibilities such as certificate pinning, mutual TLS requirements, or other technical constraints. Custom bypass rules that duplicate destinations in the system bypass list are redundant and serve no functional purpose.\n\nRedundant rules consume policy capacity, create administrative overhead, and can cause confusion about which rules are necessary. TLS inspection supports up to 1,000 rules and 8,000 destinations per tenant. Maintaining a clean policy configuration with only necessary custom bypass rules improves manageability, simplifies security audits, and ensures that policy capacity is available for legitimate business requirements.\n\n**Remediation action**\n\n- Review and remove redundant custom TLS inspection bypass rules in the Microsoft Entra admin center. Navigate to **Global Secure Access** > **Secure** > **TLS inspection policies**.\n- Review [the destinations included in the system bypass list](https://learn.microsoft.com/entra/global-secure-access/faq-transport-layer-security?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#what-destinations-are-included-in-the-system-bypass).\n",
      "TestTitle": "TLS inspection custom bypass rules don't duplicate system bypass destinations",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "27004",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Failed"
    },
    {
      "TestRisk": "Medium",
      "TestAppliesTo": null,
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestDescription": "Category-based filtering provides broader protection than URL-specific rules. Blocking entire website categories like malware, phishing, hacking, and criminal activity prevents access to thousands of malicious sites at once. Filtering policies that only target specific URLs or domains require constant maintenance and leave gaps as threat actors register new malicious domains daily.\n\n**Remediation action**\n\n- [Review available web content filtering categories](https://learn.microsoft.com/entra/global-secure-access/reference-web-content-filtering-categories?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure category-based filtering rules](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-web-content-filtering?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTitle": "Web content filtering uses category-based rules",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Global Secure Access",
      "TestId": "25409",
      "ZtmmMaturity": "Advanced",
      "ZtmmFunction": "3.5",
      "ZtmmFunctionName": "Visibility and analytics",
      "TestStatus": "Failed"
    },
    {
      "TestId": "21983",
      "TestMinimumLicense": null,
      "TestCategory": "Access control",
      "TestTitle": "No Active Medium priority Entra recommendations found",
      "TestSfiPillar": "Protect identities and secrets",
      "TestSkipped": "UnderConstruction",
      "SkippedReason": "UnderConstruction",
      "TestResult": "\nPlanned for future release.\n",
      "TestStatus": "Planned",
      "TestImplementationCost": "Low",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestPillar": "Identity",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.2",
      "ZtmmFunctionName": "Network traffic management"
    },
    {
      "TestRisk": "High",
      "TestAppliesTo": null,
      "TestImpact": "Low",
      "SkippedReason": null,
      "TestDescription": "When Microsoft 365 traffic bypasses Global Secure Access, organizations lose visibility and control over their most critical productivity workloads. Threat actors who exploit unmonitored Microsoft 365 connections can exfiltrate sensitive data through SharePoint, OneDrive, or Exchange without triggering security policies or generating actionable telemetry. Token theft and replay attacks become more difficult to detect when traffic doesn't flow through the Security Service Edge because source IP correlation with sign-in logs and Conditional Access evaluation can't be applied consistently.\n\nOrganizations with significant bypassed traffic, whether due to incomplete client deployment, misconfigured forwarding profiles, or users on unmanaged devices, create blind spots where adversary-in-the-middle attacks, credential harvesting, and unauthorized data transfers can proceed undetected. Traffic that bypasses Global Secure Access also can't benefit from compliant network checks in Conditional Access policies, tenant restrictions, or source IP restoration, leaving significant security controls ineffective.\n\n**Remediation action**\n- Enable and configure the Microsoft traffic profile. For more information, see [Enable Microsoft traffic profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-microsoft-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Deploy the Global Secure Access client to all managed devices. For more information, see [Deploy Global Secure Access client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-windows-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Review and configure traffic forwarding rules appropriately. For more information, see [Review traffic forwarding rules](https://learn.microsoft.com/entra/global-secure-access/concept-microsoft-traffic-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestTitle": "Microsoft 365 traffic is actively flowing through Global Secure Access",
      "TestPillar": "Network",
      "TestResult": "\nSkipped. This test requires one of the following licenses: (\"Entra_Premium_Private_Access\") OR (\"Entra_Premium_Internet_Access\").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/entra/identity/users/licensing-service-plan-reference)\n\n",
      "TestSfiPillar": "Protect networks",
      "TestMinimumLicense": [
        "Entra_Premium_Private_Access",
        "Entra_Premium_Internet_Access"
      ],
      "TestTags": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestCategory": "Network security",
      "TestId": "25376",
      "ZtmmMaturity": "Optimal",
      "ZtmmFunction": "3.3",
      "ZtmmFunctionName": "Traffic encryption",
      "TestStatus": "Failed"
    }
  ],
  "TenantInfo": {
    "OverviewAuthMethodsAllUsers": {
      "description": "Strongest authentication method registered by all users.",
      "nodes": [
        {
          "target": "Single factor",
          "source": "Users",
          "value": 56
        },
        {
          "target": "Phishable",
          "source": "Users",
          "value": 40
        },
        {
          "target": "Phone",
          "source": "Phishable",
          "value": 13
        },
        {
          "target": "Authenticator",
          "source": "Phishable",
          "value": 27
        },
        {
          "target": "Phish resistant",
          "source": "Users",
          "value": 7
        },
        {
          "target": "Passkey",
          "source": "Phish resistant",
          "value": 5
        },
        {
          "target": "WHfB",
          "source": "Phish resistant",
          "value": 2
        }
      ]
    },
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
        "ActionForNoncomplianceDaysPushNotification": 2,
        "ActionForNoncomplianceDaysSendEmail": 2,
        "ActionForNoncomplianceDaysRemoteLock": 2,
        "ActionForNoncomplianceDaysBlock": 1,
        "ActionForNoncomplianceDaysRetire": 3,
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
        "ActionForNoncomplianceDaysRemoteLock": 2,
        "ActionForNoncomplianceDaysBlock": 2,
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
        "ActionForNoncomplianceDaysRemoteLock": 4,
        "ActionForNoncomplianceDaysBlock": "Immediately",
        "ActionForNoncomplianceDaysRetire": 6,
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
        "ActionForNoncomplianceDaysPushNotification": 12,
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
        "ActionForNoncomplianceDaysRetire": 4,
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
    "OverviewCaDevicesAllUsers": {
      "description": "Over the past 30 days, 0% of sign-ins were from compliant devices.",
      "nodes": [
        {
          "target": "Unmanaged",
          "source": "User sign in",
          "value": 1251
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
      ]
    },
    "DeviceOverview": {
      "DesktopDevicesSummary": {
        "entrajoined": 8,
        "entrareigstered": 8,
        "description": "Desktop devices (Windows and macOS) by join type and compliance status.",
        "totalDevices": 18,
        "nodes": [
          {
            "target": "Windows",
            "source": "Desktop devices",
            "value": 16
          },
          {
            "target": "macOS",
            "source": "Desktop devices",
            "value": 2
          },
          {
            "target": "Entra joined",
            "source": "Windows",
            "value": 8
          },
          {
            "target": "Entra registered",
            "source": "Windows",
            "value": 8
          },
          {
            "target": "Entra hybrid joined",
            "source": "Windows",
            "value": 0
          },
          {
            "target": "Compliant",
            "source": "Entra joined",
            "value": null
          },
          {
            "target": "Non-compliant",
            "source": "Entra joined",
            "value": 4
          },
          {
            "target": "Unmanaged",
            "source": "Entra joined",
            "value": 4
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
            "value": 0
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
            "value": 8
          },
          {
            "target": "Compliant",
            "source": "macOS",
            "value": 0
          },
          {
            "target": "Non-compliant",
            "source": "macOS",
            "value": 2
          },
          {
            "target": "Unmanaged",
            "source": "macOS",
            "value": 0
          }
        ],
        "entrahybridjoined": 0
      },
      "ManagedDevices": null,
      "MobileSummary": {
        "nodes": [
          {
            "target": "Android",
            "source": "Mobile devices",
            "value": 0
          },
          {
            "target": "iOS",
            "source": "Mobile devices",
            "value": 0
          },
          {
            "target": "Android (Company)",
            "source": "Android",
            "value": 0
          },
          {
            "target": "Android (Personal)",
            "source": "Android",
            "value": 0
          },
          {
            "target": "iOS (Company)",
            "source": "iOS",
            "value": 0
          },
          {
            "target": "iOS (Personal)",
            "source": "iOS",
            "value": 0
          },
          {
            "target": "Compliant",
            "source": "Android (Company)",
            "value": null
          },
          {
            "target": "Non-compliant",
            "source": "Android (Company)",
            "value": null
          },
          {
            "target": "Compliant",
            "source": "Android (Personal)",
            "value": null
          },
          {
            "target": "Non-compliant",
            "source": "Android (Personal)",
            "value": null
          },
          {
            "target": "Compliant",
            "source": "iOS (Company)",
            "value": null
          },
          {
            "target": "Non-compliant",
            "source": "iOS (Company)",
            "value": null
          },
          {
            "target": "Compliant",
            "source": "iOS (Personal)",
            "value": null
          },
          {
            "target": "Non-compliant",
            "source": "iOS (Personal)",
            "value": null
          }
        ],
        "totalDevices": 2,
        "description": "Mobile devices by compliance status."
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
      },
      "DeviceOwnership": {
        "corporateCount": 0,
        "personalCount": 0
      }
    },
    "OverviewCaMfaAllUsers": {
      "description": "Over the past 30 days, 51.9% of sign-ins were protected by conditional access policies enforcing multifactor.",
      "nodes": [
        {
          "target": "No CA applied",
          "source": "User sign in",
          "value": 332
        },
        {
          "target": "CA applied",
          "source": "User sign in",
          "value": 919
        },
        {
          "target": "No MFA",
          "source": "CA applied",
          "value": 270
        },
        {
          "target": "MFA",
          "source": "CA applied",
          "value": 649
        }
      ]
    },
    "ConfigDeviceAppProtectionPolicies": [
      {
        "Platform": "Android",
        "Name": "Android Policy",
        "AppsPublic": "Cortana, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Microsoft Dynamics 365 for tablets, Microsoft Invoicing, Microsoft Edge, Power Automate, Azure Information Protection, Microsoft Launcher, Microsoft Kaizala, Microsoft Power Apps, Microsoft Excel, Skype for Business, Microsoft 365 (Office) (China), Microsoft Office (HL), Microsoft 365 Copilot, Microsoft Lens, Microsoft OneNote, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft Planner, Microsoft Power BI, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Microsoft 365 Admin, Viva Engage, Microsoft StaffHub",
        "AppsCustom": "com.microsoft.d365.fs.mobile, com.microsoft.lists.public, com.microsoft.ramobile, com.microsoft.stream, com.oracle.java.pdfviewer",
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
        "AppsPublic": "Adobe Acrobat Reader, Cortana, Microsoft Dynamics 365, Microsoft Invoicing, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Skype for Business, Microsoft Kaizala, Microsoft Power Apps, Microsoft Edge, Microsoft 365 Admin, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft Lens, Microsoft 365 Copilot, Microsoft OneNote, Microsoft Planner, Microsoft Power BI, Power Automate, Azure Information Protection, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft StaffHub, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Vera for Intune, Viva Engage",
        "AppsCustom": "com.microsoft.d365.fs.mobile, com.microsoft.ramobile, com.microsoft.splists, com.microsoft.stream, com.microsoft.visio, my.merill.net",
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
    "TenantOverview": {
      "UserCount": 84,
      "GuestCount": 4,
      "GroupCount": 92,
      "ApplicationCount": 155,
      "DeviceCount": 25,
      "ManagedDeviceCount": 0
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
    "OverviewAuthMethodsPrivilegedUsers": {
      "description": "Strongest authentication method registered by privileged users.",
      "nodes": [
        {
          "target": "Single factor",
          "source": "Users",
          "value": 11
        },
        {
          "target": "Phishable",
          "source": "Users",
          "value": 31
        },
        {
          "target": "Phone",
          "source": "Phishable",
          "value": 11
        },
        {
          "target": "Authenticator",
          "source": "Phishable",
          "value": 20
        },
        {
          "target": "Phish resistant",
          "source": "Users",
          "value": 6
        },
        {
          "target": "Passkey",
          "source": "Phish resistant",
          "value": 5
        },
        {
          "target": "WHfB",
          "source": "Phish resistant",
          "value": 1
        }
      ]
    }
  },
  "EndOfJson": "EndOfJson"
}
