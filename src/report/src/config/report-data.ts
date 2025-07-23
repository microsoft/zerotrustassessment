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
  SkippedReason: string | null;
  TestResult: string;
  TestSkipped: string;
  TestStatus: string;
  TestTags: string[];
  TestId: string;
  TestDescription: string;
}

export const reportData: ZeroTrustAssessmentReport = {
  "ExecutedAt": "2025-07-23T19:31:38.874104+10:00",
  "TenantId": "7a8188ef-3450-43dd-82b8-e7a64b39d4bb",
  "TenantName": "Jozra",
  "Domain": "jozra.com",
  "Account": "merill.admin@jozra.com",
  "CurrentVersion": "0.10.0",
  "LatestVersion": "0.10.0",
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
      "TestImpact": "Low",
      "TestStatus": "Passed",
      "TestTags": [
        "Identity"
      ],
      "SkippedReason": null,
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestCategory": "Access control",
      "TestTitle": "App instance property lock is configured for all multitenant applications",
      "TestResult": "\nNo multi-tenant apps were found in this tenant.\n\n",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestRisk": "High",
      "TestDescription": "App instance property lock prevents changes to sensitive properties of a multitenant application after the application is provisioned in another tenant. Without a lock, critical properties such as application credentials can be maliciously or unintentionally modified, causing disruptions, increased risk, unauthorized access, or privilege escalations.\n\n**Remediation action**\nEnable the app instance property lock for all multitenant applications and specify the properties to lock.\n- [Configure an app instance lock](https://learn.microsoft.com/en-us/entra/identity-platform/howto-configure-app-instance-property-locks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-an-app-instance-lock)   \n",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestId": "21777"
    }
  ],
  "TenantInfo": {
    "OverviewAuthMethodsPrivilegedUsers": null,
    "OverviewCaDevicesAllUsers": null,
    "OverviewCaMfaAllUsers": null,
    "OverviewAuthMethodsAllUsers": null
  },
  "EndOfJson": "EndOfJson"
}
