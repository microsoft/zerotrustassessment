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
}

export interface ConfigWindowsEnrollment {
  Type: string | null;
  PolicyName: string | null;
  AppliesTo: string | null;
  Groups: string | null;
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
  "ExecutedAt": "2025-08-07T21:02:52.013609+10:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora Inc.",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "0.11.0",
  "LatestVersion": "0.11.0",
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
      "TestDescription": "Windows automatic enrollment enables a device to be automatically managed by Microsoft Intune as part of the initial sign on to the device. This ensures the device is protected by the security policies defined by the organization. \n\nThreats: Data Exfiltration, Data Deletion, Password Cracking, Data Spillage\n\nRemediation impact: This change will have low impact on your users.\n\nLearn more: [Enable MDM automatic enrollment for Windows](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/windows-enroll)\n\n**Remediation action**\n\n- Enable Windows devices to automatically enroll for management with Microsoft Intune.\n\n",
      "TestResult": "\nWindows automatic enrollment is enabled and configured correctly.\n",
      "TestRisk": "High",
      "TestSkipped": "",
      "TestTitle": "Windows automatic enrollment is enabled",
      "TestImpact": "Low",
      "TestStatus": "Passed",
      "TestCategory": "Device management",
      "TestSfiPillar": "Protect engineering systems"
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
    "OverviewCaDevicesAllUsers": {
      "nodes": [
        {
          "target": "Unmanaged",
          "value": 381,
          "source": "User sign in"
        },
        {
          "target": "Managed",
          "value": 0,
          "source": "User sign in"
        },
        {
          "target": "Non-compliant",
          "value": 0,
          "source": "Managed"
        },
        {
          "target": "Compliant",
          "value": 0,
          "source": "Managed"
        }
      ],
      "description": "Over the past 30 days, 0% of sign-ins were from compliant devices."
    },
    "OverviewAuthMethodsAllUsers": {
      "nodes": [
        {
          "target": "Single factor",
          "value": 45,
          "source": "Users"
        },
        {
          "target": "Phishable",
          "value": 23,
          "source": "Users"
        },
        {
          "target": "Phone",
          "value": 7,
          "source": "Phishable"
        },
        {
          "target": "Authenticator",
          "value": 16,
          "source": "Phishable"
        },
        {
          "target": "Phish resistant",
          "value": 6,
          "source": "Users"
        },
        {
          "target": "Passkey",
          "value": 4,
          "source": "Phish resistant"
        },
        {
          "target": "WHfB",
          "value": 2,
          "source": "Phish resistant"
        }
      ],
      "description": "Strongest authentication method registered by all users."
    },
    "OverviewCaMfaAllUsers": {
      "nodes": [
        {
          "target": "No CA applied",
          "value": 251,
          "source": "User sign in"
        },
        {
          "target": "CA applied",
          "value": 130,
          "source": "User sign in"
        },
        {
          "target": "No MFA",
          "value": 0,
          "source": "CA applied"
        },
        {
          "target": "MFA",
          "value": 130,
          "source": "CA applied"
        }
      ],
      "description": "Over the past 30 days, 34.1% of sign-ins were protected by conditional access policies enforcing multifactor."
    },
    "OverviewAuthMethodsPrivilegedUsers": {
      "nodes": [
        {
          "target": "Single factor",
          "value": 4,
          "source": "Users"
        },
        {
          "target": "Phishable",
          "value": 9,
          "source": "Users"
        },
        {
          "target": "Phone",
          "value": 2,
          "source": "Phishable"
        },
        {
          "target": "Authenticator",
          "value": 7,
          "source": "Phishable"
        },
        {
          "target": "Phish resistant",
          "value": 4,
          "source": "Users"
        },
        {
          "target": "Passkey",
          "value": 3,
          "source": "Phish resistant"
        },
        {
          "target": "WHfB",
          "value": 1,
          "source": "Phish resistant"
        }
      ],
      "description": "Strongest authentication method registered by privileged users."
    }
  },
  "EndOfJson": "EndOfJson"
}
