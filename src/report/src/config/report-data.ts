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
    "ConfigWindowsEnrollment": [
      {
        "Type": "MDM",
        "PolicyName": "Microsoft Intune",
        "AppliesTo": "None",
        "Groups": "Not Applicable"
      }
    ],
        "ConfigDeviceEnrollmentRestriction": [
      {
        "Platform": "",
        "Priority": 2,
        "Name": "iOS Restriction 2",
        "MDM": "",
        "MinVer": "",
        "MaxVer": "",
        "PersonallyOwned": "",
        "BlockedManufacturers": "",
        "Scope": "",
        "AssignedTo": ""
      },
      {
        "Platform": "",
        "Priority": 1,
        "Name": "Andy Penn",
        "MDM": "",
        "MinVer": "",
        "MaxVer": "",
        "PersonallyOwned": "",
        "BlockedManufacturers": "",
        "Scope": "",
        "AssignedTo": ""
      },
      {
        "Platform": "",
        "Priority": 1,
        "Name": "Andy Penn",
        "MDM": "",
        "MinVer": "",
        "MaxVer": "",
        "PersonallyOwned": "",
        "BlockedManufacturers": "",
        "Scope": "",
        "AssignedTo": ""
      },
      {
        "Platform": "",
        "Priority": 1,
        "Name": "iOS Restriction",
        "MDM": "",
        "MinVer": "",
        "MaxVer": "",
        "PersonallyOwned": "",
        "BlockedManufacturers": "",
        "Scope": "",
        "AssignedTo": ""
      },
      {
        "Platform": "",
        "Priority": 1,
        "Name": "Win1",
        "MDM": "",
        "MinVer": "",
        "MaxVer": "",
        "PersonallyOwned": "",
        "BlockedManufacturers": "",
        "Scope": "",
        "AssignedTo": ""
      }
    ],
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
    }
  },
  "EndOfJson": "EndOfJson"
}
