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
  AgentOwnershipDistribution?: AgentOwnershipDistribution | null;
  OverviewCaMfaAllUsers?: SankeyData | null;
  OverviewCaDevicesAllUsers?: SankeyData | null;
  OverviewAuthMethodsPrivilegedUsers?: SankeyData | null;
  OverviewAuthMethodsAllUsers?: SankeyData | null;
  OverviewM365ProtectionCircuit?: M365ProtectionCircuitSankeyData | null;
  OverviewPrivateAccess?: PrivateAccessSankeyData | null;
  ConfigWindowsEnrollment?: ConfigWindowsEnrollment[] | null;
  ConfigDeviceEnrollmentRestriction?: ConfigDeviceEnrollmentRestriction[] | null;
  ConfigDeviceCompliancePolicies?: ConfigDeviceCompliancePolicies[] | null;
  ConfigDeviceAppProtectionPolicies?: ConfigDeviceAppProtectionPolicies[] | null;
  DeviceOverview?: DeviceOverview | null;
  TenantOverview?: TenantOverview | null;
  AgentOverview?: AgentOverview | null;
}

export interface AgentOwnershipDistribution {
  ownerAndSponsor: number;
  ownerOnly: number;
  sponsorOnly: number;
  neither: number;
  skippedCount?: number;
  agents?: Record<AgentOwnershipBucket, AgentOwnershipEntry[]>;
}

export type AgentOwnershipBucket = "ownerAndSponsor" | "ownerOnly" | "sponsorOnly" | "neither";

export interface AgentOwnershipEntry {
  displayName: string | null;
  accountEnabled: boolean;
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
  InfrastructurePassed?: number;
  InfrastructureTotal?: number;
  SecOpsPassed?: number;
  SecOpsTotal?: number;
  AIPassed?: number;
  AITotal?: number;
}
export interface SankeyData {
  nodes: SankeyDataNode[];
  description: string;
  totalDevices?: number;
  entrareigstered?: number;
  entrahybridjoined?: number;
  entrajoined?: number;
}

export interface PrivateAccessSankeyData extends SankeyData {
  adminAtRisk: boolean;
  populationMismatch: boolean;
  gates?: PrivateAccessGate[];
  overallStatus?: string;
  degraded?: boolean;
  applicationCount?: number;
  tenantWideAdmin?: number;
  scopedAdminAtRisk?: number;
}

export interface PrivateAccessGate {
  testId: string;
  name: string;
  status: string;
}

export interface M365ProtectionCircuitSankeyData extends SankeyData {
  gates?: CircuitStage[];
  overallStatus?: string;
  openStages?: string[];
  degraded?: boolean;
  countsAvailable?: boolean;
}

export interface CircuitStage {
  testId: string;
  name: string;
  status: string;
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
export interface AgentOverview {
  TotalAgents: number | null;
  ActiveUsers: number | null;
}
export interface DeviceOverview {
  DeviceSummary: DeviceSummary | null;
  DesktopDevicesSummary: SankeyData | null;
  MobileSummary: SankeyData | null;
  ManagedDevices: ManagedDevices | null;
  DeviceCompliance: DeviceCompliance | null;
  DeviceOwnership: DeviceOwnership | null;
  DeviceAntivirusProtection?: DeviceAntivirusProtection | null;
}

export interface DeviceAntivirusProtection {
  protectedDeviceCount: number | null;
}

export interface DeviceSummary {
  description: string;
  totalDevices: number | null;
  deviceOperatingSystemSummary: DeviceOperatingSystemSummary;
  mdeSensorInstalledOperatingSystemSummary?: DeviceOperatingSystemSummary | null;
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
  TestPillar: string | string[] | null;
  SkippedReason: string | null;
  TestResult: string;
  TestSkipped: string;
  TestStatus: string;
  TestTags: string[] | null;
  TestId: string;
  TestDescription: string;
}


// Populated by the reportDataPlaceholder Vite plugin, then replaced with the real assessment
// payload by Get-HtmlReport. The demo dataset lives in src/report/demo-report-data.json.
export const reportData: ZeroTrustAssessmentReport = (
  globalThis as unknown as { reportData: ZeroTrustAssessmentReport }
).reportData
