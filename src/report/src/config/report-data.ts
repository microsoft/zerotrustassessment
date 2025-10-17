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

export interface DeviceOverview {
  WindowsJoinSummary: SankeyData | null;
  ManagedDevices: ManagedDevices | null;
  DeviceCompliance: DeviceCompliance | null;
}

export interface ManagedDevices {
  "@odata.context": string;
  id: string;
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
  "ExecutedAt": "2025-10-17T20:28:10.323687+11:00",
  "TenantId": "4c252310-e8bc-4601-939c-eec227985cad",
  "TenantName": "UEMCATLabs.com ",
  "Domain": "UEMCATLabs.com",
  "Account": "MerillF@UEMCATLabs.com",
  "CurrentVersion": "0.18.0",
  "LatestVersion": "0.18.0",
  "TestResultSummary": {
    "IdentityPassed": 0,
    "IdentityTotal": 1,
    "DevicesPassed": 0,
    "DevicesTotal": 0,
    "DataPassed": 0,
    "DataTotal": 0
  },
  "Tests": [
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
      "TestResult": "\n❌ **Fail**: User consent settings are not sufficiently restricted, allowing users to consent to potentially risky applications.\n\n\n## Authorization Policy Configuration\n\n\n**Current [user consent settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/~/UserSettings)**\n\n- Allow user consent for apps.\nAll users can consent for any app to access the organization's data.\n\n\n",
      "TestTitle": "User consent settings are restricted",
      "TestStatus": "Failed"
    }
  ],
  "TenantInfo": {
    "ConfigDeviceAppProtectionPolicies": [
      {
        "Platform": "Android",
        "Name": [
          "[RaviK] - Android APP Zero Trust",
          "UCL - Android MAM Tunnel Edge",
          "CBAndroidTEST",
          "Edge Android APP Level 3 High",
          "Edge Android APP Level 1 Basic",
          "Edge Android APP Level 2 Enhanced",
          "SMM - App Protection Policy - DPF Level 1 - Android",
          "SMM - App Protection Policy - DPF Level 2 - Android",
          "SMM - App Protection Policy - DPF Level 3 - Android",
          "UCL - Android Default APP",
          "[andyfu] Android keyboard block test",
          "[andyfu] Samsung Knox App Protection"
        ],
        "AppsPublic": "Microsoft Edge, Microsoft Excel, Microsoft 365 (Office) (China), Microsoft Office (HL), Microsoft 365 Copilot, Microsoft OneNote, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Edge, OfficeMail Go, Unique Moments, MyQ Roger: OCR scanner PDF, Dialpad, Achievers, Adobe Acrobat Reader, Adobe Acrobat Reader for Intune (Deprecated), FleetSafer, Akumina EXP, Appian for Intune, Atom Edge, Asana: Work in one place, Riskonnect Resilience, Avenza Maps for Intune, 365Pay, Space Connect, BlueJeans Video Conferencing, Box, Comfy, F2 Touch Intune, CellTrust SL2™ for Intune, Cerby, Cisco Jabber for Intune, Webex for Intune, Citrix ShareFile for Intune, Hey DAN for Intune, Condeco, Datasite for Intune, DealCloud, Dooray! for Intune, ePRINTit SaaS, ArcGIS Indoors for Intune, FactSet, FileOrbis for Intune, 4CEE Connect, Freshservice for Intune, Fuze Mobile for Intune, Meetio, Global Relay, Hearsay Relate for Intune, Bob HR, HowNow, HP Advance for Intune, ixArma 6, CAPTOR, Intapp, ISEC7 MAIL for Intune, Leap Work for Intune, Nexis Newsdesk™ Mobile, VPSX Print for Intune, LumApps for Intune, Applications Manager - Intune, Meetings by Decisions, MentorcliQ, M-Files for Intune, Microsoft Azure, Cortana, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Microsoft Dynamics 365 for tablets, Microsoft Designer, Microsoft Invoicing, Microsoft Edge, Power Automate, Azure Information Protection, Microsoft Launcher, Microsoft Lists, Microsoft Loop, Microsoft Kaizala, Microsoft Power Apps, Microsoft Connections, Microsoft Excel, Skype for Business, Microsoft 365 (Office) (China), Microsoft Office (HL), Microsoft 365 Copilot, Microsoft Lens, Microsoft OneNote, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Outlook Groups, Microsoft Planner, Microsoft Power BI, Windows App, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Mobile Helix LINK for Intune, MoveInSync, MultiLine for Intune, MangoApps, Work from Anywhere, Microsoft 365 Admin, My Portal By MangoApps, MURAL - Visual Collaboration, MyITOps for Intune, Nine Work for Intune, Omega 365, Omnipresence Go, PagerDuty for Intune, PenPoint, PrinterOn for Microsoft, PrinterOn Print, Qlik Sense Mobile, Recruitment.Exchange, RICOH Spaces, RingCentral for Intune, Seismic, ServiceNow® Agent - Intune, Now® Mobile - Intune, Notate for Intune, Slack for Intune, Symphony Messaging Intune, Tableau Mobile for Intune, Talent.Exchange, Total Triage, Dialpad Meetings, Varicent, Vbrick Mobile, Voltage SecureMail, Workvivo, Viva Engage, Zoho Projects - Intune, IntraActive, Beakon Mobile App, Island Browser for Intune, Outreach Mobile, ANDPAD, ANDPAD CHAT, ANDPAD Inspection, ArchXtract, Confidential File Viewer, myBLDNG, Microsoft StaffHub, Naso Mobile, Board.Vision for iPad, Re:Work Enterprise, Idenprotect Go, Zoom for Intune, CiiMS GO, Microsoft Edge, Microsoft Edge, Microsoft Edge, Microsoft Edge, Microsoft Excel, Microsoft 365 (Office) (China), Microsoft Office (HL), Microsoft 365 Copilot, Microsoft OneNote, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Edge, Microsoft Excel, Microsoft 365 (Office) (China), Microsoft Office (HL), Microsoft 365 Copilot, Microsoft OneNote, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Edge, Microsoft Excel, Microsoft 365 (Office) (China), Microsoft Office (HL), Microsoft 365 Copilot, Microsoft OneNote, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, OfficeMail Go, Unique Moments, MyQ Roger: OCR scanner PDF, Dialpad, Achievers, Adobe Acrobat Reader, Adobe Acrobat Reader for Intune (Deprecated), FleetSafer, Akumina EXP, Appian for Intune, Atom Edge, Asana: Work in one place, Riskonnect Resilience, Avenza Maps for Intune, 365Pay, Space Connect, BlueJeans Video Conferencing, Box, Comfy, F2 Touch Intune, CellTrust SL2™ for Intune, Cerby, Cisco Jabber for Intune, Webex for Intune, Citrix ShareFile for Intune, Hey DAN for Intune, Condeco, Datasite for Intune, DealCloud, Dooray! for Intune, ePRINTit SaaS, ArcGIS Indoors for Intune, FactSet, FileOrbis for Intune, 4CEE Connect, Freshservice for Intune, Fuze Mobile for Intune, Meetio, Global Relay, Hearsay Relate for Intune, Bob HR, HowNow, HP Advance for Intune, ixArma 6, CAPTOR, Intapp, ISEC7 MAIL for Intune, Leap Work for Intune, Nexis Newsdesk™ Mobile, VPSX Print for Intune, LumApps for Intune, Applications Manager - Intune, Meetings by Decisions, MentorcliQ, M-Files for Intune, Microsoft Azure, Cortana, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Microsoft Dynamics 365 for tablets, Microsoft Designer, Microsoft Invoicing, Microsoft Edge, Power Automate, Azure Information Protection, Microsoft Launcher, Microsoft Lists, Microsoft Loop, Microsoft Kaizala, Microsoft Power Apps, Microsoft Connections, Microsoft Excel, Skype for Business, Microsoft 365 (Office) (China), Microsoft Office (HL), Microsoft 365 Copilot, Microsoft Lens, Microsoft OneNote, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Outlook Groups, Microsoft Planner, Microsoft Power BI, Windows App, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Mobile Helix LINK for Intune, MoveInSync, MultiLine for Intune, MangoApps, Work from Anywhere, Microsoft 365 Admin, My Portal By MangoApps, MURAL - Visual Collaboration, MyITOps for Intune, Nine Work for Intune, Omega 365, Omnipresence Go, PagerDuty for Intune, PenPoint, PrinterOn for Microsoft, PrinterOn Print, Qlik Sense Mobile, Recruitment.Exchange, RICOH Spaces, RingCentral for Intune, Seismic, ServiceNow® Agent - Intune, Now® Mobile - Intune, Notate for Intune, Slack for Intune, Symphony Messaging Intune, Tableau Mobile for Intune, Talent.Exchange, Total Triage, Dialpad Meetings, Varicent, Vbrick Mobile, Voltage SecureMail, Workvivo, Viva Engage, Zoho Projects - Intune, IntraActive, Beakon Mobile App, Island Browser for Intune, Outreach Mobile, ANDPAD, ANDPAD CHAT, ANDPAD Inspection, ArchXtract, Confidential File Viewer, myBLDNG, Microsoft StaffHub, Naso Mobile, Board.Vision for iPad, Re:Work Enterprise, Idenprotect Go, Zoom for Intune, CiiMS GO, Microsoft Azure, Cortana, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Microsoft Dynamics 365 for tablets, Microsoft Designer, Microsoft Invoicing, Microsoft Edge, Power Automate, Azure Information Protection, Microsoft Launcher, Microsoft Lists, Microsoft Loop, Microsoft Kaizala, Microsoft Power Apps, Microsoft Connections, Microsoft Excel, Skype for Business, Microsoft 365 (Office) (China), Microsoft Office (HL), Microsoft 365 Copilot, Microsoft Lens, Microsoft OneNote, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Outlook Groups, Microsoft Planner, Microsoft Power BI, Windows App, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Microsoft 365 Admin, Viva Engage, Microsoft StaffHub, OfficeMail Go, Unique Moments, MyQ Roger: OCR scanner PDF, Dialpad, Achievers, Adobe Acrobat Reader, Adobe Acrobat Reader for Intune (Deprecated), FleetSafer, Akumina EXP, Appian for Intune, Atom Edge, Asana: Work in one place, Riskonnect Resilience, Avenza Maps for Intune, 365Pay, Space Connect, BlueJeans Video Conferencing, Box, Comfy, F2 Touch Intune, CellTrust SL2™ for Intune, Cerby, Cisco Jabber for Intune, Webex for Intune, Citrix ShareFile for Intune, Hey DAN for Intune, Condeco, Datasite for Intune, DealCloud, Dooray! for Intune, ePRINTit SaaS, ArcGIS Indoors for Intune, FactSet, FileOrbis for Intune, 4CEE Connect, Freshservice for Intune, Fuze Mobile for Intune, Meetio, Global Relay, Hearsay Relate for Intune, Bob HR, HowNow, HP Advance for Intune, ixArma 6, CAPTOR, Intapp, ISEC7 MAIL for Intune, Leap Work for Intune, Nexis Newsdesk™ Mobile, VPSX Print for Intune, LumApps for Intune, Applications Manager - Intune, Meetings by Decisions, MentorcliQ, M-Files for Intune, Microsoft Azure, Cortana, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Microsoft Dynamics 365 for tablets, Microsoft Designer, Microsoft Invoicing, Microsoft Edge, Power Automate, Azure Information Protection, Microsoft Launcher, Microsoft Lists, Microsoft Loop, Microsoft Kaizala, Microsoft Power Apps, Microsoft Connections, Microsoft Excel, Skype for Business, Microsoft 365 (Office) (China), Microsoft Office (HL), Microsoft 365 Copilot, Microsoft Lens, Microsoft OneNote, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Outlook Groups, Microsoft Planner, Microsoft Power BI, Windows App, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Mobile Helix LINK for Intune, MoveInSync, MultiLine for Intune, MangoApps, Work from Anywhere, Microsoft 365 Admin, My Portal By MangoApps, MURAL - Visual Collaboration, MyITOps for Intune, Nine Work for Intune, Omega 365, Omnipresence Go, PagerDuty for Intune, PenPoint, PrinterOn for Microsoft, PrinterOn Print, Qlik Sense Mobile, Recruitment.Exchange, RICOH Spaces, RingCentral for Intune, Seismic, ServiceNow® Agent - Intune, Now® Mobile - Intune, Notate for Intune, Slack for Intune, Symphony Messaging Intune, Tableau Mobile for Intune, Talent.Exchange, Total Triage, Dialpad Meetings, Varicent, Vbrick Mobile, Voltage SecureMail, Workvivo, Viva Engage, Zoho Projects - Intune, IntraActive, Beakon Mobile App, Island Browser for Intune, Outreach Mobile, ANDPAD, ANDPAD CHAT, ANDPAD Inspection, ArchXtract, Confidential File Viewer, myBLDNG, Microsoft StaffHub, Naso Mobile, Board.Vision for iPad, Re:Work Enterprise, Idenprotect Go, Zoom for Intune, CiiMS GO",
        "AppsCustom": "com.groupdolists.android, com.microsoft.copilot, com.microsoft.d365.fs.mobile, com.microsoft.exchange.bookings, com.microsoft.ramobile, com.microsoft.rdc.android, com.microsoft.stream, com.microsoft.teams.baidu, com.ricohsmartspaces.app, com.servicenow.onboarding.mam.intune, com.microsoft.copilot, com.microsoft.ramobile",
        "BackupOrgDataToICloudOrGoogle": "Allow",
        "SendOrgDataToOtherApps": "All apps",
        "AppsToExempt": "",
        "SaveCopiesOfOrgData": "Allow",
        "AllowUserToSaveCopiesToSelectedServices": "OneDrive for Business, OneDrive for Business, SharePoint, Photo library, OneDrive for Business, SharePoint, Photo library, OneDrive for Business, SharePoint",
        "DataProtectionTransferTelecommunicationDataTo": "Any dialer app",
        "DataProtectionReceiveDataFromOtherApps": "All apps",
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
        "Scope": "Default, Default, Default, Default, Default, Default, Default, Default, Default, Default, Default, Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "iOS/iPadOS",
        "Name": [
          "[JA] - Testoing Managed / Unmanaged",
          "FCD - Fourthcoffee APP for iOS",
          "UCL - Default MAM Policy",
          "[andyfu] iOS Outlook and Teams APP v4",
          "SMM - App Protection Policy - DPF Level 1 - iOS",
          "Edge iOS APP Level 3 High",
          "UCL - MAM Tunnel",
          "[CK] Outlook",
          "SMM - App Protection Policy - DPF Level 2 - iOS",
          "Edge iOS APP Level 2 Enhanced",
          "Kevin - iPad app testing",
          "RS MAM AP Policy (BYOD) DPF Level 2",
          "Edge iOS APP Level 1 Basic",
          "SMM - App Protection Policy - DPF Level 3 - iOS",
          "CBTESTiOS"
        ],
        "AppsPublic": "LiquidText, Unique Moments, MyQ Roger: OCR scanner PDF, Fellow.app, Cinebody, MURAL - Visual Collaboration, Space Connect, Dialpad, 365Pay, 4CEE Connect, Achievers, Adobe Acrobat Reader for Intune (Deprecated), Adobe Acrobat Reader, FleetSafer, Akumina EXP, AssetScan For Intune, FacilyLife, Appian for Intune, Atom Edge, Asana: Work in one place, Riskonnect Resilience, Avenza Maps for Intune, BlueJeans Video Conferencing, Diligent Boards, Box for EMM, iAnnotate for Intune / O365, Breezy for Intune, BuddyBoard, Comfy, F2 Manager - Intune, F2 Touch Intune, CellTrust SL2™ for Intune, Cerby, Cisco Jabber for Intune, Webex for Intune, Hey DAN for Intune, Clipchamp, Condeco, Lemur Pro for Intune, Datasite for Intune, DealCloud, Dooray! for Intune, Egnyte for Intune, ePRINTit SaaS, ArcGIS Indoors for Intune, FactSet, FileOrbis for Intune, Dialpad Meetings, Freshservice for Intune, Fuze Mobile for Intune, Meetio, Global Relay, Nitro PDF Pro - iPad & iPhone, Goodnotes 6, EVALARM, HCSS Field, HCSS Plans, Bob HR, HP Advance for Intune, Dashflow for InTune, iManage Work 10 For Intune, ixArma 6, Zero for Intune, Incorta (BestBuy), Omnipresence Go, CAPTOR, Intapp, ISEC7 Mobile Exchange Delegate, ISEC7 MAIL for Intune, KeePassium for Intune, Klaxoon for Intune, Kofax Power PDF Mobile, Leap Work for Intune, Nexis Newsdesk™ Mobile, VPSX Print for Intune, LumApps for Intune, M-Files for Intune, VerityRMS, Applications Manager - Intune, MangoApps, Work from Anywhere, My Portal By MangoApps, Senses, Meetings by Decisions, MentorcliQ, Align for InTune, Microsoft Azure, Cortana, Microsoft Designer, Microsoft Dynamics 365, Microsoft Invoicing, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Outlook Groups, Microsoft Loop, Skype for Business, Microsoft Kaizala, Microsoft Power Apps, Microsoft Edge, Microsoft 365 Admin, Microsoft Connections, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft Lens, Microsoft 365 Copilot, Microsoft OneNote, Microsoft Planner, Microsoft Power BI, Power Automate, Windows App, Azure Information Protection, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft StaffHub, Microsoft OneDrive, Microsoft Teams, Microsoft Lists, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Mobile Helix LINK for Intune, MoveInSync, MultiLine for Intune, MyITOps for Intune, PagerDuty for Intune, PenPoint, Board Papers, Board Papers for Intune, Team Papers for Intune, PK Protect for Intune, PrinterOn Print, PrinterOn for Microsoft, Qlik Sense Mobile, Recruitment.Exchange, Re:Work Enterprise, RICOH Spaces, RingCentral for Intune, Seismic, ServiceNow® Agent - Intune, Now® Mobile - Intune, Notate for Intune, Citrix ShareFile for Intune, Singletrack for Intune, Slack for Intune, SMART TeamWorks, Firstup - Intune, Enterprise Files for Intune, Mobile Work Orders, Symphony Messaging Intune, Synchrotab for Intune, Tableau Mobile for Intune, Talent.Exchange, Total Triage, Varicent, Vbrick Mobile, Veeva Vault CRM, Vera for Intune, Voltage Mail, HowNow, Workvivo, Secure Contacts, IntraActive, Beakon Mobile App, Island Enterprise Browser, Outreach Mobile, ArchXtract, Confidential File Viewer, ANDPAD, ANDPAD Blueprint, ANDPAD CHAT, ANDPAD Inspection, Box — Cloud Content Management, Mijn InPlanning, iBabs For Intune, myBLDNG, Speaking Email, Hearsay Relate for Intune, Naso Mobile, Board.Vision, Board.Vision for iPad, Idenprotect Go, Zoom for Intune, Viva Engage, CiiMS GO, Clipchamp, Microsoft Azure, Cortana, Microsoft Designer, Microsoft Dynamics 365, Microsoft Invoicing, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Outlook Groups, Microsoft Loop, Skype for Business, Microsoft Kaizala, Microsoft Power Apps, Microsoft Edge, Microsoft 365 Admin, Microsoft Connections, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft Lens, Microsoft 365 Copilot, Microsoft OneNote, Microsoft Planner, Microsoft Power BI, Power Automate, Windows App, Azure Information Protection, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft StaffHub, Microsoft OneDrive, Microsoft Teams, Microsoft Lists, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Vera for Intune, Viva Engage, LiquidText, Unique Moments, MyQ Roger: OCR scanner PDF, Fellow.app, Cinebody, MURAL - Visual Collaboration, Space Connect, Dialpad, 365Pay, 4CEE Connect, Achievers, Adobe Acrobat Reader for Intune (Deprecated), Adobe Acrobat Reader, FleetSafer, Akumina EXP, AssetScan For Intune, FacilyLife, Appian for Intune, Atom Edge, Asana: Work in one place, Riskonnect Resilience, Avenza Maps for Intune, BlueJeans Video Conferencing, Diligent Boards, Box for EMM, iAnnotate for Intune / O365, Breezy for Intune, BuddyBoard, Comfy, F2 Manager - Intune, F2 Touch Intune, CellTrust SL2™ for Intune, Cerby, Cisco Jabber for Intune, Webex for Intune, Hey DAN for Intune, Clipchamp, Condeco, Lemur Pro for Intune, Datasite for Intune, DealCloud, Dooray! for Intune, Egnyte for Intune, ePRINTit SaaS, ArcGIS Indoors for Intune, FactSet, FileOrbis for Intune, Dialpad Meetings, Freshservice for Intune, Fuze Mobile for Intune, Meetio, Global Relay, Nitro PDF Pro - iPad & iPhone, Goodnotes 6, EVALARM, HCSS Field, HCSS Plans, Bob HR, HP Advance for Intune, Dashflow for InTune, iManage Work 10 For Intune, ixArma 6, Zero for Intune, Incorta (BestBuy), Omnipresence Go, CAPTOR, Intapp, ISEC7 Mobile Exchange Delegate, ISEC7 MAIL for Intune, KeePassium for Intune, Klaxoon for Intune, Kofax Power PDF Mobile, Leap Work for Intune, Nexis Newsdesk™ Mobile, VPSX Print for Intune, LumApps for Intune, M-Files for Intune, VerityRMS, Applications Manager - Intune, MangoApps, Work from Anywhere, My Portal By MangoApps, Senses, Meetings by Decisions, MentorcliQ, Align for InTune, Microsoft Azure, Cortana, Microsoft Designer, Microsoft Dynamics 365, Microsoft Invoicing, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Outlook Groups, Microsoft Loop, Skype for Business, Microsoft Kaizala, Microsoft Power Apps, Microsoft Edge, Microsoft 365 Admin, Microsoft Connections, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft Lens, Microsoft 365 Copilot, Microsoft OneNote, Microsoft Planner, Microsoft Power BI, Power Automate, Windows App, Azure Information Protection, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft StaffHub, Microsoft OneDrive, Microsoft Teams, Microsoft Lists, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Mobile Helix LINK for Intune, MoveInSync, MultiLine for Intune, MyITOps for Intune, PagerDuty for Intune, PenPoint, Board Papers, Board Papers for Intune, Team Papers for Intune, PK Protect for Intune, PrinterOn Print, PrinterOn for Microsoft, Qlik Sense Mobile, Recruitment.Exchange, Re:Work Enterprise, RICOH Spaces, RingCentral for Intune, Seismic, ServiceNow® Agent - Intune, Now® Mobile - Intune, Notate for Intune, Citrix ShareFile for Intune, Singletrack for Intune, Slack for Intune, SMART TeamWorks, Firstup - Intune, Enterprise Files for Intune, Mobile Work Orders, Symphony Messaging Intune, Synchrotab for Intune, Tableau Mobile for Intune, Talent.Exchange, Total Triage, Varicent, Vbrick Mobile, Veeva Vault CRM, Vera for Intune, Voltage Mail, HowNow, Workvivo, Secure Contacts, IntraActive, Beakon Mobile App, Island Enterprise Browser, Outreach Mobile, ArchXtract, Confidential File Viewer, ANDPAD, ANDPAD Blueprint, ANDPAD CHAT, ANDPAD Inspection, Box — Cloud Content Management, Mijn InPlanning, iBabs For Intune, myBLDNG, Speaking Email, Hearsay Relate for Intune, Naso Mobile, Board.Vision, Board.Vision for iPad, Idenprotect Go, Zoom for Intune, Viva Engage, CiiMS GO, Microsoft Excel, Microsoft Outlook, Microsoft Teams, Microsoft Edge, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft 365 Copilot, Microsoft OneNote, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Edge, Microsoft Edge, Microsoft Outlook, Microsoft Edge, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft 365 Copilot, Microsoft OneNote, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Edge, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft 365 Copilot, Microsoft Teams, Microsoft Edge, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft 365 Copilot, Microsoft OneNote, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, Microsoft Edge, Microsoft Edge, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft 365 Copilot, Microsoft OneNote, Microsoft SharePoint, Microsoft OneDrive, Microsoft Teams, Microsoft To-Do, LiquidText, Unique Moments, MyQ Roger: OCR scanner PDF, Fellow.app, Cinebody, MURAL - Visual Collaboration, Space Connect, Dialpad, 365Pay, 4CEE Connect, Achievers, Adobe Acrobat Reader for Intune (Deprecated), Adobe Acrobat Reader, FleetSafer, Akumina EXP, AssetScan For Intune, FacilyLife, Appian for Intune, Atom Edge, Asana: Work in one place, Riskonnect Resilience, Avenza Maps for Intune, BlueJeans Video Conferencing, Diligent Boards, Box for EMM, iAnnotate for Intune / O365, Breezy for Intune, BuddyBoard, Comfy, F2 Manager - Intune, F2 Touch Intune, CellTrust SL2™ for Intune, Cerby, Cisco Jabber for Intune, Webex for Intune, Hey DAN for Intune, Clipchamp, Condeco, Lemur Pro for Intune, Datasite for Intune, DealCloud, Dooray! for Intune, Egnyte for Intune, ePRINTit SaaS, ArcGIS Indoors for Intune, FactSet, FileOrbis for Intune, Dialpad Meetings, Freshservice for Intune, Fuze Mobile for Intune, Meetio, Global Relay, Nitro PDF Pro - iPad & iPhone, Goodnotes 6, EVALARM, HCSS Field, HCSS Plans, Bob HR, HP Advance for Intune, Dashflow for InTune, iManage Work 10 For Intune, ixArma 6, Zero for Intune, Incorta (BestBuy), Omnipresence Go, CAPTOR, Intapp, ISEC7 Mobile Exchange Delegate, ISEC7 MAIL for Intune, KeePassium for Intune, Klaxoon for Intune, Kofax Power PDF Mobile, Leap Work for Intune, Nexis Newsdesk™ Mobile, VPSX Print for Intune, LumApps for Intune, M-Files for Intune, VerityRMS, Applications Manager - Intune, MangoApps, Work from Anywhere, My Portal By MangoApps, Senses, Meetings by Decisions, MentorcliQ, Align for InTune, Microsoft Azure, Cortana, Microsoft Designer, Microsoft Dynamics 365, Microsoft Invoicing, Microsoft Dynamics 365 for phones, Field Service (Dynamics 365), Dynamics 365 Sales, Outlook Groups, Microsoft Loop, Skype for Business, Microsoft Kaizala, Microsoft Power Apps, Microsoft Edge, Microsoft 365 Admin, Microsoft Connections, Microsoft Excel, Microsoft Outlook, Microsoft PowerPoint, Microsoft Word, Microsoft Lens, Microsoft 365 Copilot, Microsoft OneNote, Microsoft Planner, Microsoft Power BI, Power Automate, Windows App, Azure Information Protection, Microsoft Defender Endpoint, Microsoft SharePoint, Microsoft StaffHub, Microsoft OneDrive, Microsoft Teams, Microsoft Lists, Microsoft To-Do, Microsoft Whiteboard, Work Folders, Mobile Helix LINK for Intune, MoveInSync, MultiLine for Intune, MyITOps for Intune, Omega 365, PagerDuty for Intune, PenPoint, Board Papers, Board Papers for Intune, Team Papers for Intune, PK Protect for Intune, PrinterOn Print, PrinterOn for Microsoft, Qlik Sense Mobile, Recruitment.Exchange, Re:Work Enterprise, RICOH Spaces, RingCentral for Intune, Seismic, ServiceNow® Agent - Intune, Now® Mobile - Intune, Notate for Intune, Citrix ShareFile for Intune, Singletrack for Intune, Slack for Intune, SMART TeamWorks, Firstup - Intune, Enterprise Files for Intune, Mobile Work Orders, Symphony Messaging Intune, Synchrotab for Intune, Tableau Mobile for Intune, Talent.Exchange, Total Triage, Varicent, Vbrick Mobile, Veeva Vault CRM, Vera for Intune, Voltage Mail, HowNow, Workvivo, Secure Contacts, IntraActive, Beakon Mobile App, Island Enterprise Browser, Outreach Mobile, ArchXtract, Confidential File Viewer, ANDPAD, ANDPAD Blueprint, ANDPAD CHAT, ANDPAD Inspection, Box — Cloud Content Management, Mijn InPlanning, iBabs For Intune, myBLDNG, Speaking Email, Hearsay Relate for Intune, Naso Mobile, Board.Vision, Board.Vision for iPad, Idenprotect Go, Zoom for Intune, Viva Engage, CiiMS GO",
        "AppsCustom": " com.omega365.omega365.ios, com.inboxzero.zeropro, com.microsoft.copilot, com.microsoft.ramobile, com.microsoft.stream,  com.omega365.omega365.ios, com.inboxzero.zeropro, com.microsoft.copilot, com.microsoft.ramobile,  com.omega365.omega365.ios, com.inboxzero.zeropro",
        "BackupOrgDataToICloudOrGoogle": "Allow",
        "SendOrgDataToOtherApps": "All apps",
        "AppsToExempt": ":, :, :, :, :, :, :, :, :, :, :, :, :, :, :",
        "SaveCopiesOfOrgData": "Allow",
        "AllowUserToSaveCopiesToSelectedServices": "OneDrive for Business, SharePoint, OneDrive for Business, SharePoint, OneDrive for Business, SharePoint, Photo library, OneDrive for Business, SharePoint, Photo library",
        "DataProtectionTransferTelecommunicationDataTo": "Any dialer app",
        "DataProtectionReceiveDataFromOtherApps": "All apps",
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
        "Scope": "Default, Default, Default, Default, Default, Default, Default, Default, Default, Default, Default, Default, Default, SEB Scope Tag, Default, Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "iOS/iPadOS",
        "Name": null,
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
        "Scope": "",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      }
    ],
    "OverviewCaDevicesAllUsers": {
      "nodes": [
        {
          "target": "Unmanaged",
          "source": "User sign in",
          "value": 5192
        },
        {
          "target": "Managed",
          "source": "User sign in",
          "value": null
        },
        {
          "target": "Non-compliant",
          "source": "Managed",
          "value": 10
        },
        {
          "target": "Compliant",
          "source": "Managed",
          "value": 405
        }
      ],
      "description": "Over the past 30 days, 7.8% of sign-ins were from compliant devices."
    },
    "ConfigWindowsEnrollment": [
      {
        "Type": "MDM",
        "PolicyName": "Microsoft Intune Enrollment",
        "AppliesTo": "None",
        "Groups": "Not Applicable"
      },
      {
        "Type": "MDM",
        "PolicyName": "Microsoft Intune",
        "AppliesTo": "All",
        "Groups": "Not Applicable"
      }
    ],
    "OverviewCaMfaAllUsers": {
      "nodes": [
        {
          "target": "No CA applied",
          "source": "User sign in",
          "value": 5219
        },
        {
          "target": "CA applied",
          "source": "User sign in",
          "value": 388
        },
        {
          "target": "No MFA",
          "source": "CA applied",
          "value": 313
        },
        {
          "target": "MFA",
          "source": "CA applied",
          "value": 75
        }
      ],
      "description": "Over the past 30 days, 1.3% of sign-ins were protected by conditional access policies enforcing multifactor."
    },
    "OverviewAuthMethodsAllUsers": {
      "nodes": [
        {
          "target": "Single factor",
          "source": "Users",
          "value": 41
        },
        {
          "target": "Phishable",
          "source": "Users",
          "value": 110
        },
        {
          "target": "Phone",
          "source": "Phishable",
          "value": 14
        },
        {
          "target": "Authenticator",
          "source": "Phishable",
          "value": 96
        },
        {
          "target": "Phish resistant",
          "source": "Users",
          "value": 48
        },
        {
          "target": "Passkey",
          "source": "Phish resistant",
          "value": 13
        },
        {
          "target": "WHfB",
          "source": "Phish resistant",
          "value": 35
        }
      ],
      "description": "Strongest authentication method registered by all users."
    },
    "DeviceOverview": {
      "WindowsJoinSummary": {
        "nodes": [
          {
            "target": "Entra joined",
            "source": "Windows",
            "value": 105.0
          },
          {
            "target": "Entra hybrid joined",
            "source": "Windows",
            "value": 4.0
          },
          {
            "target": "Entra registered",
            "source": "Windows",
            "value": 32.0
          },
          {
            "target": "Compliant",
            "source": "Entra joined",
            "value": 23.0
          },
          {
            "target": "Non-compliant",
            "source": "Entra joined",
            "value": 78.0
          },
          {
            "target": "Non-compliant",
            "source": "Entra hybrid joined",
            "value": 1.0
          },
          {
            "target": "Compliant",
            "source": "Entra registered",
            "value": 3.0
          },
          {
            "target": "Non-compliant",
            "source": "Entra registered",
            "value": 11.0
          }
        ],
        "description": "Join state and compliance of Windows devices"
      },
      "ManagedDevices": {
        "@odata.context": "https://graph.microsoft.com/beta/$metadata#microsoft.graph.managedDeviceOverview",
        "id": "81803ba5-3a37-4127-a2ee-2540b68e4cd1",
        "enrolledDeviceCount": 158,
        "mdmEnrolledCount": 60,
        "dualEnrolledDeviceCount": 82,
        "managedDeviceModelsAndManufacturers": null,
        "lastModifiedDateTime": "2025-10-17T09:27:44.9774012Z",
        "deviceOperatingSystemSummary": {
          "androidCount": 27,
          "iosCount": 12,
          "macOSCount": 11,
          "windowsMobileCount": 0,
          "windowsCount": 90,
          "unknownCount": 0,
          "androidDedicatedCount": 16,
          "androidDeviceAdminCount": 0,
          "androidFullyManagedCount": 0,
          "androidWorkProfileCount": 8,
          "androidCorporateWorkProfileCount": 3,
          "configMgrDeviceCount": 0,
          "aospUserlessCount": 0,
          "aospUserAssociatedCount": 0,
          "linuxCount": 2,
          "chromeOSCount": 0
        },
        "deviceExchangeAccessStateSummary": {
          "allowedDeviceCount": 0,
          "blockedDeviceCount": 0,
          "quarantinedDeviceCount": 0,
          "unknownDeviceCount": 0,
          "unavailableDeviceCount": 157
        }
      },
      "DeviceCompliance": {
        "@odata.context": "https://graph.microsoft.com/beta/$metadata#deviceManagement/deviceCompliancePolicyDeviceStateSummary/$entity",
        "inGracePeriodCount": 0,
        "configManagerCount": 1,
        "id": "fd7d3de8-b9c8-428b-bb09-9ee6def4ee83",
        "unknownDeviceCount": 16,
        "notApplicableDeviceCount": 0,
        "compliantDeviceCount": 35,
        "remediatedDeviceCount": 0,
        "nonCompliantDeviceCount": 106,
        "errorDeviceCount": 0,
        "conflictDeviceCount": 0
      }
    },
    "ConfigDeviceCompliancePolicies": [
      {
        "Platform": "Windows 10 and later",
        "PolicyName": "Compliance - MDE Risk Score",
        "DefenderForEndPoint": "Clear",
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
        "Platform": "iOS/iPadOS",
        "PolicyName": "iOS - UCL Default Compliance Policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": true,
        "MinPswdLength": 6,
        "PasswordType": "Device default",
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Not Applicable",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
        "MaxInactivityMin": null,
        "ActionForNoncomplianceDaysPushNotification": "Immediately",
        "ActionForNoncomplianceDaysSendEmail": "",
        "ActionForNoncomplianceDaysRemoteLock": "",
        "ActionForNoncomplianceDaysBlock": "Immediately",
        "ActionForNoncomplianceDaysRetire": "",
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "Windows 10 and later",
        "PolicyName": "FC - Windows Compliance Policies for a more secure future",
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
        "RequireFirewall": "Yes",
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
        "Platform": "Android Enterprise (Personal)",
        "PolicyName": "JonC - No One Lock",
        "DefenderForEndPoint": "",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": "Yes",
        "MinPswdLength": 6,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
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
        "Platform": "iOS/iPadOS",
        "PolicyName": "[CK] compliance",
        "DefenderForEndPoint": "",
        "MinOsVersion": "18",
        "MaxOsVersion": null,
        "RequirePswd": false,
        "MinPswdLength": null,
        "PasswordType": "Device default",
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Not Applicable",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
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
        "Platform": "iOS/iPadOS",
        "PolicyName": "ScottB-iOS-Device",
        "DefenderForEndPoint": "",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": false,
        "MinPswdLength": null,
        "PasswordType": "Device default",
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Not Applicable",
        "RootedJailbrokenDevices": "Blocked",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
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
        "Platform": "Windows 10 and later",
        "PolicyName": "JonC - Windows compliance",
        "DefenderForEndPoint": "",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": "",
        "MinPswdLength": null,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Yes",
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
        "PolicyName": "ScottB-macOS",
        "DefenderForEndPoint": "",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": "",
        "MinPswdLength": null,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "Not Applicable",
        "MaxDeviceThreatLevel": "",
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
        "Platform": "iOS/iPadOS",
        "PolicyName": "CBCompliancePolicyiOSTEST",
        "DefenderForEndPoint": "",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": false,
        "MinPswdLength": null,
        "PasswordType": "Device default",
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Not Applicable",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
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
        "Platform": "Windows 10 and later",
        "PolicyName": "Windows - UCL Default Compliance policy",
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
        "Platform": "Android Enterprise (Corp)",
        "PolicyName": "AE COPE - UCL Default compliance policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "11.0",
        "MaxOsVersion": null,
        "RequirePswd": "",
        "MinPswdLength": null,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
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
        "PolicyName": "(MN) macOS Compliance policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "14",
        "MaxOsVersion": null,
        "RequirePswd": "",
        "MinPswdLength": null,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "Not Applicable",
        "MaxDeviceThreatLevel": "",
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
        "Platform": "Windows 10 and later",
        "PolicyName": "FC - Custom Compliance for Patched inside last 30 days",
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
        "ActionForNoncomplianceDaysBlock": 7.0,
        "ActionForNoncomplianceDaysRetire": 30.0,
        "Scope": "Default",
        "IncludedGroups": "",
        "ExcludedGroups": ""
      },
      {
        "Platform": "iOS/iPadOS",
        "PolicyName": "Force Non-compliance test",
        "DefenderForEndPoint": "",
        "MinOsVersion": "9999.9999",
        "MaxOsVersion": null,
        "RequirePswd": false,
        "MinPswdLength": null,
        "PasswordType": "Device default",
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Not Applicable",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
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
        "Platform": "Android Enterprise (Corp)",
        "PolicyName": "CBCompliancePolicyTEST",
        "DefenderForEndPoint": "",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": "",
        "MinPswdLength": null,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
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
        "Platform": "Android Enterprise (Corp)",
        "PolicyName": "crosorio - translation test",
        "DefenderForEndPoint": "",
        "MinOsVersion": null,
        "MaxOsVersion": null,
        "RequirePswd": "Yes",
        "MinPswdLength": null,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
        "MaxInactivityMin": 1,
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
        "PolicyName": "[CK] IMM Compliance Policy",
        "DefenderForEndPoint": "",
        "MinOsVersion": "13",
        "MaxOsVersion": null,
        "RequirePswd": "Yes",
        "MinPswdLength": 6,
        "PasswordType": null,
        "PswdExpiryDays": 45,
        "CountOfPreviousPswdToBlock": 5,
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "Not Applicable",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "",
        "MaxInactivityMin": 60,
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
        "Platform": "Windows 10 and later",
        "PolicyName": "ScottB-Windows-Compliance",
        "DefenderForEndPoint": "",
        "MinOsVersion": "10.0.2",
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
        "Platform": "Android Enterprise (Personal)",
        "PolicyName": "JonC - Non Compliant Device",
        "DefenderForEndPoint": "",
        "MinOsVersion": "100.00",
        "MaxOsVersion": null,
        "RequirePswd": "",
        "MinPswdLength": null,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Yes",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
        "MaxInactivityMin": null,
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
        "Platform": "iOS/iPadOS",
        "PolicyName": "JonC - Disallowed Apps",
        "DefenderForEndPoint": "",
        "MinOsVersion": "260.000",
        "MaxOsVersion": null,
        "RequirePswd": false,
        "MinPswdLength": null,
        "PasswordType": "Device default",
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "Not Applicable",
        "RootedJailbrokenDevices": "",
        "MaxDeviceThreatLevel": "",
        "RequireFirewall": "Not Applicable",
        "MaxInactivityMin": null,
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
        "Platform": "macOS",
        "PolicyName": "[CK] Compliance Policy macOS",
        "DefenderForEndPoint": "",
        "MinOsVersion": "12",
        "MaxOsVersion": null,
        "RequirePswd": "Yes",
        "MinPswdLength": 8,
        "PasswordType": null,
        "PswdExpiryDays": null,
        "CountOfPreviousPswdToBlock": null,
        "RequireEncryption": "",
        "RootedJailbrokenDevices": "Not Applicable",
        "MaxDeviceThreatLevel": "",
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
      }
    ],
    "ConfigDeviceEnrollmentRestriction": [
      {
        "Platform": "Windows",
        "Priority": 2,
        "Name": "FC - Windows Block Anything but Autopilot",
        "MDM": "Allowed",
        "MinVer": null,
        "MaxVer": null,
        "PersonallyOwned": "Blocked",
        "BlockedManufacturers": "",
        "Scope": "Default",
        "AssignedTo": ""
      },
      {
        "Platform": "Windows",
        "Priority": 1,
        "Name": "Francesco - Block Windows Personal",
        "MDM": "Allowed",
        "MinVer": null,
        "MaxVer": null,
        "PersonallyOwned": "Blocked",
        "BlockedManufacturers": "",
        "Scope": "Default",
        "AssignedTo": "Francesco-APDevicePrep-Users"
      },
      {
        "Platform": "iOS/iPadOS",
        "Priority": "Default",
        "Name": "All users",
        "MDM": "Allowed",
        "MinVer": "15.7",
        "MaxVer": "",
        "PersonallyOwned": "Allowed",
        "BlockedManufacturers": "",
        "Scope": "",
        "AssignedTo": "All devices"
      },
      {
        "Platform": "Windows",
        "Priority": "Default",
        "Name": "All users",
        "MDM": "Allowed",
        "MinVer": "",
        "MaxVer": "",
        "PersonallyOwned": "Allowed",
        "BlockedManufacturers": "",
        "Scope": "",
        "AssignedTo": "All devices"
      },
      {
        "Platform": "Android device administrator",
        "Priority": "Default",
        "Name": "All users",
        "MDM": "Blocked",
        "MinVer": "",
        "MaxVer": "",
        "PersonallyOwned": "Allowed",
        "BlockedManufacturers": "",
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
        "PersonallyOwned": "Allowed",
        "BlockedManufacturers": "",
        "Scope": "",
        "AssignedTo": "All devices"
      },
      {
        "Platform": "Android Enterprise (work profile)",
        "Priority": "Default",
        "Name": "All users",
        "MDM": "Allowed",
        "MinVer": "",
        "MaxVer": "",
        "PersonallyOwned": "Allowed",
        "BlockedManufacturers": "",
        "Scope": "",
        "AssignedTo": "All devices"
      }
    ],
    "OverviewAuthMethodsPrivilegedUsers": {
      "nodes": [
        {
          "target": "Single factor",
          "source": "Users",
          "value": 2
        },
        {
          "target": "Phishable",
          "source": "Users",
          "value": 14
        },
        {
          "target": "Phone",
          "source": "Phishable",
          "value": 3
        },
        {
          "target": "Authenticator",
          "source": "Phishable",
          "value": 11
        },
        {
          "target": "Phish resistant",
          "source": "Users",
          "value": 3
        },
        {
          "target": "Passkey",
          "source": "Phish resistant",
          "value": 2
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
