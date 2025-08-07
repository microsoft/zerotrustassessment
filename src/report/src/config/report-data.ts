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
  "ExecutedAt": "2025-08-07T15:35:28.662392+10:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora Inc.",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "0.11.0",
  "LatestVersion": "0.11.0",
  "TestResultSummary": {
    "IdentityPassed": 0,
    "IdentityTotal": 0,
    "DevicesPassed": 0,
    "DevicesTotal": 1,
    "DataPassed": 0,
    "DataTotal": 0
  },
  "Tests": [
    {
      "TestTags": [
        "Devices"
      ],
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Devices"
      ],
      "SkippedReason": null,
      "TestPillar": "Devices",
      "TestId": "40000",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestResult": "\nPlanned for future release.\n",
      "TestRisk": "High",
      "TestSkipped": "",
      "TestTitle": "Windows automatic enrollment is enabled",
      "TestImpact": "Low",
      "TestStatus": "Failed",
      "TestCategory": "Device management",
      "TestSfiPillar": "Protect engineering systems"
    }
  ],
  "TenantInfo": {},
  "EndOfJson": "EndOfJson"
}
